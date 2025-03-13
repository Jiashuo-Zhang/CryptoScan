/**

 *Submitted for verification at Etherscan.io on 2023-07-08

*/



/* SPDX-License-Identifier: MIT



https://pepeflip.money



https://t.me/pepeflip



*/



pragma solidity ^0.8.0;



contract CoinFlip {

    enum Side {Heads, Tails}



    struct Bet {

        address player;

        uint256 amount;

        Side choice;

    }



    event CoinFlipped(address indexed player, Side result, uint256 amountWon);

    event MaxBetChanged(uint256 newMaxBet);

    event Withdrawal(address indexed owner, uint256 amount);

    event Deposit(address indexed depositor, uint256 amount);



    uint256 public maxBet = 0.2 ether; // Maximum bet amount



    address public owner;



    constructor() {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        require(msg.sender == owner, "Only the contract owner can call this function");

        _;

    }

  function deposit() external payable {

        emit Deposit(msg.sender, msg.value);

    }

    function flipCoin(Side choice) external payable {

        require(msg.value > 0, "Bet amount must be greater than zero");

        require(

            choice == Side.Heads || choice == Side.Tails,

            "Invalid choice"

        );

        require(msg.value <= maxBet, "Bet amount exceeds maximum limit");



        Side result = randomResult();

        uint256 amountWon = calculateWinAmount(msg.value, choice, result);



        if (amountWon > 0) {

            payable(msg.sender).transfer(amountWon);

        }



        emit CoinFlipped(msg.sender, result, amountWon);

    }



    function randomResult() internal view returns (Side) {

        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao)));

        return Side(randomValue % 2);

    }



    function calculateWinAmount(

        uint256 betAmount,

        Side choice,

        Side result

    ) internal pure returns (uint256) {

        if (choice == result) {

            return ((betAmount * 2) * 95) / 100; // Win amount is double the bet

        }

        return 0; // Bet lost

    }



    function changeMaxBet(uint256 newMaxBet) external onlyOwner {

        maxBet = newMaxBet;

        emit MaxBetChanged(newMaxBet);

    }



    function withdraw(uint256 amount) external onlyOwner {

        require(amount <= address(this).balance, "Amount exceeds contract balance");

        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);

    }

}