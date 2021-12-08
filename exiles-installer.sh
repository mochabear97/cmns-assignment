#! /bin/bash

# A simple Arch Linux install script.

#################
#   Functions   #
#################

# Green text print.
print () {
    echo -e "\x1b[1;32m$1\e[0m"
}

# Blue text print info.
print_i () {
    echo -e "\x1b[1;94m[i] $1\e[0m"
}

# Blue text print info (without the [i]).
print_b () {
    echo -e "\x1b[1;94m$1\e[0m"
}

# Yellow text print warnings.
print_w () {
    echo -e "\x1b[0;33m[w] $1\e[0m"
}

# Yellow text print warnings (without the [w]).
print_y () {
    echo -e "\x1b[0;33m$1\e[0m"
}

# Check if script is being ran as root and exit if it isn't.
root_check () {
    if [ "$EUID" -ne 0 ]
        then
        print_w "Please run this sript as root."
        sleep 3.0s
        exit
    fi
}

# Welcome screen.
welcome () {
    print "##############################"
    print "#                            #"
    print "#   Exile's Arch Installer   #"
    print "#                            #"
    print "#   Author: The Exiles       #"
    print "#   Version: 1.0.0           #"
    print "#                            #"
    print "##############################"
    echo -e "\n"
    print_w "NOTE: this install script is intended for"
    print_y "UEFI based systems and does not support BIOS boot."
}

# Ask the user if they want to install this script.
continue_check () {
    read -r -p "[?] Would you like to continue? (y/n): " choice
    case $choice in
        [Yy] ) print "continuing..."
               sleep 3.0s
               ;;
        [Nn] ) exit
               ;;
          "" ) print "continuing..."
               sleep 3.0s
               ;;
           * ) print_w "You did not enter a valid selection."
               continue_check
    esac
}

# Initialize the program after welcome.
intitialization () {
   clear
   print "Initializing..."
   timedatectl set-timezone "$(curl -s http://ip-api.com/line?fields=timezone)"
   timedatectl set-ntp true
   sleep 3.0s
}

# Selecting a disk to install Arch Linux on.
disk_selector () {
    clear
    print "Please select the disk where Arch Linux will be installed:"
    select ENTRY in $(lsblk -dpnoNAME | grep -P "/dev/sd|nvme|");
    do
        DISK=$ENTRY
        print "Arch Linux will be installed on $DISK"
        break
    done
}

# Check disk is correct (function).
disk_confirm () {
    read -r -p "This will delete the current partition table on $DISK. Do you agree? (y/n): " response
    case $response in
        [Yy] ) print "Wiping $DISK..."
               wipefs -af "$DISK"
               sgdisk -Zo "$DISK"
               sleep 3.0s
               ;;
        [""] ) print "Wiping $DISK..."
               wipefs -af "$DISK"
               sgdisk -Zo "$DISK"
               sleep 3.0s
               ;;
        [Nn] ) print "Exiting script..."
               sleep 3.0s
               exit
    esac
}

# Hibernation ask
hibernation_selector () {
    clear
    print_i "Hibernation is when you put a computer to sleep and store"
    print_b "temporary data onto the hard disk instead of memory."
    read -r -p "Will you use hibernation at all with your new system? (y/n)" choice
    case $choice in
        "" ) hibernation=yes
            ;;
        [Yy] ) hibernation=yes
              ;;
        [Nn] ) hibernation=no
              ;;
        * )
    esac
}

# Ask about memory size and set swap varriable accoringly. [IN PROGRESS]
mem_selector () {
    clear
    print "Please enter how much RAM (memory) your system contains."
    print_i "Available Sizes: 8, 12, 16, 24, 32, 64 & 128"
    read -r -p "A size of 8GB or greater is required. (8-128): " choice
    case $choice in
        8 ) mem=8
           ;;
        12 ) mem=12
            ;;
        16 ) mem=16
            ;;
        24 ) mem=24
            ;;
        32 ) mem=32
            ;;
        64 ) mem=64
            ;;
        128 ) mem=128
             ;;
        * ) print_w "Please enter a valid size."
            sleep 5.0s
            swap_selector
           ;;
    esac
}

