#!/usr/bin/env bash
set -eu

[ -z "${TEST_FSTYPE-}" ] && TEST_FSTYPE="ext4"

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

client_run() {
    local test_name="$1"
    shift
    local client_opts="$*"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/root.img root
    qemu_add_drive disk_args "$TESTDIR"/root_erofs.img root_erofs
    qemu_add_drive disk_args "$TESTDIR"/root_iso.img root_iso

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE rd.overlay root=live:/dev/disk/by-label/dracut $client_opts" \
        -initrd "$TESTDIR"/initramfs.testing
    check_qemu_log

    client_test_end
}

# Verify autooverlay created a second partition and wrote the marker to it.
# Extract only the second partition to avoid false positives from the test
# script in the first partition.
check_autooverlay_marker() {
    local rootPartitions part2_info part2_start part2_size
    rootPartitions=$(sfdisk -d "$TESTDIR"/root.img | grep -c 'root\.img[0-9]')
    if [ "$rootPartitions" -ne 2 ]; then
        echo >&2 "E: Expected two partitions on root.img, but got $rootPartitions."
        return 1
    fi
    part2_info=$(sfdisk -d "$TESTDIR"/root.img | grep 'root\.img2')
    part2_start=$(echo "$part2_info" | sed -n 's/.*start= *\([0-9]*\).*/\1/p')
    part2_size=$(echo "$part2_info" | sed -n 's/.*size= *\([0-9]*\).*/\1/p')
    dd if="$TESTDIR"/root.img of="$TESTDIR"/overlay-part.img bs=512 skip="$part2_start" count="$part2_size" status=none
    test_marker_check dracut-autooverlay-success overlay-part.img
}

# Reset root.img to single partition state for autooverlay test
reset_overlay_partition() {
    test_marker_reset
    sfdisk --delete "$TESTDIR"/root.img 2 2> /dev/null || :
    dd if=/dev/zero of="$TESTDIR"/root.img bs=1M seek=320 count=50 conv=notrunc status=none
    local rootPartitions
    rootPartitions=$(sfdisk -d "$TESTDIR"/root.img | grep -c 'root\.img[0-9]')
    [ "$rootPartitions" -eq 1 ]
}

test_run() {
    client_run "overlayfs" ""

    client_run "live" "rd.live.image"
    client_run "livedir" "rd.live.image rd.live.dir=LiveOS"

    # Run the erofs test only if mkfs.erofs is available
    if command -v mkfs.erofs &> /dev/null; then
        client_run "erofs" "root=live:/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root_erofs"
    fi

    # Run the iso test only if xorriso is available
    if command -v xorriso &> /dev/null; then
        client_run "iso" "iso-scan/filename=linux.iso root=live:/dev/disk/by-label/ISO rd.driver.pre=squashfs rd.driver.pre=ext4"
    fi

    reset_overlay_partition
    client_run "autooverlay" "rd.live.image rd.overlay=LABEL=persist rd.live.dir=LiveOS"
    check_autooverlay_marker

    # Test backward compatibility with rd.live.overlay (deprecated parameter)
    reset_overlay_partition
    client_run "autooverlay (deprecated rd.live.overlay)" "rd.live.image rd.live.overlay=LABEL=persist rd.live.dir=LiveOS"
    check_autooverlay_marker

    return 0
}

test_setup() {
    # Create what will eventually be our root filesystem onto an overlay
    build_client_rootfs "$TESTDIR/rootfs" ./assertion.sh

    # test to make sure /proc /sys and /dev is not needed inside the generated initrd
    rm -rf "$TESTDIR"/rootfs/proc "$TESTDIR"/rootfs/sys "$TESTDIR"/rootfs/dev

    mkdir -p "$TESTDIR"/live/LiveOS
    mksquashfs "$TESTDIR"/rootfs/ "$TESTDIR"/live/LiveOS/rootfs.img -quiet -no-progress

    # Create the blank file to use as a root filesystem
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/root.img root 1

    sfdisk "$TESTDIR"/root.img << EOF
2048,652688
EOF

    rm -f "$TESTDIR/ext4.img"
    truncate -s "$((512 * 652688))" "$TESTDIR/ext4.img"
    # Use the live structure (with LiveOS/rootfs.img squashfs) instead of raw rootfs
    mkfs.ext4 -q -L dracut -d "$TESTDIR"/live/ "$TESTDIR"/ext4.img
    dd if="$TESTDIR"/ext4.img of="$TESTDIR"/root.img bs=512 seek=2048 conv=noerror,notrunc

    # erofs drive
    qemu_add_drive disk_args "$TESTDIR"/root_erofs.img root_erofs 1

    # Write the erofs compressed filesystem to the partition
    if command -v mkfs.erofs &> /dev/null; then
        mkfs.erofs --quiet "$TESTDIR"/root_erofs.img "$TESTDIR"/rootfs/
    fi

    # iso drive
    qemu_add_drive disk_args "$TESTDIR"/root_iso.img root_iso 1

    # Write the iso to the partition
    if command -v xorriso &> /dev/null; then
        mkdir "$TESTDIR"/iso
        xorriso -as mkisofs -output "$TESTDIR"/iso/linux.iso "$TESTDIR"/live/ -volid "ISO" -iso-level 3
        mkfs.ext4 -q -L dracut_iso -d "$TESTDIR"/iso/ "$TESTDIR"/root_iso.img
    fi

    local dracut_modules="dmsquash-live-autooverlay convertfs pollcdrom kernel-modules kernel-modules-extra qemu"

    if type -p ntfs-3g &> /dev/null; then
        dracut_modules="$dracut_modules dmsquash-live-ntfs"
    fi

    if type -p NetworkManager &> /dev/null; then
        dracut_modules="$dracut_modules network-manager"
        if type -p curl &> /dev/null; then
            dracut_modules="$dracut_modules livenet"
        fi
    fi

    test_dracut \
        --no-hostonly \
        --add-drivers "${TEST_FSTYPE}" \
        --modules " $dracut_modules "
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
