/**

 *Submitted for verification at Etherscan.io on 2019-10-18

*/



pragma solidity 0.5.12;



contract Lottery {

    address public manager;

    address payable[] public players;



    event PlayerEntered(address indexed player, uint256 value);

    event WinnerPicked(address indexed winner);



    constructor() public {

        manager = msg.sender;

    }



    modifier restricted() {

        require(msg.sender == manager, "only contract creator allowed");

        _;

    }



    function () external payable {

        require(msg.value > .01 ether, "must pay the minimum amount");

        require(players.length < 50, "maximally 50 players");

        emit PlayerEntered(msg.sender, msg.value);

        players.push(msg.sender);

    }



    // This RNG is not secure, for demonstration purposes only

    function random() private view returns (uint) {

        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));

    }



    function pickWinner() public restricted  returns (address) {

        uint index = random() % players.length;

        address payable winner = players[index];

        players = new address payable[](0);

        emit WinnerPicked(winner);

        winner.transfer(address(this).balance);

        return winner;

    }



    function getPlayers() public view returns (address payable[] memory) {

        return players;

    }



}