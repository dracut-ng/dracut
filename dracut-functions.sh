#!/bin/bash
#
# functions used by dracut modules (including out-of-tree modules)
#
# There is an expectation to preserv compatibility between dracut
# releases for out-of-tree dracut modules for functions listed
# in this file.
#
# All functions in this file starting with an underscore are private functions
# and must not be called directly. All other functions in this file are meant
# to be public and documented in dracut.modules man page.
#
# Copyright 2005-2009 Red Hat, Inc.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
export LC_MESSAGES=C

# _is_func <command>
# Check whether $1 is a function.
_is_func() {
    [[ "$(type -t "$1")" == "function" ]]
}

# Generic substring function.  If $2 is in $1, return 0.
strstr() { [[ $1 == *"$2"* ]]; }
# Generic glob matching function. If glob pattern $2 matches anywhere in $1, OK
strglobin() { [[ $1 == *$2* ]]; }
# Generic glob matching function. If glob pattern $2 matches all of $1, OK
# shellcheck disable=SC2053
strglob() { [[ $1 == $2 ]]; }
# returns OK if $1 contains literal string $2 at the beginning, and isn't empty
str_starts() { [ "${1#"$2"*}" != "$1" ]; }
# returns OK if $1 contains literal string $2 at the end, and isn't empty
str_ends() { [ "${1%*"$2"}" != "$1" ]; }

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
    printf "%s" "$var"
}

# is_elf <path>
# Returns success if the given path is an ELF. Only checks the first 4 bytes.
is_elf() {
    [[ $(head --bytes=4 "$1") == $'\x7fELF' ]]
}

# find a binary.  If we were not passed the full path directly,
# search in the usual places to find the binary.
find_binary() {
    local _delim
    local _path
    local l
    local p
    [[ -z ${1##/*} ]] || _delim="/"

    if [[ $1 == *.so* ]]; then
        for l in $libdirs; do
            _path="${l}${_delim}${1}"
            if is_elf "${dracutsysrootdir-}${_path}"; then
                printf "%s\n" "${_path}"
                return 0
            fi
        done
        _path="${_delim}${1}"
        if is_elf "${dracutsysrootdir-}${_path}"; then
            printf "%s\n" "${_path}"
            return 0
        fi
    fi
    if [[ $1 == */* ]]; then
        _path="${_delim}${1}"
        if [[ -L ${dracutsysrootdir-}${_path} ]] || [[ -x ${dracutsysrootdir-}${_path} ]]; then
            printf "%s\n" "${_path}"
            return 0
        fi
    fi
    while read -r -d ':' p; do
        _path="${p}${_delim}${1}"
        if [[ -L ${dracutsysrootdir-}${_path} ]] || [[ -x ${dracutsysrootdir-}${_path} ]]; then
            printf "%s\n" "${_path}"
            return 0
        fi
    done <<< "${PATH}:"

    [[ -n ${dracutsysrootdir-} ]] && return 1
    type -P "${1##*/}"
}

ldconfig_paths() {
    $DRACUT_LDCONFIG ${dracutsysrootdir:+-r ${dracutsysrootdir} -f /etc/ld.so.conf} -pN 2> /dev/null | grep -E -v '/(lib|lib64|usr/lib|usr/lib64)/[^/]*$' | sed -n 's,.* => \(.*\)/.*,\1,p' | sort | uniq
}

# Version comparison function.  Assumes Linux style version scheme.
# $1 = version a
# $2 = comparison op (gt, ge, eq, le, lt, ne)
# $3 = version b
vercmp() {
    local _n1
    read -r -a _n1 <<< "${1//./ }"
    local _op=$2
    local _n2
    read -r -a _n2 <<< "${3//./ }"
    local _i _res

    for ((_i = 0; ; _i++)); do
        if [[ ! ${_n1[_i]}${_n2[_i]} ]]; then
            _res=0
        elif ((${_n1[_i]:-0} > ${_n2[_i]:-0})); then
            _res=1
        elif ((${_n1[_i]:-0} < ${_n2[_i]:-0})); then
            _res=2
        else
            continue
        fi
        break
    done

    case $_op in
        gt) ((_res == 1)) ;;
        ge) ((_res != 2)) ;;
        eq) ((_res == 0)) ;;
        le) ((_res != 1)) ;;
        lt) ((_res == 2)) ;;
        ne) ((_res != 0)) ;;
    esac
}

