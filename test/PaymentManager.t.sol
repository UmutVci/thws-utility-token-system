// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/PaymentManager.sol";
import "../contracts/THWSToken.sol";

contract PaymentManagerTest is Test {
    THWSToken private token;
    PaymentManager private manager;

    address private student;
    address private mensa;
    address private laundry;
    address private vending;

    bytes32 private mensaService;
    bytes32 private dorm;
    bytes32 private vendingCampus;
    bytes32 private vendingHall;

    function setUp() public {
        student = vm.addr(1);
        mensa = vm.addr(2);
        laundry = vm.addr(3);
        vending = vm.addr(4);

        vm.label(student, "student");
        vm.label(mensa, "mensa");
        vm.label(laundry, "laundry");
        vm.label(vending, "vending");

        token = new THWSToken();
        manager = new PaymentManager(address(token), address(this));

        mensaService = bytes32("MENSA");
        dorm = bytes32("SHL");
        vendingCampus = bytes32("WUE");
        vendingHall = bytes32("H1");

        manager.setServiceWallet(mensaService, mensa);
        manager.setServicePrice(mensaService, 500);

        manager.setLaundryWallet(laundry);
        manager.setLaundryLockDuration(3600);
        manager.setLaundryPrice(dorm, 1, 175);

        manager.setVendingWallet(vending);
        manager.setVendingPrice(vendingCampus, vendingHall, 2, 230);

        uint256 startingBalance = 1000 * 10 ** 2;
        token.mint(student, startingBalance);
    }

    function testPaysGenericService() public {
        uint256 amount = 500;
        vm.prank(student);
        token.approve(address(manager), amount);

        uint256 orderId = 1;
        vm.expectEmit(true, true, true, true);
        emit PaymentManager.ServicePayment(
            mensaService,
            student,
            mensa,
            amount,
            orderId
        );

        vm.prank(student);
        manager.payService(mensaService, amount, orderId);

        assertEq(token.balanceOf(mensa), amount);
    }

    function testLocksLaundryMachineForDuration() public {
        uint256 machineId = 1;
        uint256 amount = 175;
        uint256 duration = manager.laundryLockDuration();

        vm.prank(student);
        token.approve(address(manager), amount * 2);

        vm.prank(student);
        manager.payLaundry(dorm, machineId);

        uint256 lockedUntil = manager.getMachineLockedUntil(dorm, machineId);
        assertEq(lockedUntil, block.timestamp + duration);
        assertEq(token.balanceOf(laundry), amount);

        uint256 lockedUntilNow = manager.getMachineLockedUntil(dorm, machineId);
        vm.expectRevert(
            abi.encodeWithSelector(PaymentManager.MachineLocked.selector, lockedUntilNow)
        );
        vm.prank(student);
        manager.payLaundry(dorm, machineId);

        vm.warp(block.timestamp + duration);

        vm.expectEmit(true, true, true, true);
        emit PaymentManager.LaundryPayment(
            dorm,
            machineId,
            student,
            laundry,
            amount,
            block.timestamp + duration
        );

        vm.prank(student);
        manager.payLaundry(dorm, machineId);
    }

    function testRoutesVendingMachinePayments() public {
        uint256 amount = 230;
        vm.prank(student);
        token.approve(address(manager), amount);

        vm.expectEmit(true, true, true, true);
        emit PaymentManager.VendingPayment(
            vendingCampus,
            vendingHall,
            2,
            student,
            vending,
            amount
        );

        vm.prank(student);
        manager.payVendingMachine(vendingCampus, vendingHall, 2);

        assertEq(token.balanceOf(vending), amount);
    }

    function testRevertsWhenServicePriceMissingOrMismatched() public {
        bytes32 missingService = bytes32("COFFEE");
        manager.setServiceWallet(missingService, mensa);

        vm.prank(student);
        token.approve(address(manager), 1000);

        vm.expectRevert(
            abi.encodeWithSelector(
                PaymentManager.PriceNotConfigured.selector,
                missingService
            )
        );
        vm.prank(student);
        manager.payService(missingService, 100, 1);

        vm.expectRevert(
            abi.encodeWithSelector(PaymentManager.AmountMismatch.selector, 500, 499)
        );
        vm.prank(student);
        manager.payService(mensaService, 499, 1);
    }

    function testRevertsWhenLaundryPriceMissing() public {
        vm.prank(student);
        token.approve(address(manager), 1000);

        bytes32 missingMachineKey = keccak256(abi.encodePacked(dorm, uint256(99)));
        vm.expectRevert(
            abi.encodeWithSelector(
                PaymentManager.PriceNotConfigured.selector,
                missingMachineKey
            )
        );
        vm.prank(student);
        manager.payLaundry(dorm, 99);
    }

    function testRevertsWhenVendingPriceMissing() public {
        vm.prank(student);
        token.approve(address(manager), 1000);

        bytes32 missingVendingKey = keccak256(
            abi.encodePacked(vendingCampus, vendingHall, uint256(3))
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                PaymentManager.PriceNotConfigured.selector,
                missingVendingKey
            )
        );
        vm.prank(student);
        manager.payVendingMachine(vendingCampus, vendingHall, 3);
    }

    function testUsesDefaultVendingPriceWhenNoOverride() public {
        uint256 defaultPrice = 999;
        manager.setDefaultVendingPrice(defaultPrice);

        vm.prank(student);
        token.approve(address(manager), defaultPrice);

        vm.expectEmit(true, true, true, true);
        emit PaymentManager.VendingPayment(
            vendingCampus,
            vendingHall,
            5,
            student,
            vending,
            defaultPrice
        );

        vm.prank(student);
        manager.payVendingMachine(vendingCampus, vendingHall, 5);

        assertEq(token.balanceOf(vending), defaultPrice);
    }

    function testUsesDefaultLaundryPriceWhenNoOverride() public {
        uint256 defaultPrice = 150;
        manager.setDefaultLaundryPrice(defaultPrice);

        uint256 machineId = 2;
        vm.prank(student);
        token.approve(address(manager), defaultPrice);

        vm.prank(student);
        manager.payLaundry(dorm, machineId);

        uint256 lockedUntil = manager.getMachineLockedUntil(dorm, machineId);
        assertEq(token.balanceOf(laundry), defaultPrice);
        assertEq(lockedUntil, block.timestamp + manager.laundryLockDuration());
    }
}
