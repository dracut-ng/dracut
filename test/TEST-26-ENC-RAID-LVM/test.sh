#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on LVM on encrypted partitions of a RAID"

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell rd.break" # udev.log-priority=debug
#DEBUGFAIL="rd.shell rd.udev.log-priority=debug loglevel=70 systemd.log_target=kmsg systemd.log_target=debug"
#DEBUGFAIL="rd.shell loglevel=70 systemd.log_target=kmsg systemd.log_target=debug"

test_check() {
    # cryptsetup needed for crypt module and mdadm for mdraid module
    require_binaries_for_test cryptsetup mdadm
}

test_run() {
    LUKSARGS=$(cat "$TESTDIR"/luks.txt)

    client_test_start "$LUKSARGS"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/disk-1.img disk1
    qemu_add_drive disk_args "$TESTDIR"/disk-2.img disk2

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE root=/dev/dracut/root ro rd.auto rootwait $LUKSARGS" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
    client_test_end

    client_test_start "Any LUKS"
    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE root=/dev/dracut/root rd.auto" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
    client_test_end

    return 0
}

make_test_rootfs() {
    # Create what will eventually be our root filesystem onto an overlay
    build_client_rootfs "$TESTDIR/overlay/source"

    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    call_dracut -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -a "bash crypt lvm mdraid" \
        -I "grep cryptsetup" \
        -i ./create-root.sh /usr/lib/dracut/hooks/initqueue/01-create-root.sh \
        -f "$TESTDIR"/initramfs.makeroot

    # Create the blank files to use as a root filesystem
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_args "$TESTDIR"/disk-1.img disk1 1
    qemu_add_drive disk_args "$TESTDIR"/disk-2.img disk2 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot quiet" \
        -initrd "$TESTDIR"/initramfs.makeroot
    test_marker_check dracut-root-block-created
    rm -rf "$TESTDIR"/overlay
}

test_setup() {
    make_test_rootfs

    cryptoUUIDS=$(grep -F -a -m 3 ID_FS_UUID "$TESTDIR"/marker.img)
    for uuid in $cryptoUUIDS; do
        eval "$uuid"
        printf ' rd.luks.uuid=luks-%s ' "$ID_FS_UUID"
    done > "$TESTDIR"/luks.txt

    i=1
    for uuid in $cryptoUUIDS; do
        eval "$uuid"
        printf 'luks-%s /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_disk%s /etc/key timeout=0\n' "$ID_FS_UUID" $i
        ((i += 1))
    done > /tmp/crypttab
    echo -n verySecurePassword > /tmp/key
    chmod 0600 /tmp/key

    test_dracut \
        -a "crypt lvm mdraid" \
        -i "/tmp/crypttab" "/etc/crypttab" \
        -i "/tmp/key" "/etc/key"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
