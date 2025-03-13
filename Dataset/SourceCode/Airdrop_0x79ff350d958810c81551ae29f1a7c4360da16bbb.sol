// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./helpers/SnailError.sol";

contract Airdrop is Ownable {
    using MerkleProof for bytes32[];
    using SafeERC20 for IERC20;

    uint256 immutable startTime;
    uint256 immutable duration;
    uint256 immutable endTime;

    mapping(uint256 => bytes32) public merkleRoots; // tokenIndex => merkleRoot

    IERC20 public _erc20;

    mapping(uint256 => mapping(address => bool)) public _claimed; //token => users => claimed?

    event Claim(uint256 indexed airdropId, address indexed who, uint256 amount);

    event NewAirdropAdded(uint256 indexed airdropId, bytes32 root);

    constructor(
        IERC20 erc20,
        uint256[] memory tokenIndex,
        bytes32[] memory merkleTreeRoot,
        address owner,
        uint256 _startTime,
        uint256 _duration
    ) Ownable() {
        _erc20 = erc20;
        require(tokenIndex.length == merkleTreeRoot.length, SnailError.ARRAY_MISMATCH);
        for (uint256 index = 0; index < merkleTreeRoot.length; index++) {
            bytes32 element = merkleTreeRoot[index];
            uint256 _tokenIndex = tokenIndex[index];
            require(merkleRoots[_tokenIndex] == bytes32(0), SnailError.CANNOT_OVERRIDE);
            merkleRoots[_tokenIndex] = element;
            emit NewAirdropAdded(tokenIndex[index], element);
        }
        _transferOwnership(owner);
        startTime = _startTime;
        duration = _duration;
        endTime = _startTime + _duration;
    }

    function insertNewAirdrops(uint256[] memory tokenIndex, bytes32[] memory newRoots) external onlyOwner beforeEnd {
        require(tokenIndex.length == newRoots.length, SnailError.ARRAY_MISMATCH);
        for (uint256 index = 0; index < tokenIndex.length; index++) {
            uint256 element = tokenIndex[index];
            bytes32 elementRoot = newRoots[index];
            require(merkleRoots[element] == bytes32(0), SnailError.CANNOT_OVERRIDE);
            merkleRoots[element] = elementRoot;
            emit NewAirdropAdded(element, elementRoot);
        }
    }

    function claimMultiple(
        uint256[] memory tokenIndex,
        uint256[] memory amount,
        bytes32[][] calldata proof
    ) public returns (uint256) {
        require(tokenIndex.length == amount.length, SnailError.ARRAY_MISMATCH);
        require(amount.length == proof.length, SnailError.ARRAY_MISMATCH);

        address sender = _msgSender();
        uint256 totalAmountToClaim;
        for (uint256 index = 0; index < tokenIndex.length; index++) {
            totalAmountToClaim += _claim(tokenIndex[index], sender, amount[index], proof[index]);
        }
        _transferToken(msg.sender, totalAmountToClaim);
        return totalAmountToClaim;
    }

    function claim(uint256 tokenIndex, uint256 amount, bytes32[] calldata proof) external returns (uint256) {
        _claim(tokenIndex, _msgSender(), amount, proof);
        _transferToken(msg.sender, amount);

        return amount;
    }

    function _transferToken(address to, uint256 amount) internal {
        _erc20.safeTransfer(to, amount);
    }

    function _claim(
        uint256 tokenIndex,
        address who,
        uint256 amount,
        bytes32[] calldata proof
    ) internal returns (uint256) {
        require(canClaim(tokenIndex, who, amount, proof), SnailError.CANNOT_CLAIM_AIRDROP);

        _claimed[tokenIndex][who] = true;

        emit Claim(tokenIndex, who, amount);

        return amount;
    }

    function canClaim(
        uint256 tokenIndex,
        address who,
        uint256 amount,
        bytes32[] calldata proof
    ) public view beforeEnd returns (bool) {
        return (!_claimed[tokenIndex][who] &&
            proof.verify(merkleRoots[tokenIndex], keccak256(abi.encode(who, amount))));
    }

    function clean(address to) public onlyOwner {
        uint256 balance = _erc20.balanceOf(address(this));
        if (balance > 0) {
            _transferToken(to, balance);
        }
    }

    modifier afterEnd() {
        require(block.timestamp > endTime, SnailError.TIME_CRITERIA_NOT_MET);
        _;
    }

    modifier beforeEnd() {
        require(block.timestamp <= endTime, SnailError.TIME_CRITERIA_NOT_MET);
        _;
    }
}