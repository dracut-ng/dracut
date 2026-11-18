#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh

overlay_crypt=$(getarg rd.overlay.crypt)

[ -n "$overlay_crypt" ] || return 0

[ -e /run/overlayfs-crypt-ready ] && return 0

# Skip if root not mounted and rootfsbase not set up by another module (e.g. dmsquash-live)
if ! ismounted "$NEWROOT" && ! [ -e /run/rootfsbase ]; then
    return 0
fi

if ! [ -e /run/rootfsbase ]; then
    mkdir -m 0755 -p /run/rootfsbase
    mount --bind "$NEWROOT" /run/rootfsbase
fi

info "Attempting to set up encrypted overlay"

# shellcheck disable=SC1091
. /lib/overlayfs-crypt-lib.sh

if ! overlayfs_crypt_setup "$overlay_crypt"; then
    warn "Failed to set up encrypted overlay, falling back to tmpfs"
    _overlayfs_crypt_fallback_tmpfs
    return 0
fi

overlay_device="$_RET_DEVICE"
mkdir -m 0755 -p /run/overlayfs-backing

if ! /bin/mount "$overlay_device" /run/overlayfs-backing; then
    warn "Failed to mount encrypted overlay $overlay_device, falling back to tmpfs"
    _overlayfs_crypt_fallback_tmpfs
    return 0
fi

info "Successfully mounted encrypted overlay on $overlay_device"

mkdir -m 0755 -p /run/overlayfs-backing/overlay
mkdir -m 0755 -p /run/overlayfs-backing/ovlwork

ln -sf /run/overlayfs-backing/overlay /run/overlayfs
ln -sf /run/overlayfs-backing/ovlwork /run/ovlwork

# Signal mount-overlayfs.sh to proceed with the overlay mount
: > /run/overlayfs-crypt-ready
