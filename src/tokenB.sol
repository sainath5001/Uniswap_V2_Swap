// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor() ERC20("TokenB", "TKNB") {
        _mint(msg.sender, 500000 * 10 ** decimals()); // Mint 500,000 tokens to the deployer
    }
}
