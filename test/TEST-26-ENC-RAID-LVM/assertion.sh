#!/bin/sh

# required binaries: test

# Verify that dracut flagged .need_shutdown during boot. Without the flag,
# dracut-initramfs-restore exits early on shutdown, the initramfs is not
# pivoted to, and dm-shutdown.sh never runs leaving LUKS stacks
# (e.g. LVM-on-LUKS) busy and blocking poweroff
if [ ! -e /run/initramfs/.need_shutdown ]; then
    echo "/run/initramfs/.need_shutdown was not created during boot" >> /run/failed
fi
