// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../contracts/THWSToken.sol";
import "../contracts/PaymentManager.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        THWSToken token = new THWSToken();
        PaymentManager manager = new PaymentManager(address(token), msg.sender);

        console2.log("THWSToken:", address(token));
        console2.log("PaymentManager:", address(manager));

        vm.stopBroadcast();
    }
}