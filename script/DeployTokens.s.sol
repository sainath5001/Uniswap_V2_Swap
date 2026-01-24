// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TokenA} from "../src/tokenA.sol";
import {TokenB} from "../src/tokenB.sol";

contract DeployTokensScript is Script {
    function run() external {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying tokens with address:", deployer);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy TokenA
        TokenA tokenA = new TokenA();
        console.log("TokenA deployed to:", address(tokenA));
        console.log("TokenA total supply:", tokenA.totalSupply());

        // Deploy TokenB
        TokenB tokenB = new TokenB();
        console.log("TokenB deployed to:", address(tokenB));
        console.log("TokenB total supply:", tokenB.totalSupply());

        // Stop broadcasting
        vm.stopBroadcast();

        // Log final summary
        console.log("===========================================");
        console.log("Deployment Summary:");
        console.log("TokenA:", address(tokenA));
        console.log("TokenB:", address(tokenB));
        console.log("Deployer:", deployer);
        console.log("===========================================");
    }
}
