{{

  "language": "Solidity",

  "sources": {

    "src/TheSpread.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.8.19;\n\ninterface IConcord {\n    function burn(address _from, uint256 _token, uint256 _quantity) external;\n}\n\ncontract TheSpread {\n    event InfectionSpread(address indexed sender, uint256 indexed infectedToken, uint256 time);\n\n    address public concordAddress;\n    uint256 public infectionPrice = 0.01 ether;\n\n    address public constant WAGDIE = 0x8d2Eb1c6Ab5D87C5091f09fFE4a5ed31B1D9CF71;\n\n    constructor(address _concordAddress) {\n        concordAddress = _concordAddress;\n    }\n\n    function spreadInfections(uint256 quantity) external {\n        // Burn the mushrooms\n        IConcord(concordAddress).burn(msg.sender, 15, quantity);\n        // Emit infection events\n        for (uint256 i = 0; i < quantity; i++) {\n            emit InfectionSpread(msg.sender, random(6666, i), block.timestamp);\n        }\n    }\n\n    function infectWagdie(uint256 tokenId) external payable {\n        require(tokenId > 0, \"Invalid token\");\n        require(msg.value == infectionPrice, \"More sacrifice required\");\n        // Sweep payment\n        // solhint-disable-next-line no-unused-vars\n        (bool sent, bytes memory data) = WAGDIE.call{ value: msg.value }(\"\");\n        require(sent, \"Failed to send Ether\");\n        // Increase price for next infection\n        infectionPrice = infectionPrice + 0.0025 ether;\n        // Burn Concord\n        IConcord(concordAddress).burn(msg.sender, 15, 1);\n        // Emit infection\n        emit InfectionSpread(msg.sender, tokenId, block.timestamp);\n    }\n\n    // Basic Random Function\n    function random(uint256 num, uint256 iteration) public view returns (uint256) {\n        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, iteration))) % num;\n    }\n\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "@prb/test/=lib/prb-test/src/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/",

      "prb-math/=lib/prb-math/src/",

      "prb-test/=lib/prb-test/src/",

      "solc_version /= \"0.8.19\"/",

      "src/=src/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 10000

    },

    "metadata": {

      "bytecodeHash": "none",

      "appendCBOR": false

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

    "libraries": {}

  }

}}