#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="kernel-install with root filesystem on ext4 filesystem"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_check() {
    if ! command -v kernel-install > /dev/null; then
        echo "This test needs kernel-install to run."
        return 1
    fi
}

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$BOOT_ROOT/$TOKEN/$KVERSION"/initrd
    check_qemu_log

    # rescue (non-hostonly) boot
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$BOOT_ROOT/$TOKEN"/0-rescue/initrd
    check_qemu_log

    # rescue boot with custom entry token
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$BOOT_ROOT/custom-entry-token"/0-rescue/initrd
    check_qemu_log
}

test_setup() {
    # shellcheck source=./dracut-functions.sh
    . "$PKGLIBDIR"/dracut-functions.sh

    # create root filesystem
    # shellcheck disable=SC2153
    call_dracut --tmpdir "$TESTDIR" \
        --add-confdir test-root \
        -f "$TESTDIR"/initramfs.root

    KVERSION=$(determine_kernel_version "$TESTDIR"/initramfs.root)
    KIMAGE=$(determine_kernel_image "$KVERSION")

    build_ext4_image "$TESTDIR"/dracut.*/initramfs/ "$TESTDIR"/root.img dracut

    mkdir -p /run/kernel /run/initramfs/dracut.conf.d
    printf "layout=bls\ninitrd_generator=dracut\nuki_generator=none\n" >> /run/kernel/install.conf

    # enable test dracut config
    cp "${basedir}"/dracut.conf.d/test/*.conf /run/initramfs/dracut.conf.d/

    # enable rescue boot config
    cp "${basedir}"/dracut.conf.d/rescue/*.conf /run/initramfs/dracut.conf.d/

    # using kernell-install to invoke dracut
    mkdir -p "$BOOT_ROOT/$TOKEN/$KVERSION" "$BOOT_ROOT/loader/entries" "$BOOT_ROOT/$TOKEN/0-rescue/loader/entries"
    kernel-install add "$KVERSION" "$KIMAGE"
    if [[ ! -e "$BOOT_ROOT/$TOKEN/$KVERSION"/initrd ]]; then
        echo "Error: kernel-install failed to create $BOOT_ROOT/$TOKEN/$KVERSION/initrd" >&2
        return 1
    fi

    # test with a custom entry token different from machine-id
    CUSTOM_TOKEN="custom-entry-token"
    mkdir -p "$BOOT_ROOT/$CUSTOM_TOKEN/$KVERSION" "$BOOT_ROOT/loader/entries" "$BOOT_ROOT/$CUSTOM_TOKEN/0-rescue"
    kernel-install add --entry-token "literal:$CUSTOM_TOKEN" "$KVERSION" "$KIMAGE"
    if [[ ! -e "$BOOT_ROOT/$CUSTOM_TOKEN/0-rescue/initrd" ]]; then
        echo "Error: kernel-install failed to create rescue initrd with custom entry token at $BOOT_ROOT/$CUSTOM_TOKEN/0-rescue/initrd" >&2
        return 1
    fi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
