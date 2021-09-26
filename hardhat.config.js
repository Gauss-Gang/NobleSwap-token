require("@nomiclabs/hardhat-waffle");
require("chai");
require("ethereum-waffle");
require("ethers");
require("solidity-coverage");
require("@openzeppelin/hardhat-upgrades");
const { mnemonic } = require('./secrets.json');


task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  solidity: {
    version: "0.8.7",
    settings: {
        optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: {mnemonic: mnemonic}
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: {mnemonic: mnemonic}
    }
  }
};
