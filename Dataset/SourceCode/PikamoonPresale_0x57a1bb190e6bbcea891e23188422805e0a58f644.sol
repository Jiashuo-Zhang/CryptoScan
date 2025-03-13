/**

 *Submitted for verification at Etherscan.io on 2023-04-14

*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;



/// @title Pikamoon Presale

/// @author André Costa @ Terratecc



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }

}



contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {

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



interface IERC20 {

    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `recipient`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address recipient, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * Emits an {Approval} event.

     */

    function approve(address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `sender` to `recipient` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) external returns (bool);



    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by

     * a call to {approve}. `value` is the new allowance.

     */

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



interface AggregatorV3Interface {

  function decimals() external view returns (uint8);



  function description() external view returns (string memory);



  function version() external view returns (uint256);



  // getRoundData and latestRoundData should both raise "No data present"

  // if they do not have data to report, instead of returning unset values

  // which could be misinterpreted as actual reported values.

  function getRoundData(uint80 _roundId)

    external

    view

    returns (

      uint80 roundId,

      int256 answer,

      uint256 startedAt,

      uint256 updatedAt,

      uint80 answeredInRound

    );



  function latestRoundData()

    external

    view

    returns (

      uint80 roundId,

      int256 answer,

      uint256 startedAt,

      uint256 updatedAt,

      uint80 answeredInRound

    );

}