# Select swap size based on whether hibernation was selected and RAM size.
swap_selector () {
    # With hibernation.
    if [ $mem == 8 ] && [ $hibernation == yes ]
        then
        swap_size=11
    fi

    if [ $mem == 12 ] && [ $hibernation == yes ]
        then
        swap_size=15
    fi

    if [ $mem == 16 ] && [ $hibernation == yes ]
        then
        swap_size=20
    fi

    if [ $mem == 24 ] && [ $hibernation == yes ]
        then
        swap_size=29
    fi

    if [ $mem == 32 ] && [ $hibernation == yes ]
        then
        swap_size=38
    fi

    if [ $mem == 64 ] && [ $hibernation == yes ]
        then
        swap_size=72
    fi

    if [ $mem == 128 ] && [ $hibernation == yes ]
        then
        swap_size=139
    fi

    # Without hibernation.
    if [ $mem == 8 ] || [ $mem == 12 ] && [ $hibernation == no ]
        then
        swap_size=3
    fi

    if [ $mem == 16 ] && [ $hibernation == no ]
        then
        swap_size=4
    fi

    if [ $mem == 24 ] && [ $hibernation == no ]
        then
        swap_size=5
    fi

    if [ $mem == 32 ] && [ $hibernation == no ]
        then
        swap_size=6
    fi

    if [ $mem == 64 ] && [ $hibernation == no ]
        then
        swap_size=8
    fi

    if [ $mem == 128 ] && [ $hibernation == no ]
        then
        swap_size=11
    fi
}

# Creating a new partition scheme.
create_partitions () {
    clear
    print "Creating the partitions on $DISK..."
    parted -s "$DISK" \
        mklabel gpt \
        mkpart ESP fat32 1MiB 251MiB \
        set 1 esp on \
        mkpart primary linux-swap 251Mib "$swap_size".26GiB \
        mkpart primary ext4 "$swap_size".26GiB 100% \
    sleep 10.0s
}

# Format disk partitions
format_partitions () {

    if [[ "$DISK" == *"nvme"* ]]
        then
        clear
        print "Formatting partitions now..."

        mkfs.ext4 -F "$DISK"p3
        mkswap "$DISK"p2
        mkfs.fat -F 32 "$DISK"p1
        mount "$DISK"p3 /mnt
        mkdir /mnt/efi
        mount "$DISK"p1 /mnt/efi
        swapon "$DISK"p2
    fi

    if [[ "$DISK" == *"sd"* ]]
        then
        clear
        print "Formatting partitions now..."

        mkfs.ext4 -F "$DISK"3
        mkswap "$DISK"2
        mkfs.fat -F 32 "$DISK"1
        mount "$DISK"3 /mnt
        mkdir /mnt/efi
        mount "$DISK"1 /mnt/efi
        swapon "$DISK"2
    fi
    sleep 5.0s
}

# Detect microcode (AMD/INTEL).
microcode_detector () {
    clear
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ $CPU == *"AuthenticAMD"* ]]; then
        print "An AMD CPU has been detected, AMD microcode will be installed."
        sleep 3.0s
        microcode="amd-ucode"
    else
        print "An Intel CPU has been detected, Intel microcode will be installed."
        sleep 3.0s
        microcode="intel-ucode"
    fi
}

# Selecting a kernel to install.
kernel_selector () {
    clear
    print "***Kernels***"
    print "\n1) Vanilla: Stable Linux kernel with a few specific Arch Linux patches applied"
    print "2) Hardened: A security-focused Linux kernel"
    print "3) LTS: Long-term support (LTS) Linux kernel"
    print "4) Zen: A Linux kernel optimized for desktop usage"
    read -r -p "Insert the number of the corresponding kernel. (1-4): " choice
    case $choice in
        1 ) kernel="linux"
            ;;
        2 ) kernel="linux-hardened"
            ;;
        3 ) kernel="linux-lts"
            ;;
        4 ) kernel="linux-zen"
            ;;
        * ) print "You did not enter a valid selection."
            sleep 3.0s
            clear
            kernel_selector
    esac
}

