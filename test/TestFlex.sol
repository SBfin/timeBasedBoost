// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FlexStaker} from "../src/FlexStaker.sol";
import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Test, Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

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
        flexStaker = new FlexStaker(1, 1000);
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

        // Wait for some blocks
        vm.roll(block.number + flexStaker.MINIMUM_LOCK_PERIOD() + 1);
        
        // Check balances after deposit
        assertEq(token.balanceOf(address(this)), 900, "User balance should decrease by 100");
        assertEq(token.balanceOf(address(flexStaker)), 100, "FlexStaker should have received 100 tokens");
        
        // Now we can withdraw
        vm.recordLogs();
        flexStaker.withdraw(address(token), 100);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // First log is Transfer
        assertEq(entries[0].topics[0], 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef);

        // Second log is Withdraw
        assertEq(entries[1].topics[0], 0x25993effddf3b74ffcc0e68e5440be3fba18b532cdf14462257fb11e7c22fb95);

        /*
        for (uint i = 0; i < entries.length; i++) {
            console.log("Event topic 0:", entries[i].topics[0]);
            console.log("Event data:", entries[i].data);
        }*/
        
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

    function testGasDeposit() public {
        // Setup
        token.mint(address(this), 1000);
        token.approve(address(flexStaker), 100);
        
        // Measure gas for deposit
        uint256 startGas = gasleft();
        flexStaker.deposit(address(token), 100);
        uint256 gasUsed = startGas - gasleft();
        
        console.log("Gas used for deposit:", gasUsed);
    }

    function testGasWithdraw() public {
        // Setup
        token.mint(address(this), 1000);
        token.approve(address(flexStaker), 100);
        flexStaker.deposit(address(token), 100);

        // Wait for some blocks
        vm.roll(block.number + flexStaker.MINIMUM_LOCK_PERIOD() + 1);
        
        // Measure gas for withdraw
        uint256 startGas = gasleft();
        flexStaker.withdraw(address(token), 100);
        uint256 gasUsed = startGas - gasleft();
        
        console.log("Gas used for withdraw:", gasUsed);
    }

}
