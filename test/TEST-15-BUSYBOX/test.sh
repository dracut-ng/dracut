#!/usr/bin/env bash
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="busybox applets win over host binaries when busybox module is included"

test_check() {
    require_binaries_for_test busybox
}

test_setup() {
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
    local initrd="$TESTDIR/initramfs"

    test_dracut \
        --no-hostonly --no-kernel --drivers "" \
        --modules "base busybox" \
        "$initrd"

    # Check applets the base module would otherwise install from the host.
    # Each must resolve to busybox in the resulting initrd.
    check_applets_from_busybox "$initrd" ash cp ip ls mv mkdir sleep tr || ret=1

    # switch_root must NOT be a busybox symlink as the base module reinstalls
    # the host util-linux version on top of any symlink the busybox module left
    if lsinitrd "$initrd" | grep -E '^l.* switch_root -> .*busybox'; then
        echo "FAIL: switch_root is a busybox symlink, host version was not preserved" >&2
        ret=1
    fi

    # repeat the same test, but override the list of applets
    rm "$initrd"
    DRACUT_MODULE_BUSYBOX_LINKS="$(cat "${TESTDIR}/busybox.links")" \
        test_dracut \
        --no-hostonly --no-kernel --drivers "" \
        --modules "base busybox" \
        "$initrd"
    check_applets_from_busybox "$initrd" ash cp ip ls mv mkdir silly-serval sleep tr || ret=1

    return "$ret"
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
