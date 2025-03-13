//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;



/**



⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣾⣿⣿⣿⣿⣷⣶⣶⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠿⠿⠿⠿⠿⠿⢿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣤⣴⣶⣶⣶⣶⣦⣤⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣶⣶⣤⣤⣤⣤⣶⣶⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⡉⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⡇⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣽⡇⢸⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀

⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠈⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀

  _  _   __  ___  ____________ _____ _____   _____  _   _  ___________ 

 | || | / / / _ \ | ___ \ ___ \  _  |_   _| /  __ \| | | ||  ___|  ___|

/ __) |/ / / /_\ \| |_/ / |_/ / | | | | |   | /  \/| |_| || |__ | |_   

\__ \    \ |  _  ||    /|    /| | | | | |   | |    |  _  ||  __||  _|  

(   / |\  \| | | || |\ \| |\ \\ \_/ / | |   | \__/\| | | || |___| |    

 |_|\_| \_/\_| |_/\_| \_\_| \_|\___/  \_/    \____/\_| |_/\____/\_| V2   

                                                                       

                                                                       

    https://twitter.com/Karrot_gg 

 */

 

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

import "./interfaces/IRandomizer.sol";

import "./interfaces/IConfig.sol";

import "./interfaces/IKarrotsToken.sol";

import "./interfaces/IFullProtec.sol";

import "./interfaces/IStolenPool.sol";

import "./interfaces/IUniswapV2Router02.sol";

import "./interfaces/IUniswapV2Pair.sol";