# Selecting network Utility.
network_selector () {
    clear
    print "***Network Utilities***"
    print "\n1) IWD: iNet wireless daemon is a wireless daemon for Linux written by Intel (WiFi-only)"
    print "2) dhcpcd: Basic DHCP client (Ethernet only or VMs)"
    print "3) NetworkManager: Universal network utility to automatically connect to networks (both WiFi and Ethernet)"
    print "4) I will do this on my own (ADVANCED USERS ONLY)"
    read -r -p "Insert the number of the corresponding networking utility. (1-4): " choice
    case $choice in
        1 ) print "Installing IWD."
            pacstrap /mnt iwd
            sleep 2.0s
            print "Enabling IWD."
            systemctl enable iwd --root=/mnt &>/dev/null
            sleep 2.0s
            ;;
        2 ) print "Installing dhcpcd."
            pacstrap /mnt dhcpcd
            sleep 2.0s
            print "Enabling dhcpcd."
            systemctl enable dhcpcd --root=/mnt &>/dev/null
            sleep 2.0s
            ;;
        3 ) print "Installing NetworkManager."
            pacstrap /mnt networkmanager
            pacstrap /mnt dhcpcd
            sleep 2.0s
            print "Enabling NetworkManager."
            systemctl enable NetworkManager --root=/mnt &>/dev/null
            systemctl enable dhcpcd --root=/mnt &>/dev/null
            sleep 2.0s
            ;;
        4 ) ;;
        * ) print_w "You did not enter a valid selection."
            sleep 2.0s
            clear
            network_selector
    esac
}

# Select a desktop envrionment to be installed.
desktop_select () {
  clear
  print "**Desktop Environments Menu**"
  print "\n1) Cinnamon"
  print "2) GNOME"
  print "3) KDE"
  print "4) XFCE"
  print "0) None (Advanced Users)"
  read -r -p "Please select an option: " choice
  case $choice in
    0 ) clear
        print "You selected to not install a desktop environment."
        sleep 5.0s
        ;;
    1 )	desktop=Cinnamon
        clear
        echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
        print "$desktop is a desktop environment best suited for"
        print "users who most comfortable with Windows 7"
	      de_selection_check
	      ;;
    2 ) desktop=GNOME
        clear
	      echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
        print "$desktop is a very simplistic modern desktop environment"
        print "best suited for users who are used to OSX(Macintosh)"
	      de_selection_check
	      ;;
    3 ) desktop=KDE
        clear
	      echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
        print "$desktop is a very modern desktop environment built"
        print "with Windows 10/11 users in mind"
	      de_selection_check
        ;;
    4 ) desktop=XFCE
        clear
        echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
	      print "$desktop is an older desktop environment closely"
        print "resembling Windows XP in terms of look and feel."
        print "This DE is best suited for computers with older hardware."
        de_selection_check
	      ;;
    * ) print_w "That is not a valid selection."
        print_w "Please try again."
        sleep 2.0s
	      desktop_select
  esac
}

# Selection Check for desktop environment.
de_selection_check () {
  read -r -p $'\e[0;33m[?] Is this correct? (y/n):\e[0m ' choice
  case $choice in
    [Yy] ) sleep 3.0s
           ;;
    [Nn] ) print "Please try again."
	         sleep 2.0s
	         clear
           desktop_select
	         ;;
    * ) selection_check
  esac
}

