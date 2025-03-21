{{

  "language": "Solidity",

  "sources": {

    "src/Proxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.23;\n\nimport {Ownable} from \"./Ownable.sol\";\n\n/**\n * @title Proxy\n * @dev Based on Origin Protocol InitializeGovernedUpgradeabilityProxy\n * https://github.com/OriginProtocol/origin-dollar/blob/master/contracts/contracts/proxies/InitializeGovernedUpgradeabilityProxy.sol\n * @author Origin Protocol Inc\n */\ncontract Proxy is Ownable {\n    /**\n     * @dev Storage slot with the address of the current implementation.\n     * This is the keccak-256 hash of \"eip1967.proxy.implementation\" subtracted by 1, and is\n     * validated in the constructor.\n     */\n    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    /**\n     * @dev Emitted when the implementation is upgraded.\n     * @param implementation Address of the new implementation.\n     */\n    event Upgraded(address indexed implementation);\n\n    /**\n     * @dev Contract initializer with Owner enforcement\n     * @param _logic Address of the initial implementation.\n     * @param _initOwner Address of the initial Owner.\n     * @param _data Data to send as msg.data to the implementation to initialize\n     * the proxied contract.\n     * It should include the signature and the parameters of the function to be\n     * called, as described in\n     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n     * This parameter is optional, if no data is given the initialization call\n     * to proxied contract will be skipped.\n     */\n    function initialize(address _logic, address _initOwner, bytes calldata _data) public payable onlyOwner {\n        require(_implementation() == address(0));\n        assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256(\"eip1967.proxy.implementation\")) - 1));\n        _upgradeTo(_logic);\n        if (_data.length > 0) {\n            (bool success,) = _logic.delegatecall(_data);\n            require(success);\n        }\n        _setOwner(_initOwner);\n    }\n\n    /**\n     * @return The address of the proxy admin/it's also the owner.\n     */\n    function admin() external view returns (address) {\n        return _owner();\n    }\n\n    /**\n     * @return The address of the implementation.\n     */\n    function implementation() external view returns (address) {\n        return _implementation();\n    }\n\n    /**\n     * @dev Upgrade the backing implementation of the proxy.\n     * Only the admin can call this function.\n     * @param newImplementation Address of the new implementation.\n     */\n    function upgradeTo(address newImplementation) external onlyOwner {\n        _upgradeTo(newImplementation);\n    }\n\n    /**\n     * @dev Upgrade the backing implementation of the proxy and call a function\n     * on the new implementation.\n     * This is useful to initialize the proxied contract.\n     * @param newImplementation Address of the new implementation.\n     * @param data Data to send as msg.data in the low level call.\n     * It should include the signature and the parameters of the function to be called, as described in\n     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n     */\n    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable onlyOwner {\n        _upgradeTo(newImplementation);\n        (bool success,) = newImplementation.delegatecall(data);\n        require(success);\n    }\n\n    /**\n     * @dev Fallback function.\n     * Implemented entirely in `_fallback`.\n     */\n    fallback() external payable {\n        _delegate(_implementation());\n    }\n\n    /**\n     * @dev Delegates execution to an implementation contract.\n     * This is a low level function that doesn't return to its internal call site.\n     * It will return to the external caller whatever the implementation returns.\n     * @param _impl Address to delegate.\n     */\n    function _delegate(address _impl) internal {\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 because we don't know the size yet.\n            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 { revert(0, returndatasize()) }\n            default { return(0, returndatasize()) }\n        }\n    }\n\n    /**\n     * @dev Returns the current implementation.\n     * @return impl Address of the current implementation\n     */\n    function _implementation() internal view returns (address impl) {\n        bytes32 slot = IMPLEMENTATION_SLOT;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            impl := sload(slot)\n        }\n    }\n\n    /**\n     * @dev Upgrades the proxy to a new implementation.\n     * @param newImplementation Address of the new implementation.\n     */\n    function _upgradeTo(address newImplementation) internal {\n        require(newImplementation.code.length > 0, \"Cannot set a proxy implementation to a non-contract address\");\n        bytes32 slot = IMPLEMENTATION_SLOT;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            sstore(slot, newImplementation)\n        }\n        emit Upgraded(newImplementation);\n    }\n}\n"

    },

    "src/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.23;\n\ncontract Ownable {\n    // keccak256(“eip1967.proxy.admin”) - per EIP 1967\n    bytes32 internal constant OWNER_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;\n\n    event AdminChanged(address previousAdmin, address newAdmin);\n\n    constructor() {\n        assert(OWNER_SLOT == bytes32(uint256(keccak256(\"eip1967.proxy.admin\")) - 1));\n        _setOwner(msg.sender);\n    }\n\n    function owner() external view returns (address) {\n        return _owner();\n    }\n\n    function setOwner(address newOwner) external onlyOwner {\n        _setOwner(newOwner);\n    }\n\n    function _owner() internal view returns (address ownerOut) {\n        bytes32 position = OWNER_SLOT;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            ownerOut := sload(position)\n        }\n    }\n\n    function _setOwner(address newOwner) internal {\n        emit AdminChanged(_owner(), newOwner);\n        bytes32 position = OWNER_SLOT;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            sstore(position, newOwner)\n        }\n    }\n\n    function _onlyOwner() internal view {\n        require(msg.sender == _owner(), \"OSwap: Only owner can call this function.\");\n    }\n\n    modifier onlyOwner() {\n        _onlyOwner();\n        _;\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "forge-std/=lib/forge-std/src/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "useLiteralContent": false,

      "bytecodeHash": "ipfs",

      "appendCBOR": true

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

    "evmVersion": "paris",

    "libraries": {}

  }

}}