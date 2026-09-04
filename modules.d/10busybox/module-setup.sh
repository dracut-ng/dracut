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
    local _path _p _busybox _busybox_applets _busybox_path
    local _dstdir="${dstdir:-"$initdir"}"
    local _progs=()
    _busybox=$(find_binary busybox)
    _busybox_path="/usr/bin/busybox"

    # get list of available applets
    if [[ ${DRACUT_MODULE_BUSYBOX_LINKS-} ]]; then
        _busybox_applets="$DRACUT_MODULE_BUSYBOX_LINKS"
    else
        _busybox_applets="$($_busybox --list-full)"
    fi
    if ! [[ ${_busybox_applets} ]]; then
        derror "Could not get list of busybox applets!"
        dinfo "If cross-building, try setting DRACUT_MODULE_BUSYBOX_LINKS."
    fi

    # install busybox symlinks manually
    for _path in ${_busybox_applets}; do
        if [[ ${_path##*/} == blkid ]] && grep -qr "blkid -o" "${udevdir}/rules.d" 2> /dev/null; then
            # The busybox blkid applet does not support the option -o.
            # See https://github.com/vda-linux/busybox_mirror/issues/33
            continue
        fi
        if [[ ${_path##*/} == losetup ]]; then
            # The busybox losetup applet does not support the option --show.
            # See https://github.com/vda-linux/busybox_mirror/issues/37
            continue
        fi
        if [[ ${_path##*/} == mke2fs ]]; then
            # e2fsprogs provides mke2fs. mkfs.ext2, mkfs.ext3, and mkfs.ext4 are symlinks to it.
            # Busybox does not provide a mkfs.ext4 applet and mkfs.ext* would point to busybox then.
            continue
        fi
        if [[ ${_path##*/} == mount ]]; then
            # The busybox mount applet does not resolve "auto" to the actual filesystem.
            # See https://github.com/vda-linux/busybox_mirror/issues/34
            continue
        fi
        if [[ ${_path##*/} == nbd-client ]]; then
            # The busybox nbd-client applet does not support the option -check.
            # See https://github.com/vda-linux/busybox_mirror/issues/35
            # Note: When dropping this workaround, replace /usr/sbin/nbd-client by nbd-client
            continue
        fi
        if [[ ${_path##*/} == sulogin ]]; then
            # The busybox sulogin applet does not support the option -e.
            # See https://github.com/vda-linux/busybox_mirror/issues/36
            continue
        fi

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
