#!/bin/bash
#
# Copyright 2005-2010 Harald Hoyer <harald@redhat.com>
# Copyright 2005-2010 Red Hat, Inc.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

usage() {
    {
        echo "Usage: ${0##*/} [options] [<initramfs file> [<filename> [<filename> [...] ]]]"
        echo "Usage: ${0##*/} [options] -k <kernel version>"
        echo
        echo "-h, --help                  print a help message and exit."
        echo "-s, --size                  sort the contents of the initramfs by size."
        echo "-m, --mod                   list modules."
        echo "-f, --file <filename>       print the contents of <filename>."
        echo "--unpack                    unpack the initramfs, instead of displaying the contents."
        echo "                            If optional filenames are given, will only unpack specified files,"
        echo "                            else the whole image will be unpacked. Won't unpack anything from early cpio part."
        echo "--unpackearly               unpack the early microcode part of the initramfs."
        echo "                            Same as --unpack, but only unpack files from early cpio part."
        echo "-v, --verbose               unpack verbosely."
        echo "-k, --kver <kernel version> inspect the initramfs of <kernel version>."
        echo
    } >&2
}

[[ ${dracutbasedir-} ]] || dracutbasedir="$(realpath -e "${BASH_SOURCE[0]%/*}/../lib/dracut")"
[[ ${dracutbindir-} ]] || dracutbindir="${dracutbasedir}"

sorted=0
modules=0
unset verbose
declare -A filenames

unset POSIXLY_CORRECT
TEMP=$(getopt \
    -o "vshmf:k:" \
    --long kver: \
    --long file: \
    --long mod \
    --long help \
    --long size \
    --long unpack \
    --long unpackearly \
    --long verbose \
    -- "$@")

# shellcheck disable=SC2181
if (($? != 0)); then
    usage
    exit 1
fi

eval set -- "$TEMP"

while (($# > 0)); do
    case $1 in
        -k | --kver)
            KERNEL_VERSION="$2"
            shift
            ;;
        -f | --file)
            filenames[${2#/}]=1
            shift
            ;;
        -s | --size) sorted=1 ;;
        -h | --help)
            usage
            exit 0
            ;;
        -m | --mod) modules=1 ;;
        -v | --verbose) verbose="--verbose" ;;
        --unpack) unpack=1 ;;
        --unpackearly) unpackearly=1 ;;
        --)
            shift
            break
            ;;
        *)
            usage
            exit 1
            ;;
    esac
    shift
done

CPIO=cpio
if command -v 3cpio > /dev/null; then
    if threecpio_help_output=$(3cpio --help); then
        if [[ $threecpio_help_output == *--make-directories* ]]; then
            CPIO=3cpio
        fi
    elif command -v cpio > /dev/null; then
        echo "Warning: Calling '3cpio --help' failed. Cannot check if 3cpio supports --make-directories. Falling back to cpio."
    else
        echo "Warning: Calling '3cpio --help' failed. Cannot check if 3cpio supports --make-directories."
        CPIO=3cpio
    fi
    unset threecpio_help_output
fi

if ! [[ $KERNEL_VERSION ]]; then
    if type -P systemd-detect-virt &> /dev/null && ! systemd-detect-virt -c &> /dev/null && ! systemd-detect-virt -r &> /dev/null; then
        KERNEL_VERSION="$(uname -r)"
    else
        # shellcheck disable=SC2012
        KERNEL_VERSION="$(cd /lib/modules && ls -1v | tail -1)"
    fi
fi

find_initrd_for_kernel_version() {
    local kernel_version="$1"
    local base_path files initrd machine_id

    if [[ -d /efi/Default ]] || [[ -d /boot/Default ]] || [[ -d /boot/efi/Default ]]; then
        machine_id="Default"
    elif [[ -s /etc/machine-id ]]; then
        read -r machine_id < /etc/machine-id
        [[ $machine_id == "uninitialized" ]] && machine_id="Default"
    else
        machine_id="Default"
    fi

    if [ -n "$machine_id" ]; then
        for base_path in /efi /boot /boot/efi; do
            initrd="${base_path}/${machine_id}/${kernel_version}/initrd"
            if [ -f "$initrd" ]; then
                echo "$initrd"
                return
            fi
        done
    fi

    if [[ -f /lib/modules/${kernel_version}/initrd ]]; then
        echo "/lib/modules/${kernel_version}/initrd"
    elif [[ -f /lib/modules/${kernel_version}/initramfs.img ]]; then
        echo "/lib/modules/${kernel_version}/initramfs.img"
    elif [[ -f /boot/initramfs-${kernel_version}.img ]]; then
        echo "/boot/initramfs-${kernel_version}.img"
    elif [[ -f /usr/lib/modules/${kernel_version}/initramfs.img ]]; then
        echo "/usr/lib/modules/${kernel_version}/initramfs.img"
    else
        files=(/boot/initr*"${kernel_version}"*)
        if [ "${#files[@]}" -ge 1 ] && [ -e "${files[0]}" ]; then
            echo "${files[0]}"
        fi
    fi
}

if [[ $1 ]]; then
    image="$1"
    if ! [[ -f $image ]]; then
        {
            echo "$image does not exist"
            echo
        } >&2
        usage
        exit 1
    fi
else
    image=$(find_initrd_for_kernel_version "$KERNEL_VERSION")
fi

shift
while (($# > 0)); do
    filenames[${1#/}]=1
    shift
done

if ! [[ -f $image ]]; then
    {
        echo "No <initramfs file> specified and the default image '$image' cannot be accessed!"
        echo
    } >&2
    usage
    exit 1
fi
image=$(realpath "$image")

TMPDIR="$(mktemp -d -t lsinitrd.XXXXXX)"
# shellcheck disable=SC2064
trap "rm -rf '$TMPDIR'" EXIT

dracutlibdirs() {
    for d in lib64/dracut lib/dracut usr/lib64/dracut usr/lib/dracut; do
        echo "$d/$1"
    done
}

SQUASH_TMPFILE=""
SQUASH_EXTRACT="$TMPDIR/squash-extract"

# Takes optional pattern arguments
cpio_extract() {
    if [ "$CPIO" = 3cpio ]; then
        3cpio --extract --make-directories --parts "$parts" $verbose "$image" -- "$@"
    else
        $CAT "$image" 2> /dev/null | cpio -id --quiet $verbose -- "$@"
    fi
}

# Takes optional pattern arguments
cpio_extract_to_stdout() {
    if [ "$CPIO" = 3cpio ]; then
        3cpio --extract --parts "$parts" --to-stdout "$image" -- "$@"
    else
        $CAT "$image" 2> /dev/null | cpio --extract --quiet --to-stdout -- "$@"
    fi
}

# Takes optional pattern arguments
cpio_list() {
    if [ "$CPIO" = 3cpio ]; then
        3cpio --list --parts "$parts" --verbose "$image" -- "$@"
    else
        $CAT "$image" 2> /dev/null | cpio --extract --verbose --quiet --list -- "$@"
    fi
}

extract_squash_img() {
    local _img _tmp

    [[ $SQUASH_TMPDIR == none ]] && return 1
    [[ -s $SQUASH_TMPFILE ]] && return 0

    # Before dracut 104 the image was named squash-root.img. Keep the old name
    # so newer versions of lsinitrd can inspect initrds build with older dracut
    # versions.
    for _img in squash-root.img squashfs-root.img erofs-root.img; do
        _tmp="$TMPDIR/$_img"
        cpio_extract_to_stdout "$_img" > "$_tmp"
        [[ -s $_tmp ]] || continue

        SQUASH_TMPFILE="$_tmp"

        # fsck.erofs doesn't allow extracting single files or listing the
        # content of the image. So always extract the full image.
        if [[ $_img == erofs-root.img ]]; then
            mkdir -p "$SQUASH_EXTRACT"
            fsck.erofs --extract="$SQUASH_EXTRACT/erofs-root" --overwrite "$SQUASH_TMPFILE" 2> /dev/null
            ((ret += $?))
        fi

        break
    done

    if [[ -z $SQUASH_TMPFILE ]]; then
        SQUASH_TMPDIR=none
        return 1
    fi

    return 0
}

extract_files() {
    local nofileinfo

    ((${#filenames[@]} == 1)) && nofileinfo=1
    for f in "${!filenames[@]}"; do
        [[ $nofileinfo ]] || echo "initramfs:/$f"
        [[ $nofileinfo ]] || echo "========================================================================"
        # shellcheck disable=SC2001
        [[ $f == *"\\x"* ]] && f=$(echo "$f" | sed 's/\\x.\{2\}/????/g')

        case $f in
            squashfs-root/*)
                extract_squash_img
                unsquashfs -force -d "$SQUASH_EXTRACT" -no-progress "$SQUASH_TMPFILE" "${f#squashfs-root/}" &> /dev/null
                ((ret += $?))
                cat "$SQUASH_EXTRACT/${f#squashfs-root/}" 2> /dev/null
                ;;
            erofs-root/*)
                extract_squash_img
                cat "$SQUASH_EXTRACT/$f" 2> /dev/null
                ;;
            *)
                cpio_extract_to_stdout "$f"
                ((ret += $?))
                ;;
        esac

        [[ $nofileinfo ]] || echo "========================================================================"
        [[ $nofileinfo ]] || echo
    done
}

list_modules() {
    echo "dracut modules:"
    # shellcheck disable=SC2046
    cpio_extract_to_stdout $(dracutlibdirs modules.txt)
    ((ret += $?))
}

list_files() {
    echo "========================================================================"
    if [ "$sorted" -eq 1 ]; then
        cpio_list | sort -n -k5
    else
        cpio_list
    fi
    ((ret += $?))
    echo "========================================================================"
}

list_squash_content() {
    extract_squash_img || return 0

    echo "Squashed content (${SQUASH_TMPFILE##*/}):"
    echo "========================================================================"
    case $SQUASH_TMPFILE in
        */squash-root.img | */squashfs-root.img)
            unsquashfs -ll "$SQUASH_TMPFILE" | tail -n +4
            ;;
        */erofs-root.img)
            (
                cd "$SQUASH_EXTRACT" || return 1
                find erofs-root/ -ls
            )
            ;;
    esac
    echo "========================================================================"
}

