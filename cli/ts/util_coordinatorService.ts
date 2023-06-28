import { Request, Response } from 'express';


const SendGenProofRequestToCoordinatorService = async ( circuitName: string, circuitInput: string): Promise<any> => {
    const axios = require('axios');
    const url = "http://localhost:8080/" + 'api/generateProof';
    const data = {
        circuitName: circuitName,
        circuitInput: circuitInput
    };
    const response = await axios.post(url, data);
    console.log("Response from coordinator service: " + response.status + ", " +  JSON.stringify(response.data));
    return response.data;
}

// polling api/getResult until the status became ProofAvailable
// polling time is 1 second
// print how many times it has polled and how many times elapsed
const PollingGetProofFromCoordinatorService = async (circuitName: string): Promise<any> => {
    const axios = require('axios');
    const url = "http://localhost:8080/" + 'api/getResult';
    let response = await axios.get(url);
    let count = 0;
    let start = Date.now();

    let circuit = "";
    if (circuitName == "ProcessMessages") {
        circuit = "processMessagesCircuit"
    } else if (circuitName == "TallyVotes") {
        circuit = "tallyVotesCircuit"
    } else {
        // return error
    }

    while (response.data.data[circuit].status !== "ProofAvailable") {
        response = await axios.get(url);
        count++;
        await new Promise(r => setTimeout(r, 1000));
    }
    let end = Date.now();
    console.log("Polling " + count + " times");
    console.log("Elapsed time: " + (end - start) / 1000 + " seconds");

    const proof = JSON.parse(response.data.data[circuit].result.proof);
    const publicInputs = JSON.parse(response.data.data[circuit].result.publicInput);
    const status = response.data.data[circuit].status;
    console.log("Prover status: " + status)
    console.log("publicInput: " + publicInputs)
    return { proof, publicInputs};
}

export { SendGenProofRequestToCoordinatorService, PollingGetProofFromCoordinatorService }