// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



import "./DateTime.sol";

import "erc721a/contracts/ERC721A.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract Caesar is ERC721A, Ownable, ReentrancyGuard {

  uint256 public constant COLLECTION_SIZE = 10000;

  mapping(uint256 => uint256) private _tokenLockedData;

  bool public saleIsActive = false;

  uint256 public preSalePrice = 0;



  constructor() ERC721A("Caesar", "CAESAR") {}



  modifier callerIsUser() {

    require(tx.origin == msg.sender, "Caesar: caller is another contract");

    _;

  }



  function devMint(uint8 _batchSize, uint256 _quantity) external onlyOwner {

    require(

      totalSupply() + _quantity <= COLLECTION_SIZE,

      "Caesar: reached max supply"

    );

    require(

      _quantity % _batchSize == 0,

      "Caesar: can only mint a multiple of the batchSize"

    );



    uint256 numChunks = _quantity / _batchSize;



    for (uint256 i = 0; i < numChunks; i++) {

      _safeMint(msg.sender, _batchSize);

    }

  }



  string private _baseTokenURI;



  function _baseURI() internal view virtual override returns (string memory) {

    return _baseTokenURI;

  }



  function setBaseURI(string calldata baseURI) external onlyOwner {

    _baseTokenURI = baseURI;

  }



  function setSaleActive(

    bool _isActive,

    uint256 _preSalePrice

  ) external onlyOwner {

    saleIsActive = _isActive;

    preSalePrice = (_preSalePrice * 1 ether);

  }



  function setApproveToContract(

    uint256 _min,

    uint256 _max,

    bool _revoke

  ) external onlyOwner {

    require(_min < _max, "Caesar: max must be greater than min");



    for (uint256 numOfToken = _min; numOfToken <= _max; numOfToken++) {

      if (ownerOf(numOfToken) != msg.sender) continue;



      if (_revoke) {

        approve(address(0), numOfToken);

      } else {

        approve(address(this), numOfToken);

      }

    }

  }



  function _beforeTokenTransfers(

    address _from,

    address _to,

    uint256 _startTokenId,

    uint256 _quantity

  ) internal virtual override {

    super._beforeTokenTransfers(_from, _to, _startTokenId, _quantity);



    (uint256 year, uint256 month, uint256 day) = DateTime.timestampToDate(

      _tokenLockedData[_startTokenId]

    );



    string memory stringYear = Strings.toString(year);

    string memory stringMonth = "";

    string memory stringDay = Strings.toString(day);



    if (month == 1) {

      stringMonth = "Jan";

    } else if (month == 2) {

      stringMonth = "Feb";

    } else if (month == 3) {

      stringMonth = "Mar";

    } else if (month == 4) {

      stringMonth = "Apr";

    } else if (month == 5) {

      stringMonth = "Mau";

    } else if (month == 6) {

      stringMonth = "Jun";

    } else if (month == 7) {

      stringMonth = "Jul";

    } else if (month == 8) {

      stringMonth = "Aug";

    } else if (month == 9) {

      stringMonth = "Sep";

    } else if (month == 10) {

      stringMonth = "Oct";

    } else if (month == 11) {

      stringMonth = "Nov";

    } else {

      stringMonth = "Dec";

    }



    string memory message = "Caesar: This token ID cannot be transfer until ";

    message = string.concat(message, stringMonth);

    message = string.concat(message, " ");

    message = string.concat(message, stringDay);

    message = string.concat(message, ", ");

    message = string.concat(message, stringYear);



    require(block.timestamp > _tokenLockedData[_startTokenId], message);

  }



  function gracePeriodOfTransfer(

    address _to,

    uint256 _tokenId,

    uint256 _expiredDays

  ) external onlyOwner {

    safeTransferFrom(msg.sender, _to, _tokenId);



    _tokenLockedData[_tokenId] = block.timestamp + (_expiredDays * 1 days);

  }



  function getTokenLockedData(uint256 _tokenId) public view returns (uint256) {

    return _tokenLockedData[_tokenId];

  }



  function preSale(

    uint256 _tokenId

  ) external payable callerIsUser nonReentrant {

    require(

      saleIsActive && preSalePrice > 0,

      "Caesar: presale have not started yet"

    );

    require(

      ownerOf(_tokenId) == owner() && getApproved(_tokenId) == address(this),

      "Caesar: this token ID cannot be purchased"

    );



    IERC721A(address(this)).safeTransferFrom(owner(), msg.sender, _tokenId);



    refundIfOver(preSalePrice);

  }



  function refundIfOver(uint256 price) private {

    require(msg.value >= price, "Caesar: need to send more ETH");

    if (msg.value > price) {

      payable(msg.sender).transfer(msg.value - price);

    }

  }



  function withdrawMoney() external onlyOwner nonReentrant {

    (bool success, ) = msg.sender.call{value: address(this).balance}("");

    require(success, "Caesar: transfer failed");

  }

}