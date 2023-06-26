jest.setTimeout(3000000)


const _ = require('lodash');
 
import {
    loadData,
    executeSuite,
} from './suites'

import { loadYaml } from './utils'

describe('Test suites', () => {
    const config = loadYaml()
    const data = loadData('bench.json')
    const archetype = data.suites[0]

    // archetype.expectedTally =  Array(config.constants.maci.maxVoteOptions).fill(0)
    // archetype.expectedSpentVoiceCredits =  Array(config.constants.maci.maxVoteOptions).fill(0)

    let suites = []
    for (let numUsers = 1; numUsers <= 12500; numUsers++ ) {
        archetype.name = `${numUsers}user${numUsers}vote`
        archetype.numVotesPerUser = 1
        archetype.numUsers = numUsers
        archetype.expectedTotalSpentVoiceCredits = numUsers
        
        // archetype.expectedTally[0]++
        // archetype.expectedSpentVoiceCredits[0]++

        
        suites.push(_.cloneDeep(archetype))

        // let delta = 125 - (numUsers % 125);
        // numUsers += delta
    }

    // console.log(suites)

    for (const test of suites) {
        it(test.description, async () => {
            const result = await executeSuite(test, expect)
            console.log(result)

            expect(result).toBeTruthy()
        })
    }
})
