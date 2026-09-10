#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh
command -v det_fs > /dev/null || . /lib/fs-lib.sh
command -v unpack_archive > /dev/null || . /lib/img-lib.sh
command -v get_rd_overlay > /dev/null || . /lib/overlayfs-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

if getargbool 0 rd.live.debug; then
    exec > /tmp/liveroot.$$.out
    exec 2>> /tmp/liveroot.$$.out
    set -x
fi

[ "$1" ] || exit 1
livedev="$1"
ln -s "$livedev" /run/initramfs/livedev

# Determine the parent disk device for the device - $1
get_diskDevice() {
    local -
    # shellcheck disable=SC2034
    local dev syspath parent DEVTYPE='' DEVNAME DISKSEQ MAJOR MINOR \
        PARTN PARTNAME PARTUUID
    set +x
    dev="${1##*/}"
    syspath="/sys/class/block/$dev"
    [ -d "$syspath" ] || return 1
    . "$syspath/uevent"
    case $DEVTYPE in
        partition)
            parent=$(readlink -f "$syspath/..")
            diskDevice="/dev/${parent##*/}"
            ;;
        *) diskDevice="/dev/$dev" ;;
    esac
}

set +x
getcmdline
for arg in $CMDLINE; do
    case $arg in
        ro | rw) opt=$arg ;;
    esac
done
[ "$RD_DEBUG" = yes ] && set -x

devInfo=$(blkid "$livedev")
# The above works for block devices or image files.
livedev_fstype="${devInfo#* TYPE=\"}"
livedev_fstype="${livedev_fstype%%\"*}"
load_fstype "$livedev_fstype"

# mount the backing of the live image first
case $livedev_fstype in
    iso9660 | udf)
        [ -f "$livedev" ] || get_diskDevice "$livedev"
        getargbool 0 rd.live.check && rd_iso_check "${diskDevice:-$livedev}"
        [ -d /run/initramfs/live ] || {
            mntcmd="mount -m -n -t $livedev_fstype"
            [ -f "$livedev" ] && opt=ro,loop
        }
        ;;
    squashfs | erofs)
        # no mount needed - we've already got the LiveOS image in $livedev
        SQUASHED="$livedev"
        ;;
    '')
        die "Cannot mount live image (unknown filesystem type)."
        ;;
    ntfs)
        if [ -x /sbin/mount-ntfs-3g ]; then
            mkdir -m 0755 -p /run/initramfs/live
            mntcmd=/sbin/mount-ntfs-3g
        else
            die "mount-ntfs-3g is needed for ntfs filesystem mounting."
        fi
        ;;
    *)
        if [ -f "$livedev" ]; then
            FSIMG=$livedev
        else
            mntcmd="mount -m -n -t $FS"
        fi
        ;;
esac
[ "${mntcmd+mount}" ] && {
    $mntcmd -o "${opt:-ro}" "$livedev" /run/initramfs/live > /dev/kmsg 2>&1 \
        || die "Failed to mount '$livedev' bearing the live image."
}

# parse various live image specific options that make sense to be
# specified as their own things
live_dir=$(getarg rd.live.dir)
[ -z "$live_dir" ] && live_dir="LiveOS"
squash_image=$(getarg rd.live.squashimg)
[ -z "$squash_image" ] && squash_image="squashfs.img"

getargbool 0 rd.live.ram && live_ram="yes"
getargbool 0 rd.overlay.reset -d rd.live.overlay.reset && reset_overlay="yes"
getargbool 0 rd.overlay.readonly -d rd.live.overlay.readonly && readonly_overlay="--readonly" || readonly_overlay=""
getargbool 0 rd.live.overlay.nouserconfirmprompt && overlay_no_user_confirm_prompt="--noprompt" || overlay_no_user_confirm_prompt=""
overlay=$(get_rd_overlay)
getargbool 0 rd.writable.fsimg && writable_fsimg="yes"
overlay_size=$(getarg rd.live.overlay.size=)
[ -z "$overlay_size" ] && overlay_size=32768

getargbool 0 rd.live.overlay.thin && thin_snapshot="yes"
getargbool 0 rd.overlay -d rd.live.overlay.overlayfs && overlayfs="yes"

dev_to_overlay_pathname() {
    local device="$1"
    local label uuid

    label=$(blkid -s LABEL -o value "$device") || label=""
    uuid=$(blkid -s UUID -o value "$device") || uuid=""
    printf "overlay-%s-%s" "$label" "$uuid"
}

