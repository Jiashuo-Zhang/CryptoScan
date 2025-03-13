// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//                        888
//                        888
//                        888
// 88888b.d88b.   .d88b.  888888 888d888 .d88b.
// 888 "888 "88b d8P  Y8b 888    888P"  d88""88b
// 888  888  888 88888888 888    888    888  888
// 888  888  888 Y8b.     Y88b.  888    Y88..88P
// 888  888  888  "Y8888   "Y888 888     "Y88P"

// 888                    d8b          888                          888
// 888                    Y8P          888                          888
// 888                                 888                          888
// 88888b.  888  888      888 88888b.  888888       8888b.  888d888 888888
// 888 "88b 888  888      888 888 "88b 888             "88b 888P"   888
// 888  888 888  888      888 888  888 888         .d888888 888     888
// 888 d88P Y88b 888      888 888  888 Y88b.       888  888 888     Y88b.
// 88888P"   "Y88888      888 888  888  "Y888      "Y888888 888      "Y888
//               888
//          Y8b d88P
//           "Y88P"

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProofLib} from "solmate/src/utils/MerkleProofLib.sol";
import {IMetroMinter} from "./interfaces/IMetroMinter.sol";

import {IMetro} from "./interfaces/IMetro.sol";

contract MetroMinterV3 is Ownable {
    IMetro public immutable metro;

    bool public isPublicMintOpen;
    mapping(address => bool) public addressesForPublicMint;
    bytes32 public publicMerkleProof;

    error MintNotOpen();
    error AlreadyMinted();
    error InvalidProof();
    error InvalidAmount();

    constructor(address metroAddress) {
        metro = IMetro(metroAddress);
    }

    // - owner operations

    function setIsPublicMintOpen(bool _isPublicMintOpen) public onlyOwner {
        isPublicMintOpen = _isPublicMintOpen;
    }

    function updatePublicMerkleProof(
        bytes32 _publicMerkleProof
    ) public onlyOwner {
        publicMerkleProof = _publicMerkleProof;
    }

    // - public mint

    function canMint(
        address _address,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(_address, quantity));
        if (!MerkleProofLib.verify(merkleProof, publicMerkleProof, node)) {
            return false;
        }
        if (addressesForPublicMint[_address]) {
            return false;
        }
        return true;
    }

    function publicMint(
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public {
        if (!isPublicMintOpen) {
            revert MintNotOpen();
        }
        bytes32 node = keccak256(abi.encodePacked(msg.sender, quantity));
        if (!MerkleProofLib.verify(merkleProof, publicMerkleProof, node)) {
            revert InvalidProof();
        }
        if (addressesForPublicMint[msg.sender]) {
            revert AlreadyMinted();
        }
        addressesForPublicMint[msg.sender] = true;
        metro.mint(msg.sender, quantity);
    }
}