#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="live root provided over network"

# Uncomment these to debug failures
#DEBUGFAIL="rd.shell rd.debug rd.live.debug loglevel=7"

test_check() {
    # python3 needed for HTTP server
    require_binaries_for_test mksquashfs python3
}

client_run() {
    local test_name="$1"
    local append="$2"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -device "virtio-net-pci,netdev=lan0" \
        -netdev "user,id=lan0,net=10.0.2.0/24,dhcpstart=10.0.2.15" \
        -append "$append $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR/initramfs.testing"
    test_marker_check
    client_test_end
}

test_run() {
    port=$(start_webserver)

    client_run "root=live:http://server/root.squashfs" "root=live:http://10.0.2.2:$port/root.squashfs"
    client_run "root=http://server/root.squashfs" "root=http://10.0.2.2:$port/root.squashfs"
}

test_setup() {
    build_client_rootfs "$TESTDIR/rootfs"
    mksquashfs "$TESTDIR/rootfs" "$TESTDIR/root.squashfs" -quiet -no-progress

    test_dracut -a "livenet" --no-hostonly
}

test_cleanup() {
    stop_webserver
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
