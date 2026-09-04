#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

# systemd lets stdout go to journal only, but the system
# has to halt when the integrity check fails to satisfy FIPS.
if [ -z "${DRACUT_SYSTEMD-}" ]; then
    fips_info() {
        info "$*"
    }
else
    fips_info() {
        echo "$*" >&2
    }
fi

# Checks if a systemd-based UKI is running and ESP UUID is set
is_uki() {
    [ -f /sys/firmware/efi/efivars/StubFeatures-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f ] \
        && [ -f /sys/firmware/efi/efivars/LoaderDevicePartUUID-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f ]
}

mount_boot() {
    boot=$(getarg boot=)

    if is_uki && [ -z "$boot" ]; then
        # efivar file has 4 bytes header and contain UCS-2 data. Note, 'cat' is required
        # as sys/firmware/efi/efivars/ files are 'special' and don't allow 'seeking'.
        # shellcheck disable=SC2002
        boot="PARTUUID=$(cat /sys/firmware/efi/efivars/LoaderDevicePartUUID-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f | tail -c +5 | tr -d '\0' | tr 'A-F' 'a-f')"
    fi

    if [ -n "$boot" ]; then
        if [ -d /boot ] && ismounted /boot; then
            boot_dev=
            if command -v findmnt > /dev/null; then
                boot_dev=$(findmnt -n -o SOURCE /boot)
            fi
            fips_info "Ignoring 'boot=$boot' as /boot is already mounted ${boot_dev:+"from '$boot_dev'"}"
            return 0
        fi

        case "$boot" in
            LABEL=* | UUID=* | PARTUUID=* | PARTLABEL=*)
                boot="$(label_uuid_to_dev "$boot")"
                ;;
            /dev/*) ;;

            *)
                die "You have to specify boot=<boot device> as a boot option for fips=1"
                ;;
        esac

        if ! [ -e "$boot" ]; then
            udevadm trigger --action=add > /dev/null 2>&1

            i=0
            while ! [ -e "$boot" ]; do
                udevadm settle --exit-if-exists="$boot"
                [ -e "$boot" ] && break
                sleep 0.5
                i=$((i + 1))
                [ $i -gt 40 ] && break
            done
        fi

        [ -e "$boot" ] || return 1

        mkdir -p /boot
        fips_info "Mounting $boot as /boot"
        /bin/mount -oro "$boot" /boot || return 1
        FIPS_MOUNTED_BOOT=1
    elif ! ismounted /boot && [ -d "$NEWROOT/boot" ]; then
        # shellcheck disable=SC2114
        rm -fr -- /boot
        ln -sf "$NEWROOT/boot" /boot
    else
        die "You have to specify boot=<boot device> as a boot option for fips=1"
    fi
}

do_rhevh_check() {
    KERNEL=$(uname -r)
    kpath=${1}

    # If we're on RHEV-H, the kernel is in /run/initramfs/live/vmlinuz0
    HMAC_SUM_ORIG=$(while read -r a _ || [ -n "$a" ]; do printf "%s\n" "$a"; done < "$NEWROOT/boot/.vmlinuz-${KERNEL}.hmac")
    HMAC_SUM_CALC=$(sha512hmac "$kpath" | while read -r a _ || [ -n "$a" ]; do printf "%s\n" "$a"; done || return 1)
    if [ -z "$HMAC_SUM_ORIG" ] || [ -z "$HMAC_SUM_CALC" ] || [ "${HMAC_SUM_ORIG}" != "${HMAC_SUM_CALC}" ]; then
        warn "HMAC sum mismatch"
        return 1
    fi
    fips_info "rhevh_check OK"
    return 0
}

do_uki_check() {
    local KVER
    local uki_checked=0

    KVER="$(uname -r)"
    # UKI are placed in $ESP\EFI\Linux\<intall-tag>-<uname-r>.efi
    if ! [ "$FIPS_MOUNTED_BOOT" = 1 ]; then
        warn "Failed to mount ESP for doing UKI integrity check"
        return 1
    fi

    for UKIpath in /boot/EFI/Linux/*-"$KVER".efi; do
        # UKIs are installed to $ESP/EFI/Linux/<entry-token-or-machine-id>-<uname-r>.efi
        # and in some cases (e.g. when the image is used as a template for creating new
        # VMs) entry-token-or-machine-id can change. To make sure the running UKI is
        # always checked, check all UKIs which match the 'uname -r' of the running kernel
        # and fail the whole check if any of the matching UKIs are corrupted.

        [ -r "$UKIpath" ] || break

        local UKI="${UKIpath##*/}"
        local UKIHMAC=."$UKI".hmac

        fips_info "checking $UKIHMAC"
        (cd /boot/EFI/Linux/ && sha512hmac -c "$UKIHMAC") || return 1
        uki_checked=1
    done

    if [ "$uki_checked" = 0 ]; then
        warn "Failed for find UKI for checking"
        return 1
    fi
    return 0
}

