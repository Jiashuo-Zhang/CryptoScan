// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.11;

import {SafeERC20} from "../Dependencies/SafeERC20.sol";
import {IERC20} from "../Dependencies/IERC20.sol";
import {MerkleProof} from "../Dependencies/MerkleProof.sol";
import {IMerkleDistributor} from "../Interfaces/IMerkleDistributor.sol";
import {Ownable} from "../Dependencies/Ownable.sol";
import {CheckContract} from "../Dependencies/CheckContract.sol";

contract MerkleDistributor is IMerkleDistributor, Ownable, CheckContract {
    using SafeERC20 for IERC20;

    /// @dev ERC20 token
    address public token;
    /// @dev ERC20-claimee inclusion root
    bytes32 public merkleRoot;

    /// @dev Mapping of addresses who have claimed tokens
    mapping(address => bool) private _hasClaimed;

    // --- Events ---

    event LQTYTokenAddressSet(address _lqtyTokenAddress);
    event MerkleRootSet(bytes32 _merkleRoot);
    event Claim(address account, uint256 amount);

    // --- Functions ---

    constructor() public {}

    function setParams(address _lqtyTokenAddress, bytes32 _merkleRoot) external onlyOwner {
        checkContract(_lqtyTokenAddress);

        token = _lqtyTokenAddress;
        merkleRoot = _merkleRoot;

        // When Token deployed, it should have transferred Airdrop
        uint256 LQTYBalance = IERC20(token).balanceOf(address(this));
        assert(LQTYBalance > 0);

        emit LQTYTokenAddressSet(_lqtyTokenAddress);
        emit MerkleRootSet(_merkleRoot);

        _renounceOwnership();
    }

    function isClaimed(address account) public view override returns (bool) {
        return _hasClaimed[account];
    }

    function canClaim(address account, uint256 amount) public view override returns (bool) {
        return IERC20(token).balanceOf(address(this)) >= amount && !isClaimed(account);
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) public virtual override {
        require(!isClaimed(account), "MerkleDistributor: Already claimed");

        // Verify the merkle proof.
        bytes32 leaf = keccak256(abi.encodePacked(account, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "MerkleDistributor: Invalid proof");

        // Mark it claimed and send the tokens.
        _hasClaimed[account] = true;
        IERC20(token).safeTransfer(account, amount);

        emit Claim(account, amount);
    }
}