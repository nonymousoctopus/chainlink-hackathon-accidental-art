require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-ethers")
require('hardhat-deploy')
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL
const MUMBAI_RPC_URL = process.env.MUMBAI_RPC_URL
const MNEMONIC = process.env.MNEMONIC
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: { },
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: {
        mnemonic: MNEMONIC
      },
      saveDeployments: true
    },
    mumbai: {
      url: MUMBAI_RPC_URL,
      accounts: [PRIVATE_KEY],
      saveDeployments: true,
  },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
  solidity: {
    compilers: [
      {version: "0.8.0"}, {version: "0.4.24"}, {version: "0.6.6"}, {version: "0.7.0"}
    ]
  },
  namedAccounts: {
    deployer: {
      default: 0
    }
  }
}
