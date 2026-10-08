#!/bin/bash

check() {
    require_binaries_host mksquashfs || return 1
    require_binaries unsquashfs || return 1
    require_kernel_modules squashfs || return 1

    return 255
}

depends() {
    echo "squash-lib"
    return 0
}

squashfs_install() {
    hostonly="" instmods "squashfs"
}

squashfs_installpost() {
    local _img="$squashdir/squashfs-root.img"
    local _comp

    # shellcheck disable=SC2086
    if [[ $squash_compress ]]; then
        if ! mksquashfs /dev/null "$DRACUT_TMPDIR"/.squash-test.img -no-progress -comp $squash_compress &> /dev/null; then
            dwarn "mksquashfs doesn't support compressor '$squash_compress', failing back to default compressor."
        else
            _comp="$squash_compress"
        fi
    fi

    # shellcheck disable=SC2086
    if ! mksquashfs "$initdir" "$_img" \
        -no-xattrs -no-exports -noappend -no-recovery -always-use-fragments \
        -no-progress ${_comp:+-comp $_comp} \
        -e "$squashdir" 1> /dev/null; then
        dfatal "Failed making squash image"
        exit 1
    fi
}

install() {
    if [[ $DRACUT_SQUASH_POST_INST ]]; then
        squashfs_installpost
    else
        dstdir="$squashdir" squashfs_install
    fi
}
