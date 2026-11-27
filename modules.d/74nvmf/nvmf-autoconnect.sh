#!/bin/sh
# shellcheck disable=SC2086 # $NVMF_OWNER: empty or one word
#
# Argument $1 is "settled", "online", or "timeout", indicating
# the queue from which the script is called.
# In the "timeout" case, try everything.
# Otherwise, try options according to the priorities below.
#
# "fc TRADDR HOST_TRADDR" connects the FC discovery controller of an
# nvmediscovery event (95-nvmf-initqueue.rules).

[ "$RD_DEBUG" != yes ] || set -x

# An nvme that follows the pre-OS model connects as the
# owner pre-os: it records the connections in /run/nvme/pre-os.conf.d for
# nvme-discoverd, which keeps them connected in the real root and never
# disconnects them, and connects them with ctrl_loss_tmo=-1. nvme-cli up
# to 3.2 would record pre-os as an unknown owner.
NVMF_OWNER=
if /usr/sbin/nvme connect-all --help 2>&1 | grep -q 'pre-os'; then
    NVMF_OWNER=--owner=pre-os
fi

if [ "$1" = fc ]; then
    exec /usr/sbin/nvme connect-all $NVMF_OWNER --transport=fc \
        --traddr="$2" --host-traddr="$3"
fi

# parse-nvmf-boot-connections.sh creates a "finished" script that
# waits for the file /tmp/nvmf.done.
# Make sure the file is created when this script has been called once.
trap 'echo ok >/tmp/nvmf.done' 0

if [ "$1" = timeout ]; then
    [ ! -f /sys/class/fc/fc_udev_device/nvme_discovery ] \
        || echo add > /sys/class/fc/fc_udev_device/nvme_discovery
    /usr/sbin/nvme connect-all $NVMF_OWNER
    exit 0
fi

NVMF_HOSTNQN_OK=
[ ! -f "/etc/nvme/hostnqn" ] || [ ! -f "/etc/nvme/hostid" ] || NVMF_HOSTNQN_OK=1

if [ -e /tmp/nvmf-fc-auto ] && [ "$NVMF_HOSTNQN_OK" ] \
    && [ -f /sys/class/fc/fc_udev_device/nvme_discovery ]; then
    # prio 1: cmdline override "rd.nvmf.discovery=fc,auto"
    echo add > /sys/class/fc/fc_udev_device/nvme_discovery
    exit 0
fi
if [ -e /tmp/valid_nbft_entry_found ]; then
    # prio 2: NBFT
    /usr/sbin/nvme connect-all $NVMF_OWNER --nbft
    exit 0
fi
NVMF_FABRICS_CONF=
[ ! -f /etc/nvme/nvme-fabrics.conf ] || NVMF_FABRICS_CONF=1
for f in /etc/nvme/nvme-fabrics.conf.d/*.conf; do
    [ ! -f "$f" ] || NVMF_FABRICS_CONF=1
done

# nvme-cli 3 resolves the identity of nvme-fabrics.conf itself, e.g. from [Host]
if [ "$NVMF_FABRICS_CONF" ] || { [ "$NVMF_HOSTNQN_OK" ] \
    && { [ -f /etc/nvme/discovery.conf ] || [ -f /etc/nvme/config.json ]; }; }; then
    # prio 3: configuration from initrd and/or kernel command line
    # We can get here even if "rd.nvmf.nonbft" was given, thus use --no-nbft
    /usr/sbin/nvme connect-all $NVMF_OWNER --no-nbft
    exit 0
fi
if [ "$NVMF_HOSTNQN_OK" ] \
    && [ -f /sys/class/fc/fc_udev_device/nvme_discovery ]; then
    # prio 4: no discovery entries, try NVMeoFC autoconnect
    echo add > /sys/class/fc/fc_udev_device/nvme_discovery
fi
exit 0
