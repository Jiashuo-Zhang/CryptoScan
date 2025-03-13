//
//
//
/////////////////////////////////////////////////////////////////
//                                                             //
//       ██████  ███████ ███    ██ ███    ██ ██ ███████        //
//       ██   ██ ██      ████   ██ ████   ██ ██ ██             //
//       ██   ██ █████   ██ ██  ██ ██ ██  ██ ██ ███████        //
//       ██   ██ ██      ██  ██ ██ ██  ██ ██ ██      ██        //
//       ██████  ███████ ██   ████ ██   ████ ██ ███████        //
//                                                             //
// ███████  ██████ ██   ██ ███    ███ ███████ ██      ███████  //
// ██      ██      ██   ██ ████  ████ ██      ██         ███   //
// ███████ ██      ███████ ██ ████ ██ █████   ██        ███    //
//      ██ ██      ██   ██ ██  ██  ██ ██      ██       ███     //
// ███████  ██████ ██   ██ ██      ██ ███████ ███████ ███████  //
//                                                             //
/////////////////////////////////////////////////////////////////
//
//
//

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

contract AufReisenMinterBurner is Ownable {
    address public aufReisen2023 = 0xc6dca8E9c9Eb5A7eb68B04A69E63352D5d98695c;
    address public editionsByDennisSchmelz = 0x0360D20d2f170561A0C0c36F55ea4667c7aDF8ed;
    uint256 public mintTokenId = 2;

    uint256 public burnTokenAmount = 3;

    bool public isMintEnabled = true;

    constructor() {}

    function mint(uint256[] memory id, uint256[] memory amount) public {
        require(isMintEnabled, "Mint not enabled");
        require(id.length % 3 == 0, "Has to burn 3 or multiple of 3");
        require(amount.length == id.length, "amount and id length mismatch");

        ERC1155PresetMinterPauser aufReisenToken = ERC1155PresetMinterPauser(aufReisen2023);
        ERC1155PresetMinterPauser editionsByDennisSchmelzToken = ERC1155PresetMinterPauser(editionsByDennisSchmelz);
        
        require(aufReisenToken.isApprovedForAll(msg.sender, address(this)), "Not approved");
        
        for (uint256 i = 0; i < id.length; i++) {
             require(aufReisenToken.balanceOf(msg.sender, id[i]) == 1, "No tokens for given id");
        }
        
        aufReisenToken.burnBatch(msg.sender, id, amount);
        editionsByDennisSchmelzToken.mint(msg.sender, mintTokenId, id.length/3, "");
    }

    function setIsMintEnabled(bool isEnabled) public onlyOwner {
        isMintEnabled = isEnabled;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setEditionsByDennisSchmelzAddress(address newAddress) public onlyOwner {
        editionsByDennisSchmelz = newAddress;
    }

    function setAufReisen2023Address(address newAddress) public onlyOwner {
        aufReisen2023 = newAddress;
    }

    function setMintTokenId(uint256 tokenId) public onlyOwner {
        mintTokenId = tokenId;
    }

     function setBurnTokenAmount(uint256 amount) public onlyOwner {
        burnTokenAmount = amount;
    }
}