# Create all subdirectories for given path without creating the last element.
# $1 = path
mksubdirs() {
    # shellcheck disable=SC2174
    [[ -e ${1%/*} ]] || mkdir -m 0755 -p -- "${1%/*}"
}

# Function prints global variables in format name=value line by line.
# $@ = list of global variables' name
print_vars() {
    local _var _value

    for _var in "$@"; do
        eval printf -v _value "%s" \""\$$_var"\"
        [[ ${_value} ]] && printf '%s="%s"\n' "$_var" "$_value"
    done
}

# normalize_path <path>
# Prints the normalized path, where it removes any duplicated
# and trailing slashes.
# Example:
# $ normalize_path ///test/test//
# /test/test
normalize_path() {
    # shellcheck disable=SC2064
    trap "$(shopt -p extglob)" RETURN
    shopt -q -s extglob
    local p=${1//+(\/)//}
    printf "%s\n" "${p%/}"
}

# convert_abs_rel <from> <to>
# Prints the relative path, when creating a symlink to <to> from <from>.
# Example:
# $ convert_abs_rel /usr/bin/test /bin/test-2
# ../../bin/test-2
# $ ln -s $(convert_abs_rel /usr/bin/test /bin/test-2) /usr/bin/test
convert_abs_rel() {
    local __current __absolute __abssize __cursize __newpath
    local -i __i __level

    set -- "$(normalize_path "$1")" "$(normalize_path "$2")"

    # corner case #1 - self looping link
    [[ $1 == "$2" ]] && {
        printf "%s\n" "${1##*/}"
        return
    }

    # corner case #2 - own dir link
    [[ ${1%/*} == "$2" ]] && {
        printf ".\n"
        return
    }

    IFS=/ read -r -a __current <<< "$1"
    IFS=/ read -r -a __absolute <<< "$2"

    __abssize=${#__absolute[@]}
    __cursize=${#__current[@]}

    while [[ ${__absolute[__level]} == "${__current[__level]}" ]]; do
        ((__level++))
        if ((__level > __abssize || __level > __cursize)); then
            break
        fi
    done

    for ((__i = __level; __i < __cursize - 1; __i++)); do
        if ((__i > __level)); then
            __newpath=$__newpath"/"
        fi
        __newpath=$__newpath".."
    done

    for ((__i = __level; __i < __abssize; __i++)); do
        if [[ -n $__newpath ]]; then
            __newpath=$__newpath"/"
        fi
        __newpath=$__newpath${__absolute[__i]}
    done

    printf -- "%s\n" "$__newpath"
}

# get_fs_env <device>
# Get and the ID_FS_TYPE variable from udev for a device.
# Example:
# $ get_fs_env /dev/sda2
# ext4
get_fs_env() {
    [[ $1 ]] || return
    unset ID_FS_TYPE
    ID_FS_TYPE=$(blkid -u filesystem -o export -- "$1" \
        | while read -r line || [ -n "$line" ]; do
            if [[ $line == "TYPE="* ]]; then
                printf "%s" "${line#TYPE=}"
                exit 0
            fi
        done)
    if [[ $ID_FS_TYPE ]]; then
        printf "%s" "$ID_FS_TYPE"
        return 0
    fi
    return 1
}

# get_maj_min <device>
# Prints the major and minor of a device node.
# Example:
# $ get_maj_min /dev/sda2
# 8:2
get_maj_min() {
    local _majmin
    local _out

    if [[ $get_maj_min_cache_file ]]; then
        _out="$(grep -m1 -oE "^${1//\\/\\\\} \S+$" "$get_maj_min_cache_file" | grep -oE "\S+$")"
    fi

    if ! [[ "$_out" ]]; then
        _majmin="$(stat -L -c '%t:%T' "$1" 2> /dev/null)"
        _out="$(printf "%s" "$((0x${_majmin%:*})):$((0x${_majmin#*:}))")"
        if [[ $get_maj_min_cache_file ]]; then
            echo "$1 $_out" >> "$get_maj_min_cache_file"
        fi
    fi
    echo -n "$_out"
}

# get_devpath_block <device>
# get the DEVPATH in /sys of a block device
get_devpath_block() {
    local _majmin _i
    _majmin=$(get_maj_min "$1")

    for _i in /sys/block/*/dev /sys/block/*/*/dev; do
        [[ -e $_i ]] || continue
        if [[ $_majmin == "$(< "$_i")" ]]; then
            printf "%s" "${_i%/dev}"
            return 0
        fi
    done
    return 1
}

# get a persistent path from a device
get_persistent_dev() {
    local i _tmp _dev _pol

    _dev=$(get_maj_min "$1")
    [ -z "$_dev" ] && return

    if [[ -n $persistent_policy ]]; then
        _pol="/dev/disk/${persistent_policy}/*"
    else
        _pol=
    fi

    for i in \
        $_pol \
        /dev/mapper/* \
        /dev/disk/by-uuid/* \
        /dev/disk/by-label/* \
        /dev/disk/by-partuuid/* \
        /dev/disk/by-partlabel/* \
        /dev/disk/by-id/* \
        /dev/disk/by-path/*; do
        [[ -b $i ]] || continue
        [[ $i == /dev/mapper/mpath* ]] && continue
        _tmp=$(get_maj_min "$i")
        if [ "$_tmp" = "$_dev" ]; then
            printf -- "%s" "$i"
            return
        fi
    done
    printf -- "%s" "$1"
}

expand_persistent_dev() {
    local _dev=$1

    case "$_dev" in
        LABEL=*)
            _dev="/dev/disk/by-label/${_dev#LABEL=}"
            ;;
        UUID=*)
            _dev="${_dev#UUID=}"
            _dev="${_dev,,}"
            _dev="/dev/disk/by-uuid/${_dev}"
            ;;
        PARTUUID=*)
            _dev="${_dev#PARTUUID=}"
            _dev="${_dev,,}"
            _dev="/dev/disk/by-partuuid/${_dev}"
            ;;
        PARTLABEL=*)
            _dev="/dev/disk/by-partlabel/${_dev#PARTLABEL=}"
            ;;
    esac
    printf "%s" "$_dev"
}

shorten_persistent_dev() {
    local _dev="$1"
    case "$_dev" in
        /dev/disk/by-uuid/*)
            printf "%s" "UUID=${_dev##*/}"
            ;;
        /dev/disk/by-label/*)
            printf "%s" "LABEL=${_dev##*/}"
            ;;
        /dev/disk/by-partuuid/*)
            printf "%s" "PARTUUID=${_dev##*/}"
            ;;
        /dev/disk/by-partlabel/*)
            printf "%s" "PARTLABEL=${_dev##*/}"
            ;;
        *)
            printf "%s" "$_dev"
            ;;
    esac
}

# find_block_device <mountpoint>
# Prints the major and minor number of the block device
# for a given mountpoint.
# Unless $use_fstab is set to "yes" the functions
# uses /proc/self/mountinfo as the primary source of the
# information and only falls back to /etc/fstab, if the mountpoint
# is not found there.
# Example:
# $ find_block_device /usr
# 8:4
find_block_device() {
    local _dev _majmin _find_mpt
    _find_mpt="$1"

    if [[ $use_fstab != yes ]]; then
        [[ -d $_find_mpt/. ]]
        findmnt -e -v -n -o 'MAJ:MIN,SOURCE' --target "$_find_mpt" | {
            while read -r _majmin _dev || [ -n "$_dev" ]; do
                if [[ -b $_dev ]]; then
                    if ! [[ $_majmin ]] || [[ $_majmin == 0:* ]]; then
                        _majmin=$(get_maj_min "$_dev")
                    fi
                    if [[ $_majmin ]]; then
                        printf "%s\n" "$_majmin"
                    else
                        printf "%s\n" "$_dev"
                    fi
                    return 0
                fi
                if [[ $_dev == *:* ]]; then
                    printf "%s\n" "$_dev"
                    return 0
                fi
            done
            return 1
        } && return 0
    fi
    # fall back to /etc/fstab
    [[ ! -f "${dracutsysrootdir-}"/etc/fstab ]] && return 1

    findmnt -e --fstab -v -n -o 'MAJ:MIN,SOURCE' --target "$_find_mpt" | {
        while read -r _majmin _dev || [ -n "$_dev" ]; do
            if ! [[ $_dev ]]; then
                _dev="$_majmin"
                unset _majmin
            fi
            if [[ -b $_dev ]]; then
                [[ $_majmin ]] || _majmin=$(get_maj_min "$_dev")
                if [[ $_majmin ]]; then
                    printf "%s\n" "$_majmin"
                else
                    printf "%s\n" "$_dev"
                fi
                return 0
            fi
            if [[ $_dev == *:* ]]; then
                printf "%s\n" "$_dev"
                return 0
            fi
        done
        return 1
    } && return 0

    return 1
}

