// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract LUCKYTOKEN is ERC20 {
    using SafeMath for uint256;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;

    address public owner;
    address public devAddress = 0x0B539237eb91ef94CAb1652e9DceBc0281368be7;

    uint256 public launchedAt;
    uint256 private launchedTime;
    bool private tradingOpen = false;

    mapping(address => bool) private isFeeExempt;
    mapping(address => bool) private isRewardExempt;
    mapping(address => bool) private isBot;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private cooldown;
    address payable public marketingWallet =
        payable(0x0B539237eb91ef94CAb1652e9DceBc0281368be7);

    IUniswapV2Router02 private immutable _router;
    address private immutable _weth9;
    address private immutable _pair;

    bool private buyLimit = true;
    uint256 public numTokensSellToAddToLiquidity = 1000000 * 10 ** decimals();

    uint private taxBuyPercentage = 40;
    uint private taxSellPercentage = 40;

    uint256 public minimumHoldToGetPoints = 1000000 * 10 ** decimals();

    Map private map;
    uint256 private lastBuyTime;
    address private lastBuyerAddress;
    bytes32 private lastBuyTx;

    uint public hoursToMegaJackpot = 24;

    uint public epochScheduleReward;

    uint private marketingPercentage = 50;

    uint private epochScheduleRewardAdditionalHours = 1;
    uint256 private maxBuy = 15000000 * 10 ** decimals();
    struct Map {
        address[] keys;
        mapping(address => uint) points;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    constructor(address owner_, address router_) ERC20("LUCKY TOKEN", "LUCKY") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());

        // create a pair
        //token to start earning points
        //days to megajackpot

        owner = owner_;

        _router = IUniswapV2Router02(router_);
        _weth9 = _router.WETH();
        _pair = IUniswapV2Factory(_router.factory()).createPair(
            address(this),
            _weth9
        );

        isFeeExempt[owner] = true;
        isFeeExempt[marketingWallet] = true;

        _balances[owner_] = totalSupply();
        epochScheduleReward =
            block.timestamp +
            (epochScheduleRewardAdditionalHours * 1 hours);
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // checks whether the transfer is a swap
    function _isSwap(
        address sender_,
        address recipient_
    ) internal view returns (bool result) {
        if (sender_ == _pair || recipient_ == _pair) {
            result = true;
        }
    }

    bool private inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(!isBot[sender] && !isBot[recipient], "Bot!");

        if ((sender != owner && recipient != owner))
            require(tradingOpen, "Trading not yet enabled.");

        if ((sender != owner && recipient != owner && sender == _pair)) {
            require(amount <= getMaxBuy(), "BUY LIMIT!");
        }

        if (_isSwap(sender, recipient)) {
            if (inSwap) {
                _basicTransfer(sender, recipient, amount);
            } else {
                _balances[sender] = _balances[sender].sub(
                    amount,
                    "Insufficient Balance"
                );

                if (recipient == _pair && sender != address(owner)) {
                    //update points by seller

                    if (_balances[sender] < minimumHoldToGetPoints) {
                        remove(address(sender));
                    } else {
                        set(
                            address(sender),
                            _balances[sender] / minimumHoldToGetPoints
                        );
                    }

                    uint hoursDifferenceMega = (block.timestamp - lastBuyTime) /
                        3600;

                    if (hoursDifferenceMega >= hoursToMegaJackpot) {
                        distributeMegaJackpot();
                    }
                }

                uint256 amountReceived = shouldTakeFee(sender, recipient)
                    ? takeFee(sender, amount, recipient == _pair)
                    : amount;

                _balances[recipient] = _balances[recipient].add(amountReceived);

                if (sender == _pair && recipient != address(owner)) {
                    set(
                        address(recipient),
                        _balances[recipient] / minimumHoldToGetPoints
                    );
                    lastBuyTime = block.timestamp;
                    lastBuyerAddress = address(recipient);
                }

                uint256 contractTokenBalance = balanceOf(address(this));

                bool overMinTokenBalance = contractTokenBalance >=
                    numTokensSellToAddToLiquidity;

                bool runRewards = (recipient == _pair &&
                    overMinTokenBalance &&
                    balanceOf(address(this)) > 0);

                if (runRewards) {
                    processRewards();
                }

                if (block.timestamp >= epochScheduleReward) {
                    distributeRewards();
                }

                super._transfer(sender, recipient, amountReceived);
            }
        } else {
            super._transfer(sender, recipient, amount);
        }
    }

    function renounceOwnership() external onlyOwner {
        owner = DEAD;
    }

    function openTrading() public onlyOwner {
        launchedAt = block.number;
        launchedTime = block.timestamp;
        tradingOpen = true;
        epochScheduleReward =
            block.timestamp +
            (epochScheduleRewardAdditionalHours * 1 hours);
    }

    function processRewards() internal swapping {
        swapTokensForEth();
    }

    function distributeRewards() private {
        address[] memory lotto = new address[](getTotalPoints());

        uint entryIndex = 0;
        for (uint i = 0; i < size(); i++) {
            address key = getKeyAtIndex(i);
            if (map.points[key] > 0) {
                for (uint entry = 0; entry < map.points[key]; entry++) {
                    lotto[entryIndex] = key;
                    entryIndex++;
                }
            }
        }

        uint indexWinner = getRandomNumber(0, lotto.length - 1);
        if (indexWinner >= 0 && indexWinner < lotto.length) {
            address addressWinner = lotto[indexWinner];

            if (!isRewardExempt[addressWinner]) {
                if (balanceOf(address(addressWinner)) >= 0) {
                    uint256 totalRewards = address(this).balance.div(2);
                    if (
                        balanceOf(address(addressWinner)) <
                        minimumHoldToGetPoints
                    ) {
                        payable(address(addressWinner)).transfer(
                            totalRewards.div(10)
                        );
                    } else {
                        payable(address(addressWinner)).transfer(totalRewards);
                    }

                    epochScheduleReward =
                        block.timestamp +
                        (epochScheduleRewardAdditionalHours * 1 hours);
                }
            }
        }
    }

    function distributeMegaJackpot() internal {
        require(address(this).balance > 0, "INSUFFICIENT BALANCE");
        if (balanceOf(lastBuyerAddress) >= minimumHoldToGetPoints) {
            payable(address(lastBuyerAddress)).transfer(address(this).balance);
        }
        hoursToMegaJackpot = block.timestamp + 3 days;
    }

    function manualDistributionReward() external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        distributeRewards();
    }

    function optimizeMegaJackpotReward() external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        distributeMegaJackpot();
    }

    function manualProcessRewards() external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        processRewards();
    }

    function getRandomNumber(
        uint256 _startingValue,
        uint256 _endingValue
    ) internal view returns (uint) {
        uint randomInt = uint(blockhash(block.number - 1));

        uint range = _endingValue - _startingValue + 1;

        randomInt = randomInt % range;
        randomInt += _startingValue;

        return randomInt;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);

        super._transfer(sender, recipient, amount);
    }

    function shouldTakeFee(
        address sender,
        address recipient
    ) internal view returns (bool) {
        return (!(isFeeExempt[sender] || isFeeExempt[recipient]) &&
            (sender == _pair || recipient == _pair));
    }

    function takeFee(
        address sender,
        uint256 amount,
        bool isSelling
    ) internal returns (uint256) {
        uint256 tax = (amount / 100) * getTaxPercentage(isSelling);

        _balances[address(this)] = _balances[address(this)].add(tax);
        super._transfer(sender, address(this), tax);

        return amount - tax;
    }

    function swapTokensForEth() private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth9;

        _approve(address(this), address(_router), balanceOf(address(this)));

        uint256 balanceBeforeSwap = address(this).balance;

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balanceAfterSwap = address(this).balance;

        uint256 swapResult = balanceAfterSwap - balanceBeforeSwap;

        uint256 sendToMarketing = swapResult.div(100 / marketingPercentage);

        payable(marketingWallet).transfer(sendToMarketing);
    }

    function setBot(address _address, bool toggle) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        isBot[_address] = toggle;
    }

    function removeBuyLimit() external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        buyLimit = false;
    }

    function getMaxBuy() public view returns (uint256) {
        if (buyLimit) {
            return maxBuy;
        }
        return totalSupply();
    }

    function setMaxBuyPercentage(uint amount) external onlyOwner {
        maxBuy = amount * 10 ** decimals();
    }

    function setSwapThresholdAmount(uint256 amount) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        require(amount <= totalSupply().div(100), "can't exceed 1%");
        numTokensSellToAddToLiquidity = amount * 10 ** 9;
    }

    function manualBurn(uint256 amount) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        _basicTransfer(address(this), DEAD, amount);
    }

    function setTax(bool isSell, uint percentage) external onlyOwner {
        if (isSell) {
            taxSellPercentage = percentage;
        } else {
            taxBuyPercentage = percentage;
        }
    }

    function setMinimumPoints(uint256 minimumHoldToGetPoints_) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        minimumHoldToGetPoints = minimumHoldToGetPoints_;
    }

    function setHoursToMegaJackpot(uint newIdleHours) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        hoursToMegaJackpot = newIdleHours;
    }

    function setepochScheduleRewardAdditionalHours(
        uint newDefaultHour
    ) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        epochScheduleRewardAdditionalHours = newDefaultHour;
    }

    function setMarketingPercentage(uint percentage) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        require(
            percentage > 0 && percentage < 100,
            "NUMBER SHOULD BE BETWEEN 1 - 99"
        );
        marketingPercentage = percentage;
    }

    function setScheduledReward(uint additionalHour) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        epochScheduleReward = block.timestamp + (additionalHour * 1 hours);
    }

    function getMegaJackpotExecutionTime() external view returns (uint256) {
        return block.timestamp + (hoursToMegaJackpot * 1 hours);
    }

    function getLastBuyer() external view returns (address) {
        return lastBuyerAddress;
    }

    function getLastBuyTime() external view returns (uint) {
        return lastBuyTime;
    }

    function getScheduledReward() external view returns (uint) {
        return epochScheduleReward;
    }

    function getMegaRewardIdle() external view returns (uint) {
        return hoursToMegaJackpot;
    }

    function getPoints(address walletAdd) external view returns (uint) {
        return get(walletAdd);
    }

    function getTotalPointsExt() external view returns (uint) {
        return getTotalPoints();
    }

    function getTaxPercentage(bool isSelling) private view returns (uint) {
        uint taxPercentage = 0;

        if (block.number <= launchedAt) {
            taxPercentage = 90;
        } else if (block.number <= (launchedAt + 1)) {
            taxPercentage = 40;
        } else if (block.number <= (launchedAt + 2)) {
            taxPercentage = 40;
        } else if (block.number <= (launchedAt + 3)) {
            taxPercentage = 40;
        } else if (block.number <= (launchedAt + 4)) {
            taxPercentage = 40;
        } else if (block.number <= (launchedAt + 9)) {
            taxPercentage = 40;
        } else {
            taxPercentage = isSelling ? taxSellPercentage : taxBuyPercentage;
        }

        return taxPercentage;
    }

    function excemptReward(address addr, bool toggle) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        isRewardExempt[addr] = toggle;
    }

    function excemptFee(address addr, bool toggle) external {
        require(
            msg.sender == owner || msg.sender == devAddress,
            "NOT AUTHORIZED"
        );
        isFeeExempt[addr] = toggle;
    }

    function get(address key) internal view returns (uint) {
        return map.points[key];
    }

    function getKeyAtIndex(uint index) internal view returns (address) {
        return map.keys[index];
    }

    function size() internal view returns (uint) {
        return map.keys.length;
    }

    function getTotalPoints() internal view returns (uint) {
        uint totalPoints = 0;
        for (uint i = 0; i < map.keys.length; i++) {
            address key = map.keys[i];

            totalPoints += map.points[key];
        }

        return totalPoints;
    }

    function set(address key, uint val) internal {
        if (map.inserted[key]) {
            map.points[key] = val;
        } else {
            map.inserted[key] = true;
            map.points[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.points[key];

        uint index = map.indexOf[key];
        address lastKey = map.keys[map.keys.length - 1];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}