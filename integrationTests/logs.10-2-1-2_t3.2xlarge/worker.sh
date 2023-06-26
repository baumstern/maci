# users, votesPerUser, elapsedProofGenTimeProcessMessages, proofNumProcessMessages, elapsedProofGenTimeTallyVotes, proofNumTallyVotes, proofsProcessMessagesGasCost, proofsTallyVotesGasCost

dir="."
for f in "$dir"/*user*; do
  log=$(basename $f)

users=$(echo $log | cut -d 'u' -f1)
elapsedProofGenTimeProcessMessages=$(cat "$log" | grep 'processMessages' | cut -d ',' -f2 | head -n 1 | cut -d ' ' -f 2)
proofNumProcessMessages=$(cat "$log" | grep 'processMessages' | cut -d ',' -f3 | head -n 1 | cut -d ' ' -f 2)

elapsedProofGenTimeTallyVotes=$(cat "$log" | grep 'tallyVotes' | cut -d ',' -f2 | head -n 1 | cut -d ' ' -f 2)
proofNumTallyVotes=$(cat "$log" | grep 'tallyVotes' | cut -d ',' -f3 | head -n 1 | cut -d ' ' -f 2)




# Gas cost of ProcessMessages
processMessagesBatchNum=$(cat "$log" | grep 'processMessagesBatchNum' | cut -d ',' -f2 | head -n 1)
# echo $processMessagesBatchNum 'batchs'

line=$(cat "$log" | grep 'processMessagesBatchNum' | cut -d ',' -f6)
proofsProcessMessagesGasCost=$(( ${line//$'\n'/+} ))
# echo $proofsProcessMessagesGasCost

# Gas cost of Tally Votes 
tallyVotesBatchNum=$(cat "$log" | grep 'tallyBatchNum' | cut -d ',' -f2 | head -n 1)
# echo $tallyVotesBatchNum 'batchs'

line=$(cat "$log" | grep 'tallyBatchNum' | cut -d ',' -f6)
proofsTallyVotesGasCost=$(( ${line//$'\n'/+} ))
# echo $proofsTallyVotesGasCost


echo $users, $elapsedProofGenTimeProcessMessages, $proofNumProcessMessages, $elapsedProofGenTimeTallyVotes, $proofNumTallyVotes, $processMessagesBatchNum, $proofsProcessMessagesGasCost, $tallyVotesBatchNum, $proofsTallyVotesGasCost >> temp


done

echo 'users, elapsedProofGenTimeProcessMessages, proofNumProcessMessages, elapsedProofGenTimeTallyVotes, proofNumTallyVotes, processMessagesBatchNum, proofsProcessMessagesGasCost, tallyVotesBatchNum, proofsTallyVotesGasCost' >> sorted
sort -n -k 1 temp >> sorted
rm temp
