{{

  "language": "Solidity",

  "sources": {

    "contracts/BIFI/utils/BeefyContractDeployer.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract BeefyContractDeployer {\n\n    event ContractDeployed(bytes32 indexed salt, address deploymentAddress);\n\n    // Deploy a contract, if this address matches contract deployer on other chains it should match deployment address if salt/bytecode match., \n    function deploy(bytes32 _salt, bytes memory _bytecode) external returns (address deploymentAddress) {\n        address addr;\n        assembly {\n            addr := create2(0, add(_bytecode, 0x20), mload(_bytecode), _salt)\n            if iszero(extcodesize(addr)) {\n                 revert(0, 0)\n            }\n        }\n\n        emit ContractDeployed(_salt, addr);\n        return addr;\n    }\n\n    // Get address by salt and bytecode.\n    function getAddress(bytes32 _salt, bytes memory _bytecode) external view returns (address) {\n        bytes32 hash = keccak256(\n            abi.encodePacked(\n                bytes1(0xff), address(this), _salt, keccak256(_bytecode)\n            )\n        );\n        return address (uint160(uint(hash)));\n    }\n\n    // Creat salt by int or string.\n    function createSalt(uint _num, string calldata _string) external pure returns (bytes32) {\n        return _num > 0 ? keccak256(abi.encode(_num)) : keccak256(abi.encode(_string));\n    }\n}"

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