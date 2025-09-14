#!/bin/bash

# sourcing the helper file
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
source $BASE_DIR/setup-scripts/helper.sh

install_pacman "github-cli"
install_pacman "openssh"

if [[ -f "$HOME/.ssh/id_rsa.pub" || -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    printf "\n${WARN} SSH key already exists.\n"
else
  while true; do
      read -rp "Enter your name: " users_name
      read -rp "Enter your email: " user_email
      
      # Basic validation: must contain "@" and "."
      if [[ "$user_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
          ssh-keygen -t ed25519 -C "$user_email"
          git config --global user.email "$user_email"
          git config --global user.name "$users_name"
          break
      else
          printf "\n${WARN} Invalid email format. Please try again.\n"
      fi
  done
  eval "$(ssh-agent -s)"
  ssh-add $HOME/.ssh/id_ed25519
fi

read -rp "Enter the name of the ssh device: " device_name
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$device_name"
ssh -T git@github.com