nonfatal_modprobe() {
    modprobe "$1" 2>&1 > /dev/stdout \
        | while read -r line || [ -n "$line" ]; do
            echo "${line#modprobe: FATAL: }" >&2
        done
}

fips_load_crypto() {
    local _k
    local _v
    local _module
    local _found

    fips_info "Loading and integrity checking all crypto modules"
    while read -r _module; do
        if [ "$_module" != "tcrypt" ]; then
            if ! nonfatal_modprobe "${_module}" 2> /tmp/fips.modprobe_err; then
                # check if kernel provides generic algo
                _found=0
                while read -r _k _ _v || [ -n "$_k" ]; do
                    [ "$_k" != "name" ] && [ "$_k" != "driver" ] && continue
                    [ "$_v" != "$_module" ] && continue
                    _found=1
                    break
                done < /proc/crypto
                [ "$_found" = "0" ] && cat /tmp/fips.modprobe_err >&2 && return 1
            fi
        fi
    done < /etc/fipsmodules
    if [ -f /etc/fips.conf ]; then
        mkdir -p /run/modprobe.d
        cp /etc/fips.conf /run/modprobe.d/fips.conf
    fi

    fips_info "Self testing crypto algorithms"
    modprobe tcrypt || return 1
    rmmod tcrypt
}

do_fips() {
    KERNEL=$(uname -r)

    if ! getarg rd.fips.skipkernel > /dev/null; then

        fips_info "Checking integrity of kernel"
        if [ -e "/run/initramfs/live/vmlinuz0" ]; then
            do_rhevh_check /run/initramfs/live/vmlinuz0 || return 1
        elif [ -e "/run/initramfs/live/isolinux/vmlinuz0" ]; then
            do_rhevh_check /run/initramfs/live/isolinux/vmlinuz0 || return 1
        elif [ -e "/run/install/repo/images/pxeboot/vmlinuz" ]; then
            # This is a boot.iso with the .hmac inside the install.img
            do_rhevh_check /run/install/repo/images/pxeboot/vmlinuz || return 1
        elif is_uki; then
            # This is a UKI
            do_uki_check || return 1
        else
            BOOT_IMAGE="$(getarg BOOT_IMAGE)"

            # On s390x, BOOT_IMAGE isn't a path but an integer representing the
            # entry number selected. Let's try the root of /boot first, and
            # otherwise fallback to trying to parse the BLS entries if it's a
            # BLS-based system.
            if [ "$(uname -m)" = s390x ]; then
                if [ -e "/boot/vmlinuz-${KERNEL}" ]; then
                    BOOT_IMAGE="vmlinuz-${KERNEL}"
                elif [ -d /boot/loader/entries ]; then
                    bls=$(find /boot/loader/entries -name '*.conf' | sort -rV | sed -n "$((BOOT_IMAGE + 1))p")
                    if [ -e "${bls}" ]; then
                        BOOT_IMAGE=$(grep ^linux "${bls}" | cut -d' ' -f2)
                    fi
                fi
            fi

            # Trim off any leading GRUB boot device (e.g. ($root) )
            BOOT_IMAGE="$(echo "${BOOT_IMAGE}" | sed 's/^(.*)//')"

            BOOT_IMAGE_NAME="${BOOT_IMAGE##*/}"
            BOOT_IMAGE_PATH="${BOOT_IMAGE%"${BOOT_IMAGE_NAME}"}"

            if [ -z "$BOOT_IMAGE_NAME" ]; then
                BOOT_IMAGE_NAME="vmlinuz-${KERNEL}"
            elif ! [ -e "/boot/${BOOT_IMAGE_PATH}/${BOOT_IMAGE_NAME}" ]; then
                #if /boot is not a separate partition BOOT_IMAGE might start with /boot
                BOOT_IMAGE_PATH=${BOOT_IMAGE_PATH#"/boot"}
                #on some architectures BOOT_IMAGE does not contain path to kernel
                #so if we can't find anything, let's treat it in the same way as if it was empty
                if ! [ -e "/boot/${BOOT_IMAGE_PATH}/${BOOT_IMAGE_NAME}" ]; then
                    BOOT_IMAGE_NAME="vmlinuz-${KERNEL}"
                    BOOT_IMAGE_PATH=""
                fi
            fi

            BOOT_IMAGE_HMAC="/boot/${BOOT_IMAGE_PATH}/.${BOOT_IMAGE_NAME}.hmac"
            if ! [ -e "${BOOT_IMAGE_HMAC}" ]; then
                warn "${BOOT_IMAGE_HMAC} does not exist"
                return 1
            fi

            (cd "${BOOT_IMAGE_HMAC%/*}" && sha512hmac -c "${BOOT_IMAGE_HMAC}") || return 1
        fi
    fi

    fips_info "All initrd crypto checks done"

    : > /tmp/fipsdone

    if [ "$FIPS_MOUNTED_BOOT" = 1 ]; then
        fips_info "Unmounting /boot"
        umount /boot > /dev/null 2>&1
    else
        fips_info "Not unmounting /boot"
    fi

    return 0
}
