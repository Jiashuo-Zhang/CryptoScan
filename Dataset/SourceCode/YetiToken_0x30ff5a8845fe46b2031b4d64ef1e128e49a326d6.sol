// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/[email protected]/token/ERC20/ERC20.sol";
import "@openzeppelin/[email protected]/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/[email protected]/access/Ownable.sol";

contract YetiToken is ERC20, ERC20Permit, Ownable {
    constructor(address initialOwner)
        ERC20("YetiToken", "YETI")
        ERC20Permit("YetiToken")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 150000000000 * 10 ** decimals());
    }
}