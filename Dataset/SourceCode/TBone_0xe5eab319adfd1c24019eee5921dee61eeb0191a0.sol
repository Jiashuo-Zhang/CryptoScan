// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";

contract TBone is ERC20Capped, Ownable, ReentrancyGuard {
  bool public phaseOneOpen = false;
  bool public phaseTwoOpen = false;

  // Phase Supply Limit
  uint256 public _phaseOneSupply = 21040184 * 1e18;
  uint256 public _phaseTwoSupply = 29849070 * 1e18;

  uint256 public _teamSupply = 5000000 * 1e18; // initial supply
  uint256 public _treasureSupply = 13110746 * 1e18; // treasury supply

  address signer;

  mapping(address => uint256) addressBlockBought;
  mapping(string => bool) signatureUsed;
  mapping(address => bool) public isPhaseOneClaimed;
  mapping(uint256 => bool) public isPhaseTwoClaimed;

  constructor(uint256 cap, address _signer) ERC20("TBone", "TBONE") ERC20Capped(cap * 1e18) {
    signer = _signer;
    _mint(msg.sender, _teamSupply);
    _mint(msg.sender, _treasureSupply);
  }

  modifier isSecured(uint8 phaseType) {
    require(addressBlockBought[msg.sender] < block.timestamp, "Not allowed to proceed in the same block");
    require(tx.origin == msg.sender, "Sender is not allowed to mint");

    if (phaseType == 1) {
      require(phaseOneOpen, "Phase 1 not active");
    }
    if (phaseType == 2) {
      require(phaseTwoOpen, "Phase 2 not active");
    }
    _;
  }

  function togglePhaseOne() external onlyOwner {
    phaseOneOpen = !phaseOneOpen;
  }

  function togglePhaseTwo() external onlyOwner {
    phaseTwoOpen = !phaseTwoOpen;
  }

  function claimTbonePhaseOne(uint64 expireTime, bytes memory sig, uint256 amount) external isSecured(1) {
    bytes32 digest = keccak256(abi.encodePacked(msg.sender, amount, expireTime));
    uint256 claim_amount = amount * 1e18;
    require(isAuthorized(sig, digest), "Signature is invalid");
    require(totalSupply() + claim_amount <= _phaseOneSupply, "Amount exceeds the phase supply");
    require(totalSupply() + claim_amount <= cap(), "Supply is depleted");
    require(signatureUsed[string(sig)] == false, "Signature is already used");
    require(!isPhaseOneClaimed[msg.sender], "Already CLaimed");

    signatureUsed[string(sig)] = true;
    addressBlockBought[msg.sender] = block.timestamp;
    isPhaseOneClaimed[msg.sender] = true;
    _mint(msg.sender, claim_amount);
  }

  function claimTbonePhaseTwo(bytes memory sig, uint64 exp, uint256 amount, uint256 entryId) external isSecured(2) {
    bytes32 digest = keccak256(abi.encodePacked(msg.sender, amount, exp));
    uint256 claim_amount = amount * 1e18;
    require(isAuthorized(sig, digest), "Signature is invalid");
    require(totalSupply() + claim_amount <= _phaseOneSupply + _phaseTwoSupply, "Amount exceeds the phase supply");
    require(totalSupply() + claim_amount <= cap(), "Supply is depleted");
    require(signatureUsed[string(sig)] == false, "Signature is already used");
    require(!isPhaseTwoClaimed[entryId], "Already CLaimed");

    signatureUsed[string(sig)] = true;
    addressBlockBought[msg.sender] = block.timestamp;
    isPhaseTwoClaimed[entryId] = true;
    _mint(msg.sender, claim_amount);
  }

  function setSigner(address _signer) external onlyOwner {
    signer = _signer;
  }

  function isAuthorized(bytes memory sig, bytes32 digest) private view returns (bool) {
    return ECDSA.recover(digest, sig) == signer;
  }
}