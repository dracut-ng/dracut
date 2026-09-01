/* extractinitrd.c

   This program is derived from Debian initramfs-tools' unmkinitramfs.

   Copyright (C) 2025-2026 Ben Hutchings <benh@debian.org>
   Copyright (C) 2025-2026 Benjamin Drung <benjamin.drung@canonical.com>

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see <https://www.gnu.org/licenses/>.
*/

/* extractinitrd: Unpack an initramfs */

#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <err.h>
#include <getopt.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

/*
 * The "new" cpio header supported by the kernel.  All fields after
 * magic hold 32-bit values in hexadecimal.  This is immediately
 * followed by the name, then contents.
 */
struct cpio_new {
        char c_magic[6];
        char c_ino[8];
        char c_mode[8];
        char c_uid[8];
        char c_gid[8];
        char c_nlink[8];
        char c_mtime[8];
        char c_filesize[8];
        char c_dev_maj[8];
        char c_dev_min[8];
        char c_rdev_maj[8];
        char c_rdev_min[8];
        char c_namesize[8];
        char c_chksum[8];
} __attribute__((packed));

#define CPIO_NEW_MAGIC     "070701"
#define CPIO_NEW_CRC_MAGIC "070702"
#define CPIO_MAGIC_LEN     6

/* Name of the last entry in a cpio archive */
#define CPIO_NAME_TRAILER "TRAILER!!!"

struct cpio_entry {
        const char *name;
        off_t      start, end;
};

struct cpio_handle {
        FILE       *file;
        const char *name;
        off_t      next_off;
        char       name_buf[PATH_MAX];
};

struct cpio_proc {
        int pid;
        int pipe;
};

enum format {
        FORMAT_CPIO_NEW,
        FORMAT_GZIP,
        FORMAT_BZIP2,
        FORMAT_LZMA,
        FORMAT_XZ,
        FORMAT_LZO,
        FORMAT_LZ4,
        FORMAT_ZSTD,
};

#define MAX_MAGIC_LEN 12

struct magic_entry {
        unsigned int  magic_len;
        unsigned char magic[MAX_MAGIC_LEN];
        enum format   format;
};

#define MAGIC_ENTRY(magic, format) { sizeof(magic) - 1, magic, format }

static const struct magic_entry magic_table[] = {
        MAGIC_ENTRY(CPIO_NEW_MAGIC,        FORMAT_CPIO_NEW),
        MAGIC_ENTRY(CPIO_NEW_CRC_MAGIC,    FORMAT_CPIO_NEW),
        MAGIC_ENTRY("\x1f\x8b\x08",        FORMAT_GZIP),
        MAGIC_ENTRY("BZh",                 FORMAT_BZIP2),
        MAGIC_ENTRY("\x5d\0\0",            FORMAT_LZMA),
        MAGIC_ENTRY("\xfd""7zXZ\0",        FORMAT_XZ),
        MAGIC_ENTRY("\x89LZO\0\r\n\x1a\n", FORMAT_LZO),
        /* lz4 "legacy" format, the only version that the kernel supports */
        MAGIC_ENTRY("\x02\x21\x4c\x18",    FORMAT_LZ4),
        MAGIC_ENTRY("\x28\xb5\x2f\xfd",    FORMAT_ZSTD),
        { 0 }
};

static const char *const decomp_table[][2] = {
        [FORMAT_GZIP] =  { "gzip", "-cd" },
        [FORMAT_BZIP2] = { "bzip2", "-cd" },
        [FORMAT_LZMA] =  { "lzma", "-cd" },
        [FORMAT_XZ] =    { "xzcat" },
        [FORMAT_LZO] =   { "lzop", "-cd" },
        [FORMAT_LZ4] =   { "lz4cat" },
        [FORMAT_ZSTD] =  { "zstd", "-cdq" },
};

struct part_range {
        unsigned long start;
        unsigned long end;
};

/* Parse single range options: "N", "N-M", "N-", or "-M" */
static struct part_range *parse_parts(const char *spec)
{
        char *endptr;
        unsigned long start = 1;
        unsigned long end = SIZE_MAX;

