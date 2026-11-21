#!/usr/bin/env bash
set -eu

[ -z "${USE_NETWORK-}" ] && USE_NETWORK="network"

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem over multiple iSCSI with $USE_NETWORK"

#DEBUGFAIL="rd.shell rd.break rd.debug loglevel=7 "
#SERVER_DEBUG="rd.debug loglevel=7"
#SERIAL="tcp:127.0.0.1:9999"

run_server() {
    # Start server first
    echo "iSCSI TEST SETUP: Starting DHCP/iSCSI server"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/server.img serverroot 0 1
    qemu_add_drive disk_args "$TESTDIR"/singleroot.img singleroot
    qemu_add_drive disk_args "$TESTDIR"/raid0-1.img raid0-1
    qemu_add_drive disk_args "$TESTDIR"/raid0-2.img raid0-2

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -serial "${SERIAL:-"file:./server${TEST_RUN_ID:+-$TEST_RUN_ID}.log"}" \
        -device virtio-net-pci,netdev=lan0,mac=52:54:00:12:34:56 \
        -netdev dgram,id=lan0,local.type=inet,local.host=localhost,local.port=60710,remote.type=inet,remote.host=localhost,remote.port=60711 \
        -device virtio-net-pci,netdev=lan1,mac=52:54:00:12:34:57 \
        -netdev dgram,id=lan1,local.type=inet,local.host=localhost,local.port=60712,remote.type=inet,remote.host=localhost,remote.port=60713 \
        -append "panic=1 oops=panic softlockup_panic=1 systemd.crash_reboot root=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_serverroot rootfstype=ext4 rw systemd.journald.forward_to_console=1 ${SERVER_DEBUG-}" \
        -pidfile "$TESTDIR"/server.pid -daemonize \
        -initrd "$TESTDIR"/initramfs.server
    chmod 644 "$TESTDIR"/server.pid

    if ! [[ ${SERIAL-} ]]; then
        wait_for_server_startup "./server${TEST_RUN_ID:+-$TEST_RUN_ID}.log"
    else
        echo Sleeping 10 seconds to give the server a head start
        sleep 10
    fi
}

run_client() {
    local test_name=$1
    shift
    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -device virtio-net-pci,netdev=lan0,mac=52:54:00:12:34:00 \
        -netdev dgram,id=lan0,local.type=inet,local.host=localhost,local.port=60711,remote.type=inet,remote.host=localhost,remote.port=60710 \
        -device virtio-net-pci,netdev=lan1,mac=52:54:00:12:34:01 \
        -netdev dgram,id=lan1,local.type=inet,local.host=localhost,local.port=60713,remote.type=inet,remote.host=localhost,remote.port=60712 \
        -append "$TEST_KERNEL_CMDLINE rw rd.auto $*" \
        -initrd "$TESTDIR"/initramfs.testing
    if ! test_marker_check iscsi-OK; then
        client_test_end "FAILED - BAD EXIT"
        return 1
    fi

    client_test_end
    return 0
}

do_test_run() {
    initiator=$(iscsi-iname)
    run_client "netroot=iscsi target1 target2" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101:::255.255.255.0::lan0:off" \
        "ip=192.168.51.101:::255.255.255.0::lan1:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.initiator=$initiator"

    run_client "netroot=iscsi target1 target2 rd.iscsi.waitnet=0" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101:::255.255.255.0::lan0:off" \
        "ip=192.168.51.101:::255.255.255.0::lan1:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.firmware" \
        "rd.iscsi.initiator=$initiator" \
        "rd.iscsi.waitnet=0"

    run_client "netroot=iscsi target1 target2 rd.iscsi.waitnet=0 rd.iscsi.testroute=0" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101:::255.255.255.0::lan0:off" \
        "ip=192.168.51.101:::255.255.255.0::lan1:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.firmware" \
        "rd.iscsi.initiator=$initiator" \
        "rd.iscsi.waitnet=0 rd.iscsi.testroute=0"

    run_client "netroot=iscsi target1 target2 rd.iscsi.waitnet=0 rd.iscsi.testroute=0 default GW" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101::192.168.50.1:255.255.255.0::lan0:off" \
        "ip=192.168.51.101::192.168.51.1:255.255.255.0::lan1:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.firmware" \
        "rd.iscsi.initiator=$initiator" \
        "rd.iscsi.waitnet=0 rd.iscsi.testroute=0"

    echo "All tests passed [OK]"
    return 0
}

test_run() {
    if ! run_server; then
        echo "Failed to start server" 1>&2
        return 1
    fi
    do_test_run
    ret=$?
    stop_server
    return $ret
}

test_check() {
    require_binaries_for_test tgtadm tgtd
}

make_client_rootfs() {
    rm -rf -- "$TESTDIR"/overlay
    build_client_rootfs "$TESTDIR/overlay/source"
    inst_multiple ip grep setsid
    mkdir -p -- "$TESTDIR"/overlay/source/var/lib/nfs/rpc_pipefs
    inst_init ./client-init.sh "$TESTDIR"/overlay/source

    build_ext4_image "$TESTDIR/overlay/source" "$TESTDIR"/singleroot.img singleroot

    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    call_dracut -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -a "crypt lvm mdraid" \
        -I "setsid blockdev" \
        -i ./create-client-root.sh /usr/lib/dracut/hooks/initqueue/01-create-client-root.sh \
        -f "$TESTDIR"/initramfs.makeroot
    rm -rf -- "$TESTDIR"/overlay

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_args "$TESTDIR"/raid0-1.img raid0-1 1
    qemu_add_drive disk_args "$TESTDIR"/raid0-2.img raid0-2 1

    # Invoke KVM and/or QEMU to actually create the target filesystem.
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot rw rootfstype=ext4 quiet" \
        -initrd "$TESTDIR"/initramfs.makeroot
    test_marker_check dracut-root-block-created
    rm -- "$TESTDIR"/marker.img
}

make_server_rootfs() {
    build_rootfs_base "$TESTDIR"/server-rootfs

    binaries=$(sed -n "s/^# required binaries: \(.*\)/\1/p" ./server-init.sh)
    # shellcheck disable=SC2086
    inst_multiple $binaries
    inst_script ./server-init.sh /sbin/init

    inst ./dnsmasq.conf /etc/dnsmasq.conf
    echo "root:x:0:0:root:/root:/bin/sh" > "$initdir/etc/passwd"
    echo "root:x:0:" > "$initdir/etc/group"

    build_ext4_image "$TESTDIR/server-rootfs" "$TESTDIR"/server.img dracut
    rm -rf "$TESTDIR"/server-rootfs
}

test_setup() {
    make_client_rootfs
    make_server_rootfs

    # Make client's dracut image
    test_dracut \
        --no-hostonly \
        --add "watchdog $USE_NETWORK" \
        -i ./client-persistent-lan0.link /etc/systemd/network/01-persistent-lan0.link \
        -i ./client-persistent-lan1.link /etc/systemd/network/01-persistent-lan1.link

    # Make server's dracut image
    call_dracut \
        --add-confdir test \
        -a "$USE_NETWORK ${SERVER_DEBUG:+debug}" \
        -i "./server.link" "/etc/systemd/network/01-server.link" \
        -i "./wait-if-server.sh" "/usr/lib/dracut/hooks/pre-mount/99-wait-if-server.sh" \
        -N \
        -f "$TESTDIR"/initramfs.server
}

test_cleanup() {
    stop_server
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
