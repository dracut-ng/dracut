#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {
    # If the binary(s) requirements are not fulfilled the module can't be installed.
    require_binaries \
        udevadm \
        "$systemdutildir"/systemd-udevd \
        || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255
}

# Config adjustments before installing anything.
config() {
    add_dlopen_features+=" libsystemd-shared-*.so:blkid "
}

# Module dependency requirements.
depends() {
    local deps
    deps="udev-rules systemd"

    # install optional dependencies unless they are omitted
    for module in systemd-sysctl systemd-modules-load; do
        module_check $module > /dev/null 2>&1
        if [[ $? == 255 ]] && ! [[ " $omit_dracutmodules " == *\ $module\ * ]]; then
            deps+=" $module"
        fi
    done

    echo "$deps"
    return 0
}

# Install the required file(s) and directories for the module in the initramfs.
install() {
    inst_multiple -o \
        "$udevrulesdir"/90-image-dissect.rules \
        "$udevrulesdir"/99-systemd.rules \
        "$systemdutildir"/systemd-udevd \
        "$systemdsystemunitdir"/systemd-udevd.service \
        "$systemdsystemunitdir/systemd-udevd.service.d/*.conf" \
        "$systemdsystemunitdir"/systemd-udev-trigger.service \
        "$systemdsystemunitdir/systemd-udev-trigger.service.d/*.conf" \
        "$systemdsystemunitdir"/systemd-udev-settle.service \
        "$systemdsystemunitdir/systemd-udev-settle.service.d/*.conf" \
        "$systemdsystemunitdir"/systemd-udevd-control.socket \
        "$systemdsystemunitdir"/systemd-udevd-kernel.socket \
        "$systemdsystemunitdir"/systemd-udevd-varlink.socket \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-udevd-control.socket \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-udevd-kernel.socket \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-udevd-varlink.socket \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-udevd.service \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-udev-trigger.service

    # Install the hosts local user configurations if enabled.
    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "$systemdsystemconfdir"/systemd-udevd.service \
            "$systemdsystemconfdir/systemd-udevd.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-udev-trigger.service \
            "$systemdsystemconfdir/systemd-udev-trigger.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-udev-settle.service \
            "$systemdsystemconfdir/systemd-udev-settle.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-udevd-control.socket \
            "$systemdsystemconfdir/systemd-udevd-control.socket.d/*.conf" \
            "$systemdsystemconfdir"/systemd-udevd-kernel.socket \
            "$systemdsystemconfdir/systemd-udevd-kernel.socket.d/*.conf" \
            "$systemdsystemconfdir"/systemd-udevd-varlink.socket \
            "$systemdsystemconfdir/systemd-udevd-varlink.socket.d/*.conf" \
            "$systemdsystemconfdir"/sockets.target.wants/systemd-udevd-control.socket \
            "$systemdsystemconfdir"/sockets.target.wants/systemd-udevd-kernel.socket \
            "$systemdsystemconfdir"/sockets.target.wants/systemd-udevd-varlink.socket \
            "$systemdsystemconfdir"/sysinit.target.wants/systemd-udevd.service \
            "$systemdsystemconfdir"/sysinit.target.wants/systemd-udev-trigger.service

        if dracut_module_included "hwdb"; then
            inst_multiple -H -o \
                "$systemdutilconfdir"/hwdb/hwdb.bin
        fi
    fi

    inst_binary true
    ln_r "$(find_binary true)" "/usr/bin/loginctl"
    ln_r "$(find_binary true)" "/bin/loginctl"

    # Install required libraries.
    inst_libdir_file {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libudev.so.*"
}
