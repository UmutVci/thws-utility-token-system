// One-time local configuration for PaymentManager on Hardhat localhost
// Run with: npx hardhat run scripts/config-local.js --network localhost
// Updates service/laundry/vending settings and mints demo tokens.

const hre = require("hardhat");

// Adjust these if you redeploy
const PAYMENT_MANAGER_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

// Sample wallets from Hardhat node (you can change as needed)
const MENSA_WALLET = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // Account #1
const MENSA_SIGNER = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"; // Account #2
const LAUNDRY_WALLET = "0x90F79bf6EB2c4f870365E785982E1f101E93b906"; // Account #3
const VENDING_WALLET = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"; // Account #4

// Demo user to receive tokens
const DEMO_USER = "0xFABB0ac9d68B0B445fB7357272Ff202C5651694a"; // Account #12

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Configurator (CONFIG_ROLE): ${deployer.address}`);

  const pm = await hre.ethers.getContractAt("PaymentManager", PAYMENT_MANAGER_ADDRESS);
  const token = await hre.ethers.getContractAt("THWSToken", TOKEN_ADDRESS);

  // Service config (MENSA)
  const service = hre.ethers.encodeBytes32String("MENSA");
  await (await pm.setServiceWallet(service, MENSA_WALLET)).wait();
  await (await pm.setServicePrice(service, 500)).wait(); // 5.00 THWS (decimals = 2)
  await (await pm.setServiceSigner(service, MENSA_SIGNER)).wait();

  // Laundry defaults
  await (await pm.setLaundryWallet(LAUNDRY_WALLET)).wait();
  await (await pm.setDefaultLaundryPrice(300)).wait(); // 3.00 THWS

  // Vending defaults
  await (await pm.setVendingWallet(VENDING_WALLET)).wait();
  await (await pm.setDefaultVendingPrice(200)).wait(); // 2.00 THWS

  // Mint demo tokens to a user
  await (await token.mint(DEMO_USER, 100_000)).wait(); // 1000.00 THWS

  console.log("Config applied:");
  console.log(`- Service MENSA wallet: ${MENSA_WALLET}, price: 500 (5.00 THWS), signer: ${MENSA_SIGNER}`);
  console.log(`- Laundry wallet: ${LAUNDRY_WALLET}, default price: 300 (3.00 THWS)`);
  console.log(`- Vending wallet: ${VENDING_WALLET}, default price: 200 (2.00 THWS)`);
  console.log(`- Minted 1000.00 THWS to ${DEMO_USER}`);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