# find_mp_fstype <mountpoint>
# Echo the filesystem type for a given mountpoint.
# /proc/self/mountinfo is taken as the primary source of information
# and /etc/fstab is used as a fallback.
# No newline is appended!
# Example:
# $ find_mp_fstype /;echo
# ext4
find_mp_fstype() {
    local _fs

    if [[ $use_fstab != yes ]]; then
        findmnt -e -v -n -o 'FSTYPE' --target "$1" | {
            while read -r _fs || [ -n "$_fs" ]; do
                [[ $_fs ]] || continue
                [[ $_fs == "autofs" ]] && continue
                printf "%s" "$_fs"
                return 0
            done
            return 1
        } && return 0
    fi

    [[ ! -f "${dracutsysrootdir-}"/etc/fstab ]] && return 1

    findmnt --fstab -e -v -n -o 'FSTYPE' --target "$1" | {
        while read -r _fs || [ -n "$_fs" ]; do
            [[ $_fs ]] || continue
            [[ $_fs == "autofs" ]] && continue
            printf "%s" "$_fs"
            return 0
        done
        return 1
    } && return 0

    return 1
}

# find_dev_fstype <device>
# Echo the filesystem type for a given device.
# /proc/self/mountinfo is taken as the primary source of information
# and /etc/fstab is used as a fallback.
# No newline is appended!
# Example:
# $ find_dev_fstype /dev/sda2;echo
# ext4
find_dev_fstype() {
    local _find_dev _fs
    _find_dev="$1"
    if ! [[ $_find_dev == /dev* ]]; then
        [[ -b "/dev/block/$_find_dev" ]] && _find_dev="/dev/block/$_find_dev"
    fi

    if [[ $use_fstab != yes ]]; then
        findmnt -e -v -n -o 'FSTYPE' --source "$_find_dev" | {
            while read -r _fs || [ -n "$_fs" ]; do
                [[ $_fs ]] || continue
                [[ $_fs == "autofs" ]] && continue
                printf "%s" "$_fs"
                return 0
            done
            return 1
        } && return 0
    fi

    [[ ! -f "${dracutsysrootdir-}"/etc/fstab ]] && return 1

    findmnt --fstab -e -v -n -o 'FSTYPE' --source "$_find_dev" | {
        while read -r _fs || [ -n "$_fs" ]; do
            [[ $_fs ]] || continue
            [[ $_fs == "autofs" ]] && continue
            printf "%s" "$_fs"
            return 0
        done
        return 1
    } && return 0

    return 1
}

# find_mp_fsopts <mountpoint>
# Echo the filesystem options for a given mountpoint.
# /proc/self/mountinfo is taken as the primary source of information
# and /etc/fstab is used as a fallback.
# No newline is appended!
# Example:
# $ find_mp_fsopts /;echo
# rw,relatime,discard,data=ordered
find_mp_fsopts() {
    if [[ $use_fstab != yes ]]; then
        findmnt -e -v -n -o 'OPTIONS' --target "$1" 2> /dev/null && return 0
    fi

    [[ ! -f "${dracutsysrootdir-}"/etc/fstab ]] && return 1

    findmnt --fstab -e -v -n -o 'OPTIONS' --target "$1"
}

# find_dev_fsopts <device>
# Echo the filesystem options for a given device.
# /proc/self/mountinfo is taken as the primary source of information
# and /etc/fstab is used as a fallback.
# if `use_fstab == yes`, then only `/etc/fstab` is used.
#
# Example:
# $ find_dev_fsopts /dev/sda2
# rw,relatime,discard,data=ordered
find_dev_fsopts() {
    local _find_dev
    _find_dev="$1"
    if ! [[ $_find_dev == /dev* ]]; then
        [[ -b "/dev/block/$_find_dev" ]] && _find_dev="/dev/block/$_find_dev"
    fi

    if [[ $use_fstab != yes ]]; then
        findmnt -e -v -n -o 'OPTIONS' --source "$_find_dev" 2> /dev/null && return 0
    fi

    [[ ! -f "${dracutsysrootdir-}"/etc/fstab ]] && return 1

    findmnt --fstab -e -v -n -o 'OPTIONS' --source "$_find_dev"
}

# finds the major:minor of the block device backing the root filesystem.
find_root_block_device() { find_block_device /; }

# for_each_host_dev_fs <func>
# Execute "<func> <dev> <filesystem>" for every "<dev> <fs>" pair found
# in ${host_fs_types[@]}
for_each_host_dev_fs() {
    local _func="$1"
    local _dev
    local _ret=1

    [[ "${#host_fs_types[@]}" ]] || return 2

    for _dev in "${!host_fs_types[@]}"; do
        $_func "$_dev" "${host_fs_types[$_dev]}" && _ret=0
    done
    return $_ret
}

