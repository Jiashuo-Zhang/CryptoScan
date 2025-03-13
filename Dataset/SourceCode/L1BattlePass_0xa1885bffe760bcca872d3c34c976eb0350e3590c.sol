// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "./utils/NonblockingLzApp.sol";

import "./interfaces/IL1BattlePass.sol";

/**
 * @title L1 Battle Pass
 *
 * @author Jack Chuma
 *
 * @notice An eth mainnet portal contract allowing BattlePlan users to unlock
 * and re-roll their battle pass schedules hosted on L2.
 */
contract L1BattlePass is NonblockingLzApp, AccessControl, IL1BattlePass {
    using BitMaps for BitMaps.BitMap;

    // Role identifier for contract admin
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Current battle pass season (most state resets with each new season)
    uint256 public season;

    // Timestamp when season ends
    uint256 public seasonEndTimestamp;

    // Current price to unlock the premium battle pass track
    uint256 public price;

    // Chain ID that BattlePass is on
    uint16 public dstChainId;

    // Maximum amount of paid unlocks in a season
    uint256 public maxPaidUnlocks;

    // Encoded adapter params for LayerZero config
    bytes public adapterParams;

    // Re-roll count => price in eth
    mapping(uint256 => uint256) public scheduleRollPrice;

    // Season => paid unlock count
    mapping(uint256 => uint256) public paidUnlocks;

    // Address => Season => isUnlocked
    mapping(address => BitMaps.BitMap) unlocked;

    // Address => season => reRoll count
    mapping(address => mapping(uint256 => uint256)) public reRollCount;

    constructor(
        address _endpoint,
        uint16 _dstChainId
    ) NonblockingLzApp(_endpoint) {
        dstChainId = _dstChainId;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    receive() external payable {}

    /**
     * @notice Returns `true` if the user has unlocked the premium pass for the specified season.
     *
     * @param _account Player wallet address
     * @param _season BattlePass season number
     */
    function getUnlocked(
        address _account,
        uint256 _season
    ) public view returns (bool) {
        return unlocked[_account].get(_season);
    }

    /**
     * @notice Admin function to withdraw accumulated eth
     *
     * @param _to Address to send eth to
     */
    function withdraw(address _to) external onlyRole(ADMIN_ROLE) {
        require(_to != address(0), "L1BP: Zero address");

        uint256 _amount = address(this).balance;

        require(_amount > 0, "L1BP: Zero amount");

        (bool _sent, ) = _to.call{value: _amount}("");
        require(_sent, "L1BP: Transfer failed");

        emit EthWithdrawn(_to, _amount);
    }

    /**
     * @notice Admin function to set a new unlock price
     *
     * @param _price Battle Pass unlock price
     */
    function setPrice(uint256 _price) external onlyRole(ADMIN_ROLE) {
        price = _price;
        emit PriceSet(season, _price);
    }

    /**
     * @notice Admin function to set a new destination chain ID
     *
     * @param _chainId New destincation chain ID
     */
    function setDstChainId(uint16 _chainId) external onlyRole(ADMIN_ROLE) {
        dstChainId = _chainId;
        emit DstChainIdSet(_chainId);
    }

    /**
     * @notice Admin function to set the max paid unlocks
     *
     * @param _max Maximum amount of paid unlocks allowed
     */
    function setMaxPaidUnlocks(uint256 _max) external onlyRole(ADMIN_ROLE) {
        maxPaidUnlocks = _max;
        emit MaxPaidUnlocksSet(_max);
    }

    /**
     * @notice Admin function to update adapter params for layer zero config
     *
     * @param _params Encoded LayerZero adapter params
     */
    function setAdapterParams(
        bytes calldata _params
    ) external onlyRole(ADMIN_ROLE) {
        adapterParams = _params;
        emit AdapterParamsSet(_params);
    }

    /**
     * @notice Admin function to declare the price to re-roll
     *
     * @param _counts Array of roll counts
     * @param _prices Array of prices in eth
     */
    function setScheduleRollPrices(
        uint256[] calldata _counts,
        uint256[] calldata _prices
    ) external onlyRole(ADMIN_ROLE) {
        require(_counts.length > 0, "L1BP: ZeroLength");
        require(_counts.length == _prices.length, "L1BP: LengthMismatch");

        for (uint256 i; i < _counts.length; ) {
            scheduleRollPrice[_counts[i]] = _prices[i];
            unchecked {
                i++;
            }
        }

        emit ScheduleRollPricesSet(_counts, _prices);
    }

    /**
     * @notice Admin function to start a new battlepass season
     *
     * @param _price BattlePass price for the new season
     * @param _maxPaidUnlocks Max paid unlocks for the new season
     * @param _duration Length of season in seconds
     */
    function newSeason(
        uint256 _price,
        uint256 _maxPaidUnlocks,
        uint256 _duration
    ) external onlyRole(ADMIN_ROLE) {
        unchecked {
            uint256 _newSeason = ++season;
            price = _price;
            maxPaidUnlocks = _maxPaidUnlocks;
            seasonEndTimestamp = block.timestamp + _duration;
            emit NewSeasonStarted(
                _newSeason,
                _duration,
                _price,
                _maxPaidUnlocks
            );
        }
    }

    /**
     * @notice Admin function to update the season end timestamp
     *
     * @param _timestamp Timestamp for season to end at
     */
    function updateSeasonEndTimestamp(
        uint256 _timestamp
    ) external onlyRole(ADMIN_ROLE) {
        seasonEndTimestamp = _timestamp;
        emit SeasonEndTimestampUpdated(season, _timestamp);
    }

    /**
     * @notice Returns the LayerZero fee estimate to carry out the cross-chain tx.
     *
     * @param _account Player wallet address
     * @param _txType Specifies which transaction type to estimate
     */
    function estimateFee(
        address _account,
        TxType _txType
    ) external view returns (uint256 _fee) {
        bytes memory payload = abi.encode(_account, _txType);

        (_fee, ) = lzEndpoint.estimateFees(
            dstChainId,
            address(this),
            payload,
            false,
            adapterParams
        );
    }

    /**
     * @notice Unlocks a premium BattlePass track on L2 for `msg.sender`
     */
    function unlock() external payable {
        require(!getUnlocked(msg.sender, season), "L1BP: Already unlocked");
        require(paidUnlocks[season] < maxPaidUnlocks, "L1BP: No more unlocks");
        require(msg.value > price, "L1BP: Low msgvalue");

        unchecked {
            paidUnlocks[season]++;
            unlocked[msg.sender].set(season);
        }

        _send(TxType.UNLOCK, price);
    }

    /**
     * @notice Requests a new entropy to be associated with `msg.sender`'s BattlePass token on L2
     */
    function reRoll() external payable {
        uint256 _reRollCount;
        unchecked {
            _reRollCount = ++reRollCount[msg.sender][season];
        }

        uint256 _price = scheduleRollPrice[_reRollCount];
        require(msg.value > _price, "L1BP: Low msgvalue");

        _send(TxType.REROLL, _price);
    }

    /**
     * @dev All receive transactions are blocked.
     */
    function _nonblockingLzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory
    ) internal pure override {
        require(false, "No receive allowed");
    }

    function _send(TxType _txType, uint256 _price) private {
        bytes memory payload = abi.encode(msg.sender, _txType);

        // send LayerZero message
        _lzSend( // {value: messageFee} will be paid out of this contract!
            dstChainId, // destination chainId
            payload, // abi.encode()'ed bytes
            payable(address(this)), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send())
            address(0x0), // future param, unused for this example
            adapterParams, // v1 adapterParams, specify custom destination gas qty
            msg.value - _price
        );

        uint256 _nonce = lzEndpoint.getOutboundNonce(dstChainId, address(this));

        emit MessageSent(_nonce, msg.sender, season, _txType);
    }
}