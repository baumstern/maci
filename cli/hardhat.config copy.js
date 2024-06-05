/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-ethers')

const {
  DEFAULT_ETH_SK,
  DEFAULT_ETH_PROVIDER,
} = require('./build/defaults')

const config = {
  defaultNetwork: 'localhost',
  networks: {
    localhost: {
      url: "https://8a70-178-19-221-38.ngrok-free.app" || DEFAULT_ETH_PROVIDER,
      accounts: [ process.env.ETH_SK || DEFAULT_ETH_SK ],
      loggingEnabled: false,
    },
  },
  paths: {
    sources: "../contracts/contracts/",
    artifacts: "../contracts/artifacts"
  }
};

module.exports = config;
