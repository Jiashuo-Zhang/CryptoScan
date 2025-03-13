{{

  "language": "Solidity",

  "sources": {

    "contracts/shumoClaim.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity ^0.6.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n\n\n\npragma solidity ^0.6.0;\n\ncontract shumoClaim{\n\n    address public owner;\n    bytes32 public root;\n\n    address public distributionWallet=0x98AadbBd93892bc8e6c47154d9172f9Ad24d2fFE;\n\n    IERC20 public shumo;\n    bool public claimIsActive = false;\n\n     constructor() public {\n        owner=msg.sender;\n        root=0x5a69887c896dd1dac6edf4fda9ba2c381ca78a8d92739e2d794a7dd980f7a605;\n        shumo=IERC20(0xEaa2C985abF14Ac850F6614faebd6E4436BeA65f);\n    }\n\n\n\n    mapping(address => bool) claimedAddresses;\n    \n     function flipClaimState() public {\n        require(msg.sender==owner, \"Only Owner can use this function\");\n        claimIsActive = !claimIsActive;\n    }\n\n    function setPurchaseToken(IERC20 token) public  {\n        require(msg.sender==owner, \"Only Owner can use this function\");\n        shumo = token; //shumo Token\n    }\n\n    function setRoot(bytes32 newRoot) public  {\n        require(msg.sender==owner, \"Only Owner can use this function\");\n        root=newRoot; \n    }\n\n     function setDistributionWallet(address newWallet) public {\n        require(msg.sender==owner, \"Only Owner can use this function\");\n        distributionWallet=newWallet; //Set Wallet\n    }\n     function transferOwnership(address newOwner) public {\n        require(msg.sender==owner, \"Only Owner can use this function\");\n        owner=newOwner; //Set Owner\n    }\n\n    function withdrawStuckShumoBalance() public {\n        require(msg.sender==owner, \"Only Owner can use this function\");\n        shumo.transfer(msg.sender,shumo.balanceOf(address(this)));\n    }\n\n    function hasClaimed(address claimedAddress) public view returns (bool){\n      return claimedAddresses[claimedAddress]; //check if claimed\n    }\n\n    function removeFromClaimed(address claimedAddress) public {\n      require(msg.sender==owner, \"Only Owner can use this function\");\n      claimedAddresses[claimedAddress]=false; \n    }\n \n    \n  function verify(\n    bytes32 leaf,\n    bytes32[] memory proof\n  )\n    public\n    view\n    returns (bool)\n  {\n    bytes32 computedHash = leaf;\n\n    for (uint256 i = 0; i < proof.length; i++) {\n      bytes32 proofElement = proof[i];\n\n      if (computedHash < proofElement) {\n        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\n      } else {\n        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\n      }\n    }\n    return computedHash == root;\n  }\n  \nfunction claim(bytes32[] memory proof,address account, uint256 amount) public{\n\n    require(claimIsActive, \"Claim is not enabled\");\n    require(!claimedAddresses[account], \"Distributor: Drop already claimed.\");\n    require(msg.sender==account, \"Sender not claimer\");\n\n    bytes32 leaf = keccak256(abi.encodePacked(account, amount));\n    require(verify(leaf,proof), \"Not Eligible\");\n\n    shumo.transferFrom(distributionWallet,account,amount*10**9);  //decimals\n    claimedAddresses[account]=true;\n}\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 2000

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

    }

  }

}}