#!/usr/bin/env node

const TOML = require('@ltd/j-toml')

const { readFile } =require('node:fs')

 readFile('input/.example.toml', (err, data) => {
    if (err) throw err
    const config = data.toString()
    const rootTable = TOML.parse(config)

    
    console.log('export MACI_ADDRESS='+rootTable.poll.MACI_address)
    console.log('export POLL_ID='+rootTable.poll.poll_id)

    console.log('export HARDHAT_NETWORK='+rootTable.network.network)
    
    // TODO: export following env only if custom option enabled
    // console.log('export ETH_RPC_ENDPOINT='+rootTable.network.rpc_endpoint)
})

