#!/bin/bash

# This script looks for distros that have a root partition with /etc and / on
# the same pointpoint. The partition can be either encrypted or unencrypted.
# Supported filesystems are ext4, btrfs (in certain configurations), and xfs.
# RAID, LVM, and other advanced disk setups are unsupported, as are ZFS and
# multi-disk BTRFS setups. For BTRFS, the root filesystem must either be
# located in one of three places:
#
# * directly on the toplevel subvolume, or
# * in a subvolume named '@', or
# * in a subvolume named 'root'.
#
# Supported devices are SCSI disks (sdX), NVMe disks (nvmeXnY), SD/MMC cards
# (mmcblkX), virtio disks (vdX), and Xen virtual disks (xvdX).
#
# Distros MUST have an /etc/os-release file with PRETTY_NAME set in order to
# be detected.

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

partition_list=()
possible_root_list=()
os_list=()

umount /automount_scan 2>/dev/null
rm -rf /automount_scan

get_fstype() {
    local partition
    partition="${1:-}"
    blkid "${partition}" | sed 's/.*TYPE="\([a-z0-9]*\)".*/\1/'
}

mount_partition() {
    local partition mount_point filesystem

    partition="${1:-}"
    mount_point="${2:-}"
    filesystem="$(get_fstype "${partition}")"
    
    case "${filesystem}" in
        'ext4'|'xfs')
            mount -t "${filesystem}" "${partition}" "${mount_point}" || return
            ;;
        'btrfs')
            [ -z "$(which btrfs)" ] && return

            mount -t 'btrfs' "${partition}" "${mount_point}" || return
            if btrfs subvolume list "${mount_point}" \
                | grep -q -e ' path @$'; then
                umount "${mount_point}"
                mount -t 'btrfs' "${partition}" "${mount_point}" -o subvol='@' \
                    || return
            elif btrfs subvolume list "${mount_point}" \
                | grep -q -e ' path root$'; then
                umount "${mount_point}"
                mount -t 'btrfs' "${partition}" "${mount_point}" -o subvol='root' \
                    || return
            fi
            ;;
    esac
}

scan_partition() {
    local partition real_partition os_name

    partition="${1:-}"
    real_partition="${2:-}"
    os_name=''
    [ -z "${real_partition}" ] && real_partition="${partition}"

    mount_partition "${partition}" /automount_scan

    os_name="$(2>/dev/null grep 'PRETTY_NAME' \
        < /automount_scan/etc/os-release \
        | head -n1 \
        | cut -d'=' -f2
    )"
    if [ -z "${os_name}" ] \
        || ! usable_root /automount_scan; then
        umount /automount_scan 2>/dev/null
    fi
        
    if mountpoint /automount_scan >/dev/null; then
        echo "Possible root filesystem found: ${real_partition}"
        possible_root_list+=( "${real_partition}" )
        os_list+=( "${os_name}" )
        umount /automount_scan;
    fi
}

invalid_exit() {
    echo 'Invalid input provided.'
    exit
}

lsblk_report="$(lsblk -o name --list \
    | grep \
        -e '^nvme[0-9]n[0-9]' \
        -e '^sd[a-z]' \
        -e '^vd[a-z]' \
        -e '^xvd[a-z]' \
        -e '^mmcblk[0-9]'
)"
readarray -t raw_device_list < <(awk '{ print $1 }' <<< "${lsblk_report}")

for (( i = 0; i < ${#raw_device_list[@]}; i++ )); do
    device="${raw_device_list[i]}";
    if [[ "${device}" =~ ^sd ]] \
        || [[ "${device}" =~ ^vd ]] \
        || [[ "${device}" =~ ^xvd ]]; then
        if [[ "${device}" =~ [0-9]$ ]]; then
            partition_list+=( "/dev/${device}" )
        fi
    elif [[ "${device}" =~ ^nvme ]] \
        || [[ "${device}" =~ ^mmcblk ]]; then
        if [[ "${device}" =~ p[0-9]$ ]]; then
            partition_list+=( "/dev/${device}" )
        fi
    fi
done

mkdir /automount_scan

for (( i = 0; i < ${#partition_list[@]}; i++ )); do
    partition="${partition_list[i]}";
    filesystem="$(get_fstype "${partition}")"

    if [ "${filesystem}" = 'crypto_LUKS' ]; then
        if [ -n "$(which cryptsetup)" ]; then
            echo "Partition ${partition} needs to be decrypted to scan."
            if cryptsetup luksOpen "${partition}" 'automount_scan_crypt'; then
                scan_partition '/dev/mapper/automount_scan_crypt' "${partition}";
                cryptsetup luksClose "${partition}";
            else
                continue;
            fi
        else
            continue;
        fi
    else
        scan_partition "${partition}";
    fi
done

host_os_name="$(grep 'PRETTY_NAME' < /host-os-release \
    | head -n1 \
    | cut -d'=' -f2
)"

if [ "${#possible_root_list[@]}" = '0' ]; then
    echo 'No suitable root filesystems detected.';
    exit;
fi

echo

default_choice='n'
echo 'The following root filesystems were detected:';
for (( i = 0; i < ${#possible_root_list[@]}; i++ )); do
    if [ "${host_os_name}" = "${os_list[i]}" ]; then
        echo "${i}: ${possible_root_list[i]}: ${os_list[i]} (this is probably the OS you tried to boot)";
        default_choice="${i}"
    else
        echo "${i}: ${possible_root_list[i]}: ${os_list[i]}";
    fi
done

echo
echo 'Type the number of the OS you wish to attempt booting, and press Enter.'
echo 'Alternatively, type "n" and press Enter to cancel.'
echo
read -r -p "Select your choice (default ${default_choice}) " user_choice

[ -z "${user_choice}" ] && user_choice="${default_choice}"
[ "${user_choice}" = 'n' ] && exit
! [[ "${user_choice}" =~ ^[0-9]*$ ]] && invalid_exit
user_choice="$(printf '%d\n' "${user_choice}" 2>/dev/null)"
(( user_choice >= i )) && invalid_exit

partition="${possible_root_list[user_choice]}"
filesystem="$(get_fstype "${partition}")"
if [ "${filesystem}" = 'crypto_LUKS' ]; then
    echo "Partition ${partition} needs to be decrypted to mount."
    if cryptsetup luksOpen "${partition}" 'automount_crypt'; then
        mount_partition '/dev/mapper/automount_crypt' "$NEWROOT"
    else
        echo 'Failed to mount partition!'
        exit
    fi
else
    mount_partition "${partition}" "$NEWROOT"
fi

echo 'Done. Type "exit" and press Enter to attempt boot.'
