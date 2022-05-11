#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$BASE_DIR"/..
MACI_DIR="$PROJECT_ROOT"/maci





echo 'Cloning MACI...'
git config --global url."https://github.com/".insteadOf git://github.com/

git clone https://github.com/appliedzkp/maci
cd maci
git checkout v1

# To prevent `npm install` failure of circuit package, 
# it has to checkout manually because version of `circomlib` has pinned to a specific commit
mkdir -p circuits/node_modules
cd circuits/node_modules
git init circomlib
cd circomlib
git remote add origin https://github.com/weijiekoh/circomlib
git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=1 origin ac85e82c1914d47789e2032fb11ceb2cfdd38a2b
git checkout --progress --force ac85e82c1914d47789e2032fb11ceb2cfdd38a2b
rm -rf ./.git

echo 'Installing MACI...'
pwd
cd ../../..
npm install
npx lerna bootstrap --no-ci
npm run build

# Overwrite hardhat config to enable network and eth private key config
cp "$PROJECT_ROOT"/config/hardhat.config.js "$MACI_DIR"/cli/
