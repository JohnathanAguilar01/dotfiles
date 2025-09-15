#!/bin/bash
# https://github.com/JohnathanAguilar01

# Set the script to exit on error
set -e
clear

# Get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source $BASE_DIR/setup-scripts/helper.sh

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
	echo "This script should not be executed as root! Exiting......."
	exit 1
fi

# Display ASCII art
display_hello


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

# clear screen
clear

# install AUR if not already installed
run_script "aur.sh" "AUR Setup"

# clear screen
clear

# install dependenscies
run_script "dependencies.sh" "dependenscies setup"

# clear screen
clear

# install hardware drivers
run_script "hardware-drivers.sh" "install drivers"

# clear screen
clear

# use stow to sim link dotfiles
run_script "stow-config.sh" "sim link dotfiles with stow"

# clear screen
clear

# Intall nvim configs
run_script "nvim.sh" "install neovim"

# clear screen
clear

# Update grub setting to see other os
run_script "grub-os-prober.sh" "update GRUB to see other os's"

# clear screen
clear

# setup ssh for device
run_script "setup-ssh.sh" "set-up ssh for this device"

# clear screen
clear

# setup ssh for device
run_script "sddm.sh" "install SDDM and themes"

# clear screen
clear

# proceed to set wallpaper
read -n1 -rep "${CAT} Shall we proceed with setting wallpaper and color theme (y/n) " wallpaper
    echo
if [[ $wallpaper =~ ^[Yy]$ ]]; then
  hyprland
  cd $BASE_DIR
  pwd
  swww img wallpapers/minecraft-blocks.jpg
  matugen image wallpapers/minecraft-blocks.jpg
else
  printf "\n${OK} Installation completed successfully"
  sleep 2
  exit
fi
printf "\n${OK} Installation completed successfully"