        if (isdigit((unsigned char)*spec)) {
                start = strtoul(spec, &endptr, 10);
                if (start == 0)
                        return NULL;

                if (*endptr == '-') {
                        endptr++;
                        if (isdigit((unsigned char)endptr[0])) {
                                end = strtoul(endptr, &endptr, 10);
                                if (end < start)
                                        return NULL;
                        } else if (endptr[0] == '\0') {
                                end = SIZE_MAX;
                        } else {
                                return NULL;
                        }
                } else if (*endptr == '\0') {
                        end = start;
                } else {
                        return NULL;
                }
        } else if (*spec == '-') {
                if (!isdigit((unsigned char)spec[1]))
                        return NULL;
                end = strtoul(spec + 1, &endptr, 10);
                if (end == 0)
                        return NULL;
        } else {
                return NULL;
        }

        if (*endptr != '\0')
                return NULL;

        struct part_range *range = malloc(sizeof(*range));
        if (!range)
                return NULL;

        range->start = start;
        range->end = end;
        return range;
}

static bool has_part_exceeded_range(const struct part_range *range, unsigned long part_idx)
{
        if (!range)
                return false;
        return part_idx > range->end;
}

static bool is_part_selected(const struct part_range *range, unsigned long part_idx)
{
        if (!range)
                return true;
        return part_idx >= range->start && part_idx <= range->end;
}

/* mkdir() but return success if name already exists as directory */
static bool mkdir_allow_exist(const char *name, mode_t mode)
{
        struct stat st;
        int orig_errno;

        if (mkdir(name, mode) == 0)
                return true;

        orig_errno = errno;
        if (orig_errno == EEXIST && stat(name, &st) == 0 && S_ISDIR(st.st_mode))
                return true;

        errno = orig_errno;
        return false;
}

/* write() with loop in case of partial writes */
static bool write_all(int fd, const void *buf, size_t len)
{
        size_t pos;
        ssize_t ret;

        pos = 0;
        do {
                ret = write(fd, (const char *)buf + pos, len - pos);
                if (ret < 0)
                        return false;
                pos += ret;
        } while (pos < len);

        return true;
}

/*
 * Warn about failure of fread.  This may be due to a file error
 * reported in errno, or EOF which is not.
 */
static void warn_after_fread_failure(FILE *file, const char *name)
{
        if (ferror(file))
                warn("%s", name);
        else
                warnx("%s: unexpected EOF", name);
}

/*
 * Parse one of the hexadecimal fields.  Don't use strtoul() because
 * it requires null-termination.
 */
static bool cpio_parse_hex(const char *field, uint32_t *value_p)
{
        const char digits[] = "0123456789ABCDEF", *p;
        uint32_t value = 0;
        unsigned int i;
        bool found_digit = false;

        /* Skip leading spaces */
        for (i = 0; i < 8 && field[i] == ' '; ++i)
                ;

        /* Parse digits up to end of field or null */
        for (; i < 8 && field[i] != 0; ++i) {
                p = strchr(digits, (char)toupper((unsigned char)field[i]));
                if (!p)
                        return false;
                value = (value << 4) | (p - digits);
                found_digit = true;
        }

        *value_p = value;
        return found_digit;
}

/* Align offset of file contents or header */
static off_t cpio_align(off_t off)
{
        return (off + 3) & ~3;
}

static struct cpio_handle *cpio_open(FILE *file, const char *name)
{
        struct cpio_handle *cpio;

        cpio = calloc(1, sizeof(*cpio));
        if (!cpio)
                return NULL;

        cpio->file = file;
        cpio->name = name;
        cpio->next_off = ftell(file);
        return cpio;
}

/*
 * Read next cpio header and name.
 * Return:
 * -1 on error
 *  0 if entry is trailer
 *  1 if entry is anything else
 */
static int cpio_get_next(struct cpio_handle *cpio, struct cpio_entry *entry)
{
        struct cpio_new header;
        uint32_t file_size, name_size;

        if (fseek(cpio->file, cpio->next_off, SEEK_SET) < 0 ||
            fread(&header, sizeof(header), 1, cpio->file) != 1) {
                warn_after_fread_failure(cpio->file, cpio->name);
                return -1;
        }

        if ((memcmp(header.c_magic, CPIO_NEW_MAGIC, CPIO_MAGIC_LEN) != 0 &&
             memcmp(header.c_magic, CPIO_NEW_CRC_MAGIC, CPIO_MAGIC_LEN) != 0) ||
            !cpio_parse_hex(header.c_filesize, &file_size) ||
            !cpio_parse_hex(header.c_namesize, &name_size)) {
                warnx("%s: cpio archive has invalid header", cpio->name);
                return -1;
        }

        entry->name = cpio->name_buf;
        entry->start = cpio->next_off;

        /* Calculate offset of the next header */
        uint32_t header_size = cpio_align(cpio->next_off + sizeof(header) + name_size);
        cpio->next_off = cpio_align(header_size + file_size);
        entry->end = cpio->next_off;

        if (name_size > sizeof(cpio->name_buf)) {
                warnx("%s: cpio member name is too long", cpio->name);
                return -1;
        }

        if (fread(cpio->name_buf, name_size, 1, cpio->file) != 1) {
                warn_after_fread_failure(cpio->file, cpio->name);
                return -1;
        }

        if (name_size == 0 || cpio->name_buf[name_size - 1] != 0) {
                warnx("%s: cpio member name is invalid", cpio->name);
                return -1;
        }

        return strcmp(entry->name, CPIO_NAME_TRAILER) != 0;
}

