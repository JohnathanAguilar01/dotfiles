#!/bin/bash

# sourcing the helper file
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
source $BASE_DIR/setup-scripts/helper.sh

read -n1 -rep "${CAT} Would you like to remove existing dotfiles an replace with stow dotfiles? (y/n)" DOT
if [[ $DOT =~ ^[Yy]$ ]]; then
    install_pacman stow

    # Remove .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        printf " Removing existing .bashrc...\n"
        rm "$HOME/.bashrc"
    else
        printf " .bashrc not found, skipping removal.\n"
    fi
    
    # Remove .tmux.conf if it exists
    if [ -f "$HOME/.tmux.conf" ]; then
        printf " Removing existing .tmux.conf...\n"
        rm "$HOME/.tmux.conf"
    else
        printf " .tmux.conf not found, skipping removal.\n"
    fi
    
    # Remove .config if it exists
    if [ -d "$HOME/.config" ]; then
        printf " Removing existing .config dir...\n"
        rm -rf "$HOME/.config"
    else
        printf " .config not found, skipping removal.\n"
    fi

    # Go to dotfiles directory
    cd "$BASE_DIR"
    pwd
    
    # Run stow
    printf " Running stow...\n"
    stow bashrc/
    stow tmux.conf/
    stow config/
    
    printf " ${OK} Stow has made sim link\n"

    # Reload bashrc, tmux.conf and configs
    if [ -f "$HOME/.bashrc" ]; then
        printf " Sourcing new .bashrc...\n"
        source "$HOME/.bashrc"
    fi

    if [ -f "$HOME/.tmux.conf" ]; then
        printf " Sourcing new .tmux.conf...\n"
        source "$HOME/.tmux.conf"
    fi
    
    if [ -f "$HOME/.config/hypr/hyprland.config" ]; then
        printf " Sourcing .config files hyprland.config ...\n"
        # Example: if you have a shell config inside .config
        source "$HOME/.config/hypr/hyprland.config"
    fi

else
    printf "${NOTE} Existing dotfiles not deleted and replaced...\n"
fi
