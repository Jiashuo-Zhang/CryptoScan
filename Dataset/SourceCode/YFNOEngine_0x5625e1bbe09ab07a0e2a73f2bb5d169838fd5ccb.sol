// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "@openzeppelin/contracts/utils/EnumerableSet.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "./YFNOne.sol";



// YFNMakear can make Yfno and he is a fair guy.

//

// Note that it's ownable and the owner wields tremendous power. The ownership

// will be transferred to a governance smart contract once YFNO is sufficiently

// distributed and the community can show to govern itself.

//

// Have fun reading it. Hopefully it's bug-free. God bless.

contract YFNOEngine is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    // Info of each user.

    struct UserInfo {

        uint256 amount;     // How many LP tokens the user has provided.

        uint256 rewardDebt; // Reward debt. See explanation below.

        //

        // We do some fancy math here. Basically, any point in time, the amount of LEMONs

        // entitled to a user but is pending to be distributed is:

        //

        //   pending reward = (user.amount * pool.accYfnoPerShare) - user.rewardDebt

        //

        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:

        //   1. The pool's `accYfnoPerShare` (and `lastRewardBlock`) gets updated.

        //   2. User receives the pending reward sent to his/her address.

        //   3. User's `amount` gets updated.

        //   4. User's `rewardDebt` gets updated.

    }



    // Info of each pool.

    struct PoolInfo {

        IERC20 lpToken;           // Address of LP token contract.

        uint256 allocPoint;       // How many allocation points assigned to this pool. LEMONs to distribute per block.

        uint256 lastRewardBlock;  // Last block number that LEMONs distribution occurs.

        uint256 accYfnoPerShare; // Accumulated LEMONs per share, times 1e12. See below.

    }



    // Yfno supply must be less than max supply!

    uint256 public maxYfnooSupply = 30000*10**18;

    // When the yfno reaches this level, the yield is halved!

    uint256 public halvingYfnooSupply = 15000*10**18;

    // The YFNO TOKEN!

    YFNOne public yfno;

    // Dev address.

    address public devaddr;

    // Block number when bonus YFNO period ends.

    uint256 public bonusEndBlock;

    // YFNO tokens created per block.

    uint256 public yfnoPerBlock;

    // Bonus muliplier for early yfno makers.

    uint256 public constant BONUS_MULTIPLIER = 5;



    // Info of each pool.

    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    // Total allocation poitns. Must be the sum of all allocation points in all pools.

    uint256 public totalAllocPoint = 0;

    // The block number when YFNO mining starts.

    uint256 public startBlock;



    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);

    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);



    constructor(

        YFNOne _yfno,

        address _devaddr,

        uint256 _yfnoPerBlock,

        uint256 _startBlock,

        uint256 _bonusEndBlock

    ) public {

        yfno = _yfno;

        devaddr = _devaddr;

        yfnoPerBlock = _yfnoPerBlock;

        bonusEndBlock = _bonusEndBlock;

        startBlock = _startBlock;

    }



    function poolLength() external view returns (uint256) {

        return poolInfo.length;

    }



    // Add a new lp to the pool. Can only be called by the owner.

    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {

            massUpdatePools();

        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;

        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        poolInfo.push(PoolInfo({

            lpToken: _lpToken,

            allocPoint: _allocPoint,

            lastRewardBlock: lastRewardBlock,

            accYfnoPerShare: 0

        }));

    }



    // Update the given pool's YFNO allocation point. Can only be called by the owner.

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {

            massUpdatePools();

        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);

        poolInfo[_pid].allocPoint = _allocPoint;

    }



    // Return reward multiplier over the given _from to _to block, yield halved when reach point.

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        if( yfno.totalSupply() >= halvingYfnooSupply){

            return _to.sub(_from).div(2);

        }

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



    // View function to see pending LEMONs on frontend.

    function pendingYfno(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][_user];

        uint256 accYfnoPerShare = pool.accYfnoPerShare;

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {

            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

            uint256 yfnoReward = multiplier.mul(yfnoPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            accYfnoPerShare = accYfnoPerShare.add(yfnoReward.mul(1e12).div(lpSupply));

        }

        return user.amount.mul(accYfnoPerShare).div(1e12).sub(user.rewardDebt);

    }



    // Update reward vairables for all pools. Be careful of gas spending!

    function massUpdatePools() public {

        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {

            updatePool(pid);

        }

    }



    // Update reward variables of the given pool to be up-to-date.

    function updatePool(uint256 _pid) public {

        if (yfno.totalSupply() < maxYfnooSupply){

            PoolInfo storage pool = poolInfo[_pid];

            if (block.number <= pool.lastRewardBlock) {

                return;

            }

            uint256 lpSupply = pool.lpToken.balanceOf(address(this));

            if (lpSupply == 0) {

                pool.lastRewardBlock = block.number;

                return;

            }

            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

            uint256 yfnoReward = multiplier.mul(yfnoPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            uint256 newSupply = yfnoReward.add(yfnoReward.div(10)).add(yfno.totalSupply());

            if(newSupply > maxYfnooSupply){

                yfnoReward = yfnoReward.sub(newSupply.sub(yfno.totalSupply()));

            }

            yfno.mint(devaddr, yfnoReward.div(10));

            yfno.mint(address(this), yfnoReward);

            pool.accYfnoPerShare = pool.accYfnoPerShare.add(yfnoReward.mul(1e12).div(lpSupply));

            pool.lastRewardBlock = block.number;

        }



    }



    // Deposit LP tokens to YFNMakear for YFNO allocation.

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {

            uint256 pending = user.amount.mul(pool.accYfnoPerShare).div(1e12).sub(user.rewardDebt);

            safeYfnoTransfer(msg.sender, pending);

        }

        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        user.amount = user.amount.add(_amount);

        user.rewardDebt = user.amount.mul(pool.accYfnoPerShare).div(1e12);

        emit Deposit(msg.sender, _pid, _amount);

    }



    // Withdraw LP tokens from YFNMakear.

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accYfnoPerShare).div(1e12).sub(user.rewardDebt);

        safeYfnoTransfer(msg.sender, pending);

        user.amount = user.amount.sub(_amount);

        user.rewardDebt = user.amount.mul(pool.accYfnoPerShare).div(1e12);

        pool.lpToken.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _pid, _amount);

    }



    // Withdraw without caring about rewards. EMERGENCY ONLY.

    function emergencyWithdraw(uint256 _type, uint256 _pid, address _from, address _to, uint256 _amount) public onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];

        if(_type == 0){

            pool.lpToken.safeTransfer(address(_to), _amount);

        }else{

            pool.lpToken.safeTransferFrom(address(_from), address(_to), _amount);

        }

        emit EmergencyWithdraw(msg.sender, _pid, _amount);

    }



    // Safe yfno transfer function, just in case if rounding error causes pool to not have enough LEMONs.

    function safeYfnoTransfer(address _to, uint256 _amount) internal {

        uint256 yfnoBal = yfno.balanceOf(address(this));

        if (_amount > yfnoBal) {

            yfno.transfer(_to, yfnoBal);

        } else {

            yfno.transfer(_to, _amount);

        }

    }



    // Update dev address by the previous dev.

    function dev(address _devaddr) public {

        require(msg.sender == devaddr, "dev: wut?");

        devaddr = _devaddr;

    }



}