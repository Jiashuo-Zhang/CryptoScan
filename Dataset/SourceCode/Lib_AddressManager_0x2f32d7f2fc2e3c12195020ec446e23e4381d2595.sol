{{

  "language": "Solidity",

  "sources": {

    "contracts/nahmii/libraries/resolver/Lib_AddressManager.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.8.0;\n\n/* External Imports */\nimport { Ownable } from \"@openzeppelin/contracts/access/Ownable.sol\";\n\n/**\n * @title Lib_AddressManager\n */\ncontract Lib_AddressManager is Ownable {\n\n    /**********\n     * Events *\n     **********/\n\n    event AddressSet(\n        string indexed _name,\n        address _newAddress,\n        address _oldAddress\n    );\n\n\n    /*************\n     * Variables *\n     *************/\n\n    mapping (bytes32 => address) private addresses;\n\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    /**\n     * Changes the address associated with a particular name.\n     * @param _name String name to associate an address with.\n     * @param _address Address to associate with the name.\n     */\n    function setAddress(\n        string memory _name,\n        address _address\n    )\n        external\n        onlyOwner\n    {\n        bytes32 nameHash = _getNameHash(_name);\n        address oldAddress = addresses[nameHash];\n        addresses[nameHash] = _address;\n\n        emit AddressSet(\n            _name,\n            _address,\n            oldAddress\n        );\n    }\n\n    /**\n     * Retrieves the address associated with a given name.\n     * @param _name Name to retrieve an address for.\n     * @return Address associated with the given name.\n     */\n    function getAddress(\n        string memory _name\n    )\n        external\n        view\n        returns (\n            address\n        )\n    {\n        return addresses[_getNameHash(_name)];\n    }\n\n\n    /**********************\n     * Internal Functions *\n     **********************/\n\n    /**\n     * Computes the hash of a name.\n     * @param _name Name to compute a hash for.\n     * @return Hash of the given name.\n     */\n    function _getNameHash(\n        string memory _name\n    )\n        internal\n        pure\n        returns (\n            bytes32\n        )\n    {\n        return keccak256(abi.encodePacked(_name));\n    }\n}\n"

    },

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"../utils/Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "bytecodeHash": "none",

      "useLiteralContent": true

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