// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract MockUniswapV2Pair {
    address public token0;
    address public token1;
    address public factory;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN");
        require(token0 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to) external returns (uint256 liquidity) {
        // Simplified mint function - mint liquidity equal to the token balance
        // In a real implementation, this would calculate based on reserves
        liquidity = balanceOf[to] == 0 ? 1000 * 10**18 : balanceOf[to]; // Minimum liquidity
        balanceOf[to] += liquidity;
        totalSupply += liquidity;
        return liquidity;
    }
}

contract MockUniswapV2Factory is IUniswapV2Factory {
    mapping(address => mapping(address => address)) public override getPair;
    address[] public allPairs;
    address public feeTo;
    address public override feeToSetter;

    constructor() {
        feeToSetter = msg.sender;
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, "FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, "FORBIDDEN");
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "UniswapV2: PAIR_EXISTS");
        
        bytes memory bytecode = type(MockUniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}

