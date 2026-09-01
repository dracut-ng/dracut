#!/bin/bash

check() {
    # Only include the module if another module requires it
    return 255
}

depends() {
    echo "rootfs-block kernel-modules qemu initqueue"
}

install() {
    inst_multiple cp dd umount sync mkfs.ext4
    inst_hook initqueue/finished 01 "$moddir/finished-false.sh"
}
