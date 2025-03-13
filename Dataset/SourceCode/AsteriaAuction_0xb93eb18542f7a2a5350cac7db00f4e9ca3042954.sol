// SPDX-License-Identifier: MIT



/**

* Team: Asteria Labs

* Author: Lambdalf the White

*/



pragma solidity 0.8.17;



import "@lambdalf-dev/ethereum-contracts/contracts/interfaces/IEtherErrors.sol";

import "@lambdalf-dev/ethereum-contracts/contracts/interfaces/INFTSupplyErrors.sol";

import "@lambdalf-dev/ethereum-contracts/contracts/utils/ERC173.sol";

import "@lambdalf-dev/ethereum-contracts/contracts/utils/ContractState.sol";

import "@lambdalf-dev/ethereum-contracts/contracts/utils/Whitelist_ECDSA.sol";



interface IAsteriaPass {

  function airdrop(address account_, uint256 tokenId_) external;

}



contract AsteriaAuction is IEtherErrors, INFTSupplyErrors, ERC173, ContractState, Whitelist_ECDSA {

  // **************************************

  // *****    BYTECODE  VARIABLES     *****

  // **************************************

  	uint8 public constant AUCTION = 1;

  	uint8 public constant PRESALE = 2;

  	uint8 public constant REFUND = 3;

  	uint8 public constant WHITELIST = 4;

    uint256 public constant MAX_AMOUNT = 1;

    uint256 private constant _RESERVE = 5;

    uint256 public immutable DEPOSIT_PRICE; // 0.5 ETH

    uint256 public immutable MAX_SUPPLY;

  // **************************************



  // **************************************

  // *****     STORAGE VARIABLES      *****

  // **************************************

    mapping (address => uint256) public depositedAmount;

    mapping (address => bool) public hasPurchased;

    IAsteriaPass public asteriaPass;

    uint256 public salePrice;

    address payable private _asteria;

    address payable private _stable;

    uint256 private _nextWaitlist;

    uint256 private _nextPurchase = 1;

    mapping (uint256 => address) private _waitlist;

    mapping (uint256 => address) private _purchasers;

  // **************************************



  // **************************************

  // *****           ERROR            *****

  // **************************************

    /**

    * @dev Thrown when user who already deposited tries to make a new deposit.

    * 

    * @param account the address trying to make a deposit

    */

    error AA_ALREADY_DEPOSITED(address account);

    /**

    * @dev Thrown when user who already purchased a pass tries to claim a refund or complete a purchase.

    * 

    * @param account the address trying to claim a refund or completing a purchase

    */

    error AA_ALREADY_PURCHASED(address account);

    /**

    * @dev Thrown when new sale price is lower than {DEPOSIT_PRICE}

    */

    error AA_INVALID_PRICE();

    /**

    * @dev Thrown when trying to airdrop tokens when none are due.

    */

    error AA_NO_AIRDROP_DUE();

    /**

    * @dev Thrown when user with no deposit tries to claim a refund or complete a purchase.

    * 

    * @param account the address trying to claim a refund or completing a purchase

    */

    error AA_NO_DEPOSIT(address account);

    /**

    * @dev Thrown when trying to airdrop tokens while pass contract is not set.

    */

    error AA_PASS_NOT_SET();

    /**

    * @dev Thrown when trying to airdrop waitlist before finishing to airdrop purchases.

    */

    error AA_PURCHASES_PENDING();

    /**

    * @dev Thrown when trying to join the waitlist when it's full

    */

    error AA_WAITLIST_FULL();

  // **************************************



  // **************************************

  // *****           EVENT            *****

  // **************************************

    /**

    * Emitted when a user deposits money for presale

    * 

    * @param account the address purchasing a pass

    * @param amount the amount deposited

    */

    event Deposited(address indexed account, uint256 indexed amount);

    /**

    * Emitted when a user purchases a pass

    * 

    * @param account the address purchasing a pass

    */

    event Purchased(address indexed account);

    /**

    * Emitted when a user gets refunded their presale deposit

    * 

    * @param account the address purchasing a pass

    * @param amount the amount refunded

    */

    event Refunded(address indexed account, uint256 indexed amount);

  // **************************************



  constructor(address asteria_, address stable_, address signer_, uint256 maxSupply_, uint256 depositPrice_, uint256 salePrice_) {

    _asteria = payable(asteria_);

    _stable = payable(stable_);

    MAX_SUPPLY = maxSupply_;

    DEPOSIT_PRICE = depositPrice_;

    salePrice = salePrice_;

    _nextWaitlist = maxSupply_ + 1;

    _setWhitelist(signer_);

    _setOwner(msg.sender);

  }



  // **************************************

  // *****          MODIFIER          *****

  // **************************************

  	/**

  	* @dev Ensures that the caller has not already deposited.

  	*/

  	modifier hasNotDeposited() {

    	if (depositedAmount[msg.sender] != 0) {

    		revert AA_ALREADY_DEPOSITED(msg.sender);

    	}

    	_;

  	}

  	/**

  	* @dev Ensures that the caller has not already purchased a pass.

  	*/

  	modifier hasNotPurchased() {

    	if (hasPurchased[msg.sender]) {

    		revert AA_ALREADY_PURCHASED(msg.sender);

    	}

    	_;

  	}

  	/**

  	* @dev Ensures that the pass contract is set.

  	*/

  	modifier passIsSet() {

  		if (address(asteriaPass) == address(0)) {

  			revert AA_PASS_NOT_SET();

  		}

  		_;

  	}

  	/**

  	* @dev Ensures that the correct amount of ETH has been sent to cover a purchase or deposit.

  	* 

  	* @param totalPrice_ the amount of Eth required for this payment

  	*/

  	modifier validateEthAmount(uint256 totalPrice_) {

  		uint256 _expected_ = depositedAmount[msg.sender] > 0 ?

  			totalPrice_ - depositedAmount[msg.sender] : totalPrice_;

    	if (msg.value != _expected_) {

    		revert ETHER_INCORRECT_PRICE(msg.value, _expected_);

    	}

    	_;

  	}

  // **************************************



  // **************************************

  // *****          INTERNAL          *****

  // **************************************

    /**

    * @dev Internal function processing an ether payment.

    * 

    * @param recipient_ the address receiving the payment

    * @param amount_ the amount sent

    */

    function _processEthPayment(address payable recipient_, uint256 amount_) internal {

      // solhint-disable-next-line

      (bool _success_,) = recipient_.call{ value: amount_ }("");

      if (! _success_) {

        revert ETHER_TRANSFER_FAIL(recipient_, amount_);

      }

    }

  	/**

  	* @dev Internal function processing a purchase.

  	* 

    * @param account_ the address purchasing a token

  	*/

  	function _processPurchase(address account_) internal {

  		if (_nextPurchase > MAX_SUPPLY) {

  			revert NFT_MAX_SUPPLY(1, 0);

  		}

  		hasPurchased[account_] = true;

    	_purchasers[_nextPurchase] = account_;

    	unchecked {

    		++_nextPurchase;

    	}

    	emit Purchased(account_);

      uint256 _share_ = salePrice / 2;

      _processEthPayment(_stable, _share_);

      _processEthPayment(_asteria, _share_);

  	}

  // **************************************



  // **************************************

  // *****           PUBLIC           *****

  // **************************************

    /**

    * @notice Claims a refund of a deposit.

    * 

    * @param proof_ Signature confirming that the caller is eligible for a refund

    * 

    * Requirements:

    * 

    * - Contract state must be {REFUND}.

    * - Caller must have deposited some preorder funds.

    * - Caller must be eligible for a refund.

    * - Caller must be able to receive ETH.

    * - Emits a {Refunded} event.

    */

    function claimRefund(Proof calldata proof_) external isState(REFUND) {

    	uint256 _balance_ = depositedAmount[msg.sender];

      if (_balance_ == 0) {

      	revert AA_NO_DEPOSIT(msg.sender);

      }

      checkWhitelistAllowance(msg.sender, REFUND, MAX_AMOUNT, proof_);

      depositedAmount[msg.sender] = 0;

      emit Refunded(msg.sender, _balance_);

      _processEthPayment(payable(msg.sender), _balance_);

    }

    /**

    * @notice Completes a winning bid purchase.

    * 

    * @param proof_ Signature confirming that the caller is eligible for a purchase

    * 

    * Requirements:

    * 

    * - Contract state must be {PRESALE}.

    * - Caller must be eligible for a direct purchase.

    * - Caller must not have already purchased a pass.

    * - Caller must send enough ETH to complete the purchase.

    * - Emits a {Purchased} event.

    * - Transfers {salePrice} directly to withdrawal addresses.

    */

    function completePurchase(Proof calldata proof_)

    external

    payable

    isState(PRESALE)

    hasNotPurchased

    validateEthAmount(salePrice) {

      checkWhitelistAllowance(msg.sender, PRESALE, MAX_AMOUNT, proof_);

    	depositedAmount[msg.sender] = 0;

    	_processPurchase(msg.sender);

    }

    /**

    * @notice Deposits a portion of the sale price.

    * 

    * Requirements:

    * 

    * - Contract state must be {AUCTION}.

    * - Caller must not already have made a deposit.

    * - Caller must send enough ETH to cover the deposit price.

    * - Emits a {Deposited} event.

    */

    function depositBid() external payable isState(AUCTION) hasNotDeposited validateEthAmount(DEPOSIT_PRICE) {

    	depositedAmount[msg.sender] = msg.value;

    	emit Deposited(msg.sender, msg.value);

    }

    /**

    * @notice Deposits the purchase price to join the waitlist.

    * 

    * Requirements:

    * 

    * - Contract state must be {PRESALE}.

    * - Caller must not have already purchased a pass.

    * - Caller must send enough ETH to complete the purchase.

    * - Emits a {Deposited} event.

    */

    function joinWaitlist() external payable isState(PRESALE) hasNotPurchased validateEthAmount(salePrice) {

    	if (_nextWaitlist == 1) {

    		revert AA_WAITLIST_FULL();

    	}

    	unchecked {

    		--_nextWaitlist;

    		depositedAmount[msg.sender] += msg.value;

    	}

    	_waitlist[_nextWaitlist] = msg.sender;

    	emit Deposited(msg.sender, msg.value);

    }

    /**

    * @notice Purchases a Pass.

    * 

    * @param proof_ Signature confirming that the caller is eligible for a purchase

    * 

    * Requirements:

    * 

    * - Contract state must be {PRESALE}.

    * - Caller must not have already purchased a pass.

    * - Caller must send enough ETH to cover the purchase.

    * - Caller must be eligible for a direct purchase.

    * - Emits a {Purchased} event.

    * - Transfers {salePrice} directly to withdrawal addresses.

    */

    function purchasePresale(Proof calldata proof_)

    external

    payable

    isState(PRESALE)

    hasNotPurchased

    validateEthAmount(salePrice) {

      checkWhitelistAllowance(msg.sender, WHITELIST, MAX_AMOUNT, proof_);

    	_processPurchase(msg.sender);

    }

  // **************************************



  // **************************************

  // *****       CONTRACT OWNER       *****

  // **************************************

    /**

    * @notice Claims a purchased pass for `to_`.

    * Note: This function allows the team to mint a pass that hasn't been claimed during the claim period

    *   The recipient may be a different address than the purchaser, for example,

    *   if the purchasing wallet has been compromised

    * 

    * @param for_ address that purchased the pass

    * @param to_ address receiving the pass

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    * - `for_` must have purchased a pass.

    */

    // function airdropClaim(address for_, address to_) external onlyOwner {}

    /**

    * @notice Distributes purchased passes.

    * 	Note: It is preferable to not airdrop more than 50 tokens at a time.

    * 

    * @param amount_ the number of passes to distribute

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    * - Asteria pass contract must be set.

    * - Contract state must be {REFUND}.

    */

    function distributePurchasedPass(uint256 amount_) external onlyOwner passIsSet isState(REFUND) {

    	if (_nextPurchase == 1) {

    		revert AA_NO_AIRDROP_DUE();

    	}

    	uint256 _count_;

    	uint256 _index_ = _nextPurchase;

    	while (_index_ > 0 && _count_ < amount_) {

    		unchecked {

    			--_index_;

    		}

    		address _account_ = _purchasers[_index_];

    		if (_account_ != address(0)) {

	    		unchecked {

	    			++_count_;

	    		}

	    		delete _purchasers[_index_];

		    	try asteriaPass.airdrop(_account_, _index_) {}

		      catch Error(string memory reason) {

		        revert(reason);

		      }

    		}

    	}

    }

    /**

    * @notice Distributes waitlisted passes.

    * 	Note: It is preferable to not airdrop more than 50 tokens at a time.

    * 

    * @param amount_ the number of passes to distribute

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    * - Asteria pass contract must be set.

    * - Contract state must be {REFUND}.

    * - All purchased passes must be distributed.

    */

    function distributeWaitlistedPass(uint256 amount_) external onlyOwner passIsSet isState(REFUND) {

    	if (_nextWaitlist > MAX_SUPPLY) {

    		revert AA_NO_AIRDROP_DUE();

    	}

    	if (_purchasers[_nextPurchase - 1] != address(0) && _purchasers[1] != address(0)) {

    		revert AA_PURCHASES_PENDING();

    	}

    	uint256 _count_;

    	uint256 _index_ = MAX_SUPPLY + 1;

    	while (_index_ > 0 && _count_ < amount_) {

    		unchecked {

    			--_index_;

    		}

    		address _account_ = _waitlist[_index_];

    		if (_account_ != address(0)) {

	    		unchecked {

	    			++_count_;

	    		}

	    		delete _waitlist[_index_];

		    	try asteriaPass.airdrop(_account_, _index_) {}

		      catch Error(string memory reason) {

		        revert(reason);

		      }

    		}

    	}

    }

    /**

    * @notice Sets the Asteria Pass contract address.

    * 

    * @param contractAddress_ the Asteria Pass contract address

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    */

    function setAsteriaPass(address contractAddress_) external onlyOwner {

      asteriaPass = IAsteriaPass(contractAddress_);

    }

    /**

    * @notice Updates the contract state.

    * 

    * @param newState_ the new sale state

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    * - `newState_` must be a valid state.

    */

    function setContractState(uint8 newState_) external onlyOwner {

      if (newState_ > REFUND) {

        revert ContractState_INVALID_STATE(newState_);

      }

      _setContractState(newState_);

    }

    /**

    * @notice Updates the sale price.

    * 

    * @param newSalePrice_ the new private price

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    * - `newSalePrice_` must be lower than or equal to {DEPOSIT_PRICE}.

    */

    function setPrice(uint256 newSalePrice_) external onlyOwner {

    	if (DEPOSIT_PRICE > newSalePrice_) {

    		revert AA_INVALID_PRICE();

    	}

      salePrice = newSalePrice_;

    }

    /**

    * @notice Updates the whitelist signer.

    * 

    * @param newAdminSigner_ the new whitelist signer

    *  

    * Requirements:

    * 

    * - Caller must be the contract owner.

    */

    function setWhitelist(address newAdminSigner_) external onlyOwner {

      _setWhitelist(newAdminSigner_);

    }

    /**

    * @notice Updates Asteria and Stable addresses

    * 

    * @param newAsteria_ the new Asteria address

    * @param newStable_ the new Stable address

    *  

    * Requirements:

    * 

    * - Caller must be the contract owner.

    */

    function updateAddresses(address newAsteria_, address newStable_) external onlyOwner {

      _asteria = payable(newAsteria_);

      _stable = payable(newStable_);

    }

    /**

    * @notice Withdraws all the money stored in the contract and splits it between `_asteria` and `_stable`.

    * 

    * Requirements:

    * 

    * - Caller must be the contract owner.

    * - Contract state must be {PAUSED}.

    * - Contract must have a positive balance.

    * - `_asteria` must be able to receive funds.

    * - `_stable` must be able to receive funds.

    */

    function withdraw() public onlyOwner isState(PAUSED) {

      uint256 _amount_ = address(this).balance;

      if (_amount_ == 0) {

        revert ETHER_NO_BALANCE();

      }

      uint256 _share_ = _amount_ / 2;

      _processEthPayment(_stable, _share_);

      _processEthPayment(_asteria, _share_);

    }

  // **************************************



  // **************************************

  // *****            VIEW            *****

  // **************************************

  	/**

  	* @notice Returns the number of passes purchased.

  	* 

  	* @return the number of passes purchased

  	*/

  	function totalPurchased() public view returns (uint256) {

  		return _nextPurchase - 1;

  	}

  	/**

  	* @notice Returns the number of addresses on the waitlist.

  	* 

  	* @return the number of passes purchased

  	*/

  	function totalWaitlisted() public view returns (uint256) {

  		return MAX_SUPPLY + 1 - _nextWaitlist;

  	}

  // **************************************

}