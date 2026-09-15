#!/bin/sh

# replaces all occurrences of 'search' in 'str' with 'replacement'
#
# str_replace str search replacement
#
# example:
# str_replace '  one two  three  ' ' ' '_'
str_replace() {
    local in="$1"
    local s="$2"
    local r="$3"
    local out=''

    while [ "${in##*"$s"*}" != "$in" ]; do
        chop="${in%%"$s"*}"
        out="${out}${chop}$r"
        in="${in#*"$s"}"
    done
    printf -- '%s' "${out}${in}"
}

# Set 'aptName' to an appropriate name for device $1 partition [$2]. Device names
# that end with a digit must have a 'p' prepended to the partition number.
aptPartitionName() {
    local "dev=$1" "ptNbr=${2:-1}"
    # Default to partition 1 if missing.
    # shellcheck disable=SC2034
    case $dev in
        *[0-9]) aptName="${dev}p$ptNbr" ;;
        *) aptName="${dev}$ptNbr" ;;
    esac
}

# Set variable 'DUN' and printf a systemd-compatible unit name from a path=$1.
# (mimics unit_name_from_path_instance())
dev_unit_name() {
    local -
    local "dev=$1" out='' chop
    set +x

    case $dev in
        '' | /)
            printf -- '-'
            return 0
            ;;
    esac

    dev="${dev#"${dev%%[^/]*}"}"
    dev="${dev%"${dev##*[^/]}"}"
    while :; do case $dev in *//*) dev="${dev%%//*}/${dev#*//}" ;; *) break ;; esac done
    DUN=''
    [ "${dev#\.}" != "$dev" ] && DUN='\x2e'
    dev="${dev#\.}"
    while :; do
        case $dev in
            *[\\/\ -]*)
                chop="${dev%%[\\/ -]*}"
                out="${out}${chop}"
                case $dev in
                    "${chop}\\"*)
                        out="${out}"'\x5c'
                        dev="${dev#"${chop}\\"}"
                        ;;
                    "${chop}/"*)
                        out="${out}-"
                        dev="${dev#"${chop}/"}"
                        ;;
                    "${chop} "*)
                        out="${out}"'\x20'
                        dev="${dev#"${chop} "}"
                        ;;
                    "${chop}-"*)
                        out="${out}"'\x2d'
                        dev="${dev#"${chop}-"}"
                        ;;
                esac
                ;;
            *)
                DUN="${DUN}${out}${dev}"
                break
                ;;
        esac
    done
    printf -- '%s' "$DUN"
}

# wait_for_dev <dev> [<timeout>]
#
# Installs a initqueue-finished script,
# which will cause the main loop only to exit,
# if the device <dev> is recognized by the system.
wait_for_dev() {
    local _name
    local _needreload
    local _noreload
    local _timeout
    local _unit

    if [ "$1" = "-n" ]; then
        _noreload=-n
        shift
    fi

    _name="$(str_replace "$1" '/' '\x2f')"

    type mark_hostonly > /dev/null 2>&1 && mark_hostonly "$hookdir/initqueue/finished/devexists-${_name}.sh"

    [ -e "${PREFIX-}$hookdir/initqueue/finished/devexists-${_name}.sh" ] && return 0

    printf '[ -e "%s" ]\n' "$1" \
        >> "${PREFIX-}$hookdir/initqueue/finished/devexists-${_name}.sh"
    {
        printf '[ -e "%s" ] || ' "$1"
        printf 'warn "\"%s\" does not exist"\n' "$1"
    } >> "${PREFIX-}$hookdir/emergency/80-${_name}.sh"

    [ -n "${DRACUT_SYSTEMD-}" ] || return 0
    _unit="$(dev_unit_name "$1").device"

    if ! [ -L "${PREFIX-}/etc/systemd/system/initrd.target.wants/${_unit}" ]; then
        [ -d "${PREFIX-}"/etc/systemd/system/initrd.target.wants ] || mkdir -p "${PREFIX-}"/etc/systemd/system/initrd.target.wants
        ln -s ../"${_unit}" "${PREFIX-}/etc/systemd/system/initrd.target.wants/${_unit}"
        type mark_hostonly > /dev/null 2>&1 && mark_hostonly /etc/systemd/system/initrd.target.wants/"${_unit}"
        _needreload=1
    fi

    if [ -n "$2" ]; then
        _timeout="$2"
    else
        _timeout=$(getarg rd.timeout)
    fi
    _timeout=${_timeout:-infinity}

    if ! [ -f "${PREFIX-}/etc/systemd/system/${_unit}.d/timeout.conf" ]; then
        mkdir -p "${PREFIX-}/etc/systemd/system/${_unit}.d"
        {
            echo "[Unit]"
            echo "JobTimeoutSec=$_timeout"
            echo "JobRunningTimeoutSec=$_timeout"
        } > "${PREFIX-}/etc/systemd/system/${_unit}.d/timeout.conf"
        type mark_hostonly > /dev/null 2>&1 && mark_hostonly /etc/systemd/system/"${_unit}".d/timeout.conf
        _needreload=1
    fi

    if [ -z "${PREFIX-}" ] && [ "$_needreload" = 1 ] && [ -z "$_noreload" ]; then
        /sbin/initqueue --onetime --unique --name daemon-reload systemctl daemon-reload
    fi
}

