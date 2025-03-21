{{

  "language": "Solidity",

  "sources": {

    "src/Rewards.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\n/*\n\n███╗   ███╗███████╗███╗   ███╗███████╗██████╗ ██╗   ██╗██████╗ ██████╗ ██╗   ██╗\n████╗ ████║██╔════╝████╗ ████║██╔════╝██╔══██╗██║   ██║██╔══██╗██╔══██╗╚██╗ ██╔╝\n██╔████╔██║█████╗  ██╔████╔██║█████╗  ██████╔╝██║   ██║██║  ██║██║  ██║ ╚████╔╝ \n██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██╔══╝  ██╔══██╗██║   ██║██║  ██║██║  ██║  ╚██╔╝  \n██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║███████╗██████╔╝╚██████╔╝██████╔╝██████╔╝   ██║   \n╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝    ╚═╝   \n\n*/\n\npragma solidity ^0.8.13;\n\nimport \"solmate/utils/MerkleProofLib.sol\";\nimport \"solmate/auth/Owned.sol\";\n\ncontract Rewards is Owned {\n    uint256 public lockStartTime;\n\n    bytes32 public root;\n    mapping(bytes32 => mapping(uint256 => bool)) private _isClaimed;\n\n    error AlreadyClaimed();\n    error InvalidProof();\n    error ClaimsLocked();\n\n    event Claimed(address indexed recipient, bytes32 indexed root, uint256 amount);\n    event RootAdded(bytes32 newRoot);\n    event LockStartTimeSet(uint256 _lockStartTime);\n\n    /**\n     * @dev contract constructor\n     */\n    constructor() Owned(msg.sender) {}\n\n    /**\n     * @dev Checks if the claims are locked - 1 hour every 7 days for updates.\n     * @return A boolean that indicates if the claims are locked\n     */\n    function isLocked() public view returns (bool) {\n        return (block.timestamp - lockStartTime) % 7 days < 1 hours;\n    }\n\n    /**\n     * @dev Allows a user to claim their rewards\n     * @param proof The Merkle proof for the claim\n     * @param index The index of the claim\n     * @param amount The amount of the claim\n     */\n    function claim(bytes32[] calldata proof, uint256 index, uint256 amount) external {\n        if (isLocked()) {\n            revert ClaimsLocked();\n        }\n\n        if (_isClaimed[root][index]) revert AlreadyClaimed();\n\n        bytes32 leaf = keccak256(abi.encodePacked(index, msg.sender, amount));\n\n        if (!MerkleProofLib.verify(proof, root, leaf)) revert InvalidProof();\n\n        _isClaimed[root][index] = true;\n        payable(msg.sender).transfer(amount);\n\n        emit Claimed(msg.sender, root, amount);\n    }\n\n    /**\n     * @dev Allows the owner to update the root of the Merkle tree and transfer the total allocation\n     * @param _root The new root of the Merkle tree\n     */\n    function updateRoot(bytes32 _root) external onlyOwner {\n        root = _root;\n        emit RootAdded(_root);\n    }\n\n    /**\n     * @dev Allows the owner to set the lock start time\n     * @param _lockStartTime The new lock start time\n     */\n    function setLockStartTime(uint256 _lockStartTime) external onlyOwner {\n        lockStartTime = _lockStartTime;\n        emit LockStartTimeSet(_lockStartTime);\n    }\n\n    receive() external payable {}\n}\n"

    },

    "lib/solmate/src/utils/MerkleProofLib.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.8.0;\n\n/// @notice Gas optimized merkle proof verification library.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/MerkleProofLib.sol)\n/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/MerkleProofLib.sol)\nlibrary MerkleProofLib {\n    function verify(\n        bytes32[] calldata proof,\n        bytes32 root,\n        bytes32 leaf\n    ) internal pure returns (bool isValid) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            if proof.length {\n                // Left shifting by 5 is like multiplying by 32.\n                let end := add(proof.offset, shl(5, proof.length))\n\n                // Initialize offset to the offset of the proof in calldata.\n                let offset := proof.offset\n\n                // Iterate over proof elements to compute root hash.\n                // prettier-ignore\n                for {} 1 {} {\n                    // Slot where the leaf should be put in scratch space. If\n                    // leaf > calldataload(offset): slot 32, otherwise: slot 0.\n                    let leafSlot := shl(5, gt(leaf, calldataload(offset)))\n\n                    // Store elements to hash contiguously in scratch space.\n                    // The xor puts calldataload(offset) in whichever slot leaf\n                    // is not occupying, so 0 if leafSlot is 32, and 32 otherwise.\n                    mstore(leafSlot, leaf)\n                    mstore(xor(leafSlot, 32), calldataload(offset))\n\n                    // Reuse leaf to store the hash to reduce stack operations.\n                    leaf := keccak256(0, 64) // Hash both slots of scratch space.\n\n                    offset := add(offset, 32) // Shift 1 word per cycle.\n\n                    // prettier-ignore\n                    if iszero(lt(offset, end)) { break }\n                }\n            }\n\n            isValid := eq(leaf, root) // The proof is valid if the roots match.\n        }\n    }\n}\n"

    },

    "lib/solmate/src/auth/Owned.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Simple single owner authorization mixin.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)\nabstract contract Owned {\n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event OwnershipTransferred(address indexed user, address indexed newOwner);\n\n    /*//////////////////////////////////////////////////////////////\n                            OWNERSHIP STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    address public owner;\n\n    modifier onlyOwner() virtual {\n        require(msg.sender == owner, \"UNAUTHORIZED\");\n\n        _;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(address _owner) {\n        owner = _owner;\n\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                             OWNERSHIP LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        owner = newOwner;\n\n        emit OwnershipTransferred(msg.sender, newOwner);\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "openzeppelin/=lib/openzeppelin-contracts/contracts/",

      "solmate/=lib/solmate/src/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "useLiteralContent": false,

      "bytecodeHash": "ipfs",

      "appendCBOR": true

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

    "evmVersion": "paris",

    "libraries": {}

  }

}}