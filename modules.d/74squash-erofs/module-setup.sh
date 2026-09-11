#!/bin/bash

check() {
    require_binaries_host mkfs.erofs || return 1
    require_binaries fsck.erofs || return 1
    require_kernel_modules erofs || return 1

    return 255
}

depends() {
    echo "squash-lib"
    return 0
}

erofs_install() {
    hostonly="" instmods "erofs"
}

erofs_installpost() {
    local _img="$squashdir/erofs-root.img"
    local -a _erofs_args

    # --exclude-path requires a relative path
    _erofs_args+=("--exclude-path=${squashdir#"$initdir"/}")
    # In order to match the default SquashFS "block size"
    _erofs_args+=("-C" "65536")
    _erofs_args+=("-E" "fragments")
    # In order to match the SquashFS `-no-xattrs`
    _erofs_args+=("-x" "-1")
    # Clear UUID instead of randomness for the image reproducibility
    _erofs_args+=("-U" "00000000-0000-0000-0000-000000000000")
    # Clear inode timestamps for smaller image size
    _erofs_args+=("-T" "0")

    if [[ -n $squash_compress ]]; then
        if mkfs.erofs "${_erofs_args[@]}" -z "$squash_compress" "$_img" "$initdir" &> /dev/null; then
            return
        fi
        dwarn "mkfs.erofs doesn't support compressor '$squash_compress', failing back to no compression."
    fi

    if ! mkfs.erofs "${_erofs_args[@]}" "$_img" "$initdir" &> /dev/null; then
        dfatal "Failed making squash image"
        exit 1
    fi
}

install() {
    if [[ $DRACUT_SQUASH_POST_INST ]]; then
        erofs_installpost
    else
        dstdir="$squashdir" erofs_install
    fi
}
