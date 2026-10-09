#!/bin/sh
set -eu

# required binaries: grep ip

# The client booted with several NICs, each using a different ip= autoconf mode
# against a dnsmasq server serving both DHCPv4 and stateful DHCPv6. Verify each
# interface ended up with exactly the address families its mode implies. Any
# mismatch is appended to /run/failed, which test-init.sh treats as a failure.

fail() {
    echo "FAILED: $1" >> /run/failed
    ip -o addr show >> /run/failed 2>&1 || true
}

has_ipv4() {
    ip -o -4 addr show dev "$1" scope global 2> /dev/null | grep -q 'inet '
}

# A DHCPv6 address has a short host part (e.g. 2001:db8:51::100/128), unlike a
# SLAAC EUI-64 address, so matching it specifically proves the DHCPv6 half ran.
has_dhcpv6() {
    ip -o -6 addr show dev "$1" scope global 2> /dev/null \
        | grep -Eq "inet6 $2::[0-9a-f]{1,4}/"
}

# A SLAAC address lives in the link's /64 prefix but (unlike a DHCPv6 address)
# has a full 64-bit host part. Since the SLAAC links run no DHCPv6 server, any
# global address in the prefix must have come from SLAAC.
has_slaac() {
    ip -o -6 addr show dev "$1" scope global 2> /dev/null | grep -q "inet6 $2:"
}

# Count global IPv6 addresses on an interface. Used to confirm an interface
# obtained both a DHCPv6 and a SLAAC address (i.e. two of them).
count_global_ipv6() {
    ip -o -6 addr show dev "$1" scope global 2> /dev/null | grep -c 'inet6 ' || true
}

# netdhcp: ip=dhcp -> IPv4 only, and specifically no DHCPv6 address. Matching a
# DHCPv6-style address (rather than any global IPv6) means an incidental SLAAC
# address would be ignored, while a stray dhclient -6 run would still be caught.
has_ipv4 netdhcp || fail "netdhcp (dhcp): missing IPv4 address"
if has_dhcpv6 netdhcp 2001:db8:51; then
    fail "netdhcp (dhcp): unexpected DHCPv6 address"
fi

# netdhcp6: ip=dhcp6 -> DHCPv6 IPv6 only, no IPv4.
has_dhcpv6 netdhcp6 2001:db8:52 || fail "netdhcp6 (dhcp6): missing DHCPv6 address"
if has_ipv4 netdhcp6; then
    fail "netdhcp6 (dhcp6): unexpected IPv4 address"
fi

# netany: ip=any -> IPv4, DHCPv6 and SLAAC. The .53 link offers stateful DHCPv6
# and SLAAC, so a correct dual-stack "any" (do_dhcp 4 + do_dhcp 6 + do_ipv6auto)
# ends up with an IPv4 address plus two global IPv6 addresses: one DHCPv6 (short
# host part) and one SLAAC.
has_ipv4 netany || fail "netany (any): missing IPv4 address"
has_dhcpv6 netany 2001:db8:53 || fail "netany (any): missing DHCPv6 address"
[ "$(count_global_ipv6 netany)" -ge 2 ] \
    || fail "netany (any): expected both a DHCPv6 and a SLAAC address"

# netauto6: ip=auto6 -> SLAAC IPv6 only, no IPv4.
has_slaac netauto6 2001:db8:54 || fail "netauto6 (auto6): missing SLAAC address"
if has_ipv4 netauto6; then
    fail "netauto6 (auto6): unexpected IPv4 address"
fi

# neteither6: ip=either6 -> SLAAC IPv6 (auto6 path succeeds), no IPv4.
has_slaac neteither6 2001:db8:55 || fail "neteither6 (either6): missing SLAAC address"
if has_ipv4 neteither6; then
    fail "neteither6 (either6): unexpected IPv4 address"
fi
