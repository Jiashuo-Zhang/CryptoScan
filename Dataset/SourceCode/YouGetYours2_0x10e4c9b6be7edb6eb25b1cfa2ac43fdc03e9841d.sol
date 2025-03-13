// SPDX-License-Identifier: MIT

// Twitter: https://twitter.com/YouGetYoursETH

// Telegram: https://t.me/yougetyourseth_communityy



pragma solidity ^0.8.9;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

import "@openzeppelin/contracts/access/Ownable.sol";



/**

 * @title 🚀 You Get Yours (YGY) 2.0 🚀

 *

 * @dev 🌟 Welcome to YGY 2.0, the ultimate meme rocketship! 🌟

 *

 *                     🚀        🚀

 *                   🚀            🚀

 *       🚀     🌌               🌌    🚀

 *   🌌         🌌     YGY 2.0    🌌       🌌

 *       🌌     🌌               🌌    🌌

 *           🚀                 🚀

 *                   🚀            🚀

 *                     🚀        🚀

 *

 * 🤩 Get ready for a cosmic adventure filled with LOLs and emojis! 🚀🌌

 * 💎 YGY 2.0: The Shiny Unicorn of the Crypto-Verse! 🦄💫

 *

 * 🎉 We've souped up the fun factor and added more Twitter magic! 🎊📱

 * 🐦 Tweet, retweet, meme, and watch YGY 2.0 go viral! 🔥😂

 * 🌮 Forget tacos, it's raining YGY 2.0 tokens for your Twitter fam! 🌮💰

 * 🔥 Hold on tight as we aim for the moon and beyond! 🌕🚀

 *

 * 🌈 Unleash your inner memelord and create meme-masterpieces! 🎨😎

 * 🦜 Parrot NFTs? Doge wizards? Your imagination is the limit! 🦜🧙‍♂️

 *

 * 💚 YGY 2.0 is now eco-friendly - Proof-of-Laughter (POL) consensus! 💚🌱

 * 🌍 Laugh together, HODL together, and save the planet together! 🌍🤝

 *

 * 💥 Burn Mechanism: For every buy and sell, 0.10% of tokens will be burned! 💥🔥

 * 💥 Deflationary Magic: Randomly trigger a cosmic deflation! Watch those tokens vanish into the stars! ✨🌠

 *

 * So grab your memes, buckle up, and let's paint the crypto-verse with laughter! 🖌️🌟

 *

 * 🎁 Upgraded Tokenomics: 

 * 🔹 Name: You Get Yours 2.0

 * 🔹 Symbol: YGY2

 * 🔹 Decimals: 18

 * 🔹 Initial Supply: 6,900,000,000 YGY2 (A universe of laughter awaits!)

 *

 * Connect with us on Twitter: https://twitter.com/YouGetYoursETH

 * 🌐 Website: (Coming soon, but the memes are already live! 😂)

 * 📢 Telegram: https://t.me/yougetyourseth_communityy

 */

contract YouGetYours2 is ERC20, ERC20Burnable, ERC20Permit, Ownable {

    uint256 private constant BURN_RATE = 10; // 0.10% burn rate on each buy and sell



    constructor() ERC20("You Get Yours 2.0", "YGY2") ERC20Permit("You Get Yours 2.0") {

        uint256 initialSupply = 6900000000 * 10**decimals();

        _mint(msg.sender, initialSupply);

    }



    // Override the transfer function to implement burn mechanism on buy and sell

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {

        if (recipient == address(0) || sender == address(0)) {

            // Burning tokens during mint and burn operations

            super._burn(sender, amount);

        } else {

            uint256 burnAmount = amount * BURN_RATE / 10000;

            uint256 transferAmount = amount - burnAmount;

            super._burn(sender, burnAmount);

            super._transfer(sender, recipient, transferAmount);

        }



        // Randomly trigger cosmic deflation - 1% chance on each transaction

        if (random() % 100 == 0) {

            uint256 cosmicDeflation = balanceOf(address(this)) / 10;

            if (cosmicDeflation > 0) {

                super._burn(address(this), cosmicDeflation);

            }

        }

    }



    // Simple random function for cosmic deflation trigger

    function random() private view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.number)));

    }

}