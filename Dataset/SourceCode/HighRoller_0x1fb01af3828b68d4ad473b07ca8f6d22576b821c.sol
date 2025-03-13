// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "../lib/ERC721/ERC721Preset.sol";

/**
 * @title TG.Casino High Roller
 * @dev ERC721 contract for https://tg.casino
 * @custom:version v1.0
 * @custom:date 5 January 2024
 */
contract HighRoller is ERC721Preset {
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");

    constructor() ERC721Preset("TG.Casino High Roller", "TGHR") {
        _grantRole(MINT_ROLE, msg.sender);
    }

    function safeMint(address to) external onlyRole(MINT_ROLE) returns (uint256 tokenId) {
        tokenId = _safeMint(to);
        return tokenId;
    }
}