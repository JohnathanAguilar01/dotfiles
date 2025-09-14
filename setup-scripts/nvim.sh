#!/bin/bash

# sourcing the helper file
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
source $BASE_DIR/setup-scripts/helper.sh


read -n1 -rep "${CAT} OPTIONAL - Would you like to install neovim? (y/n)" inst4
if [[ $inst4 =~ ^[Yy]$ ]]; then
  cd $HOME
  git clone https://github.com/neovim/neovim.git
  cd $HOME/neovim/
  git checkout v0.11.4
  make CMAKE_BUILD_TYPE=Release
  sudo make install
fi
mkdir -p $HOME/.config/nvim
git clone https://github.com/JohnathanAguilar01/Johnny.nvim.git $HOME/.config/nvim
