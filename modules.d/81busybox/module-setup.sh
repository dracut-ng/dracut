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

        # do not remove existing destination files
        [ -e "${_dstdir}/$_path" ] && continue

        ln_r /usr/bin/busybox "$_path"
    done
    # Ensure /usr/bin/sh is always available.
    # POSIX mandates /bin/sh and most scripts use #!/bin/sh (-> /usr/bin/sh
    # on merged-usr). find_binary may locate 'sh' at a non-standard path
    # (e.g. /usr/sbin/sh) depending on $DRACUT_PATH ordering, so create
    # the symlink explicitly if absent.
    [[ -e "${_dstdir}/usr/bin/sh" ]] || ln_r /usr/bin/busybox /usr/bin/sh
}
