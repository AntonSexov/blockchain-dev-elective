require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  etherscan: {
    apiKey: process.env.ETHER_SCAN,
  },
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/PoE88OYaN127e1qqc-HMFkUZGGRC4KfD",
      accounts: [process.env.PRIVATE_KEY],
    }
  }
};