#!/bin/bash

check() {
    require_binaries ip awk grep || return 1
    return 255
}

depends() {
    echo base initqueue
    return 0
}

install() {
    inst_script "$moddir/netroot.sh" "/sbin/netroot"
    inst_simple "$moddir/net-lib.sh" "/lib/net-lib.sh"
    inst_hook pre-udev 50 "$moddir/ifname-genrules.sh"
    inst_hook cmdline 91 "$moddir/dhcp-root.sh"
    inst_multiple ip awk grep
    inst_multiple -o arping arping2
}
