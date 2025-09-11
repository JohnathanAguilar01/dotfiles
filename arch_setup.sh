#!/bin/bash
# https://github.com/JohnathanAguilar01

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
	echo "This script should not be executed as root! Exiting......."
	exit 1
fi

clear

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Function to display ASCII art
display_hello() {
    cat << "EOF"
  ___ ___         .__  .__                       ____.      .__                         
 /   |   \   ____ |  | |  |   ______  _  __     |    | ____ |  |__   ____   ____ ___.__.
/    ~    \_/ __ \|  | |  |  /  _ \ \/ \/ /     |    |/  _ \|  |  \ /    \ /    <   |  |
\    Y    /\  ___/|  |_|  |_(  <_> )     /  /\__|    (  <_> )   Y  \   |  \   |  \___  |
 \___|_  /  \___  >____/____/\____/ \/\_/   \________|\____/|___|  /___|  /___|  / ____|
       \/       \/                                               \/     \/     \/\/     
EOF
}

# Display ASCII art
display_hello

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"
sleep 1

# Print backup warning message
printf "\n"
printf "${ORANGE}$(tput smso)PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!$(tput rmso)\n"
printf "\n"
sleep 1

# Print password warning message
printf "\n${NOTE} Some commands require you to enter your password in order to execute.\n"
sleep 1
printf "\n"

# Print system-update warning message
printf "\n${NOTE} If you have not perform a full system update for a while, cancel the script by pressing CTRL c and perform a full system update first\n"
printf "${WARN} If there is a kernel update, reboot first your system and re-run script. Script may fail if not updated. .${RESET}\n"
sleep 1
printf "\n"

# proceed
read -n1 -rep "${CAT} Shall we proceed with installation (y/n) " PROCEED
    echo
if [[ $PROCEED =~ ^[Yy]$ ]]; then
    printf "\n%s  Alright.....LETS BEGIN!.\n" "${OK}"
    sleep 2
else
    printf "\n%s  NO changes made to your system. Goodbye.!!!\n" "${NOTE}"
    sleep 2
    exit
fi

#clear screen
clear

# Check for AUR helper and install if not found
ISAUR=$(command -v yay || command -v paru)

if [ -n "$ISAUR" ]; then
  printf "\n%s - AUR healper is installation located, Procedding ...\n" "${OK}"
else 
  printf "\n%s - AUR healper NOT installation not located\n" "${WARN}"

    while true; do
        read -rp "${CAT} Which AUR helper do you want to use, yay or paru? Enter 'y' or 'p': " choice 
        case "$choice" in
            y|Y)
                printf "\n%s - Installing yay from AUR\n" "${NOTE}"
                git clone https://aur.archlinux.org/yay-bin.git || { printf "%s - Failed to clone yay from AUR\n" "${ERROR}"; exit 1; }
                cd yay-bin || { printf "%s - Failed to enter yay-bin directory\n" "${ERROR}"; exit 1; }
                makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install yay from AUR\n" "${ERROR}"; exit 1; }
                cd ..
                break
                ;;
            p|P)
                printf "\n%s - Installing paru from AUR\n" "${NOTE}"
                git clone https://aur.archlinux.org/paru-bin.git || { printf "%s - Failed to clone paru from AUR\n" "${ERROR}"; exit 1; }
                cd paru-bin || { printf "%s - Failed to enter paru-bin directory\n" "${ERROR}"; exit 1; }
                makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install paru from AUR\n" "${ERROR}"; exit 1; }
                cd ..
                break
                ;;
            *)
                printf "%s - Invalid choice. Please enter 'y' or 'p'\n" "${ERROR}"
                continue
                ;;
        esac
    done
fi

#clear screen
clear

# Update system before proceeding
printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to update system\n" "${ERROR}"; exit 1; }

#clear screen
clear

# Set the script to exit on error
set -e

