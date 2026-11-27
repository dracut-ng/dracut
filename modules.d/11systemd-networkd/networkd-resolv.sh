#!/bin/sh

[ -r /run/systemd/netif/state ] || exit 0

command -v getargs > /dev/null || . /lib/dracut-lib.sh

mkdir -p /run/initramfs
for s in $(getargs nameserver) $(sed -n "s/^DNS=//p" /run/systemd/netif/state); do
    echo "nameserver $s"
done > /run/initramfs/resolv.conf.tmp
mv /run/initramfs/resolv.conf.tmp /run/initramfs/resolv.conf
