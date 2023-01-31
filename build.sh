#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
MACI_DIR="$HOME"/maci

source "$HOME"/.bashrc

# Compile circuits
cd "$MACI_DIR"/cli/
npx zkey-manager compile -c ./zkeys.config.yml


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
$(which snarkjs) \
groth16 \
setup \
zkeys/ProcessMessages_10-2-1-2_test.r1cs \
zkeys/powersOfTau28_hez_final_22.ptau zkeys/ProcessMessages_10-2-1-2_test.0.zkey

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
$(which snarkjs) \
groth16 \
setup \
zkeys/TallyVotes_10-1-2_test.r1cs \
zkeys/powersOfTau28_hez_final_23.ptau zkeys/TallyVotes_10-1-2_test.0.zkey

ls -alh zkeys