# Function for installing packages
install_package() {
    # checking if package is already installed
    if $ISAUR -Q "$1" &>> /dev/null ; then
        echo -e "${OK} $1 is already installed. skipping..."
    else
        # package not installed
        echo -e "${NOTE} installing $1 ..."
        $ISAUR -S --noconfirm "$1" 2>&1 | tee -a "$LOG"
        # making sure package installed
        if $ISAUR -Q "$1" &>> /dev/null ; then
            echo -e "\e[1A\e[K${OK} $1 was installed."
        else
            # something is missing, exitting to review log
            echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log . You may need to install manually! Sorry I have tried :("
            exit 1
        fi
    fi
}

# Function to print error messages
print_error() {
    printf " %s%s\n" "${ERROR}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "${OK}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

# Choose pacman runner (sudo if not root)
_pac() {
  if [[ $EUID -ne 0 ]]; then
    sudo pacman "$@"
  else
    pacman "$@"
  fi
}

# ---------- pacman install function ----------
install_pacman() {
  # Usage: install_pacman package1 [package2 ...]
  # Uses: pacman -S --needed --noconfirm
  # Logs: $LOG
  for pkg in "$@"; do
    if pacman -Q "$pkg" &>/dev/null; then
      printf "%s %s is already installed. skipping...\n" "${OK}" "$pkg" | tee -a "$LOG"
      continue
    fi

    printf "%s installing %s ...\n" "${NOTE}" "$pkg" | tee -a "$LOG"

    # Install without reinstalling up-to-date packages
    # (no separate -Sy to avoid partial upgrades; rely on pacman's sync during -S)
    if _pac -S --needed --noconfirm -- "$pkg" 2>&1 | tee -a "$LOG"; then
      if pacman -Q "$pkg" &>/dev/null; then
        # \e[1A\e[K: move cursor up one line and clear it (same UX touch as your script)
        echo -e "\e[1A\e[K${OK} $pkg was installed." | tee -a "$LOG"
      else
        echo -e "\e[1A\e[K${ERROR} $pkg seems not installed after attempt. Check $LOG." | tee -a "$LOG"
        exit 1
      fi
    else
      echo -e "\e[1A\e[K${ERROR} $pkg failed to install. See $LOG. You may need to install manually." | tee -a "$LOG"
      exit 1
    fi
  done
}

# Exit immediately if a command exits with a non-zero status.
set -e 

# clear screen
clear

# install dependencies
# Packages list
PACMAN_PACKAGES=(
    hyprland
    wayland
    wayland-protocols
    gtkmm3
    jsoncpp
    libsigc++
    fmt
    chrono-date
    spdlog
    gtk3
    gobject-introspection
    libgirepository
    libpulse
    libnl
    libappindicator-gtk3
    libdbusmenu-gtk3
    libmpdclient
    sndio
    libevdev
    libxkbcommon
    upower
    meson
    cmake
    scdoc
    glib2-devel
    kitty
    waybar
    swww
    rofi
    ttf-jetbrains-mono-nerd-font
    starship
)

AUR_PACKAGES=(
  matugen-bin
)

# Loop through pacman packages
for pkg in "${PACMAN_PACKAGES[@]}"; do
    read -n1 -rep "${CAT} Would you like to install $pkg? (y/n)" pkginst
    if [[ $pkginst =~ ^[Yy]$ ]]; then
        install_pacman "$pkg"
    else
        printf "${WARN} If $pkg not installed other features may not work./n"
    fi
done

# Loop through AUR packages
for pkg in "${AUR_PACKAGES[@]}"; do
    read -n1 -rep "${CAT} Would you like to install $pkg? (y/n)" pkginst
    if [[ $pkginst =~ ^[Yy]$ ]]; then
        install_package "$pkg"
    else
        printf "${WARN} If $pkg not installed other features may not work./n"
    fi
done

printf "${OK} All requested packages processed!/n"

#clear screen
clear

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" inst4
if [[ $inst4 =~ ^[Yy]$ ]]; then
  printf "${NOTE} Installing Bluetooth Packages...\n"
  for BLUE in bluez bluez-utils blueman; do
    install_package "$BLUE" 2>&1 | tee -a "$LOG"
         if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $BLUE install had failed, please check the install.log"
        exit 1
        fi
    done

  printf " Activating Bluetooth Services...\n"
  sudo systemctl enable --now bluetooth.service 2>&1 | tee -a "$LOG"
else
  printf "${NOTE} No bluetooth packages installed..\n"
fi

#clear screen
clear

# Install software for Asus ROG laptops
read -n1 -rep "${CAT} (OPTIONAL - ONLY for ROG Laptops) Would you like to install Asus ROG software support? (y/n)" ROG
if [[ $ROG =~ ^[Yy]$ ]]; then
    printf " Installing ASUS ROG packages...\n"
    for ASUS in asusctl supergfxctl rog-control-center; do
        install_package  "$ASUS" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $ASUS install had failed, please check the install.log"
        exit 1
        fi
    done
    printf " Activating ROG services...\n"
    sudo systemctl enable --now supergfxd 2>&1 | tee -a "$LOG"
    sed -i '23s/#//' config/hypr/configs/Execs.conf
else
    printf "${NOTE} Asus ROG software support not installed..\n"
fi

#clear screen
clear

read -n1 -rep "${CAT} Would you like to remove existing dotfiles an replace with stow dotfiles? (y/n)" DOT
if [[ $DOT =~ ^[Yy]$ ]]; then
  install_pacman stow
  # Go to home directory
  cd ~
  
  # Remove .bashrc if it exists
  if [ -f ".bashrc" ]; then
      printf " Removing existing .bashrc...\n"
      rm .bashrc
  else
      printf " .bashrc not found, skipping removal."
  fi
  
  # Remove .bashrc if it exists
  if [ -f ".config" ]; then
      printf " Removing existing .config dir...\n"
      rm -rf .config
  else
      printf " .config not found, skipping removal."
  fi

  # Go to dotfiles directory
  cd ~/dotfiles/
  
  # Run stow
  printf " Running stow..."
  stow .
  
  printf " ${OK} Stow has made sim link"
else
  printf "${NOTE} Existing dotfiles not deleted and replaced...\n"
fi
