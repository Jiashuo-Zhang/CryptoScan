{{

  "language": "Solidity",

  "sources": {

    "contracts/periphery/PreBluejayToken.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/utils/cryptography/MerkleProof.sol\";\n\nimport \"../interfaces/IMintableBurnableERC20.sol\";\nimport \"../interfaces/ITreasury.sol\";\nimport \"../interfaces/IPreBluejayToken.sol\";\n\nimport \"./MerkleDistributor.sol\";\n\n/// @title PreBluejayToken\n/// @author Bluejay Core Team\n/// @notice PreBluejayToken is the contract for the pBLU token. The token is a\n/// non-transferable token that can be redeemed for underlying BLU tokens. The\n/// redemption ratio is proportional to the current total supply of the BLU token\n/// against the targeted total supply of BLU tokens. The contract allows a mimimal\n/// level of tokens to be redeemed by each account for initial liquidity.\n/// ie If the target supply is 50M and the current supply is 10M, users will be\n/// able to redeem 1/5 of their pBLU tokens as BLU tokens.\n/// @dev The pBLU token is not an ERC20 token\ncontract PreBluejayToken is Ownable, MerkleDistributor, IPreBluejayToken {\n  uint256 constant WAD = 10**18;\n\n  /// @notice The contract address of the treasury, for minting BLU\n  ITreasury public immutable treasury;\n\n  /// @notice The contract address of the BLU token\n  IMintableBurnableERC20 public immutable BLU;\n\n  /// @notice Target BLU total supply when all pBLU are vested, in WAD\n  uint256 public immutable bluSupplyTarget;\n\n  /// @notice Amount claimable that does not require vesting, in WAD\n  uint256 public immutable vestingThreshold;\n\n  /// @notice Flag to pause contract\n  bool public paused;\n\n  /// @notice Mapping of addresses to allocated pBLU, in WAD\n  mapping(address => uint256) public quota;\n\n  /// @notice Mapping of addresses to redeemed pBLU, in WAD\n  mapping(address => uint256) public redeemed;\n\n  /// @notice Constructor to initialize the contract\n  /// @param _BLU Address of the BLU token\n  /// @param _treasury Address of the treasury\n  /// @param _merkleRoot Merkle root of the distribution\n  /// @param _bluSupplyTarget Target BLU total supply when all pBLU are vested, in WAD\n  /// @param _vestingThreshold Amount claimable that does not require vesting, in WAD\n  constructor(\n    address _BLU,\n    address _treasury,\n    bytes32 _merkleRoot,\n    uint256 _bluSupplyTarget,\n    uint256 _vestingThreshold\n  ) {\n    BLU = IMintableBurnableERC20(_BLU);\n    treasury = ITreasury(_treasury);\n    _setMerkleRoot(_merkleRoot);\n    bluSupplyTarget = _bluSupplyTarget;\n    vestingThreshold = _vestingThreshold;\n    paused = true;\n  }\n\n  // =============================== PUBLIC FUNCTIONS =================================\n\n  /// @notice Claims pBLU tokens\n  /// @dev The parameters of the function should come from the merkle distribution file.\n  /// @param index Index of the distribution\n  /// @param account Account where the distribution is credited to\n  /// @param amount Amount of pBLU allocated in the distribution, in WAD\n  /// @param merkleProof Array of bytes32s representing the merkle proof of the distribution\n  function claimQuota(\n    uint256 index,\n    address account,\n    uint256 amount,\n    bytes32[] calldata merkleProof\n  ) public override {\n    _claim(index, account, amount, merkleProof);\n    quota[account] += amount;\n  }\n\n  /// @notice Redeem BLU token against pBLU tokens\n  /// @dev During redemption, the quota does not change. Instead the redeemed amount is\n  /// updated to reflect amount of pBLU redeemed.\n  /// @param amount Amount of BLU tokens to redeem\n  /// @param recipient Address where the BLU tokens will be sent to\n  function redeem(uint256 amount, address recipient) public override {\n    require(!paused, \"Redemption paused\");\n    require(\n      redeemableTokens(msg.sender) >= amount,\n      \"Insufficient redeemable balance\"\n    );\n    redeemed[msg.sender] += amount;\n    treasury.mint(recipient, amount);\n    emit Redeemed(msg.sender, recipient, amount);\n  }\n\n  // =============================== VIEW FUNCTIONS =================================\n\n  /// @notice Gets the overall vesting progress\n  /// @return progress The vesting progress, in WAD\n  function vestingProgress() public view override returns (uint256) {\n    uint256 bluSupply = BLU.totalSupply();\n    return\n      bluSupply < bluSupplyTarget ? (bluSupply * WAD) / bluSupplyTarget : WAD;\n  }\n\n  /// @notice Gets the amount of BLU that can be redeemed for a given address\n  /// @param account Address to get the redeemable balance for\n  /// @return redeemableAmount Amount of BLU that can be redeemed, in WAD\n  function redeemableTokens(address account)\n    public\n    view\n    override\n    returns (uint256)\n  {\n    uint256 quotaVested = (quota[account] * vestingProgress()) / WAD;\n    if (quotaVested <= vestingThreshold) {\n      quotaVested = quota[account] < vestingThreshold\n        ? quota[account]\n        : vestingThreshold;\n    }\n    return quotaVested - redeemed[account];\n  }\n\n  // =============================== ADMIN FUNCTIONS =================================\n\n  /// @notice Pause and unpause the contract\n  /// @param _paused True to pause, false to unpause\n  function setPause(bool _paused) public onlyOwner {\n    paused = _paused;\n  }\n\n  /// @notice Set the merkle root for the distribution\n  /// @dev Setting the merkle root after distribution has begun may result in unintended consequences\n  /// @param _merkleRoot New merkle root of the distribution\n  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {\n    _setMerkleRoot(_merkleRoot);\n    emit UpdatedMerkleRoot(_merkleRoot);\n  }\n}\n"

    },

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Trees proofs.\n *\n * The proofs can be generated using the JavaScript library\n * https://github.com/miguelmota/merkletreejs[merkletreejs].\n * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.\n *\n * See `test/utils/cryptography/MerkleProof.test.js` for some examples.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(\n        bytes32[] memory proof,\n        bytes32 root,\n        bytes32 leaf\n    ) internal pure returns (bool) {\n        return processProof(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\n     * hash matches the root of the tree. When processing the proof, the pairs\n     * of leafs & pre-images are assumed to be sorted.\n     *\n     * _Available since v4.4._\n     */\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            bytes32 proofElement = proof[i];\n            if (computedHash <= proofElement) {\n                // Hash(current computed hash + current element of the proof)\n                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\n            } else {\n                // Hash(current element of the proof + current computed hash)\n                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\n            }\n        }\n        return computedHash;\n    }\n}\n"

    },

    "contracts/interfaces/IMintableBurnableERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts/interfaces/IERC20.sol\";\n\ninterface IMintableBurnableERC20 is IERC20 {\n  function mint(address _to, uint256 _amount) external;\n\n  function burn(uint256 amount) external;\n}\n"

    },

    "contracts/interfaces/ITreasury.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\ninterface ITreasury {\n  function mint(address to, uint256 amount) external;\n\n  function withdraw(\n    address token,\n    address to,\n    uint256 amount\n  ) external;\n\n  function increaseMintLimit(address minter, uint256 amount) external;\n\n  function decreaseMintLimit(address minter, uint256 amount) external;\n\n  function increaseWithdrawalLimit(\n    address asset,\n    address spender,\n    uint256 amount\n  ) external;\n\n  function decreaseWithdrawalLimit(\n    address asset,\n    address spender,\n    uint256 amount\n  ) external;\n\n  event Mint(address indexed to, uint256 amount);\n  event Withdraw(address indexed token, address indexed to, uint256 amount);\n  event MintLimitUpdate(address indexed minter, uint256 amount);\n  event WithdrawLimitUpdate(\n    address indexed token,\n    address indexed minter,\n    uint256 amount\n  );\n}\n"

    },

    "contracts/interfaces/IPreBluejayToken.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\ninterface IPreBluejayToken {\n  event Redeemed(\n    address indexed owner,\n    address indexed recipient,\n    uint256 amount\n  );\n\n  event UpdatedMerkleRoot(bytes32 merkleRoot);\n\n  function claimQuota(\n    uint256 index,\n    address account,\n    uint256 amount,\n    bytes32[] calldata merkleProof\n  ) external;\n\n  function redeem(uint256 amount, address recipient) external;\n\n  function redeemableTokens(address account) external view returns (uint256);\n\n  function vestingProgress() external view returns (uint256);\n}\n"

    },

    "contracts/periphery/MerkleDistributor.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts/utils/cryptography/MerkleProof.sol\";\n\n/// @title MerkleDistributor\n/// @author Bluejay Core Team\n/// @notice MerkleDistributor is a base contract for contracts using merkle tree to distribute assets.\n/// @dev Code inspired by https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol\n/// Merkle root generation script inspired by https://github.com/Uniswap/merkle-distributor/tree/master/scripts\nabstract contract MerkleDistributor {\n  /// @notice Merkle root of the entire distribution\n  /// @dev Setting the merkle root after distribution has begun may result in unintended consequences\n  bytes32 public merkleRoot;\n\n  /// @notice Packed array of booleans\n  mapping(uint256 => uint256) private claimedBitMap;\n\n  event Distributed(uint256 index, address account, uint256 amount);\n\n  /// @notice Checks `claimedBitMap` to see if the distribution to a given index has been claimed\n  /// @param index Index of the distribution to check\n  /// @return claimed True if the distribution has been claimed, false otherwise\n  function isClaimed(uint256 index) public view returns (bool) {\n    uint256 claimedWordIndex = index / 256;\n    uint256 claimedBitIndex = index % 256;\n    uint256 claimedWord = claimedBitMap[claimedWordIndex];\n    uint256 mask = (1 << claimedBitIndex);\n    return claimedWord & mask == mask;\n  }\n\n  /// @notice Internal function to set a distribution as claimed\n  /// @param index Index of the distribution to mark as claimed\n  function _setClaimed(uint256 index) private {\n    uint256 claimedWordIndex = index / 256;\n    uint256 claimedBitIndex = index % 256;\n    claimedBitMap[claimedWordIndex] =\n      claimedBitMap[claimedWordIndex] |\n      (1 << claimedBitIndex);\n  }\n\n  /// @notice Internal function to claim a distribution\n  /// @param index Index of the distribution to claim\n  /// @param account Address of the account to claim the distribution\n  /// @param amount Amount of the distribution to claim\n  /// @param merkleProof Array of bytes32s representing the merkle proof of the distribution\n  function _claim(\n    uint256 index,\n    address account,\n    uint256 amount,\n    bytes32[] calldata merkleProof\n  ) internal {\n    require(!isClaimed(index), \"Already claimed\");\n\n    // Verify the merkle proof.\n    bytes32 node = keccak256(abi.encodePacked(index, account, amount));\n    require(MerkleProof.verify(merkleProof, merkleRoot, node), \"Invalid proof\");\n\n    // Mark it claimed\n    _setClaimed(index);\n\n    emit Distributed(index, account, amount);\n  }\n\n  /// @notice Internal function to set the merkle root\n  /// @dev Setting the merkle root after distribution has begun may result in unintended consequences\n  function _setMerkleRoot(bytes32 _merkleRoot) internal {\n    merkleRoot = _merkleRoot;\n  }\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "@openzeppelin/contracts/interfaces/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../token/ERC20/IERC20.sol\";\n"

    },

    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 1000000

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

    "metadata": {

      "useLiteralContent": true

    },

    "libraries": {}

  }

}}