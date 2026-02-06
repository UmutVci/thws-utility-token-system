require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { RPC_URL, PRIVATE_KEY, ANVIL_PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    mynet: {
      url: RPC_URL || "",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    sepolia: {
      url: RPC_URL || "",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 11155111,
    },
    anvil: {
      url: "http://127.0.0.1:8545",
      accounts: ANVIL_PRIVATE_KEY ? [ANVIL_PRIVATE_KEY] : [],
    },
  },
};
