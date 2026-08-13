#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on a ext4 filesystem with systemd but without dracut-systemd and shell"

test_check() {
    command -v systemctl &> /dev/null
}

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell=1 rd.break=pre-mount"
client_run() {
    local test_name="$1"
    shift
    local client_opts="$*"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut systemd.default_device_timeout_sec=0 $TEST_KERNEL_CMDLINE $client_opts" \
        -initrd "$TESTDIR"/initramfs.testing

    if ! test_marker_check; then
        client_test_end "FAILED"
        return 1
    fi

    client_test_end
}

test_run() {
    client_run "readonly root" "ro"
    client_run "writeable root" "rw"
}

test_setup() {
    build_client_rootfs "$TESTDIR/rootfs"
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    # initrd for required kernel modules
    # Improve boot time by generating two initrds. Do not re-compress kernel modules
    call_dracut \
        --no-compress \
        --kernel-only \
        -m "kernel-modules qemu" \
        -d "ext4 sd_mod" \
        -f "$TESTDIR"/initramfs-test

    # vanilla kernel-independent systemd-based minimal initrd without dracut specific customizations
    # since dracut-systemd is not included in the generated initrd, only systemd options are supported during boot
    test_dracut --keep --no-kernel \
        --omit "test" \
        -m "systemd-initrd" \
        "$TESTDIR"/initramfs-systemd-initrd

    (
        # remove the shell itself from the generated initramfs to demonstrate a shell-less optimized boot
        cd "$TESTDIR"/initrd/dracut.*/initramfs
        rm -f "$(realpath bin/sh)"
        rm -f bin/sh

        # verify that dracut-lib.sh is not included to confirm that shell scripts could not execute
        if [ -e "lib/dracut-lib.sh" ]; then
            echo "unexpectedly dracut-lib.sh is found in the generated initramfs"
            return 1
        fi

        # verify that dracut systemd services are not included
        cd usr/lib/systemd/system/
        for f in dracut*.service; do
            if [ -e "$f" ]; then
                echo "unexpected dracut service found: $f"
                return 1
            fi
        done
    )

    # combine systemd-based initrd with the test infra initrd
    cat "$TESTDIR"/initramfs-test "$TESTDIR"/initramfs-systemd-initrd > "$TESTDIR"/initramfs.testing
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