list_cmdline() {

    echo "dracut cmdline:"
    cpio_extract_to_stdout etc/cmdline.d/\*.conf
    ((ret += $?))

    extract_squash_img || return 0
    case $SQUASH_TMPFILE in
        */squash-root.img | */squashfs-root.img)
            unsquashfs -force -d "$SQUASH_EXTRACT" -no-progress "$SQUASH_TMPFILE" etc/cmdline.d/\*.conf &> /dev/null
            ((ret += $?))
            cat "$SQUASH_EXTRACT"/etc/cmdline.d/*.conf 2> /dev/null
            ;;
        */erofs-root.img)
            cat "$SQUASH_EXTRACT"/erofs-root/etc/cmdline.d/*.conf 2> /dev/null
            ;;
    esac

}

unpack_files() {
    if ((${#filenames[@]} > 0)); then
        for f in "${!filenames[@]}"; do
            # shellcheck disable=SC2001
            [[ $f == *"\\x"* ]] && f=$(echo "$f" | sed 's/\\x.\{2\}/????/g')
            case $f in
                squashfs-root/*)
                    extract_squash_img || continue
                    unsquashfs -force -d "squashfs-root" -no-progress "$SQUASH_TMPFILE" "${f#squashfs-root/}" > /dev/null
                    ((ret += $?))
                    ;;
                erofs-root/*)
                    extract_squash_img || continue
                    mkdir -p "${f%/*}"
                    cp -rf "$SQUASH_EXTRACT/$f" "$f"
                    ;;
                *)
                    cpio_extract "$f"
                    ((ret += $?))
                    ;;
            esac
        done
    else
        cpio_extract
        ((ret += $?))

        extract_squash_img || return 0
        case $SQUASH_TMPFILE in
            */squash-root.img | */squashfs-root.img)
                unsquashfs -d "squashfs-root" -no-progress "$SQUASH_TMPFILE" > /dev/null
                ((ret += $?))
                ;;
            */erofs-root.img)
                cp -rf "$SQUASH_EXTRACT/erofs-root" .
                ;;
        esac
    fi
}

