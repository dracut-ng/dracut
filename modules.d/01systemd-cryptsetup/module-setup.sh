#!/bin/bash

# called by dracut
check() {
    local fs
    # if cryptsetup is not installed, then we cannot support encrypted devices.
    require_binaries "$systemdutildir"/systemd-cryptsetup || return 1

    [[ $hostonly ]] || [[ $mount_needs ]] && {
        for fs in "${host_fs_types[@]}"; do
            [[ $fs == "crypto_LUKS" ]] && return 0
        done
        return 255
    }

    return 0
}

# called by dracut
depends() {
    local deps
    deps="dm rootfs-block crypt systemd-ask-password"
    if [[ $hostonly && $hostonly_mode == "strict" && -f "$dracutsysrootdir"/etc/crypttab ]]; then
        if grep -q -e "fido2-device=" -e "fido2-cid=" "$dracutsysrootdir"/etc/crypttab; then
            deps+=" fido2"
        fi
        if grep -q "pkcs11-uri" "$dracutsysrootdir"/etc/crypttab; then
            deps+=" pkcs11"
        fi
        if grep -q "tpm2-device=" "$dracutsysrootdir"/etc/crypttab; then
            deps+=" tpm2-tss"
        fi
    else
        for module in fido2 pkcs11 tpm2-tss; do
            module_check $module > /dev/null 2>&1
            if [[ $? == 255 ]]; then
                deps+=" $module"
            fi
        done
    fi
    echo "$deps"
    return 0
}

# called by dracut
install() {
    # the cryptsetup targets are already pulled in by 00systemd, but not
    # the enablement symlinks
    inst_multiple -o \
        "$tmpfilesdir"/cryptsetup.conf \
        "$systemdutildir"/system-generators/systemd-cryptsetup-generator \
        "$systemdutildir"/systemd-cryptsetup \
        "$systemdsystemunitdir"/cryptsetup-pre.target \
        "$systemdsystemunitdir"/cryptsetup.target \
        "$systemdsystemunitdir"/sysinit.target.wants/cryptsetup.target \
        "$systemdsystemunitdir"/remote-cryptsetup.target \
        "$systemdsystemunitdir"/initrd-root-device.target.wants/remote-cryptsetup.target

    if [[ $hostonly ]] && [[ -f $initdir/etc/crypttab ]]; then
        # for each entry in /etc/crypttab check if the key file is backed by a socket unit and if so,
        # include it along with its corresponding service unit.
        while read -r _mapper _dev _luksfile _luksoptions || [[ -n $_mapper ]]; do
            # ignore paths followed by a device specification
            if [[ $_luksfile == *":"* ]]; then
                return
            fi

            # if no explicit path is provided, try to include units for auto-discoverable keys
            if [[ -z $_luksfile ]] || [[ $_luksfile == "-" ]] || [[ $_luksfile == "none" ]]; then
                _luksfile="/run/cryptsetup-keys.d/$_mapper.key"
            fi

            find "$systemdsystemunitdir" "$systemdsystemconfdir" -type f -name "*.socket" | while read -r socket_unit; do
                # systemd-cryptsetup utility only supports SOCK_STREAM (ListenStream) sockets, so we ignore
                # other types like SOCK_DGRAM (ListenDatagram), SOCK_SEQPACKET (ListenSequentialPacket), etc.
                if ! grep -E -q "^ListenStream\s*=\s*$_luksfile$" "$socket_unit"; then
                    continue
                fi

                service_name=$(grep -E "^Service\s*=\s*" "$socket_unit" | cut -d= -f2)

                if [ -z "$service_name" ]; then
                    # if no explicit Service= is defined, construct the service name based on the socket unit's name
                    if grep -P -q "^Accept\s*=\s*(?i)(1|yes|y|true|t|on)$" "$socket_unit"; then
                        # if Accept is truthy, assemble a service template
                        service_name=$(basename "$socket_unit" .socket)"@.service"
                    else
                        # otherwise, just replace .socket with .service
                        service_name=$(basename "$socket_unit" .socket)".service"
                    fi
                fi

                # this assumes the service file is in the same directory as the socket file,
                # which is a common configuration but not guaranteed.
                if ! inst_multiple -H "${socket_unit%/*}/$service_name" "$socket_unit"; then
                    continue
                fi

                # sanity check - all units which use default dependencies will depend on sysinit.target,
                # which itself depends on cryptsetup.target. This could lead to either:
                #   a) systemd-cryptsetup falling back to a passphrase prompt due to a missing socket file
                #   b) a deadlock caused by a circular dependency (service unit -> sysinit.target -> cryptsetup.target -> service unit)
                if ! grep -P -q "^DefaultDependencies\s*=\s*(?i)(0|no|n|false|f|off)" "$socket_unit"; then
                    dwarning "crypt: $socket_unit: default dependencies are not disabled," \
                        "the socket file may not exist by the time systemd-cryptsetup gets executed"
                fi

                if ! grep -P -q "^DefaultDependencies\s*=\s*(?i)(0|no|n|false|f|off)" "${socket_unit%/*}/$service_name"; then
                    dwarning "crypt: ${socket_unit%/*}/$service_name: default dependencies are not disabled," \
                        "the service unit may encounter a deadlock due to a circular dependency"
                fi

                socket_unit_basename=$(basename "$socket_unit")
                inst_multiple -H -o \
                    "$systemdsystemunitdir"/sockets.target.wants/"$socket_unit_basename" \
                    "$systemdsystemconfdir"/sockets.target.wants/"$socket_unit_basename"
                break
            done
        done < "$initdir"/etc/crypttab
    fi
}
