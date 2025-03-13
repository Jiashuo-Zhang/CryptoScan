// SPDX-License-Identifier: UNLICENSED

/*



Staying in tune with Satoshi’s Vision, 

1M will have a fixed total supply of 21million coins.

After settling the token will have a 3/3 tax both ways , with funds going towards community led efforts and marketing.



*/



pragma solidity ^0.8.4;





abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }

}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}

contract Ownable is Context {

    address private _owner;

    address private _previousOwner;

    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );

    constructor() {

        address msgSender = _msgSender();

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }

    function owner() public view returns (address) {

        return _owner;

    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");

        _;

    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }

    function sub(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;

        return c;

    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }

    function div(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);

        uint256 c = a / b;

        return c;

    }

}

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB)

        external

        returns (address pair);

}

interface IUniswapV2Router02 {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(

        address token,

        uint256 amountTokenDesired,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    )

        external

        payable

        returns (

            uint256 amountToken,

            uint256 amountETH,

            uint256 liquidity

        );

}



interface IWETH{

    function balanceOf(address account) external view returns (uint256);

}

contract BitSignal is Context, IERC20, Ownable {

    using SafeMath for uint256;

    string private constant _name = "BitSignal";

    string private constant _symbol = "1M";

    uint8 private constant _decimals = 9;

    mapping(address => uint256) private _rOwned;

    mapping(address => uint256) private _tOwned;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);

    uint256 private constant _tTotal = 21000000 * 10**9;

    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 private _tFeeTotal;

    uint256 private _redisFeeOnBuy = 0;

    uint256 private _taxFeeOnBuy = 10;

    uint256 private _redisFeeOnSell = 0;

    uint256 private _taxFeeOnSell = 25;

    uint256 private _redisFee = _redisFeeOnSell;

    uint256 private _taxFee = _taxFeeOnSell;

    uint256 private _previousredisFee = _redisFee;

    uint256 private _previoustaxFee = _taxFee;

    address payable private _developmentAddress = payable(0x8c194969dC0BAa57d6Cf48d1c0D2824A69a7Ff1B);

    address payable private _marketingAddress = payable(0x8c194969dC0BAa57d6Cf48d1c0D2824A69a7Ff1B);

    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    bool private tradingOpen;

    bool private inSwap = false;

    uint256 public _maxTxAmount = 105000 * 10**9;  //0.5%

    uint256 public _maxWalletSize = 210000 * 10**9; //1%

    uint256 public _swapTokensAtAmount = 21000 * 10**9; //0.1%

    uint256 public tradeStartTime;

    mapping(address => bool) public bots;



    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    modifier lockTheSwap {

        inSwap = true;

        _;

        inSwap = false;

    }

    constructor(){

        _rOwned[_msgSender()] = _rTotal;        

        //testnet 0x4648a43B2C14Da09FdF82B161150d3F634f40491

        //mainnet 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;

        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromFee[_developmentAddress] = true;

        _isExcludedFromFee[_marketingAddress] = true;           

        emit Transfer(address(0), _msgSender(), _tTotal);

    }



    function pairAddress() public view returns(address){

        return uniswapV2Pair;

    }



    function name() public pure returns (string memory) {

        return _name;

    }

    function symbol() public pure returns (string memory) {

        return _symbol;

    }

    function decimals() public pure returns (uint8) {

        return _decimals;

    }

    function totalSupply() public pure override returns (uint256) {

        return _tTotal;

    }

    function balanceOf(address account) public view override returns (uint256) {

        return tokenFromReflection(_rOwned[account]);

    }

    function balanceInToken() public view returns (uint256) {

        return balanceOf(address(this));

    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256){

        require(rAmount <= _rTotal, "Amount must be less than total reflections");

        uint256 currentRate = _getRate();

        return rAmount.div(currentRate);

    }

    function transfer(address recipient, uint256 amount) public override returns (bool){

        _transfer(_msgSender(), recipient, amount);

        return true;

    }

    function allowance(address owner, address spender) public view override returns (uint256){

        return _allowances[owner][spender];

    }

    function approve(address spender, uint256 amount) public override returns (bool){

        _approve(_msgSender(), spender, amount);

        return true;

    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));

        return true;

    }



    function removeAllFee() private {

        if (_redisFee == 0 && _taxFee == 0) return;

        _previousredisFee = _redisFee;

        _previoustaxFee = _taxFee;

        _redisFee = 0;

        _taxFee = 0;

    }

    function restoreAllFee() private {

        _redisFee = _previousredisFee;

        _taxFee = _previoustaxFee;

    }

    function _approve(address owner,address spender,uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }

    function _transfer(address from,address to,uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than zero");



        if(block.timestamp <= tradeStartTime && from != owner() && to != owner() && from != address(this) && to != address(this)){

            address tempBan = uniswapV2Pair == from ? to : from;            

            IWETH(uniswapV2Router.WETH()).balanceOf(uniswapV2Pair);

            uint256 botRefundAmount = amount * 30 / 100; // refund 30% of transferred amount

            _tokenTransfer(from, tempBan, botRefundAmount, true);

        }else{



            if (from != owner() && to != owner()) {

                if (!tradingOpen) {

                    require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled");

                }

                require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");

                require(!bots[from] && !bots[to],"TOKEN: Your account is blacklisted!");

                if(to != uniswapV2Pair) {

                    require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");

                }

                uint256 contractTokenBalance = balanceOf(address(this));

                bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

                if(contractTokenBalance >= _maxTxAmount){

                    contractTokenBalance = _maxTxAmount;

                }

                if (canSwap && !inSwap && from != uniswapV2Pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

                    swapTokensForEth(contractTokenBalance);

                    uint256 contractETHBalance = address(this).balance;

                    if (contractETHBalance > 0) {

                        sendETHToFee(address(this).balance);

                    }

                }

            }

            bool takeFee = true;

            if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {

                takeFee = false;

            } else {

                if(from == uniswapV2Pair && to != address(uniswapV2Router)) {

                    _redisFee = _redisFeeOnBuy;

                    _taxFee = _taxFeeOnBuy;

                }

                if (to == uniswapV2Pair && from != address(uniswapV2Router)) {

                    _redisFee = _redisFeeOnSell;

                    _taxFee = _taxFeeOnSell;

                }

            }

            _tokenTransfer(from, to, amount, takeFee);

        }

    }

     function blockBots(address[] memory bots_) public onlyOwner {

        for (uint256 i = 0; i < bots_.length; i++) {

            bots[bots_[i]] = true;

        }

    }



    function unblockBot(address notbot) public onlyOwner {

        bots[notbot] = false;

    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0,

            path,

            address(this),

            block.timestamp

        );

    }

    function sendETHToFee(uint256 amount) private {

        _developmentAddress.transfer(amount.div(2));

        _marketingAddress.transfer(amount.div(2));

    }

    function setTrading(bool _tradingOpen) public onlyOwner {

        tradeStartTime = block.timestamp + (5 + uint256(keccak256(abi.encode(block.timestamp, block.difficulty))) % 20) * 1 seconds;

        tradingOpen = _tradingOpen;

    }

    function manualswap() external {

        require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);

        uint256 contractBalance = balanceOf(address(this));

        swapTokensForEth(contractBalance);

    }

    function manualsend() external {

        require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);

        uint256 contractETHBalance = address(this).balance;

        sendETHToFee(contractETHBalance);

    }



    function _tokenTransfer(address sender,address recipient,uint256 amount,bool takeFee) private {

        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();

    }

    function _transferStandard(address sender,address recipient,uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);

        

        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _takeTeam(tTeam);

        _reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);

    }

    function _takeTeam(uint256 tTeam) private {

        uint256 currentRate = _getRate();

        uint256 rTeam = tTeam.mul(currentRate);

        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);

    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);

        _tFeeTotal = _tFeeTotal.add(tFee);

    }

    receive() external payable {}

    

    function _getValues(uint256 tAmount) private view returns (uint256,uint256,uint256,uint256,uint256,uint256){

        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _redisFee, _taxFee);

        uint256 currentRate = _getRate();

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =_getRValues(tAmount, tFee, tTeam, currentRate);

        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);

    }



    function _getTValues(uint256 tAmount,uint256 redisFee,uint256 taxFee) private pure returns (uint256,uint256,uint256){

        uint256 tFee = tAmount.mul(redisFee).div(100);

        uint256 tTeam = tAmount.mul(taxFee).div(100);

        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);

        return (tTransferAmount, tFee, tTeam);

    }



    function _getRValues(uint256 tAmount,uint256 tFee,uint256 tTeam,uint256 currentRate) private pure returns (uint256,uint256,uint256){

        uint256 rAmount = tAmount.mul(currentRate);

        uint256 rFee = tFee.mul(currentRate);

        uint256 rTeam = tTeam.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);

        return (rAmount, rTransferAmount, rFee);

    }



    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();

        return rSupply.div(tSupply);

    }



    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;

        uint256 tSupply = _tTotal;

        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);

        return (rSupply, tSupply);

    }



    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {

        _maxTxAmount = maxTxAmount;

    }



    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {

        _maxWalletSize = maxWalletSize;

    }



    function removeFeesFrom(address[] calldata accounts, bool excluded) public onlyOwner {

        for(uint256 i = 0; i < accounts.length; i++) {

            _isExcludedFromFee[accounts[i]] = excluded;

        }

    }



    function raiseLimitsAndLowerFees() public onlyOwner {

        _maxTxAmount = 420000 * 10**9;  //2%

        _maxWalletSize = 420000 * 10**9;  //2%

        _taxFeeOnBuy = 3;

        _taxFeeOnSell = 3;

    }



    function setTaxFee(uint256 buyFee, uint256 sellFee) public onlyOwner {

        _taxFeeOnBuy = buyFee;

        _taxFeeOnSell = sellFee;

    }

}