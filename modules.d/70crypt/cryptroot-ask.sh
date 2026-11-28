#!/bin/sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin
NEWROOT=${NEWROOT:-"/sysroot"}

# do not ask, if we already have root
[ -d "$NEWROOT"/proc ] && exit 0

command -v getarg > /dev/null || . /lib/dracut-lib.sh

mkdir -p -m 0700 /run/cryptsetup

# if device name is /dev/dm-X, convert to /dev/mapper/name
if [ "${1##/dev/dm-}" != "$1" ]; then
    device="/dev/mapper/$(dmsetup info -c --noheadings -o name "$1")"
else
    device="$1"
fi

# default luksname - luks-UUID
luksname=$2

# is_keysource - ask for passphrase even if a rd.luks.key argument is set
is_keysource=${3:-0}

# number of tries
numtries=${4:-10}

# TODO: improve to support what cmdline does
if [ -f /etc/crypttab ] && getargbool 1 rd.luks.crypttab; then
    while read -r name dev luksfile luksoptions || [ -n "$name" ]; do
        # ignore blank lines and comments
        if [ -z "$name" ] || [ "${name#\#}" != "$name" ]; then
            continue
        fi

        # PARTUUID used in crypttab
        if [ "${dev%%=*}" = "PARTUUID" ]; then
            if [ "luks-${dev##PARTUUID=}" = "$luksname" ]; then
                luksname="$name"
                break
            fi

        # UUID used in crypttab
        elif [ "${dev%%=*}" = "UUID" ]; then
            if [ "luks-${dev##UUID=}" = "$luksname" ]; then
                luksname="$name"
                break
            fi

        # ID used in crypttab
        elif [ "${dev%%=*}" = "ID" ]; then
            if [ "luks-${dev##ID=}" = "$luksname" ]; then
                luksname="$name"
                break
            fi

        # path used in crypttab
        else
            cdev=$(readlink -f "$dev")
            mdev=$(readlink -f "$device")
            if [ "$cdev" = "$mdev" ]; then
                luksname="$name"
                break
            fi
        fi
    done < /etc/crypttab
    unset name dev
fi

# check if destination already exists
[ -b /dev/mapper/"$luksname" ] && exit 0

# we already asked for this device
asked_file=/tmp/cryptroot-asked-$luksname
[ -f "$asked_file" ] && exit 0

# load dm_crypt if it is not already loaded
[ -d /sys/module/dm_crypt ] || modprobe dm_crypt

command -v luks_open_interactive > /dev/null || . /lib/dracut-crypt-lib.sh

#
# Open LUKS device
#

info "luksOpen $device $luksname $luksfile $luksoptions"

OLD_IFS="$IFS"
IFS=,
# shellcheck disable=SC2086
set -- $luksoptions
IFS="$OLD_IFS"

while [ $# -gt 0 ]; do
    case $1 in
        noauto)
            # skip this
            exit 0
            ;;
        swap)
            # skip this
            exit 0
            ;;
        tmp)
            # skip this
            exit 0
            ;;
        allow-discards)
            allowdiscards="--allow-discards"
            ;;
        header=*)
            cryptsetupopts="${cryptsetupopts} --${1}"
            ;;
    esac
    shift
done

# parse for allow-discards
if strstr "$(cryptsetup --help)" "allow-discards"; then
    if discarduuids=$(getargs "rd.luks.allow-discards"); then
        discarduuids=$(str_replace "$discarduuids" 'luks-' '')
        if strstr " $discarduuids " " ${luksdev##luks-}"; then
            allowdiscards="--allow-discards"
        fi
    elif getargbool 0 rd.luks.allow-discards; then
        allowdiscards="--allow-discards"
    fi
fi

if strstr "$(cryptsetup --help)" "allow-discards"; then
    cryptsetupopts="$cryptsetupopts $allowdiscards"
fi

unset allowdiscards

# fallback to passphrase
ask_passphrase=1

if [ -n "$luksfile" ] && [ "$luksfile" != "none" ] && [ -e "$luksfile" ]; then
    # shellcheck disable=SC2086
    if readkey "$luksfile" / "$device" \
        | cryptsetup -d - $cryptsetupopts luksOpen "$device" "$luksname"; then
        ask_passphrase=0
    fi
elif [ "$is_keysource" -ne 0 ]; then
    info "Asking for passphrase because $device is a keysource."
else
    while [ -n "$(getarg rd.luks.key)" ]; do
        if tmp=$(getkey /tmp/luks.keys "$device"); then
            keydev="${tmp%%:*}"
            keypath="${tmp#*:}"
        else
            if [ "$numtries" -eq 0 ]; then
                warn "No key found for $device.  Fallback to passphrase mode."
                break
            fi
            sleep 1
            info "No key found for $device.  Will try $numtries time(s) more later."
            /sbin/initqueue --unique --onetime --settled \
                --name cryptroot-ask-"$luksname" \
                "$(command -v cryptroot-ask)" "$device" "$luksname" "$is_keysource" "$((numtries - 1))"
            exit 0
        fi
        unset tmp

        info "Using '$keypath' on '$keydev'"
        # shellcheck disable=SC2086
        readkey "$keypath" "$keydev" "$device" \
            | cryptsetup -d - $cryptsetupopts luksOpen "$device" "$luksname" \
            && ask_passphrase=0
        unset keypath keydev
        break
    done
fi

if [ $ask_passphrase -ne 0 ]; then
    luks_open_interactive "$device" "$luksname" "Password ($device)" "$cryptsetupopts"
fi

if [ "$is_keysource" -ne 0 ] && [ "${luksname##luks-}" != "$luksname" ]; then
    luks_close="$(command -v cryptsetup) close"
    {
        printf -- '[ -e /dev/mapper/%s ] && ' "$luksname"
        printf -- '%s "%s"\n' "$luks_close" "$luksname"
    } >> "$hookdir/cleanup/31-crypt-keysource.sh"
    unset luks_close
fi

unset device luksname luksfile

# mark device as asked
: >> "$asked_file"

udevsettle

exit 0
