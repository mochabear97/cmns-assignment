#! /bin/sh


#################
#   Functions   #
#################


# Green text print.
print () {
  echo -e "\x1b[1;32m$1\e[0m"
}

# Print warning
print_w () {
  echo -e "\x1b[0;33m[w] $1\e[0m"
}

# Welcome screen.
welcome () {
  print "################################"
  print "#                              #"
  print "#   Exiles Desktop Installer   #"
  print "#                              #"
  print "#   Author: The Exiles         #"
  print "#   Version: 1.0.0             #"
  print "#                              #"
  print "################################"
}

# Ask to continue.
continue_check () {
   read -r -p $'\e[0;33m[?] Would You Like to continue? (y/n):\e[0m ' choice
   case $choice in
    y ) print "Continuing..."
	sleep 2.0s
	;;
    n ) exit 1
	;;
    * ) print_w "You did not enter a valid selection."
	continue_check
  esac
}

# Selection Check
selection_check () {
  read -r -p $'\e[0;33m[?] Is this correct? (y/n):\e[0m ' choice
  case $choice in
    y ) sleep 3.0s
        ;;
    n ) print "Please try again."
	sleep 2.0s
	clear
        desktop_select
	;;
    * ) selection_check
  esac
}


desktop_select () {
  print "**Desktop Environments Menu**"
  print "\n1) Cinnamon"
  print "2) GNOME"
  print "3) KDE"
  print "4) XFCE"
  print "0) Cancel"
  read -r -p "Please select an option: " choice
  case $choice in
    0 ) exit 1
	      ;;
    1 )	desktop=Cinnamon
        clear
        echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
        print "$desktop is a desktop environment best suited for"
        print "users who most comfortable with Windows 7"
	      selection_check
	      ;;
    2 ) desktop=GNOME
        clear
	      echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
        print "$desktop is a very simplistic modern desktop environment"
        print "best suited for users who are used to OSX(Macintosh)"
	      selection_check
	      ;;
    3 ) desktop=KDE
        clear
	      echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
        print "$desktop is a very modern desktop environment built"
        print "with Windows 10/11 users in mind"
	      selection_check
        ;;
    4 ) desktop=XFCE
        clear
        echo -e "\x1b[1;32mYou Selected\e[0m \x1b[0;33m$desktop\e[0m"
	      print "$desktop is an older desktop environment closely"
        print "resembling Windows XP in terms of look and feel."
        print "This DE is best suited for computers with old hardware."
        selection_check
	      ;;
    * ) print_w "That is not a valid selection."
        print_w "Please try again."
        sleep 2.0s
	      desktop_select
  esac
}


# Remove systemd file and shell script after install is complete.
remove_important () {
  clear
  print "Deleting install script from system..."
  systemctl disable exiles-desktop-installer.service
  rm -rf /bin/exiles-desktop-installer.sh
  rm -rf /etc/systemd/system/exiles-desktop-installer.service
  sleep 5.0s
}

###############
#   Program   #
###############

# clear the TTY.
clear

# Display welcome.
welcome

# Display check.
echo -e "\n"
continue_check

clear

# Select a desktop environment
desktop_select

sleep 2.0s

if [ $desktop == Cinnamon ] 
   then
   clear
   print "Cinnamon desktop environemnt will now be installed."
   print "Along with some other usefull applications."
   sleep 3.0s
   clear
   pacman -S --noconfirm acpi acpid archlinux-appstream-data audacity binutils \
    blueberry bottom bzip2 chromium cinnamon coin-or-mp cups cups-pdf dpkg exa \
    file-roller galculator gimp gnome-disk-utility gnome-keyring \
    gnome-terminal gpick gvfs libmythes libpaper libreoffice-fresh libwpg \
    lightdm lightdm-gtk-greeter lollypop meld mesa neofetch networkmanager \
    network-manager-applet npm p7zip papirus-icon-theme pavucontrol pstoedit \
    pulseaudio redshift simple-scan system-config-printer thunderbird ufw \
    unixodbc unrar vlc wget xed xdg-utils xdg-user-dirs xorg-server xreader zip
   clear
   print "\nSome Systemd services will now be enabled..."
   sleep 5.0s
   sed -i 's/#logind-check-graphical=false/logind-check-graphical=true/g' /etc/lightdm/lightdm.conf
   sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
   systemctl enable acpid.service
   systemctl enable bluetooth.service
   systemctl enable cups.socket
   systemctl enable lightdm.service
   systemctl enable NetworkManager.service
   systemctl enable ufw.service
