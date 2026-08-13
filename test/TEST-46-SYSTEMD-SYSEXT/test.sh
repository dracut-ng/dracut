#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on a ext4 filesystem with systemd and extensions"

# Uncomment these to debug failures
#DEBUGFAIL="systemd.show_status=1 systemd.log_level=debug"

test_check() {
    local binary

    for binary in systemd-repart openssl; do
        if ! type -p "$binary" &> /dev/null; then
            echo "Test needs $binary... Skipping"
            return 1
        fi
    done
}

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/marker2.img marker2 1
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR"/initramfs.testing

    test_marker_check

    # Also check if the message "dracut-sysext-success" is in the marker
    if ! test_marker_check "dracut-sysext-success" marker2.img; then
        return 1
    fi
}

test_setup() {
    local crt_dir fs_type confext_name sysext_name

    # Create plain root filesystem
    build_client_rootfs "$TESTDIR/rootfs"

    # Create an ext4 image with the rootfs
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR/root.img" dracut

    # Create X.509 certificate to sign extensions
    crt_dir="dracut-crt"
    mkdir -p "$TESTDIR/$crt_dir"
    pushd "$TESTDIR/$crt_dir"
    openssl req \
        -quiet \
        -new -x509 \
        -newkey rsa:1024 \
        -keyout "dracut.key" \
        -subj "/CN=Dracut Test Key/" \
        -outform PEM \
        -out "dracut.crt" \
        -days 365 \
        -nodes
    popd

    # systemd-repart creates erofs partitions by default, but can be explicitly
    # blacklisted by the OS (e.g., in openSUSE distributions), so if it is not
    # available, override it to use squashfs
    if ! command -v mkfs.erofs &> /dev/null \
        || grep -q -r -w "blacklist erofs" /{etc,usr/lib}/modprobe.d; then
        fs_type="squashfs"
    fi

    # Create a configuration extension: it simply creates a marker in /etc
    confext_name="dracut-confext"
    mkdir -p "$TESTDIR/$confext_name/etc/extension-release.d"
    pushd "$TESTDIR/$confext_name/etc"
    echo "dracut-sysext-success" > "$confext_name.marker"
    {
        grep -e "^ID=" -e "^VERSION_ID=" /etc/os-release
        echo "CONFEXT_SCOPE=initrd"
    } > "extension-release.d/extension-release.$confext_name"
    popd

    env ${fs_type:+SYSTEMD_REPART_OVERRIDE_FSTYPE=${fs_type-}} systemd-repart \
        --make-ddi=confext \
        --private-key="$TESTDIR/$crt_dir/dracut.key" \
        --certificate="$TESTDIR/$crt_dir/dracut.crt" \
        --copy-source="$TESTDIR/$confext_name" \
        "$TESTDIR/$confext_name.raw"

    # Create a system extension: this will create a script in
    # pre-pivot that checks if the marker created with the confext
    # exists and prints its content
    sysext_name="dracut-sysext"
    mkdir -p "$TESTDIR/$sysext_name/usr/lib/dracut/hooks/pre-pivot"
    pushd "$TESTDIR/$sysext_name/usr/lib"
    touch "dracut/hooks/pre-pivot/$sysext_name.sh"
    chmod +x "dracut/hooks/pre-pivot/$sysext_name.sh"
    echo "[ -e \"/etc/$confext_name.marker\" ] && cat /etc/$confext_name.marker | dd oflag=direct of=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_marker2 status=none" > "dracut/hooks/pre-pivot/50-$sysext_name.sh"
    mkdir -p "extension-release.d"
    {
        grep -e "^ID=" -e "^VERSION_ID=" /etc/os-release
        echo "SYSEXT_SCOPE=initrd"
    } > "extension-release.d/extension-release.$sysext_name"
    popd

    env ${fs_type:+SYSTEMD_REPART_OVERRIDE_FSTYPE=${fs_type-}} systemd-repart \
        --make-ddi=sysext \
        --private-key="$TESTDIR/$crt_dir/dracut.key" \
        --certificate="$TESTDIR/$crt_dir/dracut.crt" \
        --copy-source="$TESTDIR/$sysext_name" \
        "$TESTDIR/$sysext_name.raw"

    # "Simulate" that the bootloader copies the extensions in /.extra
    # We also need to copy the public certificate to allow userspace verity
    # signature checking
    test_dracut \
        --no-hostonly-cmdline \
        --install "dd" \
        -i "$TESTDIR/$confext_name.raw" "/.extra/confext/$confext_name.raw" \
        -i "$TESTDIR/$sysext_name.raw" "/.extra/sysext/$sysext_name.raw" \
        -i "$TESTDIR/$crt_dir/dracut.crt" "/etc/verity.d/dracut.crt" \
        -a "systemd-sysext"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
