pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./LeagueBase.sol";
import "./AdminBase.sol";

contract League is LeagueBase,AdminBase {
    using SafeMath for uint;
    uint public _dailyInvest = 0;
    uint public _staticPool = 0;
    uint public _outInvest = 0;
    uint public _safePool = 0;
    uint public _gloryPool = 0;
    mapping(address => Player) allPlayers;
    address[] public allAddress = new address[](0);
    uint[] public lockedRound = new uint[](0);
    address[] dailyPlayers = new address[](0);
    uint _rand = 88;
    uint _startTime = 0;
    bool _actived = true;

    function () external payable {
        if(msg.value > 0){
            invest(address(0));
        }else{
            withdraw();
        }
    }

    function invest(address payable parentAddr) public payable isHuman() {
        require(msg.value >= 0.5 ether, "Parameter Error");
        require(isStart(), "Game Start Limit");
        require(_actived, "Game Active Limit");
        bool isFirst = false;
        if(allPlayers[msg.sender].index == 0){
            isFirst = true;
            if(msg.sender == parentAddr) parentAddr = address(0);
            Player memory parent = allPlayers[parentAddr];
            if(parent.index == 0) {
                parentAddr = address(0);
            }
            allPlayers[msg.sender] = Player({
                self : msg.sender,
                parent : parentAddr,
                bonus: 0,
                totalBonus : 0,
                invest : msg.value,
                sons : 0,
                round: lockedRound.length,
                index: allAddress.length
            });
            allAddress.push(msg.sender);
        }else{
            Player storage user = allPlayers[msg.sender];
            uint totalBonus = 0;
            uint bonus = 0;
            bool outFlag;
            (totalBonus, bonus, outFlag) = calcBonus(user.self);
            require(outFlag, "Out Only");
            user.bonus = bonus;
            user.totalBonus = 0;
            user.invest = msg.value;
            user.round = lockedRound.length;
        }
        _dailyInvest = _dailyInvest.add(msg.value);
        _safePool = _safePool.add(msg.value.div(20));
        _gloryPool = _gloryPool.add(msg.value.mul(3).div(25));
        _staticPool = _staticPool.add(msg.value.mul(11).div(20));
        dailyPlayers.push(msg.sender);
        Player memory self = allPlayers[msg.sender];
        Player memory parent = allPlayers[self.parent];
        uint parentVal = msg.value.div(10);
        if(isFirst == true) {
            investBonus(parent.self, parentVal, true, 1);
        } else {
            investBonus(parent.self, parentVal, true, 0);
        }
        Player memory grand = allPlayers[parent.parent];
        if(grand.sons >= 2){
            uint grandVal = msg.value.div(20);
            investBonus(grand.self, grandVal, true, 0);
        }
        emit logUserInvest(msg.sender, parentAddr, isFirst, msg.value, now);
    }

    function calcBonus(address target) public view returns(uint, uint, bool) {
        Player memory player = allPlayers[target];
        if(player.invest == 0) {
            return (player.totalBonus, player.bonus, true);
        }
        uint lockedBonus = calcLocked(target);
        uint totalBonus = player.totalBonus.add(lockedBonus);
        bool outFlag = false;
        uint less = 0;
        uint maxIncome = 0;
        if(player.invest < 11 ether){
            maxIncome = player.invest.mul(3).div(2);
        }else if(player.invest >= 11 ether && player.invest < 21 ether){
            maxIncome = player.invest.mul(9).div(5);
        }else if(player.invest >= 21 ether){
            maxIncome = player.invest.mul(2);
        }
        if (totalBonus >= maxIncome) {
            less = totalBonus.sub(maxIncome);
            outFlag = true;
        }
        totalBonus = totalBonus.sub(less);
        uint bonus = player.bonus.add(lockedBonus).sub(less);
        return (totalBonus, bonus, outFlag);
    }

    function calcLocked(address target) public view returns(uint) {
        Player memory self = allPlayers[target];
        uint randTotal = 0;
        for(uint i = self.round; i<lockedRound.length; i++){
            randTotal = randTotal.add(lockedRound[i]);
        }
        uint lockedBonus = self.invest.mul(randTotal).div(1000);
        return lockedBonus;
    }

    function saveRound() internal {
        uint releaseLocked = _safePool.sub(_outInvest).div(5);
        uint x = _staticPool.div(releaseLocked);
        uint rand = 0;
        if(x<20) {
            rand = 3;
            if(_staticPool < releaseLocked.mul(rand).div(10)) rand = 0;
        } else if (x>=20 && x<30) rand = 5;
        else if (x>=30 && x<40)  rand = 10;
        else if (x>=40) rand = 20;
        _staticPool = _staticPool.sub(releaseLocked.mul(rand).div(10));
        lockedRound.push(rand);
        emit logRandom(rand, now);
    }


    function sendGloryAward(address[] memory plays, uint[] memory selfAmount, uint totalAmount)
    public onlyAdmin() {
        _gloryPool = _gloryPool.sub(totalAmount);
        for(uint i = 0; i < plays.length; i++){
            investBonus(plays[i], selfAmount[i], false, 0);
            emit logGlory(plays[i], selfAmount[i], now);
        }
    }

    function lottery() internal {
        uint luckNum = dailyPlayers.length;
        if (luckNum >= 30) {
            luckNum = 30;
        }
        address[] memory luckyDogs = new address[](luckNum);
        uint[] memory luckyAmounts = new uint[](luckNum);
        if (luckNum <= 30) {
            for(uint i = 0; i<luckNum; i++) {
                luckyDogs[i] = dailyPlayers[i];
            }
        } else {
            for(uint i = 0; i<luckNum; i++){
                uint random = getRandom(dailyPlayers.length);
                luckyDogs[i] = dailyPlayers[random];
                delete dailyPlayers[random];
            }
        }
        uint totalRandom = 0;
        for(uint i = 0; i<luckNum; i++){
            luckyAmounts[i] = getRandom(50).add(1);
            totalRandom = totalRandom.add(luckyAmounts[i]);
        }
        uint lotteryAmount = 0;
        uint luckyPool = _dailyInvest.mul(3).div(100);
        for(uint i = 0; i<luckNum; i++){
            lotteryAmount = luckyAmounts[i].mul(luckyPool).div(totalRandom);
            investBonus(luckyDogs[i], lotteryAmount, false ,0);
            emit logLucky(luckyDogs[i], lotteryAmount, now, 1);
        }
    }

    function leagueGame() public onlyAdmin() {
        saveRound();
        msg.sender.transfer(_dailyInvest.div(10));
        lottery();
        _dailyInvest = 0;
        delete dailyPlayers;
    }

    function withdraw() public isHuman() {
        require(isStart(), "Game Start Limit");
        Player storage user = allPlayers[msg.sender];
        uint totalBonus = 0;
        uint withdrawBonus = 0;
        bool outFlag;
        (totalBonus, withdrawBonus, outFlag) = calcBonus(user.self);
        if(outFlag) {
            _outInvest = _outInvest.add(user.invest);
            user.totalBonus = 0;
            user.invest = 0;
        }else {
            user.totalBonus = totalBonus;
        }
        require(withdrawBonus>0, "Above 0 Limit");
        user.round = lockedRound.length;
        user.bonus = 0;
        msg.sender.transfer(withdrawBonus);
        emit logWithDraw(msg.sender, withdrawBonus, now);
    }

    function investBonus(address targetAddr, uint bonus, bool totalFlag, uint addson)
    internal {
        if(targetAddr == address(0) || allPlayers[targetAddr].invest == 0 || bonus == 0) return;
        Player storage target = allPlayers[targetAddr];
        target.bonus = target.bonus.add(bonus);
        if(addson != 0) target.sons = target.sons+1;
        if(totalFlag) target.totalBonus = target.totalBonus.add(bonus);
    }

    function getRandom(uint max)
    internal returns(uint) {
        _rand++;
        uint rand = _rand**2;
        uint random = uint(keccak256(abi.encodePacked(block.difficulty, now, msg.sender, rand)));
        return random % max;
    }

    function start(uint time) external onlyAdmin() {
        require(time > now, "Invalid Time");
        _startTime = time;
    }

    function setActive(bool flag) public onlyAdmin() {
        _actived = flag;
    }

    function startArgs(uint staticPool, uint safePool, uint outInvest, uint dailyInvest, uint[] memory locks) public onlyAdmin() {
        _staticPool = staticPool;
        _safePool = safePool;
        _outInvest = outInvest;
        _dailyInvest = dailyInvest;
        for(uint i = 0; i<locks.length; i++) {
            lockedRound.push(locks[i]);
        }
    }

    function startGame(
        address[] memory plays, address[] memory parents,
        uint[] memory bonus, uint[] memory totalBonus,
        uint[] memory totalInvests, uint[] memory sons, uint[] memory round)
    public onlyAdmin() {
        for(uint i = 0; i<plays.length; i++) {
            Player storage user = allPlayers[plays[i]];
            user.self = plays[i];
            user.parent = parents[i];
            user.bonus = bonus[i];
            user.totalBonus = totalBonus[i];
            user.invest = totalInvests[i];
            user.sons = sons[i];
            user.round = round[i];
            user.index = allAddress.length;
            allAddress.push(plays[i]);
        }
    }

    function isStart() public view returns(bool) {
        return _startTime != 0 && now > _startTime;
    }

    function userInfo(address payable target)
    public view returns (address, address, address, uint, uint, uint, uint, uint){
        Player memory self = allPlayers[target];
        Player memory parent = allPlayers[self.parent];
        Player memory grand = allPlayers[parent.parent];
        Player memory great = allPlayers[grand.parent];
        return (parent.self, grand.self, great.self,
        self.bonus, self.totalBonus, self.invest, self.sons, self.round);
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "Human Only");
        _;
    }

}