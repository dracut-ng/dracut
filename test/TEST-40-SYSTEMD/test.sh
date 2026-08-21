#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="root filesystem on a ext4 filesystem with systemd but without initqueue"

test_check() {
    require_binaries_for_test systemctl
}

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell=1 rd.break=pre-mount"
test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu \
        "${disk_args[@]}" \
        -append "$TEST_KERNEL_CMDLINE \"root=LABEL=  rdinit=/bin/sh\" systemd.log_target=console init=/sbin/init" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
}

is_systemd_version_greater_or_equal() {
    local version="$1"

    command -v systemctl &> /dev/null
    systemd_version=$(systemctl --version | awk 'NR==1 { print $2 }')
    ((systemd_version >= "$version"))
}

test_setup() {
    build_client_rootfs "$TESTDIR/rootfs"
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img '  rdinit=/bin/sh'

    # systemd-analyze.sh calls man indirectly
    # make the man command succeed always

    #make sure --omit-drivers does not filter out drivers using regexp to test for an earlier regression (assuming there is no one letter linux kernel module needed to run the test)

    test_dracut \
        --omit "fido2 initqueue" \
        --omit-drivers 'a b c d e f g h i j k l m n o p q r s t u v w x y z' \
        -I systemd-analyze \
        -i ./systemd-analyze.sh /usr/lib/dracut/hooks/pre-pivot/00-systemd-analyze.sh \
        -i "/bin/true" "/usr/bin/man"

    # shellcheck disable=SC2144 # We're not installing multilib libfido2, so
    # glob will only match once. More matches would break the test anyway.
    if is_systemd_version_greater_or_equal 257 && compgen -G /usr/lib*/libfido2.so.1 > /dev/null \
        && ! lsinitrd "$TESTDIR"/initramfs.testing | grep -E ' usr/lib[^/]*/libfido2\.so\.1\b' > /dev/null; then
        echo "Error: libfido2.so.1 should have been included in the initramfs" >&2
        return 1
    fi
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
