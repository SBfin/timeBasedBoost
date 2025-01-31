pragma solidity ^0.8.26;

import {FlexStakerFactory} from "../src/FlexStakerFactory.sol";
import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
contract Deploy is Script {
    FlexStakerFactory public flexStakerFactory;

    function run() public {
        vm.startBroadcast();
        flexStakerFactory = new FlexStakerFactory();
        console.log("FlexStakerFactory deployed at:", address(flexStakerFactory));
        vm.stopBroadcast();
    }
}