# overlay setup helper function
do_live_overlay() {
    # create a sparse file for the overlay
    # overlay: if non-ram overlay searching is desired, do it,
    #              otherwise, create traditional overlay in ram

    if [ -z "$overlay" ]; then
        pathspec="/${live_dir}/$(dev_to_overlay_pathname "$livedev")"
    elif strstr "$overlay" ":"; then
        # pathspec specified, extract
        pathspec=${overlay##*:}
    fi

    if [ -z "$pathspec" ] || [ "$pathspec" = "auto" ]; then
        pathspec="/${live_dir}/$(dev_to_overlay_pathname "$livedev")"
    elif ! str_starts "$pathspec" "/"; then
        pathspec=/"${pathspec}"
    fi
    devspec=${overlay%%:*}

    # need to know where to look for the overlay
    if [ -z "$setup" ] && [ -n "$devspec" ] && [ -n "$pathspec" ] && [ -n "$overlay" ]; then
        if ismounted "$devspec"; then
            devmnt=$(findmnt -e -v -n -o 'TARGET' --source "$devspec")
            # We need $devspec writable for overlay storage
            mount -o remount,rw "$devspec"
            mount -m --bind "$devmnt" /run/initramfs/overlayfs
        else
            mount -m -n -t auto "$devspec" /run/initramfs/overlayfs || :
        fi
        if [ -f "/run/initramfs/overlayfs$pathspec" ] && [ -w "/run/initramfs/overlayfs$pathspec" ]; then
            OVERLAY_LOOPDEV=$(losetup -f --show ${readonly_overlay:+-r} "/run/initramfs/overlayfs$pathspec")
            over=$OVERLAY_LOOPDEV
            umount -l /run/initramfs/overlayfs || :
            det_fs "$OVERLAY_LOOPDEV"
            case $FS in
                auto | DM_snapshot_cow)
                    # An uninitialized DM overlay has no fs type
                    if [ -n "$reset_overlay" ]; then
                        info "Resetting the Device-mapper overlay."
                        dd if=/dev/zero of="$OVERLAY_LOOPDEV" bs=64k count=1 conv=fsync 2> /dev/null
                    fi
                    if [ -n "$overlayfs" ]; then
                        unset -v overlayfs
                        [ -n "${DRACUT_SYSTEMD-}" ] && reloadsysrootmountunit=":>/xor_overlayfs;"
                    fi
                    setup="yes"
                    ;;
                *)
                    mount -m -n -t "$FS" ${readonly_overlay:+-r} "$OVERLAY_LOOPDEV" /run/initramfs/overlayfs
                    if [ -d /run/initramfs/overlayfs/overlayfs ] \
                        && [ -d /run/initramfs/overlayfs/ovlwork ]; then
                        ln -s /run/initramfs/overlayfs/overlayfs /run/overlayfs${readonly_overlay:+-r}
                        ln -s /run/initramfs/overlayfs/ovlwork /run/ovlwork${readonly_overlay:+-r}
                        if [ -z "$overlayfs" ] && [ -n "${DRACUT_SYSTEMD-}" ]; then
                            reloadsysrootmountunit=":>/xor_overlayfs;"
                        fi
                        overlayfs="required"
                        setup="yes"
                    fi
                    ;;
            esac
        elif [ -d "/run/initramfs/overlayfs$pathspec" ] \
            && [ -d "/run/initramfs/overlayfs$pathspec/../ovlwork" ]; then
            ln -s "/run/initramfs/overlayfs$pathspec" /run/overlayfs${readonly_overlay:+-r}
            ln -s "/run/initramfs/overlayfs$pathspec/../ovlwork" /run/ovlwork${readonly_overlay:+-r}
            if [ -z "$overlayfs" ] && [ -n "${DRACUT_SYSTEMD-}" ]; then
                reloadsysrootmountunit=":>/xor_overlayfs;"
            fi
            overlayfs="required"
            setup="yes"
        fi
    fi
    if [ -n "$overlayfs" ]; then
        if ! load_fstype overlay; then
            if [ "$overlayfs" = required ]; then
                die "OverlayFS is required but not available."
                exit 1
            fi
            [ -n "${DRACUT_SYSTEMD-}" ] && reloadsysrootmountunit=":>/xor_overlayfs;"
            m='OverlayFS is not available; using temporary Device-mapper overlay.'
            info "$m"
            unset -v overlayfs setup
        fi
    fi

    if [ -z "$setup" ] || [ -n "$readonly_overlay" ]; then
        if [ -n "$setup" ] || [ -n "$overlay_no_user_confirm_prompt" ]; then
            warn "Using temporary overlay."
        elif [ -n "$devspec" ] && [ -n "$pathspec" ]; then
            [ -z "$m" ] \
                && m='   Unable to find a persistent overlay; using a temporary one.'
            m="$m"'
      All root filesystem changes will be lost on shutdown.
         Press [Enter] to continue.'
            printf "\n\n\n\n%s\n\n\n" "${m}" > /dev/kmsg
            if [ -n "${DRACUT_SYSTEMD-}" ]; then
                if type plymouth > /dev/null 2>&1 && plymouth --ping; then
                    if getargbool 0 rhgb || getargbool 0 splash; then
                        local n='
