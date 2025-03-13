// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// ─██████──────────██████─██████████████─██████████─██████████████████────────██████████████─██████████████─██████──██████─
// ─██░░██──────────██░░██─██░░░░░░░░░░██─██░░░░░░██─██░░░░░░░░░░░░░░██────────██░░░░░░░░░░██─██░░░░░░░░░░██─██░░██──██░░██─
// ─██░░██──────────██░░██─██░░██████████─████░░████─████████████░░░░██────────██░░██████████─██████░░██████─██░░██──██░░██─
// ─██░░██──────────██░░██─██░░██───────────██░░██───────────████░░████────────██░░██─────────────██░░██─────██░░██──██░░██─
// ─██░░██──██████──██░░██─██░░██████████───██░░██─────────████░░████──────────██░░██████████─────██░░██─────██░░██████░░██─
// ─██░░██──██░░██──██░░██─██░░░░░░░░░░██───██░░██───────████░░████────────────██░░░░░░░░░░██─────██░░██─────██░░░░░░░░░░██─
// ─██░░██──██░░██──██░░██─██░░██████████───██░░██─────████░░████──────────────██░░██████████─────██░░██─────██░░██████░░██─
// ─██░░██████░░██████░░██─██░░██───────────██░░██───████░░████────────────────██░░██─────────────██░░██─────██░░██──██░░██─
// ─██░░░░░░░░░░░░░░░░░░██─██░░██████████─████░░████─██░░░░████████████─██████─██░░██████████─────██░░██─────██░░██──██░░██─
// ─██░░██████░░██████░░██─██░░░░░░░░░░██─██░░░░░░██─██░░░░░░░░░░░░░░██─██░░██─██░░░░░░░░░░██─────██░░██─────██░░██──██░░██─
// ─██████──██████──██████─██████████████─██████████─██████████████████─██████─██████████████─────██████─────██████──██████─
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "src/MintbossDrop.sol";
import "@thirdweb-dev/contracts/extension/BatchMintMetadata.sol";
import "@thirdweb-dev/contracts/lib/TWStrings.sol";

contract JudgmentDay is 
    BatchMintMetadata,
    MintbossDrop
{
    using TWStrings for uint256;

    address private splitWallet = 0xcE914c8511C632ac872691232a3183FE4A27eb07;
    address private super_admin = 0xD06D855652A73E61Bfe26A3427Dfe51f3b827fe3;

    string private newBaseUri;

    constructor() MintbossDrop("Judgment Day by Tony Parisi", "JUDG", splitWallet, 1000, splitWallet, 0 ether, 0 ether, 0) {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DEFAULT_ADMIN_ROLE, super_admin);
        grantRole(MINTER_ROLE, super_admin);
        grantRole(ADMIN_ROLE, super_admin);
    }

    function setBaseURI(string memory _baseURI) external onlyRole(ADMIN_ROLE) {
        newBaseUri = _baseURI;
    }

    /**
     *  @notice         Returns the metadata URI for an NFT.
     *  @dev            See `BatchMintMetadata` for handling of metadata in this contract.
     *
     *  @param _tokenId The tokenId of an NFT.
     */
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(newBaseUri, _tokenId.toString()));
    }
}