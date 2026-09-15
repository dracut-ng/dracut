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
