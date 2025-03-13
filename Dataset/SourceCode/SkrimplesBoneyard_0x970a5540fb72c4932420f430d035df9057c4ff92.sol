// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Skrimples.sol";

// Skrimples is the stinkiest, scrappiest pup in all of Shibarium. 
//
// The Boneyard is where Skrimples and his Ruffhouse Gang bury their tokens to earn $SKRIMP.
//
// Stake your $Skrimp to earn more!
//
// This staking contract is a safely modified rendition of MasterChef

contract SkrimplesBoneyard is AccessControl {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;



    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many tokens the user has pledged.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some genius math here. Basically, any point in time, the amount of Skrimples
        // entitled to a user, but pending distibution is:
        //
        // pending reward = (user.amount * pool.accSkrimplesPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws ptokens to a pool. Here's what happens:
        //   1. The pool's `accSkrimplesPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 pToken;           // Address of token contract.
        uint256 allocPoint;       // Allocation points assigned to this pool. Skrimples distributed per block.
        uint256 lastRewardBlock;  // Last block number that Skrimples distribution occurs.
        uint256 accSkrimplesPerShare; // Accumulated Skrimples per share, times 1e12. See below.
        uint256 totalStaked;     // Total number of tokens staked in pool
    }

    Skrimples public skrimples;
    // Dev address.
    address public devaddr;
    // Treasury address, where the rewards come from.
    address public treasury;
    // Block number when bonus Skrimples period ends.
    uint256 public bonusEndBlock;
    // Skrimples tokens created per block.
    uint256 public skrimplesPerBlock;
    // Bonus muliplier for early skrimples stakers.
    uint256 public constant BONUS_MULTIPLIER = 10;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when Skrimples mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);


    constructor(
        Skrimples _skrimples,
        address _devaddr,
        address _treasury,
        uint256 _skrimplesPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        skrimples = _skrimples;
        devaddr = _devaddr;
        treasury = _treasury;
        skrimplesPerBlock = _skrimplesPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;     
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new token to the pool. Can only be called by the owner.
    // DO NOT add the same token more than once. Rewards will be messed up if you do.
    function addToken(uint256 _allocPoint, IERC20 _pToken, bool _withUpdate) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            pToken: _pToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accSkrimplesPerShare: 0,         
            totalStaked: 0
        }));
    }

    // Update the given pool's Skrimples allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    // use the multiplier to reward early stakers
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    // View function to see pending Skrimples on frontend.
    function pendingSkrimples(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSkrimplesPerShare = pool.accSkrimplesPerShare;
        uint256 pSupply = pool.pToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && pSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 skrimplesReward = multiplier.mul(skrimplesPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accSkrimplesPerShare = accSkrimplesPerShare.add(skrimplesReward.mul(1e12).div(pSupply));
        }
        return user.amount.mul(accSkrimplesPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 pSupply = pool.pToken.balanceOf(address(this));
        if (pSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 skrimplesReward = multiplier.mul(skrimplesPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        skrimples.transferFrom(treasury, devaddr, skrimplesReward.div(10));
        skrimples.transferFrom(treasury, address(this), skrimplesReward);
        pool.accSkrimplesPerShare = pool.accSkrimplesPerShare.add(skrimplesReward.mul(1e12).div(pSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit tokens to SkrimpleBoneyard for Skrimples allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accSkrimplesPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeSkrimplesTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.pToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accSkrimplesPerShare).div(1e12);
        pool.totalStaked = pool.totalStaked.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw tokens from SkrimplesBoneyard.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSkrimplesPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeSkrimplesTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.pToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accSkrimplesPerShare).div(1e12);
        pool.totalStaked = pool.totalStaked.sub(_amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.pToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        pool.totalStaked = pool.totalStaked.sub(user.amount);
    }

   function updateSkrimplesPerBlock(
        uint256 _skrimplesPerBlock
    ) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not admin"
        );
        skrimplesPerBlock = _skrimplesPerBlock;
    }

    function updateBonusEndBlock(
        uint256 _bonusEndBlock
        ) external {
            require(
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
                "Caller is not admin"
            );
            bonusEndBlock = _bonusEndBlock;
        }


    // Safe Skrimples transfer function, just in case if rounding error causes pool to not have enough Skrimples.
    function safeSkrimplesTransfer(address _to, uint256 _amount) internal {
        uint256 skrimplesBal = skrimples.balanceOf(address(this));
        if (_amount > skrimplesBal) {
            skrimples.transfer(_to, skrimplesBal);
        } else {
            skrimples.transfer(_to, _amount);
        }
    }

    // Update dev address.
    function dev(address _devaddr) public {
        require(
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
                "Caller is not admin"
            );
        devaddr = _devaddr;
    }
    // Update treasury address.
    function updateTreasury(address _treasury) public {
        require(
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
                "Caller is not admin"
            );
        treasury = _treasury;
    }
}