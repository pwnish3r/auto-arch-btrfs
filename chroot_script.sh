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
useradd -mG wheel $username || true
echo "Enter a password for $username:"
passwd $username

visudo -cf /etc/sudoers.tmp
echo "$(sed '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers)" | tee /etc/sudoers.tmp
visudo -c -f /etc/sudoers.tmp && mv /etc/sudoers.tmp /etc/sudoers

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
su - "$username" <<EOF
cd ~
mkdir -p auxiliary_scripts
cd auxiliary_scripts
git clone https://github.com/pwnish3r/SecuArch.git
chmod +x SecuArch/postInstall/after_install_*.sh
sudo systemctl enable SecuArch/script-scheduler.service
EOF

echo "Base System install complete. Do you want to reboot now? (yes/no)"
read reboot_now
if [ "$reboot_now" == "yes" ]; then
    umount -R /mnt || true
    <<EOF
    exit
    reboot
    EOF
else
    echo "You can reboot later with the 'reboot' command."
fi
