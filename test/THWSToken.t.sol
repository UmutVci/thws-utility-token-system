// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/THWSToken.sol";

contract THWSTokenTest is Test {
    THWSToken private token;

    function setUp() public {
        token = new THWSToken();
    }

    function testDecimalsIsTwo() public view {
        assertEq(token.decimals(), 2);
    }

    function testOwnerCanMint() public {
        token.mint(address(this), 123);
        assertEq(token.balanceOf(address(this)), 123);
    }
}
