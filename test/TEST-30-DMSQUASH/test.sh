#!/usr/bin/env bash

# shellcheck disable=SC2034
TEST_DESCRIPTION="live root on a squash filesystem"

# Uncomment these to debug failures
#DEBUGFAIL="rd.shell rd.debug rd.live.debug loglevel=7"

test_check() {
    if ! type -p mksquashfs &> /dev/null; then
        echo "Test needs mksquashfs... Skipping"
        return 1
    fi
}

test_run() {
    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_index disk_args "$TESTDIR"/root.img root

    # shellcheck source=$TESTDIR/fs
    . "$TESTDIR"/fs

    # erofs drive
    qemu_add_drive disk_index disk_args "$TESTDIR"/root_erofs.img root_erofs

    # NTFS drive
    qemu_add_drive disk_index disk_args "$TESTDIR"/root_ntfs.img root_ntfs

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -boot order=d \
        -append "$TEST_KERNEL_CMDLINE rd.live.overlay.overlayfs=1 root=live:/dev/disk/by-label/dracut" \
        -initrd "$TESTDIR"/initramfs.testing

    test_marker_check || return 1

    # Run the erofs test only if mkfs.ntfs is available
    if [[ "$EROFS" ]]; then
        test_marker_reset
        "$testdir"/run-qemu \
            "${disk_args[@]}" \
            -boot order=d \
            -append "$TEST_KERNEL_CMDLINE rd.live.overlay.overlayfs=1 root=live:/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root_erofs" \
            -initrd "$TESTDIR"/initramfs.testing

        test_marker_check || return 1
    fi

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -boot order=d \
        -append "$TEST_KERNEL_CMDLINE rd.live.image rd.live.overlay.overlayfs=1 root=LABEL=dracut" \
        -initrd "$TESTDIR"/initramfs.testing

    test_marker_check || return 1

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -boot order=d \
        -append "$TEST_KERNEL_CMDLINE rd.live.image rd.live.overlay.overlayfs=1 rd.live.dir=testdir root=LABEL=dracut" \
        -initrd "$TESTDIR"/initramfs.testing

    test_marker_check || return 1

    # Run the NTFS test only if mkfs.ntfs is available
    if [[ "$NTFS" ]]; then
        dd if=/dev/zero of="$TESTDIR"/marker.img bs=1MiB count=1 status=none
        "$testdir"/run-qemu \
            "${disk_args[@]}" \
            -boot order=d \
            -append "$TEST_KERNEL_CMDLINE rd.live.image rd.live.overlay.overlayfs=1 rd.live.dir=testdir root=LABEL=dracut_ntfs" \
            -initrd "$TESTDIR"/initramfs.testing

        test_marker_check || return 1
    fi

    test_marker_reset
    rootPartitions=$(sfdisk -d "$TESTDIR"/root.img | grep -c 'root\.img[0-9]')
    [ "$rootPartitions" -eq 1 ] || return 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -boot order=d \
        -append "init=/sbin/init-persist rd.live.image rd.live.overlay.overlayfs=1 rd.live.overlay=LABEL=persist rd.live.dir=testdir root=LABEL=dracut console=ttyS0,115200n81 quiet rd.info rd.shell=0 panic=1 oops=panic softlockup_panic=1 $DEBUGFAIL" \
        -initrd "$TESTDIR"/initramfs.testing-autooverlay

    rootPartitions=$(sfdisk -d "$TESTDIR"/root.img | grep -c 'root\.img[0-9]')
    [ "$rootPartitions" -eq 2 ] || return 1

    (
        # Ensure that this test works when run with the `V=1` parameter, which runs the script with `set -o pipefail`.
        set +o pipefail

        # Verify that the string "dracut-autooverlay-success" occurs in the second partition in the image file.
        dd if="$TESTDIR"/root.img bs=1MiB skip=80 status=none \
            | grep -U --binary-files=binary -F -m 1 -q dracut-autooverlay-success
    ) || return 1
}

test_setup() {
    # Create what will eventually be our root filesystem onto an overlay
    "$DRACUT" -N --keep --tmpdir "$TESTDIR" \
        --add-confdir test-root \
        -i ./test-init.sh /sbin/init-persist \
        -f "$TESTDIR"/initramfs.root "$KVERSION" || return 1
    mkdir -p "$TESTDIR"/overlay/source && mv "$TESTDIR"/dracut.*/initramfs/* "$TESTDIR"/overlay/source && rm -rf "$TESTDIR"/dracut.*

    # test to make sure /proc /sys and /dev is not needed inside the generated initrd
    rm -rf "$TESTDIR"/dracut.*/initramfs/proc "$TESTDIR"/dracut.*/initramfs/sys "$TESTDIR"/dracut.*/initramfs/dev

    # second, install the files needed to make the root filesystem
    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    "$DRACUT" -N -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        --install "sfdisk mkfs.ntfs mksquashfs mkfs.erofs" \
        --drivers "ntfs3 erofs" \
        --include ./create-root.sh /lib/dracut/hooks/initqueue/01-create-root.sh \
        --force "$TESTDIR"/initramfs.makeroot "$KVERSION" || return 1

    # Create the blank file to use as a root filesystem
    declare -a disk_args=()
    declare -i disk_index=0
    qemu_add_drive disk_index disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_index disk_args "$TESTDIR"/root.img root 1

    # erofs drive
    qemu_add_drive disk_index disk_args "$TESTDIR"/root_erofs.img root_erofs 1

    # NTFS drive
    qemu_add_drive disk_index disk_args "$TESTDIR"/root_ntfs.img root_ntfs 1

    # Invoke KVM and/or QEMU to actually create the target filesystem.
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/dracut/root quiet console=ttyS0,115200n81" \
        -initrd "$TESTDIR"/initramfs.makeroot || return 1

    if ! test_marker_check dracut-root-block-created; then
        echo "Could not create root filesystem"
        return 1
    fi

    # grab the list of supported filesystem kernel modules
    grep -F -a -m 1 EROFS "$TESTDIR"/marker.img >> "$TESTDIR"/fs
    grep -F -a -m 1 NTFS "$TESTDIR"/marker.img >> "$TESTDIR"/fs

    # mount NTFS with ntfs3 driver inside the generated initramfs
    cat > /tmp/ntfs3.rules << 'EOF'
SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="ntfs", ENV{ID_FS_TYPE}="ntfs3"
EOF

    test_dracut \
        --no-hostonly \
        --add "dmsquash-live qemu" \
        --drivers "ntfs3" \
        --install "mkfs.ext4" \
        -a bash \
        --include /tmp/ntfs3.rules /lib/udev/rules.d/ntfs3.rules \
        "$TESTDIR"/initramfs.testing

    test_dracut \
        --no-hostonly \
        --add "dmsquash-live-autooverlay qemu" \
        --install "mkfs.ext4" \
        -a bash \
        "$TESTDIR"/initramfs.testing-autooverlay
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
