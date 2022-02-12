#!/bin/bash

loadkeys ru
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true

echo 'Создание разделов'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +4096M;

  echo n;
  echo p;
  echo;
  echo;
  echo a;
  echo 2;

  echo w;
) | fdisk /dev/sda

echo 'Ваша разметка диска'
fdisk -l

echo 'Форматирование дисков'
mkswap /dev/sda1
mkfs.ext4 /dev/sda2

echo 'Монтирование дисков'
mount /dev/sda2 /mnt
swapon /dev/sda1

echo 'Зеркала для загрузки.'
cat > /etc/pacman.d/mirrorlist <<EOF
##
## Arch Linux repository mirrorlist
## Generated on 2022-02-11
##
## Ukraine
Server = https://archlinux.astra.in.ua/\$repo/os/\$arch
Server = https://repo.endpoint.ml/archlinux/\$repo/os/\$arch
Server = https://archlinux.ip-connect.vn.ua/\$repo/os/\$arch
Server = https://mirror.mirohost.net/archlinux/\$repo/os/\$arch
Server = https://mirrors.nix.org.ua/linux/archlinux/\$repo/os/\$arch
EOF

echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware nano dhcpcd netctl dbus e2fsprogs

echo 'Настройка системы'
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL bit.ly/3rH9EM7)"
