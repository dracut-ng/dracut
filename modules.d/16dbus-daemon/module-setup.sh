#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {

    # If the binary(s) requirements are not fulfilled the module can't be installed
    require_binaries busctl || return 1
    require_binaries dbus-daemon || return 1
    require_binaries dbus-send || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255
}

# Module dependency requirements.
depends() {

    # This module has external dependency on the systemd module.
    echo systemd
    # Return 0 to include the dependent systemd module in the initramfs.
    return 0
}

# Install the required file(s) and directories for the module in the initramfs.
install() {
    # dbus conflicts with dbus-broker.
    if dracut_module_included "dbus-broker"; then
        derror "dbus conflicts with dbus-broker in the initramfs."
        return 1
    fi

    # Create dbus related directories.
    inst_dir "$dbus"
    inst_dir "$dbusinterfaces"
    inst_dir "$dbusservices"
    inst_dir "$dbussession"
    inst_dir "$dbussystem"
    inst_dir "$dbussystemservices"

    inst_multiple -o \
        "$dbus"/system.conf \
        "$dbussystem"/org.freedesktop.systemd1.conf \
        "$dbussystemservices"/org.freedesktop.systemd1.service \
        "$systemdsystemunitdir"/dbus.service \
        "$systemdsystemunitdir"/dbus.socket \
        "$systemdsystemunitdir"/dbus.target.wants \
        "$systemdsystemunitdir"/multi-user.target.wants/dbus.service \
        "$systemdsystemunitdir"/sockets.target.wants/dbus.socket \
        busctl dbus-send dbus-daemon

    # Remove After/Requires=sysinit.target and After=basic.target for initramfs in the dbus service unit.
    sed -i -e \
        '/^\(After\|Requires\)=.*sysinit\.target/d
        /^DefaultDependencies=/d
        /^\[Unit\]/aDefaultDependencies=no\nConflicts=shutdown.target\nBefore=shutdown.target' \
        "$initdir$systemdsystemunitdir/dbus.service"

    # Remove After/Requires=sysinit.target for initramfs in the dbus socket unit.
    sed -i -e \
        '/^\(After\|Requires\)=.*sysinit\.target/d
        /^DefaultDependencies=/d
        /^\[Unit\]/aDefaultDependencies=no\nConflicts=shutdown.target\nBefore=shutdown.target sockets.target
        /^\[Socket\]/aRemoveOnStop=yes' \
        "$initdir$systemdsystemunitdir/dbus.socket"

    # Adding the user and group for dbus
    grep '^\(d\|message\)bus:' "${dracutsysrootdir-}"/etc/passwd >> "$initdir/etc/passwd"
    grep '^\(d\|message\)bus:' "${dracutsysrootdir-}"/etc/group >> "$initdir/etc/group"

    # Install the hosts local user configurations if enabled.
    if [[ $hostonly ]]; then
        inst_dir "$dbusconfdir"
        inst_dir "$dbusinterfacesconfdir"
        inst_dir "$dbusservicesconfdir"
        inst_dir "$dbussessionconfdir"
        inst_dir "$dbussystemconfdir"
        inst_dir "$dbussystemservicesconfdir"
        inst_multiple -H -o \
            "$dbusconfdir"/system.conf \
            "$dbusservicesconfdir"/org.freedesktop.systemd1.service \
            "$systemdsystemconfdir"/dbus.socket \
            "$systemdsystemconfdir"/dbus.socket.d/*.conf \
            "$systemdsystemconfdir"/dbus.service \
            "$systemdsystemconfdir"/dbus.service.d/*.conf
    fi

    # We need to make sure that systemd-tmpfiles-setup.service->dbus.socket
    # will not wait for local-fs.target to start if swap is encrypted,
    # this would make dbus wait the timeout for the swap before loading.
    # This could delay sysinit services that are dependent on dbus.service.
    sed -i -Ee \
        '/^After/s/(After[[:space:]]*=.*)(local-fs.target[[:space:]]*)(.*)/\1-\.mount \3/' \
        "$initdir$systemdsystemunitdir/systemd-tmpfiles-setup.service"
}
