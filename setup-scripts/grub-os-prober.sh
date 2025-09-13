#!/bin/bash

# Path to GRUB config file
GRUB_FILE="/etc/default/grub"

# The line we want to add
SETTING="GRUB_DISABLE_OS_PROBER=true"

# Check if line already exists
if grep -q "^${SETTING}" "$GRUB_FILE"; then
    printf "\n${OK} Setting already exists in $GRUB_FILE\n"
else
    printf "\n${NOTE} Adding setting to $GRUB_FILE\n"
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
