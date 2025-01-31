// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/FlexStakerFactory.sol";

contract FlexStakerFactoryTest is Test {
    FlexStakerFactory public factory;

    function setUp() public {
        factory = new FlexStakerFactory();
    }

    function testCreateStaker() public {
        // Create a new staker
        factory.createStaker(1, 1000);

        // Check that the staker was created
        address[] memory stakers = factory.getStakers();
        assertEq(stakers.length, 1, "Staker count should be 1");

        // Check that the staker address is not zero
        assertTrue(stakers[0] != address(0), "Staker address should not be zero");  
    }

    function testMultipleStakers() public {
        // Create multiple stakers
        factory.createStaker(1, 1000);
        factory.createStaker(2, 1000);

        // Check that both stakers were created
        address[] memory stakers = factory.getStakers();
        assertEq(stakers.length, 2, "Staker count should be 2");
    }
}