// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./FlexStaker.sol";

contract FlexStakerFactory {
    address[] public stakers;

    event StakerCreated(address indexed stakerAddress, address indexed owner);
    error BoostIdAlreadyExists();

    function getStakerByBoostId(uint256 _boostId) public view returns (address) {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (FlexStaker(stakers[i]).id() == _boostId) {
                return stakers[i];
            }
        }
        return address(0);
    }

    modifier boostIdExists(uint256 _id) {
        if (getStakerByBoostId(_id) != address(0)) revert BoostIdAlreadyExists();
        _;
    }

    function createStaker(uint256 _id, uint256 _blockDuration) external boostIdExists(_id) {
        FlexStaker staker = new FlexStaker(_id, _blockDuration);
        stakers.push(address(staker));
        emit StakerCreated(address(staker), msg.sender);
    }

    function getStakers() external view returns (address[] memory) {
        return stakers;
    }

    function getBoostId(address staker) external view returns (uint256) {
        return FlexStaker(staker).id();
    }
}
