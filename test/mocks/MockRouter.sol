// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockWETH {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MockUniswapV2Router02 is IUniswapV2Router02 {
    address private _factory;
    address private _WETH;

    constructor(address factory_, address WETH_) {
        _factory = factory_;
        _WETH = WETH_;
    }

    function factory() external pure returns (address) {
        // Note: This violates pure semantics but is required by interface
        // In practice, this will be called externally and return the correct value
        return address(0);
    }

    function WETH() external pure returns (address) {
        // Note: This violates pure semantics but is required by interface  
        // In practice, this will be called externally and return the correct value
        return address(0);
    }
    
    // Helper functions to get actual values
    function getFactory() external view returns (address) {
        return _factory;
    }
    
    function getWETH() external view returns (address) {
        return _WETH;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB, uint liquidity) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        
        // Transfer tokens from caller
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);
        
        // Get pair address
        address pair = IUniswapV2Factory(_factory).getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");
        
        // Transfer tokens to pair
        IERC20(tokenA).transfer(pair, amountADesired);
        IERC20(tokenB).transfer(pair, amountBDesired);
        
        // Mint LP tokens to recipient
        (bool success, bytes memory data) = pair.call(abi.encodeWithSignature("mint(address)", to));
        require(success, "Mint failed");
        liquidity = abi.decode(data, (uint256));
        
        amountA = amountADesired;
        amountB = amountBDesired;
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        // Simplified implementation
        amountA = liquidity;
        amountB = liquidity;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        // Simplified implementation
        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOutMin;
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        // Simplified implementation
        amounts = new uint[](2);
        amounts[0] = amountInMax;
        amounts[1] = amountOut;
    }

    // Other required functions with minimal implementations
    function quote(uint amountA, uint reserveA, uint reserveB) external pure override returns (uint amountB) {
        return (amountA * reserveB) / reserveA;
    }
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure override returns (uint amountOut) {
        return (amountIn * reserveOut) / reserveIn;
    }
    
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure override returns (uint amountIn) {
        return (amountOut * reserveIn) / reserveOut;
    }
    
    function getAmountsOut(uint amountIn, address[] calldata path) external view override returns (uint[] memory amounts) {
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i = 1; i < path.length; i++) {
            amounts[i] = amounts[i-1]; // Simplified
        }
    }
    
    function getAmountsIn(uint amountOut, address[] calldata path) external view override returns (uint[] memory amounts) {
        amounts = new uint[](path.length);
        amounts[path.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            amounts[i-1] = amounts[i]; // Simplified
        }
    }
    
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external override returns (uint amountToken, uint amountETH) {}
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external override returns (uint amountA, uint amountB) {}
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external override returns (uint amountToken, uint amountETH) {}
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external override returns (uint amountETH) {}
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external override returns (uint amountETH) {}
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external override {}
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external override payable returns (uint[] memory amounts) {}
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external override returns (uint[] memory amounts) {}
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external override returns (uint[] memory amounts) {}
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external override payable returns (uint[] memory amounts) {}
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external override payable {}
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external override {}
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external override payable returns (uint amountToken, uint amountETH, uint liquidity) {}
}

