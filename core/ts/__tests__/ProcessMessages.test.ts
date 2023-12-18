import { AssertionError } from "assert";
import { expect } from "chai";

import { Keypair } from "maci-domainobjs";

import { Poll } from "..";
import { TestHarness } from "./utils/MaciTestHarness";

describe("Poll message processing and validation", function () {
  // set timeout to 30 seconds
  this.timeout(30000);

  let testHarness: TestHarness;
  let poll: Poll;

  describe("Sanity checks", () => {
    beforeEach(async () => {
      testHarness = new TestHarness();

      poll = testHarness.poll;
    });

    it("processMessages() should process a valid message", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(1);
      testHarness.vote(users[0], testHarness.getStateIndex(users[0]), voteOptionIndex, voteWeight, nonce);
      testHarness.finalizePoll();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = users.length;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(9);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    it("processMessages() should not process messages twice", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(1);
      testHarness.vote(users[0], testHarness.getStateIndex(users[0]), voteOptionIndex, voteWeight, nonce);
      poll.processMessages(testHarness.pollId);

      expect(() => {
        poll.processMessages(testHarness.pollId);
      }).to.throw(AssertionError, /No more messages to process/);

      poll.tallyVotes();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = users.length;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(9);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    it("processMessages() should not process a message with an incorrect nonce", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);

      const users = testHarness.createUsers(5);
      // generate a bunch of invalid votes with nonces that are not 1
      let nonce: bigint;
      for (let i = 0; i < users.length; i++) {
        do {
          nonce = BigInt(Math.floor(Math.random() * 100) - 50);
        } while (nonce === BigInt(1));

        testHarness.vote(users[i], testHarness.getStateIndex(users[i]), voteOptionIndex, voteWeight, nonce);
      }

      testHarness.finalizePoll();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = users.length;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(0);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    // note: When voting, the voice credit is used. The amount of voice credit used is
    // the square of the vote weight. Since the maximum voice credit is 100 here,
    // the vote weight can only be a value between 1 and 10
    // (as these are the square roots of numbers up to 100).
    it("processMessages() should not process a message with an incorrect vote weight", async () => {
      const voteOptionIndex = BigInt(0);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(5);

      // generate a bunch of invalid votes with vote weights that are not between 1 and 10
      let voteWeight: bigint;
      for (let i = 0; i < users.length; i++) {
        do {
          voteWeight = BigInt(Math.floor(Math.random() * 100) - 50);
        } while (BigInt(1) <= voteWeight && voteWeight <= BigInt(10));

        testHarness.vote(users[i], testHarness.getStateIndex(users[i]), voteOptionIndex, voteWeight, nonce);
      }

      testHarness.finalizePoll();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = users.length;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(0);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    it("processMessages() should not process a message with an incorrect state tree index", async () => {
      const voteOptionIndex = BigInt(0);
      const nonce = BigInt(1);
      const voteWeight = BigInt(9);
      const numVotes = 5;

      const users = testHarness.createUsers(5);

      for (let i = 0; i < users.length; i++) {
        // generate a bunch of invalid votes with incorrect state tree index
        testHarness.vote(users[i], testHarness.getStateIndex(users[i]) + 1, voteOptionIndex, voteWeight, nonce);
      }

      testHarness.finalizePoll();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = numVotes;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(0);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    it("processMessages() should not process a message with an incorrect signature", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(2);

      const { command } = testHarness.createCommand(
        users[0],
        testHarness.getStateIndex(users[0]),
        voteOptionIndex,
        voteWeight,
        nonce,
      );

      // create an invalid signature
      const { signature: invalidSignature } = testHarness.createCommand(
        users[1],
        testHarness.getStateIndex(users[0]),
        voteOptionIndex,
        voteWeight,
        nonce,
      );

      // sign the command with the invalid signature
      const { message, encPubKey } = testHarness.createMessage(
        command,
        invalidSignature,
        testHarness.coordinatorKeypair,
      );

      testHarness.poll.publishMessage(message, encPubKey);
      testHarness.finalizePoll();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = users.length - 1;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(0);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    it("processMessages() should not process a message with an invalid coordinator key", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(1);

      const { command, signature } = testHarness.createCommand(
        users[0],
        testHarness.getStateIndex(users[0]),
        voteOptionIndex,
        voteWeight,
        nonce,
      );

      const { message, encPubKey } = testHarness.createMessage(command, signature, new Keypair());

      testHarness.poll.publishMessage(message, encPubKey);
      testHarness.finalizePoll();

      const messageLengthResult = poll.messages.length;
      const expectedNumVotes = users.length;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(0);
      expect(tallyResult).to.eq(expectedTallyResult);
    });
  });
});
