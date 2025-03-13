// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/[email protected]/token/ERC20/ERC20.sol";
import "@openzeppelin/[email protected]/token/ERC20/extensions/ERC20Permit.sol";

/// @custom:security-contact [email protected]
contract Abachi is ERC20, ERC20Permit {
    constructor() ERC20("Abachi", "ABI") ERC20Permit("Abachi") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}