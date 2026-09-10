#!/bin/sh

[ "$RD_DEBUG" = yes ] && set -x
PS4='+ $(read -r u _ </proc/uptime; echo "$u") ${BASH_SOURCE-$0}@$LINENO${FUNCNAME:+ $FUNCNAME()}: '

command -v getarg > /dev/null || . /lib/dracut-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

isospec=$1

[ "$isospec" ] || die "A path to the .iso was not provided."

ismounted /run/initramfs/live && exit 0

read_isospec() {
    # shellcheck disable=SC2086
    set -- $isospec
    devspec="$1"
    shift
    [ $# -eq 1 ] || {
        isopath="$devspec"
        unset -v devspec
        return 0
    }
    isopath="$1"
}
IFS='
' read_isospec

cleanup() {
    case $1 in
        3)
            losetup -d "${isoloop%p1}"
            umount -l /run/initramfs/isoscan
            losetup -d "$discloop"
            ;;
        2)
            umount -l /run/initramfs/isoscan
            losetup -d "$discloop"
            ;;
    esac
    blockdev --setrw "$dev"
}

# Set LOOP to the first loop device for $1 or fail if not found.
get_loop() {
    local bac line
    for bac in /sys/block/loop*/loop/backing_file; do
        [ -f "$bac" ] || continue
        read -r line < "$bac"
        if [ "$line" = "$1" ]; then
            # Extract the loop device name
            LOOP="${bac#/sys/block/}"
            LOOP="/dev/${LOOP%/loop/backing_file}"
            return 0
        fi
    done
    return 1
}

loopmountiso() {
    local opt discloop _isopath fsType d mntcmd line k k_maj k_min
    # Prevent writing to filesystems with journals that may have been hibernated.
    blockdev --setro "$dev"
    fsType=$(blkid "$dev")
    fsType="${fsType#* TYPE=\"}"
    fsType="${fsType%%\"*}"
    mntcmd="mount -m -n -t $fsType"
    # Prevent writing to filesystems with journals that may have been hibernated.
    case $fsType in
        btrfs)
            d=d
            read -r k < /proc/sys/kernel/osrelease
            k_maj=${k%%.*}
            k_min=${k#*.}
            k_min=${k_min%%.*}
            k_min=${k_min%%[^0-9]*}
            if [ "$k_maj" -gt 5 ] || { [ "$k_maj" -eq 5 ] && [ "$k_min" -ge 9 ]; }; then
                opt=",rescue=nologreplay"
            else
                opt=",nologreplay"
            fi
            ;;
        ext[43]) opt=,noload ;;
        xfs | f2fs) opt=,norecovery ;;
        ntfs)
            if [ -x /sbin/mount-ntfs-3g ]; then
                mkdir -m 0755 -p /run/initramfs/isoscan
                mntcmd=/sbin/mount-ntfs-3g
            else
                warn "mount-ntfs-3g is needed for ntfs filesystem mounting."
                cleanup
                return 1
            fi
            ;;
    esac
    { losetup -rf "$dev" && get_loop "$dev" && discloop="$LOOP"; } || {
        cleanup
        return 1
    }
    dmesg -c > /dev/null
    $mntcmd -o "ro$opt" "$discloop" /run/initramfs/isoscan 2> /dev/kmsg || {
        cleanup 2
        return 1
    }
    [ "$d" ] && {
        # Adjust path for btrfs subvol, if present.
        set -- /run/initramfs/isoscan/*/proc
        d="${1%/proc}"
        d="${d##*/}"
        [ "$d" = \* ] && unset -v 'd'
    }
    _isopath="/run/initramfs/isoscan/${d:+$d/}${isopath#/}"
    [ -f "$_isopath" ] || {
        cleanup 2
        return 1
    }
    dmesg | while read -r line; do
        case $line in
            *orphan* | *recovery* | *dirty* | *unclean* | *corrupt*)
                warn "The partition '$devspec' is not clean.
                The partition has been locked readonly with blockdev --setro.
                The image file '$isopath' will be checked for integrity."
                command -v rd_iso_check > /dev/null || . /lib/img-lib.sh
                rd_iso_check "$_isopath" || die "Media check failed!"
                break
                ;;
        esac
    done
    fsType=$(blkid "$_isopath")
    fsType="${fsType#* TYPE=\"}"
    fsType="${fsType%%\"*}"
    { losetup -fPr "$_isopath" && get_loop "$_isopath" && isoloop="$LOOP"; } || {
        cleanup 2
        return 1
    }
    ln -s "$isoloop" /run/initramfs/isoloop
    [ -b "${isoloop}p1" ] && isoloop="${isoloop}p1"
    mount -m -n -t "$fsType" -o ro "$isoloop" /run/initramfs/live || {
        cleanup 3
        return 1
    }
    ln -s "$dev" /run/initramfs/isoscandev
    umount -l /run/initramfs/isoscan
    blockdev --setrw "$dev"
    rm -f -- "$job"
    [ "${root%%:*}" = live ] && /sbin/initqueue --settled --onetime --unique /sbin/dmsquash-live-root "$isoloop"
    exit 0
}

[ "$devspec" ] && {
    command -v label_uuid_udevadm_trigger > /dev/null || . /lib/dracut-dev-lib.sh
    label_uuid_udevadm_trigger "$devspec"
    label_uuid_to_dev "$devspec"
    dev=$(readlink -f "$DEV")
    udevadm wait -t 10 "$dev"
    loopmountiso || die "$devspec & $isopath could not be mounted."
}

[ -d /run/initramfs/live ] || {
    udevadm trigger --subsystem-match=block --action=add
    udevadm settle
    for devspec in /dev/disk/by-uuid/*; do
        dev=$(readlink -f "$devspec")
        loopmountiso || continue
    done
    rmdir /run/initramfs/isoscan
    die "Unable to find $isopath."
}

rmdir /run/initramfs/isoscan
warn "Unable to find $isopath."
exit 1
