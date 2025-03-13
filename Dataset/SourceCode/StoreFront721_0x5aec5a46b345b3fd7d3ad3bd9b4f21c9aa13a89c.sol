// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;

import "../openzeppelin/access/Ownable.sol";
import "../openzeppelin/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../openzeppelin/utils/SafeERC20.sol";
import "../erc721psi/IERC721PsiKO.sol";

/*
  It saves bytecode to revert on custom errors instead of using require
  statements. We are just declaring these errors for reverting with upon various
  conditions later in this contract.
*/
error CannotEndSaleBeforeItStarts();
error CannotBuyZeroItems();
error CannotBuyBeforeSaleStarts();
error CannotBuyFromEndedSale();
error CannotExceedPerTransactionCap();
error CannotExceedPerCallerCap();
error CannotExceedTotalCap();
error CannotUnderpayForMint();
error RefundTransferFailed();
error SweepingTransferFailed();

/**
  @title A storefront contract built on top of DropShop721 and DropPresaleShop721
         accepts IERC721PsiKO display items (for sale) 

  @author timeout
*/
contract StoreFront721 is
  Ownable, ReentrancyGuard
{
  using SafeERC20 for IERC20;

  event Received(address, uint);
  receive () external payable {
      emit Received(msg.sender, msg.value);
  }

  /**
    This struct is used to define information regarding a particular item that
    the user may choose to place for sale

    @param startTime The time when the public sale begins.
    @param endTime The time when the public sale ends.
    @param totalCap The maximum number of items from the `collection` that may be sold.
    @param callerCap The maximum number of items that a single address may purchase.
    @param transactionCap The maximum number of items that may be purchased in a single transaction.
    @param price The price at which to sell the item.
    @param paymentDestination The destination of claimed payments.
    @param token The address of the token with which purchases will be
      If this is the zero address, then this whitelist will
      conduct purchases using ETH.
  */
  struct Display {
    address paymentDestination;
    address token;
    uint256 startTime;
    uint256 endTime;
    uint256 totalCap;
    uint256 callerCap;
    uint256 transactionCap;
    uint256 price;
  }

  /// A mapping to look up information for each specific display.
  mapping ( bytes32 => Display ) public displays;

  // A double mapping to track the number of items purchases by each caller.
  mapping ( address => mapping(address => uint256) ) public purchaseCounts;
          
  // The total number of items sold on each display
  mapping ( address => uint256) public sold;

  /**
    @dev Adds new display in the storefront to be sold
         If multiple displays exists for the same collection, the
         underlying assumptiong is that they all should have the same
         total capacity.

    @param _cfg A parameter containing store front/display information,
      passed here as a struct to avoid a stack-to-deep error.
  */
  function setDisplay(
    address _collection,
    Display calldata _cfg
  ) external onlyOwner {

    // Perform basic input validation.
    if (_cfg.endTime < _cfg.startTime) {
      revert CannotEndSaleBeforeItStarts();
    }

    bytes32 hashedKey = keccak256(abi.encodePacked(_collection,_cfg.token));

    displays[hashedKey] = Display({
      startTime: _cfg.startTime,
      endTime: _cfg.endTime,
      totalCap: _cfg.totalCap,
      callerCap: _cfg.callerCap,
      transactionCap: _cfg.transactionCap,
      price: _cfg.price,
      paymentDestination: _cfg.paymentDestination,
      token: _cfg.token
    });
  }

  /**
    Allow a caller to purchase an item.

    @param _amount The amount of items that the caller would like to purchase.
  */
  function mint(
    address _collection,
    address _token,
    uint256 _amount
  ) public virtual payable nonReentrant {

    // Reject purchases for no items.
    if (_amount < 1) { revert CannotBuyZeroItems(); }
    
    bytes32 hashedKey = keccak256(abi.encodePacked(_collection,_token));

    /// Reject purchases that happen before the start of the sale.
    if (block.timestamp < displays[hashedKey].startTime) { revert CannotBuyBeforeSaleStarts(); }

    /// Reject purchases that happen after the end of the sale.
    if (block.timestamp > displays[hashedKey].endTime) { revert CannotBuyFromEndedSale(); }

    // Reject purchases that exceed the per-transaction cap.
    if (_amount > displays[hashedKey].transactionCap) {
      revert CannotExceedPerTransactionCap();
    }

    // Reject purchases that exceed the per-caller cap.
    if (purchaseCounts[_collection][_msgSender()] + _amount > displays[hashedKey].callerCap) {
      revert CannotExceedPerCallerCap();
    }

    // Reject purchases that exceed the total sale cap.
    if (sold[_collection] + _amount > displays[hashedKey].totalCap) { revert CannotExceedTotalCap(); }

    address token = displays[hashedKey].token;
    uint256 totalCharge = displays[hashedKey].price * _amount;

    // The zero address indicates that the purchase assets is Ether.
    if (token == address(0)) {
	// Reject the purchase if the caller is underpaying.
	if (msg.value < totalCharge) { revert CannotUnderpayForMint(); }

	// Refund the caller's excess payment if they overpaid.
	if (msg.value > totalCharge) {
	   uint256 excess = msg.value - totalCharge;
	   (bool returned, ) = payable(_msgSender()).call{ value: excess }("");
	   if (!returned) { revert RefundTransferFailed(); }
	}
    } else  {
    // Otherwise, the caller is making their purchase with an ERC-20 token.
      IERC20(token).safeTransferFrom(
        _msgSender(),
        address(this),
        totalCharge
      );
    }

    // Update the count of items sold.
    sold[_collection] += _amount;

    // Update the caller's purchase count.
    purchaseCounts[_collection][_msgSender()] += _amount;

    // Mint the items.
    IERC721PsiKO(_collection).mint_Qgo(_msgSender(), _amount);
  }

  /**
    Allow any caller to send this contract's balance of Ether to the payment
    destination.
  */
  function claim(address _collection) external nonReentrant {
    bytes32 hashedKey = keccak256(abi.encodePacked(_collection, address(0)));
    (bool success, ) = payable(displays[hashedKey].paymentDestination).call{
      value: address(this).balance
    }("");
    if (!success) { revert SweepingTransferFailed(); }
  }

  /**
    Allow the owner to sweep either Ether or a particular ERC-20 token from the
    contract and send it to another address. This allows the owner of the shop
    to withdraw their funds after the sale is completed.

    @param _token The token to sweep the balance from; if a zero address is sent
      then the contract's balance of Ether will be swept.
    @param _amount The amount of token to sweep.
    @param _destination The address to send the swept tokens to.
  */
  function sweep(
    address _token,
    address _destination,
    uint256 _amount
  ) external onlyOwner nonReentrant {

    // A zero address means we should attempt to sweep Ether.
    if (_token == address(0)) {
      (bool success, ) = payable(_destination).call{ value: _amount }("");
      if (!success) { revert SweepingTransferFailed(); }

    // Otherwise, we should try to sweep an ERC-20 token.
    } else {
      IERC20(_token).safeTransfer(_destination, _amount);
    }
  }
}