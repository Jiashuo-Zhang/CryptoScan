{{

  "language": "Solidity",

  "sources": {

    "lib/openzeppelin-contracts/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"../utils/Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() {\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        _checkOwner();\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the owner.\r\n     */\r\n    function _checkOwner() internal view virtual {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby disabling any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}\r\n"

    },

    "lib/openzeppelin-contracts/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n"

    },

    "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev These functions deal with verification of Merkle Tree proofs.\r\n *\r\n * The tree and the proofs can be generated using our\r\n * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].\r\n * You will find a quickstart guide in the readme.\r\n *\r\n * WARNING: You should avoid using leaf values that are 64 bytes long prior to\r\n * hashing, or use a hash function other than keccak256 for hashing leaves.\r\n * This is because the concatenation of a sorted pair of internal nodes in\r\n * the merkle tree could be reinterpreted as a leaf value.\r\n * OpenZeppelin's JavaScript library generates merkle trees that are safe\r\n * against this attack out of the box.\r\n */\r\nlibrary MerkleProof {\r\n    /**\r\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\r\n     * defined by `root`. For this, a `proof` must be provided, containing\r\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\r\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\r\n     */\r\n    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\r\n        return processProof(proof, leaf) == root;\r\n    }\r\n\r\n    /**\r\n     * @dev Calldata version of {verify}\r\n     *\r\n     * _Available since v4.7._\r\n     */\r\n    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\r\n        return processProofCalldata(proof, leaf) == root;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up\r\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\r\n     * hash matches the root of the tree. When processing the proof, the pairs\r\n     * of leafs & pre-images are assumed to be sorted.\r\n     *\r\n     * _Available since v4.4._\r\n     */\r\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\r\n        bytes32 computedHash = leaf;\r\n        for (uint256 i = 0; i < proof.length; i++) {\r\n            computedHash = _hashPair(computedHash, proof[i]);\r\n        }\r\n        return computedHash;\r\n    }\r\n\r\n    /**\r\n     * @dev Calldata version of {processProof}\r\n     *\r\n     * _Available since v4.7._\r\n     */\r\n    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {\r\n        bytes32 computedHash = leaf;\r\n        for (uint256 i = 0; i < proof.length; i++) {\r\n            computedHash = _hashPair(computedHash, proof[i]);\r\n        }\r\n        return computedHash;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by\r\n     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.\r\n     *\r\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\r\n     *\r\n     * _Available since v4.7._\r\n     */\r\n    function multiProofVerify(\r\n        bytes32[] memory proof,\r\n        bool[] memory proofFlags,\r\n        bytes32 root,\r\n        bytes32[] memory leaves\r\n    ) internal pure returns (bool) {\r\n        return processMultiProof(proof, proofFlags, leaves) == root;\r\n    }\r\n\r\n    /**\r\n     * @dev Calldata version of {multiProofVerify}\r\n     *\r\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\r\n     *\r\n     * _Available since v4.7._\r\n     */\r\n    function multiProofVerifyCalldata(\r\n        bytes32[] calldata proof,\r\n        bool[] calldata proofFlags,\r\n        bytes32 root,\r\n        bytes32[] memory leaves\r\n    ) internal pure returns (bool) {\r\n        return processMultiProofCalldata(proof, proofFlags, leaves) == root;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction\r\n     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another\r\n     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false\r\n     * respectively.\r\n     *\r\n     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree\r\n     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the\r\n     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).\r\n     *\r\n     * _Available since v4.7._\r\n     */\r\n    function processMultiProof(\r\n        bytes32[] memory proof,\r\n        bool[] memory proofFlags,\r\n        bytes32[] memory leaves\r\n    ) internal pure returns (bytes32 merkleRoot) {\r\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\r\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\r\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\r\n        // the merkle tree.\r\n        uint256 leavesLen = leaves.length;\r\n        uint256 totalHashes = proofFlags.length;\r\n\r\n        // Check proof validity.\r\n        require(leavesLen + proof.length - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\r\n\r\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\r\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\r\n        bytes32[] memory hashes = new bytes32[](totalHashes);\r\n        uint256 leafPos = 0;\r\n        uint256 hashPos = 0;\r\n        uint256 proofPos = 0;\r\n        // At each step, we compute the next hash using two values:\r\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\r\n        //   get the next hash.\r\n        // - depending on the flag, either another value from the \"main queue\" (merging branches) or an element from the\r\n        //   `proof` array.\r\n        for (uint256 i = 0; i < totalHashes; i++) {\r\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\r\n            bytes32 b = proofFlags[i]\r\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\r\n                : proof[proofPos++];\r\n            hashes[i] = _hashPair(a, b);\r\n        }\r\n\r\n        if (totalHashes > 0) {\r\n            unchecked {\r\n                return hashes[totalHashes - 1];\r\n            }\r\n        } else if (leavesLen > 0) {\r\n            return leaves[0];\r\n        } else {\r\n            return proof[0];\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Calldata version of {processMultiProof}.\r\n     *\r\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\r\n     *\r\n     * _Available since v4.7._\r\n     */\r\n    function processMultiProofCalldata(\r\n        bytes32[] calldata proof,\r\n        bool[] calldata proofFlags,\r\n        bytes32[] memory leaves\r\n    ) internal pure returns (bytes32 merkleRoot) {\r\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\r\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\r\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\r\n        // the merkle tree.\r\n        uint256 leavesLen = leaves.length;\r\n        uint256 totalHashes = proofFlags.length;\r\n\r\n        // Check proof validity.\r\n        require(leavesLen + proof.length - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\r\n\r\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\r\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\r\n        bytes32[] memory hashes = new bytes32[](totalHashes);\r\n        uint256 leafPos = 0;\r\n        uint256 hashPos = 0;\r\n        uint256 proofPos = 0;\r\n        // At each step, we compute the next hash using two values:\r\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\r\n        //   get the next hash.\r\n        // - depending on the flag, either another value from the \"main queue\" (merging branches) or an element from the\r\n        //   `proof` array.\r\n        for (uint256 i = 0; i < totalHashes; i++) {\r\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\r\n            bytes32 b = proofFlags[i]\r\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\r\n                : proof[proofPos++];\r\n            hashes[i] = _hashPair(a, b);\r\n        }\r\n\r\n        if (totalHashes > 0) {\r\n            unchecked {\r\n                return hashes[totalHashes - 1];\r\n            }\r\n        } else if (leavesLen > 0) {\r\n            return leaves[0];\r\n        } else {\r\n            return proof[0];\r\n        }\r\n    }\r\n\r\n    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {\r\n        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);\r\n    }\r\n\r\n    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {\r\n        /// @solidity memory-safe-assembly\r\n        assembly {\r\n            mstore(0x00, a)\r\n            mstore(0x20, b)\r\n            value := keccak256(0x00, 0x40)\r\n        }\r\n    }\r\n}\r\n"

    },

    "src/KidzukiDistributor.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.13;\r\n\r\nimport \"openzeppelin-contracts/utils/cryptography/MerkleProof.sol\";\r\nimport \"openzeppelin-contracts/access/Ownable.sol\";\r\n\r\ncontract KidzukiDistributor is Ownable {\r\n\r\n    uint256 public SUPPLY_DISTRIBUTE = 5555;\r\n    uint256 public DEPOSIT_ETH_DISTRIBUTION;\r\n    bytes32 public distroMerkle;\r\n    bool public claimPaused = true;\r\n\r\n    mapping(address => bool) public userPaid;\r\n    \r\n    function claim(uint256 amountToClaim, bytes32[] calldata _merkleProof) external {\r\n        require(!claimPaused, \"Claim not open\");\r\n        address _caller = _msgSender();\r\n        require(!userPaid[_caller], \"Already claimed\");\r\n\r\n        bytes32 leaf = keccak256(abi.encodePacked(_caller, amountToClaim));\r\n        require(MerkleProof.verify(_merkleProof, distroMerkle, leaf), \"Invalid proof\");\r\n\r\n        userPaid[_caller] = true;\r\n\r\n        (bool success, ) = payable(_caller).call{value: calculatePayment(amountToClaim)}(\"\");\r\n        require(success, \"Failed to send\");\r\n    }\r\n\r\n    function calculatePayment(uint256 amountToClaim) public view returns(uint256) {\r\n        require(DEPOSIT_ETH_DISTRIBUTION > 0, \"No deposit\");\r\n        return ( DEPOSIT_ETH_DISTRIBUTION / SUPPLY_DISTRIBUTE ) * amountToClaim;\r\n    }\r\n\r\n    function makeDeposit() external payable {\r\n        require(claimPaused, \"Claim is open\");\r\n        DEPOSIT_ETH_DISTRIBUTION += msg.value;\r\n    }\r\n\r\n    function changeDeposit(uint256 _deposit) external onlyOwner {\r\n        DEPOSIT_ETH_DISTRIBUTION = _deposit;\r\n    }\r\n\r\n    function setSupply(uint256 _supply) external onlyOwner {\r\n        SUPPLY_DISTRIBUTE = _supply;\r\n    }\r\n\r\n    function setMerkle(bytes32 _merkle) external onlyOwner {\r\n        distroMerkle = _merkle;\r\n    }\r\n\r\n    function toggleClaim() external onlyOwner {\r\n        claimPaused = !claimPaused;\r\n    }\r\n\r\n    function withdrawDeposit() external onlyOwner {\r\n\r\n        DEPOSIT_ETH_DISTRIBUTION = 0;\r\n        claimPaused = true;\r\n\r\n        uint256 balance = address(this).balance;\r\n        (bool success, ) = payable(owner()).call{value: balance}(\"\");\r\n        require(success, \"Failed to send\");\r\n    }\r\n\r\n}"

    }

  },

  "settings": {

    "remappings": [

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "bytecodeHash": "ipfs"

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "evmVersion": "london",

    "libraries": {}

  }

}}