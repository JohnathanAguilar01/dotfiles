#!/bin/bash

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
