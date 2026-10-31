#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

if [ "$(cat /proc/sys/crypto/fips_enabled 2> /dev/null)" != "1" ]; then
    # Do nothing if not in FIPS mode
    return 0
fi

policyfile=/etc/crypto-policies/config
fipspolicyfile=/usr/share/crypto-policies/default-fips-config
backends=/etc/crypto-policies/back-ends
fipsbackends=/usr/share/crypto-policies/back-ends/FIPS

# When in FIPS mode, check the active crypto policy by reading the
# $root/etc/crypto-policies/config file. If it is not "FIPS", or does not start
# with "FIPS:", automatically switch to the FIPS policy by creating
# bind-mounts.

if ! [ -r "${NEWROOT}${policyfile}" ]; then
    # No crypto-policies configured, possibly not a system that uses
    # crypto-policies?
    return 0
fi

if ! [ -f "${NEWROOT}${fipspolicyfile}" ]; then
    # crypto-policies is too old to deal with automatic bind-mounting of the
    # FIPS policy over the normal policy, do not attempt to do the bind-mount.
    return 0
fi

policy=$(cat "${NEWROOT}${policyfile}")

# Remove the largest suffix pattern matching ":*" from the string (i.e., the
# complete list of active policy modules), then check for FIPS. This is part of
# POSIX sh (https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_06_02).
if [ "${policy%%:*}" = "FIPS" ]; then
    return 0
fi

# Current crypto policy is not FIPS or FIPS-based, but the system is in FIPS
# mode; this is an inconsistent configuration. Automatically bind-mount a FIPS
# configuration over this.
if ! mount -o bind,ro "${NEWROOT}${fipsbackends}" "${NEWROOT}${backends}"; then
    warn "Failed to bind-mount FIPS policy over ${backends} (the system is in FIPS mode, but the crypto-policy is not)."
    # If this bind-mount failed, don't attempt to do the other one to avoid
    # a system that seems to be in FIPS crypto-policy but actually is not.
    return 0
fi

mount -o bind,ro "${NEWROOT}${fipspolicyfile}" "${NEWROOT}${policyfile}" \
    || warn "Failed to bind-mount FIPS crypto-policy state file over ${policyfile} (the system is in FIPS mode, but the crypto-policy is not)."
