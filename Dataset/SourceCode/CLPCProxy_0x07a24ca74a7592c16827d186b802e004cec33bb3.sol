{{

  "language": "Solidity",

  "sources": {

    "contracts/CLPCProxy.sol": {

      "content": "// SPDX-License-Identifier: CC0\npragma solidity 0.8.17;\n\nimport \"@openzeppelin/contracts/proxy/Proxy.sol\";\nimport \"@openzeppelin/contracts/utils/Context.sol\";\nimport \"./StorageSlot.sol\";\n\ncontract CLPCProxy is Proxy, Context {\n    bytes32 internal constant _OWNER_SLOT =\n        bytes32(uint256(keccak256(\"eip1967.clpcproxy.admin\")) - 1);\n\n    bytes32 internal constant _IMPLEMENTATION_SLOT =\n        bytes32(uint256(keccak256(\"eip1967.clpcproxy.implementation\")) - 1);\n\n    /**\n     * @dev Emitted when the implementation is upgraded.\n     */\n    event Upgraded(address indexed implementation);\n\n    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor(address logicContract) {\n        _transferOwnership(_msgSender());\n        _setImplementation(logicContract);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        if (StorageSlot.getAddressSlot(_OWNER_SLOT).value == _msgSender()) {\n            _;\n        } else {\n            _fallback();\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(\n            newOwner != address(0),\n            \"Ownable: new owner is the zero address\"\n        );\n\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = StorageSlot.getAddressSlot(_OWNER_SLOT).value;\n        StorageSlot.getAddressSlot(_OWNER_SLOT).value = newOwner;\n\n        emit AdminChanged(oldOwner, newOwner);\n    }\n\n    function _implementation()\n        internal\n        view\n        virtual\n        override\n        returns (address)\n    {\n        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;\n    }\n\n    function getImplementation() external view returns (address) {\n        return _implementation();\n    }\n\n    function proxyOwner() external view returns (address) {\n        return StorageSlot.getAddressSlot(_OWNER_SLOT).value;\n    }\n\n    function _setImplementation(address newImplementation) private {\n        StorageSlot\n            .getAddressSlot(_IMPLEMENTATION_SLOT)\n            .value = newImplementation;\n\n        emit Upgraded(_implementation());\n    }\n\n    /**\n     * @dev Perform implementation upgrade\n     *\n     * Emits an {Upgraded} event.\n     */\n    function upgradeTo(address newImplementation) public onlyOwner {\n        _setImplementation(newImplementation);\n    }\n\n    /**\n     * @dev Perform implementation upgrade with additional setup call.\n     *\n     * Emits an {Upgraded} event.\n     */\n    function upgradeToAndCall(\n        address newImplementation,\n        bytes memory data\n    ) public onlyOwner {\n        upgradeTo(newImplementation);\n\n        functionDelegateCall(\n            newImplementation,\n            data,\n            \"CLPCProxy: UpgradeToAndCall fail\"\n        );\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            if (returndata.length > 0) {\n                assembly {\n                    let returndata_size := mload(returndata)\n\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"

    },

    "contracts/StorageSlot.sol": {

      "content": "// SPDX-License-Identifier: CC0\npragma solidity 0.8.17;\n\nlibrary StorageSlot {\n    struct AddressSlot {\n        address value;\n    }\n\n    /**\n     * @dev Returns an `AddressSlot` with member `value` located at `slot`.\n     */\n    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {\n        assembly {\n            r.slot := slot\n        }\n    }\n}"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "@openzeppelin/contracts/proxy/Proxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM\n * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to\n * be specified by overriding the virtual {_implementation} function.\n *\n * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a\n * different contract through the {_delegate} function.\n *\n * The success and return data of the delegated call will be returned back to the caller of the proxy.\n */\nabstract contract Proxy {\n    /**\n     * @dev Delegates the current call to `implementation`.\n     *\n     * This function does not return to its internal call site, it will return directly to the external caller.\n     */\n    function _delegate(address implementation) internal virtual {\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 because we don't know the size yet.\n            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n\n    /**\n     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function\n     * and {_fallback} should delegate.\n     */\n    function _implementation() internal view virtual returns (address);\n\n    /**\n     * @dev Delegates the current call to the address returned by `_implementation()`.\n     *\n     * This function does not return to its internal call site, it will return directly to the external caller.\n     */\n    function _fallback() internal virtual {\n        _beforeFallback();\n        _delegate(_implementation());\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other\n     * function in the contract matches the call data.\n     */\n    fallback() external payable virtual {\n        _fallback();\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data\n     * is empty.\n     */\n    receive() external payable virtual {\n        _fallback();\n    }\n\n    /**\n     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`\n     * call, or as part of the Solidity `fallback` or `receive` functions.\n     *\n     * If overridden should call `super._beforeFallback()`.\n     */\n    function _beforeFallback() internal virtual {}\n}\n"

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