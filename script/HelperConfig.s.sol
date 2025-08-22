//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia
            NetworkConfig memory sepoliaConfig = getSepoliaConfig();
            console.log("Sepolia Config: Price Feed Address - %s", sepoliaConfig.priceFeed);
        } else {
            activeNetworkConfig = getAnvilConfig();
            console.log("Anvil Config: Price Feed Address - %s", activeNetworkConfig.priceFeed);
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Kovan ETH/USD Price Feed
        });
        return sepoliaConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}
