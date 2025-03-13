{{

  "language": "Solidity",

  "sources": {

    "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Tree proofs.\n *\n * The tree and the proofs can be generated using our\n * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].\n * You will find a quickstart guide in the readme.\n *\n * WARNING: You should avoid using leaf values that are 64 bytes long prior to\n * hashing, or use a hash function other than keccak256 for hashing leaves.\n * This is because the concatenation of a sorted pair of internal nodes in\n * the merkle tree could be reinterpreted as a leaf value.\n * OpenZeppelin's JavaScript library generates merkle trees that are safe\n * against this attack out of the box.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        return processProof(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Calldata version of {verify}\n     *\n     * _Available since v4.7._\n     */\n    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        return processProofCalldata(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\n     * hash matches the root of the tree. When processing the proof, the pairs\n     * of leafs & pre-images are assumed to be sorted.\n     *\n     * _Available since v4.4._\n     */\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Calldata version of {processProof}\n     *\n     * _Available since v4.7._\n     */\n    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by\n     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerify(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProof(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Calldata version of {multiProofVerify}\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerifyCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProofCalldata(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction\n     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another\n     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false\n     * respectively.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree\n     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the\n     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProof(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proof.length - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value for the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i]\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\n                : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            return hashes[totalHashes - 1];\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    /**\n     * @dev Calldata version of {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProofCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proof.length - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value for the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i]\n                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])\n                : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            return hashes[totalHashes - 1];\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {\n        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);\n    }\n\n    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            mstore(0x00, a)\n            mstore(0x20, b)\n            value := keccak256(0x00, 0x40)\n        }\n    }\n}\n"

    },

    "src/FiefdomsMinter.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.17;\n\nimport \"openzeppelin/utils/cryptography/MerkleProof.sol\";\n\ninterface IFiefdomsKingdom {\n    function mintBatch(address to, uint256 amount) external;\n\n    function mint(address to) external;\n\n    function setMinter(address newMinter) external;\n}\n\ncontract FiefdomsMinter {\n    IFiefdomsKingdom public fiefdomsKingdom;\n    address public owner;\n    bytes32 public merkleRoot;\n    bool public isPublicMintable;\n    uint256 public maxPerAllowed;\n    mapping(address => uint256) public claimed;\n\n    constructor(address addr) {\n        owner = msg.sender;\n        maxPerAllowed = 7;\n        fiefdomsKingdom = IFiefdomsKingdom(addr);\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Only owner can call this function\");\n        _;\n    }\n\n    function transferMinter(address newMinter) external onlyOwner {\n        fiefdomsKingdom.setMinter(newMinter);\n    }\n\n    function setMerkleRoot(bytes32 root) external onlyOwner {\n        merkleRoot = root;\n    }\n\n    function setAllowedPerMint(uint256 amount) external onlyOwner {\n        maxPerAllowed = amount;\n    }\n\n    function setPublicMintable(bool isPublic) external onlyOwner {\n        isPublicMintable = isPublic;\n    }\n\n    function mintAllowList(\n        address to,\n        uint256 amount,\n        bytes32[] calldata merkleProof\n    ) external {\n        require(\n            claimed[to] + amount <= maxPerAllowed,\n            \"Exceeds max allowed per address\"\n        );\n        require(verify(to, merkleProof), \"Invalid proof\");\n        claimed[to] += amount;\n        fiefdomsKingdom.mintBatch(to, amount);\n    }\n\n    function mintPublic(address to) external {\n        require(isPublicMintable, \"Public minting is not allowed\");\n        fiefdomsKingdom.mint(to);\n    }\n\n    function mintPublicBatch(address to, uint256 amount) external {\n        require(isPublicMintable, \"Public minting is not allowed\");\n        fiefdomsKingdom.mintBatch(to, amount);\n    }\n\n    function verify(address to, bytes32[] calldata merkleProof)\n        public\n        view\n        returns (bool)\n    {\n        return\n            MerkleProof.verifyCalldata(\n                merkleProof,\n                merkleRoot,\n                keccak256(abi.encodePacked(to))\n            );\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",

      "openzeppelin/=lib/openzeppelin-contracts/contracts/"

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