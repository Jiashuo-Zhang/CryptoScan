{{

  "language": "Solidity",

  "sources": {

    "ScrotoHuntGame.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity >=0.8.0 <0.9.0;\r\n\r\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\r\n\r\ncontract ScrotoHuntGame {\r\n    address public owner;\r\n    address public tokenAddress;\r\n    uint256 public winningChance;\r\n    uint256 public betAmount;\r\n    uint256 public housePercentage; // Percentage of the bet amount that goes to the house\r\n\r\n    event GameResult(\r\n        address indexed player,\r\n        uint256 indexed betAmount,\r\n        bool indexed win,\r\n        uint256 userId\r\n    );\r\n\r\n    constructor(\r\n        address _tokenAddress,\r\n        uint256 _winningChance,\r\n        uint256 _betAmount,\r\n        uint256 _housePercentage\r\n    ) {\r\n        owner = msg.sender;\r\n        tokenAddress = _tokenAddress;\r\n        winningChance = _winningChance;\r\n        betAmount = _betAmount;\r\n        housePercentage = _housePercentage;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(\r\n            msg.sender == owner,\r\n            \"Only the contract owner can call this function\"\r\n        );\r\n        _;\r\n    }\r\n\r\n    function playGame(uint256 userId) external {\r\n        IERC20 token = IERC20(tokenAddress);\r\n        uint256 tokenBalance = token.balanceOf(msg.sender);\r\n        require(tokenBalance >= betAmount, \"Insufficient token balance\");\r\n\r\n        uint256 houseAmount = (betAmount * housePercentage) / 100;\r\n\r\n        require(\r\n            token.transferFrom(msg.sender, address(this), betAmount),\r\n            \"Token transfer failed\"\r\n        );\r\n\r\n        uint256 randomNumber = generateRandomNumber();\r\n\r\n        bool win = randomNumber < winningChance;\r\n        uint256 playerAmount = win ? betAmount * 2 - houseAmount : 0;\r\n\r\n        if (win) {\r\n            require(\r\n                token.transfer(msg.sender, playerAmount),\r\n                \"Token transfer to player failed\"\r\n            );\r\n        }\r\n\r\n        emit GameResult(msg.sender, betAmount, win, userId);\r\n    }\r\n\r\n    function generateRandomNumber() internal view returns (uint256) {\r\n        uint256 dummy = 0; // Adding a dummy variable\r\n        dummy = uint256(\r\n            keccak256(\r\n                abi.encodePacked(\r\n                    block.timestamp,\r\n                    block.prevrandao,\r\n                    msg.sender,\r\n                    dummy\r\n                )\r\n            )\r\n        );\r\n        return dummy % 100;\r\n    }\r\n\r\n    function setBetAmount(uint256 _betAmount) external onlyOwner {\r\n        betAmount = _betAmount;\r\n    }\r\n\r\n    function setWinningChance(uint256 _winningChance) external onlyOwner {\r\n        winningChance = _winningChance;\r\n    }\r\n\r\n    function withdrawTokens(address _teamWallet) external onlyOwner {\r\n        IERC20 token = IERC20(tokenAddress);\r\n        uint256 contractBalance = token.balanceOf(address(this));\r\n        require(contractBalance > 0, \"No tokens to withdraw\");\r\n\r\n        require(\r\n            token.transfer(_teamWallet, contractBalance),\r\n            \"Token transfer to team wallet failed\"\r\n        );\r\n    }\r\n\r\n    function setHousePercentage(uint256 _housePercentage) external onlyOwner {\r\n        housePercentage = _housePercentage;\r\n    }\r\n}\r\n"

    },

    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": false,

      "runs": 200

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