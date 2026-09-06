#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh
command -v get_rd_overlay > /dev/null || . /lib/overlayfs-lib.sh

getargbool 0 rd.overlay -d rd.live.overlay.overlayfs || return 0

getargbool 0 rd.overlay.reset -d rd.live.overlay.reset && reset_overlay="yes"
overlay=$(get_rd_overlay)

overlay_mode="tmpfs"
overlay_device=""
overlay_tmpfs_opts=""

case "$overlay" in
    LABEL=* | UUID=* | PARTLABEL=* | PARTUUID=* | /dev/*)
        overlay_mode="device"
        overlay_device=$(label_uuid_to_dev "$overlay")
        if [ ! -b "$overlay_device" ]; then
            warn "Failed to resolve device from '$overlay', falling back to tmpfs"
            overlay_mode="tmpfs"
        fi
        ;;
    tmpfs:*)
        overlay_mode="tmpfs"
        # Parse comma-separated key=value pairs from rd.overlay=tmpfs:key=val,
        OLDIFS="$IFS"
        IFS=,
        set -f
        for _param in ${overlay#tmpfs:}; do
            _key="${_param%%=*}"
            _val="${_param#*=}"
            case "$_key" in
                size | nr_blocks | nr_inodes)
                    overlay_tmpfs_opts="${overlay_tmpfs_opts:+${overlay_tmpfs_opts},}${_key}=${_val}"
                    ;;
                *)
                    warn "Unknown tmpfs option '${_key}', ignoring"
                    ;;
            esac
        done
        set +f
        IFS="$OLDIFS"
        ;;
    *)
        # For dmsquash-live compatibility, any other format uses tmpfs
        overlay_mode="tmpfs"
        ;;
esac

# Skip if root not mounted and rootfsbase not set up by another module (e.g. dmsquash-live)
if ! ismounted "$NEWROOT" && ! [ -e /run/rootfsbase ]; then
    return 0
fi

if ! [ -e /run/rootfsbase ]; then
    mkdir -m 0755 -p /run/rootfsbase
    mount --bind "$NEWROOT" /run/rootfsbase
fi

if [ "$overlay_mode" = "device" ] && [ -n "$overlay_device" ]; then
    info "Attempting to use persistent overlay on $overlay_device"

    wait_for_dev -n "$overlay_device"

    mkdir -m 0755 -p /run/overlayfs-backing

    if /bin/mount "$overlay_device" /run/overlayfs-backing; then
        info "Successfully mounted persistent overlay on $overlay_device"

        mkdir -m 0755 -p /run/overlayfs-backing/overlay
        mkdir -m 0755 -p /run/overlayfs-backing/ovlwork

        ln -sf /run/overlayfs-backing/overlay /run/overlayfs
        ln -sf /run/overlayfs-backing/ovlwork /run/ovlwork
    else
        warn "Failed to mount $overlay_device, falling back to tmpfs"
        overlay_mode="tmpfs"
    fi
fi

if [ "$overlay_mode" = "tmpfs" ]; then
    info "Using tmpfs overlay (changes will not persist across reboots)"

    [ -d /run/overlayfs ] || {
        mkdir -m 0755 -p /run/initramfs/overlay
        if [ -n "$overlay_tmpfs_opts" ]; then
            info "Mounting tmpfs overlay with options: ${overlay_tmpfs_opts}"
            if ! mount -t tmpfs -o "${overlay_tmpfs_opts}" tmpfs /run/initramfs/overlay; then
                warn "Failed to mount tmpfs with options '${overlay_tmpfs_opts}', using default"
            fi
        fi
        mkdir -m 0755 -p /run/initramfs/overlay/overlayfs
        mkdir -m 0755 -p /run/initramfs/overlay/ovlwork
        ln -sf /run/initramfs/overlay/overlayfs /run/overlayfs
        ln -sf /run/initramfs/overlay/ovlwork /run/ovlwork
    }
fi

if [ -n "$reset_overlay" ] && [ -h /run/overlayfs ]; then
    ovlfsdir=$(readlink /run/overlayfs)
    info "Resetting the OverlayFS overlay directory."
    rm -r -- "${ovlfsdir:?}"/* "${ovlfsdir:?}"/.* > /dev/null 2>&1
fi
