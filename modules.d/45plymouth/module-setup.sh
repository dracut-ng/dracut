#!/bin/bash

pkglib_dir() {
    for _dir in /usr/libexec $libdirs; do
        if [ -x "${dracutsysrootdir-}$_dir/plymouth/plymouth-populate-initrd" ]; then
            echo "$_dir/plymouth"
            return
        fi
    done
}

read_setting_from_config() {
    local setting="$1"
    local config_file="$2"
    if [[ -f $config_file ]]; then
        sed -n "s/^${setting}= *\([^ ]\+\) */\1/p" "$config_file"
    fi
}

use_simpledrm() {
    local config use_simpledrm config_dirs=()
    if [[ $hostonly ]]; then
        config_dirs+=("${dracutsysrootdir-}/etc/plymouth/plymouthd.conf")
    fi
    for config in "${config_dirs[@]}" "${dracutsysrootdir-}/usr/share/plymouth/plymouthd.defaults"; do
        use_simpledrm=$(read_setting_from_config UseSimpledrm "$config")
        if [[ $use_simpledrm -ge 1 ]]; then
            return 0
        fi
        if [[ $use_simpledrm == "0" ]]; then
            return 1
        fi
    done
    return 1
}

# called by dracut
check() {
    [[ "$mount_needs" ]] && return 1
    [[ $(pkglib_dir) ]] || return 1

    require_binaries plymouthd plymouth || return 1

    return 0
}

# called by dracut
depends() {
    if use_simpledrm; then
        echo simpledrm
    else
        echo drm
    fi
}

# called by dracut
installkernel() {
    # With simpledrm alone, the KMS driver of the boot GPU is loaded only after
    # switching root, and taking over the display from simpledrm makes the
    # screen flicker while Plymouth is running. In hostonly mode, include that
    # one driver, but not the drivers of other GPUs (e.g. the discrete GPU of a
    # hybrid laptop), to keep the benefits of using simpledrm.
    if [[ -z $hostonly ]] || ! use_simpledrm; then
        return 0
    fi

    local i modlink
    for i in /sys/bus/pci/devices/*/boot_vga; do
        [[ $(< "$i") == 1 ]] || continue
        [[ -L ${i%/*}/driver/module ]] || continue
        modlink=$(readlink "${i%/*}/driver/module")
        hostonly='' instmods "${modlink##*/}"
    done
}

# called by dracut
install() {
    PKGLIBDIR=$(pkglib_dir)
    PLYMOUTH_POPULATE_SOURCE_FUNCTIONS="$dracutfunctions" \
        "${dracutsysrootdir-}${PKGLIBDIR}"/plymouth-populate-initrd -t "$initdir" 2> /dev/null

    inst_hook emergency 50 "$moddir"/plymouth-emergency.sh

    inst_multiple readlink

    inst_multiple plymouthd plymouth

    if ! dracut_module_included "systemd"; then
        inst_hook pre-trigger 10 "$moddir"/plymouth-pretrigger.sh
        inst_hook pre-pivot 90 "$moddir"/plymouth-newroot.sh
    fi
}