# Walk all the slave relationships for a given block device.
# Stop when our helper function returns success
# $1 = function to call on every found block device
# $2 = block device in major:minor format
check_block_and_slaves() {
    local _x
    [[ -b /dev/block/$2 ]] || return 1 # Not a block device? So sorry.
    if ! lvm_internal_dev "$2"; then "$1" "$2" && return; fi
    check_vol_slaves "$@" && return 0
    if [[ -f /sys/dev/block/$2/../dev ]] && [[ /sys/dev/block/$2/../subsystem -ef /sys/class/block ]]; then
        check_block_and_slaves "$1" "$(< "/sys/dev/block/$2/../dev")" && return 0
    fi
    for _x in /sys/dev/block/"$2"/slaves/*; do
        [[ -f $_x/dev ]] || continue
        [[ $_x/subsystem -ef /sys/class/block ]] || continue
        check_block_and_slaves "$1" "$(< "$_x/dev")" && return 0
    done
    return 1
}

check_block_and_slaves_all() {
    local _x _ret=1
    [[ -b /dev/block/$2 ]] || return 1 # Not a block device? So sorry.
    if ! lvm_internal_dev "$2" && "$1" "$2"; then
        _ret=0
    fi
    check_vol_slaves_all "$@" && return 0
    if [[ -f /sys/dev/block/$2/../dev ]] && [[ /sys/dev/block/$2/../subsystem -ef /sys/class/block ]]; then
        check_block_and_slaves_all "$1" "$(< "/sys/dev/block/$2/../dev")" && _ret=0
    fi
    for _x in /sys/dev/block/"$2"/slaves/*; do
        [[ -f $_x/dev ]] || continue
        [[ $_x/subsystem -ef /sys/class/block ]] || continue
        check_block_and_slaves_all "$1" "$(< "$_x/dev")" && _ret=0
    done
    return $_ret
}
# for_each_host_dev_and_slaves <func>
# Execute "<func> <dev>" for every "<dev>" found
# in ${host_devs[@]} and their slaves
for_each_host_dev_and_slaves_all() {
    local _func="$1"
    local _dev
    local _ret=1

    [[ "${host_devs[*]}" ]] || [[ "${user_devs[*]}" ]] || return 2

    for _dev in "${host_devs[@]}" "${user_devs[@]}"; do
        [[ -b $_dev ]] || continue
        if check_block_and_slaves_all "$_func" "$(get_maj_min "$_dev")"; then
            _ret=0
        fi
    done
    return $_ret
}

for_each_host_dev_and_slaves() {
    local _func="$1"
    local _dev

    [[ "${host_devs[*]}" ]] || [[ "${user_devs[*]}" ]] || return 2

    for _dev in "${host_devs[@]}" "${user_devs[@]}"; do
        [[ -b $_dev ]] || continue
        check_block_and_slaves "$_func" "$(get_maj_min "$_dev")" && return 0
    done
    return 1
}

# /sys/dev/block/major:minor is symbol link to real hardware device
# go downstream $(realpath /sys/dev/block/major:minor) to detect driver
get_blockdev_drv_through_sys() {
    local _block_mods=""
    local _path

    _path=$(realpath "$1")
    while :; do
        if [[ -L "$_path"/driver/module ]]; then
            _mod=$(realpath "$_path"/driver/module)
            _mod=$(basename "$_mod")
            _block_mods="$_block_mods $_mod"
        fi
        _path=$(dirname "$_path")
        if [[ $_path == '/sys/devices' ]] || [[ $_path == '/' ]]; then
            break
        fi
    done
    echo "$_block_mods"
}

# get_lvm_dm_dev <maj:min>
# If $1 is an LVM device-mapper device, return the path to its dm directory
get_lvm_dm_dev() {
    local _majmin _dm
    _majmin="$1"
    _dm=/sys/dev/block/$_majmin/dm
    [[ ! -f $_dm/uuid || $(< "$_dm"/uuid) != LVM-* ]] && return 1
    printf "%s" "$_dm"
}

# ugly workaround for the lvm design
# There is no volume group device,
# so, there are no slave devices for volume groups.
# Logical volumes only have the slave devices they really live on,
# but you cannot create the logical volume without the volume group.
# And the volume group might be bigger than the devices the LV needs.
check_vol_slaves() {
    local _vg _pv _majmin _dm
    _majmin="$2"
    _dm=$(get_lvm_dm_dev "$_majmin")
    [[ -z $_dm ]] && return 1 # not an LVM device-mapper device
    _vg=$(dmsetup splitname --noheadings -o vg_name "$(< "$_dm/name")")
    # strip space
    _vg="${_vg//[[:space:]]/}"
    if [[ $_vg ]]; then
        for _pv in $(lvm vgs --noheadings -o pv_name "$_vg" 2> /dev/null); do
            check_block_and_slaves "$1" "$(get_maj_min "$_pv")" && return 0
        done
    fi
    return 1
}

check_vol_slaves_all() {
    local _vg _pv _majmin _dm _ret=1
    _majmin="$2"
    _dm=$(get_lvm_dm_dev "$_majmin")
    [[ -z $_dm ]] && return 1 # not an LVM device-mapper device
    _vg=$(dmsetup splitname --noheadings -o vg_name "$(< "$_dm/name")")
    # strip space
    _vg="${_vg//[[:space:]]/}"
    if [[ $_vg ]]; then
        # when filter/global_filter is set, lvm may be failed
        if ! lvm lvs --noheadings -o vg_name "$_vg" 2> /dev/null 1> /dev/null; then
            return 1
        fi

        for _pv in $(lvm vgs --noheadings -o pv_name "$_vg" 2> /dev/null); do
            check_block_and_slaves_all "$1" "$(get_maj_min "$_pv")" && _ret=0
        done
    fi
    return $_ret
}

# fs_get_option <filesystem options> <search for option>
# search for a specific option in a bunch of filesystem options
# and return the value
fs_get_option() {
    local _fsopts=$1
    local _option=$2
    local OLDIFS="$IFS"
    IFS=,
    # shellcheck disable=SC2086
    set -- $_fsopts
    IFS="$OLDIFS"
    while [ $# -gt 0 ]; do
        case $1 in
            $_option=*)
                echo "${1#"${_option}"=}"
                break
                ;;
        esac
        shift
    done
}

check_kernel_config() {
    local _config_opt="$1"
    local _config_file

    # If $no_kernel is set, $kernel will point to the running kernel.
    # Avoid reading the current kernel config by mistake.
    [[ $no_kernel == yes ]] && return 0

    local _config_paths=(
        "/lib/modules/$kernel/config"
        "/lib/modules/$kernel/build/.config"
        "/lib/modules/$kernel/source/.config"
        "/usr/src/linux-$kernel/.config"
        "/boot/config-$kernel"
    )

    for _config in "${_config_paths[@]}"; do
        if [[ -f ${dracutsysrootdir-}$_config ]]; then
            _config_file="$_config"
            break
        fi
    done

    # no kernel config file, so return true
    [[ $_config_file ]] || return 0

    grep -q "^${_config_opt}=" "${dracutsysrootdir-}$_config_file"
    return $?
}

# 0 if the kernel module is either built-in or available
# 1 if the kernel module is not enabled
check_kernel_module() {
    if command -v kmod > /dev/null 2> /dev/null; then
        modprobe -d "$drivers_dir/../../../" -S "$kernel" --dry-run "$1" &> /dev/null || return 1
    fi
}

# get_cpu_vendor
# Only two values are returned: AMD or Intel
get_cpu_vendor() {
    if grep -qE AMD /proc/cpuinfo; then
        printf "AMD"
    fi
    if grep -qE Intel /proc/cpuinfo; then
        printf "Intel"
    fi
}

# get_host_ucode
# Get the hosts' ucode file based on the /proc/cpuinfo
get_ucode_file() {
    local family
    local model
    local stepping
    family=$(grep -E "cpu family" /proc/cpuinfo | head -1 | sed "s/.*:\ //")
    model=$(grep -E "model" /proc/cpuinfo | grep -v name | head -1 | sed "s/.*:\ //")
    stepping=$(grep -E "stepping" /proc/cpuinfo | head -1 | sed "s/.*:\ //")

    if [[ "$(get_cpu_vendor)" == "AMD" ]]; then
        if [[ $family -ge 21 ]]; then
            printf "microcode_amd_fam%xh.bin" "$family"
        else
            printf "microcode_amd.bin"
        fi
    fi
    if [[ "$(get_cpu_vendor)" == "Intel" ]]; then
        # The /proc/cpuinfo are in decimal.
        printf "%02x-%02x-%02x" "${family}" "${model}" "${stepping}"
    fi
}

# Not every device in /dev/mapper should be examined.
# If it is an LVM device, touch only devices which have /dev/VG/LV symlink.
lvm_internal_dev() {
    local _majmin _dm
    _majmin="$1"
    _dm=$(get_lvm_dm_dev "$_majmin")
    [[ -z $_dm ]] && return 1 # not an LVM device-mapper device
    local DM_VG_NAME DM_LV_NAME DM_LV_LAYER
    eval "$(dmsetup splitname --nameprefixes --noheadings --rows "$(< "$_dm/name")" 2> /dev/null)"
    [[ ${DM_VG_NAME} ]] && [[ ${DM_LV_NAME} ]] || return 0 # Better skip this!
    [[ ${DM_LV_LAYER} ]] || [[ ! -L /dev/${DM_VG_NAME}/${DM_LV_NAME} ]]
}

btrfs_devs() {
    local _mp="$1"
    btrfs device usage "$_mp" \
        | while read -r _dev _; do
            str_starts "$_dev" "/" || continue
            _dev=${_dev%,}
            printf -- "%s\n" "$_dev"
        done
}

zfs_devs() {
    local _mp="$1"
    zpool list -H -v -P "${_mp%%/*}" | awk -F$'\t' '$2 ~ /^\// {print $2}' \
        | while read -r _dev; do
            realpath "${_dev}"
        done
}

iface_for_remote_addr() {
    # shellcheck disable=SC2046
    set -- $(ip -o route get to "$1")
    while [ $# -gt 0 ]; do
        case $1 in
            dev)
                echo "$2"
                return
                ;;
        esac
        shift
    done
}

local_addr_for_remote_addr() {
    # shellcheck disable=SC2046
    set -- $(ip -o route get to "$1")
    while [ $# -gt 0 ]; do
        case $1 in
            src)
                echo "$2"
                return
                ;;
        esac
        shift
    done
}

peer_for_addr() {
    local addr=$1
    local qtd

    # quote periods in IPv4 address
    qtd=${addr//./\\.}
    ip -o addr show \
        | sed -n 's%^.* '"$qtd"' peer \([0-9a-f.:]\{1,\}\(/[0-9]*\)\?\).*$%\1%p'
}

netmask_for_addr() {
    local addr=$1
    local qtd

    # quote periods in IPv4 address
    qtd=${addr//./\\.}
    ip -o addr show | sed -n 's,^.* '"$qtd"'/\([0-9]*\) .*$,\1,p'
}

gateway_for_iface() {
    local ifname=$1 addr=$2

    case $addr in
        *.*) proto=4 ;;
        *:*) proto=6 ;;
        *) return ;;
    esac
    ip -o -$proto route show \
        | sed -n "s/^default via \([0-9a-z.:]\{1,\}\) dev $ifname .*\$/\1/p"
}

is_unbracketed_ipv6_address() {
    strglob "$1" '*:*' && ! strglob "$1" '\[*:*\]'
}

# Create an ip= string to set up networking such that the given
# remote address can be reached
ip_params_for_remote_addr() {
    local remote_addr=$1
    local ifname local_addr peer netmask gateway ifmac

    [[ $remote_addr ]] || return 1
    ifname=$(iface_for_remote_addr "$remote_addr")
    [[ $ifname ]] || {
        berror "failed to determine interface to connect to $remote_addr"
        return 1
    }

    # ifname clause to bind the interface name to a MAC address
    if [ -d "/sys/class/net/$ifname/bonding" ]; then
        dinfo "Found bonded interface '${ifname}'. Make sure to provide an appropriate 'bond=' cmdline."
    elif [ -e "/sys/class/net/$ifname/address" ]; then
        ifmac=$(cat "/sys/class/net/$ifname/address")
        [[ $ifmac ]] && printf 'ifname=%s:%s ' "${ifname}" "${ifmac}"
    fi

    local_addr=$(local_addr_for_remote_addr "$remote_addr")
    [[ $local_addr ]] || {
        berror "failed to determine local address to connect to $remote_addr"
        return 1
    }
    peer=$(peer_for_addr "$local_addr")
    # Set peer or netmask, but not both
    [[ $peer ]] || netmask=$(netmask_for_addr "$local_addr")
    gateway=$(gateway_for_iface "$ifname" "$local_addr")
    # Quote IPv6 addresses with brackets
    is_unbracketed_ipv6_address "$local_addr" && local_addr="[$local_addr]"
    is_unbracketed_ipv6_address "$peer" && peer="[$peer]"
    is_unbracketed_ipv6_address "$gateway" && gateway="[$gateway]"
    printf 'ip=%s:%s:%s:%s::%s:none ' \
        "${local_addr}" "${peer}" "${gateway}" "${netmask}" "${ifname}"
}

# block_is_nbd <maj:min>
# Check whether $1 is an nbd device
block_is_nbd() {
    [[ -b /dev/block/$1 && $1 == 43:* ]]
}

# block_is_iscsi <maj:min>
# Check whether $1 is an iSCSI device
block_is_iscsi() {
    local _dir
    local _dev=$1
    [[ -L "/sys/dev/block/$_dev" ]] || return
    _dir="$(readlink -f "/sys/dev/block/$_dev")" || return
    until [[ -d "$_dir/sys" || -d "$_dir/iscsi_session" ]]; do
        _dir="$_dir/.."
    done
    [[ -d "$_dir/iscsi_session" ]]
}

# block_is_fcoe <maj:min>
# Check whether $1 is an FCoE device
# Will not work for HBAs that hide the ethernet aspect
# completely and present a pure FC device
block_is_fcoe() {
    local _dir
    local _dev=$1
    [[ -L "/sys/dev/block/$_dev" ]] || return
    _dir="$(readlink -f "/sys/dev/block/$_dev")"
    until [[ -d "$_dir/sys" ]]; do
        _dir="$_dir/.."
        if [[ -d "$_dir/subsystem" ]]; then
            subsystem=$(basename "$(readlink "$_dir"/subsystem)")
            [[ $subsystem == "fcoe" ]] && return 0
        fi
    done
    return 1
}

# block_is_netdevice <maj:min>
# Check whether $1 is a net device
block_is_netdevice() {
    block_is_nbd "$1" || block_is_iscsi "$1" || block_is_fcoe "$1"
}

# convert the driver name given by udevadm to the corresponding kernel module name
get_module_name() {
    local dev_driver
    while read -r dev_driver; do
        case "$dev_driver" in
            mmcblk)
                echo "mmc_block"
                ;;
            *)
                echo "$dev_driver"
                ;;
        esac
    done
}

# get the corresponding kernel modules of a /sys/class/*/* or/dev/* device
get_dev_module() {
    local dev_attr_walk
    local dev_drivers
    local dev_paths
    dev_attr_walk=$(udevadm info -a "$1")
    dev_drivers=$(echo "$dev_attr_walk" \
        | sed -n 's/\s*DRIVERS=="\(\S\+\)"/\1/p' \
        | get_module_name)

    # also return modalias info from sysfs paths parsed by udevadm
    dev_paths=$(echo "$dev_attr_walk" | sed -n 's/.*\(\/devices\/.*\)'\'':/\1/p')
    local dev_path
    for dev_path in $dev_paths; do
        local modalias_file="/sys$dev_path/modalias"
        if [ -e "$modalias_file" ]; then
            dev_drivers="$(printf "%s\n%s" "$dev_drivers" "$(cat "$modalias_file")")"
        fi
    done

    # if no kernel modules found and device is in a virtual subsystem, follow symlinks
    if [[ -z $dev_drivers && $(udevadm info -q path "$1") == "/devices/virtual"* ]]; then
        local dev_vkernel
        local dev_vsubsystem
        local dev_vpath
        dev_vkernel=$(echo "$dev_attr_walk" | sed -n 's/\s*KERNELS=="\(\S\+\)"/\1/p' | tail -1)
        dev_vsubsystem=$(echo "$dev_attr_walk" | sed -n 's/\s*SUBSYSTEMS=="\(\S\+\)"/\1/p' | tail -1)
        dev_vpath="/sys/devices/virtual/$dev_vsubsystem/$dev_vkernel"
        if [[ -n $dev_vkernel && -n $dev_vsubsystem && -d $dev_vpath ]]; then
            local dev_links
            local dev_link
            dev_links=$(find "$dev_vpath" -maxdepth 1 -type l ! -name "subsystem" -exec readlink {} \;)
            for dev_link in $dev_links; do
                [[ -n $dev_drivers && ${dev_drivers: -1} != $'\n' ]] && dev_drivers+=$'\n'
                dev_drivers+=$(udevadm info -a "$dev_vpath/$dev_link" \
                    | sed -n 's/\s*DRIVERS=="\(\S\+\)"/\1/p' \
                    | get_module_name \
                    | grep -v -e pcieport)
            done
        fi
    fi
    echo "$dev_drivers"
}

# Check if file is in PE format
pe_file_format() {
    if [[ $# -eq 1 ]]; then
        local magic
        magic=$("${OBJDUMP:-objdump}" -p "$1" \
            | awk '{if ($1 == "Magic"){print $2}}')
        # 010b (PE32), 020b (PE32+)
        [[ $magic == "020b" || $magic == "010b" ]] && return 0
    fi
    return 1
}

# Get specific data from the PE header
pe_get_header_data() {
    local data_header
    [[ $# -ne "2" ]] && return 1
    [[ $(pe_file_format "$1") -eq 1 ]] && return 1
    data_header=$("${OBJDUMP:-objdump}" -p "$1" \
        | awk -v data="$2" '{if ($1 == data){print $2}}')
    echo "$data_header"
}

# Get the SectionAlignment data from the PE header
pe_get_section_align() {
    local align_hex
    [[ $# -ne "1" ]] && return 1
    align_hex=$(pe_get_header_data "$1" "SectionAlignment")
    [[ $? -eq 1 ]] && return 1
    echo "$((16#$align_hex))"
}

# Get the ImageBase data from the PE header
pe_get_image_base() {
    local base_image
    [[ $# -ne "1" ]] && return 1
    base_image=$(pe_get_header_data "$1" "ImageBase")
    [[ $? -eq 1 ]] && return 1
    echo "$((16#$base_image))"
}

inst_dir() {
    local _ret
    [[ -e ${initdir}/"$1" ]] && return 0 # already there
    if $DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${initdir:+-D "$initdir"} -d "$@"; then
        return 0
    else
        _ret=$?
        derror FAILED: "$DRACUT_INSTALL" ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${initdir:+-D "$initdir"} -d "$@"
        return "$_ret"
    fi
}

inst() {
    local dstdir="${dstdir:-"$initdir"}"
    local _ret _hostonly_install _resolve_deps
    if [[ $1 == "-H" ]] && [[ $hostonly ]]; then
        _hostonly_install="-H"
        shift
    fi
    [[ -e ${dstdir}/"${2:-$1}" ]] && return 0 # already there
    [[ ${DRACUT_RESOLVE_LAZY-} ]] || _resolve_deps=1
    if $DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${dstdir:+-D "$dstdir"} ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} ${_hostonly_install:+-H} "$@"; then
        return 0
    else
        _ret=$?
        derror FAILED: "$DRACUT_INSTALL" ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${dstdir:+-D "$dstdir"} ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} ${_hostonly_install:+-H} "$@"
        return $_ret
    fi
}

inst_binary() {
    local _ret _resolve_deps
    [[ ${DRACUT_RESOLVE_LAZY-} ]] || _resolve_deps=1
    if $DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${initdir:+-D "$initdir"} ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} "$@"; then
        return 0
    else
        _ret=$?
        derror FAILED: "$DRACUT_INSTALL" ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${initdir:+-D "$initdir"} ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} "$@"
        return "$_ret"
    fi
}

inst_script() {
    local _ret _resolve_deps
    [[ ${DRACUT_RESOLVE_LAZY-} ]] || _resolve_deps=1
    if $DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${initdir:+-D "$initdir"} ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} "$@"; then
        return 0
    else
        _ret=$?
        derror FAILED: "$DRACUT_INSTALL" ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${initdir:+-D "$initdir"} ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} "$@"
        return "$_ret"
    fi
}

inst_simple() {
    local dstdir="${dstdir:-"$initdir"}"
    local _ret _hostonly_install
    if [[ $1 == "-H" ]] && [[ $hostonly ]]; then
        _hostonly_install="-H"
        shift
    fi
    [[ -e ${dstdir}/"${2:-$1}" ]] && return 0 # already there
    if [[ $1 == /* ]]; then
        [[ -e ${dracutsysrootdir-}/${1#"${dracutsysrootdir-}"} ]] || return 1 # no source
    else
        [[ -e $1 ]] || return 1 # no source
    fi
    if $DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${dstdir:+-D "$dstdir"} ${loginstall:+-L "$loginstall"} ${_hostonly_install:+-H} "$@"; then
        return 0
    else
        _ret=$?
        derror FAILED: "$DRACUT_INSTALL" ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${dstdir:+-D "$dstdir"} ${loginstall:+-L "$loginstall"} ${_hostonly_install:+-H} "$@"
        return $_ret
    fi
}

inst_multiple() {
    local dstdir="${dstdir:-"$initdir"}"
    local _ret _hostonly_install _resolve_deps
    if [[ $1 == "-H" ]] && [[ $hostonly ]]; then
        _hostonly_install="-H"
        shift
    fi
    [[ ${DRACUT_RESOLVE_LAZY-} ]] || _resolve_deps=1
    if $DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${dstdir:+-D "$dstdir"} -a ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} ${_hostonly_install:+-H} "$@"; then
        return 0
    else
        _ret=$?
        derror FAILED: "$DRACUT_INSTALL" ${dracutsysrootdir:+-r "$dracutsysrootdir"} ${dstdir:+-D "$dstdir"} -a ${loginstall:+-L "$loginstall"} ${_resolve_deps:+-l} ${DRACUT_FIPS_MODE:+-f} ${_hostonly_install:+-H} "$@"
        return $_ret
    fi
}

# install function specialized for hooks
# $1 = type of hook, $2 = hook priority (lower runs first), $3 = hook
# All hooks should be POSIX/SuS compliant, they will be sourced by init.
inst_hook() {
    local hook
    if ! [[ -f $3 ]]; then
        dfatal "Cannot install a hook ($3) that does not exist."
        dfatal "Aborting initrd creation."
        exit 1
    elif ! [[ $hookdirs == *$1* ]]; then
        dfatal "No such hook type $1. Aborting initrd creation."
        exit 1
    fi
    hook="/var/lib/dracut/hooks/${1}/${2}-${3##*/}"
    inst_simple "$3" "$hook"
    chmod u+x "$initdir/$hook"
}

