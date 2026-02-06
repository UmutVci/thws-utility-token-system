const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("PaymentManager", function () {
  async function deployFixture() {
    const [owner, student, mensa, laundry, vending] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("THWSToken");
    const token = await Token.deploy();

    const PaymentManager = await ethers.getContractFactory("PaymentManager");
    const manager = await PaymentManager.deploy(token.target, owner.address);

    const mensaService = ethers.encodeBytes32String("MENSA");
    const dorm = ethers.encodeBytes32String("SHL");
    const vendingCampus = ethers.encodeBytes32String("WUE");
    const vendingHall = ethers.encodeBytes32String("H1");

    await manager.setServiceWallet(mensaService, mensa.address);
    await manager.setServicePrice(mensaService, 500);

    await manager.setLaundryWallet(laundry.address);
    await manager.setLaundryLockDuration(3600);
    await manager.setLaundryPrice(dorm, 1, 175);

    await manager.setVendingWallet(vending.address);
    await manager.setVendingPrice(vendingCampus, vendingHall, 2, 230);

    const startingBalance = ethers.parseUnits("1000", 2);
    await token.mint(student.address, startingBalance);

    return {
      owner,
      student,
      mensa,
      laundry,
      vending,
      token,
      manager,
      startingBalance,
      mensaService,
      dorm,
      vendingCampus,
      vendingHall,
    };
  }

  it("pays a generic service", async function () {
    const { student, mensa, manager, token, mensaService } = await loadFixture(deployFixture);
    const amount = 500n; // price set to 500

    await token.connect(student).approve(manager.target, amount);

    const orderId = 1n;
    await expect(manager.connect(student).payService(mensaService, amount, orderId))
      .to.emit(manager, "ServicePayment")
      .withArgs(mensaService, student.address, mensa.address, amount, orderId);

    expect(await token.balanceOf(mensa.address)).to.equal(amount);
  });

  it("locks a laundry machine for the configured duration", async function () {
    const { student, laundry, manager, token, dorm } = await loadFixture(deployFixture);
    const machineId = 1;
    const amount = 175n; // override price set to 175 for machine 1
    const duration = await manager.laundryLockDuration();

    await token.connect(student).approve(manager.target, amount * 2n);

    const tx = await manager.connect(student).payLaundry(dorm, machineId);
    const receipt = await tx.wait();
    const block = await ethers.provider.getBlock(receipt.blockNumber);
    const lockedUntil = await manager.getMachineLockedUntil(dorm, machineId);

    expect(lockedUntil).to.equal(BigInt(block.timestamp) + duration);
    expect(await token.balanceOf(laundry.address)).to.equal(amount);

    const lockedUntilNow = await manager.getMachineLockedUntil(dorm, machineId);
    await expect(manager.connect(student).payLaundry(dorm, machineId))
      .to.be.revertedWithCustomError(manager, "MachineLocked")
      .withArgs(lockedUntilNow);

    await time.increase(duration);

    await expect(manager.connect(student).payLaundry(dorm, machineId)).to.emit(
      manager,
      "LaundryPayment"
    );
  });

  it("routes vending machine payments", async function () {
    const { student, vending, manager, token, vendingCampus, vendingHall } = await loadFixture(
      deployFixture
    );
    const amount = 230n; // price set to 230
    await token.connect(student).approve(manager.target, amount);

    await expect(manager.connect(student).payVendingMachine(vendingCampus, vendingHall, 2))
      .to.emit(manager, "VendingPayment")
      .withArgs(
        ethers.encodeBytes32String("WUE"),
        ethers.encodeBytes32String("H1"),
        2,
        student.address,
        vending.address,
        amount
      );

    expect(await token.balanceOf(vending.address)).to.equal(amount);
  });

  it("reverts when service price is missing or mismatched", async function () {
    const { student, mensa, manager, token } = await loadFixture(deployFixture);
    const missingService = ethers.encodeBytes32String("COFFEE");

    await manager.setServiceWallet(missingService, mensa.address);
    await token.connect(student).approve(manager.target, 1_000);

    await expect(manager.connect(student).payService(missingService, 100, 1))
      .to.be.revertedWithCustomError(manager, "PriceNotConfigured")
      .withArgs(missingService);

    const service = ethers.encodeBytes32String("MENSA"); // price = 500
    await expect(manager.connect(student).payService(service, 499, 1))
      .to.be.revertedWithCustomError(manager, "AmountMismatch")
      .withArgs(500, 499);
  });

  it("reverts when laundry price is missing or mismatched", async function () {
    const { student, manager, token, dorm } = await loadFixture(deployFixture);
    await token.connect(student).approve(manager.target, 1_000);

    const missingMachineKey = ethers.solidityPackedKeccak256(["bytes32", "uint256"], [dorm, 99]);
    await expect(manager.connect(student).payLaundry(dorm, 99))
      .to.be.revertedWithCustomError(manager, "PriceNotConfigured")
      .withArgs(missingMachineKey);
  });

  it("reverts when vending price is missing or mismatched", async function () {
    const { student, manager, token, vendingCampus, vendingHall } = await loadFixture(
      deployFixture
    );
    await token.connect(student).approve(manager.target, 1_000);

    const missingVendingKey = ethers.solidityPackedKeccak256(
      ["bytes32", "bytes32", "uint256"],
      [vendingCampus, vendingHall, 3]
    );
    await expect(manager.connect(student).payVendingMachine(vendingCampus, vendingHall, 3))
      .to.be.revertedWithCustomError(manager, "PriceNotConfigured")
      .withArgs(missingVendingKey);
  });

  it("uses default vending price when no override is set", async function () {
    const { student, vending, manager, token, vendingCampus, vendingHall } = await loadFixture(
      deployFixture
    );
    const defaultPrice = 999n;
    await manager.setDefaultVendingPrice(defaultPrice);
    await token.connect(student).approve(manager.target, defaultPrice);

    const tx = await manager.connect(student).payVendingMachine(vendingCampus, vendingHall, 5);
    await expect(tx)
      .to.emit(manager, "VendingPayment")
      .withArgs(vendingCampus, vendingHall, 5, student.address, vending.address, defaultPrice);
    expect(await token.balanceOf(vending.address)).to.equal(defaultPrice);
  });

  it("uses default laundry price when no override is set", async function () {
    const { student, laundry, manager, token, dorm } = await loadFixture(deployFixture);
    const defaultPrice = 150n;
    await manager.setDefaultLaundryPrice(defaultPrice);
    const machineId = 2; // no override set

    await token.connect(student).approve(manager.target, defaultPrice);

    const tx = await manager.connect(student).payLaundry(dorm, machineId);
    const receipt = await tx.wait();
    const block = await ethers.provider.getBlock(receipt.blockNumber);
    const lockedUntil = await manager.getMachineLockedUntil(dorm, machineId);

    expect(await token.balanceOf(laundry.address)).to.equal(defaultPrice);
    expect(lockedUntil).to.equal(BigInt(block.timestamp) + (await manager.laundryLockDuration()));
  });
});
