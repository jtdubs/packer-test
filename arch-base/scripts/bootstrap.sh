#!/usr/bin/env bash

set -eu

echo "Setting clock..."
timedatectl set-ntp true

echo "Partitioning disk..."
sgdisk --zap-all /dev/sda
wipefs --all /dev/sda
sgdisk --new=1:0:+512M --typecode=1:EF00 --change-name 1:BOOT /dev/sda
mkfs.fat -F32 /dev/sda1
sgdisk --new=2:0:+2G --typecode=2:8200 --change-name 2:SWAP /dev/sda
mkswap /dev/sda2
sgdisk --new=3:0:0 --typecode=3:8300 --change-name 3:ROOT /dev/sda
mkfs.ext4 -L "Arch Root" /dev/sda3

echo "Creating EFI boot entry..."
efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode "root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) rw initrd=\initramfs-linux.img" --verbose
efibootmgr --bootorder 0004

echo "Mounting filesystems..."
mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

echo "Bootstrapping..."
pacstrap /mnt base linux linux-firmware man-db man-pages
genfstab -U /mnt >> /mnt/etc/fstab

echo "Placing chroot files..."
chmod a+x /tmp/install.sh
mv /tmp/install.sh /mnt
mv /tmp/packer_id_rsa.pub /mnt
