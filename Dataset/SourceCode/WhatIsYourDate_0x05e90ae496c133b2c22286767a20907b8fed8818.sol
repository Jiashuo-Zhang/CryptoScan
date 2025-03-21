// SPDX-License-Identifier: MIT
/***
 *  
 *  8""""8                      
 *  8      eeeee ee   e eeee    
 *  8eeeee 8   8 88   8 8       
 *      88 8eee8 88  e8 8eee    
 *  e   88 88  8  8  8  88      
 *  8eee88 88  8  8ee8  88ee    
 *  ""8""                       
 *    8   e   e eeee            
 *    8e  8   8 8               
 *    88  8eee8 8eee            
 *    88  88  8 88              
 *    88  88  8 88ee            
 *  8""""8                      
 *  8    8 eeeee eeeee eeee     
 *  8e   8 8   8   8   8        
 *  88   8 8eee8   8e  8eee     
 *  88   8 88  8   88  88       
 *  88eee8 88  8   88  88ee     
 *  
 */
pragma solidity >=0.8.9 <0.9.0;

import './ERC721AQueryable.sol';
import './MerkleProof.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';

contract WhatIsYourDate is ERC721AQueryable, Ownable, ReentrancyGuard {
  using Strings for uint256;

  event DatesMinted(address owner, string[] dates, uint256 currentIndex, uint256 mintAmount);
  event RandomDatesMinted(address owner, uint256 currentIndex, uint256 mintAmount);

  bytes32 public merkleRoot;
  mapping(address => bool) public freelistClaimed;
  mapping(address => bool) public freelist;
  mapping(address => IERC721) public communities;


  string public uriPrefix = '';
  string public uriSuffix = '.json';  
  uint256 public cost = 0.1 ether;
  uint256 public randomDateCost = 0.05 ether;

  uint256 public maxSupply = 18000;
  uint256 public maxMintAmountPerTx = 4;
  string  public tokenName = "SaveTheDate";
  string  public tokenSymbol = "STD";

  bool public paused = true;
  bool public whitelistMintEnabled = false;

  constructor(string memory baseURI
  ) ERC721A(tokenName, tokenSymbol) {
      setUriPrefix(baseURI);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

  modifier mintRandomDatePriceCompliance(uint256 _mintAmount) {
    require(msg.value >= randomDateCost * _mintAmount, 'Insufficient funds!');
    _;
  }

  function communityMint(uint256 _mintAmount, string[] memory _dates, address _community, uint256 _nftId) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    verifyCommunityRequirements(_community, _nftId);
    mintDates(_msgSender(), _mintAmount, _dates);
  }

 function communityRandomMint(uint256 _mintAmount, address _community, uint256 _nftId) public payable mintCompliance(_mintAmount) mintRandomDatePriceCompliance(_mintAmount) {
    verifyCommunityRequirements(_community, _nftId);
    mintRandomDates(_msgSender(), _mintAmount);
  }

  function verifyCommunityRequirements(address _community, uint256 _nftId) internal view {
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    IERC721 communityContract = communities[_community];
    address _owner = communityContract.ownerOf(_nftId);
    require(_owner == msg.sender, "Must be Owner of OG collection to mint");
  }

  function whitelistMint(uint256 _mintAmount, string[] memory _dates, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    verifyWhitelistRequirements(_merkleProof);
    mintDates(_msgSender(), _mintAmount, _dates);
  }

  function whitelistRandomMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintRandomDatePriceCompliance(_mintAmount) {
    verifyWhitelistRequirements(_merkleProof);
    mintRandomDates(_msgSender(), _mintAmount);
  }

  function verifyWhitelistRequirements(bytes32[] calldata _merkleProof) internal view {
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');
  }

   function freeMint(string memory _date) public payable {
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!freelistClaimed[_msgSender()], 'Address already claimed!');
    require(freelist[_msgSender()], 'Address is not allowed for free mint');
    string[] memory tmp = new string[](1);
    tmp[0] = _date;
    mintDates(_msgSender(), 1, tmp);
  }

  function mint(uint256 _mintAmount, string[] memory _dates) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');
    mintDates(_msgSender(), _mintAmount, _dates);
  }

  function randomDateMint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintRandomDatePriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');
    mintRandomDates(_msgSender(), _mintAmount);
  }

  function mintDates(address to, uint256 _mintAmount, string[] memory _dates) internal {
    uint256 currentIndex = _currentIndex;
    _safeMint(to, _mintAmount);
    emit DatesMinted(to, _dates, currentIndex, _mintAmount);
  }

  function mintRandomDates(address to, uint256 _mintAmount) internal {
    uint256 currentIndex = _currentIndex;
    _safeMint(to, _mintAmount);
    emit RandomDatesMinted(to, currentIndex, _mintAmount);
  }

 function internalRandomMint(uint256 _teamAmount) external onlyOwner  {
    require(totalSupply() + _teamAmount <= maxSupply, 'Max supply exceeded!');
    mintRandomDates(_msgSender(), _teamAmount);
  }

 function internalMint(uint256 _teamAmount, string[] memory _dates) external onlyOwner  {
    require(totalSupply() + _teamAmount <= maxSupply, 'Max supply exceeded!');
    mintDates(_msgSender(), _teamAmount, _dates);
  }
   
  function mintForAddress(uint256 _mintAmount, string[] memory _dates, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    mintDates(_receiver, _mintAmount, _dates);
  }

  function mintForAddresses(string[] memory _dates, address[] memory _addresses) public onlyOwner {
    string[] memory tmp = new string[](1);
    for (uint i = 0; i < _addresses.length; i++) {
        tmp[0] = _dates[i];
        mintForAddress(1, tmp, _addresses[i]);
    }
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function addCommunities(address[] memory _communities) public onlyOwner {
    for (uint i = 0; i < _communities.length; i++) {
        communities[_communities[i]] = IERC721(_communities[i]);
    }
  }

  function removeCommunities(address[] memory _communities) public onlyOwner {
    for (uint i = 0; i < _communities.length; i++) {
        delete communities[_communities[i]];
    }
  }

  function addToFreelist(address[] memory addresses) public onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        freelist[addresses[i]] = true;
    }
  }

  function removeFromFreelist(address[] memory addresses) public onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        delete freelist[addresses[i]];
    }
  }

  function setRandomDateCost(uint256 _randomDateCost) public onlyOwner {
    randomDateCost = _randomDateCost;
  }

  function setMaxSupply(uint256 _maxSupply) public onlyOwner {
    maxSupply = _maxSupply;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function withdraw() public onlyOwner nonReentrant {
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}