// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

pragma experimental ABIEncoderV2;



import './ERC721Tradable.sol';



contract VirtuaNFT is ERC721Tradable{



       constructor(address eventContract) ERC721Tradable("Founder's Key", "FOUNDERS",0xa5409ec958C83C3f309868babACA7c86DCB077c1,"https://assetsmeta.virtua.com/foundersdistrict/founderskey/keys/", 0x689cDF503Ba3566a701155466a6CED27A5A921F9, 500, eventContract) {

    }



}