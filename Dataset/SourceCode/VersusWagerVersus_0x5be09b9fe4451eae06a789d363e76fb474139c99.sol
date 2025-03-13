{{

  "language": "Solidity",

  "sources": {

    "contracts/Versus.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\ninterface IERC20 {\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n}\r\n\r\ncontract VersusWagerVersus {\r\n    IERC20 public versusToken = IERC20(0xf2F80327097d312334Fe4E665F60a83CB6ce71B3);\r\n\r\n    struct Game {\r\n        address payable playerA;\r\n        address payable playerB;\r\n        uint256 stake;\r\n        bool isFlipped;\r\n        address winner;\r\n    }\r\n\r\n    mapping(string => Game) public games;\r\n    mapping(uint256 => string) public gameNumbers;\r\n    string[] public openGames;\r\n    string[] public allGames;\r\n    \r\n    uint256 public currentGameNumber = 0;\r\n\r\n    function createGame(string memory gameID, uint256 amount) public {\r\n        require(bytes(gameID).length <= 10, \"GameID too long\");\r\n        require(games[gameID].playerA == address(0), \"GameID already exists\");\r\n        \r\n        require(versusToken.transferFrom(msg.sender, address(this), amount), \"Token transfer failed\");\r\n        \r\n        games[gameID] = Game({\r\n            playerA: payable(msg.sender),\r\n            playerB: payable(address(0)),\r\n            stake: amount,\r\n            isFlipped: false,\r\n            winner: address(0)\r\n        });\r\n\r\n        currentGameNumber++;\r\n        gameNumbers[currentGameNumber] = gameID;\r\n        openGames.push(gameID);\r\n        allGames.push(gameID);\r\n    }\r\n\r\n    function joinGame(string memory gameID, uint256 amount) public {\r\n        require(games[gameID].playerA != address(0), \"Game does not exist\");\r\n        require(games[gameID].playerB == address(0), \"Game already has a second player\");\r\n        require(amount == games[gameID].stake, \"Must send the correct stake amount\");\r\n        \r\n        require(versusToken.transferFrom(msg.sender, address(this), amount), \"Token transfer failed\");\r\n        games[gameID].playerB = payable(msg.sender);\r\n\r\n        // Removing game from the openGames list\r\n        for(uint i = 0; i < openGames.length; i++) {\r\n            if(keccak256(abi.encodePacked(openGames[i])) == keccak256(abi.encodePacked(gameID))) {\r\n                openGames[i] = openGames[openGames.length - 1];\r\n                openGames.pop();\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    function flip(string memory gameID) public {\r\n        require(msg.sender == games[gameID].playerA || msg.sender == games[gameID].playerB, \"Only participating players can flip\");\r\n        require(!games[gameID].isFlipped, \"Game already flipped\");\r\n\r\n        uint256 randomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))) % 2;\r\n\r\n        if(randomness == 0) {\r\n            games[gameID].winner = games[gameID].playerA;\r\n            require(versusToken.transfer(games[gameID].playerA, games[gameID].stake * 2), \"Token transfer failed\");\r\n        } else {\r\n            games[gameID].winner = games[gameID].playerB;\r\n            require(versusToken.transfer(games[gameID].playerB, games[gameID].stake * 2), \"Token transfer failed\");\r\n        }\r\n        games[gameID].isFlipped = true;\r\n    }\r\n\r\n    function getGame(string memory gameID) public view returns (Game memory) {\r\n        return games[gameID];\r\n    }\r\n\r\n    function getOpenGames() public view returns (string[] memory) {\r\n        return openGames;\r\n    }\r\n\r\n    function getAllGames() public view returns (string[] memory) {\r\n        return allGames;\r\n    }\r\n\r\n    function getUnflippedGames(address playerAddress) public view returns (string[] memory) {\r\n        string[] memory unflippedGames = new string[](allGames.length);\r\n        uint256 count = 0;\r\n\r\n        for(uint256 i = 0; i < allGames.length; i++) {\r\n            if((games[allGames[i]].playerA == playerAddress || games[allGames[i]].playerB == playerAddress) && !games[allGames[i]].isFlipped) {\r\n                unflippedGames[count] = allGames[i];\r\n                count++;\r\n            }\r\n        }\r\n\r\n        string[] memory result = new string[](count);\r\n        for(uint256 i = 0; i < count; i++) {\r\n            result[i] = unflippedGames[i];\r\n        }\r\n\r\n        return result;\r\n    }\r\n}\r\n"

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