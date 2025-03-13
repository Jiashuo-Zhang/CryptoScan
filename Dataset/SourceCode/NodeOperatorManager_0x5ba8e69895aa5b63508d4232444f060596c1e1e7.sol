{{

  "language": "Solidity",

  "sources": {

    "src/NodeOperatorManager.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.13;\n\nimport \"../src/interfaces/INodeOperatorManager.sol\";\nimport \"../src/interfaces/IAuctionManager.sol\";\nimport \"@openzeppelin/contracts/utils/cryptography/MerkleProof.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract NodeOperatorManager is INodeOperatorManager, Ownable {\n    //--------------------------------------------------------------------------------------\n    //-------------------------------------  EVENTS  ---------------------------------------\n    //--------------------------------------------------------------------------------------\n\n    event OperatorRegistered(uint64 totalKeys, uint64 keysUsed, bytes ipfsHash);\n    event MerkleUpdated(bytes32 oldMerkle, bytes32 indexed newMerkle);\n\n    //--------------------------------------------------------------------------------------\n    //---------------------------------  STATE-VARIABLES  ----------------------------------\n    //--------------------------------------------------------------------------------------\n\n    address public auctionManagerContractAddress;\n    bytes32 public merkleRoot;\n\n    // user address => OperaterData Struct\n    mapping(address => KeyData) public addressToOperatorData;\n    mapping(address => bool) private whitelistedAddresses;\n    mapping(address => bool) public registered;\n\n    //--------------------------------------------------------------------------------------\n    //----------------------------  STATE-CHANGING FUNCTIONS  ------------------------------\n    //--------------------------------------------------------------------------------------\n\n    /// @notice Registers a user as a operator to allow them to bid\n    /// @param _merkleProof the proof verifying they are whitelisted\n    /// @param _ipfsHash location of all IPFS data stored for operator\n    /// @param _totalKeys The number of keys they have available, relates to how many validators they can run\n    function registerNodeOperator(\n        bytes32[] calldata _merkleProof,\n        bytes memory _ipfsHash,\n        uint64 _totalKeys\n    ) public {\n        require(!registered[msg.sender], \"Already registered\");\n        \n        KeyData memory keyData = KeyData({\n            totalKeys: _totalKeys,\n            keysUsed: 0,\n            ipfsHash: abi.encodePacked(_ipfsHash)\n        });\n\n        addressToOperatorData[msg.sender] = keyData;\n\n        _verifyWhitelistedAddress(msg.sender, _merkleProof);\n        registered[msg.sender] = true;\n        emit OperatorRegistered(\n            keyData.totalKeys,\n            keyData.keysUsed,\n            _ipfsHash\n        );\n    }\n\n    /// @notice Fetches the next key they have available to use\n    /// @param _user the user to fetch the key for\n    /// @return the ipfs index available for the validator\n    function fetchNextKeyIndex(\n        address _user\n    ) external onlyAuctionManagerContract returns (uint64) {\n        KeyData storage keyData = addressToOperatorData[_user];\n        uint64 totalKeys = keyData.totalKeys;\n        require(\n            keyData.keysUsed < totalKeys,\n            \"Insufficient public keys\"\n        );\n\n        uint64 ipfsIndex = keyData.keysUsed;\n        keyData.keysUsed++;\n        return ipfsIndex;\n    }\n\n    /// @notice Updates the merkle root whitelists have been updated\n    /// @dev merkleroot gets generated in JS offline and sent to the contract\n    /// @param _newMerkle new merkle root to be used for bidding\n    function updateMerkleRoot(bytes32 _newMerkle) external onlyOwner {\n        bytes32 oldMerkle = merkleRoot;\n        merkleRoot = _newMerkle;\n\n        emit MerkleUpdated(oldMerkle, _newMerkle);\n    }\n\n    //--------------------------------------------------------------------------------------\n    //-----------------------------------  GETTERS   ---------------------------------------\n    //--------------------------------------------------------------------------------------\n\n    /// @notice gets the number of keys the user has, used or un-used\n    /// @param _user the user to fetch the data for\n    /// @return totalKeys the number of keys the user has\n    function getUserTotalKeys(\n        address _user\n    ) external view returns (uint64 totalKeys) {\n        totalKeys = addressToOperatorData[_user].totalKeys;\n    }\n\n    /// @notice gets the number of keys the user has left to use\n    /// @param _user the user to fetch the data for\n    /// @return numKeysRemaining the number of keys the user has remaining\n    function getNumKeysRemaining(\n        address _user\n    ) external view returns (uint64 numKeysRemaining) {\n        KeyData storage keyData = addressToOperatorData[_user];\n\n        numKeysRemaining =\n            keyData.totalKeys - keyData.keysUsed;\n    }\n\n    /// @notice gets if the user is whitelisted\n    /// @dev used in the auction contract to verify when a user bids that they are indeed whitelisted\n    /// @param _user the user to fetch the data for\n    /// @return whitelisted bool value if they are whitelisted or not\n    function isWhitelisted(\n        address _user\n    ) public view returns (bool whitelisted) {\n        whitelisted = whitelistedAddresses[_user];\n    }\n\n    //--------------------------------------------------------------------------------------\n    //-----------------------------------  SETTERS   ---------------------------------------\n    //--------------------------------------------------------------------------------------\n\n    /// @notice Sets the auction contract address for verification purposes\n    /// @dev Set manually due to circular dependencies\n    /// @param _auctionContractAddress address of the deployed auction contract address\n    function setAuctionContractAddress(\n        address _auctionContractAddress\n    ) public onlyOwner {\n        require(auctionManagerContractAddress == address(0), \"Address already set\");\n        require(_auctionContractAddress != address(0), \"No zero addresses\");\n        auctionManagerContractAddress = _auctionContractAddress;\n    }\n\n    //--------------------------------------------------------------------------------------\n    //-------------------------------  INTERNAL FUNCTIONS   --------------------------------\n    //--------------------------------------------------------------------------------------\n\n    function _verifyWhitelistedAddress(\n        address _user,\n        bytes32[] calldata _merkleProof\n    ) internal returns (bool whitelisted) {\n        whitelisted = MerkleProof.verify(\n            _merkleProof,\n            merkleRoot,\n            keccak256(abi.encodePacked(_user))\n        );\n        if (whitelisted) {\n            whitelistedAddresses[_user] = true;\n        }\n    }\n\n    //--------------------------------------------------------------------------------------\n    //-----------------------------------  MODIFIERS  --------------------------------------\n    //--------------------------------------------------------------------------------------\n\n    modifier onlyAuctionManagerContract() {\n        require(\n            msg.sender == auctionManagerContractAddress,\n            \"Only auction manager contract function\"\n        );\n        _;\n    }\n}\n"

    },

    "src/interfaces/INodeOperatorManager.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.13;\n\ninterface INodeOperatorManager {\n    struct KeyData {\n        uint64 totalKeys;\n        uint64 keysUsed;\n        bytes ipfsHash;\n    }\n\n    function getUserTotalKeys(\n        address _user\n    ) external view returns (uint64 totalKeys);\n\n    function getNumKeysRemaining(\n        address _user\n    ) external view returns (uint64 numKeysRemaining);\n\n    function isWhitelisted(\n        address _user\n    ) external view returns (bool whitelisted);\n\n    function registerNodeOperator(\n        bytes32[] calldata _merkleProof,\n        bytes memory ipfsHash,\n        uint64 totalKeys\n    ) external;\n\n    function fetchNextKeyIndex(address _user) external returns (uint64);\n}\n"

    },

    "src/interfaces/IAuctionManager.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.13;\n\ninterface IAuctionManager {\n    struct Bid {\n        uint256 amount;\n        uint64 bidderPubKeyIndex;\n        address bidderAddress;\n        bool isActive;\n    }\n\n    function initialize(address _nodeOperatorManagerContract) external;\n\n    function getBidOwner(uint256 _bidId) external view returns (address);\n\n    function numberOfActiveBids() external view returns (uint256);\n\n    function isBidActive(uint256 _bidId) external view returns (bool);\n\n    function createBid(\n        uint256 _bidSize,\n        uint256 _bidAmount\n    ) external payable returns (uint256[] memory);\n\n    function cancelBidBatch(uint256[] calldata _bidIds) external;\n\n    function cancelBid(uint256 _bidId) external;\n\n    function reEnterAuction(uint256 _bidId) external;\n\n    function updateSelectedBidInformation(uint256 _bidId) external;\n\n    function processAuctionFeeTransfer(uint256 _validatorId) external;\n\n    function setStakingManagerContractAddress(\n        address _stakingManagerContractAddress\n    ) external;\n\n    function setProtocolRevenueManager(\n        address _protocolRevenueManager\n    ) external;\n}\n"

    },

    "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Tree proofs.\n *\n * The tree and the proofs can be generated using our\n * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].\n * You will find a quickstart guide in the readme.\n *\n * WARNING: You should avoid using leaf values that are 64 bytes long prior to\n * hashing, or use a hash function other than keccak256 for hashing leaves.\n * This is because the concatenation of a sorted pair of internal nodes in\n * the merkle tree could be reinterpreted as a leaf value.\n * OpenZeppelin's JavaScript library generates merkle trees that are safe\n * against this attack out of the box.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(\n        bytes32[] memory proof,\n        bytes32 root,\n        bytes32 leaf\n    ) internal pure returns (bool) {\n        return processProof(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Calldata version of {verify}\n     *\n     * _Available since v4.7._\n     */\n    function verifyCalldata(\n        bytes32[] calldata proof,\n        bytes32 root,\n        bytes32 leaf\n    ) internal pure returns (bool) {\n        return processProofCalldata(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\n     * hash matches the root of the tree. When processing the proof, the pairs\n     * of leafs & pre-images are assumed to be sorted.\n     *\n     * _Available since v4.4._\n     */\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Calldata version of {processProof}\n     *\n     * _Available since v4.7._\n     */\n    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            computedHash = _hashPair(computedHash, proof[i]);\n        }\n        return computedHash;\n    }\n\n    /**\n     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by\n     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerify(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProof(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Calldata version of {multiProofVerify}\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function multiProofVerifyCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32 root,\n        bytes32[] memory leaves\n    ) internal pure returns (bool) {\n        return processMultiProofCalldata(proof, proofFlags, leaves) == root;\n    }\n\n    /**\n     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction\n     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another\n     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false\n     * respectively.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree\n     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the\n     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProof(\n        bytes32[] memory proof,\n        bool[] memory proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proof.length - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value for the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            return hashes[totalHashes - 1];\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    /**\n     * @dev Calldata version of {processMultiProof}.\n     *\n     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.\n     *\n     * _Available since v4.7._\n     */\n    function processMultiProofCalldata(\n        bytes32[] calldata proof,\n        bool[] calldata proofFlags,\n        bytes32[] memory leaves\n    ) internal pure returns (bytes32 merkleRoot) {\n        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by\n        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the\n        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of\n        // the merkle tree.\n        uint256 leavesLen = leaves.length;\n        uint256 totalHashes = proofFlags.length;\n\n        // Check proof validity.\n        require(leavesLen + proof.length - 1 == totalHashes, \"MerkleProof: invalid multiproof\");\n\n        // The xxxPos values are \"pointers\" to the next value to consume in each array. All accesses are done using\n        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's \"pop\".\n        bytes32[] memory hashes = new bytes32[](totalHashes);\n        uint256 leafPos = 0;\n        uint256 hashPos = 0;\n        uint256 proofPos = 0;\n        // At each step, we compute the next hash using two values:\n        // - a value from the \"main queue\". If not all leaves have been consumed, we get the next leaf, otherwise we\n        //   get the next hash.\n        // - depending on the flag, either another value for the \"main queue\" (merging branches) or an element from the\n        //   `proof` array.\n        for (uint256 i = 0; i < totalHashes; i++) {\n            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];\n            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];\n            hashes[i] = _hashPair(a, b);\n        }\n\n        if (totalHashes > 0) {\n            return hashes[totalHashes - 1];\n        } else if (leavesLen > 0) {\n            return leaves[0];\n        } else {\n            return proof[0];\n        }\n    }\n\n    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {\n        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);\n    }\n\n    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            mstore(0x00, a)\n            mstore(0x20, b)\n            value := keccak256(0x00, 0x40)\n        }\n    }\n}\n"

    },

    "lib/openzeppelin-contracts/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "lib/openzeppelin-contracts/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",

      "@openzeppelin/=lib/openzeppelin-contracts/",

      "@uniswap/=lib/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "forge-std/=lib/forge-std/src/",

      "murky/=lib/murky/src/",

      "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/",

      "safe-contracts/=lib/safe-tools/lib/safe-contracts/contracts/",

      "safe-tools/=lib/safe-tools/src/",

      "solady/=lib/safe-tools/lib/solady/src/",

      "solmate/=lib/safe-tools/lib/solady/lib/solmate/src/",

      "v3-core/=lib/v3-core/",

      "v3-periphery/=lib/v3-periphery/contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 20000

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