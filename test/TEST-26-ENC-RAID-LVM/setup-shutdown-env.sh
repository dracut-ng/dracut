#!/bin/sh

# Creates a single-disk LVM-on-LUKS root filesystem for the shutdown test

trap 'poweroff -f' EXIT
set -ex

printf verySecurePassword > keyfile
cryptsetup --pbkdf pbkdf2 -q luksFormat /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_disk1 /keyfile
cryptsetup luksOpen /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_disk1 vault < /keyfile

lvm pvcreate -ff -y /dev/mapper/vault
lvm vgcreate dracut /dev/mapper/vault
lvm lvcreate --yes -l 100%FREE -n root dracut
lvm vgchange -ay

mkfs.ext4 -q /dev/dracut/root
mkdir -p /sysroot
mount -t ext4 /dev/dracut/root /sysroot
cp -a -t /sysroot /source/*
umount /sysroot

lvm lvchange -a n /dev/dracut/root
lvm vgchange -an
cryptsetup luksClose vault

{
    echo "dracut-root-block-created"
    udevadm info --query=property --name=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_disk1 \
        | grep 'ID_FS_UUID='
} | dd oflag=direct of=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_marker status=none
sync
