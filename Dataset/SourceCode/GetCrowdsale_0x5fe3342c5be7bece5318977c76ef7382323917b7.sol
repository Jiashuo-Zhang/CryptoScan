/**

 *Submitted for verification at Etherscan.io on 2017-11-27

*/



pragma solidity ^0.4.11;



contract SafeMath {

  function safeMul(uint a, uint b) internal returns (uint) {

    uint c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }

  function safeDiv(uint a, uint b) internal returns (uint) {

    assert(b > 0);

    uint c = a / b;

    assert(a == b * c + a % b);

    return c;

  }

  function safeSub(uint a, uint b) internal returns (uint) {

    assert(b <= a);

    return a - b;

  }

  function safeAdd(uint a, uint b) internal returns (uint) {

    uint c = a + b;

    assert(c>=a && c>=b);

    return c;

  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a >= b ? a : b;

  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a < b ? a : b;

  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {

    return a >= b ? a : b;

  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {

    return a < b ? a : b;

  }

}

/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}

/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;

  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() {

    owner = msg.sender;

  }

  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }

  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }

}

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/*

 * Haltable

 *

 * Abstract contract that allows children to implement an

 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.

 *

 *

 * Originally envisioned in FirstBlood ICO contract.

 */

contract Haltable is Ownable {

  bool public halted;

  modifier stopInEmergency {

    if (halted) throw;

    _;

  }

  modifier stopNonOwnersInEmergency {

    if (halted && msg.sender != owner) throw;

    _;

  }

  modifier onlyInEmergency {

    if (!halted) throw;

    _;

  }

  // called by the owner on emergency, triggers stopped state

  function halt() external onlyOwner {

    halted = true;

  }

  // called by the owner on end of emergency, returns to normal state

  function unhalt() external onlyOwner onlyInEmergency {

    halted = false;

  }

}

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * Interface for defining crowdsale pricing.

 */

contract PricingStrategy {

  /** Interface declaration. */

  function isPricingStrategy() public constant returns (bool) {

    return true;

  }

  /** Self check if all references are correctly set.

   *

   * Checks that pricing strategy matches crowdsale parameters.

   */

  function isSane(address crowdsale) public constant returns (bool) {

    return true;

  }

  /**

   * @dev Pricing tells if this is a presale purchase or not.

     @param purchaser Address of the purchaser

     @return False by default, true if a presale purchaser

   */

  function isPresalePurchase(address purchaser) public constant returns (bool) {

    return false;

  }

  /**

   * When somebody tries to buy tokens for X eth, calculate how many tokens they get.

   *

   *

   * @param value - What is the value of the transaction send in as wei

   * @param tokensSold - how much tokens have been sold this far

   * @param weiRaised - how much money has been raised this far in the main token sale - this number excludes presale

   * @param msgSender - who is the investor of this transaction

   * @param decimals - how many decimal units the token has

   * @return Amount of tokens the investor receives

   */

  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);

}

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * Finalize agent defines what happens at the end of succeseful crowdsale.

 *

 * - Allocate tokens for founders, bounties and community

 * - Make tokens transferable

 * - etc.

 */

contract FinalizeAgent {

  function isFinalizeAgent() public constant returns(bool) {

    return true;

  }

  /** Return true if we can run finalizeCrowdsale() properly.

   *

   * This is a safety check function that doesn't allow crowdsale to begin

   * unless the finalizer has been set up properly.

   */

  function isSane() public constant returns (bool);

  /** Called once by crowdsale finalize() if the sale was success. */

  function finalizeCrowdsale();

}

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * A token that defines fractional units as decimals.

 */

contract FractionalERC20 is ERC20 {

  uint public decimals;

}

/**

 * Abstract base contract for token sales.

 *

 * Handle

 * - start and end dates

 * - accepting investments

 * - minimum funding goal and refund

 * - various statistics during the crowdfund

 * - different pricing strategies

 * - different investment policies (require server side customer id, allow only whitelisted addresses)

 *

 */

