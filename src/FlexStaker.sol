// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";

// FlexStaker is a contract that allows users to stake their tokens and earn rewards.
// Rewards are managed by boost protocol
// FlexStaker just receives tokens from the users and emits events and calls the boost protocol
// Works for more than one tokens

contract FlexStaker is Ownable {
    // Add mapping to track deposit block numbers
    mapping(address => mapping(address => uint256)) public userDepositBlocks;
    mapping(address => mapping(address => uint256)) public userBalances;
    
    error ZeroAmount();
    error NotEnoughBalance(address token, uint256 amount);
    error TransferFailed();

    event Deposit(address indexed user, address indexed token, uint256 amount);
    // Update Withdraw event to include blocks staked
    event Withdraw(address indexed user, address indexed token, uint256 amount, uint256 blocksStaked);

    constructor() Ownable(msg.sender) {}

    function deposit(address token, uint256 amount) external {
        if (amount == 0) revert ZeroAmount();
        if (!IERC20(token).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        
        userBalances[msg.sender][token] += amount;
        // Save the current block number
        userDepositBlocks[msg.sender][token] = block.number;
        
        emit Deposit(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) external {
        if (amount == 0) revert ZeroAmount();
        if (userBalances[msg.sender][token] < amount) revert NotEnoughBalance(token, amount);
        
        uint256 blocksStaked = block.number - userDepositBlocks[msg.sender][token];
        
        userBalances[msg.sender][token] -= amount;
        if (!IERC20(token).transfer(msg.sender, amount)) revert TransferFailed();
        
        emit Withdraw(msg.sender, token, amount, blocksStaked);
    }

    /// @notice Returns the balance and blocks staked for a specific token
    /// @param user The address of the user
    /// @param token The token address to check
    /// @return balance The amount of tokens the user has staked
    /// @return blocksStaked The number of blocks since the user's last deposit
    function getUserStakeInfo(address user, address token) external view returns (uint256 balance, uint256 blocksStaked) {
        balance = userBalances[user][token];
        uint256 depositBlock = userDepositBlocks[user][token];
        blocksStaked = depositBlock == 0 ? 0 : block.number - depositBlock;
        return (balance, blocksStaked);
    }

    /// @notice Returns the balance of a specific token for a user
    /// @param user The address of the user
    /// @param token The token address to check
    /// @return The amount of tokens the user has staked
    function balanceOf(address user, address token) external view returns (uint256) {
        return userBalances[user][token];
    }

    /// @notice Returns how many blocks a user has staked a specific token
    /// @param user The address of the user
    /// @param token The token address to check
    /// @return The number of blocks since the user's last deposit
    function getBlocksStaked(address user, address token) external view returns (uint256) {
        uint256 depositBlock = userDepositBlocks[user][token];
        if (depositBlock == 0) return 0;
        return block.number - depositBlock;
    }
}
