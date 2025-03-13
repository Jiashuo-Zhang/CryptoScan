// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// ERC721A Contracts v4.2.2
// Creator: Chiru Labs
import 'erc721a/contracts/ERC721A.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract PartySheepWorld is ERC721A, Ownable, DefaultOperatorFilterer, ERC2981 {

    //マークル用
    uint256 public cost = 0.025 ether;
    uint256 public maxSupply = 1500;
    uint256 public maxMintAmountPerTransaction = 30;
    uint256 public publicSaleMaxMintAmountPerAddress = 30;

    bool public paused = true;
    bool public onlyAllowlisted = true;
    bool public mintCount = true;
    bool public burnAndMintMode = false;

    uint256 public allowlistType = 0;
    bytes32 public merkleRoot;
    uint256 public saleId = 0;
    mapping(uint256 => mapping(address => uint256)) public userMintedAmount;
    mapping(uint256 => mapping(address => uint256)) public allowlistUserAmount;

    string baseURI;
    string public baseExtension = ".json";
    bool public revealed = false;
    string public notRevealedUri;

    constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  )ERC721A(_name, _symbol) {
      setBaseURI(_initBaseURI);
      setNotRevealedURI(_initNotRevealedUri);
      _setDefaultRoyalty( owner(), 1000 );
    }

    //ERC2981
    function supportsInterface(bytes4 interfaceId) public view override(ERC721A, ERC2981) returns (bool) {
    return super.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty( address receiver, uint96 feeNumerator ) external onlyOwner { _setDefaultRoyalty( receiver, feeNumerator ); }
    function deleteDefaultRoyalty() external onlyOwner { _deleteDefaultRoyalty(); }
    function setTokenRoyalty( uint256 tokenId, address receiver, uint96 feeNumerator ) external onlyOwner { _setTokenRoyalty( tokenId, receiver, feeNumerator ); }
    function resetTokenRoyalty( uint256 tokenId ) external onlyOwner { _resetTokenRoyalty( tokenId ); }


    //mint
 
    //mint with merkle tree 
    // Copyright (c) 2022 Keisuke OHNO
    function mint(uint256 _mintAmount , uint256 _maxMintAmount , bytes32[] calldata _merkleProof , uint256 _burnId ) public payable{
        require(!paused, "the contract is paused");
        require(0 < _mintAmount, "need to mint at least 1 NFT");
        require(_mintAmount <= maxMintAmountPerTransaction, "max mint amount per session exceeded");
        require( _nextTokenId() -1 + _mintAmount <= maxSupply , "max NFT limit exceeded");
        require(cost * _mintAmount <= msg.value, "insufficient funds");

        uint256 maxMintAmountPerAddress;
        if(onlyAllowlisted == true) {
            if(allowlistType == 0){
                //Merkle tree
                bytes32 leaf = keccak256( abi.encodePacked(msg.sender, _maxMintAmount) );
                require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "user is not allowlisted");
                maxMintAmountPerAddress = _maxMintAmount;
            }else if(allowlistType == 1){
                //Mapping
                require( allowlistUserAmount[saleId][msg.sender] != 0 , "user is not allowlisted");
                maxMintAmountPerAddress = allowlistUserAmount[saleId][msg.sender];
            }
        }else{
            maxMintAmountPerAddress = publicSaleMaxMintAmountPerAddress;
        }

        if(mintCount == true){
            require(_mintAmount <= maxMintAmountPerAddress - userMintedAmount[saleId][msg.sender] , "max NFT per address exceeded");
            userMintedAmount[saleId][msg.sender] += _mintAmount;
        }

        if(burnAndMintMode == true ){
            require(_mintAmount == 1, "");
            require(msg.sender == ownerOf(_burnId) , "Owner is different");
            _burn(_burnId);
        }

        _safeMint(msg.sender, _mintAmount);
    }

    function setBurnAndMintMode(bool _burnAndMintMode) public onlyOwner {
        burnAndMintMode = _burnAndMintMode;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setPause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setAllowListType(uint256 _type)public onlyOwner{
        require( _type == 0 || _type == 1 , "Allow list type error");
        allowlistType = _type;
    }

    function setAllowlistMapping(uint256 _saleId , address[] memory addresses, uint256[] memory saleSupplies) public onlyOwner {
        require(addresses.length == saleSupplies.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            allowlistUserAmount[_saleId][addresses[i]] = saleSupplies[i];
        }
    }

    function getAllowlistUserAmount(address _address ) public view returns(uint256){
        return allowlistUserAmount[saleId][_address];
    }

    function getUserMintedAmountBySaleId(uint256 _saleId , address _address ) public view returns(uint256){
        return userMintedAmount[_saleId][_address];
    }

    function getUserMintedAmount(address _address ) public view returns(uint256){
        return userMintedAmount[saleId][_address];
    }

    function setSaleId(uint256 _saleId) public onlyOwner {
        saleId = _saleId;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner() {
        maxSupply = _maxSupply;
    }

    function setPublicSaleMaxMintAmountPerAddress(uint256 _publicSaleMaxMintAmountPerAddress) public onlyOwner() {
        publicSaleMaxMintAmountPerAddress = _publicSaleMaxMintAmountPerAddress;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setOnlyAllowlisted(bool _state) public onlyOwner {
        onlyAllowlisted = _state;
    }

    function setMaxMintAmountPerTransaction(uint256 _maxMintAmountPerTransaction) public onlyOwner {
        maxMintAmountPerTransaction = _maxMintAmountPerTransaction;
    }
  
    function setMintCount(bool _state) public onlyOwner {
        mintCount = _state;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function airdropMint(address[] calldata _airdropAddresses , uint256[] memory _UserMintAmount) public onlyOwner{
        uint256 supply = totalSupply();
        uint256 _mintAmount = 0;
        for (uint256 i = 0; i < _UserMintAmount.length; i++) {
            _mintAmount += _UserMintAmount[i];
        }
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

        for (uint256 i = 0; i < _UserMintAmount.length; i++) {
            _safeMint(_airdropAddresses[i], _UserMintAmount[i] );
        }
    }

        function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
        if(revealed == false) {
            return notRevealedUri;
        }
        return string(abi.encodePacked(ERC721A.tokenURI(tokenId), baseExtension));
    }

    //only owner  
  
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }
 
    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

     //start from tokenid　1
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }    

    //Royality
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

}