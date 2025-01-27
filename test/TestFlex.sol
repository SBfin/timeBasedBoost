// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FlexStaker} from "../src/FlexStaker.sol";
import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";

// Create a mock ERC20 with minting capabilities
contract MockERC20 is ERC20 {
    constructor() ERC20("Test", "TEST") {}

    // Function to mint tokens to any address (for testing)
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract TestFlex {
    FlexStaker public flexStaker;
    MockERC20 public token; // Change type to MockERC20 to access mint function
    
    constructor() {
        flexStaker = new FlexStaker();
        token = new MockERC20();
    }

    function testDeposit() public {
        // Mint some tokens to this contract
        token.mint(address(this), 1000);
        // Approve FlexStaker to spend tokens
        token.approve(address(flexStaker), 100);
        // Now we can deposit
        flexStaker.deposit(address(token), 100);
    }

    function testWithdraw() public {
        // Mint some tokens to this contract
        token.mint(address(this), 1000);
        // Approve FlexStaker to spend tokens
        token.approve(address(flexStaker), 100);
        // Now we can deposit
        flexStaker.deposit(address(token), 100);
        // Now we can withdraw
        flexStaker.withdraw(address(token), 100);
    }
}
