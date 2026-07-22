#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

# The legacy crypt path calls need_shutdown from cryptroot-ask.sh, but
# systemd-cryptsetup does not, so ensure the flag is set here whenever a LUKS
# mapping is active. Otherwise dracut-initramfs-restore exits early and
# dm-shutdown.sh never runs, leaving LUKS stacks busy at shutdown
for _dev in /sys/block/dm-*; do
    [ -e "${_dev}/dm/uuid" ] || continue
    case $(cat "${_dev}/dm/uuid") in
        CRYPT-LUKS*)
            need_shutdown
            break
            ;;
    esac
done
unset _dev
