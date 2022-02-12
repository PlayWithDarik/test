#!/bin/bash

echo 'Прописываем имя компьютера'
cat > /etc/hostname <<EOF
archlinux
EOF

echo 'Часовой пояс'
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
hwclock --systohc

echo 'Локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
locale-gen

echo 'Указываем язык системы'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Добавляем пользователя'
useradd -m -g users -G wheel,audio,video,storage -s /bin/bash darii

echo 'Создаем root пароль'
passwd

echo '3.5 Устанавливаем загрузчик'
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo 'Ставим иксы и драйвера'
pacman -S xorg-server xorg-drivers xorg-xinit

echo 'Микрокод'
pacman -S amd-ucode --noconfirm
 
 echo 'hosts.'
cat > /etc/hosts <<EOF
# Static table lookup for hostname
# See hosts(5) for detalis

127.0.0.1        localhost
::1              localhost
127.0.1.1        archlinux.localdomain    archlinux
EOF

echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager

echo 'программы'
pacman -S alsa-lib alsa-utils gvfs aspell-ru pulseaudio --noconfirm

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu wqy-zenhei --noconfirm 

echo "Выбираем DE"
read -p "1 - XFCE, 2 - KDE: " de_setting
if   [[ $de_setting == 1 ]]; then
  pacman -S xfce4 xfce4-goodies --noconfirm
elif [[ $de_setting == 2 ]]; then
  pacman -S plasma-desktop konsole plasma-nm plasma-pa packagekit-qt5 dolphin --noconfirm
fi

echo 'Выбираем DM'
read -p "1 - LIGHTDM, 2 - SDDM: " dm_setting
if   [[ $dm_setting == 1 ]]; then
  pacman -S lightdm lightdm-gtk-greeter-settings lightdm-gtk-greeter --noconfirm
  systemctl enable lightdm.service -f
elif [[ $dm_setting == 2 ]]; then
  pacman -S sddm sddm-kcm --noconfirm
  systemctl enable sddm.service -f
fi

echo 'Установка завершена! Перезагрузите систему.'
exit
umount -R /mnt
