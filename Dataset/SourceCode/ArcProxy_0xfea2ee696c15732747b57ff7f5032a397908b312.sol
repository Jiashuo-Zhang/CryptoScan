{{

  "language": "Solidity",

  "sources": {

    "contracts/ArcProxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\ncontract ArcProxy {\n\n    /**\n    * @dev Emitted when the implementation is upgraded.\n    * @param implementation Address of the new implementation.\n    */\n    event Upgraded(address indexed implementation);\n\n    /**\n    * @dev Emitted when the administration has been transferred.\n    * @param previousAdmin Address of the previous admin.\n    * @param newAdmin Address of the new admin.\n    */\n    event AdminChanged(address previousAdmin, address newAdmin);\n\n    /**\n    * @dev Storage slot with the admin of the contract.\n    * This is the keccak-256 hash of \"eip1967.proxy.admin\" subtracted by 1, and is\n    * validated in the constructor.\n    */\n\n    /* solhint-disable-next-line */\n    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;\n\n    /**\n    * @dev Storage slot with the address of the current implementation.\n    * This is the keccak-256 hash of \"eip1967.proxy.implementation\" subtracted by 1, and is\n    * validated in the constructor.\n    */\n\n    /* solhint-disable-next-line */\n    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    /**\n    * @dev Modifier to check whether the `msg.sender` is the admin.\n    * If it is, it will run the function. Otherwise, it will delegate the call\n    * to the implementation.\n    */\n    modifier ifAdmin() {\n        if (msg.sender == _admin()) {\n            _;\n        } else {\n            _fallback();\n        }\n    }\n\n    /**\n    * Contract constructor.\n    * @param _logic address of the initial implementation.\n    * @param admin_ Address of the proxy administrator.\n    * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.\n    * It should include the signature and the parameters of the function to be called, as described in\n    * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n    * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.\n    */\n    constructor(\n        address _logic,\n        address admin_,\n        bytes memory _data\n    )\n        payable\n    {\n        assert(\n            IMPLEMENTATION_SLOT == bytes32(\n                uint256(keccak256(\"eip1967.proxy.implementation\")) - 1\n            )\n        );\n\n        _setImplementation(_logic);\n\n        if (_data.length > 0) {\n            /* solhint-disable-next-line */\n            (bool success,) = _logic.delegatecall(_data);\n            /* solhint-disable-next-line */\n            require(success);\n        }\n\n        assert(\n            ADMIN_SLOT == bytes32(\n                uint256(keccak256(\"eip1967.proxy.admin\")) - 1\n            )\n        );\n\n        _setAdmin(admin_);\n    }\n\n    /**\n     * @dev Fallback function.\n     * Implemented entirely in `_fallback`.\n     */\n    fallback() external payable {\n        _fallback();\n    }\n\n    /**\n     * @dev fallback implementation.\n     * Extracted to enable manual triggering.\n     */\n    function _fallback() internal {\n        _delegate(_implementation());\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`.\n     *      Will run if call data is empty.\n     */\n    receive() external payable virtual {\n        _fallback();\n    }\n\n    /**\n     * @dev Delegates execution to an implementation contract.\n     * This is a low level function that doesn't return to its internal call site.\n     * It will return to the external caller whatever the implementation returns.\n     * @param implementation_ Address to delegate.\n     */\n    function _delegate(address implementation_) internal {\n        /* solhint-disable-next-line */\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 because we don't know the size yet.\n            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 { revert(0, returndatasize()) }\n            default { return(0, returndatasize()) }\n        }\n    }\n\n    /**\n     * Returns whether the target address is a contract\n     * @dev This function will return false if invoked during the constructor of a contract,\n     * as the code is not actually created until after the constructor finishes.\n     * @param account address of the account to check\n     * @return whether the target address is a contract\n     */\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        // XXX Currently there is no better way to check if there is a contract in an address\n        // than to check the size of the code at that address.\n        // See https://ethereum.stackexchange.com/a/14016/36603\n        // for more details about how this works.\n        // TODO Check this again before the Serenity release, because all addresses will be\n        // contracts then.\n        /* solhint-disable-next-line */\n        assembly { size := extcodesize(account) }\n        return size > 0;\n    }\n\n    /**\n    * @dev Returns the current implementation.\n    * @return impl Address of the current implementation\n    */\n    function _implementation() internal view returns (address impl) {\n        bytes32 slot = IMPLEMENTATION_SLOT;\n        /* solhint-disable-next-line */\n        assembly {\n            impl := sload(slot)\n        }\n    }\n\n    /**\n    * @dev Upgrades the proxy to a new implementation.\n    * @param newImplementation Address of the new implementation.\n    */\n    function _upgradeTo(address newImplementation) internal {\n        _setImplementation(newImplementation);\n        emit Upgraded(newImplementation);\n    }\n\n    /**\n    * @dev Sets the implementation address of the proxy.\n    * @param newImplementation Address of the new implementation.\n    */\n    function _setImplementation(address newImplementation) internal {\n        require(\n            isContract(newImplementation),\n            \"Cannot set a proxy implementation to a non-contract address\"\n        );\n\n        bytes32 slot = IMPLEMENTATION_SLOT;\n\n        /* solhint-disable-next-line */\n        assembly {\n            sstore(slot, newImplementation)\n        }\n    }\n\n    /**\n    * @return admin_ The address of the proxy admin.\n    */\n    function admin() external ifAdmin returns (address admin_) {\n        admin_ = _admin();\n    }\n\n    /**\n    * @return implementation_ The address of the implementation.\n    */\n    function implementation() external ifAdmin returns (address implementation_) {\n        implementation_ = _implementation();\n    }\n\n    /**\n    * @dev Changes the admin of the proxy.\n    * Only the current admin can call this function.\n    * @param newAdmin Address to transfer proxy administration to.\n    */\n    function changeAdmin(address newAdmin) external ifAdmin {\n        require(\n            newAdmin != address(0),\n            \"Cannot change the admin of a proxy to the zero address\"\n        );\n\n        emit AdminChanged(_admin(), newAdmin);\n        _setAdmin(newAdmin);\n    }\n\n    /**\n    * @dev Upgrade the backing implementation of the proxy.\n    * Only the admin can call this function.\n    * @param newImplementation Address of the new implementation.\n    */\n    function upgradeTo(address newImplementation) external ifAdmin {\n        _upgradeTo(newImplementation);\n    }\n\n    /**\n    * @dev Upgrade the backing implementation of the proxy and call a function\n    * on the new implementation.\n    * This is useful to initialize the proxied contract.\n    * @param newImplementation Address of the new implementation.\n    * @param data Data to send as msg.data in the low level call.\n    * It should include the signature and the parameters of the function to be called, as described in\n    * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n    */\n    function upgradeToAndCall(\n        address newImplementation,\n        bytes calldata data\n    )\n        external\n        payable\n        ifAdmin\n    {\n        _upgradeTo(newImplementation);\n        /* solhint-disable-next-line */\n        (bool success,) = newImplementation.delegatecall(data);\n        /* solhint-disable-next-line */\n        require(success);\n    }\n\n    /**\n    * @return adm The admin slot.\n    */\n    function _admin() internal view returns (address adm) {\n        bytes32 slot = ADMIN_SLOT;\n\n        /* solhint-disable-next-line */\n        assembly {\n            adm := sload(slot)\n        }\n    }\n\n    /**\n    * @dev Sets the address of the proxy admin.\n    * @param newAdmin Address of the new proxy admin.\n    */\n    function _setAdmin(address newAdmin) internal {\n        bytes32 slot = ADMIN_SLOT;\n\n        /* solhint-disable-next-line */\n        assembly {\n            sstore(slot, newAdmin)\n        }\n    }\n\n}\n"

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