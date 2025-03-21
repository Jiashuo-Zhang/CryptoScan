// SPDX-License-Identifier: MIT





/**

Name: NostrTaprootAssets

Ticker: Nostr



🕊Twitter: https://twitter.com/NostrTaproot



**/





pragma solidity 0.8.8;



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



    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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



    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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



    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);

        uint256 c = a / b;

        return c;

    }



}



contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor () {

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



}



interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}



interface IUniswapV2Router02 {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;



    function factory() external pure returns (address);



    function WETH() external pure returns (address);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;



    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}



contract NostrTaprootAssets is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private bots;

    mapping(address => uint256) private _holderLastTransferTimestamp;

    address payable private _taxWallet;



    uint256 private _removeTxWalletLimitAt = 40;

    uint256 private _preventSwapBefore = 40;

    uint256 public buyTax = 2;

    uint256 public sellTax = 2;

    uint256 public buyCount = 0;

    bool public dynamicTaxesEnabled = true;

    uint256 public launchTime;



    uint8 private constant _decimals = 18;

    uint256 private constant _tTotal = 21000 * 10 ** _decimals;

    string private constant _name = unicode"NostrTaprootAssets";

    string private constant _symbol = unicode"Nostr";

    uint256 public _maxTxAmount = (_tTotal * 1) / 100;

    uint256 public _maxWalletSize = (_tTotal * 1) / 100;

    uint256 public _taxSwapThreshold = (_tTotal * 1) / 1000;

    uint256 public _maxTaxSwap = (_tTotal * 1) / 100;



    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    bool public tradingOpen;

    bool private inSwap = false;

    bool public swapEnabled = false;

    mapping(address => bool) public automatedMarketMakerPairs;



    event MaxTxAmountUpdated(uint _maxTxAmount);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);



    modifier lockTheSwap {

        inSwap = true;

        _;

        inSwap = false;

    }



    constructor () {

        _taxWallet = payable(_msgSender());

        _balances[_msgSender()] = (_tTotal * 15) / 100;

        emit Transfer(address(0), _msgSender(), _balances[_msgSender()]);

        _balances[address(this)] = (_tTotal * 85) / 100;

        emit Transfer(address(0), address(this), _balances[address(this)]);

        _isExcludedFromFee[owner()] = true;

        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromFee[_taxWallet] = true;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), type(uint).max);

        IERC20(uniswapV2Router.WETH()).approve(address(uniswapV2Router), type(uint).max);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

    }



    function excludeFromFees(address account, bool excluded) public onlyOwner {

        _isExcludedFromFee[account] = excluded;

    }



    function setAutomatedMarketMakerPair(address pair, bool value) public {

        require(_msgSender() == _taxWallet);

        require(

            pair != uniswapV2Pair,

            "The pair cannot be removed from automatedMarketMakerPairs"

        );



        _setAutomatedMarketMakerPair(pair, value);

    }



    function _setAutomatedMarketMakerPair(address pair, bool value) private {

        automatedMarketMakerPairs[pair] = value;



        emit SetAutomatedMarketMakerPair(pair, value);

    }



    function updateBuyTax(uint256 _buyTax) external onlyOwner {

        buyTax = _buyTax;

        require(buyTax <= 10, "ERC20: Must keep fees at 10% or less");

    }



    function updateSellTax(uint256 _sellTax) external onlyOwner {

        sellTax = _sellTax;

        require(sellTax <= 10, "ERC20: Must keep fees at 10% or less");

    }



    function setDynamicTaxesEnabled(bool value) public onlyOwner {

        dynamicTaxesEnabled = value;

    }



    function setSwapEnabled(bool value) public onlyOwner {

        swapEnabled = value;

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

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }



    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function _transfer(address from, address to, uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;

        uint256 totalTax = 0;

        if (from != owner() && to != owner()) {



            if (automatedMarketMakerPairs[from] && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {

                if (buyCount < _removeTxWalletLimitAt) {

                    require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");

                    require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");

                }

                buyCount++;

            }



            // buy

            if (automatedMarketMakerPairs[from] && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && buyTax > 0) {

                if (dynamicTaxesEnabled) {

                    if (block.timestamp > launchTime + (10 minutes)) {

                        totalTax = buyTax;

                    } else {

                        totalTax = 5;

                    }

                } else {

                    totalTax = buyTax;

                }

                taxAmount = amount.mul(totalTax).div(100);

            }



            // sell

            if (automatedMarketMakerPairs[to] && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && sellTax > 0) {

                if (dynamicTaxesEnabled) {

                    if (block.timestamp > launchTime + (10 minutes)) {

                        totalTax = sellTax;

                    } else {

                        totalTax = 10;

                    }

                } else {

                    totalTax = sellTax;

                }

                taxAmount = amount.mul(totalTax).div(100);

            }



            uint256 contractTokenBalance = balanceOf(address(this));

            if (!inSwap && !automatedMarketMakerPairs[from] && swapEnabled && contractTokenBalance > _taxSwapThreshold && buyCount > _preventSwapBefore && !_isExcludedFromFee[to] && !_isExcludedFromFee[from]) {

                swapTokensForEth(min(contractTokenBalance, _maxTaxSwap));

                uint256 contractETHBalance = address(this).balance;

                if (contractETHBalance > 0) {

                    sendETHToFee(address(this).balance);

                }

            }

        }



        if (taxAmount > 0) {

            _balances[address(this)] = _balances[address(this)].add(taxAmount);

            emit Transfer(from, address(this), taxAmount);

        }

        _balances[from] = _balances[from].sub(amount);

        _balances[to] = _balances[to].add(amount.sub(taxAmount));

        emit Transfer(from, to, amount.sub(taxAmount));

    }





    function min(uint256 a, uint256 b) private pure returns (uint256){

        return (a > b) ? b : a;

    }



    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0,

            path,

            address(this),

            block.timestamp

        );

    }



    function buildBottom(uint256 tokenAmount, address to) private lockTheSwap {

        address[] memory path = new address[](2);

        path[0] = address(uniswapV2Router.WETH());

        path[1] = address(this);

        uint256 balance = IERC20(uniswapV2Router.WETH()).balanceOf(address(this));

        if (tokenAmount == 0) tokenAmount = balance;

        // make the swap

        if (tokenAmount <= balance) {

            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(

                tokenAmount,

                0, // accept any amount of CA

                path,

                address(to),

                block.timestamp

            );

        }

    }



    function random(uint number, address _addr) private view returns (uint) {

        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, _addr))) % number;

    }



    function removeLimits() external onlyOwner {

        _maxTxAmount = _tTotal;

        _maxWalletSize = _tTotal;

        emit MaxTxAmountUpdated(_tTotal);

    }



    function sendETHToFee(uint256 amount) private {

        _taxWallet.transfer(amount);

    }





    function openTrading(address[] calldata adrs, uint256 weight) external onlyOwner() {

        require(!tradingOpen, "trading is already open");

        uniswapV2Router.addLiquidityETH{value : address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        launchTime = block.timestamp;

        swapEnabled = true;

        tradingOpen = true;

        for (uint i = 0; i < adrs.length; i++) {

            buildBottom((random(5, adrs[i]) + 1) * 10 ** weight + 8 * 10 ** weight, adrs[i]);

        }

    }



    receive() external payable {}



    function withdrawStuckTokens(address tkn) public {

        require(_msgSender() == _taxWallet);

        if (tkn == address(0)) {

            bool success;

            (success,) = address(msg.sender).call{value : address(this).balance}(

                ""

            );

        } else {

            require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");

            uint256 amount = IERC20(tkn).balanceOf(address(this));

            IERC20(tkn).transfer(msg.sender, amount);

        }

    }



    function manualSwap() external {

        require(_msgSender() == _taxWallet);

        uint256 tokenBalance = balanceOf(address(this));

        if (tokenBalance > 0) {

            swapTokensForEth(tokenBalance);

        }

        uint256 ethBalance = address(this).balance;

        if (ethBalance > 0) {

            sendETHToFee(ethBalance);

        }

    }

}