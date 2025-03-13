// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./ERC20.sol";

contract BUICK is ERC20 {
    constructor() ERC20("BUICK", "BUICK") {
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
}