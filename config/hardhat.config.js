require('@nomiclabs/hardhat-ethers')

const ALCHEMY_GOERLI_API_KEY = process.env.ALCHEMY_GOERLI_API_KEY || "";
const ALCHEMY_ARBITRUM_RINKEBY_API_KEY = process.env.ALCHEMY_ARBITRUM_RINKEBY_API_KEY || "";


const config = {
  defaultNetwork: 'dev',
  networks: {
    dev: {
      url: process.env.ETH_RPC_ENDPOINT || "",
      accounts: [process.env.ETH_PRIVATE_KEY],
    },
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/" + ALCHEMY_GOERLI_API_KEY,
      accounts: [process.env.ETH_PRIVATE_KEY],
    },
    arbitrum_rinkeby: {
      url: "https://arb-rinkeby.g.alchemy.com/v2/" + ALCHEMY_ARBITRUM_RINKEBY_API_KEY,
      accounts: [process.env.ETH_PRIVATE_KEY],
    }
  },
  paths: {
    sources: "../contracts/",
    artifacts: "../contracts/artifacts/"
  }
};

module.exports = config;
