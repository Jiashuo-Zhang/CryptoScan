/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "solmate/src/tokens/ERC20.sol";

contract MUNCH is ERC20 {

    constructor() ERC20("MUNCH", "MUNCH", 18){
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }

}