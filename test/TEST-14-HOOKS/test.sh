#!/usr/bin/env bash
set -eu
# shellcheck disable=SC2034
TEST_DESCRIPTION="dracut hooks in various locations"

# Uncomment this to debug failures
#DEBUGFAIL="rd.shell rd.break"

test_run() {
    declare -a disk_args=()
    qemu_add_drive disk_args "$TESTDIR"/marker.img marker
    qemu_add_drive disk_args "$TESTDIR"/root.img root

    test_marker_reset
    "$testdir"/run-qemu -nic none \
        "${disk_args[@]}" \
        -append "root=LABEL=dracut $TEST_KERNEL_CMDLINE" \
        -initrd "$TESTDIR"/initramfs.testing
    test_marker_check
}

add_hook() {
    local path="$1"
    local rootdir="$TESTDIR/overlay"
    mkdir -p "${rootdir}${path%/*}"
    sed "s,@REPLACEME@,${path}," testhook.sh.template > "${rootdir}${path}"
}

test_setup() {
    local hook hookdir
    local expected_hooks_run=()
    local expected_hooks_not_run=()

    for hookdir in pre-mount cmdline pre-udev pre-trigger pre-pivot cleanup; do
        # Create hooks with different names. All of them must execute.
        add_hook "/var/lib/dracut/hooks/$hookdir/testhook-difname-var.sh"
        add_hook "/etc/dracut/hooks/$hookdir/testhook-difname-etc.sh"
        add_hook "/usr/lib/dracut/hooks/$hookdir/testhook-difname-lib.sh"
        expected_hooks_run+=(
            "/var/lib/dracut/hooks/$hookdir/testhook-difname-var.sh"
            "/etc/dracut/hooks/$hookdir/testhook-difname-etc.sh"
            "/usr/lib/dracut/hooks/$hookdir/testhook-difname-lib.sh"
        )

        # Create hooks with the same name. Only the highest priority ones must execute.
        add_hook "/var/lib/dracut/hooks/$hookdir/testhook-samename3.sh"
        add_hook "/etc/dracut/hooks/$hookdir/testhook-samename3.sh"
        add_hook "/usr/lib/dracut/hooks/$hookdir/testhook-samename3.sh"
        expected_hooks_run+=(
            "/var/lib/dracut/hooks/$hookdir/testhook-samename3.sh"
        )
        expected_hooks_not_run+=(
            "/etc/dracut/hooks/$hookdir/testhook-samename3.sh"
            "/usr/lib/dracut/hooks/$hookdir/testhook-samename3.sh"
        )

        add_hook "/etc/dracut/hooks/$hookdir/testhook-samename2.sh"
        add_hook "/usr/lib/dracut/hooks/$hookdir/testhook-samename2.sh"
        expected_hooks_run+=(
            "/etc/dracut/hooks/$hookdir/testhook-samename2.sh"
        )
        expected_hooks_not_run+=(
            "/usr/lib/dracut/hooks/$hookdir/testhook-samename2.sh"
        )
    done

    build_client_rootfs "$TESTDIR/rootfs" ./assertion.sh
    for hook in "${expected_hooks_run[@]}"; do
        echo "$hook" >> "$TESTDIR/rootfs/expected_hooks_run"
    done
    for hook in "${expected_hooks_not_run[@]}"; do
        echo "$hook" >> "$TESTDIR/rootfs/expected_hooks_not_run"
    done
    build_ext4_image "$TESTDIR/rootfs" "$TESTDIR"/root.img dracut

    test_dracut "${dracut_args[@]}"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
