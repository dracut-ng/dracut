#!/bin/sh

[ "$RD_DEBUG" = yes ] && set -x
PS4='+ $(read -r u _ </proc/uptime; echo "$u") ${BASH_SOURCE-$0}@$LINENO${FUNCNAME:+ $FUNCNAME()}: '

command -v getarg > /dev/null || . /lib/dracut-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

isospec=$1

[ "$isospec" ] || die "An path to the .iso was not provided."

ismounted /run/initramfs/live && exit 0

isopath="${isospec##*:}"

loopmountiso() {
    local - opt _isopath fsType d mntcmd line
    fsType=$(blkid "$dev")
    fsType="${fsType#* TYPE=\"}"
    fsType="${fsType%%\"*}"
    udevadm trigger "--name-match=$dev" --action=add --settle > /dev/null 2>&1
    mntcmd="mount -m -n -t $fsType"
    # Prevent writing to filesystems with journals that may have been hibernated.
    case $fsType in
        btrfs) d=d ;;
        ext[43]) opt=,noload ;;
        xfs | f2fs) opt=,norecovery ;;
        ntfs)
            if [ -x /sbin/mount-ntfs-3g ]; then
                mkdir -m 0755 -p /run/initramfs/live
                mntcmd=/sbin/mount-ntfs-3g
            else
                warn "mount-ntfs-3g is needed for ntfs filesystem mounting."
                return 1
            fi
            ;;
    esac
    dmesg -c > /dev/null
    $mntcmd -o "ro$opt" "$dev" /run/initramfs/isoscan 2> /dev/kmsg || return 1
    [ "$d" ] && {
        # Adjust path for btrfs subvol, if present.
        set -- /run/initramfs/isoscan/*/proc
        d="${1%/proc}"
        d="${d##*/}"
        [ "$d" = \* ] && unset -v 'd'
    }
    _isopath="/run/initramfs/isoscan/${d:+$d/}${isopath#/}"
    [ -f "$_isopath" ] || {
        umount /run/initramfs/isoscan
        return 1
    }
    set +x
    dmesg | while read -r line; do
        case $line in
            *orphan* | *recovery* | *dirty* | *unclean* | *corrupt*)
                command -v rd_iso_check > /dev/null || . /lib/img-lib.sh
                rd_iso_check "$_isopath"
                break
                ;;
        esac
    done
    debug_on
    fsType=$(blkid "$_isopath")
    fsType="${fsType#* TYPE=\"}"
    fsType="${fsType%%\"*}"
    losetup -fPr "$_isopath" || return 1
    isoloop=$(losetup -j "$_isopath")
    isoloop="${isoloop%%:*}p1"
    mount -m -n -t "$fsType" -o ro "$isoloop" /run/initramfs/live || {
        losetup -d "${isoloop%p1}"
        umount -l /run/initramfs/isoscan
        return 1
    }
    ln -s "$dev" /run/initramfs/isoscandev
    ln -s "$isoloop" /run/initramfs/isoloop
    umount -l /run/initramfs/isoscan
    rm -f -- "$job"
    [ "${root%%:*}" = live ] && /sbin/initqueue --settled --onetime --unique /sbin/dmsquash-live-root "$isoloop"
    exit 0
}

[ "$isopath" = "$isospec" ] || {
    devspec="${isospec%%:*}"
    command -v label_uuid_udevadm_trigger > /dev/null || . /lib/dracut-dev-lib.sh
    label_uuid_udevadm_trigger "$devspec"
    dev=$(readlink -f "$(label_uuid_to_dev "$devspec")")
    udevadm wait -t 10 "$dev"
    loopmountiso || die "$devspec & $isopath could not be mounted."
}

[ -d /run/initramfs/live ] || {
    udevadm trigger --subsystem-match=block
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
