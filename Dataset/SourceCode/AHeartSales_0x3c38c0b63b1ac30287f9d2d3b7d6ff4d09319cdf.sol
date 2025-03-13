// SPDX-License-Identifier: MIT

// Project A-Heart: https://a-he.art

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./interfaces/IAHeart.sol";
import "./interfaces/IAHeartSales.sol";

uint256 constant PRE_SALE_INDEX = 0;
uint256 constant PARTNER_SALE_INDEX = 1;
uint256 constant PUBLIC_SALE_INDEX = 2;
uint256 constant FREE_MINT_INDEX = 3;

contract AHeartSales is IAHeartSales, Ownable {
  uint256 public constant RESERVED_TOKENS = 150;

  uint256 public constant MAX_SUPPLY = 2690;

  uint256 public constant MAX_AMOUNT_PER_TX = 69;

  uint256 public totalSold;

  uint256 public totalReservedTokensMinted;

  uint256 public totalMinted;

  IAHeart public token;

  address public manager;

  bool public salesClosed;

  SaleInfo private _initialPreSaleInfo =
    SaleInfo({
      index: PRE_SALE_INDEX,
      // JST 2023-04-07T14:00:00+09:00
      // EDT 2023-04-07T01:00:00-04:00
      startTimestamp: 1680843600,
      // JST 2023-04-08T14:00:00+09:00
      // EDT 2023-04-08T01:00:00-04:00
      endTimestamp: 1680930000,
      price: 0.0369 ether,
      merkleRoot: 0xb194d4bcba328090b835a00ab692741e19d7d4abebafc6ae4f80f4ad09dee7a7
    });

  SaleInfo private _initialPartnerSaleInfo =
    SaleInfo({
      index: PARTNER_SALE_INDEX,
      // JST 2023-04-08T14:00:00+09:00
      // EDT 2023-04-08T01:00:00-04:00
      startTimestamp: 1680930000,
      // JST 2023-04-09T14:00:00+09:00
      // EDT 2023-04-09T01:00:00-04:00
      endTimestamp: 1681016400,
      price: 0.0369 ether,
      merkleRoot: 0x7413090089cb488ccb99f8b4518e4e18fa2de08ebe23d83f47ec3dabdf58d188
    });

  SaleInfo private _initialPublicSaleInfo =
    SaleInfo({
      index: PUBLIC_SALE_INDEX,
      // JST 2023-04-09T14:00:00+09:00
      // EDT 2023-04-09T01:00:00-04:00
      startTimestamp: 1681016400,
      // JST 2023-04-10T14:00:00+09:00
      // EDT 2023-04-10T01:00:00-04:00
      endTimestamp: 1681102800,
      price: 0.0369 ether,
      merkleRoot: 0x0
    });

  SaleInfo private _initialFreeMintInfo =
    SaleInfo({
      index: FREE_MINT_INDEX,
      // JST 2023-04-07T14:00:00+09:00
      // EDT 2023-04-07T01:00:00-04:00
      startTimestamp: 1680843600,
      // JST 2023-04-10T14:00:00+09:00
      // EDT 2023-04-10T01:00:00-04:00
      endTimestamp: 1681102800,
      price: 0,
      merkleRoot: 0x82a314f5575ff7d4c7256b6b05b27606482ab7f1b4cec44a94d5ffe69d41e4f6
    });

  mapping(uint256 => SaleInfo) private _saleInfo;

  mapping(uint256 => mapping(address => uint256)) private _mintedCount;

  constructor(address tokenAddress, address managerAddress) {
    require(tokenAddress != address(0), "tokenAddress is required");
    require(managerAddress != address(0), "managerAddress is required");

    token = IAHeart(tokenAddress);
    manager = managerAddress;

    _saleInfo[_initialPreSaleInfo.index] = _initialPreSaleInfo;
    _saleInfo[_initialPartnerSaleInfo.index] = _initialPartnerSaleInfo;
    _saleInfo[_initialPublicSaleInfo.index] = _initialPublicSaleInfo;
    _saleInfo[_initialFreeMintInfo.index] = _initialFreeMintInfo;
  }

  function _requireSaleIsActive(uint256 saleIndex) internal view {
    require(!salesClosed, "Sale is closed");

    SaleInfo memory info = _saleInfo[saleIndex];
    if (info.startTimestamp > 0) {
      require(info.startTimestamp <= block.timestamp, "Sale has not started yet");
    }
    if (info.endTimestamp > 0) {
      require(block.timestamp < info.endTimestamp, "Sale is over");
    }
  }

  modifier whenSaleIsActive(uint256 saleIndex) {
    _requireSaleIsActive(saleIndex);
    _;
  }

  function verify(address addr, uint256 spots, bytes32[] memory proof, bytes32 root) public pure returns (bool) {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(addr, spots))));
    return MerkleProof.verify(proof, root, leaf);
  }

  function preSaleInfo() public view returns (SaleInfo memory) {
    return _saleInfo[PRE_SALE_INDEX];
  }

  function partnerSaleInfo() public view returns (SaleInfo memory) {
    return _saleInfo[PARTNER_SALE_INDEX];
  }

  function publicSaleInfo() public view returns (SaleInfo memory) {
    return _saleInfo[PUBLIC_SALE_INDEX];
  }

  function freeMintInfo() public view returns (SaleInfo memory) {
    return _saleInfo[FREE_MINT_INDEX];
  }

  function saleInfo(uint256 saleIndex) public view returns (SaleInfo memory) {
    return _saleInfo[saleIndex];
  }

  function setMerkleRoot(uint256 saleIndex, bytes32 root) external onlyOwner {
    _saleInfo[saleIndex].merkleRoot = root;
  }

  function setTimestamps(uint256 saleIndex, uint256 start, uint256 end) external onlyOwner {
    _saleInfo[saleIndex].startTimestamp = start;
    _saleInfo[saleIndex].endTimestamp = end;
  }

  function setPrice(uint256 saleIndex, uint256 price) external onlyOwner {
    _saleInfo[saleIndex].price = price;
  }

  function mintedCount(uint256 saleIndex, address addr) public view returns (uint256) {
    return _mintedCount[saleIndex][addr];
  }

  function mintPreSale(uint256 amount, uint256 spots, bytes32[] calldata proof) external payable whenSaleIsActive(PRE_SALE_INDEX) {
    _sale(PRE_SALE_INDEX, amount, spots, proof, false);
  }

  function mintPartnerSale(uint256 amount, uint256 spots, bytes32[] calldata proof) external payable whenSaleIsActive(PARTNER_SALE_INDEX) {
    _sale(PARTNER_SALE_INDEX, amount, spots, proof, false);
  }

  function mintPublicSale(uint256 amount) external payable whenSaleIsActive(PUBLIC_SALE_INDEX) {
    _sale(PUBLIC_SALE_INDEX, amount, 0, new bytes32[](0), false);
  }

  function mintFree(uint256 amount, uint256 spots, bytes32[] calldata proof) external whenSaleIsActive(FREE_MINT_INDEX) {
    _sale(FREE_MINT_INDEX, amount, spots, proof, true);
  }

  function _sale(uint256 saleIndex, uint256 amount, uint256 spots, bytes32[] memory proof, bool reserved) internal {
    require(amount > 0, "Invalid amount");
    require(amount <= MAX_AMOUNT_PER_TX, "Too many amount");

    SaleInfo memory info = _saleInfo[saleIndex];

    if (info.merkleRoot != bytes32(0)) {
      require(verify(_msgSender(), spots, proof, info.merkleRoot), "Proof is invalid");
    }

    if (spots != 0) {
      require(_mintedCount[info.index][_msgSender()] + amount <= spots, "All spots have been consumed");
    }

    if (info.price != 0) {
      require(msg.value >= info.price * amount, "Insufficient amount of eth");
    }

    unchecked {
      _mintedCount[info.index][_msgSender()] += amount;
    }

    if (reserved) {
      _mintReservedTokens(_msgSender(), amount);
    } else {
      _mintSales(_msgSender(), amount);
    }
  }

  function _mintReservedTokens(address to, uint256 amount) internal {
    require(totalReservedTokensMinted + amount <= RESERVED_TOKENS, "Minted out");

    for (uint256 i = 0; i < amount; ) {
      token.mint(to, totalReservedTokensMinted + i + 1);
      unchecked {
        i++;
      }
    }

    unchecked {
      totalReservedTokensMinted += amount;
      totalMinted += amount;
    }
  }

  function _mintSales(address to, uint256 amount) internal {
    require(RESERVED_TOKENS + totalSold + amount <= MAX_SUPPLY, "Sold out");

    for (uint256 i = 0; i < amount; ) {
      token.mint(to, RESERVED_TOKENS + totalSold + i + 1);
      unchecked {
        i++;
      }
    }

    unchecked {
      totalSold += amount;
      totalMinted += amount;
    }
  }

  function mintTeam(address to, uint256 amount) external onlyOwner {
    require(to != address(0), "Recipient address is necessary");

    _mintReservedTokens(to, amount);
  }

  function setSalesClosed(bool value) external onlyOwner {
    salesClosed = value;
  }

  function setManager(address newManager) external onlyOwner {
    manager = newManager;
  }

  function withdraw() external onlyOwner {
    require(manager != address(0), "Manager address is not set");

    (bool success, ) = manager.call{value: address(this).balance}("");
    require(success, "Failed to send to manager");
  }
}