pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";

abstract contract FLS {
  function ownerOf(uint256 tokenId) public virtual view returns (address);
  function tokenOfOwnerByIndex(address owner, uint256 index) public virtual view returns (uint256);
  function balanceOf(address owner) external virtual view returns (uint256 balance);
}

abstract contract CATS {
  function ownerOf(uint256 tokenId) public virtual view returns (address);
  function tokenOfOwnerByIndex(address owner, uint256 index) public virtual view returns (uint256);
  function balanceOf(address owner) external virtual view returns (uint256 balance);
}

contract DistopiansManga is ERC721Enumerable, Ownable {

  FLS private fls;
  CATS private cats;
  uint256 public saleIsActive;
  uint256 public preSaleIsActive;
  uint256 public maxCopies;
  uint256 public totalCopies;
  string private baseURI;
  uint256 public reservedCounter;
  uint256 public maxReserved;
  uint256 public price;
  uint256 public preSaleCounter;
  uint256 public prePreSaleCounter;
  uint256 public totalCounter;
  address public flsAddress;
  address public catsAddress;

  constructor() ERC721("Distopians Manga", "DMANGA") { 
    maxCopies = 20;
    totalCopies = 3500;
    saleIsActive = 0;
    preSaleIsActive = 0;
    reservedCounter = 0;
    maxReserved = 50;
    totalCounter = 0;
    price = 35000000000000000;
    baseURI = "";
    flsAddress = 0xf11B3a52e636dD04aa740cC97C5813CAAb0b75d0;
    catsAddress = 0x568a1f8554Edcea5CB5F94E463ac69A9C49c0A2d;
    fls = FLS(flsAddress);
    cats = CATS(catsAddress);
  }

  function isMinted(uint256 tokenId) external view returns (bool) {
    require(tokenId <= totalCopies, "tokenId outside collection bounds");

    return _exists(tokenId);
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  function setBaseURI(string memory uri) public onlyOwner {
    baseURI = uri;
  }

  function mintReservedCopy(uint256 numberOfTokens) public onlyOwner {
    require(numberOfTokens <= maxReserved, "Can only mint 50 copies at a time");
    require((reservedCounter + numberOfTokens) <= maxReserved, "Purchase would exceed max supply of Reserved copies");

    for(uint i = 0; i < numberOfTokens; i++) {
      _safeMint(msg.sender, (reservedCounter+1));
      
      reservedCounter = reservedCounter + 1;
      totalCounter = totalCounter + 1;
    }
  }

  function mintCopy(uint256 numberOfTokens) public payable {
    require(numberOfTokens <= maxCopies, "Can only mint 20 copies at a time");
    require(saleIsActive == 1, "Sale must be active to mint a copies");
    require((totalCounter + numberOfTokens) <= totalCopies, "Purchase would exceed max supply of copies");
    require((price * numberOfTokens) <= msg.value, "Too little ETH send");

    for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, (i+100)))) % (totalCopies- maxReserved);
            mintIndex = mintIndex + maxReserved + 1;
            if (totalCounter < totalCopies) {
                while(_exists((mintIndex))) {
                    mintIndex = mintIndex + 1;
                    if (mintIndex > (totalCopies)) {
                      mintIndex = maxReserved + 1;
                    }
                }
                _safeMint(msg.sender, mintIndex);
                totalCounter = totalCounter + 1;
            }
        }
  }

    function mintFreeCopy(uint256 numberOfTokens) public payable {
    require(numberOfTokens <= maxCopies, "Can only mint 20 copies at a time");
    require(preSaleIsActive == 1, "Sale must be active to mint a copies");
    require((totalCounter + numberOfTokens) <= totalCopies, "Purchase would exceed max supply of copies");

    for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, (i+100)))) % (totalCopies- maxReserved);
            mintIndex = mintIndex + maxReserved + 1;
            if (totalCounter < totalCopies) {
                while(_exists((mintIndex))) {
                    mintIndex = mintIndex + 1;
                    if (mintIndex > (totalCopies)) {
                      mintIndex = maxReserved + 1;
                    }
                }
                _safeMint(msg.sender, mintIndex);
                totalCounter = totalCounter + 1;
            }
        }
  }

  function mintCopyPreSale(uint256 numberOfTokens) public payable {
    require(balanceOf(msg.sender)+numberOfTokens <= 5, "Can only mint 5 copies at a time");
    require(preSaleIsActive == 1, "Sale must be active to mint a copies");
    require((totalSupply() + numberOfTokens) <= totalCopies, "Purchase would exceed max supply of copies");
    require((price * numberOfTokens) <= msg.value, "Too little ETH send");

    for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, (i+100)))) % (totalCopies- maxReserved);
            mintIndex = mintIndex + maxReserved + 1;
            if (totalCounter < totalCopies) {
                while(_exists((mintIndex))) {
                    mintIndex = mintIndex + 1;
                    if (mintIndex > (totalCopies)) {
                      mintIndex = maxReserved + 1;
                    }
                }
                _safeMint(msg.sender, mintIndex);
                totalCounter = totalCounter + 1;
            }
        }
  }

  function mintPresaleFls(uint256 numberOfTokens, uint256 flsTokenId) public payable{
    require(balanceOf(msg.sender)+numberOfTokens <= 5, "Can only mint 5 copies at a time");
    require(preSaleIsActive == 1, "Sale must be active to mint a copies");
    require((totalSupply() + numberOfTokens) <= totalCopies, "Purchase would exceed max supply of copies");
    require((price * numberOfTokens) <= msg.value, "Too little ETH send");
    require(fls.ownerOf(flsTokenId) == msg.sender, "not an FLS holder");

    for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, (i+100)))) % (totalCopies- maxReserved);
            mintIndex = mintIndex + maxReserved + 1;
            if (totalCounter < totalCopies) {
                while(_exists((mintIndex))) {
                    mintIndex = mintIndex + 1;
                    if (mintIndex > (totalCopies)) {
                      mintIndex = maxReserved + 1;
                    }
                }
                _safeMint(msg.sender, mintIndex);
                totalCounter = totalCounter + 1;
            }
        }
  }

  function mintPresaleCats(uint256 numberOfTokens, uint256 catsTokenId) public payable {
    require(balanceOf(msg.sender)+numberOfTokens <= 5, "Can only mint 20 copies at a time");
    require(preSaleIsActive == 1, "Sale must be active to mint a copies");
    require((totalSupply() + numberOfTokens) <= totalCopies, "Purchase would exceed max supply of copies");
    require((price * numberOfTokens) <= msg.value, "Too little ETH send");
    require(cats.ownerOf(catsTokenId) == msg.sender, "not an ACA holder");

    for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, (i+100)))) % (totalCopies- maxReserved);
            mintIndex = mintIndex + maxReserved + 1;
            if (totalCounter < totalCopies) {
                while(_exists((mintIndex))) {
                    mintIndex = mintIndex + 1;
                    if (mintIndex > (totalCopies)) {
                      mintIndex = maxReserved + 1;
                    }
                }
                _safeMint(msg.sender, mintIndex);
                totalCounter = totalCounter + 1;
            }
        }
  }

    function flipSale(uint256 _saleState) public onlyOwner {
      saleIsActive = _saleState;
  }
    function flipPreSale(uint256 _saleState) public onlyOwner {
      preSaleIsActive = _saleState;
  }

    function withdraw() public payable onlyOwner{
        uint256 balance = address(this).balance;
        uint256 studio = balance / 100 * 20; 
        uint256 acc1 = balance / 100 * 5;
        uint256 acc2 = balance / 100 * 5;
        uint256 acc3 = balance / 100 * 40;
        uint256 acc4 = balance / 100 * 30;

        payable(0x388CcBf8c1A37F444DcFF6eDE0014DfA85BeDC1B).transfer(studio);
        payable(0x72B3639810ECfE3573B11c56AD4d52BC6A02B5B0).transfer(acc1);
        payable(0xa2F072e33e4d8f9e9231d8359725A4C059Ff596E).transfer(acc2);
        payable(0x73cd135Bea6B6071AE533b497193BE9299448579).transfer(acc3);
        payable(0x909957dcc1B114Fe262F4779e6aeD4d034D96B0f).transfer(acc4);
    }
    function setPrice(uint256 _newprice) public onlyOwner{
        require(_newprice >= 10000000000000000, "The price cannot be lower then 0.01 eth");
        price = _newprice;
    }
}