contract Crowdsale is Haltable {

  /* Max investment count when we are still allowed to change the multisig address */

  uint public MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE = 5;

  using SafeMathLib for uint;

  /* The token we are selling */

  FractionalERC20 public token;

  /* How we are going to price our offering */

  PricingStrategy public pricingStrategy;

  /* Post-success callback */

  FinalizeAgent public finalizeAgent;

  /* tokens will be transfered from this address */

  address public multisigWallet;

  /* if the funding goal is not reached, investors may withdraw their funds */

  uint public minimumFundingGoal;

  /* the UNIX timestamp start date of the crowdsale */

  uint public startsAt;

  /* the UNIX timestamp end date of the crowdsale */

  uint public endsAt;

  /* the number of tokens already sold through this contract*/

  uint public tokensSold = 0;

  /* How many wei of funding we have raised */

  uint public weiRaised = 0;

  /* Calculate incoming funds from presale contracts and addresses */

  uint public presaleWeiRaised = 0;

  /* How many distinct addresses have invested */

  uint public investorCount = 0;

  /* How much wei we have returned back to the contract after a failed crowdfund. */

  uint public loadedRefund = 0;

  /* How much wei we have given back to investors.*/

  uint public weiRefunded = 0;

  /* Has this crowdsale been finalized */

  bool public finalized;

  /* Do we need to have unique contributor id for each customer */

  bool public requireCustomerId;

  /**

    * Do we verify that contributor has been cleared on the server side (accredited investors only).

    * This method was first used in FirstBlood crowdsale to ensure all contributors have accepted terms on sale (on the web).

    */

  bool public requiredSignedAddress;

  /* Server side address that signed allowed contributors (Ethereum addresses) that can participate the crowdsale */

  address public signerAddress;

  /** How much ETH each address has invested to this crowdsale */

  mapping (address => uint256) public investedAmountOf;

  /** How much tokens this crowdsale has credited for each investor address */

  mapping (address => uint256) public tokenAmountOf;

  /** Addresses that are allowed to invest even before ICO offical opens. For testing, for ICO partners, etc. */

  mapping (address => bool) public earlyParticipantWhitelist;

  /** This is for manul testing for the interaction from owner wallet. You can set it to any value and inspect this in blockchain explorer to see that crowdsale interaction works. */

  uint public ownerTestValue;

  /** State machine

   *

   * - Preparing: All contract initialization calls and variables have not been set yet

   * - Prefunding: We have not passed start time yet

   * - Funding: Active crowdsale

   * - Success: Minimum funding goal reached

   * - Failure: Minimum funding goal not reached before ending time

   * - Finalized: The finalized has been called and succesfully executed

   * - Refunding: Refunds are loaded on the contract for reclaim.

   */

  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  // A new investment was made

  event Invested(address investor, uint weiAmount, uint tokenAmount, uint128 customerId);

  // Refund was processed for a contributor

  event Refund(address investor, uint weiAmount);

  // The rules were changed what kind of investments we accept

  event InvestmentPolicyChanged(bool newRequireCustomerId, bool newRequiredSignedAddress, address newSignerAddress);

  // Address early participation whitelist status changed

  event Whitelisted(address addr, bool status);

  // Crowdsale end time has been changed

  event EndsAtChanged(uint newEndsAt);

  function Crowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal) {

    owner = msg.sender;

    token = FractionalERC20(_token);

    setPricingStrategy(_pricingStrategy);

    multisigWallet = _multisigWallet;

    if(multisigWallet == 0) {

        throw;

    }

    if(_start == 0) {

        throw;

    }

    startsAt = _start;

    if(_end == 0) {

        throw;

    }

    endsAt = _end;

    // Don't mess the dates

    if(startsAt >= endsAt) {

        throw;

    }

    // Minimum funding goal can be zero

    minimumFundingGoal = _minimumFundingGoal;

  }

  /**

   * Don't expect to just send in money and get tokens.

   */

  function() payable {

    throw;

  }

  /**

   * Make an investment.

   *

   * Crowdsale must be running for one to invest.

   * We must have not pressed the emergency brake.

   *

   * @param receiver The Ethereum address who receives the tokens

   * @param customerId (optional) UUID v4 to track the successful payments on the server side

   *

   */

  function investInternal(address receiver, uint128 customerId) stopInEmergency private {

    // Determine if it's a good time to accept investment from this participant

    if(getState() == State.PreFunding) {

      // Are we whitelisted for early deposit

      if(!earlyParticipantWhitelist[receiver]) {

        throw;

      }

    } else if(getState() == State.Funding) {

      // Retail participants can only come in when the crowdsale is running

      // pass

    } else {

      // Unwanted state

      throw;

    }

    uint weiAmount = msg.value;

    // Account presale sales separately, so that they do not count against pricing tranches

    uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised - presaleWeiRaised, tokensSold, msg.sender, token.decimals());

    if(tokenAmount == 0) {

      // Dust transaction

      throw;

    }

    if(investedAmountOf[receiver] == 0) {

       // A new investor

       investorCount++;

    }

    // Update investor

    investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);

    tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);

    // Update totals

    weiRaised = weiRaised.plus(weiAmount);

    tokensSold = tokensSold.plus(tokenAmount);

    if(pricingStrategy.isPresalePurchase(receiver)) {

        presaleWeiRaised = presaleWeiRaised.plus(weiAmount);

    }

    // Check that we did not bust the cap

    if(isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold)) {

      throw;

    }

    assignTokens(receiver, tokenAmount);

    // Pocket the money

    if(!multisigWallet.send(weiAmount)) throw;

    // Tell us invest was success

    Invested(receiver, weiAmount, tokenAmount, customerId);

  }

  /**

   * Preallocate tokens for the early investors.

   *

   * Preallocated tokens have been sold before the actual crowdsale opens.

   * This function mints the tokens and moves the crowdsale needle.

   *

   * Investor count is not handled; it is assumed this goes for multiple investors

   * and the token distribution happens outside the smart contract flow.

   *

   * No money is exchanged, as the crowdsale team already have received the payment.

   *

   * @param fullTokens tokens as full tokens - decimal places added internally

   * @param weiPrice Price of a single full token in wei

   *

   */

  function preallocate(address receiver, uint fullTokens, uint weiPrice) public onlyOwner {

    uint tokenAmount = fullTokens * 10**token.decimals();

    uint weiAmount = weiPrice * fullTokens; // This can be also 0, we give out tokens for free

    weiRaised = weiRaised.plus(weiAmount);

    tokensSold = tokensSold.plus(tokenAmount);

    investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);

    tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);

    assignTokens(receiver, tokenAmount);

    // Tell us invest was success

    Invested(receiver, weiAmount, tokenAmount, 0);

  }

  /**

   * Allow anonymous contributions to this crowdsale.

   */

  function investWithSignedAddress(address addr, uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {

     bytes32 hash = sha256(addr);

     if (ecrecover(hash, v, r, s) != signerAddress) throw;

     if(customerId == 0) throw;  // UUIDv4 sanity check

     investInternal(addr, customerId);

  }

  /**

   * Track who is the customer making the payment so we can send thank you email.

   */

  function investWithCustomerId(address addr, uint128 customerId) public payable {

    if(requiredSignedAddress) throw; // Crowdsale allows only server-side signed participants

    if(customerId == 0) throw;  // UUIDv4 sanity check

    investInternal(addr, customerId);

  }

  /**

   * Allow anonymous contributions to this crowdsale.

   */

  function invest(address addr) public payable {

    if(requireCustomerId) throw; // Crowdsale needs to track participants for thank you email

    if(requiredSignedAddress) throw; // Crowdsale allows only server-side signed participants

    investInternal(addr, 0);

  }

  /**

   * Invest to tokens, recognize the payer and clear his address.

   *

   */

  function buyWithSignedAddress(uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {

    investWithSignedAddress(msg.sender, customerId, v, r, s);

  }

  /**

   * Invest to tokens, recognize the payer.

   *

   */

  function buyWithCustomerId(uint128 customerId) public payable {

    investWithCustomerId(msg.sender, customerId);

  }

  /**

   * The basic entry point to participate the crowdsale process.

   *

   * Pay for funding, get invested tokens back in the sender address.

   */

  function buy() public payable {

    invest(msg.sender);

  }

  /**

   * Finalize a succcesful crowdsale.

   *

   * The owner can triggre a call the contract that provides post-crowdsale actions, like releasing the tokens.

   */

  function finalize() public inState(State.Success) onlyOwner stopInEmergency {

    // Already finalized

    if(finalized) {

      throw;

    }

    // Finalizing is optional. We only call it if we are given a finalizing agent.

    if(address(finalizeAgent) != 0) {

      finalizeAgent.finalizeCrowdsale();

    }

    finalized = true;

  }

  /**

   * Allow to (re)set finalize agent.

   *

   * Design choice: no state restrictions on setting this, so that we can fix fat finger mistakes.

   */

  function setFinalizeAgent(FinalizeAgent addr) onlyOwner {

    finalizeAgent = addr;

    // Don't allow setting bad agent

    if(!finalizeAgent.isFinalizeAgent()) {

      throw;

    }

  }

  /**

   * Set policy do we need to have server-side customer ids for the investments.

   *

   */

  function setRequireCustomerId(bool value) onlyOwner {

    requireCustomerId = value;

    InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);

  }

  /**

   * Set policy if all investors must be cleared on the server side first.

   *

   * This is e.g. for the accredited investor clearing.

   *

   */

  function setRequireSignedAddress(bool value, address _signerAddress) onlyOwner {

    requiredSignedAddress = value;

    signerAddress = _signerAddress;

    InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);

  }

  /**

   * Allow addresses to do early participation.

   *

   * TODO: Fix spelling error in the name

   */

  function setEarlyParicipantWhitelist(address addr, bool status) onlyOwner {

    earlyParticipantWhitelist[addr] = status;

    Whitelisted(addr, status);

  }

  /**

   * Allow crowdsale owner to close early or extend the crowdsale.

   *

   * This is useful e.g. for a manual soft cap implementation:

   * - after X amount is reached determine manual closing

   *

   * This may put the crowdsale to an invalid state,

   * but we trust owners know what they are doing.

   *

   */

  function setEndsAt(uint time) onlyOwner {

    if(now > time) {

      throw; // Don't change past

    }

    endsAt = time;

    EndsAtChanged(endsAt);

  }

  /**

   * Allow to (re)set pricing strategy.

   *

   * Design choice: no state restrictions on the set, so that we can fix fat finger mistakes.

   */

  function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {

    pricingStrategy = _pricingStrategy;

    // Don't allow setting bad agent

    if(!pricingStrategy.isPricingStrategy()) {

      throw;

    }

  }

  /**

   * Allow to change the team multisig address in the case of emergency.

   *

   * This allows to save a deployed crowdsale wallet in the case the crowdsale has not yet begun

   * (we have done only few test transactions). After the crowdsale is going

   * then multisig address stays locked for the safety reasons.

   */

  function setMultisig(address addr) public onlyOwner {

    // Change

    if(investorCount > MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE) {

      throw;

    }

    multisigWallet = addr;

  }

  /**

   * Allow load refunds back on the contract for the refunding.

   *

   * The team can transfer the funds back on the smart contract in the case the minimum goal was not reached..

   */

  function loadRefund() public payable inState(State.Failure) {

    if(msg.value == 0) throw;

    loadedRefund = loadedRefund.plus(msg.value);

  }

  /**

   * Investors can claim refund.

   *

   * Note that any refunds from proxy buyers should be handled separately,

   * and not through this contract.

   */

  function refund() public inState(State.Refunding) {

    uint256 weiValue = investedAmountOf[msg.sender];

    if (weiValue == 0) throw;

    investedAmountOf[msg.sender] = 0;

    weiRefunded = weiRefunded.plus(weiValue);

    Refund(msg.sender, weiValue);

    if (!msg.sender.send(weiValue)) throw;

  }

  /**

   * @return true if the crowdsale has raised enough money to be a successful.

   */

  function isMinimumGoalReached() public constant returns (bool reached) {

    return weiRaised >= minimumFundingGoal;

  }

  /**

   * Check if the contract relationship looks good.

   */

  function isFinalizerSane() public constant returns (bool sane) {

    return finalizeAgent.isSane();

  }

  /**

   * Check if the contract relationship looks good.

   */

  function isPricingSane() public constant returns (bool sane) {

    return pricingStrategy.isSane(address(this));

  }

  /**

   * Crowdfund state machine management.

   *

   * We make it a function and do not assign the result to a variable, so there is no chance of the variable being stale.

   */

  function getState() public constant returns (State) {

    if(finalized) return State.Finalized;

    else if (address(finalizeAgent) == 0) return State.Preparing;

    else if (!finalizeAgent.isSane()) return State.Preparing;

    else if (!pricingStrategy.isSane(address(this))) return State.Preparing;

    else if (block.timestamp < startsAt) return State.PreFunding;

    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;

    else if (isMinimumGoalReached()) return State.Success;

    else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) return State.Refunding;

    else return State.Failure;

  }

  /** This is for manual testing of multisig wallet interaction */

  function setOwnerTestValue(uint val) onlyOwner {

    ownerTestValue = val;

  }

  /** Interface marker. */

  function isCrowdsale() public constant returns (bool) {

    return true;

  }

  //

  // Modifiers

  //

  /** Modified allowing execution only if the crowdsale is currently running.  */

  modifier inState(State state) {

    if(getState() != state) throw;

    _;

  }

  //

  // Abstract functions

  //

  /**

   * Check if the current invested breaks our cap rules.

   *

   *

   * The child contract must define their own cap setting rules.

   * We allow a lot of flexibility through different capping strategies (ETH, token count)

   * Called from invest().

   *

   * @param weiAmount The amount of wei the investor tries to invest in the current transaction

   * @param tokenAmount The amount of tokens we try to give to the investor in the current transaction

   * @param weiRaisedTotal What would be our total raised balance after this transaction

   * @param tokensSoldTotal What would be our total sold tokens count after this transaction

   *

   * @return true if taking this investment would break our cap rules

   */

  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken);

  /**

   * Check if the current crowdsale is full and we can no longer sell any tokens.

   */

  function isCrowdsaleFull() public constant returns (bool);

  /**

   * Create new tokens or transfer issued tokens to the investor depending on the cap model.

   */

  function assignTokens(address receiver, uint tokenAmount) private;

}

