// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

//import "hardhat/console.sol";

/// @title Interface to interact with Bubbles contract.
interface IBubbles {
    function mint(address recipient, uint256 amount) external;
}

/// @author The Axolittles Team
/// @title Contract for claiming Bubbles airdrops
contract BubblesAirdrop is Ownable {
    address public TOKEN;
    bytes32 public merkleRoot;
    uint256 public version;

    struct recipient {
        address user;
        uint256 amount;
    }

    mapping(uint256 => mapping(address => bool)) internal claimed;

    constructor(address _tokenAddress) {
        TOKEN = _tokenAddress;
    }

    event ClaimAirdrop(
        address indexed owner,
        uint256 rewardAmount,
        uint256 version
    );
    event SendAirdrop(address indexed owner, uint256 rewardAmount);

    /**
    todo: claim migration rewards function
    pass in data via merkle root in format of addreess/$BUBBLE owed
    keep mapping(address => bool) rewardsTracker to track who has claimed already
  */
    function claimAirdrop(uint256 _amount, bytes32[] calldata merkleProof)
        external
    {
        require(!claimed[version][msg.sender], "Already claimed!");
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _amount)); //check both address and amount
        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            "Verification failed!"
        );
        claimed[version][msg.sender] = true;
        IBubbles(TOKEN).mint(msg.sender, _amount);
        emit ClaimAirdrop(msg.sender, _amount, version);
    }

    //for admin to airdrop $BUBBLE to recipients
    function sendAirdrop(recipient[] memory _recipients) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            IBubbles(TOKEN).mint(_recipients[i].user, _recipients[i].amount);
            emit SendAirdrop(_recipients[i].user, _recipients[i].amount);
        }
    }

    /// @notice Function to change address of reward token
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        TOKEN = _tokenAddress;
    }

    /// @notice Function to set new merkle root
    function setMerkleRoot(bytes32 _root) external onlyOwner {
        merkleRoot = _root;
        version = version + 1;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}