#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on a btrfs filesystem with /usr subvolume"

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell rd.break"

test_check() {
    require_binaries_for_test mkfs.btrfs
}

client_run() {
    local test_name="$1"
    shift
    local client_opts="$*"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.btrfs root

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE $client_opts" \
        -initrd "$TESTDIR"/initramfs.testing

    if ! test_marker_check; then
        client_test_end "FAILED"
        return 1
    fi

    client_test_end
}

test_run() {
    client_run "no option specified"
    client_run "readonly root and writeable /usr" "ro"
    client_run "writeable root and /usr" "rw"
    client_run "readonly root and /usr" "ro rd.fstab=0"
    client_run "readonly root snapshot" "rd.fstab=0 subvol=snapshot-root"
}

make_test_rootfs() {
    # Create what will eventually be our root filesystem onto an overlay
    build_client_rootfs "$TESTDIR/overlay/source"
    echo "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root /usr btrfs subvol=usr,rw 0 2" \
        >> "$TESTDIR/overlay/source/etc/fstab"

    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    call_dracut -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -I "mkfs.btrfs" \
        -i ./create-root.sh /usr/lib/dracut/hooks/initqueue/01-create-root.sh \
        -f "$TESTDIR"/initramfs.makeroot

    # Create the blank file to use as a root filesystem
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_args "$TESTDIR"/root.btrfs root 1

    # Invoke KVM and/or QEMU to actually create the target filesystem.
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/dracut/root quiet" \
        -initrd "$TESTDIR"/initramfs.makeroot
    rm -rf "$TESTDIR"/overlay

    if ! test_marker_check dracut-root-block-created; then
        echo "Could not create root filesystem"
        return 1
    fi
}

test_setup() {
    make_test_rootfs
    test_dracut \
        --add-drivers "btrfs"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
