// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./ERC20.sol";

contract LiLSquidwardPants is ERC20 {
    constructor() ERC20("LiLSquidwardPants", "LSP") {
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
}