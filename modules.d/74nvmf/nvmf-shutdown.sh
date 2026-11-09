#!/bin/sh
# In the shutdown initramfs, after the root is unmounted: disconnect the
# controllers the pre-OS environment connected (owner pre-os, or nbft as
# nvme-cli up to 3.2 records it). The OS environment never disconnects
# them; without this, the power-off ends the connections
# and the target waits for the keep-alive timeout. shutdown.sh moved the
# old /sys and /run to /oldsys.

for sys in /oldsys/sys /sys; do
    [ -d "$sys/class/nvme" ] && break
done
for run in /oldsys/run /run; do
    [ -d "$run/nvme/registry" ] && break
done

for c in "$sys"/class/nvme/nvme*; do
    [ -e "$c/delete_controller" ] || continue
    n=${c##*/}
    case "$(cat "$run/nvme/registry/$n/owner" 2> /dev/null)" in
        pre-os | nbft) ;;
        *) continue ;;
    esac
    echo "nvmf: disconnecting $n of the pre-OS environment"
    echo 1 > "$c/delete_controller"
done
# A failed disconnect is not retried: the power-off ends it anyway.
:
