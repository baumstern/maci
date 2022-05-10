#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$BASE_DIR"/..
MACI_DIR="$PROJECT_ROOT"/maci


eval `"$PROJECT_ROOT"/setEnv.js`

# Overwrite hardhat config to enable network and eth private key config
cp "$PROJECT_ROOT"/config/hardhat.config.js "$MACI_DIR"/cli/

cd "$MACI_DIR"/cli
node build/index.js proveOnChain \
    --contract "$MACI_ADDRESS" \
    --poll-id "$POLL_ID" \
    --ppt "$POLL_PROCESSOR_AND_TALLYER_ADDRESS" \
    --proof-dir proofs/
