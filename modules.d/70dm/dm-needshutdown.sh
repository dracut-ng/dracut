#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

for dm in /dev/dm-[0-9]*; do
    [ -b "$dm" ] || continue
    need_shutdown
    break
done
