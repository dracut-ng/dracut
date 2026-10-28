#!/usr/bin/env bash
set -eu

[ -z "${USE_NETWORK-}" ] && USE_NETWORK="network"

# shellcheck disable=SC2034
TEST_DESCRIPTION="network-legacy ip= autoconf variations (dhcp, dhcp6, any, auto6, either6) against real DHCP servers"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"
#SERVER_DEBUG="rd.debug loglevel=7"
#SERIAL="tcp:127.0.0.1:9999"

# The client is given several NICs, each on its own point-to-point link to a NIC
# on a dnsmasq server VM. The DHCP links serve both DHCPv4 and (stateful)
# DHCPv6; the autoconf links serve only RA/SLAAC. Each NIC uses a different ip=
# autoconf mode, so a single boot exercises several variations. Because every
# DHCP link has a working DHCPv6 server, this both proves the per-protocol
# pid/lease separation and makes the test sensitive: a 4<->6 mix-up still brings
# the interface up with the wrong address family, which the assertion catches.
#
#   netdhcp    ip=dhcp    -> IPv4 only            (link 192.168.51.0/24 2001:db8:51::/64)
#   netdhcp6   ip=dhcp6   -> DHCPv6 IPv6 only      (link 192.168.52.0/24 2001:db8:52::/64)
#   netany     ip=any     -> IPv4 + DHCPv6 + SLAAC (link 192.168.53.0/24 2001:db8:53::/64)
#   netauto6   ip=auto6   -> SLAAC IPv6 only       (link 2001:db8:54::/64, RA only)
#   neteither6 ip=either6 -> SLAAC IPv6 only       (link 2001:db8:55::/64, RA only)
CLIENT_MAC_DHCP="52:54:00:00:51:00"
CLIENT_MAC_DHCP6="52:54:00:00:51:01"
CLIENT_MAC_ANY="52:54:00:00:51:02"
CLIENT_MAC_AUTO6="52:54:00:00:51:03"
CLIENT_MAC_EITHER6="52:54:00:00:51:04"

SERVER_MAC0="52:54:00:12:34:56"
SERVER_MAC1="52:54:00:12:34:57"
SERVER_MAC2="52:54:00:12:34:58"
SERVER_MAC3="52:54:00:12:34:59"
SERVER_MAC4="52:54:00:12:34:5a"

test_check() {
    if ! "$DRACUT" --list-modules 2> /dev/null | grep -qx network-legacy; then
        echo "dracut module 'network-legacy' not available; configure with --enable-network-legacy... Skipping"
        return 1
    fi

    if ! command -v dhclient &> /dev/null; then
        echo "dhclient not available, needed by network-legacy... Skipping"
        return 1
    fi

    if ! command -v dnsmasq &> /dev/null; then
        echo "dnsmasq not available, needed by the DHCP test server... Skipping"
        return 1
    fi
}

run_server() {
    echo "Starting DHCPv4/DHCPv6 server"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/server.img serverroot

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -serial "${SERIAL:-"file:./server${TEST_RUN_ID:+-$TEST_RUN_ID}.log"}" \
        -device "virtio-net-pci,netdev=lan0,mac=$SERVER_MAC0" \
        -netdev "dgram,id=lan0,local.type=inet,local.host=localhost,local.port=60510,remote.type=inet,remote.host=localhost,remote.port=60511" \
        -device "virtio-net-pci,netdev=lan1,mac=$SERVER_MAC1" \
        -netdev "dgram,id=lan1,local.type=inet,local.host=localhost,local.port=60512,remote.type=inet,remote.host=localhost,remote.port=60513" \
        -device "virtio-net-pci,netdev=lan2,mac=$SERVER_MAC2" \
        -netdev "dgram,id=lan2,local.type=inet,local.host=localhost,local.port=60514,remote.type=inet,remote.host=localhost,remote.port=60515" \
        -device "virtio-net-pci,netdev=lan3,mac=$SERVER_MAC3" \
        -netdev "dgram,id=lan3,local.type=inet,local.host=localhost,local.port=60516,remote.type=inet,remote.host=localhost,remote.port=60517" \
        -device "virtio-net-pci,netdev=lan4,mac=$SERVER_MAC4" \
        -netdev "dgram,id=lan4,local.type=inet,local.host=localhost,local.port=60518,remote.type=inet,remote.host=localhost,remote.port=60519" \
        -append "panic=1 oops=panic softlockup_panic=1 systemd.crash_reboot quiet root=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_serverroot rootfstype=ext4 rw systemd.journald.forward_to_console=1 ${SERVER_DEBUG-}" \
        -pidfile "$TESTDIR"/server.pid -daemonize \
        -initrd "$TESTDIR"/initramfs.server
    chmod 644 "$TESTDIR"/server.pid

    # The server prints "Serving" once dnsmasq is up.
    if ! [[ ${SERIAL-} ]]; then
        wait_for_server_startup "./server${TEST_RUN_ID:+-$TEST_RUN_ID}.log"
    else
        echo "Sleeping 10 seconds to give the server a head start"
        sleep 10
    fi
}

