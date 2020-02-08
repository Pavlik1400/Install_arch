# Install_arch
Hello, my name is Pasha and this is my guide of Arch linux installation. I made it personally for myself, because I'm always accidentally destroy my system. But if you like it, you can use it.
Actually some things, like kernel config, You have to adjust yourself. But if you have Lenovo LEGION y530, tham
this is ideal guide for you

# Archlinux installation

So the main installation of the system I took from [This site](https://sollus-soft.blogspot.com/2017/01/arch-linux-windows-10-uefi-systemd-boot.html)

Firstly check if you're loaded in EFI mode:`evivar -l`

On my computer wifi won't work without this command: `rfkill unblock all`

Now turn on the Wifi: `wifi-menu`. In given menu choose the your wifi and type password

Time synchronization: `timedatectl set-ntp true`

Now let's look at your previous boot records: `efibootmgr` and delete previous linux or some other shit: `efibootmgr -b X -B`, where 'X' is number of shit's boot

Now disk management: `cfdisk`. Usually I don't make swap partition. Here I delete everything from previous system and 
choose my root directory (about 65GB, linux filesystem) and new boot partition (1GB, EFI filesystem). Don't 
touch home directory (15GB). Don't forget to "write" after making new partition. 

Now format partition and mount them. Root:
```
mkfs.ext4 /dev/sda{root number} -L "ARCH"
mount /dev/sda{root number} /mnt
```
Boot:
```
mkdir -p /mnt/boot
mkfs.fat -F32 /dev/sd{boot number}
mount /dev/sda2 /mnt/boot
```

Now let's update a pacman: `pacman  -Syy`

Install base systen and packet for future AUR using: `pacstrap /mnt base linux linux-firmware base-devel`

Generate fstab: `genfstab -U /mnt >> /mnt/etc/fstab`

Check if the shit is generated: `nano /mnt/etc/fstab`

Now let's go in arch: `arch-chroot /mnt `

It is immportant to donwload text editor at the beggining: `pacman -S neovim`

Adjust locals: `nvim /etc/locale.gen` and uncomment
```
en_US.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8
uk_UA.UTF-8 UTF-8
```
Don't forget to save

Adjust time zone and time : 
```
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
hwclock --systohc
```

Adjust name of computer: `nvim /etc/hostname` and write there _"userhost - pavlik_giley"_

Adjust hosts: `nvim /ets/hosts` and write there -"27.0.0.1 pavlik_giley.localdomain pavlik_giley
"-. DONT FORGET TO SAVE EVERYTHING

Password for root: `passwd` 

Add new user: `useradd -G wheel -s /bin/bash -m pasha`, and give him sudo permissions: `nvim /etc/sudoers` 
and uncomment _"%wheel ALL=(ALL) ALL"_

pasha's password: `passwd pasha`

Download some potentially useful shit: `pacman -S  efibootmgr iw wpa_supplicant dialog netctl dhcpcd`.
And more: `pacman -S ntfs-3g mtools fuse2`

Install bootloader: `bootctl install`

Loader config: `nvim /boot/loder/loader.conf` and write there 
```
default arch                   
timeout 1
editor 1
```

Now it is vital to adjust kernel settings: 
```
pacman -S intel-ucode
nvim /boot/loader/entries/arch.conf
```
Write here :
```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
modprobe nouveau
options modprobe.blacklist=nouveau acpi_backlight=nomodeset quiet splash root=/dev/sda{root number} rw
```

Now exit and umount all partition:
```
exit
umount -R /mnt
reboot
```

# GNOME installation

Install X: `sudo pacman -S xorg-server xorg-xinit xorg-apps mesa-libgl xterm`

Install all drivers:
```
sudo pacman -S xf86-video-intel
sudo pacman -S xf86-video-nouveau
```

Now install GNOME itself:
```
sudo pacman -Syu
sudo pacman -S gnome
systemctl enable NetworkManager
systemctl enable gdm
```

# System customization and apps installation
First of all set normal wallpalers (black color for example), change touchpad sensitivity and other settings

Python: 
```
sudo pacman python-pip
sudo pacman ipython
pip install virtualenv
pip install pyenv
```

Battery optimization:
```
sudo pacman -S tlp
sudo tlp start
```

Terminal: `sudo pacman -S terminator`

git: `sudo pacman -S git`

yay: `git clone https://aur.archlinux.org/yay.git; cd yay; makepkg -si`

zsh instllation and customization (through oh my zsh):
```
cd ~
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
nvim ~/.zshrc # Here change theme to "agnoster". 
Add this to an end of the .zshrc
'''
alias x="exit"
alias sps="sudo pacman -S"
prompt_context(){}
source /home/pasha/syntax/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#
source /usr/bin/virtualenvwrapper.sh
# 
export PATH="/home/pasha/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
'''
```

Some "entertainment": 
```
yay telegram-desktop
yay google-chrome
```
Don't forget to sign in gmail, youtube, CMS, etc.

CUSTOMIZATION
```
sps gnome-tweaks
```
In tweaks change font to 1.21, choose dark theme, turn everything on in 'clock', battery percentage
In tweaks install in 'Software' "dash to dock", "Desktop icons"
In "dash to dock" choose botoom position, intelligence autohide, hide application icon, hide trash
In  "Desktop icons" hide trash, add link to Documents and Download on Desktop

Also important to install proper icons: `numix-circle-icon-theme-git`, then activate in tweaks

Install VScode: `yay visual-studio-code-insiders`

Cion `yay clion #chose just clion`. Don't forget to activate licension and type path to compilers and debugger

Eclipse: `yay eclipse-java`

Pycharm `yay pycharm #choose community version` Don't forget to install material theme and set 18's font

STM32. Install eveything except eclipse from [this tutorial](https://gist.github.com/Myralllka/42385fdecacb7cc2a45ec9376b57a4b2)
After this download STM32 itself from [official site](https://www.st.com/en/development-tools/stm32cubeide.html)
Then unzip script, give permissions to run it (chmod +x scriptname.sh) and run it with sudo
Them create script "RUN_STM.sh", because if running from icon, you won't be able to create project:
```
touch RUN_STM.sh
nvim RUN_STM.sh
# and type this
'''
#!/bin/bash
GDK_BACKEND=x11
export GDK_BACKEND
/opt/st/stm32cubeide_1.1.0/stm32cubeide
'''
```
Then if you will have problems with debuggger run those commands:
```
cd /usr/lib
sudo ln -s libncursesw.so.6.1 libncurses.so.5
sudo ln -s libncursesw.so.6.1 libtinfo.so.5
```

Looks, like that's it. Happy archlinux experience `echo ":)"`
