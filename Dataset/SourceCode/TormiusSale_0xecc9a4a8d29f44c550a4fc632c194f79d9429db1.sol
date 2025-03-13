// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {Owned} from "solmate/auth/Owned.sol";
import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";
import {EIP712} from "openzeppelin/utils/cryptography/EIP712.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {IERC1155} from "openzeppelin/token/ERC1155/IERC1155.sol";
import {FountCardCheck} from "fount-contracts/community/FountCardCheck.sol";
import {Withdraw} from "fount-contracts/utils/Withdraw.sol";
import {IPayments} from "./interfaces/IPayments.sol";
import {IRedNight} from "./interfaces/IRedNight.sol";
import {CIRCULAR_TENSION_ID, FALLEN_ANGEL_ID, RED_NIGHT_ID} from "./Constants.sol";

/**
 * @author Fount Gallery
 * @title  Tormius 23 sale contract
 * @notice Allows the sale of NFTs from the Tormius 23 collection
 */
contract TormiusSale is Owned, FountCardCheck, Withdraw, EIP712 {
    /* ------------------------------------------------------------------------
       S T O R A G E
    ------------------------------------------------------------------------ */

    /// @notice tormius.eth
    // address public artist = 0xFF559FC20D9B6d78E6E570D234B69c18142BB65e;
    address public artist = 0xeb9500b009BB53C8b28a46d8f591d620F184f53b;

    /// @notice Address where payments should be sent
    address public payments;

    /// @notice Sale start time: Thu Mar 23 2023 18:00:00 UTC
    uint256 public saleStart = 1679594400;

    /// @notice Whether the sale is paused
    bool public salePaused;

    /// @notice Struct for token sale data
    struct SaleData {
        uint96 price;
        uint8 available;
        uint32 availableUntil;
        address tokenAddress;
    }

    /// @notice Mapping of token IDs to their respective token addresses
    mapping(uint256 => SaleData) public saleData;

    /// @notice EIP-712 signing domain
    string public constant SIGNING_DOMAIN = "TormiusSale";

    /// @notice EIP-712 signature version
    string public constant SIGNATURE_VERSION = "1";

    /// @notice EIP-712 signed data type hash for collecting with an off-chain signature
    bytes32 public constant COLLECT_SIGNATURE_HASH =
        keccak256("CollectSignatureData(uint256 id,address to,uint256 nonce)");

    /// @dev EIP-712 signed data struct for collecting with an off-chain signature
    struct CollectSignatureData {
        uint256 id;
        address to;
        uint256 nonce;
        bytes signature;
    }

    /// @notice Approved signer public addresses
    mapping(address => bool) public approvedSigners;

    /// @notice Nonce management to avoid signature replay attacks
    mapping(address => uint256) public nonces;

    /* ------------------------------------------------------------------------
       E R R O R S
    ------------------------------------------------------------------------ */

    error SalePausedOrNotStarted();
    error InvalidTokenId();
    error SoldOut();
    error NoLongerCollectable();
    error IncorrectPaymentAmount();
    error InvalidSignature();
    error AlreadyCollected();

    /* ------------------------------------------------------------------------
       E V E N T S
    ------------------------------------------------------------------------ */

    event TokenListed(uint256 indexed id);
    event Collected(uint256 indexed id);

    /* ------------------------------------------------------------------------
       I N I T
    ------------------------------------------------------------------------ */

    /**
     * @param owner_ The owner of the contract
     * @param payments_ The address where payments should be sent
     * @param fountCard_ The address of the Fount Card contract
     */
    constructor(
        address owner_,
        address payments_,
        address fountCard_
    ) Owned(owner_) FountCardCheck(fountCard_) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        payments = payments_;
    }

    /**
     * @notice Maps token IDs to their respective token addresses
     * @param circularTension_ The address of the Circular Tension NFT
     * @param fallenAngel_ The address of the Fallen Angel NFT
     * @param redNight_ The address of the Red Night NFT
     */
    function mapTokenIdsToAddresses(
        address circularTension_,
        address fallenAngel_,
        address redNight_
    ) external onlyOwner {
        saleData[1] = SaleData({
            price: 3.5 ether,
            available: 1,
            availableUntil: 0,
            tokenAddress: circularTension_
        });

        saleData[2] = SaleData({
            price: 0.23 ether,
            available: 22, // One is reserved for the artist to airdrop
            availableUntil: 0,
            tokenAddress: fallenAngel_
        });

        saleData[3] = SaleData({
            price: 0,
            available: 0,
            availableUntil: 1680821940,
            tokenAddress: redNight_
        });

        emit TokenListed(1);
        emit TokenListed(2);
        emit TokenListed(3);
    }

    /* ------------------------------------------------------------------------
       P U R C H A S I N G
    ------------------------------------------------------------------------ */

    /**
     * @notice
     * Purchase either the Circular Tension or a Fallen Angel NFT
     *
     * @dev
     * Reverts if:
     *   - The token ID is invalid
     *   - The sale is paused or has not started
     *   - The token is sold out
     *   - The token is no longer collectable
     *   - The payment amount is incorrect
     *
     * @param id The token ID to purchase
     */
    function purchase(uint256 id) external payable {
        // Check the token ID is valid
        if (id == 0 || id > 2) revert InvalidTokenId();

        // Check global sale state
        if (block.timestamp < saleStart || salePaused) revert SalePausedOrNotStarted();

        // Check conditions for the given token ID
        SaleData storage data = saleData[id];
        if (data.available == 0) revert SoldOut();
        if (data.availableUntil > 0 && block.timestamp > data.availableUntil) {
            revert NoLongerCollectable();
        }
        if (msg.value != data.price) revert IncorrectPaymentAmount();

        // Decrement the available amount
        data.available--;

        // Transfer the token from the artist to the caller
        if (id == 1) {
            IERC721(data.tokenAddress).transferFrom(artist, msg.sender, CIRCULAR_TENSION_ID);
        }

        if (id == 2) {
            IERC1155(data.tokenAddress).safeTransferFrom(
                artist,
                msg.sender,
                FALLEN_ANGEL_ID,
                1,
                ""
            );
        }

        emit Collected(id);
    }

    /**
     * @notice
     * Collect an edition of the Red Night NFT with a mint signature
     *
     * @dev
     * Reverts if:
     *   - The sale is paused or has not started
     *   - The token is no longer collectable
     *   - The price is not free and the payment amount is incorrect
     *   - The provided signature is invalid
     *   - The caller already holds a Red Night edition
     */
    function collectRedNight(bytes calldata signature) external payable {
        // Red Night requires a Fount Card or a valid signature
        // If a signature was provided, then it must be valid
        if (!_verifyCollectSignature(3, msg.sender, signature)) revert InvalidSignature();

        _collectRedNight();
    }

    /**
     * @notice
     * Collect an edition of the Red Night NFT with a Fount Patron card
     *
     * @dev
     * Reverts if:
     *   - The sale is paused or has not started
     *   - The token is no longer collectable
     *   - The price is not free and the payment amount is incorrect
     *   - The caller does not hold a Fount Card
     *   - The caller already holds a Red Night edition
     */
    function collectRedNight() external payable onlyWhenFountCardHolder {
        _collectRedNight();
    }

    /**
     * @dev
     * Internal function to collect the Red Night NFT. This checks all the shared
     * conditions and then mints the token to the caller.
     */
    function _collectRedNight() internal {
        // Check global sale state
        if (block.timestamp < saleStart || salePaused) revert SalePausedOrNotStarted();

        // Check if the Red Night is still collectable
        SaleData memory data = saleData[3];
        if (block.timestamp > data.availableUntil) revert NoLongerCollectable();
        if (data.price > 0 && msg.value != data.price) revert IncorrectPaymentAmount();
        if (IERC1155(data.tokenAddress).balanceOf(msg.sender, 3) > 0) revert AlreadyCollected();

        // Mint the token to the caller
        IRedNight(data.tokenAddress).mintRedNight(msg.sender);

        emit Collected(3);
    }

    /* ------------------------------------------------------------------------
       S I G N A T U R E   V E R I F I C A T I O N
    ------------------------------------------------------------------------ */

    /**
     * @notice Internal function to verify an EIP-712 collecting signature
     * @param id The token id
     * @param to The account that has approval to collect
     * @param signature The EIP-712 signature
     * @return bool If the signature is verified or not
     */
    function _verifyCollectSignature(
        uint256 id,
        address to,
        bytes calldata signature
    ) internal returns (bool) {
        CollectSignatureData memory data = CollectSignatureData({
            id: id,
            to: to,
            nonce: nonces[to],
            signature: signature
        });

        // Hash the data for verification
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(COLLECT_SIGNATURE_HASH, data.id, data.to, nonces[data.to]++))
        );

        // Verify signature is ok
        address addr = ECDSA.recover(digest, data.signature);
        return approvedSigners[addr] && addr != address(0);
    }

    /* ------------------------------------------------------------------------
       A D M I N
    ------------------------------------------------------------------------ */

    /**
     * @notice Admin function to set the sale start time
     * @param startTime The new start time
     */
    function setSaleStart(uint256 startTime) external onlyOwner {
        saleStart = startTime;
    }

    /**
     * @notice Admin function to pause or unpause the sale
     * @param paused If the sale is paused
     */
    function setSalePaused(bool paused) external onlyOwner {
        salePaused = paused;
    }

    /**
     * @notice Admin function to set an EIP-712 signer address
     * @param signer The address of the new signer
     * @param approved If the signer is approved
     */
    function setSigner(address signer, bool approved) external onlyOwner {
        approvedSigners[signer] = approved;
    }

    /**
     * @notice Admin function to update the sale price of a token
     * @param id The token ID to update
     * @param price The new price
     */
    function updatePrice(uint256 id, uint96 price) external onlyOwner {
        saleData[id].price = price;
    }

    /**
     * @notice Admin function to update when a token should be available until
     * @param id The token ID to update
     * @param availableUntil The new available date
     */
    function updateAvailableUntil(uint256 id, uint32 availableUntil) external onlyOwner {
        saleData[id].availableUntil = availableUntil;
    }

    /**
     * @notice Admin function to update the token address if it changes
     * @param id The token ID to update
     * @param tokenAddress The new token address
     */
    function updateTokenAddress(uint256 id, address tokenAddress) external onlyOwner {
        saleData[id].tokenAddress = tokenAddress;
    }

    /* ------------------------------------------------------------------------
       W I T H D R A W
    ------------------------------------------------------------------------ */

    /**
     * @notice Withdraw ETH from this contract to the payments address
     * @dev Withdraws to the `payments` address. Reverts if the payments address is set to zero.
     */
    function withdrawETH() public {
        _withdrawETH(payments);
    }

    /**
     * @notice Withdraw ETH from this contract and release from payments contract
     * @dev Withdraws to the `payments` address, then calls `releaseAllETH` as a splitter.
     * Reverts if the payments address is set to zero.
     */
    function withdrawAndReleaseAllETH() public {
        _withdrawETH(payments);
        IPayments(payments).releaseAllETH();
    }

    /**
     * @notice Withdraw ERC-20 tokens from this contract
     * @param to The address to send the ERC-20 tokens to
     */
    function withdrawTokens(address tokenAddress, address to) public onlyOwner {
        _withdrawToken(tokenAddress, to);
    }
}