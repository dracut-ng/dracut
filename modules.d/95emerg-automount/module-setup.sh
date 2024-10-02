#!/bin/bash

check() {
    return 0;
}

install() {
    inst_multiple bash findmnt sed awk grep mount ls mkdir which mountpoint \
        umount cat head tail cut lsblk vim
    inst_multiple -o cryptsetup btrfs
    inst_hook emergency 99 "$moddir/inform-automount.sh"
    inst_simple "$moddir/automount.sh" /bin/automount.sh
    inst_simple /etc/os-release /host-os-release
}
