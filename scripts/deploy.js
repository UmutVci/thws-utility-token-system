// Basic deploy script for THWSToken and PaymentManager
// Usage:
//   npx hardhat run scripts/deploy.js --network <networkName>
// Make sure your hardhat.config.js has the target network configured with an account key.

const fs = require("fs");
const path = require("path");
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

  const network = await hre.ethers.provider.getNetwork();
  const chainId = Number(network.chainId);
  const rpcUrl = hre.network.config.url || "";

  const deployment = {
    network: hre.network.name,
    chainId,
    rpcUrl,
    paymentManager: {
      address: manager.target,
      abiPath: "artifacts/contracts/PaymentManager.sol/PaymentManager.json",
    },
    token: {
      address: token.target,
      abiPath: "artifacts/contracts/THWSToken.sol/THWSToken.json",
    },
  };

  const defaultOut = path.join(__dirname, "..", "deployments", `${hre.network.name}.json`);
  const outPath = process.env.DEPLOY_OUT || defaultOut;
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(deployment, null, 2));
  console.log(`Wrote deployment to: ${outPath}`);

  const dartOut = process.env.FRONTEND_DART_OUT;
  if (dartOut) {
    const dart = `class ContractsConfig {
  static const String rpcUrl = '${rpcUrl}';
  static const int chainId = ${chainId};
  static const String paymentManager = '${manager.target}';
  static const String token = '${token.target}';
}
`;
    fs.mkdirSync(path.dirname(dartOut), { recursive: true });
    fs.writeFileSync(dartOut, dart);
    console.log(`Wrote frontend Dart config to: ${dartOut}`);
  }

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
