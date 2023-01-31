#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
MACI_DIR="$HOME"/maci


# Setup maci repo
cd "$MACI_DIR"
npm install
npm run bootstrap
npm run build

# Compile contracts
cd "$MACI_DIR"/contracts
HARDHAT_NETWORK=hardhat npm run compileSol

# Symlink ptau files
mkdir -p "$MACI_DIR"/cli/zkeys
ln -s "$HOME"/ptaus/* "$MACI_DIR"/cli/zkeys

