// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/Lock.sol";

contract LockTest is Test {
    uint256 private constant ONE_YEAR_IN_SECS = 365 days;
    uint256 private constant ONE_GWEI = 1_000_000_000;

    receive() external payable {}

    function deployOneYearLock()
        internal
        returns (Lock lock, uint256 unlockTime, uint256 lockedAmount, address owner, address other)
    {
        lockedAmount = ONE_GWEI;
        unlockTime = block.timestamp + ONE_YEAR_IN_SECS;

        vm.deal(address(this), lockedAmount);
        lock = new Lock{value: lockedAmount}(unlockTime);

        owner = address(this);
        other = vm.addr(1);
    }

    function testDeploymentSetsUnlockTime() public {
        (Lock lock, uint256 unlockTime, , , ) = deployOneYearLock();
        assertEq(lock.unlockTime(), unlockTime);
    }

    function testDeploymentSetsOwner() public {
        (Lock lock, , , address owner, ) = deployOneYearLock();
        assertEq(lock.owner(), owner);
    }

    function testDeploymentStoresFunds() public {
        (Lock lock, , uint256 lockedAmount, , ) = deployOneYearLock();
        assertEq(address(lock).balance, lockedAmount);
    }

    function testDeploymentFailsIfUnlockTimeNotFuture() public {
        vm.deal(address(this), 1);
        vm.expectRevert("Unlock time should be in the future");
        new Lock{value: 1}(block.timestamp);
    }

    function testWithdrawRevertsIfCalledTooSoon() public {
        (Lock lock, , , , ) = deployOneYearLock();
        vm.expectRevert("You can't withdraw yet");
        lock.withdraw();
    }

    function testWithdrawRevertsIfNotOwner() public {
        (Lock lock, uint256 unlockTime, , , address other) = deployOneYearLock();

        vm.warp(unlockTime);
        vm.expectRevert("You aren't the owner");
        vm.prank(other);
        lock.withdraw();
    }

    function testWithdrawSucceedsForOwnerAfterUnlock() public {
        (Lock lock, uint256 unlockTime, , , ) = deployOneYearLock();
        vm.warp(unlockTime);
        lock.withdraw();
    }

    function testWithdrawEmitsEvent() public {
        (Lock lock, uint256 unlockTime, uint256 lockedAmount, , ) = deployOneYearLock();
        vm.warp(unlockTime);

        vm.expectEmit(true, true, true, true);
        emit Lock.Withdrawal(lockedAmount, block.timestamp);

        lock.withdraw();
    }

    function testWithdrawTransfersFundsToOwner() public {
        (Lock lock, uint256 unlockTime, uint256 lockedAmount, , ) = deployOneYearLock();
        vm.warp(unlockTime);

        uint256 ownerBalanceBefore = address(this).balance;
        lock.withdraw();

        assertEq(address(lock).balance, 0);
        assertEq(address(this).balance, ownerBalanceBefore + lockedAmount);
    }
}
