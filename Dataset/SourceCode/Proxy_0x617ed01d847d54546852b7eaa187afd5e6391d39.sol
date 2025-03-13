{{

  "language": "Solidity",

  "sources": {

    "contracts/Proxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.7;\n\nimport { ProxyOwnable } from  \"./ProxyOwnable.sol\";\nimport { Ownable } from \"./Ownable.sol\";\n\n\ncontract Proxy is ProxyOwnable, Ownable {\n    bytes32 private constant implementationPosition = keccak256(\"implementation.contract:2022\");\n    \n    event Upgraded(address indexed implementation);\n\n    constructor(address _impl) ProxyOwnable() Ownable() {\n        _setImplementation(_impl);\n    }\n\n    function implementation() public view returns (address impl) {\n        bytes32 position = implementationPosition;\n        assembly {\n            impl := sload(position)\n        }\n    }\n\n    function upgradeTo(address _newImplementation) public onlyProxyOwner {\n        address currentImplementation = implementation();\n        require(currentImplementation != _newImplementation, \"Same implementation\");\n        _setImplementation(_newImplementation);\n        emit Upgraded(_newImplementation);\n    }\n\n    function _setImplementation(address _newImplementation) internal {\n        bytes32 position = implementationPosition;\n        assembly {\n            sstore(position, _newImplementation)\n        }\n    }\n\n    function _delegatecall() internal {\n        address _impl = implementation();\n        assembly {\n            calldatacopy(0, 0, calldatasize())\n            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n\n    fallback() external {\n        _delegatecall();\n    }\n\n    receive() external payable {\n        _delegatecall();\n    }\n}"

    },

    "contracts/ProxyOwnable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.7;\n\ncontract ProxyOwnable {\n    bytes32 private constant proxyOwnerPosition = keccak256(\"proxy.owner:2022\");\n\n    event ProxyOwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    modifier onlyProxyOwner() {\n        require(msg.sender == proxyOwner(), \"Proxy: Caller not proxy owner\");\n        _;\n    }\n\n    constructor() {\n        _setUpgradeabilityOwner(msg.sender);\n    }\n\n    function proxyOwner() public view returns (address owner) {\n        bytes32 position = proxyOwnerPosition;\n        assembly {\n            owner := sload(position)\n        }\n    }\n\n    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {\n        require(_newOwner != proxyOwner(), \"Proxy: new owner is the current owner\");\n        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);\n        _setUpgradeabilityOwner(_newOwner);\n    }\n\n    function _setUpgradeabilityOwner(address _newProxyOwner) internal {\n        bytes32 position = proxyOwnerPosition;\n        assembly {\n            sstore(position, _newProxyOwner)\n        }\n    }\n}"

    },

    "contracts/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.7;\n\ncontract Ownable {\n    bytes32 private constant ownerPosition = keccak256(\"owner.contract:2022\");\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    modifier onlyOwner() {\n        require(msg.sender == owner(), \"Caller not proxy owner\");\n        _;\n    }\n\n    constructor() {\n        _setOwner(msg.sender);\n    }\n\n    function owner() public view returns (address _owner) {\n        bytes32 position = ownerPosition;\n        assembly {\n            _owner := sload(position)\n        }\n    }\n\n    function transferOwnership(address _newOwner) public onlyOwner {\n        require(_newOwner != owner(), \"New owner is the current owner\");\n        emit OwnershipTransferred(owner(), _newOwner);\n        _setOwner(_newOwner);\n    }\n\n    function _setOwner(address _newOwner) internal {\n        bytes32 position = ownerPosition;\n        assembly {\n            sstore(position, _newOwner)\n        }\n    }\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

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