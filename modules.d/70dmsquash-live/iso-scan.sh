#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

isofile=$1

[ "$isofile" ] || exit 1

ismounted /run/initramfs/isoscan && exit 0

do_iso_scan() {
    local _name dev fstype
    for dev in /dev/disk/by-uuid/*; do
        _name=$(dev_unit_name "$dev")
        [ -e "/tmp/isoscan-${_name}" ] && continue
        : > "/tmp/isoscan-${_name}"
        fstype=$(blkid "$dev")
        fstype="${fstype#* TYPE=\"}"
        fstype="${fstype%%\"*}"
        case $fstype in
            ext[43]) opt=,noload ;;
            xfs | f2fs) opt=,norecovery ;;
        esac
        dmesg -c > /dev/null
        mount -m -t "$fstype" -o "ro$opt" "$dev" /run/initramfs/isoscan 2> /dev/kmsg || continue
        if [ -f "${_isofile:="/run/initramfs/isoscan/$isofile"}" ]; then
            [ "$opt" ] && {
                command -v rd_iso_check > /dev/null || . /lib/img-lib.sh
                dmesg | while read -r line; do
                    case $line in
                        *orphan* | *recovery* | *dirty* | *unclean* | *corrupt*)
                            rd_iso_check "$_isofile"
                            break
                            ;;
                    esac
                done
            }
            loopdev=$(losetup -f)
            losetup -r "$_isofile"
            udevadm trigger "--name-match=$loopdev" --action=change --settle > /dev/kmsg 2>&1
            ln -s "$dev" /run/initramfs/isoscandev
            ln -s "$loopdev" /run/initramfs/isoloop
            umount -l /run/initramfs/isoscan
            rm -f -- "$job"
            exit 0
        else
            umount /run/initramfs/isoscan
        fi
    done
}

do_iso_scan

rmdir /run/initramfs/isoscan
warn "Unable to find $isofile."
exit 1
