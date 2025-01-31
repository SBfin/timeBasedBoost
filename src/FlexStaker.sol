// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin-contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";

// FlexStaker is a contract that allows users to stake their tokens and earn rewards.
// Rewards are managed by boost protocol
// FlexStaker just receives tokens from the users and emits events and calls the boost protocol
// Works for more than one tokens
// TODO: Add boost ID to the events

contract FlexStaker is Ownable {
    // Add mapping to track deposit block numbers
    mapping(address => mapping(address => uint256)) public userDepositBlocks;
    mapping(address => mapping(address => uint256)) public userBalances;

    // Blocks to wait before withdraw. About 30 mins.
    uint256 public MINIMUM_LOCK_PERIOD = 5;
    
    uint256 public id;
    uint256 public blockDuration;
    uint256 public startBlock;
    uint256 public endBlock;

    error ZeroAmount();
    error NotEnoughBalance(address token, uint256 amount);
    error TransferFailed();
    error NotEnoughBlocksStaked(uint256 blocksStaked);

    event Deposit(address indexed user, address indexed token, uint256 amount);
    // Update Withdraw event to include blocks staked
    event Withdraw(address indexed user, uint256 id, address indexed token, uint256 amount, uint256 blocksStaked, uint256 amountPerBlock);

    constructor(uint256 _id, uint256 _blockDuration) Ownable(msg.sender) {
        id = _id;
        blockDuration = _blockDuration;
        startBlock = block.number;
        endBlock = startBlock + blockDuration;
    }

    // TODO: Handle multiple deposits of the same token
    function deposit(address token, uint256 amount) external isWithinBoostPeriod {
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
        if (blocksStaked < MINIMUM_LOCK_PERIOD) revert NotEnoughBlocksStaked(blocksStaked);
        userBalances[msg.sender][token] -= amount;
        if (!IERC20(token).transfer(msg.sender, amount)) revert TransferFailed();

        uint256 amountPerBlock = amount * blocksStaked;
        
        emit Withdraw(msg.sender, id, token, amount, blocksStaked, amountPerBlock);
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

    function getId() external view returns (uint256) {
        return id;
    }

    function getStartBlock() external view returns (uint256) {
        return startBlock;
    }

    function getEndBlock() external view returns (uint256) {
        return endBlock;
    }

    function getBlockDuration() external view returns (uint256) {
        return blockDuration;
    }

    // modifier to check if the block is within the boost period
    modifier isWithinBoostPeriod() {
        require(block.number >= startBlock && block.number <= endBlock, "Not within boost period");
        _;
    }
}
