// SPDX-License-Identifier: AGPL-3.0-only
// @author creco.xyz 🐊 2022 

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface ShadowMonkeyComic {
  function mintTo(address _to) external returns(uint256);
  function beneficiary() external returns(address payable);
}

contract ShadowMonkeyMinter is AccessControlEnumerable {

  using SafeMath for uint256;
  using ECDSA for bytes32;

  ShadowMonkeyComic comics;
  address public verifier; 

  bool public isAllowlistActive = false;
  bool public isPublicActive = false;
  uint256 public constant MAX_PUBLIC = 10;
  uint256 public constant MAX_ALLOWLIST = 3;
  uint256 public mintPrice = 0.088 ether;

  mapping(address => uint) public allowlistMints; // allow max mints per wallet

  modifier onlyAdmin {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ShadowMonkeyMinter: must have Admin role");
    _;
  } 

  constructor(address _comics) { 
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // set admin permissions
    comics = ShadowMonkeyComic(_comics);
  }

  // O N L Y   A  D M I N
  function setVerifier(address _verifier) public onlyAdmin {
    verifier = _verifier;
  }

  function setPrice(uint256 _mintPrice) public onlyAdmin {
    mintPrice = _mintPrice;
  }

  function setComics(address _comics) public onlyAdmin {
    comics = ShadowMonkeyComic(_comics);
  }

  function setPublicActive(bool active) public onlyAdmin {
    isPublicActive = active;
  }

  function setAllowlistActive(bool active) public onlyAdmin {
    isAllowlistActive = active;
  }

  // M I N T 
  // allowlist mint
  function mintAllowlist(uint amount, bytes memory signature) public payable returns(uint256[] memory) {
    require(isAllowlistActive, "Minter: Allowlist mint is closed");
    address to = msg.sender;
    require(((allowlistMints[to] + amount) <= MAX_ALLOWLIST), "Minter: Amount exceeds allowlist limit");
    require(msg.value == mintPrice.mul(amount), "Minter: Ether value sent is not correct");
    require(verifier != address(0x0), "Minter: Verifier not set");
    // verify signature
    bytes32 _msg = keccak256(abi.encodePacked(to, MAX_ALLOWLIST));
    address _recovered = _msg.recover(signature);
    require(verifier == _recovered, "Minter: Bad signature or invalid data");
    // transfer funds
    address payable beneficiary = comics.beneficiary();
    require(beneficiary != address(0x0), "Minter: Beneficiary not set");
    beneficiary.transfer(msg.value);
    // mint tokens
    allowlistMints[to] += amount;
    uint256[] memory ids = _mint(to, amount);
    return ids;
  } 

  // public mint
  function mintPublic(uint amount) public payable returns(uint256[] memory) {
    require(isPublicActive, "Minter: Public mint is closed");
    address to = msg.sender;
    require(amount <=  MAX_PUBLIC, "Minter: Amount exceeds public limit per tx");
    require(msg.value == mintPrice.mul(amount), "Minter: Ether value sent is not correct");
    // transfer funds
    address payable beneficiary = comics.beneficiary();
    require(beneficiary != address(0x0), "Minter: Beneficiary not set");
    beneficiary.transfer(msg.value);
    //mint tokens
    uint256[] memory ids = _mint(to, amount);
    return ids;
   }

   // admin mint for treasury
   function mint(uint amount, address to) public onlyAdmin returns(uint256[] memory){
    uint256[] memory ids = _mint(to, amount);
    return ids;
   }

  // I N T E R N A L
  function _mint(address to, uint amount) internal returns(uint256[] memory) {
    uint256[] memory ids = new uint256[](amount);
    for (uint i = 0; i < amount; i++) {
      uint tokenId = comics.mintTo(to);
      ids[i] = tokenId;
    }
    return ids;
  }

}