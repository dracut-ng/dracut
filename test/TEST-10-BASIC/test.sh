#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on ext4 filesystem"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu -nic none \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
}

test_setup() {
    build_client_rootfs "$TESTDIR/rootfs"
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    # Busybox is tested in a separate test case
    test_dracut --omit busybox
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
