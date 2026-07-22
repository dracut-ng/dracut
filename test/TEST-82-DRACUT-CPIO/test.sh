#!/usr/bin/env bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="kernel cpio extraction tests for dracut-cpio"
# see dracut-cpio source for unit tests

test_check() {
    if ! [[ -x "$PKGLIBDIR/dracut-cpio" ]]; then
        echo "Test needs dracut-cpio... Skipping"
        return 1
    fi
}

test_dracut_cpio() {
    local tdir="${CPIO_TESTDIR}/${1}"
    shift
    # --enhanced-cpio tells dracut to use dracut-cpio instead of GNU cpio
    local dracut_cpio_params=("--enhanced-cpio" "$@")
    echo "SUBTEST: ${dracut_cpio_params[*]}"

    mkdir -p "$tdir"

    cat > "$tdir/init.sh" << EOF
echo "Image with ${dracut_cpio_params[*]} booted successfully"
poweroff -f
EOF

    test_dracut \
        --no-kernel --drivers "" \
        --add-confdir "test" \
        "${dracut_cpio_params[@]}" \
        --include "$tdir/init.sh" /usr/lib/dracut/hooks/emergency/00-init.sh \
        --install "poweroff"

    "$testdir"/run-qemu \
        -daemonize -pidfile "$tdir/vm.pid" \
        -serial "file:$tdir/console.out" \
        -append "panic=1 oops=panic softlockup_panic=1 rd.shell=1" \
        -initrd "$TESTDIR"/initramfs.testing

    timeout=120
    while [[ -f $tdir/vm.pid ]] \
        && ps -p "$(head -n1 "$tdir/vm.pid")" > /dev/null; do
        echo "$timeout - awaiting VM shutdown"
        sleep 1
        [[ $((timeout--)) -gt 0 ]]
    done

    cat "$tdir/console.out"
    grep -q "Image with ${dracut_cpio_params[*]} booted successfully" \
        "$tdir/console.out"
    rm "$TESTDIR"/initramfs.testing
}

test_run() {
    # dracut-cpio is typically used with compression and strip disabled, to
    # increase the chance of (reflink) extent sharing.
    test_dracut_cpio "simple" "--no-compress" "--nostrip"
    # dracut-cpio should still work fine with compression and stripping enabled
    test_dracut_cpio "compress" "--gzip" "--nostrip"
    test_dracut_cpio "strip" "--gzip" "--strip"
}

test_setup() {
    CPIO_TESTDIR=$(mktemp --directory -p "$TESTDIR" cpio-test.XXXXXXXXXX)
    export CPIO_TESTDIR
    return 0
}

test_cleanup() {
    [ -d "${CPIO_TESTDIR-}" ] && rm -rf "$CPIO_TESTDIR"
    return 0
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
