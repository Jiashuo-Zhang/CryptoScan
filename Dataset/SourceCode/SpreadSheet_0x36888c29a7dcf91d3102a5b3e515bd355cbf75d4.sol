// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { Pausable } from "@openzeppelin/security/Pausable.sol";
import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";

/**
 *
 *     _____                          _ _____ _               _
 *    /  ___|                        | /  ___| |             | |
 *    \ `--. _ __  _ __ ___  __ _  __| \ `--.| |__   ___  ___| |_
 *     `--. \ '_ \| '__/ _ \/ _` |/ _` |`--. \ '_ \ / _ \/ _ \ __|
 *    /\__/ / |_) | | |  __/ (_| | (_| /\__/ / | | |  __/  __/ |_
 *    \____/| .__/|_|  \___|\__,_|\__,_\____/|_| |_|\___|\___|\__|
 *          | |
 *          |_|
 */

/// @title SpreadSheet
/// @notice Handles the claim and distribution of SHEETs.
contract SpreadSheet is Ownable, Pausable {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the number of SHEETs an allocatee is trying to claim exceeds their allocation amount.
    ///
    /// @param allocatee The account that is trying to claim SHEETs.
    /// @param allocation The total number of SHEETs allocated to the allocatee.
    /// @param totalClaimedAfter The total number of SHEETs the allocatee is trying to have after claiming.
    error SpreadSheet__AllocationExceeded(address allocatee, uint256 allocation, uint256 totalClaimedAfter);

    /// @notice Thrown when the provided transition Merkle proof is invalid.
    ///
    /// @param sheetId The ID of the SHEET linked with the provided proof.
    /// @param botsId The ID of the BOT linked with the provided proof.
    error SpreadSheet__InvalidTransitionProof(uint256 sheetId, uint256 botsId);

    /// @notice Thrown when the provided allocation Merkle proof is invalid.
    ///
    /// @param allocatee The allocatee account linked with the provided proof.
    /// @param allocation The allocation amount linked with the provided proof.
    error SpreadSheet__InvalidAllocationProof(address allocatee, uint256 allocation);

    /// @notice Thrown when the provided allocation sheet ID is invalid.
    ///
    /// @param sheetId The provided allocation sheet ID.
    error SpreadSheet__InvalidAllocationSheetId(uint256 sheetId);

    /// @notice Thrown when the provided inputs are not of the same length.
    error SpreadSheet__MismatchedInputs();

    /// @notice Thrown when the caller is trying to claim 0 SHEETs.
    error SpreadSheet__ZeroClaim();

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when claiming SHEETs in exchange for burning BOTS.
    /// @param claimer The account that claimed the SHEETs.
    /// @param sheetIds The IDs of the SHEETs that were claimed.
    /// @param botsIds The IDs of the BOTS that were burned.
    event ClaimSheetsViaTransition(address indexed claimer, uint256[] sheetIds, uint256[] botsIds);

    /// @notice Emitted when claiming SHEETs that were allocated to the caller account.
    /// @param claimer The account that claimed the SHEETs.
    /// @param sheetIds The IDs of the SHEETs that were claimed.
    /// @param allocation The total number of SHEETs allocated to the caller.
    event ClaimSheetsViaAllocation(address indexed claimer, uint256[] sheetIds, uint256 allocation);

    /// @notice Emitted when the owner withdraws SHEETs from the contract.
    /// @param recipient The account that received the SHEETs.
    /// @param sheetIds The IDs of the SHEETs that were withdrawn.
    event AdminWithdraw(address indexed recipient, uint256[] sheetIds);

    /// @notice Emitted when the owner pauses the claim process.
    event PauseClaims();

    /// @notice Emitted when the owner unpauses the claim process.
    event UnpauseClaims();

    /// @notice Emitted when the transition Merkle root is set.
    /// @param newTransitionMerkleRoot The new transition Merkle root.
    event SetTransitionMerkleRoot(bytes32 newTransitionMerkleRoot);

    /// @notice Emitted when the allocation Merkle root is set.
    /// @param newAllocationMerkleRoot The new allocation Merkle root.
    event SetAllocationMerkleRoot(bytes32 newAllocationMerkleRoot);

    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The Sheetheads NFT contract whose tokens are to be distributed.
    IERC721 public immutable sheetNFT;

    /// @notice The Pawn Bots NFT contract whose tokens are to be burned.
    IERC721 public immutable botsNFT;

    /// @notice The ID of the first SHEET to be allocated.
    /// @dev Allocated IDs are contiguous.
    uint256 public immutable allocationSheetIdStart;

    /// @notice The Merkle root of the BOTS -> SHEET transition Merkle tree.
    bytes32 public transitionMerkleRoot;

    /// @notice The Merkle root of the SHEET allocation Merkle tree.
    bytes32 public allocationMerkleRoot;

    /// @notice The total number of SHEETs claimed by an allocatee.
    mapping(address => uint256) public totalClaimed;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param sheetNFT_ The Sheetheads NFT contract whose tokens are to be distributed.
    /// @param botsNFT_ The Pawn Bots NFT contract whose tokens are to be burned.
    /// @param allocationSheetIdStart_ The ID of the first SHEET to be allocated.
    constructor(IERC721 sheetNFT_, IERC721 botsNFT_, uint256 allocationSheetIdStart_) {
        sheetNFT = sheetNFT_;
        botsNFT = botsNFT_;
        allocationSheetIdStart = allocationSheetIdStart_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Claim SHEETs in exchange for burning BOTS and/or claiming SHEETs that were allocated to the caller.
    ///
    /// @param sheetIdsToClaimViaTransition The IDs of the SHEETs to claim via transition.
    /// @param sheetIdsToClaimViaAllocation The IDs of the SHEETs to claim via allocation.
    /// @param botsIdsToBurnViaTransition The IDs of the BOTS to burn via transition.
    /// @param allocationAmount The total number of SHEETs allocated to the caller.
    /// @param transitionProofs The Merkle proofs for verifying transition claims.
    /// @param allocationProof The Merkle proof for verifying the allocation claim.
    function claimSheets(
        uint256[] calldata sheetIdsToClaimViaTransition,
        uint256[] calldata sheetIdsToClaimViaAllocation,
        uint256[] calldata botsIdsToBurnViaTransition,
        uint256 allocationAmount,
        bytes32[][] calldata transitionProofs,
        bytes32[] calldata allocationProof
    )
        external
    {
        if (sheetIdsToClaimViaTransition.length > 0) {
            claimSheetsViaTransition({
                sheetIdsToClaim: sheetIdsToClaimViaTransition,
                botsIdsToBurn: botsIdsToBurnViaTransition,
                transitionProofs: transitionProofs
            });
        }
        if (sheetIdsToClaimViaAllocation.length > 0) {
            claimSheetsViaAllocation({
                sheetIdsToClaim: sheetIdsToClaimViaAllocation,
                allocation: allocationAmount,
                allocationProof: allocationProof
            });
        }
    }

    /// @notice Claim SHEETs in exchange for burning BOTS.
    ///
    /// @dev Emits a {ClaimSheetsViaTransition} event.
    ///
    /// Requirements:
    /// - All provided inputs must be the same length.
    /// - The number of SHEETs to claim must be greater than 0.
    /// - Each provided transition Merkle proof must be valid.
    /// - The caller must own all of the BOTS IDs to burn.
    ///
    /// @param sheetIdsToClaim The IDs of the SHEETs to claim.
    /// @param botsIdsToBurn The IDs of the BOTS to burn.
    /// @param transitionProofs The Merkle proofs for verifying transition claims.
    function claimSheetsViaTransition(
        uint256[] calldata sheetIdsToClaim,
        uint256[] calldata botsIdsToBurn,
        bytes32[][] calldata transitionProofs
    )
        public
        whenNotPaused
    {
        if (sheetIdsToClaim.length != botsIdsToBurn.length || sheetIdsToClaim.length != transitionProofs.length) {
            revert SpreadSheet__MismatchedInputs();
        }
        if (sheetIdsToClaim.length == 0) {
            revert SpreadSheet__ZeroClaim();
        }
        for (uint256 i = 0; i < sheetIdsToClaim.length; i++) {
            if (
                !MerkleProof.verify({
                    proof: transitionProofs[i],
                    root: transitionMerkleRoot,
                    leaf: keccak256(abi.encodePacked(botsIdsToBurn[i], sheetIdsToClaim[i]))
                })
            ) {
                revert SpreadSheet__InvalidTransitionProof({ sheetId: sheetIdsToClaim[i], botsId: botsIdsToBurn[i] });
            }
            botsNFT.transferFrom({ from: msg.sender, to: address(0xdead), tokenId: botsIdsToBurn[i] });
            sheetNFT.transferFrom({ from: address(this), to: msg.sender, tokenId: sheetIdsToClaim[i] });
        }
        emit ClaimSheetsViaTransition({ claimer: msg.sender, sheetIds: sheetIdsToClaim, botsIds: botsIdsToBurn });
    }

    /// @notice Claim SHEETs that were allocated to the caller account.
    ///
    /// @dev Emits a {ClaimSheetsViaAllocation} event.
    ///
    /// Requirements:
    /// - All provided inputs must be the same length.
    /// - The number of SHEETs to claim must be greater than 0.
    /// - The provided allocation Merkle proof must be valid.
    /// - The number of SHEETs to claim must not exceed the number of SHEETs allocated to the caller account.
    /// - Each provided allocation reserve Merkle proof must be valid.
    ///
    /// @param sheetIdsToClaim The IDs of the SHEETs to claim.
    /// @param allocation The total number of SHEETs allocated to the caller.
    /// @param allocationProof The Merkle proof for verifying the allocation claim.
    function claimSheetsViaAllocation(
        uint256[] calldata sheetIdsToClaim,
        uint256 allocation,
        bytes32[] calldata allocationProof
    )
        public
        whenNotPaused
    {
        if (sheetIdsToClaim.length == 0) {
            revert SpreadSheet__ZeroClaim();
        }
        if (
            !MerkleProof.verify({
                proof: allocationProof,
                root: allocationMerkleRoot,
                leaf: keccak256(abi.encodePacked(msg.sender, allocation))
            })
        ) {
            revert SpreadSheet__InvalidAllocationProof({ allocatee: msg.sender, allocation: allocation });
        }
        uint256 totalClaimedAfter = sheetIdsToClaim.length + totalClaimed[msg.sender];
        if (totalClaimedAfter > allocation) {
            revert SpreadSheet__AllocationExceeded({
                allocatee: msg.sender,
                allocation: allocation,
                totalClaimedAfter: totalClaimedAfter
            });
        }
        totalClaimed[msg.sender] = totalClaimedAfter;
        for (uint256 i = 0; i < sheetIdsToClaim.length; i++) {
            if (sheetIdsToClaim[i] < allocationSheetIdStart) {
                revert SpreadSheet__InvalidAllocationSheetId(sheetIdsToClaim[i]);
            }
            sheetNFT.transferFrom({ from: address(this), to: msg.sender, tokenId: sheetIdsToClaim[i] });
        }
        emit ClaimSheetsViaAllocation({ claimer: msg.sender, sheetIds: sheetIdsToClaim, allocation: allocation });
    }

    /// @notice Withdraw SHEETs from the contract.
    ///
    /// @dev Emits a {AdminWithdraw} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param recipient The address to withdraw to.
    /// @param sheetIds The IDs of the SHEETs to withdraw.
    function adminWithdraw(address recipient, uint256[] calldata sheetIds) external onlyOwner whenPaused {
        for (uint256 i = 0; i < sheetIds.length; i++) {
            sheetNFT.transferFrom({ from: address(this), to: recipient, tokenId: sheetIds[i] });
        }
        emit AdminWithdraw({ recipient: recipient, sheetIds: sheetIds });
    }

    /// @notice Pause the claim process.
    ///
    /// @dev Emits a {PauseClaims} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    function pauseClaims() external onlyOwner {
        _pause();
        emit PauseClaims();
    }

    /// @notice Unpause the claim process.
    ///
    /// @dev Emits an {UnpauseClaims} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    function unpauseClaims() external onlyOwner {
        _unpause();
        emit UnpauseClaims();
    }

    /// @notice Set the Merkle root of the BOTS -> SHEET transition Merkle tree.
    ///
    /// @dev Emits a {SetTransitionMerkleRoot} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param newTransitionMerkleRoot The new transition Merkle root.
    function setTransitionMerkleRoot(bytes32 newTransitionMerkleRoot) external onlyOwner {
        transitionMerkleRoot = newTransitionMerkleRoot;
        emit SetTransitionMerkleRoot(newTransitionMerkleRoot);
    }

    /// @notice Set the Merkle root of the SHEET allocation Merkle tree.
    ///
    /// @dev Emits a {SetAllocationMerkleRoot} event.
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    /// @param newAllocationMerkleRoot The new allocation Merkle root.
    function setAllocationMerkleRoot(bytes32 newAllocationMerkleRoot) external onlyOwner {
        allocationMerkleRoot = newAllocationMerkleRoot;
        emit SetAllocationMerkleRoot(newAllocationMerkleRoot);
    }
}