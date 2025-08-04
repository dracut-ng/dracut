#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {

    # If the binary(s) requirements are not fulfilled the module can't be installed.
    require_binaries \
        journalctl \
        "$systemdutildir"/systemd-journald \
        || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255

}

# Module dependency requirements.
depends() {

    # This module has external dependency on other module(s).
    echo systemd systemd-sysusers
    # Return 0 to include the dependent module(s) in the initramfs.
    return 0

}

# Config adjustments before installing anything.
config() {
    add_dlopen_features+=" libsystemd-shared-*.so:gcrypt,lz4,lzma,zstd "
}

# Install the required file(s) and directories for the module in the initramfs.
install() {

    inst_simple "$moddir/initrd.conf" "$systemdutildir/journald.conf.d/initrd.conf"

    inst_sysusers systemd-journal.conf

    inst_multiple -o \
        "$systemdutildir"/journald.conf \
        "$systemdutildir/journald.conf.d/*.conf" \
        "$systemdutildir"/systemd-journald \
        "$systemdsystemunitdir"/systemd-journald.service \
        "$systemdsystemunitdir"/systemd-journald.socket \
        "$systemdsystemunitdir"/systemd-journald@.service \
        "$systemdsystemunitdir"/systemd-journald@.socket \
        "$systemdsystemunitdir"/systemd-journald-audit.socket \
        "$systemdsystemunitdir"/systemd-journald-dev-log.socket \
        "$systemdsystemunitdir"/systemd-journald-varlink@.socket \
        "$systemdsystemunitdir"/systemd-journal-catalog-update.service \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-journald-audit.socket \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-journald-dev-log.socket \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-journald.socket \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-journald.service \
        journalctl

    # Install library file(s)
    if [[ ! $USE_SYSTEMD_DLOPEN_DEPS ]]; then
        inst_libdir_file \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"liblz4.so.*" \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"liblzma.so.*" \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libzstd.so.*"
    fi

    # Install the hosts local user configurations if enabled.
    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "$systemdutilconfdir"/journald.conf \
            "$systemdutilconfdir/journald.conf.d/*.conf" \
            "$systemdsystemconfdir"/systemd-journald.service \
            "$systemdsystemconfdir/systemd-journald.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-journal-catalog-update.service \
            "$systemdsystemconfdir/systemd-journal-catalog-update.service.d/*.conf"
    fi

}
