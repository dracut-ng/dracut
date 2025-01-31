#!/bin/bash

# called by dracut
check() {
    [[ $mount_needs ]] && return 1

    # If the binary(s) requirements are not fulfilled the module can't be installed
    require_binaries "$systemdutildir"/systemd || return 1

    return 0
}

# called by dracut
depends() {
    local deps
    deps="systemd-initrd systemd-ask-password"

    # when systemd and crypt are both included
    # systemd-cryptsetup is mandatory dependency
    # see https://github.com/dracut-ng/dracut-ng/issues/563
    if dracut_module_included "crypt"; then
        module_check systemd-cryptsetup > /dev/null 2>&1
        if [[ $? == 255 ]]; then
            deps+=" systemd-cryptsetup"
        fi
    fi

    echo "$deps"
    return 0
}

# called by dracut
install() {
    inst_script "$moddir/dracut-emergency.sh" /usr/bin/dracut-emergency
    inst_simple "$moddir/emergency.service" "${systemdsystemunitdir}"/emergency.service
    inst_simple "$moddir/dracut-emergency.service" "${systemdsystemunitdir}"/dracut-emergency.service
    inst_simple "$moddir/emergency.service" "${systemdsystemunitdir}"/rescue.service

    ln_r "${systemdsystemunitdir}/initrd.target" "${systemdsystemunitdir}/default.target"

    inst_script "$moddir/dracut-cmdline.sh" /usr/bin/dracut-cmdline
    inst_script "$moddir/dracut-cmdline-ask.sh" /usr/bin/dracut-cmdline-ask
    inst_script "$moddir/dracut-pre-udev.sh" /usr/bin/dracut-pre-udev
    inst_script "$moddir/dracut-pre-trigger.sh" /usr/bin/dracut-pre-trigger
    inst_script "$moddir/dracut-pre-mount.sh" /usr/bin/dracut-pre-mount
    inst_script "$moddir/dracut-mount.sh" /usr/bin/dracut-mount
    inst_script "$moddir/dracut-pre-pivot.sh" /usr/bin/dracut-pre-pivot

    inst_script "$moddir/rootfs-generator.sh" "$systemdutildir"/system-generators/dracut-rootfs-generator

    inst_hook cmdline 00 "$moddir/parse-root.sh"

    for i in \
        dracut-cmdline.service \
        dracut-cmdline-ask.service \
        dracut-mount.service \
        dracut-pre-mount.service \
        dracut-pre-pivot.service \
        dracut-pre-trigger.service \
        dracut-pre-udev.service; do
        inst_simple "$moddir/${i}" "$systemdsystemunitdir/${i}"
        $SYSTEMCTL -q --root "$initdir" add-wants initrd.target "$i"
    done

    inst_simple "$moddir/dracut-tmpfiles.conf" "$tmpfilesdir/dracut-tmpfiles.conf"

    inst_multiple sulogin

    [ -e "${initdir}/usr/lib" ] || mkdir -m 0755 -p "${initdir}"/usr/lib

    local VERSION=""
    local PRETTY_NAME=""
    # Derive an os-release file from the host, if it exists
    if [[ -e $dracutsysrootdir/etc/os-release ]]; then
        # shellcheck disable=SC1090
        . "$dracutsysrootdir"/etc/os-release
        grep -hE -ve '^VERSION=' -ve '^PRETTY_NAME' "$dracutsysrootdir"/etc/os-release > "${initdir}"/usr/lib/initrd-release
        [[ -n ${VERSION} ]] && VERSION+=" "
        [[ -n ${PRETTY_NAME} ]] && PRETTY_NAME+=" "
    fi
    VERSION+="dracut-$DRACUT_VERSION"
    PRETTY_NAME+="dracut-$DRACUT_VERSION (Initramfs)"
    {
        echo "VERSION=\"$VERSION\""
        echo "PRETTY_NAME=\"$PRETTY_NAME\""
        # This addition is relatively new, intended to allow software
        # to easily detect the dracut version if need be without
        # having it mixed in with the real underlying OS version.
        echo "DRACUT_VERSION=\"${DRACUT_VERSION}\""
    } >> "$initdir"/usr/lib/initrd-release
    ln -sf ../usr/lib/initrd-release "$initdir"/etc/initrd-release
    ln -sf initrd-release "$initdir"/usr/lib/os-release
    ln -sf initrd-release "$initdir"/etc/os-release

}
