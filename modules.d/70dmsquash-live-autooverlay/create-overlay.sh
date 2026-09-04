#!/bin/sh

command -v getarg > /dev/null || . /lib/dracut-lib.sh
command -v get_rd_overlay > /dev/null || . /lib/overlayfs-lib.sh

if getargbool 0 rd.live.debug; then
    exec > /tmp/create-overlay.$$.out
    exec 2>> /tmp/create-overlay.$$.out
    set -x
fi

gatherData() {
    overlay=$(get_rd_overlay)
    if [ -z "$overlay" ]; then
        info "Skipping overlay creation: kernel command line parameter 'rd.overlay' is not set"
        exit 0
    fi
    if ! str_starts "${overlay}" LABEL=; then
        die "Overlay creation failed: the partition must be set by LABEL in the 'rd.overlay' kernel parameter"
    fi

    overlayLabel=${overlay#LABEL=}
    if [ -b "/dev/disk/by-label/${overlayLabel}" ]; then
        info "Skipping overlay creation: overlay already exists"
        exit 0
    fi

    filesystem=$(getarg rd.live.overlay.cowfs)
    [ -z "$filesystem" ] && filesystem="ext4"
    if [ "$filesystem" != "ext4" ] && [ "$filesystem" != "xfs" ] && [ "$filesystem" != "btrfs" ]; then
        die "Overlay creation failed: only ext4, xfs, and btrfs are supported in the 'rd.live.overlay.cowfs' kernel parameter"
    fi

    live_dir=$(getarg rd.live.dir)
    [ -z "$live_dir" ] && live_dir="LiveOS"

    [ -z "$1" ] && exit 1
    rootDevice=$1

    # The kernel command line's 'root=' parameter was parsed into the $root variable by the dmsquash-live module.
    # $root contains the path to a symlink within /dev/disk/by-label, which points to a partition.
    # This script needs that partition's parent block device.
    rootDeviceAbsolutePath=$(readlink -f "${rootDevice}")
    rootDeviceSysfsPath="/sys/class/block/${rootDeviceAbsolutePath##*/}"
    if [ -f "${rootDeviceSysfsPath}/partition" ]; then
        read -r partition < "${rootDeviceSysfsPath}/partition"
    else
        partition=0
    fi
    read -r readonly < "${rootDeviceSysfsPath}/ro"
    if [ "$partition" != "1" ] || [ "$readonly" != "0" ]; then
        info "Skipping overlay creation: unpartitioned or read-only media detected"
        exit 0
    fi
    fullDriveSysfsPath=$(readlink -f "${rootDeviceSysfsPath}/..")
    blockDevice="/dev/${fullDriveSysfsPath##*/}"
    currentPartitionCount=$(grep -Ec "${blockDevice#/dev/}[0-9]+" /proc/partitions)

    freeSpaceStart=$(parted --script "${blockDevice}" unit % print free \
        | awk -v "x=${currentPartitionCount}" '$1 == x {getline; print $1}')
    if [ -z "$freeSpaceStart" ]; then
        info "Skipping overlay creation: there is no free space after the last partition"
        exit 0
    fi
    partitionStart=$((${freeSpaceStart%.*} + 1))
    if [ $partitionStart -eq 100 ]; then
        info "Skipping overlay creation: there is not enough free space after the last partition"
        exit 0
    fi

    overlayPartition=${blockDevice}$((currentPartitionCount + 1))

    local line
    line=$(blkid "$rootDevice")

    label="${line#* LABEL=\"}"
    if [ "$label" = "$line" ]; then
        die "Overlay creation failed: failed to look up root device label"
    fi
    label="${label%%\"*}"
    uuid="${line#* UUID=\"}"
    if [ "$uuid" = "$line" ]; then
        die "Overlay creation failed: failed to look up root device UUID"
    fi
    uuid="${uuid%%\"*}"
}

createPartition() {
    parted --script --align optimal "${blockDevice}" mkpart primary ${partitionStart}% 100%
    blockdev --rereadpt "${blockDevice}"
}

createFilesystem() {
    "mkfs.${filesystem}" -L "${overlayLabel}" "${overlayPartition}"

    baseDir=/run/initramfs/create-overlayfs
    mkdir -p ${baseDir}
    mount -t "${filesystem}" "${overlayPartition}" ${baseDir}

    mkdir -p "${baseDir}/${live_dir}/ovlwork"
    mkdir "${baseDir}/${live_dir}/overlay-${label}-${uuid}"

    umount ${baseDir}
    rm -r ${baseDir}
}

main() {
    gatherData "$1"
    createPartition
    udevsettle
    createFilesystem
    udevsettle
}

main "$1"
