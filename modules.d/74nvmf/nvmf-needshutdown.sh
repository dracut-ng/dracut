#!/bin/sh
# The controllers the pre-OS environment connected stay connected in the
# real root: nothing there disconnects them. Have the
# shutdown come back to the initramfs, which disconnects them after the
# root is unmounted (nvmf-shutdown.sh).

command -v need_shutdown > /dev/null || . /lib/dracut-lib.sh

for o in /run/nvme/registry/nvme*/owner; do
    [ -f "$o" ] || continue
    # nvme-cli leaves the entry of a removed controller in place
    n=${o%/owner}
    [ -d "/sys/class/nvme/${n##*/}" ] || continue
    case "$(cat "$o")" in
        pre-os | nbft)
            need_shutdown
            break
            ;;
    esac
done
