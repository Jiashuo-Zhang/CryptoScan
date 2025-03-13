// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './RakkuNFT.sol';

contract Minter is Ownable {
  RakkuNFT private token;
  address private contractAddress;
  mapping(uint256 => uint256) public tokenMaxSupply;
  mapping(uint256 => bytes32) public merkleRoot;
  mapping(address => bool) public mintedAddess;

  uint256 public MAX_PER_BATCH = 1;
  uint256 public MAX_PER_WALLET = 1;

  constructor() {}

  receive() external payable {}

  fallback() external payable {}

  function validateWhitelist(bytes32[] calldata merkleProof, uint256 tokenId, address sender) private view returns (bool) {
    bytes32 leaf = keccak256(abi.encodePacked(sender));
    return MerkleProof.verify(merkleProof, merkleRoot[tokenId], leaf);
  }

  /**
  ***************************
  Public
  ***************************
   */

  function mint(
    address to,
    bytes32[] calldata merkleProof,
    uint256 tokenId,
    uint256 amount
  ) public {
    // require whitelisted for genesis token
    uint256 maxSully = tokenMaxSupply[tokenId];
    require(maxSully != 0, 'Invalid token id');
    require(mintedAddess[to] != true, 'Max per wallet reached');
    require(amount <= MAX_PER_BATCH, "Max per batch reached");
    require(
      token.totalSupply(tokenId) + amount <= tokenMaxSupply[tokenId],
      'Max supply reached'
    );
    uint256 balance = token.balanceOf(to, tokenId);
    require(balance + amount <= MAX_PER_WALLET, "Max per wallet reached");
    // validate whitelisted
    require(validateWhitelist(merkleProof, tokenId, to), 'Bad credential');
    
    if (amount == 1) {
      token.mint(to, tokenId, 1, '');
      mintedAddess[to] = true;
    }

    if (amount > 1) {
      uint256[] memory tokenIds = new uint256[](1);
      tokenIds[0] = tokenId;
      uint256[] memory amounts = new uint256[](1);
      amounts[0] = amount;
      token.mintBatch(to, tokenIds, amounts, '');
      mintedAddess[to] = true;
    }
  }

  /**
  ***************************
  Customization for the contract
  ***************************
   */

  function setContractAddress(address payable _address) external onlyOwner {
    contractAddress = _address;
    token = RakkuNFT(_address);
  }

  function setMerkleRoot(uint256 id, bytes32 _merkleRoot) public onlyOwner {
    merkleRoot[id] = _merkleRoot;
  }

  function setTokenMaxSupply(uint256[] calldata _tokenMaxSupplies) public onlyOwner {
    for(uint256 i = 0; i < _tokenMaxSupplies.length; i ++)
    {
      tokenMaxSupply[i] = _tokenMaxSupplies[i];
    }
  }

  function setMaxPerBatch(uint256 _maxPerBatch) public onlyOwner {
    MAX_PER_BATCH = _maxPerBatch;
  }

  function setMaxPerWallet(uint256 _maxPerWallet) public onlyOwner {
    MAX_PER_WALLET = _maxPerWallet;
  }
}