/**

 * ICO crowdsale contract that is capped by amout of tokens.

 *

 * - Tokens are dynamically created during the crowdsale

 *

 *

 */

contract MintedTokenCappedCrowdsale is Crowdsale {

  /* Maximum amount of tokens this crowdsale can sell. */

  uint public maximumSellableTokens;

  function MintedTokenCappedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens) Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal) {

    maximumSellableTokens = _maximumSellableTokens;

  }

  /**

   * Called from invest() to confirm if the curret investment does not break our cap rule.

   */

  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {

    return tokensSoldTotal > maximumSellableTokens;

  }

  function isCrowdsaleFull() public constant returns (bool) {

    return tokensSold >= maximumSellableTokens;

  }

  /**

   * Dynamically create tokens and assign them to the investor.

   */

  function assignTokens(address receiver, uint tokenAmount) private {

    MintableToken mintableToken = MintableToken(token);

    mintableToken.mint(receiver, tokenAmount);

  }

}



/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.

 *

 * Based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */

  event Minted(address receiver, uint amount);

  /* Actual balances of token holders */

  mapping(address => uint) balances;

  /* approve() allowances */

  mapping (address => mapping (address => uint)) allowed;

  /* Interface declaration */

  function isToken() public constant returns (bool weAre) {

    return true;

  }

  function transfer(address _to, uint _value) returns (bool success) {

    balances[msg.sender] = safeSub(balances[msg.sender], _value);

    balances[_to] = safeAdd(balances[_to], _value);

    Transfer(msg.sender, _to, _value);

    return true;

  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {

    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);

    balances[_from] = safeSub(balances[_from], _value);

    allowed[_from][msg.sender] = safeSub(_allowance, _value);

    Transfer(_from, _to, _value);

    return true;

  }

  function balanceOf(address _owner) constant returns (uint balance) {

    return balances[_owner];

  }

  function approve(address _spender, uint _value) returns (bool success) {

    // To change the approve amount you first have to reduce the addresses`

    //  allowance to zero by calling `approve(_spender, 0)` if it is not

    //  already 0 to mitigate the race condition described here:

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;

  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {

    return allowed[_owner][_spender];

  }

}