static void cpio_close(struct cpio_handle *cpio)
{
        free(cpio);
}

static bool copy_to_pipe(FILE *in_file, const char *in_filename,
                         off_t start, off_t end, int out_pipe)
{
        char buf[0x10000];
        off_t in_pos;
        size_t want_len, read_len;

        /* Set input position */
        fseek(in_file, start, SEEK_SET);
        in_pos = start;

        while (in_pos < end) {
                /* How much do we want to copy? */
                want_len = sizeof(buf);
                if ((ssize_t)want_len > end - in_pos)
                        want_len = end - in_pos;

                /* Read to buffer; update input position */
                read_len = fread(buf, 1, want_len, in_file);
                if (!read_len) {
                        warn_after_fread_failure(in_file, in_filename);
                        return false;
                }
                in_pos += read_len;

                /* Write to pipe */
                if (!write_all(out_pipe, buf, read_len)) {
                        warn("pipe write");
                        return false;
                }
        }

        return true;
}

static bool handle_uncompressed(FILE *in_file, const char *in_filename,
                                int out_pipe, bool extract)
{
        struct cpio_handle *cpio;
        struct cpio_entry entry;
        uint32_t pad;
        int ret;

        cpio = cpio_open(in_file, in_filename);
        if (!cpio)
                return false;

        while ((ret = cpio_get_next(cpio, &entry)) > 0) {
                if (extract && !copy_to_pipe(in_file, in_filename,
                                             entry.start, entry.end, out_pipe)) {
                        ret = -1;
                        break;
                }
        }

        cpio_close(cpio);

        if (ret < 0)
                return false;

        /* Skip trailer and any zero padding */
        fseek(in_file, entry.end, SEEK_SET);
        while (fread(&pad, sizeof(pad), 1, in_file)) {
                if (pad != 0) {
                        fseek(in_file, -sizeof(pad), SEEK_CUR);
                        break;
                }
        }

        return true;
}

static bool handle_compressed(FILE *in_file, enum format format, int out_pipe, bool debug)
{
        const char *const *argv = decomp_table[format];
        int in_fd = fileno(in_file);
        off_t in_pos = ftell(in_file);
        int pid, wstatus;

        if (debug)
                fprintf(stderr, "extractinitrd: Executing %s %s\n", argv[0], argv[1]);

        pid = fork();
        if (pid < 0)
                return false;

        /* Child */
        if (pid == 0) {
                /*
                 * Make in_file stdin.  Reset the position of the file
                 * descriptor because stdio will have read-ahead from
                 * the position it reported.
                 */
                dup2(in_fd, 0);
                close(in_fd);
                lseek(0, in_pos, SEEK_SET);

                /* Make out_pipe stdout */
                dup2(out_pipe, 1);
                close(out_pipe);

                execlp(argv[0], argv[0], argv[1], NULL);
                _exit(127);
        }

        /* Parent: wait for child */
        if (waitpid(pid, &wstatus, 0) != pid ||
            !WIFEXITED(wstatus) || WEXITSTATUS(wstatus) != 0) {
                warnx("%s failed", argv[0]);
                return false;
        }
        return true;
}

static bool write_trailer(int out_pipe)
{
        struct {
                struct cpio_new header;
                char name[sizeof(CPIO_NAME_TRAILER)];
                char pad[-(sizeof(struct cpio_new) + sizeof(CPIO_NAME_TRAILER)) & 3];
        } __attribute__((packed)) trailer;
        char name_size[8 + 1];

        static_assert((sizeof(trailer) & 3) == 0, "pad miscalculated");

        memset(&trailer.header, '0', sizeof(trailer.header));
        memcpy(trailer.header.c_magic, CPIO_NEW_MAGIC, CPIO_MAGIC_LEN);
        sprintf(name_size, "%08zX", sizeof(CPIO_NAME_TRAILER));
        memcpy(trailer.header.c_namesize, name_size,
               sizeof(trailer.header.c_namesize));

        strcpy(trailer.name, CPIO_NAME_TRAILER);

        memset(&trailer.pad, 0, sizeof(trailer.pad));

        if (!write_all(out_pipe, &trailer, sizeof(trailer))) {
                warn("pipe write");
                return false;
        }

        return true;
}

