// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("user");
    FundMe fundMe;

    function setUp() public {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, 10e18); // Give USER 10 ETH
    }

    function testDemo() public {
        assertEq(fundMe.s_minimumUSD(), 50 * 1e18, "Minimum USD should be 50");
    }

    function testOwner() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceVersionIsAccurate() public {
        uint256 priceFeedVersion = fundMe.getVersion();
        assertEq(priceFeedVersion, 4, "Price feed version should be 4");
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18, "Amount funded should be 10 ETH");
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        uint256 startingBalance = address(fundMe).balance;
        uint256 userStartingBalance = USER.balance;

        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        uint256 endingBalance = address(fundMe).balance;
        uint256 userEndingBalance = USER.balance;

        assertEq(endingBalance, 0, "FundMe balance should be 0 after withdrawal");
        assertEq(
            userEndingBalance,
            userStartingBalance + startingBalance,
            "User balance should increase by the FundMe balance"
        );
    }

    function testWithDrawWithMultipleFunders() public funded {
    uint160 numberOfFunders = 10;
    uint256 startingFunderIndex = 1;

    for (uint256 i = startingFunderIndex; i < numberOfFunders; i++) {
        hoax(address(uint160(i)), 10e18);
        fundMe.fund{value: 10e18}();
    }

    uint256 startingOwnerBalance = fundMe.i_owner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    vm.startPrank(fundMe.i_owner());
    fundMe.withdraw();
    vm.stopPrank();

    assertEq(address(fundMe).balance, 0, "FundMe balance should be 0 after withdrawal");
    assertEq(
        fundMe.i_owner().balance,
        startingFundMeBalance + startingOwnerBalance,
        "Owner balance should equal starting balance + FundMe balance"
    );
}

}
