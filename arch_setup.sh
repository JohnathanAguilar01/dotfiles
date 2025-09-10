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
