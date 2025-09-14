#!/bin/bash

# sourcing the helper file
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
source $BASE_DIR/setup-scripts/helper.sh

# Path to GRUB config file
GRUB_FILE="/etc/default/grub"

# The line we want to add
SETTING="GRUB_DISABLE_OS_PROBER=false"

# installing os-prober
install_pacman "os-prober"
install_pacman "fuse3"

# install sleek theme
cd $BASE_DIR
git clone https://github.com/sandesh236/sleek--themes.git
cd sleek--themes/Sleek\ theme-dark/
chmod +x install.sh
sudo ./install.sh

# Check if line already exists
if grep -q "^${SETTING}" "$GRUB_FILE"; then
    printf "\n${OK} Setting already exists in $GRUB_FILE\n"
else
    printf "\n${NOTE} Adding setting to $GRUB_FILE\n"
    sudo sed -i '/^\s*GRUB_DISABLE_OS_PROBER\s*=/d' "$GRUB_FILE"
    echo "$SETTING" | sudo tee -a "$GRUB_FILE" > /dev/null
fi

# Regenerate GRUB configuration
if [[ -d /boot/grub ]]; then
    printf "\n${NOTE} Updating GRUB configuration...\n"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    printf "\n${ERROR} /boot/grub directory not found. Is GRUB installed?\n"
    exit 1
fi



printf "$\n{OK} GRUB updated successfully.\n"
sleep 4
