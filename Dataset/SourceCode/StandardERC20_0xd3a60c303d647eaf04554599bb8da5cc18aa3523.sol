// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
import "./Vendor.sol";

contract StandardERC20 is ERC20 {
    constructor (string memory name, string memory symbol, address to, uint256 totalSupply) public ERC20(name, symbol)  {
        _mint(to, totalSupply);
    }
}