cancel_wait_for_dev() {
    local _name
    _name="$(str_replace "$1" '/' '\x2f')"
    rm -f -- "$hookdir/initqueue/finished/devexists-${_name}.sh"
    rm -f -- "$hookdir/emergency/80-${_name}.sh"
    if [ -n "${DRACUT_SYSTEMD-}" ]; then
        _name=$(dev_unit_name "$1")
        rm -f -- "${PREFIX-}/etc/systemd/system/initrd.target.wants/${_name}.device"
        rm -f -- "${PREFIX-}/etc/systemd/system/${_name}.device.d/timeout.conf"
        /sbin/initqueue --onetime --unique --name daemon-reload systemctl daemon-reload
    fi
}

# Find the disc device with a particular serial number.
#   $1 - device serial number (ID_SERIAL_SHORT).
#   False if not found.
ID_SERIAL_SHORT_to_DISC() {
    local -
    local "iss=$1" s_path dev_id ser
    for s_path in /sys/class/block/*; do
        DISC=''
        [ -d "$s_path" ] || continue
        [ -f "$s_path/partition" ] && continue
        read -r dev_id < "$s_path/dev" || continue
        case ${dev_id%:*} in
            # Exclude loop (7), cdrom (11), & zram (251, 252, 259)
            7 | 11 | 25[129]) continue ;;
        esac
        DISC="/dev/${s_path##*/}"
        [ -e "$DISC" ] || continue
        ser=''
        if [ -f "$s_path/device/serial" ]; then
            read -r ser < "$s_path/device/serial" 2> /dev/null
        elif [ -f "$s_path/device/device/serial" ]; then
            read -r ser < "$s_path/device/device/serial" 2> /dev/null
        fi
        case $ser in
            "$iss")
                echo "$DISC"
                return 0
                ;;
        esac
    done
    return 1
}

# Trigger a disk or partition having property spec
#  $1 - {{LABEL=|UUID=|PARTLABEL=|PARTUUID=}<appropriate id>|SERIALID=<ID_SERIAL_SHORT>/SERIALID/[partition_spec]}
#  for action $2 - [add|remove|change|move|online|offline|bind|unbind] default: add
#  with optional additional match [$3]
label_uuid_udevadm_trigger() {
    local "devspec=$1" "act=${2:-add}" "match=${3-}"
    case $devspec in
        SERIALID=*/SERIALID/*)
            devspec="${devspec#SERIALID=}"
            match="--property-match=ID_SERIAL_SHORT=${devspec%/SERIALID/*}${match:+ $match}"
            udevadm trigger --subsystem-match=block "--action=$act" "$match" --settle
            devspec="${devspec#*/SERIALID/}"
            # devspec may have a partition specified after /SERIALID/
            [ "$devspec" ] && label_uuid_udevadm_trigger "$devspec" "$act" "$match"
            return 0
            ;;
        LABEL=* | UUID=*)
            match="--property-match=ID_FS_${devspec}${match:+ $match}"
            ;;
        PARTLABEL=*)
            match="--property-match=ID_PART_ENTRY_NAME=${devspec#PARTLABEL=}${match:+ $match}"
            ;;
        PARTUUID=*)
            match="--property-match=ID_PART_ENTRY_UUID=${devspec#PARTUUID=}${match:+ $match}"
            ;;
        *[!0-9]* | 0*) return 1 ;; # Anything but a positive integer.
        *)
            match="${match} --attr-match=partition=$devspec"
            ;;
    esac
    # shellcheck disable=SC2086
    [ "$match" ] && udevadm trigger --subsystem-match=block "--action=$act" $match --settle
}
