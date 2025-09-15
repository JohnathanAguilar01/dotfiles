#!/bin/bash

# sourcing the helper file
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
source $BASE_DIR/setup-scripts/helper.sh

# install dependencies
# Packages list
PACMAN_PACKAGES=(
    hyprland
    python
    nodejs
    npm
    tmux
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
    curl
    scdoc
    glib2-devel
    kitty
    waybar
    swww
    rofi
    ttf-jetbrains-mono-nerd
    starship
)

AUR_PACKAGES=(
  matugen-bin
)

# Loop through pacman packages
for pkg in "${PACMAN_PACKAGES[@]}"; do
    # read -n1 -rep "${CAT} Would you like to install $pkg? (y/n)" pkginst
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
