#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
MACI_DIR="$HOME"/maci

NPM="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/npm"


# Setup maci repo
cd "$MACI_DIR"
$NPM install
$NPM run bootstrap
$NPM run build

# Compile contracts
cd "$MACI_DIR"/contracts
HARDHAT_NETWORK=hardhat $NPM run compileSol

# Symlink ptau files
mkdir -p "$MACI_DIR"/cli/zkeys
ln -s "$HOME"/ptaus/* "$MACI_DIR"/cli/zkeys

