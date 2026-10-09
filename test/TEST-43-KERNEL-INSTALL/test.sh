#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="kernel-install with root filesystem on ext4 filesystem"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_check() {
    require_binaries_for_test kernel-install
}

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$BOOT_ROOT/$TOKEN/$KVERSION"/initrd
    test_marker_check

    # rescue (non-hostonly) boot
    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$BOOT_ROOT/$TOKEN"/0-rescue/initrd
    test_marker_check
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

    # test dracut outfile path detection with a custom entry token
    CUSTOM_TOKEN="custom-entry-token"
    mkdir -p /boot/loader/entries "/boot/$CUSTOM_TOKEN/$KVERSION" /etc/kernel
    echo "$CUSTOM_TOKEN" > /etc/kernel/entry-token
    call_dracut --add-confdir test-root --kver "$KVERSION" -f
    if [[ ! -e "/boot/$CUSTOM_TOKEN/$KVERSION/initrd" ]]; then
        echo "Error: dracut failed to detect outfile path with custom entry token at /boot/$CUSTOM_TOKEN/$KVERSION/initrd" >&2
        return 1
    fi

    # test that KERNEL_INSTALL_ENTRY_TOKEN env var takes precedence over the file
    ENV_TOKEN="env-entry-token"
    mkdir -p "/boot/$ENV_TOKEN/$KVERSION"
    KERNEL_INSTALL_ENTRY_TOKEN="$ENV_TOKEN" call_dracut --add-confdir test-root --kver "$KVERSION" -f
    if [[ ! -e "/boot/$ENV_TOKEN/$KVERSION/initrd" ]]; then
        echo "Error: dracut did not respect KERNEL_INSTALL_ENTRY_TOKEN env var, expected initrd at /boot/$ENV_TOKEN/$KVERSION/initrd" >&2
        return 1
    fi
    rm -f /etc/kernel/entry-token

    # test that the UKI output filename uses the entry token, not the machine-id
    if command -v ukify &> /dev/null; then
        echo "$CUSTOM_TOKEN" > /etc/kernel/entry-token
        call_dracut --uefi --add-confdir test-root --kver "$KVERSION" -f
        shopt -s nullglob
        uki=(/boot/EFI/Linux/linux-"$KVERSION"-"$CUSTOM_TOKEN"*.efi
            /boot/efi/EFI/Linux/linux-"$KVERSION"-"$CUSTOM_TOKEN"*.efi
            /efi/EFI/Linux/linux-"$KVERSION"-"$CUSTOM_TOKEN"*.efi)
        shopt -u nullglob
        if [[ ${#uki[@]} -eq 0 ]]; then
            echo "Error: dracut did not name the UKI using the entry token, expected .../EFI/Linux/linux-$KVERSION-$CUSTOM_TOKEN*.efi" >&2
            return 1
        fi
        rm -f /etc/kernel/entry-token
    fi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
