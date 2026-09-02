#!/bin/sh

trap 'poweroff -f' EXIT
set -e

modprobe btrfs || :
mkfs.btrfs -q -L dracut /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root
printf verySecurePassword > keyfile
cryptsetup --pbkdf pbkdf2 -q luksFormat /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root_crypt /keyfile
cryptsetup luksOpen /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root_crypt dracut_crypt_test < /keyfile
mkfs.btrfs -q -L dracut_crypt /dev/mapper/dracut_crypt_test
mkfs.btrfs -q -L dracutusr /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_usr
btrfs device scan /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root
btrfs device scan /dev/mapper/dracut_crypt_test
btrfs device scan /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_usr
mkdir -p /root /root_crypt
mount -t btrfs /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root /root
mount -t btrfs /dev/mapper/dracut_crypt_test /root_crypt
[ -d /root/usr ] || mkdir -p /root/usr
[ -d /root-crypt/usr ] || mkdir -p /root_crypt/usr
mount -t btrfs /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_usr /root/usr
btrfs subvolume create /root/usr/usr
umount /root/usr
mount -t btrfs -o subvol=usr /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_usr /root/usr
mount --bind /root/usr /root_crypt/usr
cp -a -t /root /source/*
for path in /source/*; do
    [ "${path##*/}" = usr ] && continue
    cp -a "$path" /root_crypt
done
mkdir -p /root/run /root_crypt/run
btrfs filesystem sync /root/usr
btrfs filesystem sync /root
btrfs filesystem sync /root_crypt/usr
btrfs filesystem sync /root_crypt
umount /root/usr /root_crypt/usr
umount /root /root_crypt
cryptsetup luksClose /dev/mapper/dracut_crypt_test
eval "$(udevadm info --query=property --name=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_root_crypt | while read -r line || [ -n "$line" ]; do [ "$line" != "${line#*ID_FS_UUID*}" ] && echo "$line"; done)"
{
    echo "dracut-root-block-created"
    echo "ID_FS_UUID=$ID_FS_UUID"
} | dd oflag=direct of=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_marker status=none
sync
exit 0
