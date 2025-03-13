// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Airdrop is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public ERC20;
    uint256 public deadline;
    bytes32 public merkleRoot;

    mapping(uint256 => uint256) private _claimedBitMap;

    event Claimed(uint256 indexed index, address indexed account, uint256 indexed amount);
    event Withdrawal(address indexed to, uint256 indexed amount);
    event AirdropChanged(address indexed token, bytes32 indexed merkleRoot, uint256 indexed deadline);

    constructor(IERC20 _erc20, bytes32 _merkleRoot, uint256 _deadline) {
        ERC20 = _erc20;
        merkleRoot = _merkleRoot;
        deadline = _deadline;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = _claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        _claimedBitMap[claimedWordIndex] = _claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external nonReentrant {
        require(block.timestamp < deadline, "The airdrop has ended");
        require(!isClaimed(index), "Airdrop has been claimed");
        bytes32 leaf = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, leaf), "Invalid proof");
        _setClaimed(index);
        ERC20.safeTransfer(account, amount);
        emit Claimed(index, account, amount);
    }

    function withdraw(address to) external onlyOwner {
        require(block.timestamp > deadline, "Airdrop not over");
        uint256 balance = ERC20.balanceOf(address(this));
        require(balance > 0, "Insufficient balance");
        ERC20.safeTransfer(to, balance);
        emit Withdrawal(to, balance);
    }

    function setAirdrop(IERC20 _erc20, bytes32 _merkleRoot, uint256 _deadline) external onlyOwner {
        ERC20 = _erc20;
        merkleRoot = _merkleRoot;
        deadline = _deadline;
        emit AirdropChanged(address(_erc20), _merkleRoot, _deadline);
    }
}