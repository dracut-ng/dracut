#!/usr/bin/env bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="test skipcpio"

test_check() {
    if ! 3cpio --help 2> /dev/null | grep -q -- --create && ! command -v cpio &> /dev/null; then
        echo "Neither 3cpio >= 0.10 nor cpio are available."
        return 1
    fi

    require_binaries_for_test diff find
}

cpio_create() {
    if 3cpio --help 2> /dev/null | grep -q -- --create; then
        find . | sort | 3cpio --create
    else
        find . -print0 | sort -z | cpio -o --null -H newc
    fi
}

cpio_list_first() {
    local file="$1"
    if 3cpio --help 2> /dev/null | grep -q -- --parts; then
        3cpio --list --parts 1 "$file"
    else
        cpio --extract --quiet --list < "$file"
    fi
}

skipcpio_simple() {
    mkdir -p "$CPIO_TESTDIR/skipcpio_simple/first_archive"
    pushd "$CPIO_TESTDIR/skipcpio_simple/first_archive"

    for ((i = 0; i < 3; i++)); do
        echo "first archive file $i" >> ./"$i"
    done
    cpio_create > "$CPIO_TESTDIR/skipcpio_simple.cpio"
    popd

    mkdir -p "$CPIO_TESTDIR/skipcpio_simple/second_archive"
    pushd "$CPIO_TESTDIR/skipcpio_simple/second_archive"

    for ((i = 10; i < 13; i++)); do
        echo "second archive file $i" >> ./"$i"
    done

    cpio_create >> "$CPIO_TESTDIR/skipcpio_simple.cpio"
    popd

    cpio_list_first "$CPIO_TESTDIR/skipcpio_simple.cpio" \
        > "$CPIO_TESTDIR/skipcpio_simple.list"
    cat << EOF | diff - "$CPIO_TESTDIR/skipcpio_simple.list"
.
0
1
2
EOF

    if [ "$PKGLIBDIR" = "$basedir" ]; then
        skipcpio_path="${PKGLIBDIR}/src/skipcpio"
    else
        skipcpio_path="${PKGLIBDIR}"
    fi
    "$skipcpio_path"/skipcpio "$CPIO_TESTDIR/skipcpio_simple.cpio" \
        > "$CPIO_TESTDIR/skipped.cpio"
    cpio_list_first "$CPIO_TESTDIR/skipped.cpio" > "$CPIO_TESTDIR/skipcpio_simple.list"
    cat << EOF | diff - "$CPIO_TESTDIR/skipcpio_simple.list"
.
10
11
12
EOF

    DEBUG_SKIPCPIO=1 "$skipcpio_path"/skipcpio "$CPIO_TESTDIR/skipcpio_simple.cpio" \
        > /dev/null 2> "$CPIO_TESTDIR/debug.log"
    if [ ! -s "$CPIO_TESTDIR/debug.log" ]; then
        echo "Debug log file is missing or empty."
        return 1
    fi
    if ! grep -q "CPIO data and any trailing zeros end at position" "$CPIO_TESTDIR/debug.log"; then
        echo "Expected debug message not found in log."
        return 1
    fi

    truncate -s 1K "$CPIO_TESTDIR/empty.img"
    DEBUG_SKIPCPIO=1 "$skipcpio_path"/skipcpio "$CPIO_TESTDIR/empty.img" > /dev/null \
        2> "$CPIO_TESTDIR/debug.log"
    if [ ! -s "$CPIO_TESTDIR/debug.log" ]; then
        echo "Debug log file is missing or empty."
        return 1
    fi
    if ! grep -q "No CPIO header found." "$CPIO_TESTDIR/debug.log"; then
        echo "Expected debug message not found in log."
        return 1
    fi
}

test_run() {
    set -x
    set -e

    skipcpio_simple

    return 0
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
