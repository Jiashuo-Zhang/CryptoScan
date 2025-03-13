// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IERC721, IERC165} from "../../openzeppelin/token/ERC721/IERC721.sol";
import {IERC1155} from "../../openzeppelin/token/ERC1155/IERC1155.sol";
import {ReentrancyGuard} from "../../openzeppelin/security/ReentrancyGuard.sol";
import {IERC20} from "../../openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "../../openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "../../openzeppelin/utils/cryptography/ECDSA.sol";
import {ICreatorCore} from "../../manifold/creator-core/core/ICreatorCore.sol";
import {IPriceFeed} from "../interfaces/IPriceFeed.sol";
import {SafeCast} from "../../openzeppelin/utils/math/SafeCast.sol";
import "../interfaces/IRoyaltyEngine.sol";

/**
 * @title IWrapperNativeToken
 * @dev Interface for Wrapped native tokens such as WETH, WMATIC, WBNB, etc
 */
interface IWrappedNativeToken {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address to, uint256 value) external returns (bool);
}

contract Marketplace is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    address public immutable owner;

    /// @notice The metadata for a given Order
    /// @param uuid The generated Unique uuid
    /// @param tokenId The NFT tokenId
    /// @param tokenContract The NFT Contract address
    /// @param quantity The total quantity of the ERC1155 token if ERC721 it is 1
    /// @param tokenOwner The address of the Token Owner
    /// @param fixedPrice Price fixed by the TokenOwner
    /// @param paymentToken ERC20 address chosen by TokenOwner for Payments
    /// @param tax Price fixed by the Exchange.
    /// @param whitelistedBuyer Address of the Whitelisted Buyer
    /// @param quotePrice If Buyer quoted price in fiat currency
    /// @param slippage Price Limit based on the percentage
    /// @param buyer Address of the buyer
    struct Order {
        string uuid;
        uint256 tokenId;
        address tokenContract;
        uint256 quantity;
        address payable tokenOwner;
        uint256 fixedPrice;
        address paymentToken;
        uint256 tax;
        address whitelistedBuyer;
        uint256 quotePrice;
        uint256 slippage;
        address buyer;
    }

    /// @notice The Bid History for a Token
    /// @param bidder Address of the Bidder
    /// @param quotePrice Price quote by them
    /// @param paymentAddress Payment ERC20 Address by the Bidder
    struct BidHistory {
        address bidder;
        uint256 quotePrice;
        address paymentAddress;
    }
    // Interface ID constants
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;
    bytes4 private constant ERC1155_INTERFACE_ID = 0xd9b67a26;
    bytes4 private constant ROYALTIES_CREATORCORE_INTERFACE_ID = 0xbb3bafd6;
    bytes4 private constant _INTERFACE_ID_ROYALTIES_EIP2981 = 0x2a55205a;
    bytes4 private constant _INTERFACE_ID_ROYALTIES_RARIBLE = 0xb7799584;
    bytes4 private constant _INTERFACE_ID_ROYALTIES_FOUNDATION = 0xd5a06d4c;

    // 1 Ether in Wei, 10^18
    int64 private constant ONE_ETH_WEI = 1e18;

    // ERC20 address of the Native token (can be WETH, WBNB, WMATIC, etc)
    address public wrappedNativeToken;

    // Platform Address
    address payable public platformAddress;

    // Fee percentage to the Platform
    uint256 public platformFeePercentage;

    // The address of the Price Feed Aggregator to use via this contract
    address public priceFeedAddress;

    // Address of the Admin
    address public adminAddress;

    // Address of the Royalty Registry
    address public royaltyRegistryAddress;

    // Status of the Royalty Contract Active or not
    bool public royaltyActive;

    // UUID validation on orders
    mapping(string => bool) private usedUUID;

    /// @notice Emitted when an Buy Event is completed
    /// @param uuid The generated Unique uuid
    /// @param tokenId The NFT tokenId
    /// @param tokenContract The NFT Contract address
    /// @param quantity The total quantity of the ERC1155 token if ERC721 it is 1
    /// @param tokenOwner The address of the Token Owner
    /// @param buyer Address of the buyer
    /// @param amount Fixed Price
    /// @param paymentToken ERC20 address chosen by TokenOwner for Payments
    /// @param marketplaceAddress Address of the Platform
    /// @param platformFee Fee sent to the Platform Address
    event BuyExecuted(
        string uuid,
        uint256 indexed tokenId,
        address indexed tokenContract,
        uint256 quantity,
        address indexed tokenOwner,
        address buyer,
        uint256 amount,
        uint256 tax,
        address paymentToken,
        address marketplaceAddress,
        uint256 platformFee
    );

    /// @notice Emitted when an Sell(Accept Offer) Event is completed
    /// @param uuid The generated Unique uuid
    /// @param tokenId The NFT tokenId
    /// @param tokenContract The NFT Contract address
    /// @param quantity The total quantity of the ERC1155 token if ERC721 it is 1
    /// @param tokenOwner The address of the Token Owner
    /// @param buyer Address of the buyer
    /// @param amount Fixed Price
    /// @param paymentToken ERC20 address chosen by TokenOwner for Payments
    /// @param marketplaceAddress Address of the Platform
    /// @param platformFee Fee sent to the Platform Address
    event SaleExecuted(
        string uuid,
        uint256 indexed tokenId,
        address indexed tokenContract,
        uint256 quantity,
        address indexed tokenOwner,
        address buyer,
        uint256 amount,
        uint256 tax,
        address paymentToken,
        address marketplaceAddress,
        uint256 platformFee
    );

    /// @notice Emitted when an End Auction Event is completed
    /// @param uuid The generated Unique uuid
    /// @param tokenId The NFT tokenId
    /// @param tokenContract The NFT Contract address
    /// @param quantity The total quantity of the ERC1155 token if ERC721 it is 1
    /// @param tokenOwner The address of the Token Owner
    /// @param highestBidder Address of the highest bidder
    /// @param amount Fixed Price
    /// @param paymentToken ERC20 address chosen by TokenOwner for Payments
    /// @param marketplaceAddress Address of the Platform
    /// @param platformFee Fee sent to the Platform Address
    /// @param bidderlist Bid History List
    event AuctionClosed(
        string uuid,
        uint256 indexed tokenId,
        address indexed tokenContract,
        uint256 quantity,
        address indexed tokenOwner,
        address highestBidder,
        uint256 amount,
        uint256 tax,
        address paymentToken,
        address marketplaceAddress,
        uint256 platformFee,
        BidHistory[] bidderlist
    );

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

    /// @notice Emitted when an Constructor is executed
    /// @param wrappedNativeToken Native ERC20 Address
    /// @param platformAddress The Platform Address
    /// @param platformFeePercentage The Platform fee percentage
    /// @param priceFeedAddress PriceFeed Contract Address
    /// @param owner Owner of the Contract
    /// @param adminAddress Admin Address
    /// @param royaltyRegistryAddress Royalty Registry Address
    /// @param royaltyActive Royalty Address is active or not
    event ConstructorExecuted(
        address wrappedNativeToken,
        address platformAddress,
        uint256 platformFeePercentage,
        address priceFeedAddress,
        address owner,
        address adminAddress,
        address royaltyRegistryAddress,
        bool royaltyActive
    );

    /// @notice Emitted when an Withdraw Payout is executed
    /// @param toAddress To Address amount is transferred
    /// @param amount The amount transferred
    event WithdrawPayout(address toAddress, uint256 amount);

    /// @notice Emitted when an Address updation is executed
    /// @param UpdateAddress To Address amount is transferred
    event UpdatedAddress(address UpdateAddress);

    /// @notice Emitted when an percentage fee is updated
    /// @param amount The amount transferred
    event UpdateFeePercentage(uint256 amount);

    /// @notice Emitted when an active status is updated
    /// @param isActive Active status
    event UpdateStatus(bool isActive);

    /// @notice Modifier to check only the owner or admin calls the function
    modifier onlyOwner() {
        require(
            msg.sender == owner || msg.sender == adminAddress,
            "sender is neither owner nor adminAddress"
        );
        _;
    }

    /// @param _wrappedNativeToken Native ERC20 Address
    /// @param _platformAddress The Platform Address
    /// @param _platformFeePercentage The Platform fee percentage
    /// @param _priceFeedAddress PriceFeed Contract Address
    /// @param _adminAddress Admin Address
    /// @param _royaltyRegistryAddress Royalty Registry Address
    /// @param _royaltyActive Royalty Address is active or not
    constructor(
        address _wrappedNativeToken,
        address _platformAddress,
        uint256 _platformFeePercentage,
        address _priceFeedAddress,
        address _adminAddress,
        address _royaltyRegistryAddress,
        bool _royaltyActive
    ) {
        require(_platformAddress != address(0), "Invalid Platform Address");
        require(_priceFeedAddress != address(0), "Invalid PriceFeed Address");
        require(
            _wrappedNativeToken != address(0),
            "Invalid WrappedNativeToken Address"
        );
        require(
            _platformFeePercentage <= 10_000,
            "platformFee should not be more than 100 %"
        );
        require(_adminAddress != address(0), "Invalid Admin Address");
        require(
            _royaltyRegistryAddress != address(0),
            "Invalid Royalty Registry Address"
        );
        wrappedNativeToken = _wrappedNativeToken;
        platformAddress = payable(_platformAddress);
        platformFeePercentage = _platformFeePercentage;
        priceFeedAddress = _priceFeedAddress;
        owner = msg.sender;
        adminAddress = _adminAddress;
        royaltyRegistryAddress = _royaltyRegistryAddress;
        royaltyActive = _royaltyActive;
        emit ConstructorExecuted(
            wrappedNativeToken,
            platformAddress,
            platformFeePercentage,
            priceFeedAddress,
            owner,
            adminAddress,
            royaltyRegistryAddress,
            royaltyActive
        );
    }

    /// @notice Buy the listed token with the sellersignature
    /// @param order Order struct consists of the listedtoken details
    /// @param sellerSignature Signature generated when signing the hash(order details) by the seller
    /// @param payableToken ERC20 address chosen by Buyer for Payments
    function buy(
        Order memory order,
        bytes memory sellerSignature,
        address payableToken
    ) external payable nonReentrant {
        // Validating the InterfaceID
        require(
            (IERC165(order.tokenContract).supportsInterface(
                ERC721_INTERFACE_ID
            ) ||
                IERC165(order.tokenContract).supportsInterface(
                    ERC1155_INTERFACE_ID
                )),
            "tokenContract does not support ERC721 or ERC1155 interface"
        );
        // Validating the caller to be the buyer
        require(order.buyer == msg.sender, "msg.sender should be the buyer");

        // Validating address if whitelisted address is present
        require(
            order.whitelistedBuyer == address(0) ||
                order.whitelistedBuyer == msg.sender,
            "can only be called by whitelisted buyer"
        );

        // Validating the paymentToken chosen by Seller
        require(
            order.paymentToken == wrappedNativeToken ||
                order.paymentToken == address(0),
            "should provide only supported currencies"
        );

        // Validating the payableToken chosen by Buyer
        require(
            payableToken == wrappedNativeToken || payableToken == address(0),
            "payableToken must be supported"
        );

        // Checking sufficient balance of ether
        if (payableToken == address(0)) {
            require(
                msg.value >= (order.fixedPrice + order.tax),
                "insufficient amount"
            );
        } else if (payableToken == wrappedNativeToken) {
            require(
                IERC20(payableToken).balanceOf(order.buyer) >=
                    (order.fixedPrice + order.tax),
                "insufficient balance"
            );
            require(
                IERC20(payableToken).allowance(order.buyer, address(this)) >=
                    (order.fixedPrice + order.tax),
                "insufficient token allowance"
            );
        }
        // Validating signatures
        require(
            _verifySignature(order, sellerSignature, order.tokenOwner),
            "Invalid seller signature"
        );

        // Validating UUID
        require(!usedUUID[order.uuid], "UUID already used");

        // Updating the Used UUID
        usedUUID[order.uuid] = true;

        // Validating the Price Conversion if quoteprice is given
        if (order.quotePrice > 0) {
            _validatePrice(
                SafeCast.toInt256(order.fixedPrice),
                SafeCast.toInt256(order.quotePrice),
                payableToken,
                SafeCast.toInt256(order.slippage)
            );
        }

        uint256 remainingProfit = order.fixedPrice;
        // Tax Settlement
        if (platformAddress != address(0) && order.tax > 0) {
            _handlePayment(
                order.buyer,
                platformAddress,
                order.paymentToken,
                order.tax,
                payableToken
            );
        }

        // PlatformFee Settlement
        uint256 platformFee = 0;
        if (platformAddress != address(0) && platformFeePercentage > 0) {
            platformFee = (remainingProfit * platformFeePercentage) / 10_000;
            remainingProfit = remainingProfit - platformFee;

            _handlePayment(
                order.buyer,
                platformAddress,
                order.paymentToken,
                platformFee,
                payableToken
            );
        }

        // Royalty Fee Payout Settlement
        remainingProfit = _handleRoyaltyEnginePayout(
            order.tokenContract,
            order.tokenId,
            remainingProfit,
            order.paymentToken,
            order.buyer,
            payableToken
        );

        // Transfer the balance to the tokenOwner
        _handlePayment(
            order.buyer,
            order.tokenOwner,
            order.paymentToken,
            remainingProfit,
            payableToken
        );

        // Transferring Tokens
        _tokenTransaction(order);

        emit BuyExecuted(
            order.uuid,
            order.tokenId,
            order.tokenContract,
            order.quantity,
            order.tokenOwner,
            order.buyer,
            order.fixedPrice,
            order.tax,
            order.paymentToken,
            platformAddress,
            platformFee
        );
    }

    /// @notice Sell the listed token with the BuyerSignature - Accepting the Offer
    /// @param order Order struct consists of the listedtoken details
    /// @param buyerSignature Signature generated when signing the hash(order details) by the buyer
    /// @param expirationTime Expiration Time for the offer
    /// @param receivableToken ERC20 address chosen by Buyer for Payments
    function sell(
        Order memory order,
        bytes memory buyerSignature,
        uint256 expirationTime,
        address receivableToken
    ) external nonReentrant {
        // Validating the InterfaceID
        require(
            (IERC165(order.tokenContract).supportsInterface(
                ERC721_INTERFACE_ID
            ) ||
                IERC165(order.tokenContract).supportsInterface(
                    ERC1155_INTERFACE_ID
                )),
            "tokenContract does not support ERC721 or ERC1155 interface"
        );

        // Validating that seller owns a sufficient amount of the token to be listed
        if (
            IERC165(order.tokenContract).supportsInterface(ERC1155_INTERFACE_ID)
        ) {
            uint256 tokenQty = IERC1155(order.tokenContract).balanceOf(
                msg.sender,
                order.tokenId
            );
            require(
                order.quantity <= tokenQty && order.quantity > 0,
                "Insufficient token balance"
            );
        }

        // Validating msg.sender to be Token Owner
        require(
            order.tokenOwner == msg.sender,
            "msg.sender should be token owner"
        );

        // Validating the expiration time
        require(
            expirationTime >= block.timestamp,
            "expirationTime must be a future timestamp"
        );

        // Validating the receivableToken chosen by Seller
        require(
            (receivableToken == wrappedNativeToken ||
                receivableToken == address(0)) &&
                order.paymentToken == wrappedNativeToken,
            "both payment and currency tokens must be supported"
        );

        // Validating buyer's ERC20 balance
        if (order.paymentToken == wrappedNativeToken) {
            require(
                IERC20(order.paymentToken).balanceOf(order.buyer) >=
                    (order.fixedPrice + order.tax),
                "insufficient balance"
            );
            require(
                IERC20(order.paymentToken).allowance(
                    order.buyer,
                    address(this)
                ) >= (order.fixedPrice + order.tax),
                "insufficient token allowance"
            );
        }
        // Validating address if whitelisted address is present
        require(
            order.whitelistedBuyer == address(0) ||
                order.whitelistedBuyer == order.buyer,
            "can only be called by whitelisted buyer"
        );

        // Validating signatures
        require(
            _verifySignature(order, buyerSignature, order.buyer),
            "Invalid buyer signature"
        );

        // Validating UUID
        require(!usedUUID[order.uuid], "UUID already used");

        // Updating the Used UUID
        usedUUID[order.uuid] = true;

        // Validating the Price Conversion if quoteprice is given
        if (order.quotePrice > 0) {
            _validatePrice(
                SafeCast.toInt256(order.fixedPrice),
                SafeCast.toInt256(order.quotePrice),
                receivableToken,
                SafeCast.toInt256(order.slippage)
            );
        }

        uint256 remainingProfit = order.fixedPrice;

        // Tax settlement
        if (platformAddress != address(0) && order.tax > 0) {
            _handlePayment(
                order.buyer,
                platformAddress,
                receivableToken,
                order.tax,
                order.paymentToken
            );
        }

        uint256 platformFee = 0;
        // PlatformFee Settlement
        if (platformAddress != address(0) && platformFeePercentage > 0) {
            platformFee = (remainingProfit * platformFeePercentage) / 10_000;
            remainingProfit = remainingProfit - platformFee;

            _handlePayment(
                order.buyer,
                platformAddress,
                receivableToken,
                platformFee,
                order.paymentToken
            );
        }

        // Royalty Fee Payout Settlement
        remainingProfit = _handleRoyaltyEnginePayout(
            order.tokenContract,
            order.tokenId,
            remainingProfit,
            receivableToken,
            order.buyer,
            order.paymentToken
        );

        // Transfer the balance to the tokenOwner
        _handlePayment(
            order.buyer,
            payable(msg.sender),
            receivableToken,
            remainingProfit,
            order.paymentToken
        );

        // Transferring Tokens
        _tokenTransaction(order);

        emit SaleExecuted(
            order.uuid,
            order.tokenId,
            order.tokenContract,
            order.quantity,
            msg.sender,
            order.buyer,
            order.fixedPrice,
            order.tax,
            receivableToken,
            platformAddress,
            platformFee
        );
    }

    /// @notice Ending an Auction based on the signature verification with highest bidder
    /// @param order Order struct consists of the listedtoken details
    /// @param sellerSignature Signature generated when signing the hash(order details) by the seller
    /// @param buyerSignature Signature generated when signing the hash(order details) by the buyer
    /// @param payableToken ERC20 address chosen by Buyer for Payments
    /// @param bidHistory Bidhistory which contains the list of bidders with the details
    function executeAuction(
        Order memory order,
        bytes memory sellerSignature,
        bytes memory buyerSignature,
        address payableToken,
        BidHistory[] memory bidHistory
    ) external payable nonReentrant {
        // Validating the InterfaceID
        require(
            (IERC165(order.tokenContract).supportsInterface(
                ERC721_INTERFACE_ID
            ) ||
                IERC165(order.tokenContract).supportsInterface(
                    ERC1155_INTERFACE_ID
                )),
            "tokenContract does not support ERC721 or ERC1155 interface"
        );

        // Validating the msg.sender with admin or buyer
        require(
            order.buyer == msg.sender || adminAddress == msg.sender,
            "Only Buyer or the Admin can call this function"
        );

        // Validating Admin can only call only if the payableToken is WrappedNativeToken
        if (adminAddress == msg.sender) {
            require(
                payableToken == wrappedNativeToken,
                "Only Admin can call this function if payableToken is WrappedNativeToken"
            );
        }
        // Validating address if whitelisted address is present
        require(
            order.whitelistedBuyer == address(0) ||
                order.whitelistedBuyer == msg.sender,
            "can only be called by whitelisted buyer"
        );

        // Validating the paymentToken chosen by Seller
        require(
            order.paymentToken == wrappedNativeToken ||
                order.paymentToken == address(0),
            "can only pay with a supported currency"
        );

        // Validating the payableToken chosen by Buyer
        require(
            payableToken == wrappedNativeToken || payableToken == address(0),
            "payableToken must be supported"
        );

        // Checking sufficient balance of ether
        if (payableToken == address(0)) {
            require(
                msg.value >= (order.fixedPrice + order.tax),
                "insufficient amount"
            );
        } else if (payableToken == wrappedNativeToken) {
            require(
                IERC20(payableToken).balanceOf(order.buyer) >=
                    (order.fixedPrice + order.tax),
                "insufficient balance"
            );
            require(
                IERC20(payableToken).allowance(order.buyer, address(this)) >=
                    (order.fixedPrice + order.tax),
                "insufficient token allowance"
            );
        }

        // Validating seller signature
        require(
            _verifySignature(order, sellerSignature, order.tokenOwner),
            "Invalid seller signature"
        );

        // Validating buyer signature
        require(
            _verifySignature(order, buyerSignature, order.buyer),
            "Invalid buyer signature"
        );

        // Validating UUID
        require(!usedUUID[order.uuid], "UUID already used");

        // Updating the Used UUID
        usedUUID[order.uuid] = true;

        // Validating the Price Conversion if quoteprice is given
        if (order.quotePrice > 0) {
            _validatePrice(
                SafeCast.toInt256(order.fixedPrice),
                SafeCast.toInt256(order.quotePrice),
                payableToken,
                SafeCast.toInt256(order.slippage)
            );
        }

        uint256 remainingProfit = order.fixedPrice;

        // Tax Settlement
        if (platformAddress != address(0) && order.tax > 0) {
            _handlePayment(
                order.buyer,
                platformAddress,
                order.paymentToken,
                order.tax,
                payableToken
            );
        }

        // PlatformFee Settlement
        uint256 platformFee = 0;
        if (platformAddress != address(0) && platformFeePercentage > 0) {
            platformFee = (remainingProfit * platformFeePercentage) / 10_000;
            remainingProfit = remainingProfit - platformFee;

            _handlePayment(
                order.buyer,
                platformAddress,
                order.paymentToken,
                platformFee,
                payableToken
            );
        }

        // Royalty Fee Payout Settlement
        remainingProfit = _handleRoyaltyEnginePayout(
            order.tokenContract,
            order.tokenId,
            remainingProfit,
            order.paymentToken,
            order.buyer,
            payableToken
        );

        // Transfer the balance to the tokenOwner
        _handlePayment(
            order.buyer,
            order.tokenOwner,
            order.paymentToken,
            remainingProfit,
            payableToken
        );

        // Transferring the Tokens
        _tokenTransaction(order);

        emit AuctionClosed(
            order.uuid,
            order.tokenId,
            order.tokenContract,
            order.quantity,
            order.tokenOwner,
            order.buyer,
            order.fixedPrice,
            order.tax,
            order.paymentToken,
            platformAddress,
            platformFee,
            bidHistory
        );
    }

    /// @notice Transferring the tokens based on the from and to Address
    /// @param _order Order struct consists of the listedtoken details
    function _tokenTransaction(Order memory _order) internal {
        if (
            IERC165(_order.tokenContract).supportsInterface(ERC721_INTERFACE_ID)
        ) {
            require(
                IERC721(_order.tokenContract).ownerOf(_order.tokenId) ==
                    _order.tokenOwner,
                "maker is not the owner"
            );

            // Transferring the ERC721
            IERC721(_order.tokenContract).safeTransferFrom(
                _order.tokenOwner,
                _order.buyer,
                _order.tokenId
            );
        }
        if (
            IERC165(_order.tokenContract).supportsInterface(
                ERC1155_INTERFACE_ID
            )
        ) {
            uint256 ownerBalance = IERC1155(_order.tokenContract).balanceOf(
                _order.tokenOwner,
                _order.tokenId
            );
            require(
                _order.quantity <= ownerBalance && _order.quantity > 0,
                "Insufficient token balance"
            );

            // Transferring the ERC1155
            IERC1155(_order.tokenContract).safeTransferFrom(
                _order.tokenOwner,
                _order.buyer,
                _order.tokenId,
                _order.quantity,
                "0x"
            );
        }
    }

    /// @notice Settle the Payment based on the given parameters
    /// @param _from Address from whom we get the payment amount to settle
    /// @param _to Address to whom need to settle the payment
    /// @param _paymentToken Address of the ERC20 Payment Token
    /// @param _amount Amount to be transferred
    /// @param _currencyToken Address of the ERC20 Token
    function _handlePayment(
        address _from,
        address payable _to,
        address _paymentToken,
        uint256 _amount,
        address _currencyToken
    ) internal {
        bool success;
        if (_paymentToken == address(0) && _currencyToken == address(0)) {
            (success, ) = _to.call{value: _amount}(new bytes(0));
            require(success, "transaction failed");
        } else if (
            _paymentToken == wrappedNativeToken && _currencyToken == address(0)
        ) {
            IWrappedNativeToken(wrappedNativeToken).deposit{value: _amount}();
            IERC20(_paymentToken).safeTransfer(_to, _amount);
        } else if (
            _paymentToken == address(0) && _currencyToken == wrappedNativeToken
        ) {
            IERC20(wrappedNativeToken).safeTransferFrom(
                _from,
                address(this),
                _amount
            );
            IWrappedNativeToken(wrappedNativeToken).withdraw(_amount);
            (success, ) = _to.call{value: _amount}(new bytes(0));
            require(success, "transaction failed");
        } else if (_paymentToken == _currencyToken) {
            IERC20(_paymentToken).safeTransferFrom(_from, _to, _amount);
        }
    }

    /// @notice Settle the Royalty Payment based on the given parameters
    /// @param _tokenContract The NFT Contract address
    /// @param _tokenId The NFT tokenId
    /// @param _amount Amount to be transferred
    /// @param _payoutCurrency Address of the ERC20 Payout
    /// @param _buyer From Address for the ERC20 Payout
    /// @param _currencyToken Address of the ERC20 Token
    /// @param amountRemaining Remaining amount from the total payout
    function _handleRoyaltyEnginePayout(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount,
        address _payoutCurrency,
        address _buyer,
        address _currencyToken
    ) internal returns (uint256 amountRemaining) {
        // Store the initial amount
        amountRemaining = _amount;
        uint256 feeAmount;
        address payable[] memory recipients;
        uint256[] memory bps;
        // Verifying whether the token contract supports Royalties of supported interfaces
        if (royaltyActive) {
            (recipients, bps) = IRoyaltyEngine(royaltyRegistryAddress)
                .getRoyalty(_tokenContract, _tokenId);
        }

        // Store the number of recipients
        uint256 totalRecipients = recipients.length;

        // If there are no royalties, return the initial amount
        if (totalRecipients == 0) return _amount;

        // pay out each royalty
        for (uint256 i = 0; i < totalRecipients; ) {
            // Cache the recipient and amount
            address payable recipient = recipients[i];

            // Calculate royalty basis points
            feeAmount = (bps[i] * _amount) / 10_000;

            // Ensure that there's still enough balance remaining
            require(amountRemaining >= feeAmount, "insolvent");

            _handlePayment(
                _buyer,
                recipient,
                _payoutCurrency,
                feeAmount,
                _currencyToken
            );
            emit RoyaltyPayout(_tokenContract, _tokenId, recipient, feeAmount);

            // Cannot underflow as remaining amount is ensured to be greater than or equal to royalty amount
            unchecked {
                amountRemaining -= feeAmount;
                ++i;
            }
        }

        return amountRemaining;
    }

    /// @notice Verifies the Signature with the required Signer
    /// @param _order Order struct consists of the listedtoken details
    /// @param _signature Signature generated when signing the hash(order details) by the signer
    /// @param _signer Address of the Signer
    /// @param isVerified Signature is verified or not
    function _verifySignature(
        Order memory _order,
        bytes memory _signature,
        address _signer
    ) internal view returns (bool isVerified) {
        return
            keccak256(
                abi.encode(
                    _order.uuid,
                    _order.tokenId,
                    _order.tokenContract,
                    _order.quantity,
                    _order.tokenOwner,
                    _order.fixedPrice,
                    _order.paymentToken,
                    block.chainid
                )
            ).toEthSignedMessageHash().recover(_signature) == _signer;
    }

    /// @notice Validate the quoted price with the ERC20 address price
    /// @param _basePrice Price fixed by the TokenOwner
    /// @param _destPrice Quoted price in fiat currency
    /// @param _saleCurrency ERC20 address chosen by TokenOwner for Payments
    /// @param _slippage Price Limit based on the percentage
    function _validatePrice(
        int256 _basePrice,
        int256 _destPrice,
        address _saleCurrency,
        int256 _slippage
    ) internal {
        // Getting the latest Price from the PriceFeed Contract
        (int256 price, uint8 roundId) = IPriceFeed(priceFeedAddress)
            .getLatestPrice(_saleCurrency);

        // Validate the exact fixed Price with the quoted Price
        require(
            (((_destPrice / ONE_ETH_WEI) +
                (((_destPrice * _slippage) / ONE_ETH_WEI) / 100)) >=
                (price * _basePrice) /
                    (SafeCast.toInt256(10**roundId) * ONE_ETH_WEI)),
            "quotePrice with slippage is less than the fixedPrice"
        );
    }

    /// @notice Withdraw the funds to contract owner
    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "zero balance in the contract");
        bool success;
        address payable to = payable(msg.sender);
        (success, ) = to.call{value: address(this).balance}(new bytes(0));
        require(success, "withdrawal failed");
        emit WithdrawPayout(to, address(this).balance);
    }

    /// @notice Update the WrappedNative Token Address
    /// @param _wrappedNativeToken Native ERC20 Address
    function updateWrappedNativeToken(address _wrappedNativeToken)
        external
        onlyOwner
    {
        require(
            _wrappedNativeToken != address(0) &&
                _wrappedNativeToken != wrappedNativeToken,
            "Invalid WrappedNativeToken Address"
        );
        wrappedNativeToken = _wrappedNativeToken;
        emit UpdatedAddress(wrappedNativeToken);
    }

    /// @notice Update the PriceFeed Address
    /// @param _priceFeedAddress PriceFeed Contract Address
    function updatePriceFeedAddress(address _priceFeedAddress)
        external
        onlyOwner
    {
        require(
            _priceFeedAddress != address(0) &&
                _priceFeedAddress != priceFeedAddress,
            "Invalid PriceFeed Address"
        );
        priceFeedAddress = _priceFeedAddress;
        emit UpdatedAddress(priceFeedAddress);
    }

    /// @notice Update the admin Address
    /// @param _adminAddress Admin Address
    function updateAdminAddress(address _adminAddress) external onlyOwner {
        require(
            _adminAddress != address(0) && _adminAddress != adminAddress,
            "Invalid Admin Address"
        );
        adminAddress = _adminAddress;
        emit UpdatedAddress(adminAddress);
    }

    /// @notice Update the platform Address
    /// @param _platformAddress The Platform Address
    function updatePlatformAddress(address _platformAddress)
        external
        onlyOwner
    {
        require(
            _platformAddress != address(0) &&
                _platformAddress != platformAddress,
            "Invalid Platform Address"
        );
        platformAddress = payable(_platformAddress);
        emit UpdatedAddress(platformAddress);
    }

    /// @notice Update the Platform Fee Percentage
    /// @param _platformFeePercentage The Platform fee percentage
    function updatePlatformFeePercentage(uint256 _platformFeePercentage)
        external
        onlyOwner
    {
        require(
            _platformFeePercentage <= 10_000,
            "platformFee should not be more than 100 %"
        );
        platformFeePercentage = _platformFeePercentage;
        emit UpdateFeePercentage(platformFeePercentage);
    }

    /// @notice Update the Royalty Registry Address
    /// @param _royaltyRegistryAddress The Royalty Registry Address
    function updateRoyaltyRegistryAddress(address _royaltyRegistryAddress)
        external
        onlyOwner
    {
        require(
            _royaltyRegistryAddress != address(0) &&
                _royaltyRegistryAddress != royaltyRegistryAddress,
            "Invalid Royalty Registry Address"
        );
        royaltyRegistryAddress = _royaltyRegistryAddress;
        emit UpdatedAddress(platformAddress);
    }

    /// @notice Update the Royalty Active Status
    /// @param _royaltyStatus The Royalty Active Status true or false
    function updateRoyaltyActive(bool _royaltyStatus) external onlyOwner {
        royaltyActive = _royaltyStatus;
        emit UpdateStatus(royaltyActive);
    }

    /// @notice Get the Royalty Info Details against the collection and TokenID
    /// @param collectionAddress The Collection Address of the token
    /// @param tokenId The TokenId value
    /// @param recipients List of Recipient Address
    /// @param bps List of Basis points
    function getRoyaltyInfo(address collectionAddress, uint256 tokenId)
        external
        view
        returns (address payable[] memory recipients, uint256[] memory bps)
    {
        require(royaltyActive, "The Royalty Address is inactive.");
        (
            recipients,
            bps // Royalty amount denominated in basis points
        ) = IRoyaltyEngine(royaltyRegistryAddress).getRoyalty(
            collectionAddress,
            tokenId
        );
    }

    receive() external payable {}

    fallback() external payable {}
}