#!/usr/bin/env bash
set -eu

[ -z "${TEST_FSTYPE-}" ] && TEST_FSTYPE="ext4"

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on multiple device $TEST_FSTYPE (on top of RAID and LUKS)"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_check() {
    (command -v zfs || (command -v lvm && command -v "mkfs.$TEST_FSTYPE")) &> /dev/null
}

USE_LVM=
HAVE_RAID=
HAVE_CRYPT=
if [ "$TEST_FSTYPE" != "zfs" ] && [ "$TEST_FSTYPE" != "btrfs" ]; then
    # test fips mode
    [ -f /usr/share/crypto-policies/default-fips-config ] && TEST_KERNEL_CMDLINE+=" fips=1 rd.fips.skipkernel boot=LABEL=dracut "

    export USE_LVM=1
    command -v mdadm > /dev/null && export HAVE_RAID=1
    command -v cryptsetup > /dev/null && export HAVE_CRYPT=1
fi

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell"
client_run() {
    local test_name="$1"
    shift
    local disk="$1"
    shift
    local client_opts="$*"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR/${disk}-1.img" disk1

    if ! grep -qF 'degraded' "$test_name"; then
        # only add disk2 if RAID is NOT degraded
        qemu_add_drive disk_args "$TESTDIR/${disk}-2.img" disk2
    fi

    if [ "$TEST_FSTYPE" = "zfs" ]; then
        TEST_KERNEL_CMDLINE+=" root=ZFS=dracut/root "
    else
        TEST_KERNEL_CMDLINE+=" root=LABEL=dracut "
    fi

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE ro $client_opts " \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check

    client_test_end
}

test_run() {
    # ignore crypttab with rd.luks.crypttab=0 and RAID with rd.md=0
    client_run "$TEST_FSTYPE" "disk" "rd.auto=1 rd.luks.crypttab=0 rd.md=0"

    # LVM-THIN
    if [ -n "$USE_LVM" ]; then
        client_run "$TEST_FSTYPE" "disk-thin" "rd.auto=1 rd.luks.crypttab=0 rd.md=0"
    fi

    # ignore crypttab with rd.luks.crypttab=0
    if [ -n "$HAVE_RAID" ]; then
        client_run "raid" "raid" "rd.auto=1 rd.luks.crypttab=0"
        client_run "degraded raid" "raid" "rd.auto=1 rd.luks.crypttab=0"
    fi

    # for encrypted test run - use raid-crypt.img drives instead of raid.img drives
    if [ -n "$HAVE_CRYPT" ] && [ -n "$HAVE_RAID" ]; then
        client_run "raid crypt" "raid-crypt" "rd.auto=1 "
        client_run "degraded raid crypt" "raid-crypt" "rd.auto=1 "

        read -r LUKS_UUID < "$TESTDIR"/luksuuid
        read -r MD_UUID < "$TESTDIR"/mduuid
        client_run "degraded raid crypt" "raid-crypt" "rd.luks.uuid=$LUKS_UUID rd.md.uuid=$MD_UUID rd.md.conf=0 rd.lvm.vg=dracut"
        client_run "degraded raid crypt" "raid-crypt" "rd.luks.uuid=$LUKS_UUID rd.md.uuid=$MD_UUID rd.lvm.vg=dracut"
        client_run "degraded raid crypt" "raid-crypt" "rd.luks.uuid=$LUKS_UUID rd.md.uuid=$MD_UUID rd.lvm.lv=dracut/root"
    fi
}

test_makeroot() {
    local test_name="$1"
    shift
    local disk="$1"
    shift
    local client_opts="$*"

    echo "MAKEROOT START: $test_name"

    # Create the blank files to use as a root filesystem
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker 1
    qemu_add_drive disk_args "$TESTDIR/${disk}-1.img" disk1 1
    qemu_add_drive disk_args "$TESTDIR/${disk}-2.img" disk2 1

    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=/dev/fakeroot quiet $client_opts " \
        -initrd "$TESTDIR"/initramfs.makeroot
    test_marker_check dracut-root-block-created

    echo "MAKEROOT END: $test_name [OK]"
}

test_setup() {
    # Create what will eventually be our root filesystem onto an overlay
    build_client_rootfs "$TESTDIR/overlay/source"

    # pass enviroment variables to make the root filesystem
    echo "TEST_FSTYPE=${TEST_FSTYPE}" > "$TESTDIR"/overlay/env

    # create an initramfs that will create the target root filesystem.
    # We do it this way so that we do not risk trashing the host mdraid
    # devices, volume groups, encrypted partitions, etc.

    # shellcheck disable=SC2046
    call_dracut -i "$TESTDIR"/overlay / \
        --add-confdir test-makeroot \
        -a "lvm" \
        -I "grep" \
        $(if command -v mdadm > /dev/null; then echo "-a mdraid"; fi) \
        $(if command -v cryptsetup > /dev/null; then echo "-a crypt -I cryptsetup"; fi) \
        $(if [ "$TEST_FSTYPE" = "zfs" ]; then echo "-a zfs"; else echo "-I mkfs.${TEST_FSTYPE} --add-drivers ${TEST_FSTYPE}"; fi) \
        -i ./create-root.sh /usr/lib/dracut/hooks/initqueue/01-create-root.sh \
        -f "$TESTDIR"/initramfs.makeroot

    # LVM
    test_makeroot "$TEST_FSTYPE" "disk" "rd.md=0 rd.luks=0"

    # LVM-THIN
    if [ -n "$USE_LVM" ]; then
        test_makeroot "$TEST_FSTYPE" "disk-thin" "rd.md=0 rd.luks=0 test.thin"
    fi

    if [ -n "$HAVE_RAID" ]; then
        test_makeroot "raid" "raid" "rd.luks=0"
    fi

    # for encrypted test run - use raid-crypt.img drives instead of raid.img drives
    if [ -n "$HAVE_CRYPT" ] && [ -n "$HAVE_RAID" ]; then
        test_makeroot "raid-crypt" "raid-crypt" " "

        eval "$(grep -F -a -m 1 MD_UUID "$TESTDIR"/marker.img)"
        echo "$MD_UUID" > "$TESTDIR"/mduuid

        eval "$(grep -F -a -m 1 ID_FS_UUID "$TESTDIR"/marker.img)"
        echo "$ID_FS_UUID" > "$TESTDIR"/luksuuid
        echo "testluks UUID=$ID_FS_UUID /etc/key" > /tmp/crypttab
        echo -n "verySecurePassword" > /tmp/key
        chmod 0600 /tmp/key
    fi

    rm -rf "$TESTDIR"/overlay

    # shellcheck disable=SC2046
    test_dracut \
        -a "lvm" \
        $(if command -v mdadm > /dev/null; then echo "-a mdraid"; fi) \
        $(if command -v cryptsetup > /dev/null; then echo "-a crypt"; fi) \
        --add-drivers "${TEST_FSTYPE}" \
        -i "/tmp/crypttab" "/etc/crypttab" \
        -i "/tmp/key" "/etc/key"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
