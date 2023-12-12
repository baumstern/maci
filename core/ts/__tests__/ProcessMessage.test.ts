/* eslint-disable */
describe("Message processing", () => {
  describe("Process a batch of messages", () => {
    beforeEach(async () => {
      testHarness = new TestHarness();

      poll = testHarness.poll;
    });

    it("processMessage() should process a valid message", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(1);
      testHarness.vote(users[0], testHarness.getStateIndex(users[0]), voteOptionIndex, voteWeight, nonce);
      testHarness.finalizePoll();

      expect(poll.messages.length).to.eq(1);
      expect(poll.tallyResult[0]).to.eq(BigInt(9));
    });

    it("processMessage() should not process messages twice", async () => {
      const voteOptionIndex = BigInt(0);
      const voteWeight = BigInt(9);
      const nonce = BigInt(1);

      const users = testHarness.createUsers(1);
      testHarness.vote(users[0], testHarness.getStateIndex(users[0]), voteOptionIndex, voteWeight, nonce);
      poll.processMessages(testHarness.pollId);

      expect(() => {
        poll.processMessages(testHarness.pollId);
      }).to.throw();

      poll.tallyVotes();

      expect(poll.messages.length).to.eq(1);
      expect(poll.tallyResult[0]).to.eq(BigInt(9));
    });

    it("processMessage() should not process a message with an incorrect nonce", async () => {
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
    it("processMessage() should not process a message with an incorrect vote weight", async () => {
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

    it("processMessage() should not process a message with an incorrect state tree index", async () => {
      const voteOptionIndex = BigInt(0);
      const nonce = BigInt(1);
      const numVotes = 5;

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
      const expectedNumVotes = numVotes;
      expect(messageLengthResult).to.eq(expectedNumVotes);

      const tallyResult = poll.tallyResult[0];
      const expectedTallyResult = BigInt(0);
      expect(tallyResult).to.eq(expectedTallyResult);
    });

    it("processMessage() should not process a message with an incorrect signature", async () => {
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

    it("processMessage() should not process a message with an invalid coordinator key", async () => {
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
