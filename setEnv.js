#!/usr/bin/env node

const TOML = require('@ltd/j-toml')

const { readFile } =require('node:fs')

 readFile('input/trigger.toml', (err, data) => {
    if (err) throw err
    const config = data.toString()
    const rootTable = TOML.parse(config)

    
    console.log('export MACI_ADDRESS='+rootTable.poll.MACI_address)
    console.log('export POLL_PROCESSOR_AND_TALLYER_ADDRESS='+rootTable.poll.poll_processor_and_tallyer_address)
    console.log('export POLL_ID='+rootTable.poll.poll_id)
    console.log('export ZKEYS_PARAMS='+rootTable.poll.zkey_params)

    console.log('export HARDHAT_NETWORK='+rootTable.network.network)
    
    
    // TODO: export following env only if custom option enabled
    // console.log('export ETH_RPC_ENDPOINT='+rootTable.network.rpc_endpoint)
})

