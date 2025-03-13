// SPDX-License-Identifier: MIT

/*

________/\\\\\\\\\_______/\\\\\_______/\\\___________________/\\\\\_________/\\\\\\\\\_________/\\\\\\\\\\\___        
 _____/\\\////////______/\\\///\\\____\/\\\_________________/\\\///\\\_____/\\\///////\\\_____/\\\/////////\\\_       
  ___/\\\/_____________/\\\/__\///\\\__\/\\\_______________/\\\/__\///\\\__\/\\\_____\/\\\____\//\\\______\///__      
   __/\\\______________/\\\______\//\\\_\/\\\______________/\\\______\//\\\_\/\\\\\\\\\\\/______\////\\\_________     
    _\/\\\_____________\/\\\_______\/\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\//////\\\_________\////\\\______    
     _\//\\\____________\//\\\______/\\\__\/\\\_____________\//\\\______/\\\__\/\\\____\//\\\___________\////\\\___   
      __\///\\\___________\///\\\__/\\\____\/\\\______________\///\\\__/\\\____\/\\\_____\//\\\___/\\\______\//\\\__  
       ____\////\\\\\\\\\____\///\\\\\/_____\/\\\\\\\\\\\\\\\____\///\\\\\/_____\/\\\______\//\\\_\///\\\\\\\\\\\/___ 
        _______\/////////_______\/////_______\///////////////_______\/////_______\///________\///____\///////////_____
____/\\\\\\\\\______/\\\\\\\\\\\\\\\__/\\\\\\\\\\\\\_________/\\\\\_________/\\\\\\\\\______/\\\\\_____/\\\_          
 __/\\\///////\\\___\/\\\///////////__\/\\\/////////\\\_____/\\\///\\\_____/\\\///////\\\___\/\\\\\\___\/\\\_         
  _\/\\\_____\/\\\___\/\\\_____________\/\\\_______\/\\\___/\\\/__\///\\\__\/\\\_____\/\\\___\/\\\/\\\__\/\\\_        
   _\/\\\\\\\\\\\/____\/\\\\\\\\\\\_____\/\\\\\\\\\\\\\\___/\\\______\//\\\_\/\\\\\\\\\\\/____\/\\\//\\\_\/\\\_       
    _\/\\\//////\\\____\/\\\///////______\/\\\/////////\\\_\/\\\_______\/\\\_\/\\\//////\\\____\/\\\\//\\\\/\\\_      
     _\/\\\____\//\\\___\/\\\_____________\/\\\_______\/\\\_\//\\\______/\\\__\/\\\____\//\\\___\/\\\_\//\\\/\\\_     
      _\/\\\_____\//\\\__\/\\\_____________\/\\\_______\/\\\__\///\\\__/\\\____\/\\\_____\//\\\__\/\\\__\//\\\\\\_    
       _\/\\\______\//\\\_\/\\\\\\\\\\\\\\\_\/\\\\\\\\\\\\\/_____\///\\\\\/_____\/\\\______\//\\\_\/\\\___\//\\\\\_   
        _\///________\///__\///////////////__\/////////////_________\/////_______\///________\///__\///_____\/////__  

*/

pragma solidity ^0.8.0;

import "ERC721A.sol";
import "DefaultOperatorFilterer.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";
import "Strings.sol";

contract COLORSREBORN is
    Ownable,
    ERC721A,
    ReentrancyGuard,
    DefaultOperatorFilterer
{
    uint256 public price = 0.11 * 10 ** 18;
    uint256 public maxSupply = 2200;
    uint256 public maxMintPerTx = 10;
    bytes32 public whitelistMerkleRoot =
        0xc6a0851cad10c3eeb1e61812e98dc67ffaa11b42d955c5a89855092def99fabc;
    bool public publicPaused = true;
    bool public revealed = false;
    string public baseURI;
    string public hiddenMetadataUri =
        "ipfs://QmUhEn1D1fc2MKzhT4DqcqoKWAWsAZRHzSBvmWm96zcNpJ";

    constructor() ERC721A("COLORS REBORN", "COLOR") {}

    function mint(uint256 amount) external payable {
        uint256 ts = totalSupply();
        require(publicPaused == false, "Mint not open for public");
        require(ts + amount <= maxSupply, "Purchase would exceed max tokens");
        require(
            amount <= maxMintPerTx,
            "Amount should not exceed max mint number"
        );

        require(msg.value >= price * amount, "Please send the exact amount.");

        _safeMint(msg.sender, amount);
    }

    function openPublicMint(bool paused) external onlyOwner {
        publicPaused = paused;
    }

    function setWhitelistMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        whitelistMerkleRoot = _merkleRoot;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function whitelistStop(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxPerTx(uint256 _maxMintPerTx) external onlyOwner {
        maxMintPerTx = _maxMintPerTx;
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setApprovalForAlll(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function whitelistMint(
        uint256 amount,
        bytes32[] calldata _merkleProof
    ) public payable {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        uint256 ts = totalSupply();
        require(ts + amount <= maxSupply, "Purchase would exceed max tokens");

        require(
            MerkleProof.verify(_merkleProof, whitelistMerkleRoot, leaf),
            "Invalid proof!"
        );

        {
            _safeMint(msg.sender, amount);
        }
    }

    function setHiddenMetadataUri(
        string memory _hiddenMetadataUri
    ) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(currentBaseURI, Strings.toString(_tokenId))
                )
                : "";
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // OVERRIDDEN PUBLIC WRITE CONTRACT FUNCTIONS: OpenSea's Royalty Filterer Implementation. //

    function approve(
        address operator,
        uint256 tokenId
    ) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }
}