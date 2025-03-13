// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title PreSaleDopInstitution contract
/// @notice Implements the institution preSale of Dop Token
/// @dev The PreSaleDopInstitution contract allows you to purchase dop token with ETH and other tokens
/// @dev The recorded DOP tokens claims will be distributed later using another distributor contract.

contract PreSaleDopInstitution is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice Thrown when address is blacklisted
    error Blacklisted();

    /// @notice Thrown when updating an address with zero address
    error ZeroAddress();

    /// @notice Thrown when buy is disabled
    error BuyNotEnable();

    /// @notice Thrown when Sign is invalid
    error InvalidSignature();

    /// @notice Thrown when price from pricefeed is zero
    error PriceNotFound();

    /// @notice Thrown when both pricefeed and reference price are non zero
    error CodeSyncIssue();

    /// @notice Thrown when Eth price suddenly drops while purchasing with ETH
    error UnexpectedPriceDifference();

    /// @notice Thrown when value to transfer is zero
    error ZeroValue();

    /// @notice Thrown when updating with the same value as previously stored
    error IdenticalValue();

    /// @notice Thrown when two array lengths does not match
    error ArrayLengthMismatch();

    /// @notice Thrown when value to transfer is zero
    error ValueZero();

    /// @notice Thrown when sign deadline is expired
    error DeadlineExpired();

    /// @notice Thrown when updating with an array of no values
    error ZeroLengthArray();

    /// @notice Thrown when Token is restricted in given round
    error TokenDisallowed();

    /// @dev The ETH identifier
    IERC20 public constant ETH =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /// @notice BuyEnable or not
    bool public buyEnable = true;

    /// @notice The address of signerWallet
    address public signerWallet;

    /// @notice The address of fundsWallet
    address public fundsWallet;

    /// @notice Gives claim info of user
    mapping(address => uint256) public claims;

    /// @notice Gives us onchain price oracle address of the token
    mapping(IERC20 => PriceFeedData) public tokenData;

    /// @notice Gives info about address's permission
    mapping(address => bool) public blacklistAddress;

    /// @notice mapping gives us access info of the token
    mapping(IERC20 => bool) public allowedTokens;

    /// @dev Emitted when dop is purchased with ETH
    event InvestedWithEth(
        address indexed by,
        string code,
        uint256 amountInvestedEth,
        address indexed recipient,
        uint256 indexed price,
        uint256 dopPurchased
    );

    /// @dev Emitted when dop is purchased with Token
    event InvestedWithToken(
        address indexed by,
        string code,
        IERC20 indexed token,
        uint256 amountInvested,
        address indexed recipient,
        uint256 price,
        uint256 tokenPrice,
        uint256 dopPurchased
    );

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldAddress, address newAddress);

    /// @dev Emitted when blacklist access of address is updated
    event BlacklistUpdated(address which, bool accessNow);

    /// @dev Emitted when buying access changes
    event BuyEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when address of Chainlink priceFeed contract is added for the token
    event TokenDataAdded(IERC20 indexed token, AggregatorV3Interface priceFeed);

    /// @dev Emitted when token access is updated
    event TokensAccessUpdated(IERC20 indexed token, bool indexed access);

    /// @member priceFeed The Chainlink priceFeed address
    /// @member normalizationFactorForToken The normalization factor to achieve return value of 18 decimals ,while calculating dop token purchases and always with different token decimals
    struct PriceFeedData {
        AggregatorV3Interface priceFeed;
        uint8 normalizationFactor;
    }

    /// @member price The price of token from priceFeed
    /// @member normalizationFactorForToken The normalization factor to achieve return value of 18 decimals ,while calculating dop token purchases and always with different token decimals
    struct TokenInfo {
        uint256 latestPrice;
        uint8 normalizationFactor;
    }

    /// @notice Restricts blacklisted addresses
    modifier notBlacklisted(address which) {
        if (blacklistAddress[which]) {
            revert Blacklisted();
        }
        _;
    }

    /// @notice Restricts when updating wallet/contract address to zero address
    modifier checkZeroAddress(address which) {
        if (which == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    /// @notice Ensures that buy is enabled when buying
    modifier canBuy() {
        if (!buyEnable) {
            revert BuyNotEnable();
        }
        _;
    }

    /// @dev Constructor.
    /// @param signerAddress The address of signer wallet
    /// @param fundsWalletAddress The address of funds wallet
    /// @param owner The address of owner wallet
    constructor(
        address fundsWalletAddress,
        address signerAddress,
        address owner
    ) Ownable(owner) {
        if (
            fundsWalletAddress == address(0) ||
            signerAddress == address(0) ||
            owner == address(0)
        ) {
            revert ZeroAddress();
        }
        fundsWallet = fundsWalletAddress;
        signerWallet = signerAddress;
    }

    /// @notice Changes access of buying
    /// @param enabled The decision about buying
    function enableBuy(bool enabled) external onlyOwner {
        if (buyEnable == enabled) {
            revert IdenticalValue();
        }
        emit BuyEnableUpdated({oldAccess: buyEnable, newAccess: enabled});
        buyEnable = enabled;
    }

    /// @notice Changes signer wallet address
    /// @param newSigner The address of the new signer wallet
    function changeSigner(
        address newSigner
    ) external checkZeroAddress(newSigner) onlyOwner {
        address oldSigner = signerWallet;
        if (oldSigner == newSigner) {
            revert IdenticalValue();
        }
        emit SignerUpdated({oldSigner: oldSigner, newSigner: newSigner});
        signerWallet = newSigner;
    }

    /// @notice Changes funds wallet to a new address
    /// @param newFundsWallet The address of the new funds wallet
    function changeFundsWallet(
        address newFundsWallet
    ) external checkZeroAddress(newFundsWallet) onlyOwner {
        address oldWallet = fundsWallet;
        if (oldWallet == newFundsWallet) {
            revert IdenticalValue();
        }
        emit FundsWalletUpdated({
            oldAddress: oldWallet,
            newAddress: newFundsWallet
        });
        fundsWallet = newFundsWallet;
    }

    /// @notice Changes the access of any address in contract interaction
    /// @param which The address for which access is updated
    /// @param access The access decision of `which` address
    function updateBlackListedUser(
        address which,
        bool access
    ) external checkZeroAddress(which) onlyOwner {
        bool oldAccess = blacklistAddress[which];
        if (oldAccess == access) {
            revert IdenticalValue();
        }
        emit BlacklistUpdated({which: which, accessNow: access});
        blacklistAddress[which] = access;
    }

    /// @notice Purchases dopToken with Eth
    /// @param code The code is used to verify signature of the user
    /// @param recipient The recipient is the address which will claim Dop tokens
    /// @param price The price is usdt price of Dop token
    /// @param deadline The deadline is validity of the signature
    /// @param minAmountDop The minAmountDop user agrees to purchase
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseWithEth(
        string memory code,
        address recipient,
        uint256 price,
        uint256 deadline,
        uint256 minAmountDop,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable notBlacklisted(recipient) canBuy nonReentrant {
        _validatePurchase(deadline, ETH, msg.value);
        _verifyCode(code, recipient, price, deadline, v, r, s);
        TokenInfo memory tokenInfo = getLatestPrice(ETH);
        if (tokenInfo.latestPrice == 0) {
            revert PriceNotFound();
        }
        uint256 toReturn = ((msg.value * tokenInfo.latestPrice) *
            (10 ** tokenInfo.normalizationFactor)) / price;
        if (toReturn < minAmountDop) {
            revert UnexpectedPriceDifference();
        }
        claims[recipient] += toReturn;
        payable(fundsWallet).sendValue(msg.value);
        emit InvestedWithEth({
            by: msg.sender,
            code: code,
            amountInvestedEth: msg.value,
            recipient: recipient,
            price: price,
            dopPurchased: toReturn
        });
    }

    /// @notice Purchases dopToken with token
    /// @param token The Investment token
    /// @param investment The Investment amount
    /// @param code The code is used to verify signature of the user
    /// @param referenceNormalizationFactor The normalization factor
    /// @param referenceTokenPrice The current price of token in 10 decimals
    /// @param recipient The recipient is the address which will claim Dop tokens
    /// @param price The price is usdt price of Dop token
    /// @param deadline The deadline is validity of the signature
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseWithToken(
        IERC20 token,
        uint256 investment,
        string memory code,
        uint8 referenceNormalizationFactor,
        uint256 referenceTokenPrice,
        uint256 minAmountDop,
        address recipient,
        uint256 price,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external notBlacklisted(recipient) canBuy nonReentrant {
        _validatePurchase(deadline, token, investment);
        _verifyCodeWithPrice(
            token,
            code,
            recipient,
            price,
            deadline,
            referenceNormalizationFactor,
            referenceTokenPrice,
            v,
            r,
            s
        );
        (uint256 latestPrice, uint8 normalizationFactor) = _validatePrice(
            token,
            referenceTokenPrice,
            referenceNormalizationFactor
        );
        // we don't expect such value such that this multiplication overflows and reverts.
        uint256 toReturn = (investment *
            latestPrice *
            (10 ** normalizationFactor)) / price;
        if (toReturn < minAmountDop) {
            revert UnexpectedPriceDifference();
        }
        claims[recipient] += toReturn;
        token.safeTransferFrom(msg.sender, fundsWallet, investment);
        emit InvestedWithToken({
            by: msg.sender,
            code: code,
            token: token,
            amountInvested: investment,
            recipient: recipient,
            price: price,
            tokenPrice: latestPrice,
            dopPurchased: toReturn
        });
    }

    /// @notice The Chainlink inherited function, give us tokens live price
    function getLatestPrice(
        IERC20 token
    ) public view returns (TokenInfo memory) {
        PriceFeedData memory data = tokenData[token];
        TokenInfo memory tokenInfo;
        if (address(data.priceFeed) == address(0)) {
            return tokenInfo;
        }
        (
            ,
            /*uint80 roundID*/ int price /*uint256 startedAt*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = /*uint256 timeStamp*/ data.priceFeed.latestRoundData();
        tokenInfo = TokenInfo({
            latestPrice: uint256(price),
            normalizationFactor: data.normalizationFactor
        });
        return tokenInfo;
    }

    /// @notice Sets Chainlink price feed contracts of the tokens
    /// @param tokens The addresses of the tokens
    /// @param priceFeedData Contains the priceFeed of the tokens and the normalization factor
    function setTokenPriceFeed(
        IERC20[] calldata tokens,
        PriceFeedData[] calldata priceFeedData
    ) external onlyOwner {
        if (tokens.length == 0) {
            revert ZeroLengthArray();
        }
        if (tokens.length != priceFeedData.length) {
            revert ArrayLengthMismatch();
        }
        for (uint256 i = 0; i < tokens.length; ++i) {
            PriceFeedData memory data = priceFeedData[i];
            IERC20 token = tokens[i];
            PriceFeedData memory currentPriceFeedData = tokenData[token];
            if (
                address(token) == address(0) ||
                address(data.priceFeed) == address(0)
            ) {
                revert ZeroAddress();
            }
            if (
                currentPriceFeedData.priceFeed == data.priceFeed &&
                currentPriceFeedData.normalizationFactor ==
                data.normalizationFactor
            ) {
                revert IdenticalValue();
            }
            emit TokenDataAdded({token: token, priceFeed: data.priceFeed});
            tokenData[token] = data;
        }
    }

    /// @notice Updates the access of tokens in a given round
    /// @param tokens addresses of the tokens
    /// @param accesses The access for the tokens
    function updateAllowedTokens(
        IERC20[] calldata tokens,
        bool[] memory accesses
    ) external onlyOwner {
        if (tokens.length == 0) {
            revert ZeroLengthArray();
        }
        if (tokens.length != accesses.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            if (address(token) == address(0)) {
                revert ZeroAddress();
            }
            allowedTokens[token] = accesses[i];
            emit TokensAccessUpdated({token: token, access: accesses[i]});
        }
    }

    /// @notice The helper function which verifies signature, signed by signerWallet, reverts if invalidSignature
    function _verifyCode(
        string memory code,
        address recipient,
        uint256 price,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        bytes32 encodedMessageHash = keccak256(
            abi.encodePacked(code, recipient, price, deadline)
        );

        _verifyMessage(encodedMessageHash, v, r, s);
    }

    /// @notice The helper function which verifies signature, signed by signerWallet, reverts if invalidSignature
    function _verifyCodeWithPrice(
        IERC20 token,
        string memory code,
        address recipient,
        uint256 price,
        uint256 deadline,
        uint8 normalizationFactor,
        uint256 referenceTokenPrice,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        bytes32 encodedMessageHash = keccak256(
            abi.encodePacked(
                token,
                code,
                recipient,
                price,
                normalizationFactor,
                referenceTokenPrice,
                deadline
            )
        );

        _verifyMessage(encodedMessageHash, v, r, s);
    }

    /// @notice Verifies the address that signed a hashed message (`hash`) with
    /// `signature`
    function _verifyMessage(
        bytes32 encodedMessageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view {
        if (
            signerWallet !=
            ECDSA.recover(
                MessageHashUtils.toEthSignedMessageHash(encodedMessageHash),
                v,
                r,
                s
            )
        ) {
            revert InvalidSignature();
        }
    }

    /// @notice Checks value, if zero then reverts
    function _checkValue(uint256 value) internal pure {
        if (value == 0) {
            revert ValueZero();
        }
    }

    /// @notice Checks and returns price and normalization factor of the token
    function _validatePrice(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint8 referenceNormalizationFactor
    ) private view returns (uint256, uint8) {
        TokenInfo memory tokenInfo = getLatestPrice(token);
        if (
            tokenInfo.latestPrice != 0 &&
            (referenceTokenPrice != 0 || referenceNormalizationFactor != 0)
        ) {
            revert CodeSyncIssue();
        }
        //  If price feed isn't available,we fallback to the reference price
        if (tokenInfo.latestPrice == 0) {
            if (referenceTokenPrice == 0 || referenceNormalizationFactor == 0) {
                revert ZeroValue();
            }
            tokenInfo.latestPrice = referenceTokenPrice;
            tokenInfo.normalizationFactor = referenceNormalizationFactor;
        }
        return (tokenInfo.latestPrice, tokenInfo.normalizationFactor);
    }

    /// @notice Checks deadline, token access and investment
    function _validatePurchase(
        uint256 deadline,
        IERC20 token,
        uint256 investment
    ) internal view {
        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }
        if (!allowedTokens[token]) {
            revert TokenDisallowed();
        }
        _checkValue(investment);
    }
}