static bool spawn_cpio(int optc, const char **optv, const char *dirname,
                       bool to_stdout, bool debug, struct cpio_proc *proc)
{
        const char *argv[optc + 5];
        int pipe_fds[2], pid;
        size_t argc;

        /* Combine base cpio command with extra options */
        argc = 0;
        argv[argc++] = "cpio";
        argv[argc++] = "-i";
        argv[argc++] = "--quiet";
        if (to_stdout)
                argv[argc++] = "--to-stdout";
        else
                argv[argc++] = "-m";
        while (optc--)
                argv[argc++] = *optv++;
        argv[argc] = NULL;

        if (debug) {
                fprintf(stderr, "extractinitrd: Executing");
                for (size_t i = 0; argv[i] != NULL; i++)
                        fprintf(stderr, " %s", argv[i]);
                if (dirname)
                        fprintf(stderr, " (in directory: %s)", dirname);
                fprintf(stderr, "\n");
        }

        if (pipe(pipe_fds)) {
                warn("pipe");
                return false;
        }
        pid = fork();
        if (pid < 0) {
                warn("fork");
                return false;
        }

        /* Child */
        if (pid == 0) {
                if (dirname && chdir(dirname))
                        _exit(127);

                /*
                 * Close write end of the pipe; make the read end
                 * stdout.
                 */
                close(pipe_fds[1]);
                dup2(pipe_fds[0], 0);
                close(pipe_fds[0]);

                execvp("cpio", (char **)argv);
                _exit(127);
        }

        /*
         * Parent: close read end of the pipe; return child pid and
         * write end of pipe.
         */
        close(pipe_fds[0]);
        proc->pid = pid;
        proc->pipe = pipe_fds[1];
        return true;
}

static bool end_cpio(const struct cpio_proc *proc, bool ok)
{
        int wstatus;

        close(proc->pipe);

        if (ok) {
                if (waitpid(proc->pid, &wstatus, 0) != proc->pid ||
                    !WIFEXITED(wstatus) || WEXITSTATUS(wstatus) != 0) {
                        warnx("cpio failed");
                        return false;
                }
        } else {
                kill(proc->pid, SIGTERM);
        }

        return true;
}

// Run cpio --help and check if --no-absolute-filenames is listed
// Assume existing support in case of failure.
static bool cpio_supports_no_absolute_filenames(void)
{
        int pipe_fds[2];
        if (pipe(pipe_fds) != 0)
                return true;

        pid_t pid = fork();
        if (pid < 0) {
                close(pipe_fds[0]);
                close(pipe_fds[1]);
                return true;
        }

        if (pid == 0) {
                close(pipe_fds[0]);
                dup2(pipe_fds[1], STDOUT_FILENO);
                dup2(pipe_fds[1], STDERR_FILENO);
                close(pipe_fds[1]);
                execlp("cpio", "cpio", "--help", NULL);
                _exit(127);
        }

        close(pipe_fds[1]);
        char buf[1024];
        ssize_t n;
        bool found = false;

        while ((n = read(pipe_fds[0], buf, sizeof(buf) - 1)) > 0) {
                buf[n] = '\0';
                if (strstr(buf, "--no-absolute-filenames") != NULL) {
                        found = true;
                        break;
                }
        }

        close(pipe_fds[0]);
        waitpid(pid, NULL, 0);
        return found;
}

static const struct option long_opts[] = {
        { "help",          no_argument,       NULL, 'h' },
        { "list",          no_argument,       NULL, 'l' },
        { "parts",         required_argument, NULL, 'P' },
        { "verbose",       no_argument,       NULL, 'v' },
        { "to-stdout",     no_argument,       NULL, 's' },
        { "directory",     required_argument, NULL, 'D' },
        { "debug",         no_argument,       NULL, 'd' },
        { NULL,            0,                 NULL, 0 }
};

