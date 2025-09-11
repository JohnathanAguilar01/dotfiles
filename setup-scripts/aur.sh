#!/bin/bash

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

