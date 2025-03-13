// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./ERC20.sol";

contract ESCALADE is ERC20 {
    constructor() ERC20("ESCALADE", "ESC") {
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
}