/**

 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net

 *

 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt

 */

/**

 * Safe unsigned safe math.

 *

 * https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736#.750gwtwli

 *

 * Originally from https://raw.githubusercontent.com/AragonOne/zeppelin-solidity/master/contracts/SafeMathLib.sol

 *

 * Maintained here until merged to mainline zeppelin-solidity.

 *

 */

library SafeMathLib {

  function times(uint a, uint b) returns (uint) {

    uint c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }

  function minus(uint a, uint b) returns (uint) {

    assert(b <= a);

    return a - b;

  }

  function plus(uint a, uint b) returns (uint) {

    uint c = a + b;

    assert(c>=a);

    return c;

  }

}

/**

 * A token that can increase its supply by another contract.

 *

 * This allows uncapped crowdsale by dynamically increasing the supply when money pours in.

 * Only mint agents, contracts whitelisted by owner, can mint new tokens.

 *

 */

contract MintableToken is StandardToken, Ownable {

  using SafeMathLib for uint;

  bool public mintingFinished = false;

  /** List of agents that are allowed to create new tokens */

  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state  );

  /**

   * Create new tokens and allocate them to an address..

   *

   * Only callably by a crowdsale contract (mint agent).

   */

  function mint(address receiver, uint amount) onlyMintAgent canMint public {

    totalSupply = totalSupply.plus(amount);

    balances[receiver] = balances[receiver].plus(amount);

    // This will make the mint transaction apper in EtherScan.io

    // We can remove this after there is a standardized minting event

    Transfer(0, receiver, amount);

  }

  /**

   * Owner can allow a crowdsale contract to mint new tokens.

   */

  function setMintAgent(address addr, bool state) onlyOwner canMint public {

    mintAgents[addr] = state;

    MintingAgentChanged(addr, state);

  }

  modifier onlyMintAgent() {

    // Only crowdsale contracts are allowed to mint new tokens

    if(!mintAgents[msg.sender]) {

        throw;

    }

    _;

  }

  /** Make sure we are not done yet. */

  modifier canMint() {

    if(mintingFinished) throw;

    _;

  }

}

