#!/bin/bash

# called by dracut
check() {
    if [[ $hostonly_mode != "strict" ]] && dracut_module_included "qemu"; then
        return 0
    fi

    [[ $hostonly ]] || [[ $mount_needs ]] && {
        for fs in "${host_fs_types[@]}"; do
            [[ $fs == "9p" ]] && return 0
        done
        return 255
    }

    return 255
}

# called by dracut
installkernel() {
    hostonly=$(optional_hostonly) instmods 9p 9pnet_virtio virtio_pci
}

# called by dracut
install() {
    inst_hook cmdline 95 "$moddir/parse-virtfs.sh"
    inst_hook pre-mount 99 "$moddir/mount-virtfs.sh"
}