fi

if [ $desktop == GNOME ]
  then
  clear
  print "$desktop desktop environment will now be installed."
  print "Along with some other usefull applications."
  sleep 5.0s
  clear
  pacman -S --noconfirm acpi acpid archlinux-appstream-data audacity binutils \
    bluez bottom bzip2 chromium coin-or-mp cups cups-pdf dpkg exa gimp gnome \
    gpick libmythes libpaper libreoffice-fresh libwpg materia-gtk-theme \
    meld mesa neofetch networkmanager npm p7zip papirus-icon-theme pstoedit \
    pulseaudio simple-scan system-config-printer thunderbird ufw unixodbc \
    unrar vlc wget xdg-utils xorg-server zip
  clear
  print "\nSome Systemd services will now be enabled..."
  sleep 5.0s
  systemctl enable acpid.service
  systemctl enable bluetooth.service
  systemctl enable cups.socket
  systemctl enable gdm.service
  systemctl enable NetworkManager.service
  systemctl enable ufw.service
fi

if [ $desktop == KDE ]
  then
  clear
  print "$desktop desktop environment will now be installed."
  print "Along with some other usefull applications."
  sleep 3.0s
  clear
  pacman -S --noconfirm acpi acpid archlinux-appstream-data ark audacity binutils \
    bluedevil bottom breeze-gtk bzip2 cargo chromium coin-or-mp cups cups-pdf \
    dolphin dpkg drkonqi elisa exa filelight gnome-keyring gwenview kalarm \
    kate kcalc kcolorchooser kde-gtk-config kdeplasma-addons kdiff3 kgamma5 \
    khelpcenter khotkeys kinfocenter kmag knotes konsole korganizer kscreen \
    ksshaskpass kwallet-pam kwayland-integration kwrited libmythes libpaper \
    libreoffice-fresh libwpg mesa neofetch networkmanager npm okular oxygen \
    p7zip plasma-desktop plasma-disks plasma-firewall plasma-nm  \
    plasma-pa plasma-systemmonitor plasma-thunderbolt plasma-vault \
    plasma-workspace-wallpapers pstoedit sddm-kcm skanlite spectacle \
    system-config-printer thunderbird ufw unixodbc unrar wget \
    xdg-desktop-portal-kde xdg-utils xdg-user-dirs xorg-server zip
  clear
  print "\nSome Systemd services will now be enabled..."
  sleep 5.0s
  systemctl enable acpid.service
  systemctl enable bluetooth.service
  systemctl enable cups.socket
  systemctl enable NetworkManager.service
  systemctl enable sddm.service
  systemctl enable ufw.service
fi


if [ $desktop == XFCE ]
  then
  clear
  print "$desktop desktop environment will now be installed."
  print "Along with some other usefull applications."
  sleep 3.0s
  clear
  pacman -S --noconfirm acpi acpid archlinux-appstream-data ark audacity binutils \
    blueman bottom bzip2 chromium coin-or-mp cups cups-pdf dpkg exa galculator \
    gimp gnome-disk-utility gnome-keyring gpick gvfs libcanberra libmythes \
    libpaper libreoffice-fresh libwpg lightdm lightdm-gtk-greeter lollypop \
    meld mesa neofetch networkmanager network-manager-applet npm p7zip \
    papirus-icon-theme pavucontrol picom pstoedit pulseaudio redshift \
    simple-scan system-config-printer thunderbird ufw unixodbc unrar vlc wget \
    xdg-utils xdg-user-dirs xfce4 xfce4-goodies zip
  clear
  print "\n Some Systemd services will now be enabled..."
  sleep 5.0s
  sed -i 's/#logind-check-graphical=false/logind-check-graphical=true/g' /etc/lightdm/lightdm.conf
  sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
  systemctl enable acpid.service
  systemctl enable bluetooth.service
  systemctl enable cups.socket
  systemctl enable lightdm.service
  systemctl enable NetworkManager.service
  systemctl enable ufw.service
  sleep 3.0s
fi

remove_important

# End of desktop environment installation.
clear
print "Installation is now complete."
print "Computer will now restart in 10s"

sleep 10.0s

reboot

