#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {
    # If the binary(s) requirements are not fulfilled the module can't be installed.
    # systemd-255 renamed systemd-pcrphase to systemd-pcrextend, check for old and new location.
    if ! require_any_binary \
        "$systemdutildir"/systemd-pcrextend \
        "$systemdutildir"/systemd-pcrphase; then
        return 1
    fi

    return 0
}

# Module dependency requirements.
depends() {
    # This module has external dependency on other module(s).

    local deps
    deps="systemd"

    # optional dependencies
    module="tpm2-tss"
    module_check $module > /dev/null 2>&1
    if [[ $? == 255 ]]; then
        deps+=" $module"
    fi
    echo "$deps"

    # Return 0 to include the dependent module(s) in the initramfs.
    return 0
}

# Config adjustments before installing anything.
config() {
    add_dlopen_features+=" libsystemd-shared-*.so:libcrypto "
}

# Install the required file(s) and directories for the module in the initramfs.
install() {
    inst_multiple -o \
        "$systemdutildir"/systemd-pcrphase \
        "$systemdutildir"/systemd-pcrextend \
        "$systemdsystemunitdir"/systemd-pcrphase-initrd.service \
        "$systemdsystemunitdir/systemd-pcrphase-initrd.service.d/*.conf" \
        "$systemdsystemunitdir"/systemd-pcrnvdone.service \
        "$systemdsystemunitdir/systemd-pcrnvdone.service.d/*.conf" \
        "$systemdsystemunitdir"/systemd-pcrosseparator.service \
        "$systemdsystemunitdir/systemd-pcrosseparator.service.d/*.conf" \
        "$systemdsystemunitdir"/initrd.target.wants/systemd-pcrphase-initrd.service \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-pcrnvdone.service \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-pcrosseparator.service \
        "/usr/lib/nvpcr/*.nvpcr"

    # Install the hosts local user configurations if enabled.
    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "$systemdsystemconfdir"/systemd-pcrphase-initrd.service \
            "$systemdsystemconfdir/systemd-pcrphase-initrd.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-pcrnvdone.service \
            "$systemdsystemconfdir/systemd-pcrnvdone.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-pcrosseparator.service \
            "$systemdsystemconfdir/systemd-pcrosseparator.service.d/*.conf" \
            "$systemdsystemconfdir"/initrd.target.wants/systemd-pcrphase-initrd.service \
            "$systemdsystemconfdir"/sysinit.target.wants/systemd-pcrnvdone.service \
            "$systemdsystemconfdir"/sysinit.target.wants/systemd-pcrosseparator.service
    fi
}
