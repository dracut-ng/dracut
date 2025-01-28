#!/usr/bin/env bash

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem over multiple iSCSI with $USE_NETWORK"

#DEBUGFAIL="rd.shell rd.break rd.debug loglevel=7 "
#SERVER_DEBUG="rd.debug loglevel=7"
#SERIAL="tcp:127.0.0.1:9999"

run_server() {
    # Start server first
    echo "iSCSI TEST SETUP: Starting DHCP/iSCSI server"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "$ ls -alh $TESTDIR"
    ls -alh "$TESTDIR"
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/server.img serverroot 0 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/singleroot.img singleroot
    qemu_add_drive disk_index disk_args "$TESTDIR"/raid0-1.img raid0-1
    qemu_add_drive disk_index disk_args "$TESTDIR"/raid0-2.img raid0-2

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -serial "${SERIAL:-"file:$TESTDIR/server.log"}" \
        -net nic,macaddr=52:54:00:12:34:56,model=virtio \
        -net nic,macaddr=52:54:00:12:34:57,model=virtio \
        -net socket,listen=127.0.0.1:12331 \
        -append "panic=1 oops=panic softlockup_panic=1 systemd.crash_reboot root=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_serverroot rootfstype=ext4 rw console=ttyS0,115200n81 $SERVER_DEBUG" \
        -initrd "$TESTDIR"/initramfs.server \
        -pidfile "$TESTDIR"/server.pid -daemonize || return 1
    chmod 644 "$TESTDIR"/server.pid || return 1

    if ! [[ $SERIAL ]]; then
        wait_for_server_startup || return 1
    else
        echo Sleeping 10 seconds to give the server a head start
        sleep 10
    fi
}

run_client() {
    local test_name=$1
    shift
    echo "CLIENT TEST START: $test_name"

    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -net nic,macaddr=52:54:00:12:34:00,model=virtio \
        -net nic,macaddr=52:54:00:12:34:01,model=virtio \
        -net socket,connect=127.0.0.1:12331 \
        -append "$TEST_KERNEL_CMDLINE rw rd.auto $*" \
        -initrd "$TESTDIR"/initramfs.testing
    if ! test_marker_check iscsi-OK; then
        echo "CLIENT TEST END: $test_name [FAILED - BAD EXIT]"
        return 1
    fi

    echo "CLIENT TEST END: $test_name [OK]"
    return 0
}

do_test_run() {
    initiator=$(iscsi-iname)
    run_client "netroot=iscsi target1 target2" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101:::255.255.255.0::enp0s1:off" \
        "ip=192.168.51.101:::255.255.255.0::enp0s2:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.initiator=$initiator" \
        || return 1

    run_client "netroot=iscsi target1 target2 rd.iscsi.waitnet=0" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101:::255.255.255.0::enp0s1:off" \
        "ip=192.168.51.101:::255.255.255.0::enp0s2:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.firmware" \
        "rd.iscsi.initiator=$initiator" \
        "rd.iscsi.waitnet=0" \
        || return 1

    run_client "netroot=iscsi target1 target2 rd.iscsi.waitnet=0 rd.iscsi.testroute=0" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101:::255.255.255.0::enp0s1:off" \
        "ip=192.168.51.101:::255.255.255.0::enp0s2:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.firmware" \
        "rd.iscsi.initiator=$initiator" \
        "rd.iscsi.waitnet=0 rd.iscsi.testroute=0" \
        || return 1

    run_client "netroot=iscsi target1 target2 rd.iscsi.waitnet=0 rd.iscsi.testroute=0 default GW" \
        "root=LABEL=sysroot" \
        "ip=192.168.50.101::192.168.50.1:255.255.255.0::enp0s1:off" \
        "ip=192.168.51.101::192.168.51.1:255.255.255.0::enp0s2:off" \
        "netroot=iscsi:192.168.51.1::::iqn.2009-06.dracut:target1" \
        "netroot=iscsi:192.168.50.1::::iqn.2009-06.dracut:target2" \
        "rd.iscsi.firmware" \
        "rd.iscsi.initiator=$initiator" \
        "rd.iscsi.waitnet=0 rd.iscsi.testroute=0" \
        || return 1

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
    if [[ -s $TESTDIR/server.pid ]]; then
        kill -TERM "$(cat "$TESTDIR"/server.pid)"
        rm -f -- "$TESTDIR"/server.pid
    fi
    return $ret
}

test_check() {
    if ! type -p dhclient &> /dev/null; then
        echo "Test needs dhclient for server networking... Skipping"
        return 1
    fi

    if ! command -v tgtd &> /dev/null || ! command -v tgtadm &> /dev/null; then
        echo "Need tgtd and tgtadm from scsi-target-utils"
        return 1
    fi
    if ! [ -f /lib/systemd/system/iscsiuio.socket ]; then
        echo "Need iscsiuio.socket to run this test"
        return 1
    fi
}

