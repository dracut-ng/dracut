#!/bin/bash

# called by dracut
depends() {
    echo base
    return 0
}

# called by dracut
install() {
    local _d _b _systemctl
    inst_multiple umount losetup stat sleep timeout
    inst_multiple -o kexec

    # poweroff/reboot/halt are usually symlinks to systemctl, but some
    # distributions ship them in a separate package (e.g. systemd-sysvcompat
    # on Arch Linux). shutdown.sh only calls them with "-f", in which case
    # systemctl invokes reboot(2) directly without talking to PID 1, so fall
    # back to symlinking systemctl if they are missing.
    for _b in poweroff reboot halt; do
        if find_binary "$_b" > /dev/null; then
            inst_multiple "$_b"
        elif _systemctl=$(find_binary systemctl); then
            inst_multiple systemctl
            ln_r "$_systemctl" "/usr/sbin/$_b"
        else
            dfatal "Could not find '$_b' or systemctl to provide it"
            return 1
        fi
    done

    inst "$moddir/shutdown.sh" "$prefix/shutdown"
    mkdir -m 0755 -p "${initdir}"/var/lib/dracut/hooks

    for _d in $hookdirs shutdown shutdown-emergency; do
        mkdir -m 0755 -p "${initdir}"/var/lib/dracut/hooks/"$_d"
    done
}
