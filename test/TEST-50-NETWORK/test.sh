#!/usr/bin/env bash
set -e

[ -z "${USE_NETWORK-}" ] && USE_NETWORK="network"

# shellcheck disable=SC2034
TEST_DESCRIPTION="bring up network without netroot set with $USE_NETWORK"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu \
        -device "virtio-net-pci,netdev=lan0" \
        -netdev "user,id=lan0,net=10.0.2.0/24,dhcpstart=10.0.2.15" \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE rd.neednet=1" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
}

test_setup() {
    # create root filesystem
    build_client_rootfs "$TESTDIR/rootfs" ./assertion.sh
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    test_dracut --add-drivers "virtio_net" --add "qemu-net $USE_NETWORK"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