contract PikamoonPresale is Ownable {



  // The token being sold

  IERC20Metadata public token;



  // Address where funds are collected

  address public recipient;



  uint256 public maxTotalTokens = 15 * 10 ** 18;



  // Amount of funds raised

  uint256 public totalFundsRaisedEth;

  uint256 public totalFundsRaisedStable;

  uint256 public totalTokensSold;



  // Stores the stablecoins accepted for purchase

  mapping(address => bool) public acceptedTokens;



  // To get the price of ETH

  AggregatorV3Interface internal priceFeed;



  // Stores if presale has been opened or not

  bool public saleState;



  struct Sale {

        uint256 maxTokens;

        uint256 tokensSold;

        uint256 fundsRaisedEth;

        uint256 fundsRaisedStable;

        uint256 tokenPrice; // 8 decimals

        uint256 claimStart;

  }

  mapping(uint256 => Sale) private sales;

  uint256 public lastSaleId;



  mapping(address => uint256) public nonce;



  mapping(address => mapping(uint256 => uint256)) internal tokensToBeClaimed;

  mapping(address => uint256) internal claimedTokens;



  //dummy address that we use to sign the mint transaction to make sure it is valid

  address private dummy = 0x80E4929c869102140E69550BBECC20bEd61B080c;



  uint256 public discount = 10;



  uint256 extraTokens = 100;





  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value usd paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokenPurchase(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  constructor() {

        //token = IERC20Metadata();



        //acceptedTokens[] = true; //USDT 0xdAC17F958D2ee523a2206206994597C13D831ec7

        //acceptedTokens[] = true; //USDC 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

        //acceptedTokens[] = true; //DAI 0x6B175474E89094C44Da98b954EedeAC495271d0F



        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e); // 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   */

  receive() external payable {

    buyTokensEth(msg.sender);

  }



  modifier correctState() {

    require(saleState, "Sale is Not Open!");

    _;

  }



  /**

   * @dev allow owner to add a new token address

   * @param _tokenAddress contract address of new token

   */

  function addAcceptedToken(address _tokenAddress) external onlyOwner {

    require(!acceptedTokens[_tokenAddress], "Invalid Address!");

    acceptedTokens[_tokenAddress] = true;

  }



  /**

   * @dev allow owner to remove a token address

   * @param _tokenAddress contract address of token to be removed

   */

  function removeAcceptedToken(address _tokenAddress) external onlyOwner {

    require(acceptedTokens[_tokenAddress], "Invalid Address!");

    acceptedTokens[_tokenAddress] = false;

  }



  /**

   * @dev allow owner to open and close the sale

   */

  function switchSaleState() external onlyOwner {

    saleState = !saleState;

  }



  /**

   * @dev allow owner to start a sale

   * @param maxTokens the amount of tokens that are put up for sale

   * @param tokenPrice the price in USD of 1 PIKA (10**9). USD price has 8 decimals (5$ = 500000000)

   * @param claimStart the amount of days after the opening of the sale that the tokens can be claimed

   */

  function newSale(uint256 maxTokens, uint256 tokenPrice, uint256 claimStart) external onlyOwner {

    require(totalTokensSold + maxTokens <= maxTotalTokens / 10 ** token.decimals(), "Exceeds Max Total Tokens!");

    

    lastSaleId++;

    sales[lastSaleId].maxTokens = maxTokens;

    sales[lastSaleId].tokenPrice = tokenPrice;

    sales[lastSaleId].claimStart = block.timestamp + (claimStart * 86400);



  }



  /**

   * @dev allow owner to set time to allow claim of tokens

   */

  function setClaimStart(uint256 newTimestamp) external onlyOwner {

    require(newTimestamp > sales[lastSaleId].claimStart, "Invalid Timestamp!");

    sales[lastSaleId].claimStart = newTimestamp;

  }



  /**

   * @dev allow owner to set discount

   * @param newDiscount new discount percentage

   */

  function setDiscount(uint256 newDiscount) external onlyOwner {

    require(newDiscount < 100, "Incorrect Value!");

    discount = newDiscount;

  }



  /**

   * @dev allow owner to set new amount of extra tokens

   * @param newExtra new discount percentage

   */

  function setExtraTokens(uint256 newExtra) external onlyOwner {

    extraTokens = newExtra;

  }



  /**

   * @dev allow owner to set the & of discount

   * @param newPrice new price in USD with 8 decimals (0.1$ = 10000000)

   */

  function setTokenPrice(uint256 newPrice) external onlyOwner {

    sales[lastSaleId].tokenPrice = newPrice;

  }



  /**

   * @dev allow owner to set the token contract

   * @param newToken address of new contract

   */

  function setToken(address newToken) external onlyOwner {

    require(newToken != address(0), "Invalid Address!");

    token = IERC20Metadata(newToken);

  }



  /**

   * @dev allow owner to set a new recipient

   * @param newRecipient new address to receive funds

   */

  function setRecipient(address newRecipient) external onlyOwner {

    require(newRecipient != address(0), "Invalid Address!");

    recipient = newRecipient;

  }



  ///  CHAINLINK PRICE FEED



  function changePriceFeed(address newFeed) public onlyOwner {

        priceFeed = AggregatorV3Interface(newFeed);

    }



  function getTokentoUSD() public view returns(int) {

          (,int price,,,) = priceFeed.latestRoundData();

          return price;

    }



  function getPriceToken() public view returns(uint256) {

          int price = getTokentoUSD();

          return (sales[lastSaleId].tokenPrice * 10 ** 18) / uint256(price);

    }



  // CLAIM



  function tokensAvailable(address recipient_) public view returns(uint256) {

    require(lastSaleId != 0, "No Sales have started!");



    uint256 tokens;

    for (uint i = 0; i <= lastSaleId; i++) {

      if (block.timestamp >= sales[i].claimStart) {

        tokens += tokensToBeClaimed[recipient_][i];

      }

    }



    return tokens - claimedTokens[recipient_];

  }



  function claimTokens(address recipient_) external correctState {

        uint256 availableTokens = tokensAvailable(recipient_);

        require(availableTokens != 0, "No tokens available to claim!");



        claimedTokens[recipient_] += availableTokens;

        token.transfer(recipient_, availableTokens * 10 ** token.decimals());



    }

 

    /* 

    * @dev Verifies if message was signed by owner to give access to _add for this contract.

    *      Assumes Geth signature prefix.

    * @param _add Address of agent with access

    * @param _v ECDSA signature parameter v.

    * @param _r ECDSA signature parameters r.

    * @param _s ECDSA signature parameters s.

    * @return Validity of access message for a given address.

    */

  function isValidAccessMessage(address _add, uint8 _v, bytes32 _r, bytes32 _s) view public returns (bool) {

        bytes32 hash = keccak256(abi.encodePacked(address(this), _add, nonce[msg.sender]));

        return dummy == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), _v, _r, _s);

  }





  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokensEthDiscounted(address _beneficiary, uint8 _v, bytes32 _r, bytes32 _s) public payable correctState {

    require(isValidAccessMessage(msg.sender, _v, _r, _s), "Signature is Incorrect!");



    uint256 weiAmount = msg.value;

    _preValidatePurchase(_beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmountEth(weiAmount, true);

    require(tokens != 0, "Insufficient Funds!");

    require(sales[lastSaleId].tokensSold + tokens <= sales[lastSaleId].maxTokens, "Token Sale Limit Reached!");



    // update state

    sales[lastSaleId].fundsRaisedEth += msg.value;

    totalFundsRaisedEth += msg.value;

    tokensToBeClaimed[_beneficiary][lastSaleId] += tokens;

    sales[lastSaleId].tokensSold += tokens;

    totalTokensSold += tokens;



    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _forwardFundsEth();

    _postValidatePurchase(_beneficiary, weiAmount);



    nonce[msg.sender]++;

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokensEth(address _beneficiary) public payable correctState {



    uint256 weiAmount = msg.value;

    _preValidatePurchase(_beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmountEth(weiAmount, false);

    require(tokens != 0, "Insufficient Funds!");

    require(sales[lastSaleId].tokensSold + tokens <= sales[lastSaleId].maxTokens, "Token Sale Limit Reached!");



    // update state

    sales[lastSaleId].fundsRaisedEth += msg.value;

    totalFundsRaisedEth += msg.value;

    tokensToBeClaimed[_beneficiary][lastSaleId] += tokens;

    sales[lastSaleId].tokensSold += tokens;

    totalTokensSold += tokens;



    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _forwardFundsEth();

    _postValidatePurchase(_beneficiary, weiAmount);



    

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   * @param _tokenAddress the token used to perform the purchase

   * @param _amount quantity of stablecoin sent

   */

  function buyTokensStableDiscounted(address _beneficiary, address _tokenAddress, uint256 _amount, uint8 _v, bytes32 _r, bytes32 _s) public correctState {

    require(acceptedTokens[_tokenAddress], "Invalid Address!");

    require(isValidAccessMessage(msg.sender, _v, _r, _s), "Signature is Incorrect!");

    _amount = _amount * 10 ** IERC20Metadata(_tokenAddress).decimals();



    _preValidatePurchase(_beneficiary, _amount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmountStable(_tokenAddress, _amount, true);

    require(tokens != 0, "Insufficient Funds!");

    require(sales[lastSaleId].tokensSold + tokens <= sales[lastSaleId].maxTokens, "Token Sale Limit Reached!");



    // update state

    sales[lastSaleId].fundsRaisedStable += _amount / 10 ** IERC20Metadata(_tokenAddress).decimals();

    totalFundsRaisedStable += _amount / 10 ** IERC20Metadata(_tokenAddress).decimals();

    tokensToBeClaimed[_beneficiary][lastSaleId] += tokens;

    sales[lastSaleId].tokensSold += tokens;

    totalTokensSold += tokens;



    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      _amount,

      tokens

    );



    _forwardFundsStable(_tokenAddress, _amount);

    _postValidatePurchase(_beneficiary, _amount);



    nonce[msg.sender]++;

  }





  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   * @param _tokenAddress the token used to perform the purchase

   * @param _amount quantity of stablecoin sent

   */

  function buyTokensStable(address _beneficiary, address _tokenAddress, uint256 _amount) public correctState {

    require(acceptedTokens[_tokenAddress], "Invalid Address!");

    _amount = _amount * 10 ** IERC20Metadata(_tokenAddress).decimals();



    _preValidatePurchase(_beneficiary, _amount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmountStable(_tokenAddress, _amount, false);

    require(tokens != 0, "Insufficient Funds!");

    require(sales[lastSaleId].tokensSold + tokens <= sales[lastSaleId].maxTokens, "Token Sale Limit Reached!");



    // update state

    sales[lastSaleId].fundsRaisedStable += _amount / 10 ** IERC20Metadata(_tokenAddress).decimals();

    totalFundsRaisedStable += _amount / 10 ** IERC20Metadata(_tokenAddress).decimals();

    tokensToBeClaimed[_beneficiary][lastSaleId] += tokens;

    sales[lastSaleId].tokensSold += tokens;

    totalTokensSold += tokens;



    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      _amount,

      tokens

    );



    _forwardFundsStable(_tokenAddress, _amount);

    _postValidatePurchase(_beneficiary, _amount);

  }





  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

   * @param _beneficiary Address performing the token purchase

   * @param _amount Value involved in the purchase

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _amount

  )

    pure internal

  {

    require(_beneficiary != address(0));

    require(_amount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param _beneficiary Address performing the token purchase

   * @param _amount Value involved in the purchase

   */

  function _postValidatePurchase(

    address _beneficiary,

    uint256 _amount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param _weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmountEth(uint256 _weiAmount, bool discounted)

    public view returns (uint256)

  {

    if (discounted) {

      return _weiAmount / ((getPriceToken() * (100 - discount)) / 100);

    }

    else {

      if (_weiAmount * uint256(getTokentoUSD()) >= 1000 * 10 ** (18 + priceFeed.decimals())) {

        return (_weiAmount / getPriceToken()) + (extraTokens);

      }

      else {

        return _weiAmount / getPriceToken();

      }

      

    }

    

  }



  /**

   * @dev Override to extend the way in which stablecoin is converted to tokens

   * @param _tokenAddress Contract address of stablecoin

   * @param _amount Value in stablecoin to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _amount

   */

  function _getTokenAmountStable(address _tokenAddress, uint256 _amount, bool discounted)

    public view returns (uint256)

  {

    if (discounted) {

      return (_amount * 10**priceFeed.decimals() ) / (10**IERC20Metadata(_tokenAddress).decimals() * ((sales[lastSaleId].tokenPrice * (100 - discount)) / 100));

    }

    else {

      if (_amount / 10**IERC20Metadata(_tokenAddress).decimals() >= 1000) {

        return ((_amount * 10**priceFeed.decimals() ) / (10**IERC20Metadata(_tokenAddress).decimals() * sales[lastSaleId].tokenPrice)) + (extraTokens);

      }

      else {

        return (_amount * 10**priceFeed.decimals() ) / (10**IERC20Metadata(_tokenAddress).decimals() * sales[lastSaleId].tokenPrice);

      }

    }

    

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFundsEth() internal {

    (bool sent, ) = recipient.call{value: msg.value}("");

    require(sent, "Failed to send Ether");

  }



  /**

   * @dev Determines how a token is stored/forwarded on purchases.

   */

  function _forwardFundsStable(address _tokenAddress, uint256 _amount) internal {

    IERC20(_tokenAddress).transferFrom(msg.sender, recipient, _amount);

  }



  function balanceOf(address address_) public view returns(uint256) {

    return token.balanceOf(address_);

  }

  



}