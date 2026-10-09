#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

if [ "$(cat /proc/sys/crypto/fips_enabled 2> /dev/null)" != "1" ]; then
    :
elif getarg boot= > /dev/null; then
    . /sbin/fips.sh
    fips_info "fips-boot: start"
    if mount_boot; then
        do_fips || die "FIPS integrity test failed"
    fi
    fips_info "fips-boot: done!"
fi
