// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import {IERC721, IERC165} from "../../openzeppelin/token/ERC721/IERC721.sol";
import {IERC1155} from "../../openzeppelin/token/ERC1155/IERC1155.sol";
import {ReentrancyGuard} from "../../openzeppelin/security/ReentrancyGuard.sol";
import {IERC20} from "../../openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "../../openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {ICreatorCore} from "../../manifold/creator-core/core/ICreatorCore.sol";
import {AdminControl} from "../../manifold/libraries-solidity/access/AdminControl.sol";
import {MerkleProof} from "../../openzeppelin/utils/cryptography/MerkleProof.sol";
import {Address} from "../../openzeppelin/utils/Address.sol";
import {ECDSA} from "../../openzeppelin/utils/cryptography/ECDSA.sol";
import "../../mojito/interfaces/IRoyaltyEngine.sol";

/**
 * @title onchainAuction, enabling collectors and curators to run their own auctions
 */

contract OnchainAuction is ReentrancyGuard, AdminControl {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    /// @notice The metadata for a given Order
    /// @param nftContractAddress the nft contract address
    /// @param tokenId the Nft token Id
    /// @param quantityOf1155 the quantity of 1155 for auction
    /// @param tokenOwnerAddress the address of the nft owner of the auction
    /// @param mimimumCryptoPrice the mimimum price of the NFT
    /// @param ReservedPrice the Reserve price of the NFT
    /// @param paymentCurrency the payment currency for seller requirement
    /// @param whitelistedBuyers the root hash of the list of whitelisted address
    /// @param blacklistedBuyers the root hash of the list of blackisted address
    /// @param paymentSettlement the settlement address and payment percentage provided in basis points
    struct createAuctionList {
        address nftContractAddress;
        uint256 tokenId;
        uint256 quantityOf1155;
        address tokenOwnerAddress;
        uint256 minimumBidCryptoPrice;
        uint256 ReservedPrice;
        address paymentCurrency; // cant support multiple currency here
        bytes32 whitelistedBuyers;
        bytes32 blacklistedBuyers;
        settlementList paymentSettlement;
    }

    /// @notice The metadata for a given Order
    /// @param paymentSettlementAddress the settlement address for the listed tokens
    /// @param taxSettlementAddress the taxsettlement address for settlement of tax fee
    /// @param platformSettlementAddress the platform address for settlement of platform fee
    /// @param platformFeePercentage the platform fee given in basis points
    /// @param commissionAddress the commission address for settlement of commission fee
    /// @param commissionFeePercentage the commission fee given in basis points
    struct settlementList {
        address paymentSettlementAddress;
        address taxSettlementAddress;
        address commissionAddress;
        address platformSettlementAddress;
        uint16 commissionFeePercentage; // in basis points
        uint16 platformFeePercentage; // in basis points
    }

    // Interface ID constants
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;
    bytes4 private constant ERC1155_INTERFACE_ID = 0xd9b67a26;

    // Time period to check if nearing to end
    uint64 durationForCheck;

    // Time Extension of end time
    uint64 durationToIncrease;

    // Platform Address
    address payable platformAddress;

    // Fee percentage to the Platform
    uint16 platformFeePercentage;

    // The address of the royaltySupport to use via this contract
    IRoyaltyEngine royaltySupport;

    /// @notice the bid history of tokenId
    /// @param startTime the time when the bid starts
    /// @param endTime the time when the bid ends
    /// @param bidder the address of the last three bidder
    /// @param amount the bid amount of the last three bidder
    struct bidHistory {
        uint64 startTime;
        uint64 endTime;
        address highestBidder;
        uint256 highestBid;
        uint256 tax;
    }
    
    // listing the auction details in the string named auction Id
    mapping(string => createAuctionList) public listings;

    // listing auctionId to tokenId to get the bidHistory for each tokens seperately.
    mapping(string => bidHistory) public bidderDetails;

    // validating saleId
    mapping(string => bool) public usedAuctionId;

    // @notice Emitted when an auction cration is completed
    // @param createdDetails the details of the created auction
    // @param startTime the time when the bid starts
    // @param endTime the time when the bid ends
    event AuctionCreated(
        string indexed auctionId,
        createAuctionList createdDetails,
        uint64 startTime,
        uint64 endTime);

    // @notice Emitted when an auction bid is completed
    // @param auctionId the id of the created auction
    // @param bidder the address of the bidder
    // @param bidAmount the amount of the bid
    // @param bidTime the Bidding TimeStamp
    event AuctionBid(
        string indexed auctionId,
        address bidder,
        uint256 bidAmount,
        uint64 BidTime
    );

    // @notice Emitted when an auction is ended
    // @param auctionId the id of the created auction
    // @param createdDetails the details of the auction
    // @param AuctionHistory the history of the auction
    event AuctionEnded(
        string indexed auctionId,
        createAuctionList createdDetails,
        bidHistory AuctionHistory
    );

    // @notice Emitted when an auction is closed
    // @param auctionId the id of the created auction
    event CancelAuction(string indexed auctionId);

    /// @notice Emitted when an Royalty Payout is executed
    /// @param tokenId The NFT tokenId
    /// @param tokenContract The NFT Contract address
    /// @param recipient Address of the Royalty Recipient
    /// @param amount Amount sent to the royalty recipient address
    event RoyaltyPayout(
        address tokenContract,
        uint256 tokenId,
        address recipient,
        uint256 amount
    );
    
    // @notice Emitted when an end Time of auction is Extended automatically
    // @param auctionId the id of the created auction
    // @param oldEndTime the old end time of the created auction
    // @param newEndTime the extended end time of the created auction
    event EndTimeExtended(
        string indexed auctionId,
        uint64 oldEndTime,
        uint64 newEndTime
    );
       
    // @notice Emitted when minimumPrice is Updated
    // @param auctionId the id of the created auction
    // @param oldMinimumBidPrice the old MinimumBidPrice of the created auction
    // @param newMinimumBidPrice the new MinimumBidPrice of the created auction
    event MinimumPriceUpdated(
        string indexed auctionId,
        uint256 oldMinimumBidPrice,
        uint256 newMinimumBidPrice
    );

    // @notice Emitted when startTime is Updated
    // @param auctionId the id of the created auction
    // @param oldStartTime the old start time of the created auction
    // @param newStartTime the new start time of the created auction
    event StartTimeUpdated(
        string indexed auctionId,
        uint256 oldStartTime,
        uint256 newStartTime
    );
    
    // @notice Emitted when an end Time of auction is updated
    // @param auctionId the id of the created auction
    // @param oldEndTime the old end time of the created auction
    // @param newEndTime the new end time of the created auction
    event EndTimeUpdated(
        string indexed auctionId,
        uint256 oldEndTime,
        uint256 newEndTime
    );

    // @notice Emitted when paymentSettlementAddress is Updated
    // @param auctionId the id of the created auction
    // @param oldPaymentSettlementAddress the old PaymentSettlementAddress of the created auction
    // @param newPaymentSettlementAddress the new PaymentSettlementAddress of the created auction
    event PaymentSettlementAddressUpdated(
        string indexed auctionId,
        address oldPaymentSettlementAddress,
        address newPaymentSettlementAddress
    );
    
    // @notice Emitted when taxSettlementAddress is Updated
    // @param auctionId the id of the created auction
    // @param oldTaxSettlementAddress the old TaxSettlementAddress of the created auction
    // @param newTaxSettlementAddress the new TaxSettlementAddress of the created auction
    event TaxSettlementAddressUpdated(
        string indexed auctionId,
        address oldTaxSettlementAddress,
        address newTaxSettlementAddress
    );
    
    // @notice Emitted when platformAddress is Updated at contract Level
    // @param oldPlatformAddress the old PlatformAddress of the created auction
    // @param newPlatformAddress the new PlatformAddress of the created auction
    event PlatformAddressUpdated(
        address oldPlatformAddress,
        address newPlatformAddress
    );
    
    // @notice Emitted when platformFeePercentage is Updated at contract Level
    // @param oldPlatformFeePercentage the old platformFeePercentage of the created auction
    // @param newPlatformFeePercentage the new platformFeePercentage of the created auction
    event PlatformFeePercentageUpdated(
        uint16 oldPlatformFeePercentage,
        uint16 newPlatformFeePercentage
    );

    // @notice Emitted when an AutoTimeExtensionValues are Updated
    // @param oldDurationForCheck the old Time period to check if nearing to end
    // @param oldDurationToIncrease the old Time Extension of end time
    // @param newDurationForCheck the new Time period to check if nearing to end
    // @param newDurationToIncrease the new Time Extension of end time
    event AutoTimeExtensionUpdated(
        uint256 oldDurationForCheck,
        uint256 newDurationForCheck,
        uint256 oldDurationToIncrease,
        uint256 newDurationToIncrease
    );
    
    // @notice Emitted when withdrawn is called by admin
    // @param to the To address
    // @param amount the amount transferred from contract
    // @param paymentCurrency the type of transfer (ETH OR ERC20)
    event Withdrew(address indexed to,uint256 amount,address paymentCurrency);

    /// @param _platformAddress The Platform Address
    /// @param _platformFeePercentage The Platform fee percentage
    /// @param _royaltySupport The address of RoyaltyEngine
    /// @param _durationForCheck the Time period to check if nearing to end
    /// @param _durationToIncrease the Time Extension of end time
    constructor(
        address _platformAddress,
        uint16 _platformFeePercentage,
        IRoyaltyEngine _royaltySupport,
        uint64 _durationForCheck,
        uint64 _durationToIncrease) {
        require(_platformAddress != address(0), "Invalid Platform Address");
        require(
            _platformFeePercentage < 10000,
            "platformFee should not be more than 100 %"
        );

        durationForCheck = _durationForCheck;
        durationToIncrease = _durationToIncrease;

        platformAddress = payable(_platformAddress);
        platformFeePercentage = _platformFeePercentage;
        royaltySupport = _royaltySupport;
    }
        
    /*
     * @notice creating a auction .
     * @param auctionId the id of the listed auction
     * @param list gives the listing details to create a auction
     * @param startTime the starting time stamp of auction
     * @param endTime the ending time stamp of auction
     */
    function createAuction(
        string calldata auctionId,
        createAuctionList calldata list,
        uint32 startTime,
        uint32 endTime
    ) external nonReentrant {
        // checks for should not use the same auctionId
        require(!usedAuctionId[auctionId], "auctionId is already used");

        require(
            isAdmin(msg.sender) || list.tokenOwnerAddress == msg.sender,
            "only the admin of this contract or Token owner can call this function"
        );

        uint16 totalFeeBasisPoints = 0;
        // checks for platform and commission fee to be less than 100 %
        if (list.paymentSettlement.platformFeePercentage != 0) {
            totalFeeBasisPoints += (list
                .paymentSettlement
                .platformFeePercentage +
                list.paymentSettlement.commissionFeePercentage);
        } else {
            totalFeeBasisPoints += (platformFeePercentage +
                list.paymentSettlement.commissionFeePercentage);
        }
        require(
            totalFeeBasisPoints < 10000,
            "the total fee basis point should be less than 10000"
        );
        // checks for amount to buy the token should not be provided as zero
        require(
            list.minimumBidCryptoPrice > 0,
            "minimum price should be greater than zero"
        );

        // checks to provide only supported interface for nftContractAddress
        require(
            IERC165(list.nftContractAddress).supportsInterface(
                ERC721_INTERFACE_ID
            ) ||
                IERC165(list.nftContractAddress).supportsInterface(
                    ERC1155_INTERFACE_ID
                ),
            "should provide only supported Nft Address"
        );
        
        if (
            IERC165(list.nftContractAddress).supportsInterface(
                ERC721_INTERFACE_ID
            )
        ) { 
            // checks for owner of Token
            require(
                IERC721(list.nftContractAddress).ownerOf(list.tokenId) ==
                    list.tokenOwnerAddress,
                "invalid tokenOwnerAddress"
            );
            //  checks for approval to Auction Contract
            require(
                IERC721(list.nftContractAddress).isApprovedForAll(
                    list.tokenOwnerAddress,address(this)),
                " approval for all is not given"
            );
        } else if (
            IERC165(list.nftContractAddress).supportsInterface(
                ERC1155_INTERFACE_ID
            )
        ) {
            uint256 tokenQty = IERC1155(list.nftContractAddress).balanceOf(
                list.tokenOwnerAddress,
                list.tokenId
            );
            //  checks for enough quantity to create auction
            require(
                list.quantityOf1155 <= tokenQty && list.quantityOf1155 > 0,
                "insufficient token balance"
            );
            //  checks for approval to Auction Contract
            require(
                IERC1155(list.nftContractAddress).isApprovedForAll(
                    list.tokenOwnerAddress,address(this)),
                    " approval for all is not given"
            );
        }

        // checks for paymentSettlementAddress should not be zero
        require(
            list.paymentSettlement.paymentSettlementAddress != address(0),
            "should provide Settlement address"
        );

        // checks to support only erc-20 and native currency
        require(
            Address.isContract(list.paymentCurrency) ||
                list.paymentCurrency == address(0),
            "auction support only native and erc20 currency"
        );

        // checks for taxSettlementAddress should not be zero
        require(
            list.paymentSettlement.taxSettlementAddress != address(0),
            "should provide tax Settlement address"
        );

        // checks for timestamp for starttime and endtime to be greater than zero
        require(
            startTime > 0 && endTime > startTime,
            "auction time should not be provided as zero or invalid"
        );
        listings[auctionId] = list;

        bidderDetails[auctionId].startTime = startTime;

        bidderDetails[auctionId].endTime = endTime;

        usedAuctionId[auctionId] = true;

        emit AuctionCreated(
            auctionId,
            list,
            bidderDetails[auctionId].startTime,
            bidderDetails[auctionId].endTime
            );
    }

    /**
     * @notice bid, making a bid of a token in created auction
     * @param auctionId the id of the created auction
     * @param bidAmount the amount of to the bid
     * @param tax the tax amount 
     * @param whitelistedProof proof of the whiltelisted leaf
     * @param blacklistedProof proof of the blacklisted leaf
     */
    function bid(
        string calldata auctionId,
        uint256 bidAmount,
        uint256 tax,
        bytes32[] memory whitelistedProof,
        bytes32[] memory blacklistedProof
    ) external payable nonReentrant {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");

        createAuctionList memory listingDetails = listings[auctionId];
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        // Whitelisted address validation using Merkle Proof of caller Address
        if (listingDetails.whitelistedBuyers != bytes32(0)) {
            require(
                MerkleProof.verify(
                    whitelistedProof,
                    listingDetails.whitelistedBuyers,
                    leaf
                ),
                "bidder should be a whitelisted Buyer"
            );
        }
        // Blacklisted address validation using Merkle Proof of caller Address
        if (listingDetails.blacklistedBuyers != bytes32(0)) {
            require(
                !MerkleProof.verify(
                    blacklistedProof,
                    listingDetails.blacklistedBuyers,
                    leaf
                ),
                "you are been blacklisted from bidding"
            );
        }
        require(
            bidderDetails[auctionId].startTime <= uint64(block.timestamp),
            "the auction has not started"
        );
        require(
            bidderDetails[auctionId].endTime > uint64(block.timestamp),
            "the auction has already ended"
        );
        if (
            bidAmount >= listingDetails.minimumBidCryptoPrice &&
            bidAmount > bidderDetails[auctionId].highestBid
        ) {
            if (listingDetails.paymentCurrency != address(0)) {
                // check for enough token allowance to create offer
                require(
                    IERC20(listingDetails.paymentCurrency).allowance(msg.sender, address(this)) >=
                    (bidAmount + tax),
                    "insufficent token allowance"
                );
                // checks the buyer has sufficient amount to buy the nft
                require(
                    IERC20(listingDetails.paymentCurrency).balanceOf(
                        msg.sender
                    ) >= (bidAmount + tax),
                    "insufficient Erc20 amount"
                );
            } else if (listingDetails.paymentCurrency == address(0)) {
                require(
                    msg.value >= (bidAmount + tax),
                    "insufficent Eth amount"
                );
            }
        } else {
            revert("provide bid amount higher than previous bid");
        }

        address _highestBidder = bidderDetails[auctionId].highestBidder;
        uint256 _highestBid = bidderDetails[auctionId].highestBid;
        uint256 _tax=bidderDetails[auctionId].tax;
        bidderDetails[auctionId].highestBidder = msg.sender;
        bidderDetails[auctionId].highestBid = bidAmount;
        bidderDetails[auctionId].tax = tax;

        if (bidderDetails[auctionId].endTime - durationForCheck < uint64(block.timestamp)) {
            emit EndTimeExtended(
                auctionId,
                bidderDetails[auctionId].endTime,
                bidderDetails[auctionId].endTime+durationToIncrease
                );
            bidderDetails[auctionId].endTime += durationToIncrease;
        }

        if (_highestBid != 0) {
            _handlePayment(
                payable(_highestBidder),
                listingDetails.paymentCurrency,
                (_highestBid +_tax)
            );
        }

        if (listingDetails.paymentCurrency != address(0)) {
            IERC20(listingDetails.paymentCurrency).safeTransferFrom(msg.sender,address(this),(bidAmount + tax));
        }
               
        emit AuctionBid(auctionId, msg.sender, bidAmount,uint64(block.timestamp));
    }
     
    /**
     * @notice endAuction, Ending the created auction by admin or highest Bidder
     * @param auctionId the id of the created auction
     */
    function endAuction(string memory auctionId) external nonReentrant {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");
        
        // Checks for auctionId is closed or not.
        require(
            listings[auctionId].nftContractAddress!=address(0),
            "auction ended already"
        );

        bidHistory memory bidderdetails = bidderDetails[auctionId];
        createAuctionList memory listingDetails = listings[auctionId];
        settlementList memory paymentSettlement = listings[auctionId]
            .paymentSettlement;
        // should be called by the contract admins or by the buyer
        require(
            isAdmin(msg.sender) || bidderdetails.highestBidder == msg.sender,
            "only the admin of this contract or highestBidder can call this function"
        );

        // checks the auction time is ended or not
        require(
            uint64(block.timestamp) >= bidderdetails.endTime,
            "auction has not yet ended"
        );

        uint256 bidAmount = bidderdetails.highestBid;
        address buyer = bidderdetails.highestBidder;
        address paymentToken = listingDetails.paymentCurrency;
        address tokenContract = listingDetails.nftContractAddress;
        uint256 tokenId = listingDetails.tokenId;

        delete (listings[auctionId]);
        delete (bidderDetails[auctionId]);

        if (listingDetails.ReservedPrice > bidAmount) {
            // bid doesen't meet the reserved price so we are returning the amount+tax to highest bidder
            _handlePayment(
                payable(buyer),
                paymentToken,
                (bidAmount + bidderdetails.tax)
            );
            } else if (listingDetails.ReservedPrice <= bidAmount) {
            // Transferring  the NFT tokens to the highest Bidder
            _tokenTransaction(
                listingDetails.tokenOwnerAddress,
                tokenContract,
                buyer,
                tokenId,
                listingDetails.quantityOf1155
            );

            // transferring the excess amount given by by buyer as tax to taxSettlementAddress
            if (bidderdetails.tax != 0) {
                _handlePayment(
                    payable(paymentSettlement.taxSettlementAddress),
                    paymentToken,
                    bidderdetails.tax
                );
            }

            uint256 remainingProfit = bidAmount;

            // PlatformFee Settlement
            uint256 paymentAmount = 0;
            // transferring the platformFee amount  to the platformSettlementAddress
            if (
                paymentSettlement.platformSettlementAddress != address(0) &&
                paymentSettlement.platformFeePercentage > 0
            ) {
                _handlePayment(
                    payable(paymentSettlement.platformSettlementAddress),
                    paymentToken,
                    paymentAmount += ((remainingProfit *
                        paymentSettlement.platformFeePercentage) / 10000)
                );
            } else if (
                platformAddress != address(0) && platformFeePercentage > 0
            ) {
                _handlePayment(
                    platformAddress,
                    paymentToken,
                    paymentAmount += ((remainingProfit *
                        platformFeePercentage) / 10000)
                );
            }
           
            // transferring the commissionfee amount to the commissionAddress
            if (
                paymentSettlement.commissionAddress != address(0) &&
                paymentSettlement.commissionFeePercentage > 0
            ) {
                paymentAmount += ((remainingProfit *
                    paymentSettlement.commissionFeePercentage) / 10000);
                _handlePayment(
                    payable(paymentSettlement.commissionAddress),
                    paymentToken,
                    ((remainingProfit *
                        paymentSettlement.commissionFeePercentage) / 10000)
                );
            }
            remainingProfit = remainingProfit - paymentAmount;
            // Royalty Fee Payout Settlement
            if(royaltySupport!=IRoyaltyEngine(address(0)))
            {
            remainingProfit = _handleRoyaltyEnginePayout(
                tokenContract,
                tokenId,
                remainingProfit,
                paymentToken
            );
            }
            // Transfer the balance to the tokenOwner
            _handlePayment(
                payable(paymentSettlement.paymentSettlementAddress),
                paymentToken,
                remainingProfit
            );

            emit AuctionEnded(
                auctionId,
                listingDetails,
                bidderdetails
            );
        }
        
    }
    
    /// @notice The details to be provided to buy the token
    /// @param _tokenOwner the owner of the nft token
    /// @param _tokenContract the address of the nft contract
    /// @param _buyer the address of the buyer
    /// @param _tokenId the token Id of the owner owns
    /// @param _quantity the quantity of tokens for 1155 only
    function _tokenTransaction(
        address _tokenOwner,
        address _tokenContract,
        address _buyer,
        uint256 _tokenId,
        uint256 _quantity
    ) private {
        if (IERC165(_tokenContract).supportsInterface(ERC721_INTERFACE_ID)) {
            require(
                IERC721(_tokenContract).ownerOf(_tokenId) == _tokenOwner,
                "maker is not the owner"
            );
            // Transferring the ERC721
            IERC721(_tokenContract).safeTransferFrom(
                _tokenOwner,
                _buyer,
                _tokenId
            );
        } else if (
            IERC165(_tokenContract).supportsInterface(ERC1155_INTERFACE_ID)
        ) {
            uint256 ownerBalance = IERC1155(_tokenContract).balanceOf(
                _tokenOwner,
                _tokenId
            );
            require(
                _quantity <= ownerBalance && _quantity > 0,
                "insufficeint token balance"
            );

            // Transferring the ERC1155
            IERC1155(_tokenContract).safeTransferFrom(
                _tokenOwner,
                _buyer,
                _tokenId,
                _quantity,
                "0x"
            );
        }
    }

    /// @notice Settle the Payment based on the given parameters
    /// @param _to Address to whom need to settle the payment
    /// @param _paymentToken Address of the ERC20 Payment Token
    /// @param _amount Amount to be transferred
    function _handlePayment(
        address payable _to,
        address _paymentToken,
        uint256 _amount
    ) private {
        bool success;
        if (_paymentToken == address(0)) {
            // transferreng the native currency
            (success, ) = _to.call{value: _amount}(new bytes(0));
            require(success, "transaction failed");
        } else {
            // transferring ERC20 currency
            IERC20(_paymentToken).safeTransfer(_to, _amount);
        }
    }

    /// @notice Settle the Royalty Payment based on the given parameters
    /// @param _tokenContract The NFT Contract address
    /// @param _tokenId The NFT tokenId
    /// @param _amount Amount to be transferred
    /// @param _payoutCurrency Address of the ERC20 Payout
    function _handleRoyaltyEnginePayout(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount,
        address _payoutCurrency
    ) private returns (uint256) {
        // Store the initial amount
        uint256 amountRemaining = _amount;
        uint256 feeAmount;

        // Verifying whether the token contract supports Royalties of supported interfaces
        (
            address payable[] memory recipients,
            uint256[] memory bps // Royalty amount denominated in basis points
        ) = royaltySupport.getRoyalty(_tokenContract, _tokenId);

        // Store the number of recipients
        uint256 totalRecipients = recipients.length;

        // If there are no royalties, return the initial amount
        if (totalRecipients == 0) return _amount;

        // Payout each royalty
        for (uint256 i = 0; i < totalRecipients; ) {
            // Cache the recipient and amount
            address payable recipient = recipients[i];

            feeAmount = (bps[i] * _amount) / 10000;

            // Ensure that we aren't somehow paying out more than we have
            require(amountRemaining >= feeAmount, "insolvent");

            _handlePayment(recipient, _payoutCurrency, feeAmount);
            emit RoyaltyPayout(_tokenContract, _tokenId, recipient, feeAmount);

            // Cannot underflow as remaining amount is ensured to be greater than or equal to royalty amount
            unchecked {
                amountRemaining -= feeAmount;
                ++i;
            }
        }
        return amountRemaining;
    }

    /// @notice cancel the sale of a listed token
    /// @param auctionId to cansel the sale
    function cancelAuction(string memory auctionId) external adminRequired {
        
        require(usedAuctionId[auctionId], "unsupported sale");
        require(
                bidderDetails[auctionId].highestBid == 0,
            "the auction bid has already started"
        );
        delete(listings[auctionId]);
        delete (bidderDetails[auctionId]);
        emit CancelAuction(auctionId);
    }
   
      
    /// @notice Update the MinimumPrice
    /// @param auctionId The Auction Id
    /// @param minimumBidPrice The minimumBidPrice
    function updateMinimumPrice(
        string calldata auctionId,
        uint256 minimumBidPrice
    ) external adminRequired {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");

        require(
                bidderDetails[auctionId].highestBid == 0,
            "the auction bid has already started"
        );
        emit MinimumPriceUpdated(
            auctionId,
            listings[auctionId].minimumBidCryptoPrice,
            minimumBidPrice
            );
        listings[auctionId].minimumBidCryptoPrice = minimumBidPrice;
    }
    
    /// @notice Update the StartTime
    /// @param auctionId The Auction Id
    /// @param startTime The startTime
    function updateStartTime(string calldata auctionId, uint64 startTime)
        external
        adminRequired
    {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");

        require(
                bidderDetails[auctionId].highestBid == 0,
            "the auction bid has already started"
        );
        emit StartTimeUpdated(auctionId,bidderDetails[auctionId].startTime,startTime);
        bidderDetails[auctionId].startTime = startTime;
    }
    
    /// @notice Update the EndTime
    /// @param auctionId The Auction Id
    /// @param endTime The endTime
    function updateEndTime(string calldata auctionId, uint64 endTime)
        external
        adminRequired
    {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");

        require(
            listings[auctionId].nftContractAddress!=address(0),
            "auction ended already"
        );
        require(
            bidderDetails[auctionId].endTime <= uint64(block.timestamp) || 
               bidderDetails[auctionId].highestBid == 0,
            "auction has not started or not yet ended"
        );
        require(bidderDetails[auctionId].endTime < endTime, "new EndTime must be greater than old EndTIme");
        emit EndTimeUpdated(auctionId,bidderDetails[auctionId].endTime,endTime);
        bidderDetails[auctionId].endTime = endTime;
    }
        
    /// @notice Update the Payment Settlement Address
    /// @param auctionId The Auction Id
    /// @param paymentSettlementAddress The Payment Settlement Address 
    function updatePaymentSettlementAddress(
        string calldata auctionId,
        address paymentSettlementAddress
    ) external adminRequired {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");

        require(
            bidderDetails[auctionId].startTime >= uint64(block.timestamp) ||
                bidderDetails[auctionId].highestBid == 0,
            "the auction bid has already started"
        );

        require(paymentSettlementAddress != address(0));
        emit PaymentSettlementAddressUpdated(
            auctionId,
            listings[auctionId].paymentSettlement.paymentSettlementAddress,
            paymentSettlementAddress
            );
        listings[auctionId]
            .paymentSettlement
            .paymentSettlementAddress = paymentSettlementAddress;
    }
    
    /// @notice Update the Tax Settlement Address
    /// @param auctionId The Auction Id
    /// @param taxSettlementAddress The TAX Settlement Address
    function updateTaxSettlementAddress(
        string calldata auctionId,
        address taxSettlementAddress
    ) external adminRequired {
        // checks for auctionId is created for auction
        require(usedAuctionId[auctionId], "unsupported sale");

        require(
            bidderDetails[auctionId].startTime >= uint64(block.timestamp) ||
                bidderDetails[auctionId].highestBid == 0,
            "the auction bid has already started"
        );

        require(taxSettlementAddress != address(0));
        emit TaxSettlementAddressUpdated(
            auctionId,
            listings[auctionId].paymentSettlement.taxSettlementAddress,
            taxSettlementAddress
            );
        listings[auctionId]
            .paymentSettlement
            .taxSettlementAddress = taxSettlementAddress;
    }
    
    /// @notice Update the values of AutoTimeExtension
    /// @param _durationForCheck Time period to check the nearest to end.
    /// @param _durationToIncrease  Time Extension of end time. 
    function updateValuesOfAutoTimeExtension(uint64 _durationForCheck, uint64 _durationToIncrease)
    external adminRequired {
       emit AutoTimeExtensionUpdated(durationForCheck,_durationForCheck,durationToIncrease,_durationToIncrease);
       durationForCheck = _durationForCheck;
       durationToIncrease = _durationToIncrease;
    }

    /// @notice Update the platform Address
    /// @param _platformAddress The Platform Address
    function updatePlatformAddress(address _platformAddress)
        external
        adminRequired
    {
        require(_platformAddress != address(0), "invalid Platform Address");
        emit PlatformAddressUpdated(platformAddress,_platformAddress);
        platformAddress = payable(_platformAddress);
    }

    /// @notice Update the Platform Fee Percentage
    /// @param _platformFeePercentage The Platform fee percentage
    function updatePlatformFeePercentage(uint16 _platformFeePercentage)
        external
        adminRequired
    {
        require(
            _platformFeePercentage < 10000,
            "platformFee should not be more than 100 %"
        );
        emit PlatformFeePercentageUpdated(platformFeePercentage,_platformFeePercentage);
        platformFeePercentage = _platformFeePercentage;
       
    }
    
    /// @notice Withdraw the funds to owner
    /// @param paymentCurrency the address of token or address(0) if native
    function withdraw(address paymentCurrency) external adminRequired {
        bool success;
        address payable to = payable(msg.sender);
        require(to!=address(0), "to address should not be zero Address");
        if(paymentCurrency == address(0)){
             emit Withdrew(to,(payable(address(this))).balance,paymentCurrency);
            (success, ) = to.call{value: address(this).balance}(new bytes(0));
            require(success, "withdraw to withdraw funds. please try again");
        } else if (paymentCurrency != address(0)){
            // transferring ERC20 currency
            uint256 amount = IERC20(paymentCurrency).balanceOf(address(this));
            emit Withdrew(to,amount,paymentCurrency);
            IERC20(paymentCurrency).safeTransfer(to, amount);  
              
        }    
    }

    /*
     * @notice Getting contract information.
     * @returns contractInfo as platformAddress,platformFeePercentage,royaltySupport,
     * durationForCheckand durationToIncrease
     */ 
    function getContractInfo() public view returns(address, uint16,IRoyaltyEngine,uint64,uint64){
        return (platformAddress,platformFeePercentage,royaltySupport,durationForCheck,durationToIncrease);
    }

    receive() external payable {}
    fallback() external payable {}
}