// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract FoxeAirdrop is Ownable {
    IERC20 public token;
    uint256 private constant MAX_CLAIMABLE = 1777819;
    uint256 private claimedCount;
    mapping(address => bool) public hasClaimed;
    bytes32 public merkleRoot;
    bool public isAirdropEnabled;

    event Claimed(address indexed claimer, uint256 amount);

    constructor(IERC20 _token, bytes32 _merkleRoot) {
        token = _token;
        merkleRoot = _merkleRoot;
        isAirdropEnabled = true;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function toggleAirdrop(bool _isAirdropEnabled) external onlyOwner {
        isAirdropEnabled = _isAirdropEnabled;
    }

    function claim(bytes32[] calldata merkleProof) external {
        require(isAirdropEnabled, "Airdrop: The airdrop is currently disabled");
        require(claimedCount < MAX_CLAIMABLE, "Airdrop: All tokens have been claimed");
        require(!hasClaimed[msg.sender], "Airdrop: You have already claimed your tokens");

        bytes32 node = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Airdrop: Invalid merkle proof");

        uint256 amount;
        if (claimedCount < 50) {
            amount = 1777819000000 * 10 ** 18;
        } else if (claimedCount >= 50 && claimedCount < 500) {
            amount = 47408506667 * 10 ** 18;
        } else if (claimedCount >= 500 && claimedCount < 2500) {
            amount = 10666914000 * 10 ** 18;
        } else if (claimedCount >= 2500 && claimedCount < 10000) {
            amount = 2844510400 * 10 ** 18;
        } else if (claimedCount >= 10000 && claimedCount < 50000) {
            amount = 533345700 * 10 ** 18;
        } else {
            amount = 12347258.6 * 10 ** 18;
        }

        hasClaimed[msg.sender] = true;
        claimedCount++;

        require(token.transfer(msg.sender, amount), "Airdrop: Token transfer failed");
        emit Claimed(msg.sender, amount);
    }

    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        require(token.transfer(owner(), _amount), "Airdrop: Emergency withdrawal failed");
    }
}