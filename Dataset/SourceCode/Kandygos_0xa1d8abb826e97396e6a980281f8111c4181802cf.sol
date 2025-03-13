// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract Kandygos is Ownable, ERC721A, DefaultOperatorFilterer {

    uint256 public constant MAX_SUPPLY = 5555;
    uint256 public max_wl_supply = 155;
    uint256 public free_per_wallet = 1;
    uint256 public max_per_wallet = 5;
    uint256 public price = 0.0035 ether;

    string private baseUri;
    bytes32 public merkleRoot = 0xffee316e4fb585f13d941f103ac045e1569aafe70a82983fd7983ef86e981e25; 

    bool public mintActive = false;

    constructor(string memory _baseUri) ERC721A("Kandygos", "KNDGS") {
        baseUri = _baseUri;
    }

    function publicMint(uint256 quantity) external payable {
        require(mintActive,"Sale hasn't started yet");
        require(balanceOf(msg.sender) + quantity <= max_per_wallet, "Max per wallet");
        require(_totalMinted() + quantity <= MAX_SUPPLY - max_wl_supply, "SOLD OUT");
        require(msg.sender == tx.origin,"Contracts not allowed");
        
        uint _quantity = quantity;
        uint64 freeMinted = _getAux(msg.sender);

        if (freeMinted < 1) {
            _quantity = quantity - 1;
            _setAux(msg.sender, 1);
        }

        if (_quantity > 0) {
            require(price * _quantity <= msg.value,"Insufficient funds sent");
        }
        
        _mint(msg.sender, quantity);
    }

    function WLMint(uint256 quantity,bytes32[] calldata _merkleProof) external payable {
        require(mintActive, "Sale has not started yet");
        require(balanceOf(msg.sender) + quantity <= max_per_wallet, "Max per wallet");
        require(MerkleProof.verify(_merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))),"Not on WL");
        require(_totalMinted() + quantity <= max_wl_supply, "SOLD OUT");
        
        uint _quantity = quantity;
        uint64 freeMinted = _getAux(msg.sender);

        if (freeMinted < 1) {
            _quantity = quantity - 1;
            _setAux(msg.sender, 1);
        }

        if (_quantity > 0) {
            require(price * _quantity <= msg.value,"Insufficient funds sent");
        }
        
        _mint(msg.sender, quantity);
    }
    
    function airdrop(uint256 quantity, address[] memory adresses) external payable onlyOwner {
        require(totalSupply() + quantity * adresses.length <= MAX_SUPPLY,"SOLD OUT");
        for (uint32 i = 0; i < adresses.length;){
            _mint(adresses[i], quantity);
            unchecked {i++;}
        }
    }
    
    function setFreePerWallet(uint _free_per_wallet) external onlyOwner {
        free_per_wallet = _free_per_wallet;
    }

    function setMaxWlSupply(uint _max_wl_supply) external onlyOwner {
        max_wl_supply = _max_wl_supply;
    }

    function setMaxPerWallet(uint _max_per_wallet) external onlyOwner {
        max_per_wallet = _max_per_wallet;
    }

    function setPrice(uint _price) external onlyOwner {
        price = _price;
    }

    function changeBaseUri(string memory newURI) external onlyOwner {
        baseUri = newURI;
    }

    function setSale(bool state) external onlyOwner {
        mintActive = state;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdrawAll() external onlyOwner {
        (bool os, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(os);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(
        address operator,
        uint256 tokenId
    ) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
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
}