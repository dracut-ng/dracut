#!/bin/bash
set -eu

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
export PS1='nfstest-server:\w\$ '
: > /dev/watchdog
echo "made it to the NFS server rootfs!"
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

wait_for_if_up() {
    local cnt=0
    local li
    while [ $cnt -lt 200 ]; do
        li=$(ip -o link show up dev "$1")
        [ -n "$li" ] && return 0
        sleep 0.1
        cnt=$((cnt + 1))
    done
    return 1
}

wait_for_route_ok() {
    local cnt=0
    while [ $cnt -lt 200 ]; do
        li=$(ip route show)
        [ -n "$li" ] && [ -z "${li##*"$1"*}" ] && return 0
        sleep 0.1
        cnt=$((cnt + 1))
    done
    return 1
}

linkup() {
    wait_for_if_link "$1" 2> /dev/null && ip link set "$1" up 2> /dev/null && wait_for_if_up "$1" 2> /dev/null
}

wait_for_if_link enx525400123456

ip addr add 192.168.50.1/24 dev enx525400123456
ip addr add 192.168.50.2/24 dev enx525400123456
ip addr add 192.168.50.3/24 dev enx525400123456
linkup enx525400123456

: > /dev/watchdog
mkdir /nfs/nfs3-4
mount --bind /nfs/client /nfs/nfs3-4
: > /dev/watchdog
mkdir -p /nfs/ip/192.168.50.101
mount --bind /nfs/client /nfs/ip/192.168.50.101
: > /dev/watchdog
mkdir -p /nfs/tftpboot/nfs4-4
mount --bind /nfs/client /nfs/tftpboot/nfs4-4
: > /dev/watchdog
modprobe sunrpc
: > /dev/watchdog
mount -t rpc_pipefs sunrpc /var/lib/nfs/rpc_pipefs
: > /dev/watchdog
[ -x /sbin/portmap ] && portmap
: > /dev/watchdog
mkdir -p /run/rpcbind
[ -x /sbin/rpcbind ] && rpcbind
: > /dev/watchdog
modprobe nfsd
: > /dev/watchdog
mount -t nfsd nfsd /proc/fs/nfsd
: > /dev/watchdog
exportfs -r
: > /dev/watchdog
nfsdcld
: > /dev/watchdog
rpc.nfsd
: > /dev/watchdog
rpc.mountd
: > /dev/watchdog
command -v rpc.idmapd > /dev/null && [ -z "$(pidof rpc.idmapd)" ] && rpc.idmapd
: > /dev/watchdog
exportfs -r
: > /dev/watchdog
dnsmasq
: > /dev/watchdog
exportfs -s
# tcpdump is a workaround for https://github.com/dracut-ng/dracut/issues/2283
tcpdump -Z root -i enx525400123456 -n port 67 or port 68 &
echo "Serving NFS mounts"
while :; do
    [ -n "$(jobs -rp)" ] && : > /dev/watchdog
    sleep 10
done
mount -n -o remount,ro /
