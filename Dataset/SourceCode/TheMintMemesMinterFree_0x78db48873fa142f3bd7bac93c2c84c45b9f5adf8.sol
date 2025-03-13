//
//
//
///////////////////////////////////////////////////
//   __  __ _ _         _  _                     //
//  |  \/  (_) |_____  | || |__ _ __ _ ___ _ _   //
//  | |\/| | | / / -_) | __ / _` / _` / -_) '_|  //
//  |_|  |_|_|_\_\___| |_||_\__,_\__, \___|_|    //
//                               |___/           //
///////////////////////////////////////////////////
//
//
//

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract TheMintMemesMinterFree is Ownable {
    address public theMintMemesAddress = 0x3820e79dEb5E60F6f488fA2A62C8e190CC69BB47;

    uint256 public mintTokenId = 7;

    bool public isMintEnabled = true;

    mapping(address => uint256) public claimedNFTs;

    constructor() {}

    function freeMint() public {
        require(isMintEnabled , "Mint not enabled");
        require(claimedNFTs[msg.sender] < 1, "Wallet already claimed");

        ERC1155PresetMinterPauser token = ERC1155PresetMinterPauser(theMintMemesAddress);
        token.mint(msg.sender, mintTokenId, 1, "");

        claimedNFTs[msg.sender] = 1;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setTheMintMemesAddress(address newAddress) public onlyOwner {
        theMintMemesAddress = newAddress;
    }

    function setIsMintEnabled(bool isEnabled) public onlyOwner {
        isMintEnabled = isEnabled;
    }

    function setMintTokenId(uint256 tokenId) public onlyOwner {
        mintTokenId = tokenId;
    }

}