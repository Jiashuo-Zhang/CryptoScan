// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;



// Lambo Finance: https://lamboeth.finance/

// Twitter: https://twitter.com/lambofinanceeth

// Telegram: https://t.me/lambofinanceeth



import "solady/tokens/ERC20.sol";



contract LamboFinance is ERC20 {

    constructor() {

        _mint(msg.sender, 1_000_000_000_000 * (10 ** 18));

    }



    function name() public view virtual override returns (string memory) {

        return "lamboeth.finance";

    }



    function symbol() public view virtual override returns (string memory) {

        return "LAMBO";

    }



    function burn(uint256 amount) public {

        _burn(msg.sender, amount);

    }



    function renounceOwnership() external {}

}