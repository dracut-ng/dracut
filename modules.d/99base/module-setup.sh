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

# called by dracut
install() {
    inst_multiple \
        chmod \
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
        less

    inst_binary "${dracutbasedir}/dracut-util" "/usr/bin/dracut-util"

    ln -s dracut-util "${initdir}/usr/bin/dracut-getarg"
    ln -s dracut-util "${initdir}/usr/bin/dracut-getargs"

    # fallback when shell-interpreter is not included
    [ ! -e "${initdir}/bin/sh" ] && inst_simple "${initdir}/bin/sh" "/bin/sh"

    # add common users in /etc/passwd, it will be used by nfs/ssh currently
    # use password for hostonly images to facilitate secure sulogin in emergency console
    [[ $hostonly ]] && pwshadow='x'
    grep '^root:' "$initdir/etc/passwd" > /dev/null 2>&1 || echo "root:$pwshadow:0:0::/root:/bin/sh" >> "$initdir/etc/passwd"
    grep '^nobody:' "$dracutsysrootdir"/etc/passwd >> "$initdir/etc/passwd"

    [[ $hostonly ]] && grep '^root:' "$dracutsysrootdir"/etc/shadow >> "$initdir/etc/shadow"

    # install our scripts and hooks
    inst_script "$moddir/loginit.sh" "/sbin/loginit"
    inst_script "$moddir/rdsosreport.sh" "/sbin/rdsosreport"

    [ -e "${initdir}/lib" ] || mkdir -m 0755 -p "${initdir}"/lib
    mkdir -m 0755 -p "${initdir}"/lib/dracut
    mkdir -m 0755 -p "${initdir}"/var/lib/dracut/hooks

    # symlink to old hooks location for compatibility
    ln_r /var/lib/dracut/hooks /lib/dracut/hooks

    mkdir -p "${initdir}"/tmp

    inst_simple "$moddir/dracut-lib.sh" "/lib/dracut-lib.sh"
    inst_simple "$moddir/dracut-dev-lib.sh" "/lib/dracut-dev-lib.sh"
    mkdir -p "${initdir}"/var

    if ! dracut_module_included "systemd"; then
        inst_multiple switch_root || dfatal "Failed to install switch_root"
        inst_script "$moddir/init.sh" "/init"
        inst_hook cmdline 10 "$moddir/parse-root-opts.sh"
    fi

    ln -fs /proc/self/mounts "$initdir/etc/mtab"
    if [[ $ro_mnt == yes ]]; then
        echo ro >> "${initdir}/etc/cmdline.d/base.conf"
    fi

    {
        echo "NAME=dracut"
        echo "ID=dracut"
        echo "VERSION_ID=\"$DRACUT_VERSION\""
        echo 'ANSI_COLOR="0;34"'
    } > "${initdir}"/usr/lib/initrd-release

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
                export hookdir=/lib/dracut/hooks

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
                        /dev/?*) wait_for_dev "$_pdev" 0 ;;
                        *) ;;
                    esac
                done

                for _dev in "${user_devs[@]}"; do

                    case "$_dev" in
                        /dev/?*) wait_for_dev "$_dev" 0 ;;
                        *) ;;
                    esac

                    _pdev=$(get_persistent_dev "$_dev")
                    [[ $_dev == "$_pdev" ]] && continue

                    case "$_pdev" in
                        /dev/?*) wait_for_dev "$_pdev" 0 ;;
                        *) ;;
                    esac
                done
            )
        fi
    fi
}
