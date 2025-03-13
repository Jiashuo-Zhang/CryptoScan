{{

  "language": "Solidity",

  "sources": {

    "spawner.sol": {

      "content": "pragma solidity ^0.8.9;\r\n\r\ncontract PondCoinSpawner {\r\n    event Spawned(address indexed invoker, string emotion, uint256 amount);\r\n\r\n    constructor() {\r\n\r\n    }\r\n\r\n    function spawn(address invoker, uint256 amount) external returns (bool) {\r\n        string memory emotion = _randomEmotion();\r\n        \r\n        emit Spawned(invoker, emotion, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    function _randomEmotion() internal view returns (string memory) {\r\n        uint256 randomNum = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))) % 2;\r\n\r\n        if (randomNum == 0) {\r\n            return \"Happy Pepe\";\r\n        } else {\r\n            return \"Sad Pepe\";\r\n        }\r\n    }\r\n}\r\n"

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

    }

  }

}}