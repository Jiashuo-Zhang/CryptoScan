{{

  "language": "Solidity",

  "sources": {

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "contracts/domain-governer/VerifiedTldHub.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract VerifiedTldHub is Ownable {\n\n    struct TldInfo {\n        string tld;\n        uint256 identifier;\n        uint256 chainId;\n        address registry;\n    }\n\n    struct chainInfo {\n        uint256 chainId;\n        string defaultRpc;\n        address sann;\n    }\n\n    struct completeTldInfo {\n        string tld;\n        uint256 identifier;\n        uint256 chainId;\n        string defaultRpc;\n        address registry;\n        address sann;\n    }\n\n    mapping(string => TldInfo) private tldInfos;\n    mapping(uint256 => string[]) private chainTlds;\n    mapping(uint256 => chainInfo) private chainInfos;\n    string[] private tlds;\n\n\n    constructor(){}\n\n    function updateTldInfo(string calldata tldName, uint256 identifier, uint256 chainId, address registry) public onlyOwner {\n        if (tldInfos[tldName].identifier == 0 && tldInfos[tldName].chainId == 0 && tldInfos[tldName].registry == address(0)) {\n            tlds.push(tldName);\n            chainTlds[chainId].push(tldName);\n        }\n        tldInfos[tldName] = TldInfo(tldName, identifier, chainId, registry);\n    }\n\n    function removeTldInfo(uint256 chainId, string calldata tldName) public onlyOwner {\n        delete tldInfos[tldName];\n        for (uint i = 0; i < tlds.length; i++) {\n            if (keccak256(abi.encodePacked(tlds[i])) == keccak256(abi.encodePacked(tldName))) {\n                tlds[i] = tlds[tlds.length - 1];\n                tlds.pop();\n                break;\n            }\n        }\n        for (uint i = 0; i < chainTlds[chainId].length; i++) {\n            if (keccak256(abi.encodePacked(chainTlds[chainId][i])) == keccak256(abi.encodePacked(tldName))) {\n                chainTlds[chainId][i] = chainTlds[chainId][chainTlds[chainId].length - 1];\n                chainTlds[chainId].pop();\n                break;\n            }\n        }\n    }\n\n    function updateChainInfo(uint256 chainId, string calldata defaultRpc, address sann) public onlyOwner {\n        chainInfos[chainId] = chainInfo(chainId, defaultRpc, sann);\n    }\n\n    function updateDefaultRpc(uint256 chainId, string calldata defaultRpc) public onlyOwner {\n        chainInfos[chainId].defaultRpc = defaultRpc;\n    }\n\n    function getChainTlds(uint256 chainId) public view returns (string[] memory) {\n        string[] memory tldList = new string[](chainTlds[chainId].length);\n        for (uint i = 0; i < chainTlds[chainId].length; i++) {\n            tldList[i] = chainTlds[chainId][i];\n        }\n        return tldList;\n    }\n\n    function getTlds() public view returns (string[] memory) {\n        return tlds;\n    }\n\n    function getChainInfo(uint256 chainId) public view returns (chainInfo memory) {\n        return chainInfos[chainId];\n    }\n\n    function getTldInfo(string[] calldata tldList) public view returns (completeTldInfo[] memory) {\n        completeTldInfo[] memory infos = new completeTldInfo[](tldList.length);\n        for (uint i = 0; i < tldList.length; i++) {\n            string memory tld = tldList[i];\n            uint256 chainId = tldInfos[tldList[i]].chainId;\n            uint256 identifier = tldInfos[tldList[i]].identifier;\n            address registry = tldInfos[tldList[i]].registry;\n            infos[i] = completeTldInfo(tld, identifier, chainId, chainInfos[chainId].defaultRpc, registry, chainInfos[chainId].sann);\n        }\n        return infos;\n    }\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 1000

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