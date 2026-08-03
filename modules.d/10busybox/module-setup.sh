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
    local _i _path _busybox
    local _dstdir="${dstdir:-"$initdir"}"
    local _progs=()
    _busybox=$(find_binary busybox)
    inst "$_busybox" /usr/bin/busybox

    # do not depend on CONFIG_FEATURE_INSTALLER
    # install busybox symlinks manually
    for _i in $($_busybox --list); do
        [[ ${_i} == busybox ]] && continue
        _progs+=("${_i}")
    done

    for _i in "${_progs[@]}"; do
        _path=$(find_binary "$_i")
        [ -z "$_path" ] && continue

        # An existing symlink (e.g. another applet alias) is left alone. A real
        # file at this path comes from install_items, which dracut.sh processes
        # before module install(). Replace it with the busybox applet so the
        # module's "busybox wins" contract holds even when downstream configs
        # pre-stage host binaries (e.g. Fedora's 01-dist.conf, see #2454).
        # Modules that need the host binary must drop the symlink and reinstall
        [ -L "${_dstdir}/$_path" ] && continue
        [ -e "${_dstdir}/$_path" ] && rm -f "${_dstdir}/$_path"

        ln_r /usr/bin/busybox "$_path"
    done
}
