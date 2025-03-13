// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



contract VersusWager {

    struct Game {

        address payable playerA;

        address payable playerB;

        uint256 stake;

        bool isFlipped;

        address winner;

    }



    mapping(string => Game) public games; // Maps gameID to Game.

    mapping(uint256 => string) public gameNumbers; // Maps gameNumber to gameID.

    uint256 public currentGameNumber = 0;

    string[] public openGames;

    

    function createGame(string memory gameID) public payable {

        require(bytes(gameID).length <= 10, "GameID too long");

        require(games[gameID].playerA == address(0), "GameID already exists");

        

    games[gameID] = Game({

        playerA: payable(msg.sender),

        playerB: payable(address(0)),

        stake: msg.value,

        isFlipped: false,

        winner: address(0)

    });





        currentGameNumber++;

        gameNumbers[currentGameNumber] = gameID;

        openGames.push(gameID);

    }



    function joinGame(string memory gameID) public payable {

        require(games[gameID].playerA != address(0), "Game does not exist");

        require(games[gameID].playerB == address(0), "Game already has a second player");

        require(msg.value == games[gameID].stake, "Must send the correct stake amount");



        games[gameID].playerB = payable(msg.sender);



        // Removing game from the openGames list

        for(uint i = 0; i < openGames.length; i++) {

            if(keccak256(abi.encodePacked(openGames[i])) == keccak256(abi.encodePacked(gameID))) {

                openGames[i] = openGames[openGames.length - 1];

                openGames.pop();

                break;

            }

        }

    }



    function flip(string memory gameID) public {

        require(games[gameID].playerB != address(0), "Game does not have a second player yet");

        require(!games[gameID].isFlipped, "Game has already been flipped");

        require(msg.sender == games[gameID].playerA || msg.sender == games[gameID].playerB, "Only participants can initiate the flip");

        

        uint256 randomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))) % 2;

        if(randomness == 0) {

            games[gameID].winner = games[gameID].playerA;

            games[gameID].playerA.transfer(games[gameID].stake * 2);

        } else {

            games[gameID].winner = games[gameID].playerB;

            games[gameID].playerB.transfer(games[gameID].stake * 2);

        }

        games[gameID].isFlipped = true;

    }

    

    function getGame(string memory gameID) public view returns(Game memory) {

        return games[gameID];

    }



    function getOpenGames() public view returns(string[] memory) {

        return openGames;

    }



    function getAllGames() public view returns(string[] memory) {

        string[] memory allGames = new string[](currentGameNumber);

        for(uint i = 0; i < currentGameNumber; i++) {

            allGames[i] = gameNumbers[i+1];

        }

        return allGames;

    }



    function getUnflippedGames(address player) public view returns(string[] memory) {

        uint count = 0;

        for(uint i = 0; i < openGames.length; i++) {

            if(games[openGames[i]].playerA == player || games[openGames[i]].playerB == player) {

                count++;

            }

        }

        

        string[] memory unflipped = new string[](count);

        uint j = 0;

        for(uint i = 0; i < openGames.length; i++) {

            if(games[openGames[i]].playerA == player || games[openGames[i]].playerB == player) {

                unflipped[j] = openGames[i];

                j++;

            }

        }

        return unflipped;

    }

}