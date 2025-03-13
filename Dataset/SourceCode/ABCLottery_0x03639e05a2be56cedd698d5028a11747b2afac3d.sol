/*

https://t.me/AppleBitsCoinNews



https://twitter.com/Applebitseth





 ▄▄▄       ██▓███   ██▓███   ██▓    ▓█████  ▄▄▄▄    ██▓▄▄▄█████▓  ██████  ▄████▄   ▒█████   ██▓ ███▄    █ 

▒████▄    ▓██░  ██▒▓██░  ██▒▓██▒    ▓█   ▀ ▓█████▄ ▓██▒▓  ██▒ ▓▒▒██    ▒ ▒██▀ ▀█  ▒██▒  ██▒▓██▒ ██ ▀█   █ 

▒██  ▀█▄  ▓██░ ██▓▒▓██░ ██▓▒▒██░    ▒███   ▒██▒ ▄██▒██▒▒ ▓██░ ▒░░ ▓██▄   ▒▓█    ▄ ▒██░  ██▒▒██▒▓██  ▀█ ██▒

░██▄▄▄▄██ ▒██▄█▓▒ ▒▒██▄█▓▒ ▒▒██░    ▒▓█  ▄ ▒██░█▀  ░██░░ ▓██▓ ░   ▒   ██▒▒▓▓▄ ▄██▒▒██   ██░░██░▓██▒  ▐▌██▒

 ▓█   ▓██▒▒██▒ ░  ░▒██▒ ░  ░░██████▒░▒████▒░▓█  ▀█▓░██░  ▒██▒ ░ ▒██████▒▒▒ ▓███▀ ░░ ████▓▒░░██░▒██░   ▓██░

 ▒▒   ▓▒█░▒▓▒░ ░  ░▒▓▒░ ░  ░░ ▒░▓  ░░░ ▒░ ░░▒▓███▀▒░▓    ▒ ░░   ▒ ▒▓▒ ▒ ░░ ░▒ ▒  ░░ ▒░▒░▒░ ░▓  ░ ▒░   ▒ ▒ 

  ▒   ▒▒ ░░▒ ░     ░▒ ░     ░ ░ ▒  ░ ░ ░  ░▒░▒   ░  ▒ ░    ░    ░ ░▒  ░ ░  ░  ▒     ░ ▒ ▒░  ▒ ░░ ░░   ░ ▒░

  ░   ▒   ░░       ░░         ░ ░      ░    ░    ░  ▒ ░  ░      ░  ░  ░  ░        ░ ░ ░ ▒   ▒ ░   ░   ░ ░ 

      ░  ░                      ░  ░   ░  ░ ░       ░                 ░  ░ ░          ░ ░   ░           ░ 

                                                 ░                       ░                                



*/





// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;



interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

}



contract ABCLottery {

    error NotUser();

    error NotToTime();

    error NotOwner();

    error NotEnoughETH();



    address immutable owner;

    IERC20 public abc;



    uint public number;

    uint public onceLotteryAward;



    mapping(address => uint) public userLastStartLottery;



    uint total = 1 * 1e6;



    event Record(

        uint number,

        address user,

        bool result,

        uint userNum,

        uint SysNum

    );



    constructor(address _token) payable {

        owner = msg.sender;

        abc = IERC20(_token);

        onceLotteryAward = msg.value / 8;

    }



    function setOnceLotteryAward(uint _n) external {

        if (msg.sender != owner) {

            revert NotOwner();

        }



        onceLotteryAward = _n;

    }



    function withdraw() external {

        if (msg.sender != owner) {

            revert NotOwner();

        }

        payable(msg.sender).transfer(address(this).balance);

    }



    function getUserRate(address _user) public view returns (uint) {

        return abc.balanceOf(_user) / (1000 * 10 ** 18);

    }



    function generateRandomNumber() public view returns (uint256) {

        uint256 random = uint256(

            keccak256(abi.encodePacked(block.timestamp, msg.sender, block.coinbase))

        ) % 100;

        return random;

    }



    function rollApple() external {

        require(msg.sender == tx.origin, "toxin apple");

        uint userNum = getUserRate(msg.sender);

        if (userNum == 0) {

            revert NotUser();

        }

        if (userLastStartLottery[msg.sender] + 1 days > block.timestamp) {

            revert NotToTime();

        }

        if (address(this).balance < onceLotteryAward) {

            revert NotEnoughETH();

        }

        uint SysNum = generateRandomNumber();



        //state change

        userLastStartLottery[msg.sender] = block.timestamp;

        number++;



        bool result;

        if (userNum > SysNum) {

            result = true;

            payable(msg.sender).transfer(onceLotteryAward);

        }



        emit Record(number, msg.sender, result, userNum, SysNum);

    }



    receive() external payable {

        if (msg.sender != owner) {

            revert NotOwner();

        }

        onceLotteryAward = address(this).balance / 8;

    }

}