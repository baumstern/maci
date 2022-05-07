/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-ethers')


const config = {
  defaultNetwork: 'dev',
  networks: {
    dev: {
      url: process.env.ETH_RPC_ENDPOINT,
      accounts: [process.env.ETH_SK],
    }
  },
  paths: {
    sources: "node_modules/maci-contracts/contracts/",
    artifacts: "node_modules/maci-contracts/artifacts/"
  }
};

module.exports = config;
