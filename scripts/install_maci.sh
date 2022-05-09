#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$BASE_DIR"/..
MACI_DIR="$PROJECT_ROOT"/maci


git config --global url."https://github.com/".insteadOf git://github.com/


# To prevent `npm install` failure of circuit package, 
# it has to checkout manually because version of `circomlib` has pinned to a specific commit
cd "$MACI_DIR"/circuits/node_modules
git init circomlib
cd "$MACI_DIR"/circuits/node_modules/circomlib
git remote add origin https://github.com/weijiekoh/circomlib
git -c protocol.version=2 fetch --no-tags --prune --progress --no-recurse-submodules --depth=1 origin ac85e82c1914d47789e2032fb11ceb2cfdd38a2b
git checkout --progress --force ac85e82c1914d47789e2032fb11ceb2cfdd38a2b
rm -rf ./.git

# Setup maci repo
cd "$MACI_DIR"
npm install
npx lerna bootstrap --no-ci
npm run build

# Compile contracts
cd "$MACI_DIR"/contracts
npm run compileSol


RAPIDSNARK_LINK=https://maci-devops-zkeys.s3.ap-northeast-2.amazonaws.com/rapidsnark-linux-amd64-1c137
RAPIDSNARK_PATH=~/rapidsnark/build

echo 'Install rapidsnark (1c137)'

# Download rapidsnark (1c137)
mkdir -p "$RAPIDSNARK_PATH"
wget -qO "$RAPIDSNARK_PATH"/prover "$RAPIDSNARK_LINK"
chmod +x "$RAPIDSNARK_PATH"/prover


ZKEYS_LINK=https://maci-devops.s3.ap-northeast-2.amazonaws.com/zkeys_glibc-211.tar.gz
ZKEYS_FILE_NAME=zkeys.tar.gz
ZKEYS_PARAMS='10-2-1-2'
ZKEYS_GLIBC='2.11'

echo 'Download zkeys. params: "$ZKEYS_PARAMS", GLIBC version: "$ZKEYS_GLIBC"'
# Download zkeys (development parameter)
# stateTreeDepth: 10
# msgTreeDepth: 2
# msgBatchDepth: 1
# voteOptionTreeDepth: 2
#
cd "$MACI_DIR"/cli
wget -qO "$ZKEYS_FILE_NAME" "$ZKEYS_LINK"
tar -xzvf "$ZKEYS_FILE_NAME"