'
                        m=">>>${n}>>>${n}>>>${n}${n}${n}${m%n.*}n.${n}${n}${n}<<<${n}<<<${n}<<<"
                        plymouth display-message --text="${m}"
                    else
                        plymouth ask-question --prompt="${m}" --command=true
                    fi
                else
                    m=">>>$(printf '%s' "$m" | tr -d '\n')  <<<"
                    systemd-ask-password --timeout=0 "${m}"
                fi
            else
                type plymouth > /dev/null 2>&1 && plymouth --ping && plymouth --quit
                printf '\n\n%s' "$m"
                read -r _
            fi
        fi
        if [ -n "$overlayfs" ]; then
            if [ -n "$readonly_overlay" ] && ! [ -h /run/overlayfs-r ]; then
                info "No persistent overlay found."
                unset -v readonly_overlay
                [ -n "${DRACUT_SYSTEMD-}" ] && reloadsysrootmountunit="${reloadsysrootmountunit}:>/xor_readonly;"
            fi
        else
            dd if=/dev/null of=/overlay bs=1024 count=1 seek=$((overlay_size * 1024)) 2> /dev/null
            if [ -n "$setup" ] && [ -n "$readonly_overlay" ]; then
                RO_OVERLAY_LOOPDEV=$(losetup -f --show /overlay)
                over=$RO_OVERLAY_LOOPDEV
            else
                OVERLAY_LOOPDEV=$(losetup -f --show /overlay)
                over=$OVERLAY_LOOPDEV
            fi
        fi
    fi

    # set up the snapshot
    if [ -z "$overlayfs" ]; then
        if [ -n "$readonly_overlay" ] && [ -n "$OVERLAY_LOOPDEV" ]; then
            echo 0 "$sz" snapshot "$BASE_LOOPDEV" "$OVERLAY_LOOPDEV" P 8 | dmsetup create --readonly live-ro
            base="/dev/mapper/live-ro"
        else
            base=$BASE_LOOPDEV
        fi
    fi

    if [ -n "$thin_snapshot" ]; then
        modprobe dm_thin_pool
        mkdir -m 0755 -p /run/initramfs/thin-overlay

        # In block units (512b)
        thin_data_sz=$((overlay_size * 1024 * 1024 / 512))
        thin_meta_sz=$((thin_data_sz / 10))

        # It is important to have the backing file on a tmpfs
        # this is needed to let the loopdevice support TRIM
        dd if=/dev/null of=/run/initramfs/thin-overlay/meta bs=1b count=1 seek=$((thin_meta_sz)) 2> /dev/null
        dd if=/dev/null of=/run/initramfs/thin-overlay/data bs=1b count=1 seek=$((thin_data_sz)) 2> /dev/null

        THIN_META_LOOPDEV=$(losetup --show -f /run/initramfs/thin-overlay/meta)
        THIN_DATA_LOOPDEV=$(losetup --show -f /run/initramfs/thin-overlay/data)

        echo 0 $thin_data_sz thin-pool "$THIN_META_LOOPDEV" "$THIN_DATA_LOOPDEV" 1024 1024 | dmsetup create live-overlay-pool
        dmsetup message /dev/mapper/live-overlay-pool 0 "create_thin 0"

        # Create a snapshot of the base image
        echo 0 "$thin_data_sz" thin /dev/mapper/live-overlay-pool 0 "$base" | dmsetup create live-rw
    elif [ -z "$overlayfs" ]; then
        echo 0 "$sz" snapshot "$base" "$over" PO 8 | dmsetup create live-rw
    fi

    # Create a device for the ro base of overlaid file systems.
    if [ -z "$overlayfs" ]; then
        echo 0 "$sz" linear "$BASE_LOOPDEV" 0 | dmsetup create --readonly live-base
    fi
    ln -s "$BASE_LOOPDEV" /dev/live-base
}
# end do_live_overlay()

# we might have an embedded fs image on squashfs (compressed live)
if [ -e "/run/initramfs/live/${live_dir}/${squash_image}" ]; then
    SQUASHED="/run/initramfs/live/${live_dir}/${squash_image}"
