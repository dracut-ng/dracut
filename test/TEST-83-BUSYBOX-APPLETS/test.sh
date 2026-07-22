#!/usr/bin/env bash

set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="busybox applets win over host binaries when busybox module is included"

test_check() {
    if ! command -v busybox &> /dev/null; then
        echo "Test needs busybox on host... Skipping"
        return 1
    fi
}

test_run() {
    set -x
    local initrd="$TESTDIR/initramfs"

    test_dracut \
        --no-hostonly --no-kernel --drivers "" \
        --modules "base busybox" \
        "$initrd"

    # Applets the base module would otherwise install from the host. Each must
    # resolve to busybox in the resulting initrd. Match layout-agnostically:
    # the applet may live under bin/ or usr/bin/, and the symlink target may be
    # relative (e.g. bin/cp -> ../usr/bin/busybox on alpine) or just "busybox"
    local _applet ret=0
    local _listing
    _listing=$(lsinitrd "$initrd")
    for _applet in cp ls mv rm mkdir sleep tr; do
        if ! grep -qE "(^|/)$_applet -> ([^ ]*/)?busybox\$" <<< "$_listing"; then
            echo "FAIL: $_applet is not a busybox symlink in the initrd" >&2
            ret=1
        fi
    done

    # switch_root must NOT be a busybox symlink as the base module reinstalls
    # the host util-linux version on top of any symlink the busybox module left
    if grep -E '^l.* switch_root -> .*busybox' <<< "$_listing"; then
        echo "FAIL: switch_root is a busybox symlink, host version was not preserved" >&2
        ret=1
    fi

    return "$ret"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