test_setup() {
    # Create what will eventually be our root filesystem onto an overlay
    rm -rf -- "$TESTDIR"/overlay
    "$DRACUT" --keep --tmpdir "$TESTDIR" \
        --add-confdir test-root \
        -I "ip grep setsid" \
        --no-hostonly --no-hostonly-cmdline --nohardlink \
        -f "$TESTDIR"/initramfs.root "$KVERSION" || return 1
    mkdir -p "$TESTDIR"/overlay/source && mv "$TESTDIR"/dracut.*/initramfs/* "$TESTDIR"/overlay/source && rm -rf "$TESTDIR"/dracut.*
    mkdir -p -- "$TESTDIR"/overlay/source/var/lib/nfs/rpc_pipefs
    cp ./client-init.sh "$TESTDIR"/overlay/source/sbin/init

    # second, install the files needed to make the root filesystem
    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    "$DRACUT" -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -a "crypt lvm mdraid" \
        -I "setsid blockdev" \
        -i ./create-client-root.sh /lib/dracut/hooks/initqueue/01-create-client-root.sh \
        --no-hostonly-cmdline -N \
        -f "$TESTDIR"/initramfs.makeroot "$KVERSION" || return 1
    rm -rf -- "$TESTDIR"/overlay

    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/singleroot.img singleroot 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/raid0-1.img raid0-1 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/raid0-2.img raid0-2 1

    # Invoke KVM and/or QEMU to actually create the target filesystem.
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot rw rootfstype=ext4 quiet console=ttyS0,115200n81" \
        -initrd "$TESTDIR"/initramfs.makeroot || return 1
    test_marker_check dracut-root-block-created || return 1
    rm -- "$TESTDIR"/marker.img

    rm -rf -- "$TESTDIR"/overlay
    "$DRACUT" -N --keep --tmpdir "$TESTDIR" \
        --add-confdir test-root \
        -a "network-legacy iscsi" \
        -d "iscsi_tcp crc32c ipv6 af_packet" \
        -I "ip grep sleep setsid chmod modprobe pidof tgtd tgtadm" \
        --install-optional "/etc/netconfig dhcpd /etc/group /etc/nsswitch.conf /etc/rpc /etc/protocols /etc/services /usr/etc/nsswitch.conf /usr/etc/rpc /usr/etc/protocols /usr/etc/services" \
        -i /tmp/config /etc/nbd-server/config \
        -i "./dhcpd.conf" "/etc/dhcpd.conf" \
        -f "$TESTDIR"/initramfs.root "$KVERSION" || return 1
    mkdir -p "$TESTDIR"/overlay/source && mv "$TESTDIR"/dracut.*/initramfs/* "$TESTDIR"/overlay/source && rm -rf "$TESTDIR"/dracut.*

    mkdir -p -- "$TESTDIR"/overlay/source/var/lib/dhcpd "$TESTDIR"/overlay/source/etc/iscsi
    cp ./server-init.sh "$TESTDIR"/overlay/source/sbin/init

    # second, install the files needed to make the root filesystem
    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    "$DRACUT" -N -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -i ./create-server-root.sh /lib/dracut/hooks/initqueue/01-create-server-root.sh \
        -f "$TESTDIR"/initramfs.makeroot "$KVERSION" || return 1
    rm -rf -- "$TESTDIR"/overlay

    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/server.img root 1

    # Invoke KVM and/or QEMU to actually create the target filesystem.
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/dracut/root rw rootfstype=ext4 quiet console=ttyS0,115200n81" \
        -initrd "$TESTDIR"/initramfs.makeroot || return 1
    test_marker_check dracut-root-block-created || return 1
    rm -- "$TESTDIR"/marker.img

    # Make client's dracut image
    test_dracut \
        --no-hostonly --no-hostonly-cmdline \
        --add "$USE_NETWORK" \
        -i "./client.link" "/etc/systemd/network/01-client.link"

    # Make server's dracut image
    "$DRACUT" -i "$TESTDIR"/overlay / \
        -a "test rootfs-block kernel-modules network-legacy ${SERVER_DEBUG:+debug}" \
        -d "af_packet piix ide-gd_mod ata_piix ext4 sd_mod drbg virtio_net" \
        -i "./server.link" "/etc/systemd/network/01-server.link" \
        -i "./wait-if-server.sh" "/lib/dracut/hooks/pre-mount/99-wait-if-server.sh" \
        --no-hostonly-cmdline -N \
        -f "$TESTDIR"/initramfs.server "$KVERSION" || return 1
}

test_cleanup() {
    if [[ -s $TESTDIR/server.pid ]]; then
        kill -TERM "$(cat "$TESTDIR"/server.pid)"
        rm -f -- "$TESTDIR"/server.pid
    fi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