contract KarrotChefV3 is Ownable, ReentrancyGuard {

    //=========================================================================

    // SETUP

    //=========================================================================

    using SafeERC20 for IERC20;

    using Address for address;



    uint256 public constant taxFreeRequestId = uint256(keccak256(abi.encodePacked("KARROT TAX EXEMPT (FOR COMPOUNDING)"))); //kek

    uint256 public constant REWARD_SCALING_FACTOR = 1e12;

    uint256 public constant KARROTS_DECIMALS = 1e18;



    struct UserInfo {

        uint256 amount; // How many LP tokens the user has provided.

        uint224 rewardDebt; // Reward debt. See explanation below.

        uint32 lockEndedTimestamp;

        //

        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt

        //

        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:

        //   1. The pool's `accRewardPerShare` (and `lastRewardBlock`) gets updated.

        //   2. User receives the pending reward sent to his/her address.

        //   3. User's `amount` gets updated.

        //   4. User's `rewardDebt` gets updated.

    }



    struct PoolInfo {

        IERC20 lpToken; // Address of LP token contract.

        uint128 allocPoint; // How many allocation points assigned to this pool. Rewards to distribute per block.

        uint32 lastRewardBlock; // Last block number that Rewards distribution occurs.

        uint96 accRewardPerShare; // Accumulated Rewards per share.

    }



    IConfig public config;



    uint16 public karrotClaimTaxRate = 2500; // 25%

    uint16 public fullProtecProtocolLiqProportion = 3200; // "33"%

    uint24 public requestNonce;

    uint40 public startBlock;    

    /**

     * @dev scales debase linearly, 

     * s.t. 1e13 = 0.001% (~6.7%/day) debase per block, 

     * 113 * 1e11 = 0.00113% (~7.5%/day) debase per block

     * 138 * 1e11 =  0.00138% (~9%/day) debase per block

     */

    uint48 public debaseMultiplier = 138 * 1e11; 

    uint64 public lastBlock;

    uint16 public constant PERCENTAGE_DENOMINATOR = 10000;



    uint8 public constant blockOffset = 1; //just to keep math safer maybe, so that user cant deposit on "block 0"

    uint88 public karrotRewardPerBlock = uint88(13_000_000 * KARROTS_DECIMALS); //13M karrots/block

    uint128 public totalAllocPoint = 0;



    bool public vaultDepositsAreOpen = false; //all vaults closed. (big/smol)

    bool public depositsPaused = false; //for pausing without resetting startblock



    /// @dev Info of each pool.

    PoolInfo[] public poolInfo;

    /// @dev Info of each user.

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    /// @dev user's withdrawable rewards

    mapping(uint256 => mapping(address => uint256)) private userRewards;

    /// @dev Lock duration in seconds

    mapping(uint256 => uint256) public lockDurations;



    // Events

    event SetDepositsEnabled(bool enabled);

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);

    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event RewardPaid(address indexed user, uint256 indexed pid, uint256 amount);

    event TaxPaid(address indexed user, uint256 indexed pid, uint256 amount);

    event SetRewardPerBlock(uint88 amount);

    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken);

    event SetAllocationPoint(uint256 indexed pid, uint256 allocPoint);

    event PoolUpdated(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);

    event SetLockDuration(uint256 indexed pid, uint256 lockDuration);

    event Claim(address indexed user, uint256 indexed pid, uint256 amount, uint256 tax);

    event RewardQueued(address _account, uint256 _pid, uint256 pending);

    event Compound(address indexed user, uint256 amountKarrot, uint256 poolId);

    event TaxRatioUpdate(address indexed user, uint256 indexed newUserTaxRatio);

    

    error InvalidAllowance();

    error EOAsOnly();

    error RabbitsPerWalletLimitReached();

    error NoPendingRewards(address user);

    error ForwardFailed();

    error CallerIsNotConfig();

    error VaultsDepositsAreClosed();

    error CallerIsNotAccountOrThisContract();

    error PoolExists();

    error InvalidAmount();

    error StillLocked();



    constructor(address _configManager) Ownable() ReentrancyGuard() {

        config = IConfig(_configManager);



        IERC20(config.karrotsAddress()).safeApprove(config.karrotStolenPoolAddress(), type(uint).max);



        //default lockDurations

        lockDurations[0] = 1 days;

        lockDurations[1] = 1 days;

    }



    modifier onlyConfig() {

        if (msg.sender != address(config)) {

            revert CallerIsNotConfig();

        }

        _;

    }



    //=========================================================================

    // ADMIN POOL ACTIONS

    //=========================================================================



    // Add a new lp to the pool. Can only be called by the owner.

    function addPool(uint128 _allocPoint, address _lpToken, bool _withUpdatePools) external onlyOwner {

        if(!lpTokenIsNotAlreadyAdded(_lpToken)){

            revert PoolExists();

        }

        if (_withUpdatePools) {

            massUpdatePools();

        }



        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;

        totalAllocPoint = totalAllocPoint + _allocPoint;

        poolInfo.push(

            PoolInfo({

                lpToken: IERC20(_lpToken),

                allocPoint: _allocPoint,

                lastRewardBlock: uint32(lastRewardBlock),

                accRewardPerShare: 0

            })

        );



        emit LogPoolAddition(poolInfo.length - 1, _allocPoint, IERC20(_lpToken));

    }



    // Update reward vairables for all pools. Be careful of gas spending!

    function massUpdatePools() public {

        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {

            updatePool(pid);

        }

    }



    function lpTokenIsNotAlreadyAdded(address _lpToken) internal view returns (bool) {

        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {

            if (address(poolInfo[pid].lpToken) == _lpToken) {

                return false;

            }

        }

        return true;

    }



    // Update reward variables of the given pool to be up-to-date.

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 lpSupply;



        if(address(pool.lpToken) == address(0)){

            return;

        }

        if (block.number <= pool.lastRewardBlock) {

            return;

        }

        

        if (address(pool.lpToken) == config.karrotsAddress()) {

            lpSupply = IKarrotsToken(config.karrotsAddress()).balanceOfUnderlying(address(this));

        } else {

            lpSupply = pool.lpToken.balanceOf(address(this));

        }



        if (lpSupply == 0) {

            pool.lastRewardBlock = uint32(block.number);

            return;

        }



        uint256 karrotsReward = Math.mulDiv(

            block.number - pool.lastRewardBlock,

            karrotRewardPerBlock * pool.allocPoint,

            totalAllocPoint

        );



        pool.accRewardPerShare += uint96(Math.mulDiv(karrotsReward, REWARD_SCALING_FACTOR, lpSupply));

        pool.lastRewardBlock = uint32(block.number);



        emit PoolUpdated(_pid, pool.lastRewardBlock, lpSupply, pool.accRewardPerShare);

    }



    //=========================================================================

    // USER ACTIONS

    //=========================================================================



    /// @dev Deposit tokens to KarrotsChef for Karrots allocation.

    /// @dev 1e18 in 1e24 out 

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {



        if (!vaultDepositsAreOpen || depositsPaused) {

            revert VaultsDepositsAreClosed();

        }



        if(_amount == 0){

            revert InvalidAmount();

        }



        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];

        

        if(pool.lpToken.allowance(msg.sender, address(this)) < _amount){

            revert InvalidAllowance();

        }        

        

        user.lockEndedTimestamp = uint32(block.timestamp + lockDurations[_pid]);

        

        updatePool(_pid);

        _queueRewards(_pid, msg.sender);



        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);



        /// @dev 1e18-->1e24

        if (address(pool.lpToken) == config.karrotsAddress()) {

            _amount = IKarrotsToken(config.karrotsAddress()).fragmentToKarrots(_amount);

        }

        /// @dev +n*1e24

        user.amount += _amount; 

        user.rewardDebt = uint224(Math.mulDiv(user.amount, pool.accRewardPerShare, REWARD_SCALING_FACTOR));



        emit Deposit(msg.sender, _pid, _amount);

        emit TaxRatioUpdate(msg.sender, getFullToChefRatio(msg.sender));



    }



    /// @dev Withdraw tokens from KarrotChef.

    /// @dev 1e24 in 1e18 out

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {

        if(_amount == 0){

            revert InvalidAmount();

        }

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];



        if(user.lockEndedTimestamp > block.timestamp){

            revert StillLocked();

        }



        if(_amount > user.amount){

            revert InvalidAmount();

        }



        updatePool(_pid);

        _queueRewards(_pid, msg.sender);



        //expects 1e24 value

        user.amount -= _amount; //-n*1e24

        user.rewardDebt = uint224((user.amount * pool.accRewardPerShare) / REWARD_SCALING_FACTOR);

        user.lockEndedTimestamp = uint32(block.timestamp) + uint32(lockDurations[_pid]);



        //1e24-->1e18

        if (address(pool.lpToken) == config.karrotsAddress()) {

            _amount = IKarrotsToken(config.karrotsAddress()).karrotsToFragment(_amount);

        }

        

        pool.lpToken.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _pid, _amount);

        emit TaxRatioUpdate(msg.sender, getFullToChefRatio(msg.sender));



    }



    function requestClaim(uint256 _pid) external payable nonReentrant {



        address sender = msg.sender;



        if (sender != tx.origin) {

            revert EOAsOnly();

        }



        updatePool(_pid);

        _queueRewards(_pid, sender);



        if (userRewards[_pid][sender] == 0) {

            revert NoPendingRewards(sender);

        }   



        uint256 randomNumber = IRandomizer(config.randomizerAddress()).getRandomNumber(

            sender,

            block.timestamp,

            requestNonce

        );



        (uint256 rewards, uint256 tax) = _claim(_pid, sender, randomNumber, requestNonce, false);

        ++requestNonce;



        emit Claim(sender, _pid, rewards, tax);

    }



    /// @dev claims pending karrot rewards in smol protec vault tax-free, then immediately deposits back into smol protec vault

    function compoundSmol() external {

        uint256 _randomNumber = 0;

        (uint256 rewards, ) = _claim(1, msg.sender, _randomNumber, taxFreeRequestId, true);

        deposit(1, rewards);

        emit Compound(msg.sender, rewards, 1);

    }





    //=========================================================================

    // INTERNAL WRITE FUNCTIONS

    //=========================================================================



    /// @dev Claim Karrots from KarrotChef

    function _claim(

        uint256 _pid,

        address _account,

        uint256 _randomNumber,

        uint256 _requestId,

        bool callerIsCompounder

    )

        internal

        returns (

            uint256,

            uint256

        )

    {

        uint256 tax = 0;



        //to avoid double queueing when calls are made through requestClaim

        if(_requestId == taxFreeRequestId){

            updatePool(_pid);

            _queueRewards(_pid, _account);

        }

        

        uint256 pendingRewards = userRewards[_pid][_account];

        if (pendingRewards == 0) {

            revert NoPendingRewards(_account);

        }



        IKarrotsToken karrots = IKarrotsToken(config.karrotsAddress());



        UserInfo storage user = userInfo[_pid][_account];

        user.lockEndedTimestamp = uint32(block.timestamp) + uint32(lockDurations[_pid]);



        userRewards[_pid][_account] = 0;

        userInfo[_pid][_account].rewardDebt = uint224(

            (userInfo[_pid][_account].amount * poolInfo[_pid].accRewardPerShare) /

            (REWARD_SCALING_FACTOR));



        if (lastBlock != block.number) {

            uint256 debaseIndexDelta = Math.mulDiv(block.number - lastBlock, debaseMultiplier, 1);

            karrots.rebase(block.number, debaseIndexDelta, false);

            lastBlock = uint64(block.number);

            IUniswapV2Pair(config.karrotsPoolAddress()).sync();

        }



        //[!] if user has enough deposited into the Full Protec Pool, no withdrawal tax

        //if they don't, there will be a 33% tax on their claim

        //the taxed amount will be sent to the stolen pool

        if (userIsExemptFromClaimTax(_account) || _requestId == taxFreeRequestId) {

            karrots.mint(_account, pendingRewards);

            emit RewardPaid(_account, _pid, pendingRewards);        

        } else {

            tax = Math.mulDiv(pendingRewards, karrotClaimTaxRate, PERCENTAGE_DENOMINATOR);

            karrots.mint(_account, pendingRewards - tax);

            

            IStolenPool(config.karrotStolenPoolAddress()).virtualDeposit(tax);



            emit TaxPaid(config.karrotStolenPoolAddress(), _pid, tax);  

            emit RewardPaid(_account, _pid, pendingRewards - tax);

        }

        

        return (pendingRewards, tax);

    }



    function _queueRewards(uint256 _pid, address _account) private {

        UserInfo storage user = userInfo[_pid][_account];

        uint256 pendingRewards = Math.mulDiv(user.amount, poolInfo[_pid].accRewardPerShare, REWARD_SCALING_FACTOR) - user.rewardDebt;

        if (pendingRewards > 0) {

            userRewards[_pid][_account] += pendingRewards;

        }

        emit RewardQueued(_account, _pid, pendingRewards);

    }



    //=========================================================================

    // GETTERS

    //=========================================================================



    function poolLength() external view returns (uint256) {

        return poolInfo.length;

    }



    // View function to see pending Karrots on frontend.

    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][_user];

        uint256 accRewardPerShare = pool.accRewardPerShare;

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (address(pool.lpToken) == config.karrotsAddress()) {

            lpSupply = IKarrotsToken(config.karrotsAddress()).balanceOfUnderlying(address(this));

        }

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {

            uint256 karrotsReward = (block.number - pool.lastRewardBlock) * Math.mulDiv(karrotRewardPerBlock, pool.allocPoint, totalAllocPoint);

            accRewardPerShare += (karrotsReward * REWARD_SCALING_FACTOR) / lpSupply;

        }

        return userRewards[_pid][_user] + (user.amount * accRewardPerShare / REWARD_SCALING_FACTOR) - user.rewardDebt;

    }

    

    ///@dev check both threshold karrot amount in full protec, and % of total karrots in all vaults in full protec to be above 33% (or n%)

    function userIsExemptFromClaimTax(address _user) public view returns (bool) {

        IFullProtec fullProtec = IFullProtec(config.karrotFullProtecAddress());

        

        bool thresholdCheck = fullProtec.getIsUserAboveThresholdToAvoidClaimTax(_user);

        

        uint256 karrotsInFullProtec = fullProtec.getUserStakedAmount(_user);

        uint256 karrotsInBigAndSmol = getBigAndSmolKarrotEquivalent(_user);



        if(karrotsInBigAndSmol == 0) return thresholdCheck;



        uint256 karrotsInFullProtecRatio = Math.mulDiv(karrotsInFullProtec, PERCENTAGE_DENOMINATOR, karrotsInBigAndSmol);

        bool ratioCheck = karrotsInFullProtecRatio > fullProtecProtocolLiqProportion;



        if(thresholdCheck && ratioCheck) {

            return true;

        }

        

        return false;

    }



    /// @dev for UI - output the ratio of full / smol+big(equivalent) which determines whether user is exempt

    function getFullToChefRatio(address _user) public view returns (uint256) {

        IFullProtec fullProtec = IFullProtec(config.karrotFullProtecAddress());

        uint256 karrotsInFullProtec = fullProtec.getUserStakedAmount(_user);

        uint256 karrotsInBigAndSmol = getBigAndSmolKarrotEquivalent(_user);

        if(karrotsInBigAndSmol == 0) return karrotsInFullProtec;

        return Math.mulDiv(karrotsInFullProtec, PERCENTAGE_DENOMINATOR, karrotsInBigAndSmol);

    }



    function getBigAndSmolKarrotEquivalent(address _user) public view returns (uint256) {

        uint256 bigProtecKarrotEquivalentAmount = getKarrotEquivalent(getTotalAmountStakedInPoolByUser(0, _user));

        uint256 smolProtecAmount = getTotalAmountStakedInPoolByUser(1, _user);

        return bigProtecKarrotEquivalentAmount + smolProtecAmount;

    }



    /**

     * @dev returns the amount of karrots corresponding to the given amount of LP tokens

     * @param _amount the amount of LP tokens to convert to karrots

     */

    function getKarrotEquivalent(uint256 _amount) public view returns (uint256) {

            

        if(_amount == 0) return 0;

        

        IUniswapV2Pair karrotsEthPool = IUniswapV2Pair(config.karrotsPoolAddress());

        uint256 totalLpTokenSupply = karrotsEthPool.totalSupply();

        (uint112 _reserve0, uint112 _reserve1, ) = karrotsEthPool.getReserves();

        address token0 = karrotsEthPool.token0();

        address token1 = karrotsEthPool.token1();



        uint256 tokenReserve = 0;

        if(token0 == config.karrotsAddress()){

            tokenReserve = uint256(_reserve0);

        } else if(token1 == config.karrotsAddress()){

            tokenReserve = uint256(_reserve1);

        }



        // Calculate the ERC20 token equivalent for the given _amount of LP tokens

        return Math.mulDiv(_amount, tokenReserve, totalLpTokenSupply);

    }



    

    /**

     * @dev gets converted (wallet-visible, 10^18 units) amounts for each pool

     * @param _user the user to get the amounts for

     * @param _pid the pool id to get the amounts for

     */

    function getTotalAmountStakedInPoolByUser(uint256 _pid, address _user) public view returns (uint256) {

        if(_pid == 1){

            return IKarrotsToken(config.karrotsAddress()).karrotsToFragment(userInfo[_pid][_user].amount);

        } else {

            return userInfo[_pid][_user].amount;

        }

    }



    /// @dev get the address of the token corresponding to each pool, so karrot-ETH LP (0), karrot (1)

    function poolIdToToken(uint256 _pid) external view returns (address) {

        return address(poolInfo[_pid].lpToken);

    }



    /// @dev get 10^24 units of the total amount of karrots staked in the given pool

    function getUserInfoAmount(address _user, uint256 _pid) external view returns (uint256) {

        return userInfo[_pid][_user].amount;

    }



    //=========================================================================

    // SETTERS (CONFIG MANAGER CONTROLLED)

    //=========================================================================



    // Update the given pool's Karrots allocation point. Can only be called by the config manager.

    function setAllocationPoint(uint256 _pid, uint128 _allocPoint, bool _withUpdatePools) external onlyConfig {

        if (_withUpdatePools) {

            massUpdatePools();

        }

        totalAllocPoint = totalAllocPoint - uint128(poolInfo[_pid].allocPoint) + _allocPoint;

        poolInfo[_pid].allocPoint = _allocPoint;

        emit SetAllocationPoint(_pid, _allocPoint);

    }



    function setLockDuration(uint256 _pid, uint256 _lockDuration) external onlyConfig {

        lockDurations[_pid] = _lockDuration;

        emit SetLockDuration(_pid, _lockDuration);

    }



    function updateRewardPerBlock(uint88 _rewardPerBlock) external onlyConfig {

        massUpdatePools();

        karrotRewardPerBlock = _rewardPerBlock;

        emit SetRewardPerBlock(_rewardPerBlock);

    }



    function setDebaseMultiplier(uint48 _debaseMultiplier) external onlyConfig {

        debaseMultiplier = _debaseMultiplier;

    }



    function openKarrotChefDeposits() external onlyConfig {

        startBlock = uint40(block.number - blockOffset);

        lastBlock = startBlock;

        vaultDepositsAreOpen = true;

        emit SetDepositsEnabled(true);

    }



    function setDepositIsPaused(bool _isPaused) external onlyConfig {

        depositsPaused = _isPaused;

        emit SetDepositsEnabled(_isPaused);

    }



    function setClaimTaxRate(uint16 _maxTaxRate) external onlyConfig {

        karrotClaimTaxRate = _maxTaxRate;

    }



    function setFullProtecLiquidityProportion(uint16 _fullProtecLiquidityProportion) external onlyConfig {

        fullProtecProtocolLiqProportion = _fullProtecLiquidityProportion;

    }



    function setConfigManagerAddress(address _configManagerAddress) external onlyOwner {

        config = IConfig(_configManagerAddress);

    }



}