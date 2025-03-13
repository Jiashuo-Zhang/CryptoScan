// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../contracts/WSTFX.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract WSTFXpreSaleContract is Ownable {

    WSTFXtoken private tokenContract;
    using SafeMath for uint256;

    //Goerli  usd/eth:  0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    // usdt use wstfx:  0x8f7296E684BD57c5C898FA78043d06D164208c3D

    address private usdtEthPair = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
	address private usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    AggregatorV3Interface internal priceFeed;

    bool private _active;
    bool private _claim;
    mapping(address => uint256) private _accountTotalPurchased;
    mapping(address => uint256) private _accountUSDpurchased;
    mapping(uint256 => address) private _addressSeq;
    uint256 private _sequence;
    uint256 private _totalUSD;
    uint256 private _totalPurchased;
    uint256[10] private _stagePrice;
    uint256 private stage;
    uint256[10] private _stageAvailableQty;
    uint256 private constant MAX_STAGE = 9;
    uint256 private constant MAX_USDT = 10000 * 10 ** 18;
    

    event BuyWithETH(address indexed sender, uint256 amount);
    event BuyWithFiat(address indexed sender, uint256 amount);
    event WithdrawalETH(address indexed sender, uint256 amount);
    event PaymentSent(address indexed sender, uint256 amount);
    event BuyWithUSDT(address indexed sender, uint256 amount);
    event Claim(address indexed sender, uint256 amount);


    constructor(WSTFXtoken _tokenContract) {
        _active = false;
        _claim = false;
        stage = 0;
        tokenContract = _tokenContract;
       
        priceFeed = AggregatorV3Interface(
            usdtEthPair
        );
        _sequence = 0;
        _stagePrice[0] = 10 * 10 ** 15;  // Make sure to change !
        _stagePrice[1] = 20 * 10 ** 15;
        _stagePrice[2] = 25 * 10 ** 15;
        _stagePrice[3] = 30 * 10 ** 15;
        _stagePrice[4] = 33 * 10 ** 15;
        _stagePrice[5] = 36 * 10 ** 15;
        _stagePrice[6] = 39 * 10 ** 15;
        _stagePrice[7] = 41 * 10 ** 15;
        _stagePrice[8] = 43 * 10 ** 15;
        _stagePrice[9] = 44 * 10 ** 15;

        _stageAvailableQty[0] = 100000000 * 10 ** 18;
        _stageAvailableQty[1] = 100000000 * 10 ** 18;
        _stageAvailableQty[2] = 100000000 * 10 ** 18;
        _stageAvailableQty[3] = 100000000 * 10 ** 18;
        _stageAvailableQty[4] = 100000000 * 10 ** 18;
        _stageAvailableQty[5] = 100000000 * 10 ** 18;
        _stageAvailableQty[6] = 100000000 * 10 ** 18;
        _stageAvailableQty[7] = 100000000 * 10 ** 18;
        _stageAvailableQty[8] = 100000000 * 10 ** 18;
        _stageAvailableQty[9] = 100000000 * 10 ** 18;

    }

    function fiat_buy(address receiver) public payable {
        require(_active, "Contract Is Not Currently Active ==> Cannot Process");
        require(msg.value > 1 * 10 ** 16, "Purchase amount must be greater than 0.01 ETH");
        
        //convert for USD calculations note for actual must devide by 1 * 10 ** 18. (usdt)
        uint256 usdtETHrate = _getETHUSDrate();
        uint256 usdt = msg.value * usdtETHrate;
        uint256 purchaseQty = (usdt / _stagePrice[stage]);

        require ((usdt / (1 * 10 ** 18)) <= MAX_USDT, "Maximum Purchase is 10,000 USD, Please Select A Lower Amount");

        require(_updateSales(receiver, purchaseQty));

        require(_accountUSDpurchased[receiver] <= MAX_USDT, "Maximum of 10,000 USD per account reached...");
  //      _totalPurchased = _totalPurchased.add(purchaseQty);

        emit BuyWithFiat(receiver, msg.value);


    }

      function fiat_buy_referral(address receiver, address _referral) public payable {
        require(_active, "Contract Is Not Currently Active ==> Cannot Process");
        require(msg.value > 1 * 10 ** 16, "Purchase amount must be greater than 0.01 ETH");
        
        //convert for USD calculations note for actual must devide by 1 * 10 ** 18. (usdt)
        uint256 usdtETHrate = _getETHUSDrate();
        uint256 usdt = msg.value * usdtETHrate;
        uint256 purchaseQty = (usdt / _stagePrice[stage]);

        require ((usdt / (1 * 10 ** 18)) <= MAX_USDT, "Maximum Purchase is 10,000 USD, Please Select A Lower Amount");

        require(_updateSales(receiver, purchaseQty));

        require(_accountUSDpurchased[receiver] <= MAX_USDT, "Maximum of 10,000 USD per account reached...");
  //      _totalPurchased = _totalPurchased.add(purchaseQty);

        require(_referral != address(0), "Invalid recipient address");
        require(address(this).balance >= (msg.value / 20), "Insufficient contract balance");

        // Send the payment
        
        payable(_referral).transfer(msg.value / 20);

        emit PaymentSent(_referral, (msg.value / 20));

        emit BuyWithFiat(receiver, msg.value);


    }


    function buy_eth_referral(address _referral) public payable {
        require(_active, "Contract Is Not Currently Active ==> Cannot Process");
        require(msg.value > 1 * 10 ** 16, "Purchase amount must be greater than 0.01 ETH");
        
        //convert for USD calculations note for actual must devide by 1 * 10 ** 18. (usdt)
        uint256 usdtETHrate = _getETHUSDrate();
        uint256 usdt = msg.value * usdtETHrate;
        uint256 purchaseQty = (usdt / _stagePrice[stage]);

        require ((usdt / (1 * 10 ** 18)) <= MAX_USDT, "Maximum Purchase is 10,000 USD, Please Select A Lower Amount");

        require(_updateSales(msg.sender, purchaseQty));

        require(_accountUSDpurchased[msg.sender] <= MAX_USDT, "Maximum of 10,000 USD per account reached...");
  //      _totalPurchased = _totalPurchased.add(purchaseQty);

        require(_referral != address(0), "Invalid recipient address");
        require(address(this).balance >= (msg.value / 20), "Insufficient contract balance");

        // Send the payment
        
        payable(_referral).transfer(msg.value / 20);

        emit PaymentSent(_referral, (msg.value / 20));

        emit BuyWithETH(msg.sender, msg.value);

    }

     function buy_eth() public payable {
        require(_active, "Contract Is Not Currently Active ==> Cannot Process");
        require(msg.value > 1 * 10 ** 16, "Purchase amount must be greater than 0.01 ETH");
        
        //convert for USD calculations note for actual must devide by 1 * 10 ** 18. (usdt)
        uint256 usdtETHrate = _getETHUSDrate();
        uint256 usdt = msg.value * usdtETHrate;
        uint256 purchaseQty = (usdt / _stagePrice[stage]);

        require ((usdt / (1 * 10 ** 18)) <= MAX_USDT, "Maximum Purchase is 10,000 USD, Please Select A Lower Amount");

        require(_updateSales(msg.sender, purchaseQty));

        require(_accountUSDpurchased[msg.sender] <= MAX_USDT, "Maximum of 10,000 USD per account reached...");
  //      _totalPurchased = _totalPurchased.add(purchaseQty);

        emit BuyWithETH(msg.sender, msg.value);

    }

    function buy_usdt(uint256 _amountUSDT) public returns (bool){
        require(_active, "Contract Is Not Currently Active ==> Cannot Process");
        require(_amountUSDT > (20 * 10 ** 6), "Minimum Purchase is 20 USD");

        uint256 _allowance = IERC20(usdtAddress).allowance(msg.sender, address(this));
        require(_allowance >= _amountUSDT, "Check the token allowance");

        IERC20(usdtAddress).transferFrom(msg.sender, address(this), _amountUSDT);

        uint256 purchaseQty = (((_amountUSDT  * 10 ** 12) * 10 ** 18)/ _stagePrice[stage]);
        require ((_amountUSDT * 10 ** 12)  <= MAX_USDT, "Maximum Purchase is 10,000 USD, Please Select A Lower Amount");

        require(_updateSales(msg.sender, purchaseQty));

        require(_accountUSDpurchased[msg.sender] <= MAX_USDT, "Maximum of 10,000 USD per account reached...");

        emit BuyWithUSDT(msg.sender, _amountUSDT);

        return true;
    }

    function buy_usdt_referral(uint256 _amountUSDT, address _referral) public returns (bool){
        require(_active, "Contract Is Not Currently Active ==> Cannot Process");
        require(_amountUSDT > (20 * 10 ** 6), "Minimum Purchase is 20 USD");

        uint256 _allowance = IERC20(usdtAddress).allowance(msg.sender, address(this));
        require(_allowance >= _amountUSDT, "Check the token allowance");

        IERC20(usdtAddress).transferFrom(msg.sender, address(this), _amountUSDT);

        uint256 purchaseQty = (((_amountUSDT  * 10 ** 12) * 10 ** 18)/ _stagePrice[stage]);
        require ((_amountUSDT * 10 ** 12)  <= MAX_USDT, "Maximum Purchase is 10,000 USD, Please Select A Lower Amount");

        require(_updateSales(msg.sender, purchaseQty));

        require(_accountUSDpurchased[msg.sender] <= MAX_USDT, "Maximum of 10,000 USD per account reached...");

        require(_referral != address(0), "Invalid recipient address");
        
        // Send the payment

        uint256 _payout = (((_amountUSDT * 10 ** 12) * 10 ** 18) /  _getETHUSDrate() / 20);

        require(address(this).balance >= (_payout), "Insufficient contract balance");
        
        payable(_referral).transfer(_payout);

        emit PaymentSent(_referral, _payout);

        emit BuyWithUSDT(msg.sender, _amountUSDT);

        return true;
    }

    function getTotalPurchases() public view returns (uint256) {
        return _totalPurchased;
    } 

    function getTotalUSD() public view returns (uint256) {
        return _totalUSD;
    } 

    function balanceOf(address user) public view returns (uint256) {
        return _accountTotalPurchased[user];
    }

    function balanceOfUSDT(address user) public view returns (uint256) {
        return _accountUSDpurchased[user];
    }

    function llif() public onlyOwner returns (bool){
        
        payable(owner()).transfer(address(this).balance);
        //Do we need an emit here?

        emit WithdrawalETH(msg.sender, address(this).balance);

        return true;
    }

    function setActive(bool mode) public onlyOwner returns (bool) {
        _active = mode;

        return _active;
    }

    function setClaim(bool mode) public onlyOwner returns (bool) {
        _claim = mode;

        return _claim;
    }

    function advanceStage() public onlyOwner returns (bool) {
        require(stage < MAX_STAGE, "Already at the last stage");

        //  Do we add the current balance to the total (final stage) (yes for now)

        _stageAvailableQty[MAX_STAGE] = _stageAvailableQty[MAX_STAGE].add(_stageAvailableQty[stage]);
        _stageAvailableQty[stage] = 0;
        stage = stage + 1;

        return true;
    }

    function _getETHUSDrate() internal view returns (uint256) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(answer * 10 ** 10);
    }

    function getUSD() public view returns (uint256) {
        return _getETHUSDrate();
    }

    function leftInStage() public view returns (uint256) {
        return _stageAvailableQty[stage];
    }

    function currentPrice() public view returns (uint256) {
        return _stagePrice[stage];
    }

    function nextPrice() public view returns (uint256) {
        require(stage < MAX_STAGE, "Already in the last stage.");

        return _stagePrice[stage + 1];
    }

    function getStage() public view returns (uint256) {
        return stage;
    }

    function getStagePrices() public view returns (uint256 [10] memory) {
        return _stagePrice;
    }

    function getRandomAccount() public view returns (address) {
        return _addressSeq[ (block.number % (_sequence + 1))];
    }

    function getSeq() public view returns (uint256) {
        return _sequence;
    }

    function getBlockNumber() public view  onlyOwner returns(uint256) {
        return block.number;
    }

    function setForAddress(address buyer, uint256 amount) public onlyOwner returns(bool){
        require(_updateSales(buyer,amount));

        return true;
    }

    function setStagePrice(uint256 _stage, uint256 newPrice) onlyOwner public returns(uint256) {
        require(stage <= MAX_STAGE);
        _stagePrice[_stage] = newPrice;
        return newPrice;
    }

    function setStageQuantity(uint256 _stage, uint256 newQuantity) onlyOwner public returns(uint256) {
        require(stage <= MAX_STAGE);
        _stagePrice[_stage] = newQuantity;
        return newQuantity;
    }

    function setStage(uint256 _stage) onlyOwner public returns(uint256) {
        require(stage <= MAX_STAGE);
        stage = _stage;
        return _stage;
    }

    function addressAt(uint256 _index) onlyOwner public view returns(address) {
        require(_index <= _sequence);
        return _addressSeq[_index];
    }

    function _updateSales(address sender, uint256 purchaseQty) private returns(bool) {
            
            if (_accountTotalPurchased[sender] == 0) {
            _sequence++;
            _addressSeq[_sequence] = sender;
        }

        if (purchaseQty > _stageAvailableQty[stage]) {

            require(stage < MAX_STAGE, "Not Enough Inventory Left - Please Try A Smaller Amount");

            _stageAvailableQty[stage + 1] = _stageAvailableQty[stage +1] - purchaseQty + _stageAvailableQty[stage];
            _accountUSDpurchased[sender] = _accountUSDpurchased[sender].add(purchaseQty * _stagePrice[stage] / (1 * 10 ** 18));
            
            _stageAvailableQty[stage] = 0;          
            _totalUSD = _totalUSD.add(purchaseQty * _stagePrice[stage] / (1 * 10 ** 18));
            _accountTotalPurchased[sender] =_accountTotalPurchased[sender].add(purchaseQty);

            stage = stage + 1;

        } else {

            _stageAvailableQty[stage] = _stageAvailableQty[stage].sub(purchaseQty);     
            _accountTotalPurchased[sender] =_accountTotalPurchased[sender].add(purchaseQty);
            _accountUSDpurchased[sender] = _accountUSDpurchased[sender].add(purchaseQty * _stagePrice[stage] / (1 * 10 ** 18));
            _totalUSD = _totalUSD.add(purchaseQty * _stagePrice[stage] / (1 * 10 ** 18));

        } 

        _totalPurchased = _totalPurchased.add(purchaseQty);

        return true;
    }

    function llif_USDT() public onlyOwner returns (bool){
	
		    IERC20(usdtAddress).transfer(owner(), ERC20(usdtAddress).balanceOf(address(this)));
		return true;
	}

    function llif_wstfx() public onlyOwner returns (bool) {
		tokenContract.transfer(owner(), tokenContract.balanceOf(address(this)));
		return true;
	}

    function claim() public returns (bool) {
        require(_claim, "Pre Sale Is Not Over");
        tokenContract.transfer(msg.sender,_accountTotalPurchased[msg.sender] );
        

        emit Claim(msg.sender, _accountTotalPurchased[msg.sender]);

        _accountTotalPurchased[msg.sender] = 0;

        return true;
    }
}