#!/bin/bash

# called by dracut
check() {
    require_binaries busybox || return 1

    return 255
}

# This module installs busybox and its applet symlinks before the base dracut
# module. Later modules that call inst_multiple for names busybox provides will
# see the symlinks already in $initdir and skip the install. Modules that
# specifically need the host's real binary must explicitly remove the symlink
# first and reinstall (`[ -L "$initdir$bin" ] && rm "$initdir$bin"; inst "$bin"`)

# called by dracut
install() {
    local _path _p _busybox _busybox_path
    local _dstdir="${dstdir:-"$initdir"}"
    local _progs=()
    _busybox=$(find_binary busybox)
    _busybox_path="/usr/bin/busybox"

    # install busybox symlinks manually
    for _path in $($_busybox --list-full); do
        # if busybox is built without CONFIG_FEATURE_INSTALLER=y, the list
        # has only plain names
        if [[ ${_path##*/} == "${_path}" ]]; then
            _p=$(find_binary "${_path}")
            if [[ $_p ]]; then
                # if the applet is installed, use its path
                _path="${_p}"
            else
                # otherwise guess usr/bin/
                _path="usr/bin/${_path}"
            fi
        fi

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
