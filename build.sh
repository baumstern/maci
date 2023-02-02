#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
MACI_DIR="$HOME"/maci

NPM="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/npm"
NPX="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/npx"
NODE="/home/ubuntu/.nvm/versions/node/v16.19.0/bin/node"

export PATH="$NODE:$NPX:$NPM:$PATH"

sudo ln -s "$(which node)" /usr/bin/node
sudo ln -s "$(which npm)" /usr/bin/npm

# Compile circuits
# cd "$MACI_DIR"/cli/
# $NPX zkey-manager \
#     compile -c ./zkeys.config.yml


# Generate .zkey files
~/node/out/Release/node --trace-gc \
--trace-gc-ignore-scavenger \
--max-old-space-size=2048000 \
--initial-old-space-size=2048000 \
--no-global-gc-scheduling \
--no-incremental-marking \
--max-semi-space-size=1024 \
--initial-heap-size=2048000 \
--expose-gc \
/home/ubuntu/.nvm/versions/node/v16.19.0/bin/snarkjs \
groth16 \
setup \
"$MACI_DIR"/cli/zkeys/ProcessMessages_10-2-1-2_test.r1cs \
"$MACI_DIR"/cli/zkeys/powersOfTau28_hez_final_20.ptau zkeys/ProcessMessages_10-2-1-2_test.0.zkey

sleep 10

~/node/out/Release/node --trace-gc \
--trace-gc-ignore-scavenger \
--max-old-space-size=2048000 \
--initial-old-space-size=2048000 \
--no-global-gc-scheduling \
--no-incremental-marking \
--max-semi-space-size=1024 \
--initial-heap-size=2048000 \
--expose-gc \
/home/ubuntu/.nvm/versions/node/v16.19.0/bin/snarkjs \
groth16 \
setup \
"$MACI_DIR"/cli/zkeys/TallyVotes_10-1-2_test.r1cs \
"$MACI_DIR"/cli/zkeys/powersOfTau28_hez_final_20.ptau \
"$MACI_DIR"/cli/zkeys/TallyVotes_10-1-2_test.0.zkey

ls -alh zkeys