#!/usr/bin/env bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="test dracut-extractinitrd"

# Uncomment this to debug failures
#DEBUG="1"

test_check() {
    require_binaries_for_test cpio diff find gzip
}

# Dummy compressor; wrapper for cat that ignores its argument (-c)
# shellcheck disable=SC2329
no_compressor() {
    # shellcheck disable=SC2317
    cat
}

make_one_archive() {
    local type="$1"
    local i="$2"
    local dir_name
    local j

    case "$type" in
        early)
            dir_name="kernel/dir$i"
            ;;
        main)
            dir_name="dir$i"
            ;;
        *)
            echo >&2 "E: Bad archive type $type"
            exit 1
            ;;
    esac

    mkdir -p "$TESTDIR/input/$type$i/$dir_name"
    for j in $(seq 0 9); do
        size=$((j * 987 + i * 654 + 321))
        dd if=/dev/urandom of="$TESTDIR/input/$type$i/$dir_name/file$j" \
            bs="$size" count=1 status=none
    done
    echo "$type$i" > "$TESTDIR/input/$type$i/$dir_name/metadata"
    (
        cd "$TESTDIR/input/$type$i"
        find . -print0 | sort -z | cpio -o --null --quiet -H newc > ../"$type$i.cpio"
    )
}

construct_initrd_image() {
    local n_early="$1"
    local n_main="$2"
    local compressor="$3"

    # BusyBox lzma only supports extraction.
    if [ "$compressor" = "lzma" ] && ! lzma --help 2>&1 | grep -qwi "compress"; then
        compressor="xz --format=lzma"
    fi

    : > "$TESTDIR/initrd.img"
    for i in $(seq 0 $((n_early - 1))); do
        cat "$TESTDIR/input/early$i.cpio" >> "$TESTDIR/initrd.img"
    done
    for i in $(seq 0 $((n_main - 2))); do
        cat "$TESTDIR/input/main$i.cpio" >> "$TESTDIR/initrd.img"
    done
    if [ "$n_main" -ge 1 ]; then
        $compressor -c < "$TESTDIR/input/main$((n_main - 1)).cpio" \
            >> "$TESTDIR/initrd.img"
    fi
}

verify_extraction() {
    local n_early="$1"
    local n_main="$2"

    # Construct what we expect output to look like
    rm -rf "$TESTDIR/reference"
    mkdir "$TESTDIR/reference"
    for i in $(seq 0 $((n_early - 1))); do
        mkdir -p "$TESTDIR/reference/kernel"
        ln -s ../../input/"early$i/kernel/dir$i" "$TESTDIR/reference/kernel/"
    done
    for i in $(seq 0 $((n_main - 1))); do
        ln -s ../input/"main$i/dir$i" "$TESTDIR/reference/"
    done

    # Compare reference and output
    diff -r "$TESTDIR/reference" "$TESTDIR/output" || {
        echo >&2 'E: Output files do not match input'
        return 1
    }
}

# Test extracting the full initrd with all cpio parts in all combinations.
test_full_extraction() {
    local compressor="$1"
    # Test up to 2 early and 2 main cpio archives, and all supported
    # compressors (including none) for the last main archive
    for n_early in 0 1 2; do
        for n_main in 0 1 2; do
            # There must be at least 1 archive
            if [ $((n_early + n_main)) -eq 0 ]; then
                continue
            fi
            # If last archive is early, it can't be compressed
            if [ $n_main -eq 0 ] && [ "$compressor" != no_compressor ]; then
                continue
            fi

            echo "I: Testing full extraction on initrd with $n_early early + $n_main main archive(s) with $compressor"
            construct_initrd_image "$n_early" "$n_main" "$compressor"

            # Unpack it
            rm -rf "$TESTDIR/output"
            "${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} -D "$TESTDIR/output" "$TESTDIR/initrd.img" || {
                echo >&2 'E: dracut-extractinitrd failed'
                return 1
            }

            verify_extraction "$n_early" "$n_main"
        done
    done
}