fi
if [ -e "$SQUASHED" ]; then
    if [ -n "$live_ram" ]; then
        imgsize=$(($(stat -c %s -- "$SQUASHED") / (1024 * 1024)))
        check_live_ram $imgsize
        echo 'Copying live image to RAM...' > /dev/kmsg
        echo ' (this may take a minute)' > /dev/kmsg
        dd "if=$SQUASHED" of=/run/initramfs/squashed.img bs=512 2> /dev/null
        echo 'Done copying live image to RAM.' > /dev/kmsg
        SQUASHED="/run/initramfs/squashed.img"
    fi

    SQUASHED_LOOPDEV=$(losetup -f)
    losetup -r "$SQUASHED_LOOPDEV" "$SQUASHED"
    det_fs "$SQUASHED_LOOPDEV"
    load_fstype "$FS"
    mount -m -n -t "$FS" -o ro "$SQUASHED_LOOPDEV" /run/initramfs/squashfs

    if [ -d /run/initramfs/squashfs/LiveOS ]; then
        if [ -f /run/initramfs/squashfs/LiveOS/rootfs.img ]; then
            FSIMG="/run/initramfs/squashfs/LiveOS/rootfs.img"
        fi
    elif [ -d /run/initramfs/squashfs/usr ] || [ -d /run/initramfs/squashfs/ostree ]; then
        FSIMG=$SQUASHED
        if [ -z "$overlayfs" ] && [ -n "${DRACUT_SYSTEMD-}" ]; then
            reloadsysrootmountunit=":>/xor_overlayfs;"
        fi
        overlayfs="required"
    else
        die "Failed to find a root filesystem in $SQUASHED."
        exit 1
    fi
else
    # we might have an embedded fs image to use as rootfs (uncompressed live)
    if [ -e "/run/initramfs/live/${live_dir}/rootfs.img" ]; then
        FSIMG="/run/initramfs/live/${live_dir}/rootfs.img"
    fi
    if [ -n "$live_ram" ]; then
        echo 'Copying live image to RAM...' > /dev/kmsg
        echo ' (this may take a minute or so)' > /dev/kmsg
        dd "if=$FSIMG" of=/run/initramfs/rootfs.img bs=512 2> /dev/null
        echo 'Done copying live image to RAM.' > /dev/kmsg
        FSIMG='/run/initramfs/rootfs.img'
    fi
fi

if [ -n "$FSIMG" ]; then
    if [ -n "$writable_fsimg" ]; then
        # mount the provided filesystem read/write
        echo "Unpacking live filesystem (may take some time)" > /dev/kmsg
        mkdir -m 0755 -p /run/initramfs/fsimg/
        if [ -n "$SQUASHED" ]; then
            cp -v "$FSIMG" /run/initramfs/fsimg/rootfs.img
        else
            unpack_archive "$FSIMG" /run/initramfs/fsimg/
        fi
        FSIMG=/run/initramfs/fsimg/rootfs.img
    fi
    # For writable DM images...
    readonly_base=1
    if [ -z "$SQUASHED" ] && [ -n "$live_ram" ] && [ -z "$overlayfs" ] \
        || [ -n "$writable_fsimg" ] \
        || [ "$overlay" = none ] || [ "$overlay" = None ] || [ "$overlay" = NONE ]; then
        if [ -z "$readonly_overlay" ]; then
            unset readonly_base
            setup=rw
        else
            setup=yes
        fi
    fi
    if [ "$FSIMG" = "$SQUASHED" ]; then
        BASE_LOOPDEV=$SQUASHED_LOOPDEV
    else
        BASE_LOOPDEV=$(losetup -f --show ${readonly_base:+-r} "$FSIMG")
        sz=$(blockdev --getsz "$BASE_LOOPDEV")
    fi
    if [ "$setup" = rw ]; then
        echo 0 "$sz" linear "$BASE_LOOPDEV" 0 | dmsetup create live-rw
    else
        # Add a DM snapshot or OverlayFS for writes.
        do_live_overlay
    fi
fi

if [ -n "$reloadsysrootmountunit" ]; then
    eval "$reloadsysrootmountunit"
    systemctl daemon-reload
fi

ROOTFLAGS="$(getarg rootflags)"

if [ "$overlayfs" = required ] && ! getargbool 0 rd.overlay; then
    echo "rd.overlay" > /etc/cmdline.d/20-dmsquash-need-overlay.conf
fi

if [ -n "$overlayfs" ]; then
    if [ -n "$FSIMG" ]; then
        if [ "$FSIMG" = "$SQUASHED" ]; then
            mount -m --bind /run/initramfs/squashfs /run/rootfsbase
        else
            det_fs "$FSIMG"
            load_fstype "$FS"
            mount -m -t "$FS" -r "$FSIMG" /run/rootfsbase
        fi
    else
        ln -sf /run/initramfs/live /run/rootfsbase
    fi
else
    if [ -z "${DRACUT_SYSTEMD-}" ]; then
        [ -n "$ROOTFLAGS" ] && ROOTFLAGS="-o $ROOTFLAGS"
        printf 'mount %s /dev/mapper/live-rw %s\n' "$ROOTFLAGS" "$NEWROOT" > "$hookdir"/mount/01-$$-live.sh
    fi
fi
[ -e "$SQUASHED" ] && umount -l /run/initramfs/squashfs

ln -s null /dev/root

need_shutdown

exit 0