# Install a desktop environment of choice.
de_install () {
  if [ $desktop == Cinnamon ]
     then
     clear
     print "Cinnamon desktop environemnt will now be installed."
     print "Along with some other useful applications."
     sleep 3.0s
     clear
     pacstrap /mnt archlinux-appstream-data audacity binutils \
      blueberry bottom bzip2 chromium cinnamon coin-or-mp cups cups-pdf dpkg exa \
      file-roller galculator gimp gnome-disk-utility gnome-keyring \
      gnome-terminal gpick gvfs libmythes libpaper libreoffice-fresh libwpg \
      lightdm lightdm-gtk-greeter lollypop meld neofetch networkmanager \
      network-manager-applet npm p7zip papirus-icon-theme pavucontrol pstoedit \
      pulseaudio redshift simple-scan system-config-printer thunderbird ufw \
      unixodbc unrar vlc wget xed xdg-utils xdg-user-dirs xorg-server xreader zip
     clear
     print "\nSome Systemd services will now be enabled..."
     sleep 5.0s
     sed -i 's/#logind-check-graphical=false/logind-check-graphical=true/g' /mnt/etc/lightdm/lightdm.conf
     sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /mnt/etc/lightdm/lightdm.conf
     arch-chroot /mnt systemctl enable bluetooth.service
     arch-chroot /mnt systemctl enable cups.socket
     arch-chroot /mnt systemctl enable lightdm.service
     arch-chroot /mnt systemctl enable NetworkManager.service
     arch-chroot /mnt systemctl enable ufw.service
  fi

  if [ $desktop == GNOME ]
    then
    clear
    print "$desktop desktop environment will now be installed."
    print "Along with some other useful applications."
    sleep 5.0s
    clear
    pacstrap /mnt archlinux-appstream-data audacity binutils \
      bluez bottom bzip2 chromium coin-or-mp cups cups-pdf dpkg exa gimp gnome \
      gpick libmythes libpaper libreoffice-fresh libwpg materia-gtk-theme \
      meld neofetch networkmanager npm p7zip papirus-icon-theme pstoedit \
      pulseaudio simple-scan system-config-printer thunderbird ufw unixodbc \
      unrar vlc wget xdg-utils xorg-server zip
    clear
    print "\nSome Systemd services will now be enabled..."
    sleep 5.0s
    arch-chroot /mnt systemctl enable bluetooth.service
    arch-chroot /mnt systemctl enable cups.socket
    arch-chroot /mnt systemctl enable gdm.service
    arch-chroot /mnt systemctl enable NetworkManager.service
    arch-chroot /mnt systemctl enable ufw.service
  fi

  if [ $desktop == KDE ]
    then
    clear
    print "$desktop desktop environment will now be installed."
    print "Along with some other useful applications."
    sleep 3.0s
    clear
    pacstap /mnt archlinux-appstream-data ark audacity binutils \
      bluedevil bottom breeze-gtk bzip2 cargo chromium coin-or-mp cups cups-pdf \
      dolphin dpkg drkonqi elisa exa filelight gnome-keyring gwenview kalarm \
      kate kcalc kcolorchooser kde-gtk-config kdeplasma-addons kdiff3 kgamma5 \
      khelpcenter khotkeys kinfocenter kmag knotes konsole korganizer kscreen \
      ksshaskpass kwallet-pam kwayland-integration kwrited libmythes libpaper \
      libreoffice-fresh libwpg neofetch networkmanager npm okular oxygen \
      p7zip plasma-desktop plasma-disks plasma-firewall plasma-nm \
      plasma-pa plasma-systemmonitor plasma-thunderbolt plasma-vault \
      plasma-workspace-wallpapers pstoedit sddm-kcm skanlite spectacle \
      system-config-printer thunderbird ufw unixodbc unrar wget \
      xdg-desktop-portal-kde xdg-utils xdg-user-dirs xorg-server zip
    clear
    print "\nSome Systemd services will now be enabled..."
    sleep 5.0s
    arch-chroot /mnt systemctl enable bluetooth.service
    arch-chroot /mnt systemctl enable cups.socket
    arch-chroot /mnt systemctl enable NetworkManager.service
    arch-chroot /mnt systemctl enable sddm.service
    arch-chroot /mnt systemctl enable ufw.service
  fi


  if [ $desktop == XFCE ]
    then
    clear
    print "$desktop desktop environment will now be installed."
    print "Along with some other useful applications."
    sleep 3.0s
    clear
    pacstrap /mnt archlinux-appstream-data ark audacity binutils \
      blueman bottom bzip2 chromium coin-or-mp cups cups-pdf dpkg exa galculator \
      gimp gnome-disk-utility gnome-keyring gpick gvfs libcanberra libmythes \
      libpaper libreoffice-fresh libwpg lightdm lightdm-gtk-greeter lollypop \
      meld neofetch networkmanager network-manager-applet npm p7zip \
      papirus-icon-theme pavucontrol picom pstoedit pulseaudio redshift \
      simple-scan system-config-printer thunderbird ufw unixodbc unrar vlc wget \
      xdg-utils xdg-user-dirs xorg-server xfce4 xfce4-goodies zip
    clear
    print "\n Some Systemd services will now be enabled..."
    sleep 5.0s
    sed -i 's/#logind-check-graphical=false/logind-check-graphical=true/g' /mnt/etc/lightdm/lightdm.conf
    sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /mnt/etc/lightdm/lightdm.conf
    arch-chroot /mnt systemctl enable bluetooth.service
    arch-chroot /mnt systemctl enable cups.socket
    arch-chroot /mnt systemctl enable lightdm.service
    arch-chroot /mnt systemctl enable NetworkManager.service
    arch-chroot /mnt systemctl enable ufw.service
    sleep 3.0s
  fi
}

