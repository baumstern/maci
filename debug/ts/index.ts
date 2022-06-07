import {
    maciContractAbi,
} from 'maci-contracts'

import {
    MaciState,
} from 'maci-core'

import {
    PubKey,
    Message
} from 'maci-domainobjs'

import * as ethers from 'ethers'


async function main() {
    const ethProvider = 'https://arb-mainnet.g.alchemy.com/v2/2JeixoeTyrAEVClZH5-kpfcc2j3MOwDs'

    const provider = new ethers.providers.JsonRpcProvider(ethProvider)
    
    const address = '0x938fedD63C6770Ba50266Fe4C548A09FD2D1c9f1'
    
    
    const maciContract = new ethers.Contract(
        address,
        maciContractAbi,
        provider,
    )
    
    const treeDepths = await maciContract.treeDepths()
    
    const stateTreeDepth = BigInt(treeDepths[0].toString())
    const messageTreeDepth = BigInt(treeDepths[1].toString())
    const voteOptionTreeDepth = BigInt(treeDepths[2].toString())
    const maxVoteOptionIndex = BigInt((
            await maciContract.voteOptionsMaxLeafIndex()
        ).toString())
    
    const coordinatorKeypair = 1
    const maciState = new MaciState(
        coordinatorKeypair,
        stateTreeDepth,
        messageTreeDepth,
        voteOptionTreeDepth,
        maxVoteOptionIndex,
    )

    const onChainMessageRoot = await maciContract.getMessageTreeRoot()
    console.log('onchain stored state root: ' + BigInt(onChainMessageRoot).toString(10))


    // const signUpLogs = await provider.getLogs({
    //     ...maciContract.filters.SignUp(),
    //     fromBlock: 0,
    // })

    // console.log('logs length:' + signUpLogs.length)


    // There is log size limit on rpc provider
    // '{"jsonrpc":"2.0","id":47,"error":{"code":-32602,"message":"Log response size
    //  exceeded. You can make eth_getLogs requests with up to a 2K block range and no 
    //  limit on the response size, or you can request any block range with a cap of 
    //  10K logs in the response. Based on your parameters and the response size limit, 
    //  this block range should work: [0xc321aa, 0xc4a5e6]"}}'
    // 0xbf7a49, 0xc321aa, 0xc4a5e6
    let publishMessageLogs


    let Logs = await provider.getLogs({
        ...maciContract.filters.PublishMessage(),
        fromBlock: 0,
        toBlock: 0xbf7a48,
    })

    const Logs1 = await provider.getLogs({
        ...maciContract.filters.PublishMessage(),
        fromBlock: 0xbf7a49,
        toBlock: 0xc321a9,
    })

    const Logs2 = await provider.getLogs({
        ...maciContract.filters.PublishMessage(),
        fromBlock: 0xc321aa,
        toBlock: 0xc4a5e5,
    })

    const Logs3 = await provider.getLogs({
        ...maciContract.filters.PublishMessage(),
        fromBlock: 0xc4a5e6,
    })
    console.log('publish message logs length:' + Logs.length)
    Logs = Logs.concat(Logs1)
    console.log('publish message logs length:' + Logs.length)
    Logs = Logs.concat(Logs2)
    console.log('publish message logs length:' + Logs.length)
    Logs = Logs.concat(Logs3)
    console.log('publish message logs length:' + Logs.length)


    publishMessageLogs = Logs
    
    console.log('publish message logs length:' + publishMessageLogs.length)

    const iface = new ethers.utils.Interface(maciContractAbi)
    // for (const log of signUpLogs) {
    //     const event = iface.parseLog(log)
    //     const voiceCreditBalance = BigInt(event.values._voiceCreditBalance.toString())
    //     const pubKey = new PubKey([
    //         BigInt(event.values._userPubKey[0]),
    //         BigInt(event.values._userPubKey[1]),
    //     ])

    //     maciState.signUp(
    //         pubKey,
    //         voiceCreditBalance,
    //     )
    // }

    for (const log of publishMessageLogs) {
        const event = iface.parseLog(log)
        const msgIv = BigInt(event.values._message[0].toString())
        const msgData = event.values._message[1].map((x) => BigInt(x.toString()))
        const message = new Message(msgIv, msgData)
        const encPubKey = new PubKey([
            BigInt(event.values._encPubKey[0]),
            BigInt(event.values._encPubKey[1]),
        ])

        maciState.publishMessage(message, encPubKey)
    }

    console.log('generate state root: ' + maciState.messageTree.root.toString(10))

}

main()