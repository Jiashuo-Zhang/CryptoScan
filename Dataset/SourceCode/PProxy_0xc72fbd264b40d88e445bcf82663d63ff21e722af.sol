{{

  "language": "Solidity",

  "sources": {

    "lib/pie-proxy/contracts/PProxy.sol": {

      "content": "pragma solidity ^0.8.0;\n\nimport \"./PProxyStorage.sol\";\n\ncontract PProxy is PProxyStorage {\n\n    bytes32 constant IMPLEMENTATION_SLOT = keccak256(abi.encodePacked(\"IMPLEMENTATION_SLOT\"));\n    bytes32 constant OWNER_SLOT = keccak256(abi.encodePacked(\"OWNER_SLOT\"));\n\n    modifier onlyProxyOwner() {\n        require(msg.sender == readAddress(OWNER_SLOT), \"PProxy.onlyProxyOwner: msg sender not owner\");\n        _;\n    }\n\n    constructor () public {\n        setAddress(OWNER_SLOT, msg.sender);\n    }\n\n    function getProxyOwner() public view returns (address) {\n       return readAddress(OWNER_SLOT);\n    }\n\n    function setProxyOwner(address _newOwner) onlyProxyOwner public {\n        setAddress(OWNER_SLOT, _newOwner);\n    }\n\n    function getImplementation() public view returns (address) {\n        return readAddress(IMPLEMENTATION_SLOT);\n    }\n\n    function setImplementation(address _newImplementation) onlyProxyOwner public {\n        setAddress(IMPLEMENTATION_SLOT, _newImplementation);\n    }\n\n\n    fallback () external payable {\n       return internalFallback();\n    }\n\n    function internalFallback() internal virtual {\n        address contractAddr = readAddress(IMPLEMENTATION_SLOT);\n        assembly {\n            let ptr := mload(0x40)\n            calldatacopy(ptr, 0, calldatasize())\n            let result := delegatecall(gas(), contractAddr, ptr, calldatasize(), 0, 0)\n            let size := returndatasize()\n            returndatacopy(ptr, 0, size)\n\n            switch result\n            case 0 { revert(ptr, size) }\n            default { return(ptr, size) }\n        }\n    }\n\n}"

    },

    "lib/pie-proxy/contracts/PProxyStorage.sol": {

      "content": "pragma solidity ^0.8.0;\n\ncontract PProxyStorage {\n\n    function readBool(bytes32 _key) public view returns(bool) {\n        return storageRead(_key) == bytes32(uint256(1));\n    }\n\n    function setBool(bytes32 _key, bool _value) internal {\n        if(_value) {\n            storageSet(_key, bytes32(uint256(1)));\n        } else {\n            storageSet(_key, bytes32(uint256(0)));\n        }\n    }\n\n    function readAddress(bytes32 _key) public view returns(address) {\n        return bytes32ToAddress(storageRead(_key));\n    }\n\n    function setAddress(bytes32 _key, address _value) internal {\n        storageSet(_key, addressToBytes32(_value));\n    }\n\n    function storageRead(bytes32 _key) public view returns(bytes32) {\n        bytes32 value;\n        //solium-disable-next-line security/no-inline-assembly\n        assembly {\n            value := sload(_key)\n        }\n        return value;\n    }\n\n    function storageSet(bytes32 _key, bytes32 _value) internal {\n        // targetAddress = _address;  // No!\n        bytes32 implAddressStorageKey = _key;\n        //solium-disable-next-line security/no-inline-assembly\n        assembly {\n            sstore(implAddressStorageKey, _value)\n        }\n    }\n\n    function bytes32ToAddress(bytes32 _value) public pure returns(address) {\n        return address(uint160(uint256(_value)));\n    }\n\n    function addressToBytes32(address _value) public pure returns(bytes32) {\n        return bytes32(uint256(uint160(_value)));\n    }\n\n}"

    }

  },

  "settings": {

    "remappings": [

      "@bridge/=src/modules/vedough-bridge/",

      "@forge-std/=lib/forge-std/src/",

      "@governance/=src/modules/governance/",

      "@interfaces/=src/interfaces/",

      "@mocks/=test/mocks/",

      "@oracles/=src/modules/reward-policies/",

      "@oz-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",

      "@oz/=lib/openzeppelin-contracts/contracts/",

      "@pproxy/=lib/pie-proxy/contracts/",

      "@prv/=src/modules/PRV/",

      "@rewards/=src/modules/rewards/",

      "@src/=src/",

      "@test/=test/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "erc4626-tests/=lib/openzeppelin-contracts-upgradeable/lib/erc4626-tests/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/",

      "pie-proxy/=lib/pie-proxy/contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "bytecodeHash": "ipfs"

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

    "evmVersion": "london",

    "libraries": {

      "src/modules/PRV/bitfield.sol": {

        "Bitfields": "0x013b49b72da7f746eec30c7bca848bd788c4fcfe"

      }

    }

  }

}}