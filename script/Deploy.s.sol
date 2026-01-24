// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {uniswapV2Swap} from "../src/uniswapV2Swap.sol";

contract DeployScript is Script {
    // Sepolia Uniswap V2 addresses
    address constant UNISWAP_V2_SEPOLIA_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_SEPOLIA_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    function run() external {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy uniswapV2Swap contract with Sepolia addresses
        // Pass zero addresses to use default Sepolia addresses
        uniswapV2Swap uniswapSwap = new uniswapV2Swap(address(0), address(0));

        // Stop broadcasting
        vm.stopBroadcast();

        // Log deployment information
        console.log("===========================================");
        console.log("uniswapV2Swap deployed to:", address(uniswapSwap));
        console.log("Factory address:", address(uniswapSwap.uniswap_v2_sepolia_factory()));
        console.log("Router address:", address(uniswapSwap.uniswap_v2_sepolia_router()));
        console.log("===========================================");
    }
}
