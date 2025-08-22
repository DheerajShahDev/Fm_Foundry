// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_USD, "Not enough ETH sent");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            s_addressToAmountFunded[s_funders[i]] = 0;
        }
        s_funders = new address[](0);

        (bool success, ) = payable(i_owner).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Only owner can withdraw");
        _;
    }

    // 👇 Public getters for tests
    function getAddressToAmountFunded(address funder) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function s_minimumUSD() public pure returns (uint256) {
        return MINIMUM_USD;
    }
}
