// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../interfaces/IIdentityTree.sol";
import "../degradable/Degradable.sol";
import "../lib/Bytes32Set.sol";

/**
 @notice This contract holds the history of identity tree merkle roots announced by the aggregator. 
 Each root has an associated birthday that records when it was created. Zero-knowledge proofs rely
 on these roots. Claims supported by proofs are considered to be of the same age as the roots they
 rely on for validity. 
 */

contract IdentityTree is IIdentityTree, Degradable { 

    using Bytes32Set for Bytes32Set.Set;

    uint256 private constant INFINITY = ~uint256(0);
    address private constant NULL_ADDRESS = address(0);
    bytes32 private constant NULL_BYTES32 = bytes32(0);
    bytes32 public constant override ROLE_AGGREGATOR = keccak256("aggregator role");

    Bytes32Set.Set merkleRootSet;

    modifier onlyAggregator() {
        _checkRole(ROLE_AGGREGATOR, _msgSender(), "IdentityTree::onlyAggregator");
        _;
    }

    /**
     * @param trustedForwarder_ Contract address that is allowed to relay message signers.
     * @param policyManager_ The policy manager contract address.
     * @param maximumConsentPeriod_ The maximum allowable user consent period.
     */
    constructor(
        address trustedForwarder_,
        address policyManager_,
        uint256 maximumConsentPeriod_
    ) 
        Degradable(
            trustedForwarder_,
            policyManager_,
            maximumConsentPeriod_
        ) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit Deployed(_msgSender(), trustedForwarder_, policyManager_, maximumConsentPeriod);
    }

    /**
     * @notice The aggregator can set roots with non-zero birthdays.
     * @dev Explicit birthday declaration ensures that root age is not extended by mining delays. 
     * @param merkleRoot The merkleRoot to set.
     * @param birthday The timestamp of the merkleRoot. 0 to invalidate the root.
     */
    function setMerkleRootBirthday(bytes32 merkleRoot, uint256 birthday) external override onlyAggregator {
        if (birthday > block.timestamp)
            revert Unacceptable({
                reason: "birthday cannot be in the future"
            });
        if (merkleRoot == NULL_BYTES32)
            revert Unacceptable({
                reason: "merkle root cannot be empty"
            });
        if (birthday < lastUpdate) 
            revert Unacceptable({
                reason: "birthday precedes previously recorded birthday"
            });
        _recordUpdate(merkleRoot, birthday);
        merkleRootSet.insert(merkleRoot, "IdentityTree::setMerkleRoot");
        emit SetMerkleRootBirthday(merkleRoot, birthday);
    }

    /**
     * @notice Inspect the Identity Tree
     * @dev Use static calls to inspect.
     * @param observer The observer for degradation mitigation consent. 
     * @param merkleRoot The merkle root to inspect. 
     * @param admissionPolicyId The admission policy for the credential to inspect.
     * @return passed True if a valid merkle root exists or if mitigation measures are applicable.
     */
    function checkRoot(
        address observer, 
        bytes32 merkleRoot,
        uint32 admissionPolicyId
    ) external override returns (bool passed) {
        
        passed = _checkKey(
            observer,
            merkleRoot,
            admissionPolicyId
        );
    }

    /**
     * @return count The number of merkle roots recorded since the beginning
     */
    function merkleRootCount() public view override returns (uint256 count) {
        count = merkleRootSet.count();
    }

    /**
     * @notice Enumerate the recorded merkle roots.
     * @param index Row to return.
     * @return merkleRoot The root stored at the row.
     */
    function merkleRootAtIndex(uint256 index) external view override returns (bytes32 merkleRoot) {
        if (index >= merkleRootSet.count())
            revert Unacceptable({
                reason: "index"
            });
        merkleRoot = merkleRootSet.keyAtIndex(index);
    }

    /**
     * @notice Check for existence in history.
     * @param merkleRoot The root to check.
     * @return isIndeed True if the root has been recorded.
     */
    function isMerkleRoot(bytes32 merkleRoot) external view override returns (bool isIndeed) {
        isIndeed = merkleRootSet.exists(merkleRoot);
    }

    /**
     @notice Return the lastest merkle root recorded. 
     @return root The latest merkle root recorded.
     */
    function latestRoot() external view override returns (bytes32 root) {
        if (merkleRootSet.count() > 0) {
            root= merkleRootSet.keyAtIndex(merkleRootSet.count() - 1);
        }
    }
}