static void usage(FILE *stream)
{
        fprintf(stream, "\
\n\
Usage: dracut-extractinitrd [-l|--list] [-P|--parts RANGE] [--to-stdout] [-D|--directory DIR]\n\
                     [-v|--verbose] [--debug] INITRD [PATTERN...]\n\
\n\
Options:\n\
  -l, --list           List the contents of the cpio archives\n\
  -P, --parts RANGE    Only operate on specified cpio archive range (e.g. 1, 1-3, 2-, -2)\n\
  --to-stdout          Extract files to standard output\n\
  -D, --directory DIR  Change to directory DIR before extracting\n\
  -v, --verbose        Display verbose messages about extraction\n\
  --debug              Print debugging information\n\
\n"
               );
}

int main(int argc, char **argv)
{
        int opt;
        bool do_list = false;
        bool verbose = false;
        bool to_stdout = false;
        bool debug = false;
        const char *out_dirname = NULL;
        struct part_range *range = NULL;
        const char *in_filename;
        FILE *in_file;
        const char *cpio_optv[argc];
        int cpio_optc = 0;
        struct cpio_proc cpio_proc = { 0 };
        bool ok = true;

        /* Parse options */
        opterr = 0;
        while ((opt = getopt_long(argc, argv, "hlP:vD:s", long_opts, NULL)) >= 0) {
                switch (opt) {
                case '?':
                        usage(stderr);
                        return 2;
                case 'h':
                        usage(stdout);
                        return 0;
                case 'l':
                        do_list = true;
                        break;
                case 'P':
                        range = parse_parts(optarg);
                        if (!range)
                                errx(2, "invalid --parts: '%s'", optarg);
                        break;
                case 'v':
                        verbose = true;
                        break;
                case 's':
                        to_stdout = true;
                        break;
                case 'D':
                        out_dirname = optarg;
                        break;
                case 'd':
                        debug = true;
                        break;
                }
        }

        /* Check number of non-option arguments */
        if (argc - optind < 1) {
                usage(stderr);
                return 2;
        }

        in_filename = argv[optind];
        optind++;

        /* Set up input file and output directory */
        in_file = fopen(in_filename, "rb");
        if (!in_file)
                err(1, "%s", in_filename);
        if (out_dirname != NULL) {
                if (!mkdir_allow_exist(out_dirname, 0777))
                        err(1, "%s", out_dirname);
        }

        /* Spawn cpio with appropriate options and pipe */
        if (do_list)
                cpio_optv[cpio_optc++] = "-t";
        if (verbose)
                cpio_optv[cpio_optc++] = "-v";
        if (!do_list && !to_stdout && cpio_supports_no_absolute_filenames())
                cpio_optv[cpio_optc++] = "--no-absolute-filenames";
        while (optind < argc)
                cpio_optv[cpio_optc++] = argv[optind++];

        if (!spawn_cpio(cpio_optc, cpio_optv, out_dirname, to_stdout, debug, &cpio_proc))
                return 1;

        /* Iterate over archives within the initramfs */
        for (unsigned long current_part = 1; ; current_part++) {
                unsigned char magic_buf[MAX_MAGIC_LEN];
                size_t read_len;
                const struct magic_entry *me;

                if (has_part_exceeded_range(range, current_part)) {
                        if (!write_trailer(cpio_proc.pipe))
                                ok = false;
                        break;
                }

                /* Peek at first bytes of next archive; handle EOF */
                read_len = fread(magic_buf, 1, sizeof(magic_buf), in_file);
                if (read_len == 0) {
                        /*
                         * EOF with no compressed archive. Add back a
                         * trailer to keep cpio happy.
                         */
                        if (ferror(in_file)) {
                                warn("%s", in_filename);
                                ok = false;
                        }
                        if (!write_trailer(cpio_proc.pipe))
                                ok = false;
                        break;
                }
                fseek(in_file, -(long)read_len, SEEK_CUR);

                /* Identify format */
                for (me = magic_table; me->magic_len; ++me)
                        if (read_len >= me->magic_len &&
                            memcmp(magic_buf, me->magic, me->magic_len) == 0)
                                break;
                if (me->magic_len == 0) {
                        warnx("%s: unrecognised compression or corrupted file",
                              in_filename);
                        ok = false;
                        break;
                }

                bool selected = is_part_selected(range, current_part);

                if (me->format == FORMAT_CPIO_NEW) {
                        ok = handle_uncompressed(in_file, in_filename,
                                                 cpio_proc.pipe, selected);
                        if (!ok)
                                break;
                } else {
                        if (selected) {
                                ok = handle_compressed(in_file, me->format,
                                                       cpio_proc.pipe, debug);
                        }
                        break;
                }
        }

        fclose(in_file);
        free(range);

        if (!end_cpio(&cpio_proc, ok))
                ok = false;

        return !ok;
}
