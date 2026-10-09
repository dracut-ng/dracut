#!/bin/bash

check() {
    require_kernel_modules loop overlay || return 1

    return 255
}

depends() {
    echo "systemd-initrd"

    return 0
}

squash_get_handler() {
    local _module _handler
    local -a _modules=(squash-squashfs squash-erofs)

    for _module in "${_modules[@]}"; do
        if dracut_module_included "$_module"; then
            _handler="$_module"
            break
        fi
    done

    if [[ -z $_handler ]]; then
        dfatal "Cannot include squash-lib directly. It requires one of: ${_modules[*]}"
        return 1
    fi

    echo "$_handler"
}

squash_install() {
    local _busybox _dir

    # verify that there is a valid handler before doing anything
    squash_get_handler > /dev/null || return 1

    _busybox=$(find_binary busybox)

    # Create mount points for squash loader and basic directories
    mkdir -p "$initdir"/squash
    for _dir in squash usr/bin usr/sbin usr/lib; do
        if [[ -L ${dracutsysrootdir-}/$_dir ]]; then
            # the host directory is a symlink (e.g. /usr/sbin -> bin on
            # merged-usr systems); replicate the same symlink in the
            # loader, otherwise tools installed into one merged tree
            # (e.g. sh in usr/sbin) are not reachable from the other
            # (/usr/bin/sh). The target text is copied from the host so
            # that the link is valid both at boot time and while the
            # loader directory is still being populated.
            ln -sfn "$(readlink "${dracutsysrootdir-}/$_dir")" "$squashdir/$_dir"
        else
            mkdir -p "$squashdir/$_dir"
        fi
        [[ $_dir == usr/* ]] && ln_r "/$_dir" "${_dir#usr}"
    done

    # Install required modules and binaries for the squash image init script.
    if [[ $_busybox ]]; then
        module_install "busybox"
    else
        DRACUT_RESOLVE_LAZY="" inst_multiple sh mount modprobe mkdir switch_root grep umount

        # libpthread workaround: pthread_cancel wants to dlopen libgcc_s.so
        inst_libdir_file "libgcc_s.so*"

        # FIPS workaround for Fedora/RHEL: libcrypto needs libssl when FIPS is enabled
        [[ $DRACUT_FIPS_MODE ]] && inst_libdir_file "libssl.so*"
    fi

    hostonly="" instmods "loop" "overlay"
    dracut_kernel_post

    # Install squash image init script.
    inst_simple "$moddir"/init-squash.sh /init

    # make sure that library links are correct and up to date for squash loader
    build_ld_cache
}

squash_installpost() {
    local _file _handler

    # this shouldn't happen but...
    # ...better safe than deleting your rootfs
    if [[ -z $initdir ]]; then
        #shellcheck disable=SC2016
        dfatal '$initdir not set. Something went terribly wrong.'
        exit 1
    fi

    _handler=$(squash_get_handler)
    [[ -n $_handler ]] || return 1

    DRACUT_SQUASH_POST_INST=1 module_install "$_handler"

    # Rescue the dracut spec files so dracut rebuild and lsinitrd can work
    for _file in "$initdir"/usr/lib/dracut/*; do
        [[ -f $_file ]] || continue
        DRACUT_RESOLVE_LAZY="" dstdir=$squashdir inst "$_file" "${_file#"$initdir"}"
    done

    # Remove everything that got squashed into the image
    for _file in "$initdir"/*; do
        [[ $_file == "$squashdir" ]] && continue
        rm -rf "$_file"
    done
    mv "$squashdir"/* "$initdir"
}

# due to this installation step below, this dracut module needs to be ordered to be the absolute last one
install() {

    if [[ $DRACUT_SQUASH_POST_INST ]]; then
        squash_installpost
    else
        dstdir="$squashdir" squash_install
    fi
}
