#!/bin/sh

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh
type det_fs > /dev/null 2>&1 || . /lib/fs-lib.sh

command -v unpack_archive > /dev/null || . /lib/img-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

if getargbool 0 rd.live.debug -n -y rdlivedebug; then
    exec > /tmp/liveroot.$$.out
    exec 2>> /tmp/liveroot.$$.out
    set -x
fi

[ -z "$1" ] && exit 1
livedev="$1"

# parse various live image specific options that make sense to be
# specified as their own things
live_dir=$(getarg rd.live.dir -d live_dir)
[ -z "$live_dir" ] && live_dir="LiveOS"
squash_image=$(getarg rd.live.squashimg)
[ -z "$squash_image" ] && squash_image="squashfs.img"

getargbool 0 rd.live.ram -d -y live_ram && live_ram="yes"
getargbool 0 rd.live.overlay.reset -d -y reset_overlay && reset_overlay="yes"
getargbool 0 rd.live.overlay.readonly -d -y readonly_overlay && readonly_overlay="--readonly" || readonly_overlay=""
overlay=$(getarg rd.live.overlay -d overlay)
getargbool 0 rd.writable.fsimg -d -y writable_fsimg && writable_fsimg="yes"
overlay_size=$(getarg rd.live.overlay.size=)
[ -z "$overlay_size" ] && overlay_size=32768

getargbool 0 rd.live.overlay.thin && thin_snapshot="yes"
getargbool 0 rd.live.overlay.overlayfs && overlayfs="yes"

# Take a path to a disk label and return the parent disk if it is a partition
# Otherwise returns the original path
get_check_dev() {
    local _udevinfo
    dev_path="$(udevadm info -q path --name "$1")"
    _udevinfo="$(udevadm info -q property --path "${dev_path}")"
    strstr "$_udevinfo" "DEVTYPE=partition" || {
        echo "$1"
        return
    }
    parent="${dev_path%/*}"
    _udevinfo="$(udevadm info -q property --path "${parent}")"
    strstr "$_udevinfo" "DEVTYPE=disk" || {
        echo "$1"
        return
    }
    strstr "$_udevinfo" "ID_FS_TYPE=iso9660" || {
        echo "$1"
        return
    }

    # Return the name of the parent disk device
    echo "$_udevinfo" | grep "DEVNAME=" | sed 's/DEVNAME=//'
}

# Check ISO checksum only if we have a path to a block device (or just its name
# without '/dev'). In other words, in this context, we perform the check only
# if the given $livedev is not a filesystem file image.
if [ ! -f "$livedev" ]; then
    # Find the right device to run check on
    check_dev=$(get_check_dev "$livedev")
    # CD/DVD media check
    [ -b "$check_dev" ] && fs=$(det_fs "$check_dev")
    if [ "$fs" = "iso9660" ] || [ "$fs" = "udf" ]; then
        check="yes"
    fi
    getarg rd.live.check -d check || check=""
    if [ -n "$check" ]; then
        type plymouth > /dev/null 2>&1 && plymouth --hide-splash
        if [ -n "$DRACUT_SYSTEMD" ]; then
            p=$(dev_unit_name "$check_dev")
            systemctl start checkisomd5@"${p}".service
        else
            checkisomd5 --verbose "$check_dev"
        fi
        if [ $? -eq 1 ]; then
            warn "Media check failed! We do not recommend using this medium. System will halt in 12 hours"
            sleep 43200
            die "Media check failed!"
            exit 1
        fi
        type plymouth > /dev/null 2>&1 && plymouth --show-splash
    fi
fi

ln -s "$livedev" /run/initramfs/livedev

# determine filesystem type for a filesystem image
det_img_fs() {
    udevadm settle >&2
    blkid -s TYPE -u noraid -o value "$1"
}

load_fstype squashfs
CMDLINE=$(getcmdline)
for arg in $CMDLINE; do
    case $arg in
        ro | rw) liverw=$arg ;;
    esac
done

# mount the backing of the live image first
mkdir -m 0755 -p /run/initramfs/live
if [ -f "$livedev" ]; then
    # no mount needed - we've already got the LiveOS image in initramfs
    # check filesystem type and handle accordingly
    fstype=$(det_img_fs "$livedev")
    case $fstype in
        squashfs) SQUASHED=$livedev ;;
        auto) die "cannot mount live image (unknown filesystem type)" ;;
        *) FSIMG=$livedev ;;
    esac
    load_fstype "$fstype"