contract GetWhitelist is Ownable {

    using SafeMathLib for uint;

    event NewEntry(address whitelisted);

    event NewBatch();

    event EdittedEntry(address whitelisted, uint tier);

    event WhitelisterChange(address whitelister, bool iswhitelister);

    struct WhitelistInfo {

        uint presaleAmount;

        uint tier1Amount;

        uint tier2Amount;

        uint tier3Amount;

        uint tier4Amount;

        bool isWhitelisted;

    }

    mapping (address => bool) public whitelisters;

    

    mapping (address => WhitelistInfo) public entries;

    uint presaleCap;

    uint tier1Cap;

    uint tier2Cap;

    uint tier3Cap;

    uint tier4Cap;

    modifier onlyWhitelister() {

        require(whitelisters[msg.sender]);

        _;

    }

    function GetWhitelist(uint _presaleCap, uint _tier1Cap, uint _tier2Cap, uint _tier3Cap, uint _tier4Cap) {

        presaleCap = _presaleCap;

        tier1Cap = _tier1Cap;

        tier2Cap = _tier2Cap;

        tier3Cap = _tier3Cap;

        tier4Cap = _tier4Cap;

    }

    function isGetWhiteList() constant returns (bool) {

        return true;

    }

    function acceptBatched(address[] _addresses, bool _isEarly) onlyWhitelister {

        // trying to save up some gas here

        uint _presaleCap;

        if (_isEarly) {

            _presaleCap = presaleCap;

        } else {

            _presaleCap = 0;

        }

        for (uint i=0; i<_addresses.length; i++) {

            entries[_addresses[i]] = WhitelistInfo(

                _presaleCap,

                tier1Cap,

                tier2Cap,

                tier3Cap,

                tier4Cap,

                true

            );

        }

        NewBatch();

    }

    function accept(address _address, bool _isEarly) onlyWhitelister {

        require(!entries[_address].isWhitelisted);

        uint _presaleCap;

        if (_isEarly) {

            _presaleCap = presaleCap;

        } else {

            _presaleCap = 0;

        }

        entries[_address] = WhitelistInfo(_presaleCap, tier1Cap, tier2Cap, tier3Cap, tier4Cap, true);

        NewEntry(_address);

    }

    function subtractAmount(address _address, uint _tier, uint _amount) onlyWhitelister {

        require(_amount > 0);

        require(entries[_address].isWhitelisted);

        if (_tier == 0) {

            entries[_address].presaleAmount = entries[_address].presaleAmount.minus(_amount);

            EdittedEntry(_address, 0);

            return;

        }else if (_tier == 1) {

            entries[_address].tier1Amount = entries[_address].tier1Amount.minus(_amount);

            EdittedEntry(_address, 1);

            return;

        }else if (_tier == 2) {

            entries[_address].tier2Amount = entries[_address].tier2Amount.minus(_amount);

            EdittedEntry(_address, 2);

            return;

        }else if (_tier == 3) {

            entries[_address].tier3Amount = entries[_address].tier3Amount.minus(_amount);

            EdittedEntry(_address, 3);

            return;

        }else if (_tier == 4) {

            entries[_address].tier4Amount = entries[_address].tier4Amount.minus(_amount);

            EdittedEntry(_address, 4);

            return;

        }

        revert();

    }

    function setWhitelister(address _whitelister, bool _isWhitelister) onlyOwner {

        whitelisters[_whitelister] = _isWhitelister;

        WhitelisterChange(_whitelister, _isWhitelister);

    }

    function setCaps(uint _presaleCap, uint _tier1Cap, uint _tier2Cap, uint _tier3Cap, uint _tier4Cap) onlyOwner {

        presaleCap = _presaleCap;

        tier1Cap = _tier1Cap;

        tier2Cap = _tier2Cap;

        tier3Cap = _tier3Cap;

        tier4Cap = _tier4Cap;

    }

    function() payable {

        revert();

    }

}

