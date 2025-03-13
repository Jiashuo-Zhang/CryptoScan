// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../IKiyoshisSeedsProject.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract KiyoshisEvolution is AccessControl, Ownable, Pausable {
    using Strings for address;

    bytes32 public constant ADMIN = "ADMIN";

    IKiyoshisSeedsProject public kiyoshi;
    mapping(string => uint256) public evolutionTarget;
    uint256 public maxPerTribe = 5;
    uint256 public minBornTribe = 1;
    uint256 public maxBornTribe = 6;

    struct Token {
        address collectionAddress;
        uint256 tokenId;
    }

    constructor() {
        _grantRole(ADMIN, msg.sender);
    }

    // ==================================================================
    // For seeds
    // ==================================================================
    modifier enoughAmount(uint256 amount) {
        require(
            IERC1155(address(kiyoshi)).balanceOf(msg.sender, 100_000) >= amount,
            "not enough seeds."
        );
        _;
    }

    function born(uint256 pairCount)
        external
        enoughAmount(pairCount * 2)
        whenNotPaused
    {
        kiyoshi.burn(msg.sender, 100_000, pairCount * 2);
        for (uint256 i = 0; i < pairCount; i++) {
            uint256 tribe = _decideBornTribe(i);
            uint256 tokenId = tribe * 10 + _decideCharacter(tribe, i);
            kiyoshi.mint(msg.sender, tokenId, 1);
        }
    }

    function _decideCharacter(uint256 tribe, uint256 i) private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(blockhash(block.number - 1), tribe, i))
            ) % maxPerTribe;
    }

    function _decideBornTribe(uint256 seed) private view returns (uint256) {
        return
            (uint256(
                keccak256(abi.encodePacked(blockhash(block.number - 1), seed))
            ) % (maxBornTribe - minBornTribe + 1)) + minBornTribe;
    }

    function setMinBornTribe(uint256 value) external onlyRole(ADMIN) {
        minBornTribe = value;
    }

    function setMaxBornTribe(uint256 value) external onlyRole(ADMIN) {
        maxBornTribe = value;
    }

    // ==================================================================
    // For kiyoshi
    // ==================================================================
    modifier isHolder(Token[] calldata tokens) {
        for (uint256 i = 0; i < tokens.length; i++) {
            require(
                IERC1155(tokens[i].collectionAddress).balanceOf(
                    msg.sender,
                    tokens[i].tokenId
                ) >= 1,
                "not owner."
            );
        }
        _;
    }

    function evolve(Token[] calldata tokens)
        external
        isHolder(tokens)
        whenNotPaused
    {
        uint256 targetTokenId = evolutionTarget[_createKey(tokens)];
        require(targetTokenId != 0, "invalid combination.");

        for (uint256 i = 0; i < tokens.length; i++) {
            IKiyoshisSeedsProject(tokens[i].collectionAddress).burn(
                msg.sender,
                tokens[i].tokenId,
                1
            );
        }
        kiyoshi.mint(msg.sender, targetTokenId, 1);
    }

    function canEvolve(Token[] calldata tokens) external view returns (bool) {
        uint256 tribe = evolutionTarget[_createKey(tokens)];
        return tribe != 0;
    }

    function _createKey(Token[] calldata tokens)
        private
        pure
        returns (string memory)
    {
        string memory key = "";

        for (uint256 i = 0; i < tokens.length; i++) {
            if (i == 0) {
                key = string(
                    abi.encodePacked(
                        tokens[i].collectionAddress.toHexString(),
                        "-",
                        tokens[i].tokenId
                    )
                );
            } else {
                key = string(
                    abi.encodePacked(
                        key,
                        "-",
                        tokens[i].collectionAddress.toHexString(),
                        "-",
                        tokens[i].tokenId
                    )
                );
            }
        }

        return key;
    }

    function setEvolveTarget(Token[] calldata tokens, uint256 targetTokenId)
        external
        onlyRole(ADMIN)
    {
        evolutionTarget[_createKey(tokens)] = targetTokenId;
    }

    function deleteEvolveTarget(Token[] calldata tokens)
        external
        onlyRole(ADMIN)
    {
        delete evolutionTarget[_createKey(tokens)];
    }

    function setMaxPerTribe(uint256 value) external onlyRole(ADMIN) {
        maxPerTribe = value;
    }

    function setKiyoshi(address value) external onlyRole(ADMIN) {
        kiyoshi = IKiyoshisSeedsProject(value);
    }

    // ==================================================================
    // For pause
    // ==================================================================
    function pause() external onlyRole(ADMIN) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN) {
        _unpause();
    }

    // ==================================================================
    // override AccessControl
    // ==================================================================
    function grantRole(bytes32 role, address account)
        public
        override
        onlyOwner
    {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account)
        public
        override
        onlyOwner
    {
        _revokeRole(role, account);
    }
}