#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="initramfs created from sysroot"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    "$testdir"/run-qemu -nic none \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR"/initramfs.testing
    check_qemu_log
}

test_setup() {
    # create root filesystem
    build_client_rootfs "$TESTDIR/rootfs"
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    ln -s / "$TESTDIR"/sysroot
    # test DRACUT_EXTRA_ARGS
    DRACUT_EXTRA_ARGS="--keep --hostonly --sysroot '$TESTDIR/sysroot'" test_dracut

    grep 'hostonly' "$TESTDIR"/initrd/dracut.*/initramfs/lib/dracut/build-parameter.txt

    if grep -q '^root:' /etc/shadow; then
        if ! grep -q '^root:' "$TESTDIR"/initrd/dracut.*/initramfs/etc/shadow; then
            echo "Entry for root in /etc/shadow is missing, failing the test."
            rm "$TESTDIR"/initramfs.testing
        fi

        root_password=$(grep '^root:' "/etc/shadow" | cut -d':' -f2)
        initramfs_root_password=$(grep '^root:' "$TESTDIR"/initrd/dracut.*/initramfs/etc/shadow | cut -d':' -f2)

        if [ "$root_password" != "$initramfs_root_password" ]; then
            echo "The password for root does not match, failing the test."
            return 1
        fi
    fi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