# Basic install of Arch Linux.
basic_install () {
    clear
    print "Installing base system now..."
    sleep 3.0s

    pacstrap /mnt base $microcode $kernel linux-firmware git grub efibootmgr \
    base-devel man-db man-pages os-prober sudo texinfo
}

# Virtualization check.
virtual_check () {
    hypervisor=$(systemd-detect-virt)
    case $hypervisor in
        kvm )   print "KVM has been detected."
                print "Installing guest tools."
                pacstrap /mnt qemu-guest-agent
                print "Enabling specific services for the guest tools."
                systemctl enable qemu-guest-agent --root=/mnt &>/dev/null
                ;;
        vmware  )   print "VMWare Workstation/ESXi has been detected."
                    print "Installing guest tools."
                    pacstrap /mnt open-vm-tools
                    print "Enabling specific services for the guest tools."
                    systemctl enable vmtoolsd --root=/mnt &>/dev/null
                    systemctl enable vmware-vmblock-fuse --root=/mnt &>/dev/null
                    ;;
        oracle )    print "VirtualBox has been detected."
                    print "Installing guest tools."
                    pacstrap /mnt virtualbox-guest-utils
                    print "Enabling specific services for the guest tools."
                    systemctl enable vboxservice --root=/mnt &>/dev/null
                    ;;
        microsoft ) print "Hyper-V has been detected."
                    print "Installing guest tools."
                    pacstrap /mnt hyperv
                    print "Enabling specific services for the guest tools."
                    systemctl enable hv_fcopy_daemon --root=/mnt &>/dev/null
                    systemctl enable hv_kvp_daemon --root=/mnt &>/dev/null
                    systemctl enable hv_vss_daemon --root=/mnt &>/dev/null
                    ;;
        * ) ;;
    esac
}

# Laptop check (Install acpi & acpid)
laptop_check () {
    clear
    read -r -p "Are you installing Arch Linux onto a laptop? (y/n): " choice
    case $choice in
        "" ) clear
             print "Installing necessary files for laptops..."
             sleep 2.0s
             arch-chroot /mnt pacman -S --noconfirm acpi acpid
             arch-chroot /mnt systemctl enable acpid.service
             ;;
        [Yy] ) clear
               print "Installing necessary files for laptops..."
               sleep 2.0s
               arch-chroot /mnt pacman -S --noconfirm acpi acpid
               arch-chroot /mnt systemctl enable acpid.service
               ;;
        [Nn] ) ;;
        * ) clear
            print "Not a valid selection. Please try again."
            sleep 2.0s
            laptop_check
    esac
}

# Set a hostname for the new system.
hostname_creator () {
    clear
    read -r -p "Please enter the hostname for your new system: " hostname
    if [ -z "$hostname" ]; then
        print_w "You need to enter a hostname in order to continue."
        hostname_creator
    fi
    echo "$hostname" > /mnt/etc/hostname
}

# Generate fstab.
gen_stab () {
    clear
    print "Generating a new fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    sleep 3.0s
}

# Select a language locale.
locale_selector () {
    clear
    read -r -p "Please insert the locale you use (format: xx_XX or enter empty to use en_US): " locale
    if [ -z "$locale" ]; then
        print_w "en_US will be used as default locale."
        locale="en_US"
    fi
    sed -i "s/#$locale.UTF-8/$locale.UTF-8/g" /mnt/etc/locale.gen
    echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
}

# Select a keyboard layout to be installed.
keyboard_selector () {
    clear
    read -r -p "Please insert the keyboard layout you use (Press enter to use US keyboard layout): " kblayout
    if [ -z "$kblayout" ]; then
        print_w "Default keyboard layout set to US."
        kblayout="us"
    fi
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
}

# configure new system.
system_setup () {
    clear
    print "Beginning system configuration..."
    sleep 3.0s
    print "\nSetting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$(curl -s http://ip-api.com/line?fields=timezone)" /etc/localtime &>/dev/null
    sleep 1.0s

    print "\nConfiguring system hardware clock..."
    arch-chroot /mnt hwclock --systohc
    sleep 1.0s

    print "\nGenerating locales..."
    arch-chroot /mnt locale-gen &>/dev/null
    sleep 1.0s

    print "\nGenerating new initramfs..."
    arch-chroot /mnt mkinitcpio -P &>/dev/null
    sleep 1.0s

    print "\nInstalling grub bootloader..."
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi \
    --bootloader-id=GRUB &>/dev/null
    sleep 1.0s

    print "\nCreating grub config file..."
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
    sleep 1.0s
}

