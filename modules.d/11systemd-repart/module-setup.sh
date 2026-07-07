#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {
    # If the binary(s) requirements are not fulfilled the module can't be installed.
    require_binaries systemd-repart || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255
}

# Config adjustments before installing anything.
config() {
    add_dlopen_features+=" libsystemd-shared-*.so:fdisk,libcrypto "
}

# Install the required file(s) for the module in the initramfs.
install() {
    inst_multiple -o \
        "/usr/lib/repart.d/*.conf" \
        "$systemdsystemunitdir"/systemd-repart.service \
        "$systemdsystemunitdir/systemd-repart.service.d/*.conf" \
        "$systemdsystemunitdir"/initrd-root-fs.target.wants/systemd-repart.service \
        systemd-repart

    # Systemd-repart is capable of also formatting the created partition.
    # Support all filesystems that repart.d supports.
    inst_multiple -o \
        "mkfs.ext4" \
        "mkfs.btrfs" \
        "mkfs.xfs" \
        "mkfs.vfat" \
        "mkfs.erofs" \
        "mksquashfs"

    # Install library file(s)
    if [[ ! $USE_SYSTEMD_DLOPEN_DEPS ]]; then
        inst_libdir_file \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libfdisk.so.*"
    fi

    # Install the hosts local user configurations if enabled.
    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "/etc/repart.d/*.conf" \
            "$systemdsystemconfdir"/systemd-repart.service \
            "$systemdsystemconfdir/systemd-repart.service.d/*.conf"
    fi
}
