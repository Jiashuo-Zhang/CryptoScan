//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Twitter: https://twitter.com/mikedemarais
// Twitter: https://twitter.com/JctysmIjrm0iETH

// Telegram: https://t.me/+NpMW9yJ-ZrAxZWVh

// friend.tech @JctysmIjrm0iETH


/**
 * @title $JESUS
 * @notice JesusChristThankYouSoMuchIJustRecevedMine10Inu
 */
contract Jesus is Ownable, ERC20, ERC20Permit {
  address private constant MIKE = 0xE5501BC2B0Df6D0D7daAFC18D2ef127D9e612963;
  string private constant NAME = "JesusChristThankYouSoMuchIJustRecevedMine10Inu";
  string private constant SYMBOL = "JESUS";

  bool public goodDreamsSecured = false;

  // modifier for only token holder can burn
  modifier tokenOwner(address from) {
    require(_msgSender() == from, "Only token owner can burn");
          _;
  }

  constructor() ERC20(NAME, SYMBOL) ERC20Permit(NAME) {}

  function onlyGoodDreams() external onlyOwner {
    require(!goodDreamsSecured, "Good dreams already secured");
    goodDreamsSecured = true;
    _mint(MIKE, 50_000_000 ether);
    _mint(msg.sender, 950_000_000 ether);
  }

  function burn(address from, uint256 amount) external tokenOwner(from) {
    _burn(from, amount);
  }
}