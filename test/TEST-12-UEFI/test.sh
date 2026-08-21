#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="UEFI boot (ukify, kernel-install)"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_check() {
    require_binaries_for_test mksquashfs

    local arch=${DRACUT_ARCH:-$(uname -m)}
    if [[ ! ${arch} =~ ^(x86_64|i.86|aarch64|riscv64)$ ]]; then
        echo "Architecture '$arch' not supported to create a UEFI executable... Skipping" >&2
        return 1
    fi

    if ! "$testdir"/run-qemu --check-uefi; then
        echo "No UEFI firmware (for QEMU) found" >&2
        return 1
    fi
}

client_run() {
    local test_name="$1"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/squashfs.img root

    test_marker_reset
    "$testdir"/run-qemu "${disk_args[@]}" -net none \
        -drive file=fat:rw:"$TESTDIR"/ESP,format=vvfat,label=EFI
    test_marker_check
}

test_run() {
    client_run "UEFI with UKI and squashfs root"
}

test_setup() {
    # shellcheck source=./dracut-functions.sh
    . "$PKGLIBDIR"/dracut-functions.sh

    # Create what will eventually be our root filesystem
    call_dracut --tmpdir "$TESTDIR" \
        --add-confdir test-root \
        "$TESTDIR"/tmp-initramfs.root

    KVERSION=$(determine_kernel_version "$TESTDIR"/tmp-initramfs.root)
    KIMAGE=$(determine_kernel_image "$KVERSION")

    mksquashfs "$TESTDIR"/dracut.*/initramfs/ "$TESTDIR"/squashfs.img -quiet -no-progress

    mkdir -p "$TESTDIR"/ESP/EFI/BOOT "$TESTDIR"/dracut.conf.d

    # This is the preferred way to build uki with dracut on a systemd based system
    if command -v kernel-install &> /dev/null \
        && command -v systemctl &> /dev/null \
        && command -v ukify &> /dev/null; then

        echo "Using ukify via kernel-install to create UKI"

        export KERNEL_INSTALL_CONF_ROOT="$TESTDIR"/kernel-install
        mkdir -p "$KERNEL_INSTALL_CONF_ROOT"

        {
            echo 'initrd_generator=dracut'
            echo 'layout=uki'
            echo 'uki_generator=ukify'
        } >> "$KERNEL_INSTALL_CONF_ROOT/install.conf"

        echo "$TEST_KERNEL_CMDLINE root=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root" >> "$KERNEL_INSTALL_CONF_ROOT/cmdline"

        # enable test dracut config
        mkdir -p /run/initramfs/dracut.conf.d
        cp "${basedir}"/dracut.conf.d/test/* ./10-uki-virt.conf /run/initramfs/dracut.conf.d/
        echo 'add_drivers+=" squashfs "' >> /run/initramfs/dracut.conf.d/extra.conf

        # using kernell-install to invoke dracut
        mkdir -p "$BOOT_ROOT/$TOKEN/$KVERSION" "$BOOT_ROOT/loader/entries"
        kernel-install add "$KVERSION" "$KIMAGE"

        mv "$TESTDIR"/EFI/Linux/*.efi "$TESTDIR"/ESP/EFI/BOOT/BOOTX64.efi

        return 0
    fi

    # test with the reference uki config when systemd is available
    if command -v systemctl &> /dev/null; then
        cp ./10-uki-virt.conf "$TESTDIR"/dracut.conf.d/

    fi

    echo "Using dracut to create UKI"
    test_dracut \
        --kernel-cmdline "$TEST_KERNEL_CMDLINE root=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root" \
        --add-drivers 'squashfs' \
        --kver "$KVERSION" \
        --uefi \
        "$TESTDIR"/ESP/EFI/BOOT/BOOTX64.efi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