test_part_extraction() {
    local compressor="$1"

    construct_initrd_image "1" "2" "$compressor"

    echo "I: Testing extracting part 1 of initrd with $compressor"
    rm -rf "$TESTDIR/output"
    "${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} -D "$TESTDIR/output" --parts 1 "$TESTDIR/initrd.img" || {
        echo >&2 'E: dracut-extractinitrd failed'
        return 1
    }
    verify_extraction 1 0

    echo "I: Testing extracting part 2 of initrd with $compressor"
    rm -rf "$TESTDIR/output"
    "${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} -D "$TESTDIR/output" --parts 2 "$TESTDIR/initrd.img" || {
        echo >&2 'E: dracut-extractinitrd failed'
        return 1
    }
    verify_extraction 0 1

    echo "I: Testing extracting everything except part 1 of initrd with $compressor"
    rm -rf "$TESTDIR/output"
    "${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} -D "$TESTDIR/output" --parts 2- "$TESTDIR/initrd.img" || {
        echo >&2 'E: dracut-extractinitrd failed'
        return 1
    }
    verify_extraction 0 2
}

assert_equal() {
    local got="$1"
    local expected="$2"

    if [ "$got" != "$expected" ]; then
        echo "E: '$got' does not match '$expected'" >&2
        return 1
    fi
}

test_extract_to_stdout() {
    local compressor="$1"

    construct_initrd_image "2" "2" "$compressor"

    echo "I: Testing pattern does not match anything of initrd with $compressor"
    metadata=$("${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} --to-stdout \
        "$TESTDIR/initrd.img" -- non-existing)
    assert_equal "$metadata" ''

    echo "I: Testing extracting early 1 metadata of initrd with $compressor"
    metadata=$("${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} --to-stdout \
        "$TESTDIR/initrd.img" -- kernel/dir0/metadata)
    assert_equal "$metadata" 'early0'

    echo "I: Testing extracting two metadata files of initrd with $compressor"
    metadata=$("${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} --to-stdout \
        "$TESTDIR/initrd.img" -- kernel/dir1/metadata dir0/metadata)
    assert_equal "$metadata" $'early1\nmain0'
}

test_list() {
    local compressor="$1"

    construct_initrd_image "1" "2" "$compressor"

    echo "I: Testing list full content of initrd with $compressor"
    metadata=$("${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} --list "$TESTDIR/initrd.img")
    assert_equal "$metadata" '.
kernel
kernel/dir0
kernel/dir0/file0
kernel/dir0/file1
kernel/dir0/file2
kernel/dir0/file3
kernel/dir0/file4
kernel/dir0/file5
kernel/dir0/file6
kernel/dir0/file7
kernel/dir0/file8
kernel/dir0/file9
kernel/dir0/metadata
.
dir0
dir0/file0
dir0/file1
dir0/file2
dir0/file3
dir0/file4
dir0/file5
dir0/file6
dir0/file7
dir0/file8
dir0/file9
dir0/metadata
.
dir1
dir1/file0
dir1/file1
dir1/file2
dir1/file3
dir1/file4
dir1/file5
dir1/file6
dir1/file7
dir1/file8
dir1/file9
dir1/metadata'

    echo "I: Testing list part 2 of initrd with $compressor"
    metadata=$("${PKGLIBDIR}/dracut-extractinitrd" ${DEBUG:+--debug} --list --part 2 "$TESTDIR/initrd.img")
    assert_equal "$metadata" '.
dir0
dir0/file0
dir0/file1
dir0/file2
dir0/file3
dir0/file4
dir0/file5
dir0/file6
dir0/file7
dir0/file8
dir0/file9
dir0/metadata'
}

test_run() {
    for compressor in no_compressor gzip bzip2 lzma xz lzop 'lz4 -l' zstd; do
        if ! command -v "${compressor%% *}" &> /dev/null; then
            echo "I: Skip testing with '$compressor' because the command is missing." >&2
            continue
        fi

        test_full_extraction "$compressor"
        test_part_extraction "$compressor"
        test_extract_to_stdout "$compressor"
        test_list "$compressor"
    done
}

test_setup() {
    # Create input files and archives
    mkdir "$TESTDIR/input"
    for in_type in early main; do
        for i in 0 1 2; do
            make_one_archive "$in_type" "$i"
        done
    done
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
