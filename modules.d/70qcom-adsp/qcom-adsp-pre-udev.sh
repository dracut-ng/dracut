#!/bin/sh

# Blacklist the Qualcomm Hexagon DSP remoteproc driver so that udev does not
# load it early in the initrd, which may not include the DSP firmware. The
# driver does not attempt to reload the firmware later. Instead, the driver is
# loaded and the firmware is downloaded after the rootfs has been mounted.
mkdir -p /run/modprobe.d
echo "blacklist qcom_q6v5_pas" > /run/modprobe.d/70qcom-adsp.conf

# On sc8280xp and x1e, loading the driver reboots the ADSP, which also resets
# the TCPM and re-enumerates all USB devices connected over Type-C ports.
# Load the driver now, before any filesystems are mounted, so that a rootfs on
# a USB drive is not lost.
if grep -q -E 'qcom,sc8280xp-adsp-pas|qcom,x1e80100-adsp-pas' \
    /sys/bus/platform/devices/*.remoteproc/modalias 2> /dev/null; then
    modprobe qcom_q6v5_pas
fi
