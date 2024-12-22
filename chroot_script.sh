#!/bin/bash
set -e
trap 'echo "An error occurred on line $LINENO. Exiting..."; exit 1' ERR

ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "KEYMAP=en" > /etc/vconsole.conf
echo "SecuArch" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 SecuArch
EOF
echo "Enter a password for root:"
passwd
echo "Enter a username for the new user:"
read username
useradd -mG wheel $username
echo "Enter a password for $username:"
passwd $username
sed -i '/# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
echo "Base System install complete. Do you want to reboot now? (yes/no)"
read reboot_now
if [ "$reboot_now" == "yes" ]; then
    umount -R /mnt
    reboot
else
    echo "You can reboot later with the 'reboot' command."
fi