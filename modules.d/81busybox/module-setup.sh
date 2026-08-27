#!/bin/bash

# called by dracut
check() {
    require_binaries busybox || return 1

    return 255
}

# we prefer the non-busybox implementation of switch_root
# due to the dependency, the busybox dracut module needs to be order later than the base dracut module
# as the base dracut module would install the non-busybox implementation of switch_root, if available

# called by dracut
install() {
    local _path _busybox _busybox_path
    local _dstdir="${dstdir:-"$initdir"}"
    local _progs=()
    _busybox=$(find_binary busybox)
    _busybox_path="/usr/bin/busybox"

    # do not depend on CONFIG_FEATURE_INSTALLER
    # install busybox symlinks manually
    for _path in $($_busybox --list-full); do
        if [[ ${_path##*/} == busybox ]]; then
            _busybox_path="/${_path#/}"
        else
            _progs+=("/${_path#/}")
        fi
    done

    inst "$_busybox" "$_busybox_path"
    for _path in "${_progs[@]}"; do
        # do not remove existing destination files
        [ -e "${_dstdir}$_path" ] && continue

        ln_r "$_busybox_path" "$_path"
    done
}