contract GetCrowdsale is MintedTokenCappedCrowdsale {

    uint public lockTime;

    FinalizeAgent presaleFinalizeAgent;

    event PresaleUpdated(uint weiAmount, uint tokenAmount);

    function GetCrowdsale(

        uint _lockTime, FinalizeAgent _presaleFinalizeAgent,

        address _token, PricingStrategy _pricingStrategy, address _multisigWallet,

        uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens)

        MintedTokenCappedCrowdsale(_token, _pricingStrategy, _multisigWallet,

            _start, _end, _minimumFundingGoal, _maximumSellableTokens)

    {

        require(_presaleFinalizeAgent.isSane());

        require(_lockTime > 0);

        lockTime = _lockTime;

        presaleFinalizeAgent = _presaleFinalizeAgent;

    }

    function logPresaleResults(uint tokenAmount, uint weiAmount) returns (bool) {

        require(msg.sender == address(presaleFinalizeAgent));

        weiRaised = weiRaised.plus(weiAmount);

        tokensSold = tokensSold.plus(tokenAmount);

        presaleWeiRaised = presaleWeiRaised.plus(weiAmount);

        PresaleUpdated(weiAmount, tokenAmount);

        return true;

    }

    // overriden because presaleWeiRaised was not altered and would mess with the TranchePricing

    function preallocate(address receiver, uint fullTokens, uint weiPrice) public onlyOwner {

        uint tokenAmount = fullTokens * 10**token.decimals();

        uint weiAmount = weiPrice * fullTokens; // This can be also 0, we give out tokens for free

        weiRaised = weiRaised.plus(weiAmount);

        tokensSold = tokensSold.plus(tokenAmount);

        presaleWeiRaised = presaleWeiRaised.plus(weiAmount);

        investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);

        tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);

        assignTokens(receiver, tokenAmount);

        // Tell us invest was success

        Invested(receiver, weiAmount, tokenAmount, 0);

    }

    function setEarlyParicipantWhitelist(address addr, bool status) onlyOwner {

        // We don't need this function, we have external whitelist

        revert();

    }

    // added this here because it was not visible by preallocate

    function assignTokens(address receiver, uint tokenAmount) private {

        MintableToken mintableToken = MintableToken(token);

        mintableToken.mint(receiver, tokenAmount);

    }

    function finalize() public inState(State.Success) onlyOwner stopInEmergency {

        require(now > endsAt + lockTime);

        super.finalize();

    }

    function() payable {

        invest(msg.sender);

    }

}