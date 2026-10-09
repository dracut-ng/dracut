#!/bin/sh
set -eu

# required binaries: dnsmasq ip mount pidof poweroff sleep

export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# shellcheck disable=SC2317,SC2329  # called via EXIT trap
_poweroff() {
    local exit_code="$?"

    set +x
    [ "$exit_code" -eq 0 ] || echo "Error: $0 failed with exit code $exit_code."
    echo "Powering down."

    poweroff -f
}

trap _poweroff EXIT

exec < /dev/console > /dev/console 2>&1
set -x
export TERM=linux
export PS1='legacy-server:\w\$ '
echo "made it to the network-legacy DHCP server rootfs!"
echo server > /proc/sys/kernel/hostname

wait_for_if_link() {
    local cnt=0
    local li
    while [ $cnt -lt 600 ]; do
        li=$(ip -o link show dev "$1" 2> /dev/null)
        [ -n "$li" ] && return 0
        sleep 0.1
        cnt=$((cnt + 1))
    done
    return 1
}

# configure <iface> <ipv4/prefix> <ipv6/prefix>
configure() {
    wait_for_if_link "$1"
    ip link set "$1" up
    ip addr add "$2" dev "$1"
    ip -6 addr add "$3" dev "$1" nodad
}

# configure_v6 <iface> <ipv6/prefix>
configure_v6() {
    wait_for_if_link "$1"
    ip link set "$1" up
    ip -6 addr add "$2" dev "$1" nodad
}

# Static addresses matching the dnsmasq pools below, one link per client NIC.
# The first three are DHCPv4 + stateful DHCPv6 links; the last two are RA/SLAAC
# only.
configure enx525400123456 192.168.51.1/24 2001:db8:51::1/64
configure enx525400123457 192.168.52.1/24 2001:db8:52::1/64
configure enx525400123458 192.168.53.1/24 2001:db8:53::1/64
configure_v6 enx525400123459 2001:db8:54::1/64
configure_v6 enx52540012345a 2001:db8:55::1/64

dnsmasq
echo "Serving DHCP"
while pidof dnsmasq; do
    echo > /dev/watchdog
    sleep 1
done

mount -n -o remount,ro /
