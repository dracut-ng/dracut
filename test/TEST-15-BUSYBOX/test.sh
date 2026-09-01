#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="busybox applets win over host binaries when busybox module is included"

# Uncomment this to debug failures
#DEBUGFAIL="rd.debug rd.shell"

test_check() {
    require_binaries_for_test busybox
}

test_setup() {
    build_client_rootfs "$TESTDIR/rootfs"
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    busybox --list-full > "${TESTDIR}/busybox.links"
    # add an extra link to see if the list is used
    echo "usr/bin/silly-serval" >> "${TESTDIR}/busybox.links"
}

check_applets_from_busybox() {
    local _applet _listing ret=0
    local initrd="$1"
    shift
    _listing=$(lsinitrd "$initrd")
    if [[ ${V-} -ge 1 ]]; then
        echo "$_listing"
    fi
    for _applet in "$@"; do
        # Match applets layout-agnostically: the applet may live under
        # bin/ or usr/bin/, and the symlink target may be # relative
        # (e.g. bin/cp -> ../usr/bin/busybox on alpine) or just "busybox"
        if ! grep -qE "(^|/)$_applet -> ([^ ]*/)?busybox\$" <<< "$_listing"; then
            echo "FAIL: $_applet is not a busybox symlink in the initrd" >&2
            ret=1
        fi
    done
    return "$ret"
}

test_run() {
    if [[ ${V-} -ge 2 ]]; then
        set -x
    fi
    local ret=0

    # Test override the list of applets
    DRACUT_MODULE_BUSYBOX_LINKS="$(cat "${TESTDIR}/busybox.links")" \
        test_dracut \
        --no-hostonly --no-kernel --drivers "" \
        --modules "base busybox"
    check_applets_from_busybox "$TESTDIR/initramfs.testing" ash cp ip ls mv mkdir silly-serval sleep tr || ret=1

    # Test using busybox
    rm "$TESTDIR/initramfs.testing"
    test_dracut --add busybox

    # Check applets the base module would otherwise install from the host.
    # Each must resolve to busybox in the resulting initrd.
    check_applets_from_busybox "$TESTDIR/initramfs.testing" ash cp ip ls mv mkdir sleep tr || ret=1

    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root
    test_marker_reset
    "$testdir"/run-qemu -nic none \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR/initramfs.testing"
    test_marker_check

    return "$ret"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
