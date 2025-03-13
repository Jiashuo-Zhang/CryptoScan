// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract Surf is Ownable, ERC721A, DefaultOperatorFilterer {
  using ECDSA for bytes32;
  using Strings for uint256;

  string private _baseTokenURI;

  uint256 public mintPrice = 0.019 ether;

  bool public isPresaleActive = false;
  bool public isSaleActive = false;

  uint256 public maxSupply = 6000;
  uint256 public presaleSupply = 6000;

  uint256 public maxMintPerWallet = 2;

  bool public isRevealed = false;

  mapping(address => bool) public isAddressPresaleMinted;
  mapping(address => bool) public isAddressMinted;

  address public signer;

  constructor() ERC721A("Surf and Turf", "SURF") DefaultOperatorFilterer() {}

  modifier noContractMint() {
    require(tx.origin == msg.sender, "contract call denied");
    _;
  }

  function presaleMint(uint256 quantity, bytes calldata signature)
    external
    payable
    noContractMint
  {
    require(isPresaleActive, "presale is not active");
    require(msg.value >= mintPrice * quantity, "insufficient funds");
    require(
      totalSupply() + quantity <= presaleSupply,
      "max supply reached in presale phase"
    );
    require(totalSupply() + quantity <= maxSupply, "max supply reached");
    require(quantity <= maxMintPerWallet, "quantity exceed maxMintPerWallet");
    require(
      isAddressPresaleMinted[msg.sender] == false,
      "can only presaleMint once"
    );
    require(
      _verifyPresaleWhitelistSignature(signature),
      "can only mint with whitelist signature"
    );

    isAddressPresaleMinted[msg.sender] = true;
    _safeMint(msg.sender, quantity);
  }

  function _verifyPresaleWhitelistSignature(bytes calldata signature)
    internal
    view
    returns (bool)
  {
    address recoveredAddress = keccak256(abi.encodePacked(msg.sender))
      .toEthSignedMessageHash()
      .recover(signature);
    return (recoveredAddress != address(0) && recoveredAddress == signer);
  }

  function setSigner(address _signer) external onlyOwner {
    signer = _signer;
  }

  function publicMint(uint256 quantity) external payable noContractMint {
    require(isSaleActive, "sale is not active");
    require(msg.value >= mintPrice * quantity, "insufficient funds");
    require(totalSupply() + quantity <= maxSupply, "max supply reached");
    require(quantity <= maxMintPerWallet, "quantity exceed maxMintPerWallet");
    require(isAddressMinted[msg.sender] == false, "can only publicMint once");

    isAddressMinted[msg.sender] = true;
    _safeMint(msg.sender, quantity);
  }

  function devMint(uint256 quantity, address to) external onlyOwner {
    require(totalSupply() + quantity <= maxSupply, "max supply reached");

    _safeMint(to, quantity);
  }

  // implements operator-filter-registry blocklist filtering
  function setApprovalForAll(address operator, bool approved)
    public
    override
    onlyAllowedOperatorApproval(operator)
  {
    super.setApprovalForAll(operator, approved);
  }

  function approve(address operator, uint256 tokenId)
    public
    payable
    override
    onlyAllowedOperatorApproval(operator)
  {
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

  function setIsPresaleActive(bool _isActive) external onlyOwner {
    isPresaleActive = _isActive;
  }

  function setIsSaleActive(bool _isActive) external onlyOwner {
    isSaleActive = _isActive;
  }

  function setIsRevealed(bool _isRevealed) external onlyOwner {
    isRevealed = _isRevealed;
  }

  function _baseURI() internal view override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

    string memory baseURI = _baseURI();
    if (!isRevealed) return bytes(baseURI).length != 0 ? baseURI : "";
    return
      bytes(baseURI).length != 0
        ? string(abi.encodePacked(baseURI, _toString(tokenId)))
        : "";
  }

  function setMintPrice(uint256 _mintPrice) external onlyOwner {
    mintPrice = _mintPrice;
  }

  function setMaxSupply(uint256 _maxSupply) external onlyOwner {
    require(totalSupply() <= _maxSupply, "reached _maxSupply");
    maxSupply = _maxSupply;
  }

  function setPresaleSupply(uint256 _presaleSupply) external onlyOwner {
    presaleSupply = _presaleSupply;
  }

  function setMaxMintPerWallet(uint256 _maxMint) external onlyOwner {
    maxMintPerWallet = _maxMint;
  }

  // no ReentrancyGuard needed for Ownable
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}(
      ""
    );
    require(success, "Transfer failed.");
  }
}