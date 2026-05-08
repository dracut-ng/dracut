#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

parse_overlay_opts() {
    local input="$1" ns="${2:-_RET_}"
    local _oldifs="$IFS" tok key val

    _RET=""
    set -f
    IFS=","
    # shellcheck disable=SC2086
    set -- $input
    IFS="$_oldifs"
    set +f

    for tok in "$@"; do
        key="${tok%%=*}"
        val="${tok#*=}"
        [ "$key" = "$tok" ] && val=""
        case "$key" in
            mapname | fstype | mkfs | timeout)
                eval "${ns}${key}='${val}'"
                _RET="${_RET:+$_RET }${ns}${key}"
                ;;
            *)
                warn "Unknown option '$key'"
                ;;
        esac
    done
    return 0
}

generate_random_password() {
    local tmpf entropy_sources pass
    local persist_dir="/run/initramfs"

    [ -d "$persist_dir" ] || mkdir -p "$persist_dir"

    tmpf=$(mktemp "${persist_dir}/overlayfs-crypt.XXXXXX") || {
        warn "Failed to create temp file for password"
        return 1
    }

    entropy_sources="/proc/sys/kernel/random/boot_id /proc/sys/kernel/random/uuid /dev/urandom"

    stat -L /dev/* /proc/* /sys/* > "$tmpf" 2>&1 || :

    for src in $entropy_sources; do
        [ -e "$src" ] && head -c 4096 "$src" >> "$tmpf" 2> /dev/null
    done

    pass=$(sha512sum "$tmpf" 2> /dev/null) || {
        rm -f "$tmpf"
        warn "Failed to generate password"
        return 1
    }
    pass="${pass%% *}"

    printf "%s" "$pass" > "${persist_dir}/overlayfs.passwd"
    chmod 400 "${persist_dir}/overlayfs.passwd"

    rm -f "$tmpf"
    _RET="$pass"
    return 0
}

_overlayfs_crypt_fallback_tmpfs() {
    [ -d /run/overlayfs ] || {
        mkdir -m 0755 -p /run/initramfs/overlay/overlayfs
        mkdir -m 0755 -p /run/initramfs/overlay/ovlwork
        ln -sf /run/initramfs/overlay/overlayfs /run/overlayfs
        ln -sf /run/initramfs/overlay/ovlwork /run/ovlwork
    }
    # Signal mount-overlayfs.sh to proceed with the overlay mount
    : > /run/overlayfs-crypt-ready
}

overlayfs_crypt_setup() {
    local options="$1"
    local dev="" mapname="overlay-crypt" fstype="ext4" mkfs="1" timeout=""
    local crypt_dev

    # Device is the first positional argument
    local device="${options%%,*}"
    case "$device" in
        LABEL=* | UUID=* | PARTLABEL=* | PARTUUID=* | /dev/*)
            dev="$device"
            options="${options#"$device"}"
            options="${options#,}"
            ;;
    esac

    parse_overlay_opts "$options" "_ovl_" || return 1

    mapname="${_ovl_mapname:-$mapname}"
    fstype="${_ovl_fstype:-$fstype}"
    mkfs="${_ovl_mkfs:-$mkfs}"
    timeout="${_ovl_timeout:-$timeout}"

    [ -n "$dev" ] || {
        warn "Device parameter is required"
        return 1
    }

    case "$dev" in
        LABEL=* | UUID=* | PARTLABEL=* | PARTUUID=*)
            dev=$(label_uuid_to_dev "$dev")
            ;;
        /dev/*) ;;
        *)
            dev="/dev/$dev"
            ;;
    esac

    if [ "$timeout" = "0" ]; then
        : # Don't wait for the device
    elif [ -n "$timeout" ]; then
        wait_for_dev -n "$dev" "$timeout" || {
            warn "Device $dev not available after ${timeout}s"
            return 1
        }
    else
        wait_for_dev -n "$dev" || {
            warn "Device $dev not available"
            return 1
        }
    fi

    # Resolve symlink to actual block device
    local real_dev="$dev"
    if [ -L "$dev" ]; then
        real_dev=$(readlink -f "$dev" 2> /dev/null) || real_dev="$dev"
    fi

    [ -b "$real_dev" ] || {
        warn "Device $real_dev not found"
        return 1
    }

    dev="$real_dev"

    info "Setting up encrypted overlay on $dev"

    modprobe -q dm_mod 2> /dev/null || :
    modprobe -q dm_crypt 2> /dev/null || :

    crypt_dev="/dev/mapper/$mapname"

    if cryptsetup isLuks "$dev" 2> /dev/null; then
        info "Existing LUKS device found at $dev, prompting for password"
        command -v luks_open_interactive > /dev/null || . /lib/dracut-crypt-lib.sh
        luks_open_interactive "$dev" "$mapname" "Overlay password ($dev)" || {
            warn "Failed to open LUKS device at $dev"
            return 1
        }
        wait_for_dev -n "$crypt_dev" || {
            warn "Device $crypt_dev did not appear"
            return 1
        }
        _RET_DEVICE="$crypt_dev"
        return 0
    fi

    if [ "$mkfs" = "0" ]; then
        warn "No LUKS found at $dev and mkfs=0"
        return 1
    fi

    generate_random_password || return 1
    local pass="$_RET"
    info "No existing LUKS found; creating new encrypted overlay"

    info "Wiping $dev"
    wipefs -a "$dev" || {
        warn "Failed to wipe $dev"
        return 1
    }

    info "Formatting $dev with LUKS"
    # DM_DISABLE_UDEV=1 prevents cryptsetup from waiting for udev to process the device
    if ! printf "%s" "$pass" | DM_DISABLE_UDEV=1 cryptsetup luksFormat --pbkdf pbkdf2 -q "$dev" --key-file -; then
        warn "luksFormat failed on $dev"
        return 1
    fi

    info "Opening LUKS device"
    if ! printf "%s" "$pass" | DM_DISABLE_UDEV=1 cryptsetup luksOpen "$dev" "$mapname" --key-file -; then
        warn "luksOpen failed on $dev"
        return 1
    fi
    udevadm settle 2> /dev/null || :

    info "LUKS device opened, waiting for $crypt_dev"

    wait_for_dev -n "$crypt_dev" || {
        warn "Device $crypt_dev did not appear after luksOpen"
        return 1
    }

    info "Creating $fstype filesystem on $crypt_dev"
    case "$fstype" in
        ext2 | ext3 | ext4)
            mkfs."$fstype" -q "$crypt_dev" || {
                warn "mkfs.$fstype failed on $crypt_dev"
                cryptsetup luksClose "$mapname"
                return 1
            }
            ;;
        *)
            warn "Unsupported filesystem type '$fstype'"
            cryptsetup luksClose "$mapname"
            return 1
            ;;
    esac

    info "Successfully set up encrypted overlay at $crypt_dev"
    _RET_DEVICE="$crypt_dev"
    return 0
}
