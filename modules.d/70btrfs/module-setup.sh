#!/bin/bash

# called by dracut
check() {
    # if we don't have btrfs installed on the host system,
    # no point in trying to support it in the initramfs.
    require_binaries btrfs || return 1

    [[ $hostonly ]] || [[ $mount_needs ]] && {
        for fs in "${host_fs_types[@]}"; do
            [[ $fs == "btrfs" ]] && return 0
        done
        return 255
    }

    return 0
}

# called by dracut
depends() {
    echo udev-rules initqueue
    return 0
}

# called by dracut
cmdline() {
    # Hack for slow machines
    # see https://github.com/dracutdevs/dracut/issues/658
    printf " rd.driver.pre=btrfs"
}

# called by dracut
installkernel() {
    hostonly='' instmods btrfs
}

# called by dracut
install() {
    # 64-btrfs.rules is shipped by udev/eudev, and it must always be installed
    # by the udev-rules module even if the btrfs module is not installed, to
    # mark btrfs devices ready or not.
    # See 567c4557537fe7f477f0f54237df00ebc79e56be

    inst_rules 64-btrfs-dm.rules

    if ! dracut_module_included "systemd"; then
        inst_hook initqueue/timeout 10 "$moddir/btrfs_timeout.sh"
    fi

    inst_multiple -o btrfsck btrfstune
    inst btrfs /sbin/btrfs

    if [[ $hostonly_cmdline == "yes" ]]; then
        printf "%s\n" "$(cmdline)" > "${initdir}/etc/cmdline.d/20-btrfs.conf"
    fi
}
