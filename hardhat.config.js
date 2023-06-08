require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.

require('dotenv').config();

const { INFURA_PROJECT_ID, PRIVATE_KEY,POLYGONSCAN_API_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    mainnet: {
      url: `https://polygon-rpc.com`,
      accounts: [PRIVATE_KEY]
    },
    mumbai: {
      url: `https://rpc-mumbai.maticvigil.com`,
      accounts: [PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY,
 }
};
