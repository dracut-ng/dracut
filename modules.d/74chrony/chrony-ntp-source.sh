#!/bin/sh

command -v getargbool > /dev/null || . /lib/dracut-lib.sh

if getargbool 0 rd.ntp.nodhcp; then
    info "rd.ntp.nodhcp=1: not adding NTP sources from DHCP."
    return 0
fi

_ifname=$1
[ -n "$_ifname" ] || return 0

_dhcpopts_file="/tmp/dhclient.$_ifname.dhcpopts"
[ -s "$_dhcpopts_file" ] || return 0

(
    # shellcheck disable=SC1090
    . "$_dhcpopts_file"
    [ -n "$new_ntp_servers" ] || [ -n "$new_dhcp6_ntp_servers" ] || return 0

    info "Adding NTP sources from DHCP ($_ifname)."

    [ -d /run/chrony-dhcp ] || mkdir -p /run/chrony-dhcp
    for _srv in $new_ntp_servers $new_dhcp6_ntp_servers; do
        echo "server $_srv iburst" >> "/run/chrony-dhcp/$_ifname.sources"
    done

    chronyc reload sources > /dev/null 2>&1 \
        || warn "chronyc failed to reload NTP sources"
)

unset _ifname _dhcpopts_file
