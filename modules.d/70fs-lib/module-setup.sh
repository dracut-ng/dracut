#!/bin/bash

echo_fs_helper() {
    local fs=$2
    case "$fs" in
        xfs)
            echo -n " xfs_db xfs_repair xfs_check xfs_metadump "
            ;;
        ext?)
            echo -n " e2fsck "
            ;;
        jfs)
            echo -n " jfs_fsck "
            ;;
        btrfs)
            echo -n " btrfsck "
            ;;
    esac

    echo -n " fsck.$fs "
    return 0
}

include_fs_helper_modules() {
    local fs=$2
    case "$fs" in
        xfs | btrfs | ext4 | ext3)
            instmods crc32c
            ;;
        f2fs)
            instmods crc32
            ;;
        vfat)
            instmods "=fs/nls"
            ;;
    esac
}

# called by dracut
installkernel() {
    # xfs/btrfs/ext4 need crc32c, f2fs needs crc32,
    # vfat needs charsets for codepage= and iocharset=
    if [[ $hostonly_mode == "strict" ]]; then
        for_each_host_dev_fs include_fs_helper_modules
        :
    else
        hostonly='' instmods crc32c crc32 "=fs/nls"
    fi
}

# called by dracut
install() {
    local _helpers

    inst "$moddir/fs-lib.sh" "/lib/fs-lib.sh"
    : > "${initdir}"/etc/fstab.empty

    [[ $nofscks == "yes" ]] && return 0

    if [[ $fscks == "${fscks#*[^ ]*}" ]]; then
        _helpers=(
            /sbin/fsck* /usr/sbin/fsck*
            xfs_db xfs_check xfs_repair xfs_metadump
            e2fsck jfs_fsck btrfsck
        )
        if [[ $hostonly_mode == "strict" ]]; then
            read -r -a _helpers < <(for_each_host_dev_fs echo_fs_helper)
        fi
    else
        read -r -a _helpers <<< "$fscks"
    fi

    _helpers+=(umount mount)

    if [[ ${_helpers[*]} == *e2fsck* ]] && [[ -e "${dracutsysrootdir-}/etc/e2fsck.conf" ]]; then
        inst_simple /etc/e2fsck.conf
    fi

    inst_multiple -o "${_helpers[@]}" fsck
}
