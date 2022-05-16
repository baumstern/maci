#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$BASE_DIR"/..
MACI_DIR="$PROJECT_ROOT"/maci

eval `"$PROJECT_ROOT"/setEnv.js`

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
HARDHAT_NETWORK=hardhat npm run compileSol


RAPIDSNARK_LINK=https://maci-devops-zkeys.s3.ap-northeast-2.amazonaws.com/rapidsnark-linux-amd64-1c137
RAPIDSNARK_PATH=~/rapidsnark/build

echo 'Install rapidsnark (1c137)'

# Download rapidsnark (1c137)
mkdir -p "$RAPIDSNARK_PATH"
wget -qO "$RAPIDSNARK_PATH"/prover "$RAPIDSNARK_LINK"
chmod +x "$RAPIDSNARK_PATH"/prover


# Download .zkey files
ZKEYS_GLIBC='2.11'
ZKEY_COMPILED=zkeys_"$ZKEYS_PARAMS"_glibc-211.tar.gz

# $ZKEY_PARAMS should be declared in `input/*.toml` config and exported by `setEnv.js` scropt
STATE_TREE_DEPTH=$(echo "$ZKEYS_PARAMS" | cut -d '-' -f 1)
INT_STATE_TREE_DEPTH=$(echo "$ZKEYS_PARAMS" | cut -d '-' -f 3)
VOTE_OPTION_TREE_DEPTH=$(echo "$ZKEYS_PARAMS" | cut -d '-' -f 4)

TALLY_PARAMS=""$STATE_TREE_DEPTH"-"$INT_STATE_TREE_DEPTH"-"$VOTE_OPTION_TREE_DEPTH""

ZKEY_COMPILED_LINK=https://maci-devops-zkeys.s3.ap-northeast-2.amazonaws.com/"$ZKEY_COMPILED"
ZKEY_PROCESS_MESSAGES_LINK=https://maci-devops-zkeys.s3.ap-northeast-2.amazonaws.com/ProcessMessages_"$ZKEYS_PARAMS"_test.0.zkey
ZKEY_TALLY_VOTES_LINK=https://maci-devops-zkeys.s3.ap-northeast-2.amazonaws.com/TallyVotes_"$TALLY_PARAMS"_test.0.zkey


echo "Download zkeys. params: "$ZKEYS_PARAMS", GLIBC version: "$ZKEYS_GLIBC""

cd "$MACI_DIR"/cli
wget -q "$ZKEY_COMPILED_LINK"
tar -xzvf "$ZKEY_COMPILED"

cd zkeys
wget -q "$ZKEY_PROCESS_MESSAGES_LINK"
wget -q "$ZKEY_TALLY_VOTES_LINK"
