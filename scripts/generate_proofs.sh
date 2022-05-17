#!/bin/bash

set -x

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT="$BASE_DIR"/..
MACI_DIR="$PROJECT_ROOT"/maci

RAPIDSNARK=~/rapidsnark/build/prover


eval `"$PROJECT_ROOT"/setEnv.js`

# $ZKEY_PARAMS should be declared in `input/*.toml` config and exported by `setEnv.js` scropt
STATE_TREE_DEPTH=$(echo "$ZKEYS_PARAMS" | cut -d '-' -f 1)
INT_STATE_TREE_DEPTH=$(echo "$ZKEYS_PARAMS" | cut -d '-' -f 3)
VOTE_OPTION_TREE_DEPTH=$(echo "$ZKEYS_PARAMS" | cut -d '-' -f 4)

TALLY_PARAMS=""$STATE_TREE_DEPTH"-"$INT_STATE_TREE_DEPTH"-"$VOTE_OPTION_TREE_DEPTH""

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
                    --process-witnessgen ./zkeys/ProcessMessages_"$ZKEYS_PARAMS"_test \
                    --tally-witnessgen ./zkeys/TallyVotes_"$TALLY_PARAMS"_test \
                    --process-zkey ./zkeys/ProcessMessages_"$ZKEYS_PARAMS"_test.0.zkey \
                    --tally-zkey ./zkeys/TallyVotes_"$TALLY_PARAMS"_test.0.zkey \
                    --tally-file tally.json \
                    --output proofs/

ls -al proofs

cat tally.json