test_run() {
    if ! run_server; then
        echo "Failed to start server" 1>&2
        return 1
    fi

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    local cmdline="rd.neednet=1 bootdev=netdhcp"
    cmdline+=" ifname=netdhcp:$CLIENT_MAC_DHCP"
    cmdline+=" ifname=netdhcp6:$CLIENT_MAC_DHCP6"
    cmdline+=" ifname=netany:$CLIENT_MAC_ANY"
    cmdline+=" ifname=netauto6:$CLIENT_MAC_AUTO6"
    cmdline+=" ifname=neteither6:$CLIENT_MAC_EITHER6"
    cmdline+=" ip=netdhcp:dhcp ip=netdhcp6:dhcp6 ip=netany:any"
    cmdline+=" ip=netauto6:auto6 ip=neteither6:either6"

    test_marker_reset
    "$testdir"/run-qemu \
        -device "virtio-net-pci,netdev=lan0,mac=$CLIENT_MAC_DHCP" \
        -netdev "dgram,id=lan0,local.type=inet,local.host=localhost,local.port=60511,remote.type=inet,remote.host=localhost,remote.port=60510" \
        -device "virtio-net-pci,netdev=lan1,mac=$CLIENT_MAC_DHCP6" \
        -netdev "dgram,id=lan1,local.type=inet,local.host=localhost,local.port=60513,remote.type=inet,remote.host=localhost,remote.port=60512" \
        -device "virtio-net-pci,netdev=lan2,mac=$CLIENT_MAC_ANY" \
        -netdev "dgram,id=lan2,local.type=inet,local.host=localhost,local.port=60515,remote.type=inet,remote.host=localhost,remote.port=60514" \
        -device "virtio-net-pci,netdev=lan3,mac=$CLIENT_MAC_AUTO6" \
        -netdev "dgram,id=lan3,local.type=inet,local.host=localhost,local.port=60517,remote.type=inet,remote.host=localhost,remote.port=60516" \
        -device "virtio-net-pci,netdev=lan4,mac=$CLIENT_MAC_EITHER6" \
        -netdev "dgram,id=lan4,local.type=inet,local.host=localhost,local.port=60519,remote.type=inet,remote.host=localhost,remote.port=60518" \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE $cmdline" \
        -initrd "$TESTDIR"/initramfs.testing

    local ret=0
    test_marker_check || ret=$?
    kill_server
    return "$ret"
}

make_server_rootfs() {
    rm -fr "$TESTDIR"/server-rootfs
    build_rootfs_base "$TESTDIR"/server-rootfs

    binaries=$(sed -n "s/^# required binaries: \(.*\)/\1/p" ./server-init.sh)
    # shellcheck disable=SC2086
    inst_multiple $binaries
    inst_script ./server-init.sh /sbin/init
    inst ./dnsmasq.conf /etc/dnsmasq.conf
    echo "root:x:0:0:root:/root:/bin/sh" > "$initdir/etc/passwd"
    echo "root:x:0:" > "$initdir/etc/group"

    build_ext4_image "$TESTDIR/server-rootfs" "$TESTDIR"/server.img dracut
    rm -fr "$TESTDIR"/server-rootfs
}

test_setup() {
    # client root filesystem, with the dual-stack assertion baked in
    build_client_rootfs "$TESTDIR/rootfs" ./assertion.sh
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    # server root filesystem, running dnsmasq as a DHCPv4/DHCPv6 server
    make_server_rootfs

    # client initramfs: force network-legacy so the 'network' meta-module does
    # not pick NetworkManager/networkd instead.
    test_dracut --add-drivers "virtio_net" --add "qemu-net network network-legacy"

    # server initramfs: only needs to rename the NICs (via server.link) and boot
    # the server root; the network itself is configured by server-init.sh.
    call_dracut -N \
        --add-confdir test \
        -a "$USE_NETWORK ${SERVER_DEBUG:+debug}" \
        -i "./server.link" "/etc/systemd/network/01-server.link" \
        -i "./wait-if-server.sh" "/usr/lib/dracut/hooks/pre-mount/99-wait-if-server.sh" \
        -f "$TESTDIR"/initramfs.server
}

kill_server() {
    if [[ -s $TESTDIR/server.pid ]]; then
        kill -TERM "$(cat "$TESTDIR"/server.pid)"
        rm -f -- "$TESTDIR"/server.pid
    fi
}

test_cleanup() {
    kill_server
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
