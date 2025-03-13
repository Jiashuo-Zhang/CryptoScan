//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/common/ERC2981.sol";

// import "erc721psi/contracts/ERC721Psi.sol"; // token IDが0開始の場合

import "./ERC721Psi.sol"; // token IDが1開始の場合

import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

// import "./operator-filter-registry/src/DefaultOperatorFilterer.sol";



contract TOYBOY is

    ERC721Psi,

    ERC2981,

    Ownable,

    ReentrancyGuard,

    DefaultOperatorFilterer

{

    using Strings for uint256;



    uint256 public constant PRE_PRICE = 0.01 ether;

    uint256 public constant PUB_PRICE = 0.01 ether;



    uint256 public max_supply = 500;



    bool public preSaleStart;

    bool public pubSaleStart;



    uint256 public mintLimit = 2;



    bytes32 public merkleRoot;



    bool private _revealed = true;

    string private _baseTokenURI;

    string private _unrevealedURI = "https://example.com";



    mapping(address => uint256) public claimed;



    constructor() ERC721Psi("Name", "symbol") {

        _setDefaultRoyalty(owner(), 1000);

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return _baseTokenURI;

    }



    function tokenURI(uint256 _tokenId)

        public

        view

        virtual

        override(ERC721Psi)

        returns (string memory)

    {

        if (_revealed) {

            return

                string(abi.encodePacked(ERC721Psi.tokenURI(_tokenId), ".json"));

        } else {

            return _unrevealedURI;

        }

    }



    function pubMint(uint256 _quantity) public payable nonReentrant {

        uint256 supply = totalSupply();

        uint256 cost = PUB_PRICE * _quantity;

        require(pubSaleStart, "Before sale begin.");

        _mintCheckForPubSale(_quantity, supply, cost);



        claimed[msg.sender] += _quantity;

        _safeMint(msg.sender, _quantity);

    }



    function checkMerkleProof(bytes32[] calldata _merkleProof)

        public

        view

        returns (bool)

    {

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        return MerkleProof.verifyCalldata(_merkleProof, merkleRoot, leaf);

    }



    function preMint(uint256 _quantity, bytes32[] calldata _merkleProof)

        public

        payable

        nonReentrant

    {

        uint256 supply = totalSupply();

        uint256 cost = PRE_PRICE * _quantity;

        require(preSaleStart, "Before sale begin.");

        _mintCheck(_quantity, supply, cost);



        require(checkMerkleProof(_merkleProof), "Invalid Merkle Proof");



        claimed[msg.sender] += _quantity;

        _safeMint(msg.sender, _quantity);

    }



    function _mintCheck(

        uint256 _quantity,

        uint256 _supply,

        uint256 _cost

    ) private view {

        require(_supply + _quantity <= max_supply, "Max supply over");

        require(_quantity <= mintLimit, "Mint quantity over");

        require(msg.value >= _cost, "Not enough funds");

        require(

            claimed[msg.sender] + _quantity <= mintLimit,

            "Already claimed max"

        );

    }



    function _mintCheckForPubSale(

        uint256 _quantity,

        uint256 _supply,

        uint256 _cost

    ) private view {

        require(_supply + _quantity <= max_supply, "Max supply over");

        require(msg.value >= _cost, "Not enough funds");

    }



    function ownerMint(address _address, uint256 _quantity) public onlyOwner {

        uint256 supply = totalSupply();

        require(supply + _quantity <= max_supply, "Max supply over");

        _safeMint(_address, _quantity);

    }



    // only owner

    function setUnrevealedURI(string calldata _uri) public onlyOwner {

        _unrevealedURI = _uri;

    }



    function setBaseURI(string calldata _uri) external onlyOwner {

        _baseTokenURI = _uri;

    }



    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {

        merkleRoot = _merkleRoot;

    }



    function setPresale(bool _state) public onlyOwner {

        preSaleStart = _state;

    }



    function setPubsale(bool _state) public onlyOwner {

        pubSaleStart = _state;

    }



    function setMintLimit(uint256 _quantity) public onlyOwner {

        mintLimit = _quantity;

    }



    function reveal(bool _state) public onlyOwner {

        _revealed = _state;

    }



    function withdrawRevenueShare() external onlyOwner {

        uint256 sendAmount = address(this).balance;

        address artist   = payable(0x4A85C42Fe1C82dA31C56E1157cc418Bc7d0498Fb); 

        address creator   = payable(0x135C84f1589b260440D4404f405Ee6bB294bA5DC); 

        address platformer = payable(0x48A23fb6f56F9c14D29FA47A4f45b3a03167dDAe); 

        address engineer   = payable(0x7A3df47Cb07Cb1b35A6d706Fd639bfbD46e907Ac); 

        bool success;

        

        (success, ) = artist.call{value: (sendAmount * 400/1000)}("");

        require(success, "Failed to withdraw Ether");

        (success, ) = creator.call{value: (sendAmount * 320/1000)}("");

        require(success, "Failed to withdraw Ether");

        (success, ) = platformer.call{value: (sendAmount * 150/1000)}("");

        require(success, "Failed to withdraw Ether");

        (success, ) = engineer.call{value: (sendAmount * 130/1000)}("");

        require(success, "Failed to withdraw Ether");

    }



    // OperatorFilterer

    function setOperatorFilteringEnabled(bool _state) external onlyOwner {

        operatorFilteringEnabled = _state;

    }



    function setApprovalForAll(address operator, bool approved)

        public

        override

        onlyAllowedOperatorApproval(operator)

    {

        super.setApprovalForAll(operator, approved);

    }



    function approve(address operator, uint256 tokenId)

        public

        override

        onlyAllowedOperatorApproval(operator)

    {

        super.approve(operator, tokenId);

    }



    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    // Royality

    function setRoyalty(address _royaltyAddress, uint96 _feeNumerator)

        external

        onlyOwner

    {

        _setDefaultRoyalty(_royaltyAddress, _feeNumerator);

    }



    function supportsInterface(bytes4 _interfaceId)

        public

        view

        virtual

        override(ERC721Psi, ERC2981)

        returns (bool)

    {

        return

            ERC721Psi.supportsInterface(_interfaceId) ||

            ERC2981.supportsInterface(_interfaceId);

    }



    // set max supply

    function setMaxSupply(uint256 _num) external onlyOwner {

        require(max_supply <= 1000, "Max supply need to be until 1000");

        max_supply = _num;

    }

}