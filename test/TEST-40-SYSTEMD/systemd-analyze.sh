#!/usr/bin/env bash

for i in \
    sysinit.target \
    basic.target \
    initrd-fs.target \
    initrd.target \
    initrd-switch-root.target \
    emergency.target \
    shutdown.target; do
    if ! systemd-analyze --man=no verify "$i"; then
        warn "systemd-analyze.sh pre-pivot check 'systemd-analyze --man=no verify $i' failed. Failing test."
        poweroff
    fi
done
