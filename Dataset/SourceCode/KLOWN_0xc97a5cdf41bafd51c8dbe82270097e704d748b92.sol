/**

 *Submitted for verification at Etherscan.io on 2019-08-17

*/



pragma solidity 0.5.8;



interface IERC20 

{

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract ApproveAndCallFallBack {



    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;

}



library SafeMath 

{

    function mul(uint256 a, uint256 b) internal pure returns (uint256) 

    {

        if (a == 0) 

        {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }

    

    function div(uint256 a, uint256 b) internal pure returns (uint256) 

    {

        uint256 c = a / b;

        return c;

    }

    

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 

    {

        assert(b <= a);

        return a - b;

    }

    

    function add(uint256 a, uint256 b) internal pure returns (uint256) 

    {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

    

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) 

    {

        uint256 c = add(a,m);

        uint256 d = sub(c,1);

        return mul(div(d,m),m);

    }

}



contract ERC20Detailed is IERC20 

{

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    

    constructor(string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }

    

    function name() public view returns(string memory) {

        return _name;

    }

    

    function symbol() public view returns(string memory) {

        return _symbol;

    }

    

    function decimals() public view returns(uint8) {

        return _decimals;

    }

}



contract KLOWN is ERC20Detailed 

{

    using SafeMath for uint256;

    

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    

    string constant tokenName = "Ether Clown";//"Ether Clown";

    string constant tokenSymbol = "KLOWN";//"KLOWN"; 

    uint8  constant tokenDecimals = 7;

    uint256 _totalSupply = 0;

	

	    //shown in public 

    uint256 public RemainingSupply = 0;



    

    // ------------------------------------------------------------------------

  

    address public contractOwner;







    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    // ------------------------------------------------------------------------

    

    constructor() public ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) 

    {

        contractOwner = msg.sender;



        _mint(msg.sender, 777000 * (10**uint256(tokenDecimals)));

    }

    

    // ------------------------------------------------------------------------



    function transferOwnership(address newOwner) public 

    {

        require(msg.sender == contractOwner);

        require(newOwner != address(0));

        emit OwnershipTransferred(contractOwner, newOwner);

        contractOwner = newOwner;

    }

    

    function totalSupply() public view returns (uint256) 

    {

        return _totalSupply;

    }

    

    function balanceOf(address owner) public view returns (uint256) 

    {

        return _balances[owner];

    }

    

   

   

    function allowance(address owner, address spender) public view returns (uint256) 

    {

        return _allowed[owner][spender];

    }

    

    function transfer(address to, uint256 value) public returns (bool) 

    {

        _executeTransfer(msg.sender, to, value);

        return true;

    }

    

    function multiTransfer(address[] memory receivers, uint256[] memory values) public

    {

        require(receivers.length == values.length);

        for(uint256 i = 0; i < receivers.length; i++)

            _executeTransfer(msg.sender, receivers[i], values[i]);

    }

    

    function transferFrom(address from, address to, uint256 value) public returns (bool) 

    {

        require(value <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _executeTransfer(from, to, value);

        return true;

    }

    

    function approve(address spender, uint256 value) public returns (bool) 

    {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }

    

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) 

    {

        _allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);

        return true;

    }

    

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 

    {

        require(spender != address(0));

        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }

    

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 

    {

        require(spender != address(0));

        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }

    

    function _mint(address account, uint256 value) internal 

    {

        require(value != 0);

        

        uint256 initalBalance = _balances[account];

        uint256 newBalance = initalBalance.add(value);

        

        _balances[account] = newBalance;

        _totalSupply = _totalSupply.add(value);





		RemainingSupply = _totalSupply;

        



        emit Transfer(address(0), account, value);

    }

    

    function burn(uint256 value) external 

    {

        _burn(msg.sender, value);

    }

    

    function burnFrom(address account, uint256 value) external 

    {

        require(value <= _allowed[account][msg.sender]);

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

    }

    

    function _burn(address account, uint256 value) internal 

    {

        require(value != 0);

        require(value <= _balances[account]);

        

        uint256 initalBalance = _balances[account];

        uint256 newBalance = initalBalance.sub(value);

        

        _balances[account] = newBalance;

        _totalSupply = _totalSupply.sub(value);

		//public

		RemainingSupply = _totalSupply;

        

        

        emit Transfer(account, address(0), value);

    }

    

    function random() private view returns (uint256) {

        

        

        uint256 rndValue =  uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));

        // get a psudeorandom value between 150 and 350 (to be used as percent % burn)

        rndValue = rndValue %200 + 150;

     

        

       

       return

        rndValue;

        

   }



    

    /*

    *   transfer with additional burn and stake rewards

    *   the receiver gets 95% of the sent value

    *   5% are split to be burnt and distributed to holders

    */

    function _executeTransfer(address from, address to, uint256 value) private

    {

        require(value <= _balances[from]);

        require(to != address(0) && to != address(this));



		

        uint256 randomBurnPercent = 0;

		uint256 burnPercent = 0;

		

		

		//burn only if total remaining supply > 15540 (percentage of orignal supply)

		if(_totalSupply > 15540)

		{

			randomBurnPercent = random();

		

			

			/*

				random number generated is between 150 and 350. need it to be between 1.5 and 3.5 

				this technique is used due to the way solidity handles floating point numbers

				10000 is dividing by 100 twice 

			*/ 

			

			burnPercent = value.mul(randomBurnPercent).div(10000);

        }

        

		

        uint256 initalBalance_from = _balances[from];

        uint256 newBalance_from = initalBalance_from.sub(value);

        

        value = value.sub(burnPercent);

        

        uint256 initalBalance_to = _balances[to];

        uint256 newBalance_to = initalBalance_to.add(value);

        

        //transfer

        _balances[from] = newBalance_from;

        _balances[to] = newBalance_to;

        emit Transfer(from, to, value);

                

        uint256 amountToBurn = burnPercent;

                

        //update total supply

        _totalSupply = _totalSupply.sub(amountToBurn);

		//public

		RemainingSupply = _totalSupply;

		

        emit Transfer(msg.sender, address(0), amountToBurn);

    }

    

    

    //withdraw tokens that were sent to this contract by accident

    function withdrawERC20Tokens(address tokenAddress, uint256 amount) public

    {

        require(msg.sender == contractOwner);

        require(tokenAddress != address(this));

        IERC20(tokenAddress).transfer(msg.sender, amount);

    }

    

}