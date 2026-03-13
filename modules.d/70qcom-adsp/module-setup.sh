#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# On Qualcomm sc8280xp and x1e laptops the kernel reboots the ADSP with new
# firmware because the BIOS loads ADSP firmware with limited functionality
# without sound or battery charge/status reading support.
#
# Unfortunately the ADSP also controls the TCPM (Type-C Port Manager) and
# rebooting the ADSP also resets the TCPM, causing any USB devices connected
# over Type-C ports to get disconnected as all devices on the USB bus are
# removed and re-enumerated.
#
# This breaks booting from USB-drives as the drive gets disconnected and
# re-enumerated as a new block device, leaving any filesystems mounted
# before the ADSP reset without any backing device.
#
# To workaround this, this module load the ADSP driver from a pre-udev hook
# so that the USB re-enumeration happens before the rootfs is mounted.

# called by dracut
check() {
    [ "$DRACUT_ARCH" = "aarch64" ] || return 1
    if [[ $hostonly_mode == "strict" ]]; then
        grep -q -E 'qcom,sc8280xp-adsp-pas|qcom,x1e80100-adsp-pas' \
            /sys/bus/platform/devices/*.remoteproc/modalias 2> /dev/null || return 1
    fi
    return 0
}

# called by dracut
installkernel() {
    instmods qcom_q6v5_pas
}

# called by dracut
install() {
    inst_multiple modprobe grep
    inst_hook pre-udev 30 "$moddir/qcom-adsp-pre-udev.sh"
}
