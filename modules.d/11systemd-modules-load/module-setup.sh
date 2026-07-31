#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {
    # If the binary(s) requirements are not fulfilled the module can't be installed
    require_binaries "$systemdutildir"/systemd-modules-load || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255
}

# Install kernel module(s).
installkernel() {
    local _mods

    modules_load_get() {
        local _line _i
        for _i in "${dracutsysrootdir-}$1"/*.conf; do
            [[ -f $_i ]] || continue
            while read -r _line || [ -n "$_line" ]; do
                case $_line in
                    \#*) ;;

                    \;*) ;;

                    *)
                        echo "$_line"
                        ;;
                esac
            done < "$_i"
        done
    }

    mapfile -t _mods < <(modules_load_get "$modulesload")
    if [[ ${#_mods[@]} -gt 0 ]]; then
        hostonly='' instmods "${_mods[@]}"
    fi

    if [[ $hostonly ]]; then
        mapfile -t _mods < <(modules_load_get "$modulesloadconfdir")
        if [[ ${#_mods[@]} -gt 0 ]]; then
            hostonly='' instmods "${_mods[@]}"
        fi
    fi

    return 0
}

# Install the required file(s) and directories for the module in the initramfs.
install() {
    inst_multiple -o \
        "$modulesload/*.conf" \
        "$systemdutildir"/systemd-modules-load \
        "$systemdsystemunitdir"/systemd-modules-load.service \
        "$systemdsystemunitdir"/modprobe@.service \
        "$systemdsystemunitdir"/kmod-static-nodes.service \
        "$systemdsystemunitdir"/sysinit.target.wants/systemd-modules-load.service \
        "$systemdsystemunitdir"/sysinit.target.wants/kmod-static-nodes.service \
        kmod insmod rmmod modprobe modinfo depmod lsmod

    # Enable systemd type unit(s)
    $SYSTEMCTL -q --root "$initdir" enable systemd-modules-load.service

    # Install the hosts local user configurations if enabled.
    if [[ $hostonly ]]; then
        inst_multiple -H -o \
            "$modulesloadconfdir/*.conf" \
            "$systemdsystemconfdir"/modprobe@.service \
            "$systemdsystemconfdir/modprobe@.service.d/*.conf" \
            "$systemdsystemconfdir"/systemd-modules-load.service \
            "$systemdsystemconfdir/systemd-modules-load.service.d/*.conf"
    fi
}