read -r -N 2 bin < "$image"
if [ "$bin" = "MZ" ]; then
    command -v "${OBJCOPY:-objcopy}" > /dev/null || {
        echo "Need 'objcopy' to unpack an UEFI executable."
        exit 1
    }
    "${OBJCOPY:-objcopy}" \
        --dump-section .linux="$TMPDIR/vmlinuz" \
        --dump-section .initrd="$TMPDIR/initrd.img" \
        --dump-section .cmdline="$TMPDIR/cmdline.txt" \
        --dump-section .osrel="$TMPDIR/osrel.txt" \
        "$image" /dev/null
    uefi="$image"
    image="$TMPDIR/initrd.img"
    [ -f "$image" ] || exit 1
fi

if ((${#filenames[@]} <= 0)) && [[ -z $unpack ]] && [[ -z $unpackearly ]]; then
    if [ -n "$uefi" ]; then
        echo -n "initrd in UEFI: $uefi: "
        du -h "$image" | while read -r a _ || [ -n "$a" ]; do echo "$a"; done
        if [ -f "$TMPDIR/osrel.txt" ]; then
            name=$(sed -En '/^PRETTY_NAME/ s/^\w+=["'"'"']?([^"'"'"'$]*)["'"'"']?/\1/p' "$TMPDIR/osrel.txt")
            id=$(sed -En '/^ID/ s/^\w+=["'"'"']?([^"'"'"'$]*)["'"'"']?/\1/p' "$TMPDIR/osrel.txt")
            build=$(sed -En '/^BUILD_ID/ s/^\w+=["'"'"']?([^"'"'"'$]*)["'"'"']?/\1/p' "$TMPDIR/osrel.txt")
            echo "OS Release: $name (${id}-${build})"
        fi
        if [ -f "$TMPDIR/vmlinuz" ]; then
            version=$(strings -n 20 "$TMPDIR/vmlinuz" | sed -En '/[0-9]+\.[0-9]+\.[0-9]+/ { p; q 0 }')
            echo "Kernel Version: $version"
        fi
        if [ -f "$TMPDIR/cmdline.txt" ]; then
            echo "Command line:"
            sed -En 's/\s+/\n/g; s/\x00/\n/; p' "$TMPDIR/cmdline.txt"
        fi
    else
        echo -n "Image: $image: "
        du -h "$image" | while read -r a _ || [ -n "$a" ]; do echo "$a"; done
    fi

    echo "========================================================================"
fi

unset skip
read -r -N 6 bin < "$image"
case $bin in
    $'\x71\xc7'* | 070701)
        CAT="cat --"
        parts=1
        is_early=$(cpio_extract_to_stdout early_cpio 2> /dev/null)
        # Debian mkinitramfs does not create the file 'early_cpio', so let's check if firmware files exist
        [[ "$is_early" ]] || is_early=$(cpio_list 'kernel/*/microcode/*.bin' 2> /dev/null)
        if [[ "$is_early" ]]; then
            if [[ -n $unpack ]]; then
                # should use --unpackearly for early CPIO
                :
            elif [[ -n $unpackearly ]]; then
                unpack_files
            elif ((${#filenames[@]} > 0)); then
                extract_files
            else
                echo "Early CPIO image"
                list_files
            fi
            if [[ -f "$dracutbindir/src/skipcpio/skipcpio" ]]; then
                skip="$dracutbindir/src/skipcpio/skipcpio"
            else
                skip="$dracutbindir/skipcpio"
            fi
            if ! [[ -x $skip ]]; then
                echo
                echo "'$skip' not found, cannot display remaining contents!" >&2
                echo
                exit 0
            fi
        fi
        ;;
esac

if [[ $skip ]]; then
    bin="$($skip "$image" | { read -r -N 6 bin && echo "$bin"; })"
else
    read -r -N 6 bin < "$image"
fi
case $bin in
    $'\x1f\x8b'*)
        CAT="zcat --"
        ;;
    BZh*)
        CAT="bzcat --"
        ;;
    $'\x71\xc7'* | 070701)
        CAT="cat --"
        ;;
    $'\x02\x21'*)
        CAT="lz4 -d -c"
        ;;
    $'\x89'LZO$'\0'*)
        CAT="lzop -d -c"
        ;;
    $'\x28\xB5\x2F\xFD'*)
        CAT="zstd -d -c"
        ;;
    *)
        if echo "test" | xz | xzcat --single-stream > /dev/null 2>&1; then
            CAT="xzcat --single-stream --"
        else
            CAT="xzcat --"
        fi
        ;;
