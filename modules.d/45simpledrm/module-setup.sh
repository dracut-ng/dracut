#!/bin/bash

# called by dracut
check() {
    return 255
}

# called by dracut
installkernel() {
    # Include simple DRM driver
    hostonly='' instmods simpledrm =drivers/gpu/drm/panel

    if [[ $hostonly_mode == "strict" ]]; then
        # if there is a privacy screen then its driver must be loaded before the
        # kms driver will bind, otherwise its probe() will return -EPROBE_DEFER
        # note privacy screens always register, even with e.g. nokmsboot
        for i in /sys/class/drm/privacy_screen-*/device/driver/module; do
            [[ -L $i ]] || continue
            modlink=$(readlink "$i")
            modname="${modlink##*/}"
            hostonly='' instmods "$modname"
        done
    else
        # include privacy screen providers (see above comment)
        # atm all providers live under drivers/platform/x86
        dracut_instmods -o -s "drm_privacy_screen_register" "=drivers/platform/x86"
    fi
}
