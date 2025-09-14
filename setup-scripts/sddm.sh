#!/bin/bash

# sourcing the helper file
BASE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../")
source $BASE_DIR/setup-scripts/helper.sh

install_pacman sddm
sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
