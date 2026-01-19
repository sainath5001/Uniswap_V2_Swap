// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {uniswapV2Swap} from "../src/uniswapV2Swap.sol";
import {Test} from "forge-std/Test.sol";
import {TokenA} from "../src/tokenA.sol";
import {TokenB} from "../src/tokenB.sol";
import {console} from "forge-std/console.sol";
import {MockUniswapV2Factory} from "./mocks/MockFactory.sol";
import {MockUniswapV2Router02, MockWETH} from "./mocks/MockRouter.sol";

contract UniswapV2SwapTest is Test {
    uniswapV2Swap uniswapV2SwapInstance;
    TokenA tokenA;
    TokenB tokenB;
    MockUniswapV2Factory factory;
    MockUniswapV2Router02 router;
    MockWETH weth;
    address recipient = address(0xAE7168d00595a769C9434AB1ddE4D9F0273177CE);

    function setUp() public {
        // Deploy mock contracts
        factory = new MockUniswapV2Factory();
        weth = new MockWETH();
        router = new MockUniswapV2Router02(address(factory), address(weth));

        // Deploy uniswapV2Swap with factory and router addresses
        uniswapV2SwapInstance = new uniswapV2Swap(address(factory), address(router));

        tokenA = new TokenA();
        tokenB = new TokenB();
    }

    function testCreatePair() public {
        address pairAddress = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        assertTrue(pairAddress != address(0), "Pair address should not be zero");
        console.log("Pair created at address:", pairAddress);
    }

    function testGetPairAddress() public {
        address pairAddress1 = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        address pairAddress2 = uniswapV2SwapInstance.getPairAddress(address(tokenA), address(tokenB));
        assertEq(pairAddress1, pairAddress2, "Pair addresses should match");
        console.log("Pair address retrieved:", pairAddress2);
    }

    function testAddLiquidity() public {
        // Create pair
        address pairAddress = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));

        // Transfer tokens to uniswapV2Swap contract
        uint256 amountA = 100 * 10 ** 18; // 100 TokenA
        uint256 amountB = 1000 * 10 ** 18; // 1000 TokenB
        tokenA.transfer(address(uniswapV2SwapInstance), amountA);
        tokenB.transfer(address(uniswapV2SwapInstance), amountB);

        // Add liquidity
        uint256 deadline = block.timestamp + 1 minutes;
        (uint256 amountAAdded, uint256 amountBAdded, uint256 liquidity) =
            uniswapV2SwapInstance.addLiquidity(address(tokenA), address(tokenB), amountA, amountB, recipient, deadline);

        // Check balances in the pair contract
        uint256 pairBalanceA = tokenA.balanceOf(pairAddress);
        uint256 pairBalanceB = tokenB.balanceOf(pairAddress);
        assertEq(pairBalanceA, amountAAdded, "TokenA balance in pair should match");
        assertEq(pairBalanceB, amountBAdded, "TokenB balance in pair should match");

        // Check LP tokens for recipient
        IERC20 pairContract = IERC20(pairAddress);
        uint256 lpBalance = pairContract.balanceOf(recipient);
        assertEq(lpBalance, liquidity, "LP token balance should match liquidity");

        console.log("Added liquidity: %s TokenA, %s TokenB", amountAAdded / 10 ** 18, amountBAdded / 10 ** 18);
        console.log("Liquidity tokens received:", liquidity / 10 ** 18);
        console.log("Liquidity added successfully");
    }

    // Test removing liquidity
    function testRemoveLiquidity() public {}

    // swap exact tokens for tokens
    function testSwapExactTokensForTokens() public {}

    // swap token to exact tokens
    function testSwapTokensForExactTokens() public {}
}
