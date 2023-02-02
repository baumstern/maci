#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
MACI_DIR="$HOME"/maci

NPM="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/npm"
NPX="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/npx"
NODE="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/node"

export PATH="$NODE:$NPX:$NPM:$PATH"

echo $PATH


sudo ln -s $NODE /usr/bin/node
sudo ln -s $NPM /usr/bin/npm


rm -rf "$MACI_DIR"/cli/zkeys

# Setup maci repo
cd "$MACI_DIR"


## TEMP test
cd "$MACI_DIR"
git fetch
git pull origin circuit-builder



$NPM install
$NPM run bootstrap
$NPM run build

# Compile contracts
cd "$MACI_DIR"/contracts
HARDHAT_NETWORK=hardhat $NPM run compileSol

# Symlink ptau files
mkdir -p "$MACI_DIR"/cli/zkeys
ln -s "$HOME"/ptaus/* "$MACI_DIR"/cli/zkeys

