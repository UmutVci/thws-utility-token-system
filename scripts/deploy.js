// Basic deploy script for THWSToken and PaymentManager
// Usage:
//   npx hardhat run scripts/deploy.js --network <networkName>
// Make sure your hardhat.config.js has the target network configured with an account key.

const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log(`Deployer: ${deployer.address}`);
  console.log(`Network: ${hre.network.name}`);

  // Deploy ERC20
  const Token = await hre.ethers.getContractFactory("THWSToken");
  const token = await Token.deploy();
  await token.waitForDeployment();
  console.log(`THWSToken deployed at: ${token.target}`);

  // Deploy PaymentManager; initialAdmin = deployer
  const PaymentManager = await hre.ethers.getContractFactory("PaymentManager");
  const manager = await PaymentManager.deploy(token.target, deployer.address);
  await manager.waitForDeployment();
  console.log(`PaymentManager deployed at: ${manager.target}`);

  // Optional: grant CONFIG_ROLE to another address after deployment
  // const configRole = await manager.CONFIG_ROLE();
  // await manager.grantRole(configRole, "0xAdminAddress");

  // Optional: set initial service/laundry/vending config here
  // await manager.setServiceWallet(ethers.encodeBytes32String("MENSA"), "0xWallet");
  // await manager.setServicePrice(ethers.encodeBytes32String("MENSA"), 500);

  console.log("Deployment complete.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
