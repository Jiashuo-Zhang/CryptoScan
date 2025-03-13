// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./ERC20.sol";

contract ELCAMINO is ERC20 {
    constructor() ERC20("ELCAMINO", "CMN") {
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
}