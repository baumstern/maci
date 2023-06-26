#!/bin/bash

dir="."
for f in "$dir"/*user*; do
  log=$(basename $f)

users=$(echo $log | cut -d 'u' -f1)
elapsedProofGenTimeProcessMessages=$(cat "$log" | grep 'processMessages' | cut -d ',' -f2 | head -n 1 | cut -d ' ' -f 2)
proofNumProcessMessages=$(cat "$log" | grep 'processMessages' | cut -d ',' -f3 | head -n 1 | cut -d ' ' -f 2)

elapsedProofGenTimeTallyVotes=$(cat "$log" | grep 'tallyVotes' | cut -d ',' -f2 | head -n 1 | cut -d ' ' -f 2)
proofNumTallyVotes=$(cat "$log" | grep 'tallyVotes' | cut -d ',' -f3 | head -n 1 | cut -d ' ' -f 2)



# Process gas costs of merging tree on-chain
part1=$(cat "$log" | sed -e '/message tree/,$d')
part2=$(cat "$log" | sed -n -e '/message tree/,$p' )

# merging message subtree
line=$(echo "$part1" | grep 'mergeMaciStateAqSubRoots' | cut -d ':' -f2)
mergeMessageSubtreeCost=$(( ${line//$'\n'/+} ))

# merging message tree
line=$(echo "$part1" | grep 'mergeMessageAq' | cut -d ':' -f2)
mergeMessageTreeCost=$(( ${line//$'\n'/+} ))

# merging state subtree
line=$(echo "$part2" | grep 'mergeMaciStateAqSubRoots' | cut -d ':' -f2)
mergeStateSubtreeCost=$(( ${line//$'\n'/+} ))

# merging state tree
line=$(echo "$part2" | grep 'mergeStateAq' | cut -d ':' -f2)
mergeStateTreeCost=$(( ${line//$'\n'/+} ))


# Gas cost of ProcessMessages
processMessagesBatchNum=$(cat "$log" | grep 'processMessagesBatchNum' | cut -d ',' -f2 | head -n 1)

line=$(cat "$log" | grep 'processMessagesBatchNum' | cut -d ',' -f6)
proofsProcessMessagesGasCost=$(( ${line//$'\n'/+} ))


# Gas cost of Tally Votes 
tallyVotesBatchNum=$(cat "$log" | grep 'tallyBatchNum' | cut -d ',' -f2 | head -n 1)

line=$(cat "$log" | grep 'tallyBatchNum' | cut -d ',' -f6)
proofsTallyVotesGasCost=$(( ${line//$'\n'/+} ))



echo $users, $elapsedProofGenTimeProcessMessages, $proofNumProcessMessages, $elapsedProofGenTimeTallyVotes, $proofNumTallyVotes, $mergeMessageSubtreeCost, $mergeMessageTreeCost, $mergeStateSubtreeCost, $mergeStateTreeCost, $processMessagesBatchNum, $proofsProcessMessagesGasCost, $tallyVotesBatchNum, $proofsTallyVotesGasCost >> temp


done

echo 'users, elapsedProofGenTimeProcessMessages, proofNumProcessMessages, elapsedProofGenTimeTallyVotes, proofNumTallyVotes, mergeMessageSubtreeCost, mergeMessageTreeCost, mergeStateSubtreeCost, mergeStateTreeCost, processMessagesBatchNum, proofsProcessMessagesGasCost, tallyVotesBatchNum, proofsTallyVotesGasCost' >> sorted
sort -n -k 1 temp >> sorted
rm temp
