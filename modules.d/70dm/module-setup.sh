#!/bin/bash

# called by dracut
check() {
    require_binaries dmsetup || return 1
    return 255
}

depends() {
    echo rootfs-block
    return 0
}

# called by dracut
installkernel() {
    hostonly=$(optional_hostonly) instmods '=drivers/md' dm_mod dm-cache dm-cache-mq dm-cache-cleaner
}

# called by dracut
install() {
    modinfo -k "$kernel" dm_mod > /dev/null 2>&1 \
        && inst_hook pre-udev 30 "$moddir/dm-pre-udev.sh"

    inst_multiple dmsetup

    inst_rules 10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
    # debian udev rules
    inst_rules 60-persistent-storage-dm.rules 55-dm.rules

    inst_rules "$moddir/11-dm.rules"

    inst_hook shutdown 25 "$moddir/dm-shutdown.sh"
    inst_hook cleanup 89 "$moddir/dm-needshutdown.sh"
}
