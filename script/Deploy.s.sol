// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FlexStaker} from "../src/FlexStaker.sol";
import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
contract Deploy is Script {
    FlexStaker public flexStaker;

    function run() public {
        vm.startBroadcast();
        flexStaker = new FlexStaker();
        console.log("FlexStaker deployed at:", address(flexStaker));
        vm.stopBroadcast();
    }
}