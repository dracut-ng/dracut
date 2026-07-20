#!/bin/bash

# called by dracut
check() {
    require_binaries sed grep NetworkManager || return 1

    # do not add this module by default
    return 255
}

# called by dracut
depends() {
    echo net-lib kernel-network-modules initqueue
    if dracut_module_included systemd; then
        echo dbus
    fi
    return 0
}

# called by dracut
installkernel() {
    hostonly='' instmods nf_tables nfnetlink nft_fwd_netdev
}

# called by dracut
install() {
    local _nm_version

    _nm_version=${NM_VERSION:-$(NetworkManager --version)}

    # We don't need `ip` but having it is *really* useful for people debugging
    # in an emergency shell.
    inst_multiple ip sed grep

    inst NetworkManager
    inst_multiple -o /usr/{lib,libexec}/nm-initrd-generator
    inst_multiple -o /usr/{lib,libexec}/nm-daemon-helper
    inst_multiple -o teamd dhclient nft
    inst_hook cmdline 99 "$moddir/nm-config.sh"
    if dracut_module_included "systemd"; then

        inst "$dbussystem"/org.freedesktop.NetworkManager.conf
        inst_multiple nmcli nm-online

        # teaming support under systemd+dbus
        inst_multiple -o \
            "$dbussystem"/teamd.conf

        if [[ $hostonly ]]; then
            inst_multiple -H -o \
                "$dbussystemconfdir"/teamd.conf
        fi

        # Install a configuration snippet to prevent the automatic creation of
        # "Wired connection #" DHCP connections for Ethernet interfaces
        inst_simple "$moddir"/initrd-no-auto-default.conf /usr/lib/NetworkManager/conf.d/

        # Install systemd service units
        if [[ -e "$systemdsystemunitdir"/NetworkManager-config-initrd.service ]]; then
            # NetworkManager-1.54 provides its own initrd services
            inst_multiple -o \
                "$systemdsystemunitdir"/NetworkManager-config-initrd.service \
                "$systemdsystemunitdir"/NetworkManager-initrd.service \
                "$systemdsystemunitdir"/NetworkManager-wait-online-initrd.service

            # dracut specific dropins to override upstream systemd services
            inst_simple "$moddir/NetworkManager-config-initrd-dracut.conf" \
                "$systemdsystemunitdir/NetworkManager-config-initrd.service.d/NetworkManager-config-initrd-dracut.conf"
            inst_simple "$moddir/NetworkManager-wait-online-initrd-dracut.conf" \
                "$systemdsystemunitdir/NetworkManager-wait-online-initrd.service.d/NetworkManager-wait-online-initrd-dracut.conf"

            # NetworkManager-1.56 provides a systemd generator to install initrd
            # services, so they no longer have an "[Install]" section.
            if [[ -e "$systemdutildir"/system-generators/nm-initrd-generator.sh ]]; then
                inst "$systemdutildir"/system-generators/nm-initrd-generator.sh
            else
                $SYSTEMCTL -q --root "$initdir" enable NetworkManager-initrd.service
            fi
        else
            #TODO: remove custom systemd services when NetworkManager-1.56 is the minimum supported version
            inst_simple "$moddir"/nm-initrd.service "$systemdsystemunitdir"/nm-initrd.service
            inst_simple "$moddir"/nm-wait-online-initrd.service "$systemdsystemunitdir"/nm-wait-online-initrd.service

            $SYSTEMCTL -q --root "$initdir" enable nm-initrd.service
        fi

        # Adding default link and (if exists) 98-default-mac-none.link
        inst_multiple -o \
            "${systemdnetwork}/99-default.link" \
            "${systemdnetwork}/98-default-mac-none.link"
        [[ $hostonly ]] && inst_multiple -H -o "${systemdnetworkconfdir}/*.link"
    fi

    inst_hook initqueue/settled 99 "$moddir/nm-run.sh"

    inst_rules 85-nm-unmanaged.rules
    inst_libdir_dir "NetworkManager/$_nm_version"
    inst_libdir_file "NetworkManager/$_nm_version/libnm-device-plugin-team.so"
    inst_simple "$moddir/nm-lib.sh" "/lib/nm-lib.sh"

    if [[ -x "$initdir/usr/sbin/dhclient" ]]; then
        inst_multiple -o /usr/{lib,libexec}/nm-dhcp-helper
    elif ! [[ -e "$initdir/etc/machine-id" ]]; then
        # The internal DHCP client silently fails if we
        # have no machine-id
        local UUID
        UUID=$(< /proc/sys/kernel/random/uuid)
        echo "${UUID//-/}" > "$initdir/etc/machine-id"
    fi

    inst_libdir_file {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libnss_dns.so.*" \
        {"tls/$DRACUT_ARCH/",tls/,"$DRACUT_ARCH/",}"libnss_mdns4_minimal.so.*"
}
