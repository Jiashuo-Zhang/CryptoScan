{{

  "language": "Solidity",

  "sources": {

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "contracts/CampaignGoFuckYourself.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ncontract CampaignGoFuckYourself is Ownable {\n    // ========================================\n    //     EVENT & ERROR DEFINITIONS\n    // ========================================\n\n    error TransferFailed();\n    error InvalidSignature();\n    error NoPermissionToExecute();\n    error NotEnoughCollateral();\n    error NotEnoughSupplyToBorrow();\n    error ExpiredPrice();\n    error ExpiredTime();\n    error ContractsNotAllowed();\n\n    // ========================================\n    //     VARIABLE DEFINITIONS\n    // ========================================\n\n    struct SignatureContent {\n        uint256 nonce;\n        uint256 amount;\n        uint256 price;\n        uint40 timestamp;\n        address token;\n    }\n\n    address public SIGNER;\n    bytes32 internal constant SIG_TYPEHASH =\n        keccak256(\n            \"SignatureContent(uint256 nonce,uint256 amount,uint256 price,uint40 timestamp,address token)\"\n        );\n    mapping(address => address) public supportedTokens;\n    mapping(bytes32 => bool) public revokedSignatures;\n\n    // ========================================\n    //    CONSTRUCTOR AND CORE FUNCTIONS\n    // ========================================\n\n    constructor(\n        address _token,\n        address _tokenOwner,\n        address _signer\n    ) {\n        supportedTokens[_token] = _tokenOwner;\n        SIGNER = _signer;\n    }\n\n    function burnToken(\n        SignatureContent calldata _content,\n        bytes calldata _signature\n    ) external payable {\n        require(supportedTokens[_content.token] != address(0), \"Invalid Token\");\n        require(\n            IERC20(_content.token).balanceOf(address(this)) >=\n                _content.amount &&\n                _content.amount > 0,\n            \"Not enough balance\"\n        );\n        signatureCheck(_content, _signature);\n        require(msg.value >= _content.price, \"Invalid Amount\");\n\n        IERC20(_content.token).transfer(\n            0x000000000000000000000000000000000000dEaD,\n            _content.amount\n        );\n    }\n\n    // ========================================\n    //     SIGNATURE FUNCTIONS\n    // ========================================\n\n    function revokeSignature(bytes32 _hash) internal {\n        if (revokedSignatures[_hash] == true) revert InvalidSignature();\n        revokedSignatures[_hash] = true;\n    }\n\n    function _eip712DomainSeparator() private view returns (bytes32) {\n        return\n            keccak256(\n                abi.encode(\n                    keccak256(\n                        \"EIP712Domain(string name,string version,address verifyingContract)\"\n                    ),\n                    keccak256(bytes(\"CampaignGoFuckYourself\")),\n                    keccak256(bytes(\"1.0\")),\n                    address(this)\n                )\n            );\n    }\n\n    function getMessageHash(SignatureContent memory _content)\n        public\n        pure\n        returns (bytes32)\n    {\n        return\n            keccak256(\n                abi.encode(\n                    SIG_TYPEHASH,\n                    _content.nonce,\n                    _content.amount,\n                    _content.price,\n                    _content.timestamp,\n                    _content.token\n                )\n            );\n    }\n\n    function getEthSignedMessageHash(SignatureContent calldata _content)\n        public\n        view\n        returns (bytes32)\n    {\n        return\n            keccak256(\n                abi.encodePacked(\n                    \"\\x19\\x01\",\n                    _eip712DomainSeparator(),\n                    getMessageHash(_content)\n                )\n            );\n    }\n\n    function validateSignature(uint40 _expiration, bytes32 _hash) public view {\n        if (block.timestamp >= _expiration) revert ExpiredTime();\n        if (revokedSignatures[_hash] != false) revert InvalidSignature();\n    }\n\n    function signatureCheck(\n        SignatureContent calldata _content,\n        bytes memory signature\n    ) public view returns (bool) {\n        bytes32 ethSignedMessageHash = getEthSignedMessageHash(_content);\n        validateSignature(_content.timestamp, ethSignedMessageHash);\n        return recoverSigner(ethSignedMessageHash, signature) == SIGNER;\n    }\n\n    function recoverSigner(\n        bytes32 _ethSignedMessageHash,\n        bytes memory _signature\n    ) public pure returns (address) {\n        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);\n\n        return ecrecover(_ethSignedMessageHash, v, r, s);\n    }\n\n    function splitSignature(bytes memory sig)\n        public\n        pure\n        returns (\n            bytes32 r,\n            bytes32 s,\n            uint8 v\n        )\n    {\n        require(sig.length == 65, \"invalid signature length\");\n\n        assembly {\n            r := mload(add(sig, 32))\n            // second 32 bytes\n            s := mload(add(sig, 64))\n            // final byte (first byte of the next 32 bytes)\n            v := byte(0, mload(add(sig, 96)))\n        }\n    }\n\n    // ========================================\n    //     ADMIN FUNCTIONS\n    // ========================================\n\n    function addOrRemoveToken(address _token, address _tokenOwner)\n        public\n        onlyOwner\n    {\n        supportedTokens[_token] = _tokenOwner;\n    }\n\n    function withdrawETH() external onlyOwner {\n        bool success;\n        (success, ) = address(msg.sender).call{value: address(this).balance}(\n            \"\"\n        );\n    }\n\n    function withdrawTokens(address _token) external {\n        require(_token != address(this), \"Cannot withdraw this token\");\n        require(supportedTokens[_token] == msg.sender, \"Not Token Owner\");\n        require(IERC20(_token).balanceOf(address(this)) > 0, \"No tokens\");\n        uint256 amount = IERC20(_token).balanceOf(address(this));\n        IERC20(_token).transfer(msg.sender, amount);\n    }\n\n    function setSigner(address _signer) external onlyOwner {\n        SIGNER = _signer;\n    }\n}\n"

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

    },

    "libraries": {}

  }

}}