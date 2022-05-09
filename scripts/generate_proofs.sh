#!/bin/bash

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$BASE_DIR"/..
MACI_DIR="$PROJECT_ROOT"/maci

RAPIDSNARK=~/rapidsnark/build/prover


eval `"$PROJECT_ROOT"/setEnv.js`

# Overwrite hardhat config to enable network and eth private key config
cp "$PROJECT_ROOT"/config/hardhat.config.js "$MACI_DIR"/cli/

cd "$MACI_DIR"/cli
node build/index.js mergeMessages \
                    --contract "$MACI_ADDRESS" \
                    --poll-id "$POLL_ID"

node build/index.js mergeSignups \
                    --contract "$MACI_ADDRESS" \
                    --poll-id "$POLL_ID"

node build/index.js genProofs \
                    --contract "$MACI_ADDRESS" \
                    --privkey macisk."$COORDINATOR_PRIVATE_KEY" \
                    --poll-id "$POLL_ID" \
                    --rapidsnark "$RAPIDSNARK" \
                    --process-witnessgen ./zkeys/ProcessMessages_10-2-1-2_test \
                    --tally-witnessgen ./zkeys/TallyVotes_10-1-2_test \
                    --process-zkey ./zkeys/ProcessMessages_10-2-1-2_test.0.zkey \
                    --tally-zkey ./zkeys/TallyVotes_10-1-2_test.0.zkey \
                    --tally-file tally.json \
                    --output proofs/

ls -al proofs

cat tally.json