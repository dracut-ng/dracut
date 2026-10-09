#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

if [ "$(cat /proc/sys/crypto/fips_enabled 2> /dev/null)" != "1" ]; then
    :
elif ! [ -f /tmp/fipsdone ]; then
    . /sbin/fips.sh
    fips_info "fips-noboot: start"
    mount_boot
    do_fips || die "FIPS integrity test failed"
    fips_info "fips-noboot: done!"
fi