esac

type "${CAT%% *}" > /dev/null 2>&1 || {
    echo "Need '${CAT%% *}' to unpack the initramfs."
    exit 1
}

# shellcheck disable=SC2317,SC2329  # assigned to CAT and $CAT called later
skipcpio() {
    $skip "$@" | $ORIG_CAT
}

parts="1-"
if [[ $skip ]]; then
    ORIG_CAT="$CAT"
    CAT=skipcpio
    parts="2-"
fi

if ((${#filenames[@]} > 1)); then
    TMPFILE="$TMPDIR/initrd.cpio"
    $CAT "$image" 2> /dev/null > "$TMPFILE"
    # shellcheck disable=SC2317,SC2329  # assigned to CAT and $CAT called later
    pre_decompress() {
        cat "$TMPFILE"
    }
    CAT=pre_decompress
fi

ret=0

if [[ -n $unpack ]]; then
    unpack_files
elif ((${#filenames[@]} > 0)); then
    extract_files
else
    # shellcheck disable=SC2046
    version=$(cpio_extract_to_stdout $(dracutlibdirs 'dracut-*'))
    ((ret += $?))
    echo "Version: $version"
    echo
    if [ "$modules" -eq 1 ]; then
        list_modules
        echo "========================================================================"
    else
        echo -n "Arguments: "
        # shellcheck disable=SC2046
        cpio_extract_to_stdout $(dracutlibdirs build-parameter.txt)
        echo
        list_modules
        list_files
        list_squash_content
        echo
        list_cmdline
    fi
fi

exit "$ret"
