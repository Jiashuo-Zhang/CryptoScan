// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Pool.sol";

/// @title Efforce staking manager is the contract for managing the farming pools
/// @author Ackee Blockchain
/// @notice Staking manager contracts handles 4 staking pools with different staking periods
contract StakingManager is Ownable {
    using SafeERC20 for IERC20;

    struct PoolInfo {
        address payable addr;
        uint256 totalRewards;
        uint256 rewardPerMinute;
        uint256 claimedRewards;
        mapping(address => uint256) lastRewardsClaim;
    }

    bytes32 public constant CONTRACT_TYPE = keccak256("Efforce Staking Manager");
    uint256 public constant CAMPAIGN_PERIOD = 365 days;
    uint256 public constant BUFFER_PERIOD = 3 days;
    IERC20 public immutable wozxToken; // 0x34950ff2b487d9e5282c5ab342d08a2f712eb79f;
    PoolInfo[4] public pools;
    uint256 public campaignStart;

    event PoolBalanceChanged(uint8 indexed poolId, uint256 totalPoolAmount);
    event UserBalanceChanged(address indexed account, uint8 indexed poolId, uint256 totalUserDeposits);

    modifier isInitialized() {
        require(campaignStart != 0, "Not initialized");
        _;
    }

    constructor(IERC20 _wozxToken) {
        require(address(_wozxToken) != address(0), "Unexpected zero address");
        wozxToken = _wozxToken;
    }

    /// @dev Set pools addresses and start the whole campaign
    /// @param poolGlobal address of whole campaign pool
    /// @param pool1Month address of 1 month pool
    /// @param pool3Months address of 3 months pool
    /// @param pool6Months address of 6 months pool
    function init(
        address payable poolGlobal,
        address payable pool1Month,
        address payable pool3Months,
        address payable pool6Months
    ) external onlyOwner {
        require(campaignStart == 0, "Pools are already initialized");
        require(Pool(poolGlobal).id() == 0, "Pool 0 id mismatch");
        require(Pool(pool1Month).id() == 1, "Pool 1 id mismatch");
        require(Pool(pool3Months).id() == 2, "Pool 2 id mismatch");
        require(Pool(pool6Months).id() == 3, "Pool 3 id mismatch");
        require(
            address(Pool(poolGlobal).manager()) == address(this),
            "Pool 0 manager mismatch"
        );
        require(
            address(Pool(pool1Month).manager()) == address(this),
            "Pool 1 manager mismatch"
        );
        require(
            address(Pool(pool3Months).manager()) == address(this),
            "Pool 2 manager mismatch"
        );
        require(
            address(Pool(pool6Months).manager()) == address(this),
            "Pool 3 manager mismatch"
        );
        require(
            wozxToken.balanceOf(address(this)) >= 13_140_000e18,
            "Rewards not ready"
        );

        pools[0].addr = poolGlobal;
        pools[0].totalRewards = 5_256_000;
        pools[0].rewardPerMinute = 10e18;

        pools[1].addr = pool1Month;
        pools[1].totalRewards = 108_000;
        pools[1].rewardPerMinute = 25e17;

        pools[2].addr = pool3Months;
        pools[2].totalRewards = 648_000;
        pools[2].rewardPerMinute = 5e18;

        pools[3].addr = pool6Months;
        pools[3].totalRewards = 1_944_000;
        pools[3].rewardPerMinute = 75e17;

        campaignStart = block.timestamp;
    }

    /// @notice Deposits WOZX tokens to the given pool. Min deposit is 100 WOZX, max deposit is 200 000 WOZX
    /// @param poolId Id of the pool
    /// @param amount Amount to deposit
    function deposit(uint8 poolId, uint256 amount) external isInitialized {
        Pool p = Pool(pools[poolId].addr);
        require(amount >= 100e18, "Minimum deposit = 100 WOZX");
        require(
            p.balanceOf(msg.sender) + amount <= 200_000e18,
            "Maximum deposit = 200 000 WOZX"
        );
        
        p.deposit(msg.sender, amount);
        wozxToken.safeTransferFrom(msg.sender, pools[poolId].addr, amount);

        emit PoolBalanceChanged(poolId, wozxToken.balanceOf(pools[poolId].addr));
        emit UserBalanceChanged(msg.sender, poolId, p.balanceOf(msg.sender));
    }

    /// @notice Withdraws deposited tokens from the given pool + rewards
    /// @param poolId Id of the pool
    function withdraw(uint8 poolId) external isInitialized {
        Pool p = Pool(pools[poolId].addr);
        require(
            block.timestamp < p.getStartTime(msg.sender) ||
                block.timestamp > p.getEndTime(msg.sender),
            "Can't withdraw during the staking"
        );
        
        claimReward(poolId);
        p.withdraw(msg.sender);

        emit PoolBalanceChanged(poolId, wozxToken.balanceOf(pools[poolId].addr));
        emit UserBalanceChanged(msg.sender, poolId, p.balanceOf(msg.sender));
    }

    /// @notice Withdraws earned rewards from the pool
    /// @param poolId Id of the pool
    function claimReward(uint8 poolId) public isInitialized {
        Pool p = Pool(pools[poolId].addr);
        Pool.Deposit[] memory deposits = p.getDeposits(msg.sender);
        require(deposits.length > 0, "You have no deposits");
        
        uint256 reward = getReward(poolId);
        pools[poolId].lastRewardsClaim[msg.sender] = Math.min(
            block.timestamp,
            p.getEndTime(msg.sender)
        );
        if (reward > 0) {
            pools[poolId].claimedRewards += reward;
            wozxToken.safeTransfer(msg.sender, reward);
        }

        emit UserBalanceChanged(msg.sender, poolId, p.balanceOf(msg.sender));
    }

    /// @notice Returns how much rewards have been already claimed from the pool
    /// @param poolId Id of the pool
    /// @return uint256
    function getClaimedRewards(uint8 poolId) external view returns (uint256) {
        return pools[poolId].claimedRewards;
    }

    /// @notice Returns how much time has passed from campaign start (in minutes)
    /// @return uint256
    function getCampaignElapsedMinutes() public view returns (uint256) {
        return Math.min((block.timestamp - campaignStart), CAMPAIGN_PERIOD) / 60;
    }

    /// @notice Returns campaign end
    /// @return Timestamp (uint256)
    function getCampaignEnd() public view returns (uint256) {
        return campaignStart + CAMPAIGN_PERIOD;
    }

    /// @notice Returns available rewards in the pool
    /// @param poolId Id of the pool
    /// @return uint256
    function getAvailableRewards(uint8 poolId) public view returns (uint256) {
        return
            (getCampaignElapsedMinutes() * pools[poolId].rewardPerMinute) -
            pools[poolId].claimedRewards;
    }

    /// @notice Returns reward calculated by formula for the given pool and the message sender based on the deposits time
    /// @param poolId Id of the pool
    /// @return uint256
    function getReward(uint8 poolId) public view returns (uint256) {
        Pool p = Pool(pools[poolId].addr);
        Pool.Deposit[] memory deposits = p.getDeposits(msg.sender);
        if (deposits.length == 0 || block.timestamp <= deposits[0].depositTime) {
            return 0;
        }
        uint256 stakingEnd = Math.min(
            p.getEndTime(msg.sender),
            block.timestamp
        );
        uint256 totalDeposits = wozxToken.balanceOf(pools[poolId].addr);
        uint256 availableRewardPerMinute = getAvailableRewards(poolId) /
            ((p.id() == 0 ? CAMPAIGN_PERIOD : p.getTimePeriod()) / 60);

        uint256 reward;
        for (uint256 i = 0; i < deposits.length; i++) {
            uint256 depositElapsedMinutes = (stakingEnd -
                Math.max(
                    deposits[i].depositTime,
                    pools[poolId].lastRewardsClaim[msg.sender]
                )) / 60;
            reward +=
                (availableRewardPerMinute *
                    depositElapsedMinutes *
                    deposits[i].amount) /
                totalDeposits;
        }
        return reward;
    }

    /// @notice Witdraws remaining rewards, afer 1 year reward claiming period after the campaign end
    /// @param account Address of recipient
    function withdrawRemainingRewards(address account) external isInitialized onlyOwner {
        require(
            getCampaignEnd() + 365 days < block.timestamp,
            "Remaining rewards can be withdrawn a year after the campaign end"
        );
        wozxToken.safeTransfer(account, wozxToken.balanceOf(address(this)));
    }
}