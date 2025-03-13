// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HEK is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    string private _baseTokenURI;
    address payable public beneficiary;
    event TokenMinted(address indexed owner, uint256 indexed tokenId);

    constructor(string memory baseTokenURI_) ERC721("Friends of HEK", "HEK") {
        _baseTokenURI = baseTokenURI_;
        beneficiary = payable(0x23106570beE3c2CD6C7981C102d2bb84E98e0d53);
    }

     function contractURI() public pure returns (string memory) {
        string memory json = '{"name": "Friends of HEK","description": "Friends of HEK represents the home of all yearly membership tokens which were collectively created by the Friends of HEK community.", "image": "ipfs://QmPiRQhUpR3TvyiyXL9fzLFGT4VsJy63aSbVaiu6oopcif"}';
        return string(abi.encodePacked("data:application/json;utf8,", json));
    }

    function setBaseTokenURI(string memory baseTokenURI_) public onlyOwner {
        _baseTokenURI = baseTokenURI_;
        if (_tokenIdCounter.current() > 0) {  // only emit event if any tokens have been minted
            emit BatchMetadataUpdate(1, _tokenIdCounter.current());
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    uint256 public mintPrice = 0.04 ether;

    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    function safeMint(address to) public payable {
        require(balanceOf(to) == 0 || to == beneficiary, "Address already owns a token");
        if (msg.sender != beneficiary) {
            require(msg.value >= mintPrice, "Not enough Ether provided.");
        }
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(to, newTokenId);
        // Forward the funds
        if (msg.value > 0) {
            beneficiary.transfer(msg.value);
        }
        emit TokenMinted(to, newTokenId);
    }

    // HEK's mint function to mint multiple tokens at once
    function mintMultiple(address to, uint256 numTokens) public {
        require(msg.sender == beneficiary, "Only beneficiary can mint multiple tokens.");

        for(uint256 i = 0; i < numTokens; i++) {
            _tokenIdCounter.increment();
            uint256 newTokenId = _tokenIdCounter.current();
            _mint(to, newTokenId);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}