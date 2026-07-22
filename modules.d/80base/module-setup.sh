#!/bin/bash

# called by dracut
depends() {
    local deps
    deps="udev-rules"

    if [[ $hostonly_cmdline == "yes" ]]; then
        if [[ -n ${host_devs[*]} ]] || [[ -n ${user_devs[*]} ]]; then
            deps+=" initqueue"
        fi
    fi

    echo "$deps"
    return 0
}

# The busybox dracut module runs before this module and lays down its applet
# symlinks. inst_multiple calls for those names then no-op because the
# destinations already exist
#
# Exception: switch_root is preferred from the host (util-linux) over the
# busybox applet, so the inst_multiple switch_root call below first removes any
# busybox applet symlink the busybox dracut module may have left in place

# This dracut module needs to be ordered after the systemd-sysusers dracut
# module so the root password is set for the emergency console in host-only
# mode

# called by dracut
install() {
    inst_multiple \
        cp \
        dmesg \
        flock \
        ln \
        ls \
        mkdir \
        mkfifo \
        mknod \
        modprobe \
        mount \
        mv \
        readlink \
        rm \
        rmmod \
        sed \
        setsid \
        sleep \
        tr \
        umount

    inst_multiple -o \
        chown \
        findmnt \
        kmod \
        less \
        halt \
        poweroff \
        reboot \
        sysctl

    inst_binary "${dracutbasedir}/dracut-util" "/usr/bin/dracut-util"

    ln -s dracut-util "${initdir}/usr/bin/dracut-getarg"
    ln -s dracut-util "${initdir}/usr/bin/dracut-getargs"

    # fallback when shell-interpreter is not included
    [ ! -e "${initdir}/bin/sh" ] && inst_simple "${initdir}/bin/sh" "/bin/sh"

    # add common users in /etc/passwd, it will be used by nfs/ssh currently
    # use password for hostonly images to facilitate secure sulogin in emergency console
    [[ $hostonly ]] && pwshadow='x'
    grep -qs '^root:' "$initdir/etc/passwd" || echo "root:$pwshadow:0:0::/root:/bin/sh" >> "$initdir/etc/passwd"

    if [[ $hostonly ]]; then
        # check if other dracut modules already created an entry for root in /etc/shadow
        if grep -qs '^root:' "$initdir/etc/shadow"; then
            grep -v '^root:' "$initdir/etc/shadow" > "$initdir/etc/shadow-"
            mv "$initdir/etc/shadow-" "$initdir/etc/shadow"
        fi
        # replace root password in the existing entry in etc/shadow
        # root password from host takes precedence over root password set by systemd-sysuser in hostonly mode
        # create a new entry for root in /etc/shadow
        grep '^root:' "${dracutsysrootdir-}"/etc/shadow >> "$initdir/etc/shadow"
    fi

    # install our scripts and hooks
    inst_script "$moddir/loginit.sh" "/sbin/loginit"
    inst_script "$moddir/rdsosreport.sh" "/sbin/rdsosreport"

    [ -e "${initdir}/lib" ] || mkdir -m 0755 -p "${initdir}"/lib
    mkdir -m 0755 -p "${initdir}"/lib/dracut
    mkdir -m 0755 -p "${initdir}"/var/lib/dracut/hooks

    mkdir -p "${initdir}"/tmp

    inst_simple "$moddir/dracut-lib.sh" "/lib/dracut-lib.sh"
    inst_simple "$moddir/dracut-dev-lib.sh" "/lib/dracut-dev-lib.sh"
    mkdir -p "${initdir}"/var

    [[ -d /lib/modprobe.d ]] && inst_multiple -o "/lib/modprobe.d/*.conf"
    [[ -d /usr/lib/modprobe.d ]] && inst_multiple -o "/usr/lib/modprobe.d/*.conf"
    [[ $hostonly ]] && inst_multiple -H -o /etc/modprobe.d/*.conf /etc/modprobe.conf

    inst_simple "$moddir/insmodpost.sh" /sbin/insmodpost.sh

    if ! dracut_module_included "systemd"; then
        # Prefer the host's util-linux switch_root over the busybox
        # applet. When the busybox dracut module is included it runs first and
        # may have symlinked switch_root to its applet. Drop that symlink so
        # the host binary is installed instead
        if dracut_module_included "busybox"; then
            local _sr
            _sr=$(find_binary switch_root)
            [[ -n $_sr && -L ${initdir}${_sr} ]] && rm -f "${initdir}${_sr}"
        fi
        inst_multiple switch_root || dfatal "Failed to install switch_root"
        inst_script "$moddir/init.sh" "/init"
        inst_hook cmdline 01 "$moddir/parse-kernel.sh"
        inst_hook cmdline 10 "$moddir/parse-root-opts.sh"

        {
            echo "NAME=dracut"
            echo "ID=dracut"
            echo "VERSION_ID=\"$DRACUT_VERSION\""
            echo 'ANSI_COLOR="0;34"'
        } > "${initdir}"/usr/lib/initrd-release
    fi

    ln -fs /proc/self/mounts "$initdir/etc/mtab"
    if [[ $ro_mnt == yes ]]; then
        echo ro >> "${initdir}/etc/cmdline.d/20-base.conf"
    fi

    echo "dracut-$DRACUT_VERSION" > "$initdir/lib/dracut/dracut-$DRACUT_VERSION"

    ## save host_devs which we need bring up
    if [[ $hostonly_cmdline == "yes" ]]; then
        if [[ -n ${host_devs[*]} ]] || [[ -n ${user_devs[*]} ]]; then
            dracut_need_initqueue
        fi
        if [[ -f $initdir/lib/dracut/need-initqueue ]] || ! dracut_module_included "systemd"; then
            (
                if dracut_module_included "systemd"; then
                    export DRACUT_SYSTEMD=1
                fi
                export PREFIX="$initdir"
                export hookdir=/var/lib/dracut/hooks

                # shellcheck source=dracut-dev-lib.sh
                . "$moddir/dracut-dev-lib.sh"

                for _dev in "${host_devs[@]}"; do
                    for _dev2 in "${root_devs[@]}"; do
                        [[ $_dev == "$_dev2" ]] && continue 2
                    done

                    # We only actually wait for real devs - swap is only needed
                    # for resume and udev rules generated when parsing resume=
                    # argument take care of the waiting for us
                    for _dev2 in "${swap_devs[@]}"; do
                        [[ $_dev == "$_dev2" ]] && continue 2
                    done

                    _pdev=$(get_persistent_dev "$_dev")

                    case "$_pdev" in
                        /dev/?*) wait_for_dev "$_pdev" "infinity" ;;
                        *) ;;
                    esac
                done

                for _dev in "${user_devs[@]}"; do

                    case "$_dev" in
                        /dev/?*) wait_for_dev "$_dev" "infinity" ;;
                        *) ;;
                    esac

                    _pdev=$(get_persistent_dev "$_dev")
                    [[ $_dev == "$_pdev" ]] && continue

                    case "$_pdev" in
                        /dev/?*) wait_for_dev "$_pdev" "infinity" ;;
                        *) ;;
                    esac
                done
            )
        fi
    fi
}
