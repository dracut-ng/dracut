#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

btrfs_check_complete() {
    local _rootinfo _dev
    _dev="${1:-/dev/root}"
    [ -e "$_dev" ] || return 0
    _rootinfo=$(udevadm info --query=property --name="$_dev" --property=ID_FS_TYPE --value)
    if [ "$_rootinfo" = "btrfs" ]; then
        info "Checking, if btrfs device complete"
        btrfs device ready "$_dev" > /dev/null 2>&1
        return $?
    fi
    return 0
}

btrfs_check_complete "$1"
