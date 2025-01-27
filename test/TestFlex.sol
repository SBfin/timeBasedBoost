// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FlexStaker} from "../src/FlexStaker.sol";
import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Test} from "forge-std/Test.sol";
// Create a mock ERC20 with minting capabilities
contract MockERC20 is ERC20 {
    constructor() ERC20("Test", "TEST") {}

    // Function to mint tokens to any address (for testing)
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract TestFlex is Test {
    FlexStaker public flexStaker;
    MockERC20 public token; // Change type to MockERC20 to access mint function
    
    constructor() {
        flexStaker = new FlexStaker();
        token = new MockERC20();
    }

    function testDeposit() public {
        // Mint some tokens to this contract
        token.mint(address(this), 1000);
        
        // Check initial balance
        assertEq(token.balanceOf(address(this)), 1000, "Initial balance should be 1000");
        assertEq(token.balanceOf(address(flexStaker)), 0, "FlexStaker should start with 0 balance");

        // Approve FlexStaker to spend tokens
        token.approve(address(flexStaker), 100);
        
        // Now we can deposit
        flexStaker.deposit(address(token), 100);

        // Check balances after deposit
        assertEq(token.balanceOf(address(this)), 900, "User balance should decrease by 100");
        assertEq(token.balanceOf(address(flexStaker)), 100, "FlexStaker should have received 100 tokens");
    }

    function testWithdraw() public {
        // Mint some tokens to this contract
        token.mint(address(this), 1000);
        
        // Check initial balance
        assertEq(token.balanceOf(address(this)), 1000, "Initial balance should be 1000");
        
        // Approve FlexStaker to spend tokens
        token.approve(address(flexStaker), 100);
        
        // Deposit
        flexStaker.deposit(address(token), 100);
        
        // Check balances after deposit
        assertEq(token.balanceOf(address(this)), 900, "User balance should decrease by 100");
        assertEq(token.balanceOf(address(flexStaker)), 100, "FlexStaker should have received 100 tokens");
        
        // Now we can withdraw
        flexStaker.withdraw(address(token), 100);
        
        // Check balances after withdrawal
        assertEq(token.balanceOf(address(this)), 1000, "User should have received tokens back");
        assertEq(token.balanceOf(address(flexStaker)), 0, "FlexStaker should have 0 balance");
    }

    function testGetUserStakeInfo() public {
        // Mint and deposit tokens
        token.mint(address(this), 1000);
        token.approve(address(flexStaker), 100);
        flexStaker.deposit(address(token), 100);

        // Get stake info
        (uint256 balance, uint256 blocksStaked) = flexStaker.getUserStakeInfo(address(this), address(token));
        
        // Assert balance
        assertEq(balance, 100, "Balance should be 100");
        assertEq(blocksStaked, 0, "Blocks staked should be greater than 0");
    }
}
