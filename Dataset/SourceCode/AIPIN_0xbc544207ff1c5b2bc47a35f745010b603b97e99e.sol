// SPDX-License-Identifier: MIT
/**
 *             _____ 
 *      /\    |_   _|
 *     /  \     | |  
 *    / /\ \    | |  
 *   / ____\ \ _| |_ 
 *  |_/     \_\__ __|
 *                   
 *                                    
 * 
 * AI PIN : Your Gateway to Endless Creativity and Simplified Solutions in Generative AI
 *
 * Homepage: https://ai-pin.io 
 * Twitter: https://twitter.com/aipin_io
 * Telegram: https://t.me/aipinio 
 * 
 * Total Supply: 100 Million Tokens
*/
/**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script file_path
   */
pragma solidity ^0.8.23;

import "@openzeppelin/[email protected]/token/ERC20/ERC20.sol";
import "@openzeppelin/[email protected]/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/[email protected]/token/ERC20/extensions/ERC20FlashMint.sol";
import "@openzeppelin/[email protected]/access/Ownable.sol";

/// @custom:security-contact [email protected]
contract AIPIN is ERC20, ERC20Permit, ERC20FlashMint, Ownable {
    constructor(address initialOwner)
        ERC20("AI PIN", "AI")
        ERC20Permit("AI PIN")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }
}