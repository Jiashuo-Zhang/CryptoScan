{{

  "language": "Solidity",

  "sources": {

    "contracts/YetiDistributor.sol": {

      "content": "// SPDX-License-Identifier: NONE\n\npragma solidity ^0.8.0;\n\nimport \"./utils/MerkleProof.sol\";\nimport \"./utils/Ownable.sol\";\nimport \"./ERC20/IERC20.sol\";\nimport \"./IDistributor.sol\";\n\n/**\n * @title Cover Distributor for Yeti BPT staked in Yeti staking contract\n * @author crypto-pumpkin\n */\ncontract YetiDistributor is IDistributor, Ownable {\n  address public immutable override token;\n  bytes32 public immutable override merkleRoot;\n\n  uint256 public override totalClaimed;\n  uint256 public deployedAt;\n\n  mapping(uint256 => uint256) private claimedBitMap;\n\n  constructor(address token_, bytes32 merkleRoot_) {\n    token = token_;\n    merkleRoot = merkleRoot_;\n    deployedAt = block.timestamp;\n  }\n\n  function isClaimed(uint256 index) public view override returns (bool) {\n    uint256 claimedWordIndex = index / 256;\n    uint256 claimedBitIndex = index % 256;\n    uint256 claimedWord = claimedBitMap[claimedWordIndex];\n    uint256 mask = (1 << claimedBitIndex);\n    return claimedWord & mask == mask;\n  }\n\n  function claim(\n    uint256 index,\n    address account,\n    uint256 amount,\n    bytes32[] calldata merkleProof\n  ) external override {\n    require(!isClaimed(index), \"YetiDistributor: Already claimed\");\n\n    // Verify the merkle proof.\n    bytes32 node = keccak256(abi.encodePacked(index, account, amount));\n    require(MerkleProof.verify(merkleProof, merkleRoot, node), \"YetiDistributor: Invalid proof\");\n\n    // Mark it claimed and send the token.\n    totalClaimed = totalClaimed + amount;\n    _setClaimed(index);\n    require(IERC20(token).transfer(account, amount), \"YetiDistributor: Transfer failed\");\n\n    emit Claimed(index, account, amount);\n  }\n\n  // collect any token send by mistake, collect target after 90 days\n  function collectDust(address _token) external {\n    if (_token == address(0)) { // token address(0) = ETH\n      payable(owner()).transfer(address(this).balance);\n    } else {\n      if (_token == token) {\n        require(block.timestamp > deployedAt + 90 days, \"YetiDistributor: Not ready\");\n      }\n      uint256 balance = IERC20(_token).balanceOf(address(this));\n      IERC20(_token).transfer(owner(), balance);\n    }\n  }\n\n  function _setClaimed(uint256 index) private {\n    uint256 claimedWordIndex = index / 256;\n    uint256 claimedBitIndex = index % 256;\n    claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);\n  }\n}"

    },

    "contracts/utils/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle trees (hash trees),\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        bytes32 computedHash = leaf;\n\n        for (uint256 i = 0; i < proof.length; i++) {\n            bytes32 proofElement = proof[i];\n\n            if (computedHash <= proofElement) {\n                // Hash(current computed hash + current element of the proof)\n                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\n            } else {\n                // Hash(current element of the proof + current computed hash)\n                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\n            }\n        }\n\n        // Check if the computed hash (root) is equal to the provided root\n        return computedHash == root;\n    }\n}"

    },

    "contracts/utils/Ownable.sol": {

      "content": "// SPDX-License-Identifier: None\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n * @author crypto-pumpkin@github\n *\n * By initialization, the owner account will be the one that called initializeOwner. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\ncontract Ownable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev COVER: Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () {\n        _owner = msg.sender;\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(_owner == msg.sender, \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}"

    },

    "contracts/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: No License\n\npragma solidity ^0.8.0;\n\n/**\n * @title Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    function balanceOf(address account) external view returns (uint256);\n    function totalSupply() external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);\n    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);\n}"

    },

    "contracts/IDistributor.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n// Allows anyone to claim a token if they exist in a merkle root.\ninterface IDistributor {\n    // Returns the address of the token distributed by this contract.\n    function token() external view returns (address);\n    // Returns the merkle root of the merkle tree containing account balances available to claim.\n    function merkleRoot() external view returns (bytes32);\n    // Returns true if the index has been marked claimed.\n    function isClaimed(uint256 index) external view returns (bool);\n    function totalClaimed() external view returns (uint256);\n    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.\n    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;\n\n    // This event is triggered whenever a call to #claim succeeds.\n    event Claimed(uint256 index, address account, uint256 amount);\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "abi"

        ]

      }

    },

    "libraries": {}

  }

}}