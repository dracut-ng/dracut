#!/bin/bash

check() {
    require_kernel_modules overlay || return 1
    return 255
}

depends() {
    echo base
}

installkernel() {
    hostonly="" instmods overlay
}

install() {
    inst_hook pre-mount 01 "$moddir/prepare-overlayfs.sh"
    inst_hook mount 01 "$moddir/mount-overlayfs.sh" # overlay on top of block device
    dracut_module_included net-lib && {
        inst_hook pre-pivot 00 "$moddir/prepare-overlayfs.sh" # prepare for network root (e.g. nfs)
        inst_hook pre-pivot 10 "$moddir/mount-overlayfs.sh"   # overlay on top of network device
    }
    inst_simple "$moddir/overlayfs-lib.sh" "/lib/overlayfs-lib.sh"
}
