#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on LVM on encrypted partitions (with and without RAID)"

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell rd.break" # udev.log-priority=debug
#DEBUGFAIL="rd.shell rd.udev.log-priority=debug loglevel=70 systemd.log_target=kmsg systemd.log_target=debug"
#DEBUGFAIL="rd.shell loglevel=70 systemd.log_target=kmsg systemd.log_target=debug"

test_check() {
    if ! type -p cryptsetup &> /dev/null; then
        echo "Test needs cryptsetup for crypt module... Skipping"
        return 1
    fi

    if ! type -p lvm &> /dev/null; then
        echo "Test needs lvm for lvm module... Skipping"
        return 1
    fi

    if ! type -p mdadm &> /dev/null; then
        echo "Test needs mdadm for mdraid module ... Skipping"
        return 1
    fi
}

test_run() {
    LUKSARGS=$(cat "$TESTDIR"/luks.txt)

    client_test_start "$LUKSARGS"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/disk-1.img disk1
    qemu_add_drive disk_args "$TESTDIR"/disk-2.img disk2

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE root=/dev/dracut/root ro rd.auto rootwait $LUKSARGS" \
        -initrd "$TESTDIR"/initramfs.testing
    check_qemu_log
    client_test_end

    client_test_start "Any LUKS"
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE root=/dev/dracut/root rd.auto" \
        -initrd "$TESTDIR"/initramfs.testing
    check_qemu_log
    client_test_end

    if [ -f "$TESTDIR"/initramfs.testing.enc-lvm ]; then
        client_test_start "LVM-on-LUKS with systemd (need_shutdown set)"

        declare -a enc_lvm_disk_args=()
        qemu_add_drive enc_lvm_disk_args "$TESTDIR"/disk-enc-lvm.img disk1

        LUKSARGS_ENC_LVM=$(cat "$TESTDIR"/luks-enc-lvm.txt)
        "$testdir"/run-qemu \
            "${enc_lvm_disk_args[@]}" \
            -append "$TEST_KERNEL_CMDLINE root=/dev/dracut/root ro rd.auto rootwait $LUKSARGS_ENC_LVM" \
            -initrd "$TESTDIR"/initramfs.testing.enc-lvm
        check_qemu_log
        client_test_end
    fi

    return 0
}

make_enc_lvm_rootfs() {
    # Build a root filesystem on a single encrypted disk (LVM-on-LUKS, no RAID)
    build_client_rootfs "$TESTDIR/overlay-enc-lvm/source" ./assertion.sh

    call_dracut -i "$TESTDIR/overlay-enc-lvm" / \
        --add-confdir test-makeroot \
        -a "bash crypt lvm" \
        -I "grep cryptsetup" \
        -i ./setup-shutdown-env.sh /usr/lib/dracut/hooks/initqueue/01-create-root.sh \
        -f "$TESTDIR"/initramfs.makeroot-enc-lvm

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker-enc-lvm.img marker 1
    qemu_add_drive disk_args "$TESTDIR"/disk-enc-lvm.img disk1 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot quiet" \
        -initrd "$TESTDIR"/initramfs.makeroot-enc-lvm
    test_marker_check dracut-root-block-created marker-enc-lvm.img
    rm -rf "$TESTDIR/overlay-enc-lvm"
}

make_test_rootfs() {
    # Create what will eventually be our root filesystem onto an overlay
    build_client_rootfs "$TESTDIR/overlay/source"

    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.
    call_dracut -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -a "bash crypt lvm mdraid" \
        -I "grep cryptsetup" \
        -i ./create-root.sh /usr/lib/dracut/hooks/initqueue/01-create-root.sh \
        -f "$TESTDIR"/initramfs.makeroot

    # Create the blank files to use as a root filesystem
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_args "$TESTDIR"/disk-1.img disk1 1
    qemu_add_drive disk_args "$TESTDIR"/disk-2.img disk2 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot quiet" \
        -initrd "$TESTDIR"/initramfs.makeroot
    test_marker_check dracut-root-block-created
    rm -rf "$TESTDIR"/overlay
}

test_setup() {
    echo -n verySecurePassword > /tmp/key
    chmod 0600 /tmp/key

    # The LVM-on-LUKS systemd case needs the systemd-cryptsetup binary. Skip
    # that case on hosts without it
    if [ -x /usr/lib/systemd/systemd-cryptsetup ] || [ -x /lib/systemd/systemd-cryptsetup ]; then
        # Build the no-RAID rootfs and systemd-based initramfs first, then
        # rename it aside, the RAID build reuses $TESTDIR/initramfs.testing
        make_enc_lvm_rootfs

        luks_uuid=$(grep -F -a -m 1 ID_FS_UUID "$TESTDIR"/marker-enc-lvm.img | cut -d= -f2)
        printf 'rd.luks.uuid=luks-%s' "$luks_uuid" > "$TESTDIR"/luks-enc-lvm.txt
        printf 'luks-%s /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_disk1 /etc/key timeout=0\n' "$luks_uuid" > /tmp/crypttab-enc-lvm

        test_dracut -f \
            -a "crypt lvm" \
            --add "systemd systemd-cryptsetup" \
            -i "/tmp/crypttab-enc-lvm" "/etc/crypttab" \
            -i "/tmp/key" "/etc/key"
        mv "$TESTDIR/initramfs.testing" "$TESTDIR/initramfs.testing.enc-lvm"
    else
        echo "systemd-cryptsetup not found, skipping LVM-on-LUKS systemd build"
    fi

    make_test_rootfs

    cryptoUUIDS=$(grep -F -a -m 3 ID_FS_UUID "$TESTDIR"/marker.img)
    for uuid in $cryptoUUIDS; do
        eval "$uuid"
        printf ' rd.luks.uuid=luks-%s ' "$ID_FS_UUID"
    done > "$TESTDIR"/luks.txt

    i=1
    for uuid in $cryptoUUIDS; do
        eval "$uuid"
        printf 'luks-%s /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_disk%s /etc/key timeout=0\n' "$ID_FS_UUID" $i
        ((i += 1))
    done > /tmp/crypttab

    test_dracut -f \
        -a "crypt lvm mdraid" \
        -i "/tmp/crypttab" "/etc/crypttab" \
        -i "/tmp/key" "/etc/key"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
