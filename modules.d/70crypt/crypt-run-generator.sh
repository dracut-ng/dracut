#!/bin/sh

command -v getargs > /dev/null || . /lib/dracut-lib.sh
command -v crypttab_contains > /dev/null || . /lib/dracut-crypt-lib.sh

dev=$1
luks=$2

crypttab_contains "$luks" "$dev" && exit 0

allowdiscards="-"

# parse for allow-discards
if [ -n "${DRACUT_SYSTEMD-}" ] || strstr "$(cryptsetup --help)" "allow-discards"; then
    if discarduuids=$(getargs "rd.luks.allow-discards"); then
        discarduuids=$(str_replace "$discarduuids" 'luks-' '')
        if strstr " $discarduuids " " ${luks##luks-}"; then
            allowdiscards="discard"
        fi
    elif getargbool 0 rd.luks.allow-discards; then
        allowdiscards="discard"
    fi
fi

_tries=$(get_luks_option tries)
_tries=${_tries:-0}

echo "$luks $dev - timeout=0,tries=$_tries,$allowdiscards" >> /etc/crypttab

if command -v systemctl > /dev/null; then
    systemctl daemon-reload
    systemctl start cryptsetup.target
fi
exit 0