else
    livedev_fstype=$(det_fs "$livedev")
    if [ "$livedev_fstype" = "squashfs" ]; then
        # no mount needed - we've already got the LiveOS image in $livedev
        SQUASHED=$livedev
    elif [ "$livedev_fstype" != "ntfs" ]; then
        if ! mount -n -t "$livedev_fstype" -o "${liverw:-ro}" "$livedev" /run/initramfs/live; then
            die "Failed to mount block device of live image"
            exit 1
        fi
    else
        [ -x "/sbin/mount-ntfs-3g" ] && /sbin/mount-ntfs-3g -o "${liverw:-ro}" "$livedev" /run/initramfs/live
    fi
fi

# overlay setup helper function
do_live_overlay() {
    # create a sparse file for the overlay
    # overlay: if non-ram overlay searching is desired, do it,
    #              otherwise, create traditional overlay in ram

    l=$(blkid -s LABEL -o value "$livedev") || l=""
    u=$(blkid -s UUID -o value "$livedev") || u=""

    if [ -z "$overlay" ]; then
        pathspec="/${live_dir}/overlay-$l-$u"
    elif strstr "$overlay" ":"; then
        # pathspec specified, extract
        pathspec=${overlay##*:}
    fi

    if [ -z "$pathspec" ] || [ "$pathspec" = "auto" ]; then
        pathspec="/${live_dir}/overlay-$l-$u"
    elif ! str_starts "$pathspec" "/"; then
        pathspec=/"${pathspec}"
    fi
    devspec=${overlay%%:*}

    # need to know where to look for the overlay
    if [ -z "$setup" ] && [ -n "$devspec" ] && [ -n "$pathspec" ] && [ -n "$overlay" ]; then
        mkdir -m 0755 -p /run/initramfs/overlayfs
        if ismounted "$devspec"; then
            devmnt=$(findmnt -e -v -n -o 'TARGET' --source "$devspec")
            # We need $devspec writable for overlay storage
            mount -o remount,rw "$devspec"
            mount --bind "$devmnt" /run/initramfs/overlayfs
        else
            mount -n -t auto "$devspec" /run/initramfs/overlayfs || :
        fi
        if [ -f /run/initramfs/overlayfs$pathspec ] && [ -w /run/initramfs/overlayfs$pathspec ]; then
            OVERLAY_LOOPDEV=$(losetup -f --show ${readonly_overlay:+-r} /run/initramfs/overlayfs$pathspec)
            over=$OVERLAY_LOOPDEV
            umount -l /run/initramfs/overlayfs || :
            oltype=$(det_img_fs "$OVERLAY_LOOPDEV")
            if [ -z "$oltype" ] || [ "$oltype" = DM_snapshot_cow ]; then
                if [ -n "$reset_overlay" ]; then
                    info "Resetting the Device-mapper overlay."
                    dd if=/dev/zero of="$OVERLAY_LOOPDEV" bs=64k count=1 conv=fsync 2> /dev/null
                fi
                if [ -n "$overlayfs" ]; then
                    unset -v overlayfs
                    [ -n "$DRACUT_SYSTEMD" ] && reloadsysrootmountunit=":>/xor_overlayfs;"
                fi
                setup="yes"
            else
                mount -n -t "$oltype" ${readonly_overlay:+-r} "$OVERLAY_LOOPDEV" /run/initramfs/overlayfs
                if [ -d /run/initramfs/overlayfs/overlayfs ] \
                    && [ -d /run/initramfs/overlayfs/ovlwork ]; then
                    ln -s /run/initramfs/overlayfs/overlayfs /run/overlayfs${readonly_overlay:+-r}
                    ln -s /run/initramfs/overlayfs/ovlwork /run/ovlwork${readonly_overlay:+-r}
                    if [ -z "$overlayfs" ] && [ -n "$DRACUT_SYSTEMD" ]; then
                        reloadsysrootmountunit=":>/xor_overlayfs;"
                    fi
                    overlayfs="required"
                    setup="yes"
                fi
            fi
        elif [ -d /run/initramfs/overlayfs$pathspec ] \
            && [ -d /run/initramfs/overlayfs$pathspec/../ovlwork ]; then
            ln -s /run/initramfs/overlayfs$pathspec /run/overlayfs${readonly_overlay:+-r}
            ln -s /run/initramfs/overlayfs$pathspec/../ovlwork /run/ovlwork${readonly_overlay:+-r}
            if [ -z "$overlayfs" ] && [ -n "$DRACUT_SYSTEMD" ]; then
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
            [ -n "$DRACUT_SYSTEMD" ] && reloadsysrootmountunit=":>/xor_overlayfs;"
            m='OverlayFS is not available; using temporary Device-mapper overlay.'
            info "$m"
            unset -v overlayfs setup
        fi
    fi

    if [ -z "$setup" ] || [ -n "$readonly_overlay" ]; then
        if [ -n "$setup" ]; then
            warn "Using temporary overlay."
        elif [ -n "$devspec" ] && [ -n "$pathspec" ]; then
            [ -z "$m" ] \
                && m='   Unable to find a persistent overlay; using a temporary one.'
            m="$m"'
      All root filesystem changes will be lost on shutdown.
         Press [Enter] to continue.'
            printf "\n\n\n\n%s\n\n\n" "${m}" > /dev/kmsg
            if [ -n "$DRACUT_SYSTEMD" ]; then
                if type plymouth > /dev/null 2>&1 && plymouth --ping; then
                    if getargbool 0 rhgb || getargbool 0 splash; then
                        m='>>>
>>>
>>>


'"$m"
                        m="${m%n.*}"'n.


<<<
<<<
<<<'
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
                [ -n "$DRACUT_SYSTEMD" ] && reloadsysrootmountunit="${reloadsysrootmountunit}:>/xor_readonly;"
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
if [ -e /run/initramfs/live/${live_dir}/${squash_image} ]; then
    SQUASHED="/run/initramfs/live/${live_dir}/${squash_image}"
fi
if [ -e "$SQUASHED" ]; then
    if [ -n "$live_ram" ]; then
        imgsize=$(($(stat -c %s -- $SQUASHED) / (1024 * 1024)))
        check_live_ram $imgsize
        echo 'Copying live image to RAM...' > /dev/kmsg
        echo ' (this may take a minute)' > /dev/kmsg
        dd if=$SQUASHED of=/run/initramfs/squashed.img bs=512 2> /dev/null
        echo 'Done copying live image to RAM.' > /dev/kmsg
        SQUASHED="/run/initramfs/squashed.img"
    fi

    SQUASHED_LOOPDEV=$(losetup -f)
    losetup -r "$SQUASHED_LOOPDEV" $SQUASHED
    mkdir -m 0755 -p /run/initramfs/squashfs
    mount -n -t squashfs -o ro "$SQUASHED_LOOPDEV" /run/initramfs/squashfs

    if [ -d /run/initramfs/squashfs/LiveOS ]; then
        if [ -f /run/initramfs/squashfs/LiveOS/rootfs.img ]; then
            FSIMG="/run/initramfs/squashfs/LiveOS/rootfs.img"
        elif [ -f /run/initramfs/squashfs/LiveOS/ext3fs.img ]; then
            FSIMG="/run/initramfs/squashfs/LiveOS/ext3fs.img"
        fi
    elif [ -d /run/initramfs/squashfs/proc ]; then
        FSIMG=$SQUASHED
        if [ -z "$overlayfs" ] && [ -n "$DRACUT_SYSTEMD" ]; then
            reloadsysrootmountunit=":>/xor_overlayfs;"
        fi
        overlayfs="required"
    else
        die "Failed to find a root filesystem in $SQUASHED."
        exit 1
    fi
else
    # we might have an embedded fs image to use as rootfs (uncompressed live)
    if [ -e /run/initramfs/live/${live_dir}/rootfs.img ]; then
        FSIMG="/run/initramfs/live/${live_dir}/rootfs.img"
    elif [ -e /run/initramfs/live/${live_dir}/ext3fs.img ]; then
        FSIMG="/run/initramfs/live/${live_dir}/ext3fs.img"
    fi
    if [ -n "$live_ram" ]; then
        echo 'Copying live image to RAM...' > /dev/kmsg
        echo ' (this may take a minute or so)' > /dev/kmsg
        dd if=$FSIMG of=/run/initramfs/rootfs.img bs=512 2> /dev/null
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
            cp -v $FSIMG /run/initramfs/fsimg/rootfs.img
        else
            unpack_archive $FSIMG /run/initramfs/fsimg/
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
        BASE_LOOPDEV=$(losetup -f --show ${readonly_base:+-r} $FSIMG)
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

if [ "$overlayfs" = required ]; then
    echo "rd.live.overlay.overlayfs=1" > /etc/cmdline.d/dmsquash-need-overlay.conf
fi

if [ -n "$overlayfs" ]; then
    if [ -n "$FSIMG" ]; then
        mkdir -m 0755 -p /run/rootfsbase
        mount -r $FSIMG /run/rootfsbase
    else
        ln -sf /run/initramfs/live /run/rootfsbase
    fi
else
    if [ -z "$DRACUT_SYSTEMD" ]; then
        [ -n "$ROOTFLAGS" ] && ROOTFLAGS="-o $ROOTFLAGS"
        printf 'mount %s /dev/mapper/live-rw %s\n' "$ROOTFLAGS" "$NEWROOT" > "$hookdir"/mount/01-$$-live.sh
    fi
fi
[ -e "$SQUASHED" ] && umount -l /run/initramfs/squashfs

ln -s null /dev/root

need_shutdown

exit 0
