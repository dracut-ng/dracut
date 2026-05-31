#!/bin/bash

check() {
    require_binaries \
        "$systemdutildir"/systemd-importd \
        || return 1

    return 255
}

# due to the dependencies below, this dracut module needs to be ordered later
# than the network dracut modules
depends() {
    echo systemd network
    return 0
}

config() {
    add_dlopen_features+=" libsystemd-shared-*.so:archive,curl,libcrypto,lz4,lzma,zstd "
}

installkernel() {
    hostonly='' instmods btrfs erofs ext4 f2fs loop squashfs vfat xfs

    # xfs/btrfs/ext4 need crc32c, f2fs needs crc32,
    # vfat needs charsets for codepage= and iocharset=
    hostonly='' instmods crc32c crc32 "=fs/nls"
}

install() {
    local _systemd_version
    _systemd_version=$(udevadm --version 2> /dev/null)

    inst_hook cmdline 10 "$moddir/parse-systemd-import.sh"

    inst_multiple -o \
        "$dbussystem"/org.freedesktop.import1.conf \
        "$dbussystemservices"/org.freedesktop.import1.service \
        "$systemdutildir"/import-pubring.pgp \
        "$systemdutildir"/systemd-import \
        "$systemdutildir"/systemd-import-fs \
        "$systemdutildir"/systemd-importd \
        "$systemdutildir"/systemd-pull \
        "$systemdutildir"/system-generators/systemd-import-generator \
        "$systemdsystemunitdir"/systemd-importd.service \
        "$systemdsystemunitdir"/systemd-importd.socket \
        "$systemdsystemunitdir"/systemd-loop@.service \
        "$systemdsystemunitdir"/imports.target \
        "$systemdsystemunitdir"/imports-pre.target \
        "$systemdsystemunitdir"/dbus-org.freedesktop.import1.service \
        "$systemdsystemunitdir"/sockets.target.wants/systemd-importd.socket \
        "$systemdsystemunitdir"/sysinit.target.wants/imports.target \
        gpg systemd-dissect

    inst "$moddir/dracut-remount-sysroot.service" "$systemdsystemunitdir"/dracut-remount-sysroot.service
    $SYSTEMCTL -q --root "$initdir" enable dracut-remount-sysroot.service

    # systemd < v259: requires the tar binary
    # See: https://github.com/systemd/systemd/commit/a7c8f92d1f937113a279adbe62399f6f0773473f
    if ((_systemd_version < 259)); then
        inst_multiple -o \
            tar
    fi

    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "$systemdutilconfdir"/import-pubring.pgp \
            "$systemdsystemconfdir"/systemd-importd.service \
            "$systemdsystemconfdir/systemd-importd.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-importd.socket \
            "$systemdsystemconfdir/systemd-importd.socket.d/*.conf" \
            "$systemdsystemconfdir"/systemd-loop@.service \
            "$systemdsystemconfdir/systemd-loop@.service.d/*.conf" \
            "$systemdsystemconfdir"/imports.target \
            "$systemdsystemconfdir/imports.target.wants/*.target" \
            "$systemdsystemconfdir"/imports-pre.target \
            "$systemdsystemconfdir/imports-pre.target.wants/*.target"
    fi

    # libcurl and libopenssl are not loaded via dlopen
    inst_libdir_file \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libcurl.so*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libssl.so*"

    if [[ ! $USE_SYSTEMD_DLOPEN_DEPS ]]; then
        inst_libdir_file \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libarchive.so*" \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"liblz4.so*" \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"liblzma.so*" \
            {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libzstd.so*"
    fi
}
