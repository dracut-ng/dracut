#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {

    # If the binary(s) requirements are not fulfilled the module can't be installed.
    require_binaries tpm2 || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255

}

# Module dependency requirements.
depends() {

    # This module has external dependency on other module(s).
    echo systemd-sysusers systemd-udevd
    # Return 0 to include the dependent module(s) in the initramfs.
    return 0

}

# Config adjustments before installing anything.
config() {
    add_dlopen_features+=" libsystemd-shared-*.so:libcrypto "
}

# Install kernel module(s).
installkernel() {
    hostonly=$(optional_hostonly) instmods '=drivers/char/tpm'
}

# Install the required file(s) and directories for the module in the initramfs.
install() {
    inst_sysusers tpm2-tss.conf
    inst_sysusers system-user-tss.conf
    grep -s '^tss:' "${dracutsysrootdir-}"/etc/passwd >> "$initdir/etc/passwd"
    grep -s '^tss:' "${dracutsysrootdir-}"/etc/group >> "$initdir/etc/group"

    inst_multiple -o \
        "$tmpfilesdir"/tpm2-tss-fapi.conf \
        "$udevrulesdir"/60-tpm-udev.rules \
        "$udevrulesdir"/90-tpm.rules \
        "$systemdutildir"/systemd-tpm2-setup \
        "$systemdutildir"/system-generators/systemd-tpm2-generator \
        "$systemdsystemunitdir/tpm2.target" \
        "$systemdsystemunitdir"/systemd-tpm2-setup-early.service \
        "$systemdsystemunitdir/systemd-tpm2-setup-early.service.d/*.conf" \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-tpm2-setup-early.service \
        tpm2_pcrread tpm2_pcrextend tpm2_createprimary tpm2_createpolicy \
        tpm2_create tpm2_load tpm2_unseal tpm2

    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "$systemdsystemconfdir"/systemd-tpm2-setup-early.service \
            "$systemdsystemconfdir/systemd-tpm2-setup-early.service.d/*.conf" \
            "$systemdsystemconfdir"/sysinit.target.wants/systemd-tpm2-setup-early.service
    fi

    # Install library file(s)
    inst_libdir_file \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-esys.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-fapi.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-mu.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-rc.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-sys.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-tcti-cmd.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-tcti-device.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-tcti-mssim.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-tcti-swtpm.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libtss2-tctildr.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libcryptsetup.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"cryptsetup/libcryptsetup-token-systemd-tpm2.so" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libcurl.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libjson-c.so.*"

}
