/**

 *Submitted for verification at Etherscan.io on 2023-07-25

*/



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20 {

    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by

     * a call to {approve}. `value` is the new allowance.

     */

    event Approval(address indexed owner, address indexed spender, uint256 value);



    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `to`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address to, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * Emits an {Approval} event.

     */

    function approve(address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `from` to `to` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



// File: @openzeppelin/contracts/security/ReentrancyGuard.sol



// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)



pragma solidity ^0.8.0;



/**

 * @dev Contract module that helps prevent reentrant calls to a function.

 *

 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier

 * available, which can be applied to functions to make sure there are no nested

 * (reentrant) calls to them.

 *

 * Note that because there is a single `nonReentrant` guard, functions marked as

 * `nonReentrant` may not call one another. This can be worked around by making

 * those functions `private`, and then adding `external` `nonReentrant` entry

 * points to them.

 *

 * TIP: If you would like to learn more about reentrancy and alternative ways

 * to protect against it, check out our blog post

 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].

 */

abstract contract ReentrancyGuard {

    // Booleans are more expensive than uint256 or any type that takes up a full

    // word because each write operation emits an extra SLOAD to first read the

    // slot's contents, replace the bits taken up by the boolean, and then write

    // back. This is the compiler's defense against contract upgrades and

    // pointer aliasing, and it cannot be disabled.



    // The values being non-zero value makes deployment a bit more expensive,

    // but in exchange the refund on every call to nonReentrant will be lower in

    // amount. Since refunds are capped to a percentage of the total

    // transaction's gas, it is best to keep them low in cases like this one, to

    // increase the likelihood of the full refund coming into effect.

    uint256 private constant _NOT_ENTERED = 1;

    uint256 private constant _ENTERED = 2;



    uint256 private _status;



    constructor() {

        _status = _NOT_ENTERED;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and making it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _nonReentrantBefore();

        _;

        _nonReentrantAfter();

    }



    function _nonReentrantBefore() private {

        // On the first call to nonReentrant, _status will be _NOT_ENTERED

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _status = _ENTERED;

    }



    function _nonReentrantAfter() private {

        // By storing the original value once again, a refund is triggered (see

        // https://eips.ethereum.org/EIPS/eip-2200)

        _status = _NOT_ENTERED;

    }



    /**

     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a

     * `nonReentrant` function in the call stack.

     */

    function _reentrancyGuardEntered() internal view returns (bool) {

        return _status == _ENTERED;

    }

}



// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol



// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)



pragma solidity ^0.8.0;



/**

 * @dev These functions deal with verification of Merkle Tree proofs.

 *

 * The tree and the proofs can be generated using our

 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].

 * You will find a quickstart guide in the readme.

 *

 * WARNING: You should avoid using leaf values that are 64 bytes long prior to

 * hashing, or use a hash function other than keccak256 for hashing leaves.

 * This is because the concatenation of a sorted pair of internal nodes in

 * the merkle tree could be reinterpreted as a leaf value.

 * OpenZeppelin's JavaScript library generates merkle trees that are safe

 * against this attack out of the box.

 */

library MerkleProof {

    /**

     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree

     * defined by `root`. For this, a `proof` must be provided, containing

     * sibling hashes on the branch from the leaf to the root of the tree. Each

     * pair of leaves and each pair of pre-images are assumed to be sorted.

     */

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        return processProof(proof, leaf) == root;

    }



    /**

     * @dev Calldata version of {verify}

     *

     * _Available since v4.7._

     */

    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        return processProofCalldata(proof, leaf) == root;

    }



    /**

     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up

     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt

     * hash matches the root of the tree. When processing the proof, the pairs

     * of leafs & pre-images are assumed to be sorted.

     *

     * _Available since v4.4._

     */

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Calldata version of {processProof}

     *

     * _Available since v4.7._

     */

    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by

     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function multiProofVerify(

        bytes32[] memory proof,

        bool[] memory proofFlags,

        bytes32 root,

        bytes32[] memory leaves

    ) internal pure returns (bool) {

        return processMultiProof(proof, proofFlags, leaves) == root;

    }



    /**

     * @dev Calldata version of {multiProofVerify}

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function multiProofVerifyCalldata(

        bytes32[] calldata proof,

        bool[] calldata proofFlags,

        bytes32 root,

        bytes32[] memory leaves

    ) internal pure returns (bool) {

        return processMultiProofCalldata(proof, proofFlags, leaves) == root;

    }



    /**

     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction

     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another

     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false

     * respectively.

     *

     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree

     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the

     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).

     *

     * _Available since v4.7._

     */

    function processMultiProof(

        bytes32[] memory proof,

        bool[] memory proofFlags,

        bytes32[] memory leaves

    ) internal pure returns (bytes32 merkleRoot) {

        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 proofLen = proof.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])

                : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            require(proofPos == proofLen, "MerkleProof: invalid multiproof");

            unchecked {

                return hashes[totalHashes - 1];

            }

        } else if (leavesLen > 0) {

            return leaves[0];

        } else {

            return proof[0];

        }

    }



    /**

     * @dev Calldata version of {processMultiProof}.

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function processMultiProofCalldata(

        bytes32[] calldata proof,

        bool[] calldata proofFlags,

        bytes32[] memory leaves

    ) internal pure returns (bytes32 merkleRoot) {

        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 proofLen = proof.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])

                : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            require(proofPos == proofLen, "MerkleProof: invalid multiproof");

            unchecked {

                return hashes[totalHashes - 1];

            }

        } else if (leavesLen > 0) {

            return leaves[0];

        } else {

            return proof[0];

        }

    }



    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {

        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);

    }



    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        /// @solidity memory-safe-assembly

        assembly {

            mstore(0x00, a)

            mstore(0x20, b)

            value := keccak256(0x00, 0x40)

        }

    }

}



// File: contracts/TokenClaim.sol



pragma solidity ^0.8.14;







contract TokenClaim is ReentrancyGuard {

    error NotAdmin(); // 0x7bfa4b9f

    error InsufficientBalance(); // 0xf4d678b8

    error AlreadyClaimed(); // 0x646cf558

    error WrongProof(); // 0x923983b9

    error ClaimFailed(); // 0x360e42e1

    error EmergencyClaimFailed(); // 0xa89168c5



    event Claimed(address who, uint256 amount);

    event EmergencyClaimed(address who, uint256 amount);

    event MerkleRootChanged(bytes32 newRoot);



    IERC20 public immutable token;

    address public immutable admin;

    bytes32 public merkleRoot;

    uint256 public totalClaimed;



    mapping(address => bool) public claimed;



    modifier onlyAdmin() {

        if (msg.sender != admin) {

            revert NotAdmin();

        }

        _;

    }



    constructor(address admin_, IERC20 token_, bytes32 merkleRoot_) {

        admin = admin_;

        token = token_;

        merkleRoot = merkleRoot_;

    }



    function isClaimedBatch(

        address[] calldata accounts_

    ) external view returns (bool[] memory ret) {

        ret = new bool[](accounts_.length);

        for (uint256 i = 0; i < accounts_.length; ++i) {

            ret[i] = claimed[accounts_[i]];

        }

    }



    function _verify(

        address account,

        uint256 amount,

        bytes32[] calldata proof

    ) internal view returns (bool) {

        bytes32 leaf = keccak256(abi.encodePacked(account, amount));

        return MerkleProof.verify(proof, merkleRoot, leaf);

    }



    function verify(

        address account,

        uint256 amount,

        bytes32[] calldata proof

    ) external view returns (bool) {

        return _verify(account, amount, proof);

    }



    function claim(

        uint256 amount_,

        bytes32[] calldata proof

    ) external nonReentrant {

        if (claimed[msg.sender]) {

            revert AlreadyClaimed();

        }



        if (token.balanceOf(address(this)) < amount_) {

            revert InsufficientBalance();

        }



        if (!_verify(msg.sender, amount_, proof)) {

            revert WrongProof();

        }



        if (!token.transfer(msg.sender, amount_)) {

            revert ClaimFailed();

        }

        claimed[msg.sender] = true;

        totalClaimed += amount_;



        emit Claimed(msg.sender, amount_);

    }



    function setMerkleRoot(bytes32 merkleRoot_) external onlyAdmin {

        merkleRoot = merkleRoot_;

        emit MerkleRootChanged(merkleRoot);

    }



    function emergencyClaim() external onlyAdmin {

        uint256 amount = token.balanceOf(address(this));

        if (!token.transfer(msg.sender, amount)) {

            revert EmergencyClaimFailed();

        }

        emit EmergencyClaimed(msg.sender, amount);

    }

}