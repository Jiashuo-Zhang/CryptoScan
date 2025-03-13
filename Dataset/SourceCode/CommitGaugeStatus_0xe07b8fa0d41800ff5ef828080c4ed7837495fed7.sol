{{

  "language": "Solidity",

  "sources": {

    "/contracts/CommitGaugeStatus.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.10;\r\n\r\nimport \"./interfaces/ICurveGauge.sol\";\r\nimport \"./interfaces/IGaugeController.sol\";\r\nimport \"./interfaces/IZkEvmBridge.sol\";\r\n\r\ncontract CommitGaugeStatus {\r\n\r\n    bytes4 private constant updateSelector = bytes4(keccak256(\"setGauge(address,bool,uint256)\"));\r\n    address public constant gaugeController = address(0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB);\r\n    address public constant bridge = address(0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe);\r\n    uint256 public constant epochDuration = 86400 * 7;\r\n    \r\n    function currentEpoch() public view returns (uint256) {\r\n        return block.timestamp/epochDuration*epochDuration;\r\n    }\r\n\r\n    function commit(\r\n        address _gauge,\r\n        address _contractAddr\r\n    ) external  {\r\n        //check killed for status\r\n        bool active = isValidGauge(_gauge);\r\n\r\n        //build data\r\n        bytes memory data = abi.encodeWithSelector(updateSelector, _gauge, active, currentEpoch());\r\n\r\n        //submit to L2\r\n        uint32 destinationNetwork = 1;\r\n        bool forceUpdateGlobalExitRoot = true;\r\n        IZkEvmBridge(bridge).bridgeMessage{value:0}(\r\n            destinationNetwork,\r\n            _contractAddr,\r\n            forceUpdateGlobalExitRoot,\r\n            data\r\n        );\r\n    }\r\n\r\n    function isValidGauge(address _gauge) public view returns(bool){\r\n        return IGaugeController(gaugeController).get_gauge_weight(_gauge) > 0 && !ICurveGauge(_gauge).is_killed();\r\n    }\r\n}"

    },

    "/contracts/interfaces/IZkEvmBridge.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.10;\r\n\r\n\r\ninterface IZkEvmBridge{\r\n\tfunction bridgeMessage(\r\n\t\tuint32 destinationNetwork,\r\n\t\taddress destinationAddress,\r\n\t\tbool forceUpdateGlobalExitRoot,\r\n\t\tbytes calldata metadata\r\n\t) external payable;\r\n}\r\n"

    },

    "/contracts/interfaces/IGaugeController.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.10;\r\n\r\ninterface IGaugeController {\r\n    function get_gauge_weight(address _gauge) external view returns(uint256);\r\n    function vote_user_slopes(address,address) external view returns(uint256,uint256,uint256);//slope,power,end\r\n    function vote_for_gauge_weights(address,uint256) external;\r\n    function add_gauge(address,int128,uint256) external;\r\n}"

    },

    "/contracts/interfaces/ICurveGauge.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.10;\r\n\r\ninterface ICurveGauge {\r\n    function is_killed() external view returns(bool);\r\n}"

    }

  },

  "settings": {

    "remappings": [],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "evmVersion": "london",

    "libraries": {},

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