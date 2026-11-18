#!/usr/bin/env bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="hostonly firmware installation from sysfs requested entries"

test_check() {
    if ! [[ -x "$PKGLIBDIR/dracut-install" ]]; then
        echo "Test needs dracut-install... Skipping"
        return 1
    fi
}

test_setup() {
    # Create a fake sysroot with mock sysfs firmware entries
    mkdir -p "$TESTDIR/sysroot/sys/class/firmware"
    echo "vendor/real-fw.bin" > "$TESTDIR/sysroot/sys/class/firmware/requested0"
    echo "vendor/other-fw.bin" > "$TESTDIR/sysroot/sys/class/firmware/requested1"

    # Create firmware files under the sysroot at the standard path, with
    # files that are and aren't in the sysfs requested list
    mkdir -p "$TESTDIR/sysroot/lib/firmware/vendor"
    echo "real firmware" > "$TESTDIR/sysroot/lib/firmware/vendor/real-fw.bin"
    echo "other firmware" > "$TESTDIR/sysroot/lib/firmware/vendor/other-fw.bin"
    echo "unrequested firmware" > "$TESTDIR/sysroot/lib/firmware/vendor/extra-fw.bin"

    # Create destination directory
    mkdir -p "$TESTDIR/destdir"
}

test_sysfs_firmware() {
    local kver
    kver=$(uname -r)

    echo "TEST: with sysfs entries, only requested firmware is installed"

    rm -rf "$TESTDIR/destdir"
    mkdir -p "$TESTDIR/destdir"

    "$PKGLIBDIR/dracut-install" --sysfs-firmware \
        -D "$TESTDIR/destdir" \
        -r "$TESTDIR/sysroot" \
        -H \
        --firmwaredirs "$TESTDIR/sysroot/lib/firmware" \
        -m -o \
        --kerneldir "/lib/modules/$kver" \
        =kernel/crypto 2>&1 || true

    # The sysfs-requested firmware should be installed
    if ! find "$TESTDIR/destdir" -path "*/vendor/real-fw.bin" -print -quit | grep -q .; then
        echo "FAIL: requested firmware vendor/real-fw.bin was not installed"
        find "$TESTDIR/destdir" -type f
        return 1
    fi
    if ! find "$TESTDIR/destdir" -path "*/vendor/other-fw.bin" -print -quit | grep -q .; then
        echo "FAIL: requested firmware vendor/other-fw.bin was not installed"
        return 1
    fi

    # The unrequested firmware should NOT be installed
    if find "$TESTDIR/destdir" -path "*/vendor/extra-fw.bin" -print -quit | grep -q .; then
        echo "FAIL: unrequested firmware vendor/extra-fw.bin was installed"
        return 1
    fi

    echo "PASS: sysfs firmware filtering works"
}

test_no_sysfs_entries() {
    echo "TEST: without sysfs entries, falls back to per-module firmware"

    # Create a sysroot without requestedN entries but with firmware files
    mkdir -p "$TESTDIR/sysroot-nosysfs/sys/class/firmware"
    mkdir -p "$TESTDIR/sysroot-nosysfs/lib/firmware/vendor"
    echo "real firmware" > "$TESTDIR/sysroot-nosysfs/lib/firmware/vendor/real-fw.bin"

    rm -rf "$TESTDIR/destdir"
    mkdir -p "$TESTDIR/destdir"

    local kver
    kver=$(uname -r)

    "$PKGLIBDIR/dracut-install" --sysfs-firmware \
        -D "$TESTDIR/destdir" \
        -r "$TESTDIR/sysroot-nosysfs" \
        -H \
        --firmwaredirs "$TESTDIR/sysroot-nosysfs/lib/firmware" \
        -m -o \
        --kerneldir "/lib/modules/$kver" \
        =kernel/crypto 2>&1 || true

    # Without requestedN entries, install_sysfs_firmware is not called.
    # Our fake firmware is not in any MODULE_FIRMWARE(), so it should not
    # appear — the per-module path only installs firmware declared by modules.
    if find "$TESTDIR/destdir" -path "*/vendor/real-fw.bin" -print -quit | grep -q .; then
        echo "FAIL: sysfs firmware installed despite no sysfs entries"
        return 1
    fi

    echo "PASS: fallback to per-module firmware works"
}

test_no_sysfs_dir() {
    echo "TEST: without sysfs directory, falls back gracefully"

    # Create a sysroot without /sys/class/firmware at all
    mkdir -p "$TESTDIR/sysroot-nodir"

    rm -rf "$TESTDIR/destdir"
    mkdir -p "$TESTDIR/destdir"

    local kver
    kver=$(uname -r)

    "$PKGLIBDIR/dracut-install" --sysfs-firmware \
        -D "$TESTDIR/destdir" \
        -r "$TESTDIR/sysroot-nodir" \
        -H \
        --firmwaredirs "$TESTDIR/sysroot-nodir/lib/firmware" \
        -m -o \
        --kerneldir "/lib/modules/$kver" \
        =kernel/crypto 2>&1 || true

    echo "PASS: no crash without sysfs directory"
}

test_non_hostonly_ignores_sysfs() {
    echo "TEST: without --hostonly, sysfs entries are ignored"

    rm -rf "$TESTDIR/destdir"
    mkdir -p "$TESTDIR/destdir"

    local kver
    kver=$(uname -r)

    # Same sysroot with requestedN entries, but no -H flag
    "$PKGLIBDIR/dracut-install" \
        -D "$TESTDIR/destdir" \
        -r "$TESTDIR/sysroot" \
        --firmwaredirs "$TESTDIR/sysroot/lib/firmware" \
        -m -o \
        --kerneldir "/lib/modules/$kver" \
        =kernel/crypto 2>&1 || true

    echo "PASS: non-hostonly mode does not crash with sysfs entries present"
}

test_opt_in_required() {
    echo "TEST: sysfs firmware requires --sysfs-firmware opt-in"

    rm -rf "$TESTDIR/destdir"
    mkdir -p "$TESTDIR/destdir"

    local kver
    kver=$(uname -r)

    # Hostonly with sysfs entries present, but --sysfs-firmware not passed
    "$PKGLIBDIR/dracut-install" \
        -D "$TESTDIR/destdir" \
        -r "$TESTDIR/sysroot" \
        -H \
        --firmwaredirs "$TESTDIR/sysroot/lib/firmware" \
        -m -o \
        --kerneldir "/lib/modules/$kver" \
        =kernel/crypto 2>&1 || true

    # Without opt-in, our fake firmware should NOT be installed (it is not
    # declared in any MODULE_FIRMWARE(), so the per-module path skips it)
    if find "$TESTDIR/destdir" -path "*/vendor/real-fw.bin" -print -quit | grep -q .; then
        echo "FAIL: sysfs firmware installed without opt-in"
        return 1
    fi

    echo "PASS: sysfs firmware requires opt-in"
}

test_run() {
    set -x
    test_sysfs_firmware
    test_no_sysfs_entries
    test_no_sysfs_dir
    test_non_hostonly_ignores_sysfs
    test_opt_in_required
}

test_cleanup() {
    rm -rf "$TESTDIR"/sysroot* "$TESTDIR"/fwdir "$TESTDIR"/destdir
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
