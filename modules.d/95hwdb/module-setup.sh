#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

check() {
    return 255
}

# called by dracut
install() {
    local hwdb_bin

    # Follow the same priority as `systemd-hwdb`; `/etc` is the default
    # and `/usr/lib` an alternative location.
    hwdb_bin="${udevconfdir}"/hwdb.bin

    if [[ ! -r ${hwdb_bin} ]]; then
        hwdb_bin="${udevdir}"/hwdb.bin
    fi

    if [[ $hostonly ]]; then
        inst_multiple -H "${hwdb_bin}"
    else
        inst_multiple "${hwdb_bin}"
    fi
}
