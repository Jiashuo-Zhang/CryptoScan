// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

abstract contract IEditions {
    struct Edition {
        bool frozenMetadata;
        uint256 maxSupply;
        string uri;
    }

    function editionExists(uint256 __id) external view virtual returns (bool);

    function mint(
        address __account,
        uint256 __id,
        uint256 __amount
    ) external virtual;

    function maxSupply(uint __id) external virtual returns (uint256);
}

contract Sales is Ownable, ReentrancyGuard {
    error AmountExceedsTransactionLimit();
    error AmountExceedsWalletLimit();
    error EditionNotFound();
    error HasEnded();
    error HasNotStarted();
    error HasStarted();
    error IncorrectPrice();
    error InvalidProof();
    error InvalidStart();
    error InvalidTimeframe();
    error LimitGreaterThanSupply();
    error MerkleRootNotSet();
    error ProofIsRequired();
    error SaleNotFound();
    error WithdrawFailed();

    event SaleCreated(uint256 __tokenID, uint256 __saleID);
    event SalePriceUpdated(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __price
    );
    event SaleStartUpdated(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __start
    );
    event SaleEndUpdated(uint256 __tokenID, uint256 __saleID, uint256 __end);
    event SaleWalletLimitUpdated(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __walletLimit
    );
    event SaleMerkleRootUpdated(
        uint256 __tokenID,
        uint256 __saleID,
        bytes32 __merkleRoot
    );

    struct Sale {
        uint256 price;
        uint256 start;
        uint256 end;
        uint256 walletLimit;
        bytes32 merkleRoot;
    }

    IEditions private _editionsContract;

    uint256 public transactionLimit = 100;

    // Mapping of sales
    mapping(uint256 => Sale[]) private _sales;

    // Mapping of wallet sales
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        private _walletSales;

    /**
     * @dev Sets editions contract using contract address upon construction.
     */
    constructor(address __editionsContractAddress) {
        _editionsContract = IEditions(__editionsContractAddress);
    }

    ////////////////////////////////////////////////////////////////////////////
    // MODIFIERS
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Checks if sale exists.
     *
     * Requirements:
     *
     * - `__id` must be of existing edition.
     */
    modifier onlyExistingSale(uint256 __tokenID, uint256 __saleID) {
        if (__saleID >= _sales[__tokenID].length) {
            revert SaleNotFound();
        }
        _;
    }

    ////////////////////////////////////////////////////////////////////////////
    // INTERNALS
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Used to complete purchase.
     *
     * Requirements:
     *
     * - `__tokenID` must be of existing edition.
     * - `__saleID` must be of existing sale.
     * - `__amount` plus current wallet sales cannot exceed wallet limit.
     * - `msg.value` must be correct price of sale.
     * - `block.timestampe` must be within sale timeframe.
     */
    function _buy(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __amount
    ) internal {
        Sale memory sale = _sales[__tokenID][__saleID];

        if (__amount > transactionLimit) revert AmountExceedsTransactionLimit();

        if (sale.walletLimit != 0) {
            if (
                _walletSales[__tokenID][__saleID][_msgSender()] + __amount >
                sale.walletLimit
            ) revert AmountExceedsWalletLimit();
        }

        if (sale.price * __amount != msg.value) {
            revert IncorrectPrice();
        }

        if (sale.start > 0 && block.timestamp < sale.start) {
            revert HasNotStarted();
        }

        if (sale.end > 0 && block.timestamp > sale.end) {
            revert HasEnded();
        }

        _walletSales[__tokenID][__saleID][_msgSender()] =
            _walletSales[__tokenID][__saleID][_msgSender()] +
            __amount;

        _editionsContract.mint(_msgSender(), __tokenID, __amount);
    }

    /**
     * @dev Used to verify merkle proof.
     *
     * Requirements:
     *
     * - Sale's `merkleRoot` must be set.
     */
    function _verifyProof(
        address __sender,
        uint256 __tokenID,
        uint256 __saleID,
        bytes32[] calldata __proof
    ) internal view {
        if (_sales[__tokenID][__saleID].merkleRoot == 0x0)
            revert MerkleRootNotSet();

        bool verified = MerkleProof.verify(
            __proof,
            _sales[__tokenID][__saleID].merkleRoot,
            keccak256(abi.encodePacked(__sender))
        );

        if (!verified) revert InvalidProof();
    }

    ////////////////////////////////////////////////////////////////////////////
    // ADMIN
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Used to create a new sale.
     *
     * Requirements:
     *
     * - `__tokenID` must be of existing edition.
     * - `__start` must be later than current time.
     * - `__start` must be earlier than `__end`.
     * - `__walletLimit` must be less or equal to max supply of edition.
     *
     * Emits a {SaleCreated} event.
     *
     */
    function createSale(
        uint256 __tokenID,
        uint256 __price,
        uint256 __start,
        uint256 __end,
        uint256 __walletLimit,
        bytes32 __merkleRoot
    ) external onlyOwner {
        if (!_editionsContract.editionExists(__tokenID)) {
            revert EditionNotFound();
        }

        if (__start > 0 && block.timestamp > __start) revert InvalidStart();

        if (__end > 0 && __start > __end) revert InvalidTimeframe();

        if (
            _editionsContract.maxSupply(__tokenID) > 0 &&
            __walletLimit > _editionsContract.maxSupply(__tokenID)
        ) revert LimitGreaterThanSupply();

        _sales[__tokenID].push(
            Sale({
                price: __price,
                start: __start,
                end: __end,
                walletLimit: __walletLimit,
                merkleRoot: __merkleRoot
            })
        );

        emit SaleCreated(__tokenID, _sales[__tokenID].length - 1);
    }

    ////////////////////////////////////////////////////////////////////////////
    // OWNER
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Used to update the merkle root of a sale.
     *
     * Emits a {SaleMerkleRootUpdated} event.
     *
     */
    function editMerkleRoot(
        uint256 __tokenID,
        uint256 __saleID,
        bytes32 __merkleRoot
    ) external onlyOwner onlyExistingSale(__tokenID, __saleID) {
        _sales[__tokenID][__saleID].merkleRoot = __merkleRoot;

        emit SaleMerkleRootUpdated(__tokenID, __saleID, __merkleRoot);
    }

    /**
     * @dev Used to update the price of a sale.
     *
     * Emits a {SalePriceUpdated} event.
     *
     */
    function editPrice(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __price
    ) external onlyOwner onlyExistingSale(__tokenID, __saleID) {
        _sales[__tokenID][__saleID].price = __price;

        emit SalePriceUpdated(__tokenID, __saleID, __price);
    }

    /**
     * @dev Used to update the start/end timeframe of a sale.
     *
     * Requirements:
     *
     * - Sale must not have already started.
     * - `__start` must be later than current time.
     * - `__start` must be earlier than sale end.
     *
     * Emits a {SaleStartUpdated} event.
     *
     */
    function editStart(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __start
    ) external onlyOwner onlyExistingSale(__tokenID, __saleID) {
        if (block.timestamp >= _sales[__tokenID][__saleID].start)
            revert HasStarted();

        if (__start > 0 && block.timestamp > __start) revert InvalidStart();

        if (
            _sales[__tokenID][__saleID].end > 0 &&
            __start > _sales[__tokenID][__saleID].end
        ) revert InvalidTimeframe();

        _sales[__tokenID][__saleID].start = __start;

        emit SaleStartUpdated(__tokenID, __saleID, __start);
    }

    /**
     * @dev Used to update the start/end timeframe of a sale.
     *
     * Requirements:
     *
     * - Sale must not have already ended.
     * - `__end` must be later than sale start.
     *
     * Emits a {SaleEndUpdated} event.
     *
     */
    function editEnd(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __end
    ) external onlyOwner onlyExistingSale(__tokenID, __saleID) {
        if (
            _sales[__tokenID][__saleID].end > 0 &&
            block.timestamp >= _sales[__tokenID][__saleID].end
        ) revert HasEnded();

        if (__end > 0 && _sales[__tokenID][__saleID].start > __end)
            revert InvalidTimeframe();

        _sales[__tokenID][__saleID].end = __end;

        emit SaleEndUpdated(__tokenID, __saleID, __end);
    }

    /**
     * @dev Used to update the wallet limit of a sale.
     *
     * Requirements:
     *
     * - `__walletLimit` must be less or equal to max supply of edition.
     *
     * Emits a {SaleWalletLimitUpdated} event.
     *
     */
    function editWalletLimit(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __walletLimit
    ) external onlyOwner onlyExistingSale(__tokenID, __saleID) {
        if (
            _editionsContract.maxSupply(__tokenID) > 0 &&
            __walletLimit > _editionsContract.maxSupply(__tokenID)
        ) revert LimitGreaterThanSupply();

        _sales[__tokenID][__saleID].walletLimit = __walletLimit;

        emit SaleWalletLimitUpdated(__tokenID, __saleID, __walletLimit);
    }

    /**
     * @dev Used to end a sale immediately.
     *
     * Requirements:
     *
     * - Sale must not have already ended.
     *
     * Emits a {SaleEndUpdated} event.
     *
     */
    function endSale(
        uint256 __tokenID,
        uint256 __saleID
    ) external onlyOwner onlyExistingSale(__tokenID, __saleID) {
        if (
            _sales[__tokenID][__saleID].end > 0 &&
            block.timestamp >= _sales[__tokenID][__saleID].end
        ) revert HasEnded();

        _sales[__tokenID][__saleID].end = block.timestamp;

        emit SaleEndUpdated(__tokenID, __saleID, block.timestamp);
    }

    /**
     * @dev Used to withdraw funds from the contract.
     */
    function setTransactionLimit(
        uint256 __transactionLimit
    ) external onlyOwner {
        transactionLimit = __transactionLimit;
    }

    /**
     * @dev Used to withdraw funds from the contract.
     */
    function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = owner().call{value: amount}("");

        if (!success) revert WithdrawFailed();
    }

    /**
     * @dev Used to withdraw all funds from the contract.
     */
    function withdrawAll() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");

        if (!success) revert WithdrawFailed();
    }

    ////////////////////////////////////////////////////////////////////////////
    // WRITES
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Buys an edition.
     */
    function buy(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __amount
    ) external payable nonReentrant onlyExistingSale(__tokenID, __saleID) {
        if (_sales[__tokenID][__saleID].merkleRoot != 0x0)
            revert ProofIsRequired();

        _buy(__tokenID, __saleID, __amount);
    }

    /**
     * @dev Buys an edition with a merkle proof.
     */
    function buyWithProof(
        uint256 __tokenID,
        uint256 __saleID,
        uint256 __amount,
        bytes32[] calldata __proof
    ) external payable nonReentrant onlyExistingSale(__tokenID, __saleID) {
        _verifyProof(_msgSender(), __tokenID, __saleID, __proof);

        _buy(__tokenID, __saleID, __amount);
    }

    ////////////////////////////////////////////////////////////////////////////
    // READS
    ////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Returns an edition sale.
     */
    function getSale(
        uint256 __tokenID,
        uint256 __saleID
    )
        external
        view
        onlyExistingSale(__tokenID, __saleID)
        returns (Sale memory)
    {
        return _sales[__tokenID][__saleID];
    }

    /**
     * @dev Returns number of wallet sales per edition.
     */
    function getWalletSales(
        address __account,
        uint256 __tokenID,
        uint256 __saleID
    ) external view onlyExistingSale(__tokenID, __saleID) returns (uint256) {
        return _walletSales[__tokenID][__saleID][__account];
    }

    /**
     * @dev Returns number of sales per edition.
     */
    function totalSales(uint256 __tokenID) external view returns (uint256) {
        return _sales[__tokenID].length;
    }
}