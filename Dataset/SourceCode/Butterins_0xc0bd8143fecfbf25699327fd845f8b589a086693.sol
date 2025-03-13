// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//
// Co-curate EthCC 
// Find more info on app.daolize.com/ethcc
// (starting from Sun 16th Jul 23)
//

contract Butterins is ERC721, Ownable {
    uint256 private _currentTokenId = 0;
    string private _inernalBaseURI;
    uint256 public maxSupply = 1000;

    constructor(string memory baseURI_) ERC721("Butterins", "BUTTERIN") {
        _inernalBaseURI = baseURI_;
    }

    function mint(address to) public {
        require(_currentTokenId < maxSupply, "Max supply reached");

        _mint(to, _currentTokenId);

        _currentTokenId++;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        _inernalBaseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _inernalBaseURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        require(to == address(0) || balanceOf(to) == 0, "Recipient already owns a token");
    }

    function numTokensMinted() external view returns(uint256) {
        return _currentTokenId;
    }
}