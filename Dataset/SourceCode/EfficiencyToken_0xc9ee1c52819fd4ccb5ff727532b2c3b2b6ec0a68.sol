// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/[email protected]/token/ERC20/ERC20.sol";
import "@openzeppelin/[email protected]/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/[email protected]/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/[email protected]/access/Ownable.sol";

contract EfficiencyToken is ERC20, ERC20Burnable, ERC20Permit, Ownable {
    constructor(address initialOwner)
        ERC20("Efficiency Token", "EFFY")
        ERC20Permit("Efficiency Token")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}