# Install GPU drivers if detected.
gpu_driver_check () {
    clear
    print "Checking for graphics card..."
    NVIDIA_CHECK=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -o "NVIDIA")
    AMD_CHECK=$(lspci -k | grep -A 2 -E "(VGA|3D)" | grep -o "Advanced Micro Devices")
    if [ "$NVIDIA_CHECK" == "NVIDIA" ] && [ $kernel == linux ]
        then
        clear
        print "Nvidia graphics detected. Installing drivers now..."
        sleep 3.0s
        sed -i "/\[multilib\]/,/Include/"'s/^#//g' /mnt/etc/pacman.conf
        arch-chroot /mnt pacman -Syy
        arch-chroot /mnt pacman -S --noconfirm nvidia lib32-nvidia-utils nvidia-settings
        sleep 2.0s
    fi

    if [ "$NVIDIA_CHECK" == "NVIDIA" ] && [ $kernel == linux-lts ]
        then
        clear
        print "Nvidia graphics detected. Installing drivers now..."
        sleep 3.0s
        sed -i "/\[multilib\]/,/Include/"'s/^#//g' /mnt/etc/pacman.conf
        arch-chroot /mnt pacman -Syy
        arch-chroot /mnt pacman -S --noconfirm nvidia-lts lib32-nvidia-utils nvidia-settings
        sleep 2.0s
    fi

    if [ "$NVIDIA_CHECK" == "NVIDIA" ] && [ $kernel == linux-hardened ] || [ $kernel == linux-zen ]
        then
        clear
        print "Nvidia graphics detected. Installing drivers now..."
        sleep 3.0s
        sed -i "/\[multilib\]/,/Include/"'s/^#//g' /mnt/etc/pacman.conf
        arch-chroot /mnt pacman -Syy
        arch-chroot /mnt pacman -S --noconfirm nvidia-dkms lib32-nvidia-utils nvidia-settings
        sleep 2.0s
    fi

    if [ "$AMD_CHECK" == "Advanced Micro Devices" ]
        then
        clear
        print "AMD graphics detected. Installing drivers now..."
        sleep 3.0s
        sed -i "/\[multilib\]/,/Include/"'s/^#//g' /mnt/etc/pacman.conf
        arch-chroot /mnt pacman -Syy
        arch-chroot /mnt pacman -S --noconfirm mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon mesa-vdpau lib32-mesa-vdpau
        sleep 2.0s
    fi
}

# Set root password.
root_set() {
    clear
    print "Please create a password for the root user."
    until arch-chroot /mnt passwd root
    do
        print_w "You must enter a valid matching root password to continue."
    done
    sleep 3.0s
}

# User creation.
create_user () {
  clear
  read -r -p "Please Enter a name for a user account (leave empty and press enter to skip): "  username
  if [ -n "$username" ]; then
    arch-chroot /mnt useradd -m "$username"
    print "\nPlease enter a password for $username."
    until arch-chroot /mnt passwd "$username"
    do
        print_w "Please try again."
    done
    sleep 3.0s
    echo -e "\x1b[1;34mAdding\e[0m \x1b[0;33m$username\e[0m \x1b[1;34mwith root privileges.\e[0m"
    arch-chroot /mnt gpasswd -a "$username" adm
    arch-chroot /mnt gpasswd -a "$username" rfkill
    arch-chroot /mnt gpasswd -a "$username" wheel
    echo "$username  ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/"$username"
    sleep 3.0s
  fi
}

###############
#   Program   #
###############

# Check root first
root_check

# Start by clearing the terminal
clear

# Installation
welcome
continue_check
intitialization
disk_selector
disk_confirm
hibernation_selector
mem_selector
swap_selector
create_partitions
format_partitions
microcode_detector
kernel_selector
network_selector
basic_install
virtual_check
laptop_check
hostname_creator
gen_stab
locale_selector
keyboard_selector
system_setup
gpu_driver_check
desktop_select
de_install
root_set
create_user

# Print a message after installing then restart the system.
clear
print "Installation of Arch Linux is now complete!"
print "Computer will now restart in 10.0s..."
sleep 10.0s

print "Exiting"
reboot

# Exit script.
exit
