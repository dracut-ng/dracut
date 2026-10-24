#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

if [ "$(cat /proc/sys/crypto/fips_enabled 2> /dev/null)" != "1" ]; then
    if fipsmode=$(getarg fips) && [ "$fipsmode" != "0" ]; then
        warn "fips= asks for FIPS mode, but the kernel is not in FIPS mode; skipping FIPS checks"
    fi
else
    . /sbin/fips.sh
    fips_info "fips-load-crypto: start"
    fips_load_crypto || die "FIPS integrity test failed"
    fips_info "fips-load-crypto: done!"
fi
