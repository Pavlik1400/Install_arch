# Installing Arch

*The basis for this tutorial is [this one](https://sollus-soft.blogspot.com/2017/01/arch-linux-windows-10-uefi-systemd-boot.html)*

# Preparing
First of all, install arch ISO on your USB stick. [Here](https://www.archlinux.org/download/) you can find an official image. 

I recomend using [RUFUS](https://rufus.ie/) for proper image installation under Windows. Choose everything as you see on this photo: 
![](images/rufus.PNG)

Under Linux I recommend "dd":
$ sudo dd bs=4M if=path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync

**Important!** all files from USB-stick will be deleted

Now go to the BIOS (press F2 or F8 or smth else on you laptop during booting), and choose `UEFI mode` and change boot order (make your USB first prior). result should be something like that:

![](images/bios.jpg)

Save changes and exit

# Main part of installation
Firstly check if you're loaded in EFI mode: `efivar -l`. The output should be like this: 
![](images/efivar.png)

On some computers Wifi won't work without turning the module on with this  command: `rfkill unblock all`

Now let's turn on Wifi. Firstly get name of your interface: `ip link` (it usually starts with 'w', i.e: 'wlan0') 
Then activate the interface: `ip link set interface_name up`.

First method: `iwctl` 
```
iwctl
station interface_name scan
station interface_name get-networks
station interface_name connect network_name
```

Example of turning on wifi:

![](images/iwctl.jpg)

Check if internet works with `ping google.com` (should appear messages with '64 bytes' at the beginning, press CTRL+C to finish check)

Time synchronization: `timedatectl set-ntp true`

Now let's look at your previous boot records: `efibootmgr` and delete previous linux or some other stuff: `efibootmgr -b X -B`, where 'X' is number of stuff's boot

Here is how it should look like

![](images/efibootmgr.png)

Now disk management: `cfdisk`. Here I delete everything from previous system and 
- choose  root directory (about 50GB, linux filesystem) 
- boot partition (1GB, EFI filesystem) (Actually it's better to install bootloader on the Windows EFI partition, if you want to see choise of system during loading). 
- Create (or do nothing if you already have) home directory (40GB, linux filesystem). 
- Create swap partition (4-8GB, Linux swap)
Don't forget to "write" after making new partition. And don't delete Windows partitions if you want dual boot.

Here, how it looks on my laptop:
![](images/cfdisk.png)
As you can see I have 64GB root (/dev/sda11), 33GB home (/dev/sda10) 20GB swap (/dev/sda5), and my boot is /dev/sda3. Remeber, that on your laptop/PC, there will be other partition numbers.

Now format partition and mount them. Root:
```
mkfs.ext4 /dev/sda{root number} -L "ARCH"
mount /dev/sda{root number} /mnt
```
Boot:
```
mkdir -p /mnt/boot
mkfs.fat -F32 /dev/sda{boot number}
mount /dev/sda{boot number} /mnt/boot
```
Or just mount Windows EFI partition, if you didn't create new one
```
mount /dev/sda{windows boot number} /mnt/boot
```
Swap:
```
mkswap /dev/sda{swap num}
swapon /dev/sda{swap num}
```

Now let's update pacman: `pacman  -Syy`

Install base system and packet for future AUR using: `pacstrap /mnt base linux linux-firmware base-devel linux-headers`

Generate fstab: `genfstab -U /mnt >> /mnt/etc/fstab`
Check if it is generated: `nano /mnt/etc/fstab`

Example fstab(don't forget to change filesystem UUIDs (you can find them in 'cfdisk')): 
```
UUID=8d3f44f4-a017-4c76-9e66-dd5068dc5397	/         	ext4      	rw,relatime,discard	0 1

UUID=2f671175-0fe6-472a-a4b0-1da5345f03e1	/home     	ext4      	rw,relatime,discard	0 2

UUID=1892-CB1C      	/boot     	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro	0 2
```
!!**IMPORTANT**!! If you have SSD, than this is extremely important to automatically activate TRIM each time it's needed. This will save lifetime of your SSD. So please, add 'discard' option to mount points in fstab (as you can see in the example)

Now let's go in arch: `arch-chroot /mnt `

It is good idea to download an adequate text editor at the beggining: `pacman -S vim`

super short guide for vim: 
- i - go to 'insert' mode (you can type in this mode!)
- Esc - back to 'normal' mode
- :w - write to file (in normal mode)
- :q - quit from file (again, in normal mode) (you can combine: ':wq') 

Adjust locals: `vim /etc/locale.gen` and uncomment
```
en_US.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8
uk_UA.UTF-8 UTF-8
```
Don't forget to save

**User-related stuff**

Adjust time zone and time : 
```
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
hwclock --systohc
```

Adjust the name of the computer: `vim /etc/hostname` and write there _"YOUR_USERNAME"_

Adjust hosts: `vim /etc/hosts` and write there -

```
127.0.0.1 localhost
::1 	    localhost
127.0.1.1 pasha.localdomain pasha
``` 


Password for root: `passwd` 

Add new user: `useradd -G wheel -s /bin/bash -m YOUR_USERNAME`, and give him sudo permissions: `vim /etc/sudoers` 
and uncomment _"%wheel ALL=(ALL) ALL"_

**note** if /etc/sudoers is readonly, try `visudo`

user's password: `passwd YOUR_USERNAME`

Download some potentially useful stuff: `pacman -S efibootmgr iwd netctl ntfs-3g htop dhcp`.

**Boot configuration**

Install bootloader: `bootctl install`

Loader config: `vim /boot/loader/loader.conf`

Example loader: 
```
default arch
timeout 2
editor 0
```
(It will wait 2 seconds before running into default choice - arch, editor 0 means you can't change loader parameters during boot(this is for security))

Now it is vital to adjust kernel settings: 
```
pacman -S intel-ucode
pacman -S linux
vim /boot/loader/entries/arch.conf
```
Write here something like this (maybe you will need to change them in the future):
```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root="LABEL=ARCH" rw
```
Now exit and umount all partition:
```
exit
umount -R /mnt
reboot
```

**Graphics**

Install X: `sudo pacman -S xorg-server xorg-xinit xorg-apps mesa-libgl xterm`

Install graphic drivers:
```
sudo pacman -S xf86-video-intel
sudo pacman -S nvidia #if you have nvidia GPU
```

To make nvidia render gui (tested only on KDE):
- use additional options from arch.conf
- add `xrandr --auto` to `/etc/X11/xinit/xinitrc`

# GNOME installation & customizaton

GNOME itself:
```
sudo pacman -Syu
sudo pacman -S gnome
systemctl enable NetworkManager
systemctl enable gdm
```

Lenovo y530 (my laptop) can't render HDMI output with intel GPU, so if you want to use second monitor, read [here](https://wiki.archlinux.org/index.php/PRIME#PRIME_render_offload)
Also download prime-run (for running application with nvidia GPU(if you have nvidia): `sudo pacman -S prime-run`

Now customization. First of all set normal wallpalers, change touchpad sensitivity and other settings in GNOME

```
yay gnome-tweaks
```

Also it's quite useful to configurate your touchpad gestures with [this](https://github.com/bulletmark/libinput-gestures) application, if you're using xorg on gnome

Download all extension and setup tweaks as you like (dash to panel / dash to dock, DropDownTerminal, PanelOSD)

**Appereance**:
- Theme: vimix-dark-laptop
- Font: google-sans-regular
- Cursor: Bibata-original-ice
- Icons: numix-circle/shadow

# KDE Installation & customization
*don't install KDE and Gnome at the same time!!!*

KDE itself:
```
sudo pacman -Syu
sudo pacman -S plasma
sudo pacman -S NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl enable sddm.service
```
reboot after installation

How to enable nvidia - go to GNOME installation part

Other important applications:
```
yay konsole vlc dolphin gwenview lollypop exa
```

**Appereance**:
- Theme: Chrome os dark
- Font: open sans
- Cursor: google dot black
- Icons: Tela circle black

widgets:
Application Launcher
Pager
Icons-only task manager
Total CPU usage
Memory usage
System Tray
Battery and Brightness
Digital Clock
Show Desktop

Main panel & window should look like this:
![](images/KDE-look.png)

# System configuration

Python: 
```
sudo pacman -S python-pip ipython
# conda:
wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
sudo chmod +x Anaconda3-2021.11-Linux-x86_64.sh
./Anaconda3-2021.11-Linux-x86_64.sh
```

Java:
```
sudo pacman -S jdk11-openjdk jdk8-openjdk java11-openjfx java8-openjfx
```

Terminal emulator: `sudo pacman -S tilix`

git: `sudo pacman -S git`

**Battery optimization**:
```
sudo pacman -S tlp
sudo tlp start
sudo systemctl enable tlp.service
```
Bluetooth configuration:
```
yay bluez bluez-utils bluez-libs
#if btusb is not connected, then
modprobe btusb
sudo systemctl enable --now bluetooth.service
```

It's a good idea to create new **mirrorlist** file for Pacman, if you from Ukraine, you can use this: (replace it in /etc/pacman.d/mirrorlist)
```
## Ukraine
Server = http://archlinux.ip-connect.vn.ua/$repo/os/$arch
Server = https://archlinux.ip-connect.vn.ua/$repo/os/$arch
Server = http://mirror.mirohost.net/archlinux/$repo/os/$arch
Server = https://mirror.mirohost.net/archlinux/$repo/os/$arch
Server = http://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
Server = https://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
```

yay: `git clone https://aur.archlinux.org/yay.git; cd yay; makepkg -si`

**zsh installation** and customization with oh-my-zsh:
```
cd ~
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```
**Browser**
```
yay firefox
```
Don't forget to sign in gmail, youtube, CMS, etc.

Also take all dot files, configure vim plugins, .zshrc, etc.

# Apps for work
**Code editors**: 
```
yay visual-studio-code-insiders clion pycharm-community-edition intellij-idea-community-edition
```

Don't forget to install material theme and set 16's source code pro font in jetBrains programs

**Communication**:
```
yay teams slack-desktop telegram-desktop viber zoom
```

**Useful tools**:
```
yay flameshot simplescreenrecorder cmake gparted zip unzip
```

STM32. Install eveything except eclipse from [this tutorial](https://gist.github.com/Myralllka/42385fdecacb7cc2a45ec9376b57a4b2)
After this download STM32CubeMX itself from [official site](https://www.st.com/en/development-tools/stm32cubemx.html)
Then unzip script, give permissions to run it (chmod +x scriptname.sh) and run it with sudo

Then if you will have problems with debuggger run those commands:
```
cd /usr/lib
sudo ln -s libncursesw.so.6.1 libncurses.so.5
sudo ln -s libncursesw.so.6.1 libtinfo.so.5
```
Follow [this tutorial](https://cms.ucu.edu.ua/pluginfile.php/181558/mod_resource/content/1/CLion_STM32_Settings.pdf) to work with STM32 through CLion: 

Quartus Prime:
```
yay quartus-free quartus-free-modelsim quartus-free-quartus quartus-free-devinfo-cyclone quartus-free-help
```

Looks like that's it. Happy archlinux experience!

