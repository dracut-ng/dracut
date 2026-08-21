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
    local _i _path _busybox _busybox_applets
    local _dstdir="${dstdir:-"$initdir"}"
    local _progs=()
    _busybox=$(find_binary busybox)
    inst "$_busybox" /usr/bin/busybox

    # do not depend on CONFIG_FEATURE_INSTALLER
    # install busybox symlinks manually
    if [[ $DRACUT_MODULE_BUSYBOX_LINKS ]]; then
        _busybox_applets="$(cat "$DRACUT_MODULE_BUSYBOX_LINKS")"
    else
        _busybox_applets="$($_busybox --list)"
    fi
    if ! [[ ${_busybox_applets} ]]; then
        derror "Could not get list of busybox applets!"
        dinfo "If cross-building, try setting DRACUT_MODULE_BUSYBOX_LINKS."
    fi
    for _i in ${_busybox_applets}; do
        [[ ${_i} == busybox ]] && continue
        _progs+=("${_i}")
    done

    for _i in "${_progs[@]}"; do
        _path=$(find_binary "$_i")
        [ -z "$_path" ] && continue

        # do not remove existing destination files
        [ -e "${_dstdir}/$_path" ] && continue

        ln_r /usr/bin/busybox "$_path"
    done
}
