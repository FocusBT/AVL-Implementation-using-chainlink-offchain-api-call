// hardhat.config.js
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.12"
      }
    ]
  },
  defaultNetwork: 'sepholia',
  networks: {
    
    sepholia: {
      url: process.env.QUICKNODE_SEPHOLIA_KEY,
      accounts: [process.env.METAMASK_PRIVATE_KEY],
    }
  },
  namedAccounts: {
    account0: 0 
  },
  etherscan: {
    apiKey: process.env.SEPHOLIA_ETHERSCAN_API
  }
};
// 0x28FeA719D7114cE383Ee22daA3d8a03f45Ea6A97