dracut_need_initqueue() {
    : > "$initdir/lib/dracut/need-initqueue"
}

# attempt to install any programs specified in a udev rule
_inst_rule_programs() {
    local _prog _bin

    # shellcheck disable=SC2013
    for _prog in $(sed -nr 's/.*PROGRAM==?"([^ "]+).*/\1/p' "$1"); do
        _bin=""
        if [[ -x "${dracutsysrootdir-}${udevdir}/$_prog" ]]; then
            _bin="${udevdir}"/$_prog
        elif [[ ${_prog/\$env\{/} == "$_prog" ]]; then
            _bin=$(find_binary "$_prog") || {
                dinfo "Skipping program $_prog using in udev rule ${1##*/} as it cannot be found"
                continue
            }
        fi

        [[ $_bin ]] && inst_binary "$_bin"
    done

    # shellcheck disable=SC2013
    for _prog in $(sed -nr 's/.*RUN[+=]=?"([^ "]+).*/\1/p' "$1"); do
        _bin=""
        if [[ -x "${dracutsysrootdir-}${udevdir}/$_prog" ]]; then
            _bin=${udevdir}/$_prog
        elif [[ ${_prog/\$env\{/} == "$_prog" ]] && [[ ${_prog} != "/sbin/initqueue" ]]; then
            _bin=$(find_binary "$_prog") || {
                dinfo "Skipping program $_prog using in udev rule ${1##*/} as it cannot be found"
                continue
            }
        fi

        [[ $_bin ]] && inst_binary "$_bin"
    done

    # shellcheck disable=SC2013
    for _prog in $(sed -nr 's/.*IMPORT\{program\}==?"([^ "]+).*/\1/p' "$1"); do
        _bin=""
        if [[ -x "${dracutsysrootdir-}${udevdir}/$_prog" ]]; then
            _bin=${udevdir}/$_prog
        elif [[ ${_prog/\$env\{/} == "$_prog" ]]; then
            _bin=$(find_binary "$_prog") || {
                dinfo "Skipping program $_prog using in udev rule ${1##*/} as it cannot be found"
                continue
            }
        fi

        [[ $_bin ]] && inst_multiple "$_bin"
    done
}

# attempt to create any groups and users specified in a udev rule
_inst_rule_group_owner() {
    local i

    # shellcheck disable=SC2013
    for i in $(sed -nr 's/.*OWNER=?"([^ "]+).*/\1/p' "$1"); do
        if ! grep -Eqs "^$i:" "$initdir/etc/passwd"; then
            grep -Es "^$i:" "${dracutsysrootdir-}/etc/passwd" >> "$initdir/etc/passwd"
        fi
    done

    # shellcheck disable=SC2013
    for i in $(sed -nr 's/.*GROUP=?"([^ "]+).*/\1/p' "$1"); do
        if ! grep -Eqs "^$i:" "$initdir/etc/group"; then
            grep -Es "^$i:" "${dracutsysrootdir-}/etc/group" >> "$initdir/etc/group"
        fi
    done
}

_inst_rule_initqueue() {
    if grep -q -F initqueue "$1"; then
        dracut_need_initqueue
    fi
}

# udev rules always get installed in the same place, so
# create a function to install them to make life simpler.
inst_rules() {
    local _target=/etc/udev/rules.d _rule _found

    inst_dir "${udevdir}/rules.d"
    inst_dir "$_target"
    for _rule in "$@"; do
        if [ "${_rule#/}" = "$_rule" ]; then
            for r in ${hostonly:+"${dracutsysrootdir-}"/etc/udev/rules.d} "${dracutsysrootdir-}${udevdir}/rules.d"; do
                [[ -e $r/$_rule ]] || continue
                _found="$r/$_rule"
                _inst_rule_programs "$_found"
                _inst_rule_group_owner "$_found"
                _inst_rule_initqueue "$_found"
                inst_simple "$_found"
            done
        fi
        for r in '' "${dracutsysrootdir-}$dracutbasedir/rules.d/"; do
            # skip rules without an absolute path
            [[ "${r}$_rule" != /* ]] && continue
            [[ -f ${r}$_rule ]] || continue
            _found="${r}$_rule"
            _inst_rule_programs "$_found"
            _inst_rule_group_owner "$_found"
            _inst_rule_initqueue "$_found"
            inst_simple "$_found" "$_target/${_found##*/}"
        done
        [[ $_found ]] || ddebug "Skipping udev rule: $_rule"
    done
}

# install sysusers files
inst_sysusers() {
    inst_multiple -o "$sysusers/$*" "$sysusers/acct-*-$*"

    if [[ ${hostonly-} ]]; then
        inst_multiple -H -o "$sysusersconfdir/$*" "$sysusers/acct-*-$*"
    fi
}

# inst_libdir_dir <dir> [<dir>...]
# Install a <dir> located on a lib directory to the initramfs image
inst_libdir_dir() {
    local -a _dirs
    for _dir in $libdirs; do
        for _i in "$@"; do
            for _d in "${dracutsysrootdir-}$_dir"/$_i; do
                [[ -d $_d ]] && _dirs+=("${_d#"${dracutsysrootdir-}"}")
            done
        done
    done
    for _dir in "${_dirs[@]}"; do
        inst_dir "$_dir"
    done
}

# inst_libdir_file [-n <pattern>] <file> [<file>...]
# Install a <file> located on a lib directory to the initramfs image
# -n <pattern> install matching files
inst_libdir_file() {
    local -a _files=()
    if [[ $1 == "-n" ]]; then
        local _pattern=$2
        shift 2
        for _dir in $libdirs; do
            for _i in "$@"; do
                for _f in "${dracutsysrootdir-}$_dir"/$_i; do
                    [[ ${_f#"${dracutsysrootdir-}"} =~ $_pattern ]] || continue
                    [[ -e $_f ]] && _files+=("${_f#"${dracutsysrootdir-}"}")
                done
            done
        done
    else
        for _dir in $libdirs; do
            for _i in "$@"; do
                for _f in "${dracutsysrootdir-}$_dir"/$_i; do
                    [[ -e $_f ]] && _files+=("${_f#"${dracutsysrootdir-}"}")
                done
            done
        done
    fi
    [[ ${#_files[@]} -gt 0 ]] && inst_multiple "${_files[@]}"
}

instmods() {
    # instmods [-c [-s]] <kernel module> [<kernel module> ... ]
    # instmods [-c [-s]] <kernel subsystem>
    # install kernel modules along with all their dependencies.
    # <kernel subsystem> can be e.g. "=block" or "=drivers/usb/storage"
    # -c check
    # -s silent
    local dstdir="${dstdir:-"$initdir"}"
    local _optional="-o"
    local _silent
    local _ret

    [[ $no_kernel == yes ]] && return

    if [[ $1 == '-c' ]]; then
        unset _optional
        shift
    fi
    if [[ $1 == '-s' ]]; then
        _silent=1
        shift
    fi

    if (($# == 0)); then
        read -r -d '' -a args
        set -- "${args[@]}"
    fi

    if (($# == 0)); then
        return 0
    fi

    $DRACUT_INSTALL \
        ${dstdir:+-D "$dstdir"} \
        ${dracutsysrootdir:+-r "$dracutsysrootdir"} \
        ${loginstall:+-L "$loginstall"} \
        ${hostonly:+-H} \
        ${omit_drivers:+-N "$omit_drivers"} \
        ${srcmods:+--kerneldir "$srcmods"} \
        ${_optional:+-o} \
        ${_silent:+--silent} \
        -m "$@"
    _ret=$?

    if ((_ret != 0)) && [[ -z $_silent ]]; then
        derror "FAILED: " \
            "$DRACUT_INSTALL" \
            ${dstdir:+-D "$dstdir"} \
            ${dracutsysrootdir:+-r "$dracutsysrootdir"} \
            ${loginstall:+-L "$loginstall"} \
            ${hostonly:+-H} \
            ${omit_drivers:+-N "$omit_drivers"} \
            ${srcmods:+--kerneldir "$srcmods"} \
            ${_optional:+-o} \
            ${_silent:+--silent} \
            -m "$@"
    fi

    [[ "$_optional" ]] && return 0
    return $_ret
}

# Use with form hostonly="$(optional_hostonly)" inst_xxxx <args>
# If hostonly mode is set to "strict", hostonly restrictions will still
# be applied, else will ignore hostonly mode and try to install all
# given modules.
optional_hostonly() {
    if [[ $hostonly_mode == "strict" ]]; then
        printf -- "%s" "${hostonly-}"
    else
        printf ""
    fi
}

# helper function for check() in module-setup.sh
# to check for required installed binaries
# issues a standardized warning message
require_binaries() {
    local _module_name="${moddir##*/}"
    local _ret=0

    for cmd in "$@"; do
        if ! find_binary "$cmd" &> /dev/null; then
            ddebug "Module '${_module_name#[0-9][0-9]}' will not be installed, because command '$cmd' could not be found!"
            ((_ret++))
        fi
    done
    return "$_ret"
}

require_any_binary() {
    local _module_name="${moddir##*/}"
    local _ret=1

    for cmd in "$@"; do
        if find_binary "$cmd" &> /dev/null; then
            _ret=0
            break
        fi
    done

    if ((_ret != 0)); then
        dinfo "$_module_name: Could not find any command of '$*'!"
        return 1
    fi

    return 0
}

# helper function for check() in module-setup.sh
# to check for required kernel modules
# issues a standardized warning message
require_kernel_modules() {
    local _module_name="${moddir##*/}"
    local _ret=0

    # Ignore kernel module requirement for no-kernel build
    [[ $no_kernel == yes ]] && return 0

    for mod in "$@"; do
        if ! check_kernel_module "$mod" &> /dev/null; then
            dinfo "Module '${_module_name#[0-9][0-9]}' will not be installed, because kernel module '$mod' is not available!"
            ((_ret++))
        fi
    done
    return "$_ret"
}

determine_kernel_image() {
    local kversion="$1"
    local paths=(
        "${dracutsysrootdir-}/lib/modules/${kversion}/vmlinuz"
        "${dracutsysrootdir-}/lib/modules/${kversion}/vmlinux"
        "${dracutsysrootdir-}/lib/modules/${kversion}/Image"
        "${dracutsysrootdir-}/boot/vmlinuz-${kversion}"
        "${dracutsysrootdir-}/boot/vmlinux-${kversion}"
    )

    for path in "${paths[@]}"; do
        if [ -s "$path" ]; then
            echo "$path"
            return 0
        fi
    done

    echo "Could not find a Linux kernel image for version '$kversion'!" >&2
    return 1
}

_detect_library_directories() {
    local -a libdirs=()
    local line

    if [[ $($DRACUT_INSTALL ${dracutsysrootdir:+-r "$dracutsysrootdir"} --dry-run -R "$DRACUT_TESTBIN") == */lib64/* ]] &> /dev/null \
        && [[ -d "${dracutsysrootdir-}/lib64" ]]; then
        libdirs+=("/lib64")
        [[ -d "${dracutsysrootdir-}/usr/lib64" ]] && libdirs+=("/usr/lib64")
    fi

    if [[ -d "${dracutsysrootdir-}/lib" ]]; then
        libdirs+=("/lib")
        [[ -d "${dracutsysrootdir-}/usr/lib" ]] && libdirs+=("/usr/lib")
    fi

    while IFS='' read -r line; do libdirs+=("$line"); done < <(ldconfig_paths)

    echo "${libdirs[@]}"
}

if ! _is_func dinfo > /dev/null 2>&1; then
    # shellcheck source=./dracut-logger.sh
    . "${BASH_SOURCE[0]%/*}/dracut-logger.sh"
    dlog_init
fi

DRACUT_LDCONFIG=${DRACUT_LDCONFIG:-ldconfig}
DRACUT_TESTBIN=${DRACUT_TESTBIN:-/bin/sh}

if ! [[ "${DRACUT_INSTALL-}" ]]; then
    DRACUT_INSTALL=$(find_binary dracut-install || :)
fi

if ! [[ $DRACUT_INSTALL ]] && [[ -x "${BASH_SOURCE[0]%/*}/dracut-install" ]]; then
    DRACUT_INSTALL="${BASH_SOURCE[0]%/*}/dracut-install"
elif ! [[ $DRACUT_INSTALL ]] && [[ -x "${BASH_SOURCE[0]%/*}/src/install/dracut-install" ]]; then
    DRACUT_INSTALL="${BASH_SOURCE[0]%/*}/src/install/dracut-install"
fi

# Test if the configured dracut-install command exists.
# Catch DRACUT_INSTALL being unset/empty.
# The variable DRACUT_INSTALL may be set externally as:
# DRACUT_INSTALL="valgrind dracut-install"
# or
# DRACUT_INSTALL="dracut-install --debug"
# in that case check if the first parameter (e.g. valgrind) is executable.
if ! command -v "${DRACUT_INSTALL%% *}" > /dev/null 2>&1; then
    dfatal "${DRACUT_INSTALL:-dracut-install} not found!"
    exit 10
fi

if ! [[ ${libdirs-} ]]; then
    libdirs=$(_detect_library_directories)
fi
