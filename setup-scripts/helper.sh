#!/bin/bash

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Get the directory of the current script
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")

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

# Function to run a script with retry and confirmation
run_script() {
  local script="$BASE_DIR/scripts/$1"
  local description="$2"
  read -n1 -rep "${CAT} Would you like to install $2? (y/n)" script
  if [[ $script =~ ^[Yy]$ ]]; then
    while ! bash "$script"; do
      print_error "$description script failed."
      read -n1 -rep "${CAT} Would you like to retry installing $2? (y/n)" retry
      if [[ $retry =~ ^[Nn]$ ]]; then
          return 1  # User chose not to retry
      fi
    done
    print_success "\n$description completed successfully."
  else
      return 1  # User chose not to run the script
  fi
}
