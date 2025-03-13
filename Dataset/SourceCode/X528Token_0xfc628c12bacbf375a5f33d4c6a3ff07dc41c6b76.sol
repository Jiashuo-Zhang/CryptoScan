// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";



contract X528Token is ERC20, ERC20Permit, ERC20Votes, AccessControl {

    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");



    constructor() ERC20("X528", "X528") ERC20Permit("X528") {

        _mint(msg.sender, 1000000000 * 10 ** decimals());

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

    }



    // Only the wallet assigned with the burner role can burn tokens

    // AND the burner can only burn tokens already owned by the burner wallet

    function burn(uint256 amount) public

    {

        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");

        _burn(msg.sender, amount);

    }





    // The following functions are overrides required by Solidity.



    function _afterTokenTransfer(address from, address to, uint256 amount)

        internal

        override(ERC20, ERC20Votes)

    {

        super._afterTokenTransfer(from, to, amount);

    }



    function _mint(address to, uint256 amount)

        internal

        override(ERC20, ERC20Votes)

    {

        super._mint(to, amount);

    }



    function _burn(address account, uint256 amount)

        internal

        override(ERC20, ERC20Votes)

    {

        super._burn(account, amount);

    }

}