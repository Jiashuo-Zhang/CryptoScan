{{

  "language": "Solidity",

  "sources": {

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "contracts/XVGClaim.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.21;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\n// ____  _______   ____________\n// \\   \\/  /\\   \\ /   /  _____/\n//  \\     /  \\   Y   /   \\  ___\n//  /     \\   \\     /\\    \\_\\  \\\n// /___/\\  \\   \\___/  \\______  /2023\n//       \\_/XVG              \\/\n//\n// https://github.com/vergecurrency/erc20\n\ncontract XVGClaim is Ownable {\n\n    IERC20 immutable XVG;\n    uint256 immutable maxClaims;\n    uint256 public minClaimAmount = 10_000 ether;\n    uint256 public maxClaimAmount = 25_000 ether;\n    uint256 public totalClaims;\n    mapping(address => bool) public claimed;\n\n    error AlreadyClaimed();\n    error NotEligible();\n    error TransferFailed();\n    error ClaimingStopped();\n\n    event Claim(address indexed user, uint256 amount);\n\n    constructor(address owner_, address xvg_, uint256 maxClaims_) {\n        XVG = IERC20(xvg_);\n        maxClaims = maxClaims_;\n        transferOwnership(owner_);\n    }\n\n    /// @notice Claims a random amount of XVG tokens between minClaimAmount and maxClaimAmount\n    function claim() external returns (uint256 amount) {\n        if (totalClaims + 1 > maxClaims) revert ClaimingStopped();\n        if (claimed[msg.sender]) revert AlreadyClaimed();\n        if (XVG.balanceOf(msg.sender) > 0) revert NotEligible();\n        claimed[msg.sender] = true;\n        amount = getRandomAmount();\n        bool success = XVG.transfer(msg.sender, amount);\n        if (!success) revert TransferFailed();\n        totalClaims++;\n\n        emit Claim(msg.sender, amount);\n    }\n\n    /// @notice Sets the min and max claim amount\n    function setMinMaxClaimAmount(uint256 min, uint256 max) external onlyOwner {\n        minClaimAmount = min;\n        maxClaimAmount = max;\n    }\n\n    /// @notice Withdraws any ERC20 token to the owner\n    function withdrawToken(IERC20 token, uint256 amount) external onlyOwner {\n        uint256 balance = token.balanceOf(address(this));\n        if (amount == 0) amount = balance;\n        token.transfer(owner(), amount);\n    }\n\n    /// @dev Gets a random amount between minClaimAmount and maxClaimAmount\n    function getRandomAmount() internal view returns (uint256) {\n        return uint256(\n            keccak256(\n                abi.encodePacked(\n                    block.timestamp,\n                    block.prevrandao,\n                    msg.sender\n                )\n            )\n        ) % (maxClaimAmount - minClaimAmount) + minClaimAmount;\n    }\n}\n"

    }

  },

  "settings": {

    "evmVersion": "shanghai",

    "optimizer": {

      "enabled": true,

      "runs": 20000

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

    "libraries": {}

  }

}}