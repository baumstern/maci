#!/bin/bash

# one signup and one valid message

set -e

export HARDHAT_NETWORK=rinkarby
export ETH_SK=0x56ab0fb24e1e5ae1064cea5a1f03ee83f639ce5755604af6bbb2cd34ec7a50ce

MACI_ADDRESS=0xB613d45E1E6b8FcaF2E4911cE7C6a12FF74D4e0A
VK_REGISTRY_ADDRESS=0x0cdD604CAA73251A3B8681bDfA6f5420c50f55B9

node build/index.js deployVkRegistry

node build/index.js setVerifyingKeys -s 10 -i 1 -m 2 -v 2 -b 1 \
    -p ./zkeys/ProcessMessages_10-2-1-2_test.0.zkey \
    -t ./zkeys/TallyVotes_10-1-2_test.0.zkey \
    --vk_registry "$VK_REGISTRY_ADDRESS"

node build/index.js create \
    --vk-registry "$VK_REGISTRY_ADDRESS"


node ./build/index.js deployPoll --maci-address "$MACI_ADDRESS" \
    --pubkey macipk.c974f4f168b79727ac98bfd53a65ea0b4e45dc2552fe73df9f8b51ebb0930330 \
    --duration 100 --max-messages 25 --max-vote-options 25 --int-state-tree-depth 1 --msg-tree-depth 2 --msg_batch_depth 1 --vote-option-tree-depth 2

node ./build/index.js signup \
    --pubkey macipk.3e7bb2d7f0a1b7e980f1b6f363d1e3b7a12b9ae354c2cd60a9cfa9fd12917391 \
    --contract "$MACI_ADDRESS"

node build/index.js publish \
    --pubkey macipk.3e7bb2d7f0a1b7e980f1b6f363d1e3b7a12b9ae354c2cd60a9cfa9fd12917391 \
    --privkey macisk.fd7aa614ec4a82716ffc219c24fd7e7b52a2b63b5afb17e81c22fe21515539c \
    --contract "$MACI_ADDRESS" \
    --state-index 1 --vote-option-index 0 --new-vote-weight 9 --nonce 1 --poll-id 0

# Only valid for localhost?    
node build/index.js timeTravel --seconds 30

node build/index.js mergeMessages --contract "$MACI_ADDRESS" --poll-id 0

node build/index.js mergeSignups -x "$MACI_ADDRESS" -o 0

rm -rf proofs tally.json
node build/index.js genProofs -x "$MACI_ADDRESS" \
    -sk macisk.49953af3585856f539d194b46c82f4ed54ec508fb9b882940cbe68bbc57e59e \
    -o 0 \
    -r ~/rapidsnark/build/prover \
    -wp ./zkeys/ProcessMessages_10-2-1-2_test \
    -wt ./zkeys/TallyVotes_10-1-2_test \
    -zp ./zkeys/ProcessMessages_10-2-1-2_test.0.zkey \
    -zt ./zkeys/TallyVotes_10-1-2_test.0.zkey \
    -t tally.json \
    -f proofs/

node build/index.js proveOnChain \
    -x "$MACI_ADDRESS" \
    -o 0 \
    -q 0xEcFcaB0A285d3380E488A39B4BB21e777f8A4EaC \
    -f proofs/

node build/index.js verify \
    -x "$MACI_ADDRESS" \
    -o 0 \
    -t tally.json \
    -q 0xEcFcaB0A285d3380E488A39B4BB21e777f8A4EaC

