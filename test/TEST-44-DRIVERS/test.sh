#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="no (xfs) driver on root filesystem"

test_check() {
    if ! type -p mkfs.xfs &> /dev/null; then
        echo "Test needs mkfs.xfs.. Skipping"
        return 1
    fi

    if ! command -v systemctl > /dev/null; then
        echo "This test needs systemd to run."
        return 1
    fi
}

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell=1 rd.break=pre-mount"
test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root
    qemu_add_drive disk_args "$TESTDIR"/mnt.img mnt

    # This test should fail if rd.driver.export is not passed at kernel command-line
    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE rd.driver.export" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
}

test_setup() {
    # Create client root filesystem
    call_dracut --tmpdir "$TESTDIR" \
        --no-kernel \
        --add "systemd-udevd systemd-journald systemd-tmpfiles systemd-ldconfig systemd-ask-password shutdown" \
        --mount "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_mnt /mnt xfs rw" \
        --add-confdir test-root \
        -f "$TESTDIR"/initramfs.root
    mkdir -p "$TESTDIR"/rootfs
    mv "$TESTDIR"/dracut.*/initramfs/* "$TESTDIR"/rootfs
    rm -rf "$TESTDIR"/dracut.*

    # make sure no linux kernel driver is included in the rootfs
    rm -rf "$TESTDIR"/rootfs/lib/modules/*

    # make sure /lib/modules directory exists inside the rootfs
    mkdir -p "$TESTDIR"/rootfs/lib/modules "$TESTDIR"/rootfs/mnt

    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut
    rm -rf "$TESTDIR"/rootfs

    rm -f "$TESTDIR/mnt.img"
    truncate -s 512M "$TESTDIR/mnt.img"
    mkfs.xfs -q "$TESTDIR/mnt.img"

    test_dracut \
        --add-drivers xfs \
        --add kernel-modules-export
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
