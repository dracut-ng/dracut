#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="download and import disk images at boot with systemd-import"

# Uncomment these to debug failures
#DEBUGFAIL="systemd.show_status=1 systemd.log_level=debug"

# Verify checksum by default
IMPORT_VERIFY="checksum"

test_check() {
    # python3 needed for HTTP server
    require_binaries_for_test python3 /usr/lib/systemd/systemd-importd systemd-dissect tar zstd
}

client_run() {
    local test_name="$1"
    local append="$2"

    client_test_start "$test_name"

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -device "virtio-net-pci,netdev=lan0" \
        -netdev "user,id=lan0,net=10.0.2.0/24,dhcpstart=10.0.2.15" \
        -append "$append $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR/initramfs.testing"
    test_marker_check

    client_test_end
}

test_run() {
    local port root_dir image_name

    port=$(start_webserver)

    root_dir="root"
    client_run "Download tar disk image into /run/machines/$root_dir, verify $IMPORT_VERIFY and bind mount it into /sysroot" \
        "rd.systemd.pull=tar,machine,verify=$IMPORT_VERIFY:$root_dir:http://10.0.2.2:$port/root.tar.zst root=bind:/run/machines/$root_dir"

    image_name="image"
    client_run "Download ext4 raw image into memory, verify $IMPORT_VERIFY and attach it to a loopback block device" \
        "rd.systemd.pull=raw,machine,verify=$IMPORT_VERIFY,blockdev:$image_name:http://10.0.2.2:$port/root_ext4.img root=/dev/disk/by-loop-ref/$image_name.raw"

    if command -v mksquashfs &> /dev/null; then
        client_run "Download squashfs image into memory, verify $IMPORT_VERIFY and attach it to a loopback block device" \
            "rd.systemd.pull=raw,machine,verify=$IMPORT_VERIFY,blockdev:$image_name:http://10.0.2.2:$port/root_squashfs.img root=/dev/disk/by-loop-ref/$image_name.raw"
    fi

    if command -v mkfs.erofs &> /dev/null \
        && ! grep -q -r -w "blacklist erofs" /{etc,usr/lib}/modprobe.d; then
        client_run "Download erofs image into memory, verify $IMPORT_VERIFY and attach it to a loopback block device" \
            "rd.systemd.pull=raw,machine,verify=$IMPORT_VERIFY,blockdev:$image_name:http://10.0.2.2:$port/root_erofs.img root=/dev/disk/by-loop-ref/$image_name.raw"
    fi
}

test_setup() {
    local image images=() local_pubring=() network_handler

    # Create plain root filesystem
    build_client_rootfs "$TESTDIR/rootfs" ./assertion.sh

    # Create a compressed tarball with the plain rootfs
    tar -C "$TESTDIR/rootfs" --zstd -cf "$TESTDIR/root.tar.zst" .
    images+=("root.tar.zst")

    # Create an ext4 image with the rootfs
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR/root_ext4.img" dracut
    images+=("root_ext4.img")

    # If mksquashfs is available, create a squashfs image with the rootfs
    if command -v mksquashfs &> /dev/null; then
        mksquashfs "$TESTDIR/rootfs" "$TESTDIR/root_squashfs.img" -quiet -no-progress
        images+=("root_squashfs.img")
    fi

    # erofs is supported, but can be explicitly blacklisted by the OS
    # (e.g., in openSUSE distributions)
    if command -v mkfs.erofs &> /dev/null \
        && ! grep -q -r -w "blacklist erofs" /{etc,usr/lib}/modprobe.d; then
        mkfs.erofs --quiet "$TESTDIR/root_erofs.img" "$TESTDIR/rootfs"
        images+=("root_erofs.img")
    fi

    # If GnuPG is available, generate a key and import it into a keyring file
    # that will be checked by systemd-import, so it can verify the signature of
    # the checksums of each image
    if command -v gpg &> /dev/null && command -v gpg-agent &> /dev/null; then
        mkdir -m 700 "$TESTDIR/gpg"
        gpg --homedir "$TESTDIR/gpg" --batch --quick-generate-key --passphrase "" "dracut" ed25519 default 0
        gpg --homedir "$TESTDIR/gpg" --output "$TESTDIR/dracut.asc" --export -a "dracut"
        gpg --homedir "$TESTDIR/gpg" --no-default-keyring --keyring "$TESTDIR/import-pubring.pgp" --import "$TESTDIR/dracut.asc"
        local_pubring=("-i" "$TESTDIR/import-pubring.pgp" "/etc/systemd/import-pubring.pgp")
        IMPORT_VERIFY="signature"
    fi

    # Save sha256 checksums, and sign them if GnuPG is available
    pushd "$TESTDIR"
    for image in "${images[@]}"; do
        sha256sum "$image" > "$image.sha256"
        if [[ $IMPORT_VERIFY == "signature" ]]; then
            gpg --homedir "$TESTDIR/gpg" --detach-sig --sign -u "dracut" -a "$image.sha256"
        fi
    done
    popd

    # If systemd-networkd is installed, give preference to it, because
    # network-manager uses dbus, and depending on the specific implementation
    # of the broker (e.g. Ubuntu), it can lead to ordering cycles.
    network_handler=""
    if [[ -x /usr/lib/systemd/systemd-networkd ]]; then
        network_handler="systemd-networkd"
    fi
    test_dracut \
        "${local_pubring[@]}" \
        -a "systemd-import $network_handler"
}

test_cleanup() {
    stop_webserver
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
