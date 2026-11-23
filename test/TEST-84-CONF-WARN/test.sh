#!/usr/bin/env bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

# shellcheck disable=SC2034
TEST_DESCRIPTION="warn about missing whitespace around double-quoted += values"

test_check() {
    require_binaries_for_test grep sed
}

# Load check_conf_file() from dracut.sh without running dracut so the test
# only exercises the configuration file check and does not build an image.
load_check_conf_file() {
    # shellcheck disable=SC1090
    eval "$(sed -n '/^check_conf_file()/,/^}/p' "$basedir"/dracut.sh)"
}

# assert_warns <config line>: the line must be reported
assert_warns() {
    printf '%s\n' "$1" > "$TESTDIR"/test.conf
    if ! check_conf_file "$TESTDIR"/test.conf 2>&1 \
        | grep -q "should have surrounding white spaces"; then
        echo "E: expected a warning for: $1" >&2
        return 1
    fi
}

# assert_silent <config line>: the line must not be reported
assert_silent() {
    printf '%s\n' "$1" > "$TESTDIR"/test.conf
    if check_conf_file "$TESTDIR"/test.conf 2>&1 \
        | grep -q "should have surrounding white spaces"; then
        echo "E: unexpected warning for: $1" >&2
        return 1
    fi
}

test_run() {
    load_check_conf_file

    # Missing whitespace is reported for either side.
    assert_warns 'kernel_cmdline+="foo"'
    assert_warns 'kernel_cmdline+="foo "'
    assert_warns 'kernel_cmdline+=" foo"'
    assert_warns 'kernel_cmdline+=" foo \"bar\""'

    # Properly padded values are not reported.
    assert_silent 'kernel_cmdline+=" foo "'
    assert_silent $'kernel_cmdline+="\tfoo\t"'
    assert_silent 'kernel_cmdline+=""'
    assert_silent 'kernel_cmdline+=" foo \"bar\" "'
    assert_silent "kernel_cmdline+=' dyndbg=\"func fw_log_firmware_info +p\" '"
    assert_silent '#kernel_cmdline+="foo"'
}

# shellcheck disable=SC1090
. "$testdir"/test-functions
