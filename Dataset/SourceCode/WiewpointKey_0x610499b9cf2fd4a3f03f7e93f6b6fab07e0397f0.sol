// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";


contract WiewpointKey is ERC721Royalty, Ownable {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 private _tokenIdCounter = 0;
    uint96 public constant ROYALTY = 500; // 5%
    string private BASE_URI;

    constructor(address _receiver) ERC721("WiewpointKey", "WPKEY") Ownable(msg.sender) {
        _setDefaultRoyalty(_receiver, ROYALTY);

    }

    function safeMint(address to) public onlyOwner {
        require(_tokenIdCounter < MAX_SUPPLY, "Max supply reached");
        _safeMint(to, _tokenIdCounter);
        _tokenIdCounter++;
    }

    function _baseURI() internal view override(ERC721) returns (string memory) {
        return BASE_URI;
    }

    function setBaseURI(string calldata URI) external onlyOwner {
        BASE_URI = URI;
    }
}