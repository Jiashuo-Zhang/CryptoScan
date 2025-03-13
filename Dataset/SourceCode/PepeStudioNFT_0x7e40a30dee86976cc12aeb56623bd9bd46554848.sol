// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/Address.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

error MintPriceNotPaid();
error NonExistentTokenURI();
error WithdrawTransfer();
error NotEnoughPepe();
error TransferStakedNFT();

contract PepeStudioNFT is ERC721, ReentrancyGuard, Ownable {
    using Strings for uint256;
    string public baseURI;
    IERC20 public immutable pepeToken;
    IERC20 public immutable pepeStudioToken;
    IUniswapV2Pair public immutable uniswapV2Pair;
    uint256 public currentTokenId;
    uint256 public BASE_MINT_PRICE = 10_000_000 ether;
    address public dev;
    
    // referral reward pool
    mapping(address => uint256) public referralRewards;
    mapping(address => uint256) public nextWithdrawTime;

    // emission rate
    uint256 public constant EMISSION_RATE = 200_000 ether; // 200,000 PEPESTUDIO per block
    uint256 public totalStakedNFTs;

    // burn address
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // Each pepe studio nft has a rarity level
    enum RarityLevel {
        COMMON,
        RARE,
        EPIC,
        LEGENDARY
    }
    struct NFTMetadata {
        uint256 stakedAt;
        uint256 hashRate;
        RarityLevel rarityLevel;
        bool isStaked;
    }
    mapping(uint256 => NFTMetadata) public metadata;

    // Info of each user.
    struct UserInfo {
        uint256 hashRate; // How many hash rate the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256[] stakedNFTs;
        //
        // We do some fancy math here. Basically, any point in time, the amount of PEPESTUDIO
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPepestudioPerShare) - user.rewardDebt
        //
        // Whenever a user stake or unstake NFT to a pool. Here's what happens:
        //   1. The pool's `accPepestudioPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 currentHashRate; // Current hash rate in this pool
        uint256 minimumHashRate; // Minimum hash rate required to stake
        uint256 maximumHashRate; // Maximum hash rate allowed to stake
        uint256 stakeTime; // Minimum time required to stake
        uint256 allocPoint; // How many allocation points assigned to this pool. PEPESTUDIO to distribute per block.
        uint256 lastRewardBlock; // Last block number that PEPESTUDIO distribution occurs.
        uint256 accPepeStudioPerShare; // Accumulated PEPESTUDIO per share, times 1e12. See below.
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes Pepe Studio NFT.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when PEPESTUDIO mining starts.
    uint256 public startStakingBlock;
    // The block number when PEPESTUDIO NFT minting starts.
    uint256 public startMintBlock;

    event ReferralRegistered(address indexed referrer, address indexed referee, uint256 tokenId);
    event WithdrawReferralReward(address indexed referrer, uint256 amount);
    event Stake(uint256 indexed tokenId);
    event Unstake(uint256 indexed tokenId, uint256 stakedAtTimestamp, uint256 removedFromStakeAtTimestamp);
    event EmergencyUnstake(address indexed user, uint256 indexed pid, uint256[] nfts);

    /**
        * @dev Throws if called by any contract.
     */
    modifier notContract() {
        require(!Address.isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
        * @dev Modifier to make a function callable only when the minting has started.
     */
    modifier startMint() {
        require(block.number >= startMintBlock, "minting has not started yet");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the staking has started.
     */
    modifier startStake() {
        require(block.number >= startStakingBlock, "staking has not started yet");
        _;
    }

    /**
        * @dev Constructor of the contract.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _pepeToken,
        address _pepeStudioToken,
        address _uniswapV2Factory,
        uint256 _startStakingBlock,
        uint256 _startMintBlock
    ) ERC721(_name, _symbol) Ownable() {
        dev = msg.sender;
        baseURI = _baseURI;
        pepeToken = IERC20(_pepeToken);
        pepeStudioToken = IERC20(_pepeStudioToken);
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(_uniswapV2Factory);
        // Create a uniswap pair for PEPESTUDIO/PEPE token
        uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.createPair(_pepeStudioToken, _pepeToken));

        // Set the start staking block
        startStakingBlock = _startStakingBlock;
        // Set the start mint block
        startMintBlock = _startMintBlock;

        // Create a staking pool for common NFT, with 3x allocation point and stake time is 7 days
        poolInfo.push(
            PoolInfo({
                currentHashRate: 0,
                minimumHashRate: 0,
                maximumHashRate: 0,
                stakeTime: 0,
                allocPoint: 0,
                lastRewardBlock: _startStakingBlock,
                accPepeStudioPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                currentHashRate: 0,
                minimumHashRate: 0,
                maximumHashRate: 100000,
                stakeTime: 9 days,
                allocPoint: 300,
                lastRewardBlock: _startStakingBlock,
                accPepeStudioPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                currentHashRate: 0,
                minimumHashRate: 100000,
                maximumHashRate: 200000,
                stakeTime: 10 days,
                allocPoint: 200,
                lastRewardBlock: _startStakingBlock,
                accPepeStudioPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                currentHashRate: 0,
                minimumHashRate: 0,
                maximumHashRate: 200000,
                stakeTime: 7 days,
                allocPoint: 500,
                lastRewardBlock: _startStakingBlock,
                accPepeStudioPerShare: 0
            })
        );

        totalAllocPoint = 1000;
    }

    // Function to calculate NFT minting price
    function calculateMintingPrice(uint256 _tokenId) internal view returns (uint256) {
        // for every 1000 token minted, increase 3% of the minting price
        return BASE_MINT_PRICE * (100 + (_tokenId / 1000) * 3) / 100;
    }

    function getMintingPrice() public view returns (uint256) {
        return calculateMintingPrice(currentTokenId + 1);
    }

    // change dev address
    function changeDev(address _dev) public {
        require(msg.sender == dev, "Only dev can change dev address");
        dev = _dev;
    }


    function randomInRange(uint256 min, uint256 max, uint256 nonce) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, nonce)
                )
            ) % (max - min) + min;
    }

    function mintUsingPEPE(address recipient, uint256 quantity, address referrer) public startMint notContract {
        // calculate and update new minting price
        uint256 mintingPrice = calculateMintingPrice(currentTokenId + 1);
        if(mintingPrice > BASE_MINT_PRICE) {
            BASE_MINT_PRICE = mintingPrice;
        }

        // Send the pepe token, to save gas, we will not calculate the minting price increase in case of multiple minting
        pepeToken.transferFrom(msg.sender, address(this), mintingPrice * quantity);

        // reward to referrer
        if (referrer != address(0) && referrer != msg.sender) {
            uint256 referrerReward = mintingPrice * quantity / 20; // 5%
            referralRewards[referrer] += referrerReward;
        }

        for(uint256 i = 0; i < quantity; i++) {
            uint256 newTokenId = ++currentTokenId;
            // calculate the rarity level using randomness, 68.75% is common, 19.25% is rare, 10,25% is epic, 1,75% is legendary
            uint256 randomNumber = randomInRange(0, 10000, newTokenId);
            uint256 hashRate;
            RarityLevel rarityLevel;
            if (randomNumber < 6875) {
                rarityLevel = RarityLevel.COMMON;
                hashRate = randomInRange(10000, 100000, block.number * (i + 1));
            } else if (randomNumber < 8700) {
                rarityLevel = RarityLevel.RARE;
                hashRate = randomInRange(20000, 100000, block.number * (i + 1));
            } else if (randomNumber < 9800) {
                rarityLevel = RarityLevel.EPIC;
                hashRate = randomInRange(30000, 100000, block.number * (i + 1));
            } else {
                rarityLevel = RarityLevel.LEGENDARY;
                hashRate = randomInRange(1, 200000, block.number * (i + 1));
            }
            metadata[newTokenId] = NFTMetadata({
                rarityLevel: rarityLevel,
                hashRate: hashRate,
                stakedAt: 0,
                isStaked: false
            });
            _safeMint(recipient, newTokenId);
            emit ReferralRegistered(referrer, recipient, newTokenId);
        }
    }

    function mintUsingPEPEStudio(address recipient, uint256 quantity) public startMint notContract {
        // calculate and update new minting price
        uint256 mintingPrice = calculateMintingPrice(currentTokenId + 1);
        if(mintingPrice > BASE_MINT_PRICE) {
            BASE_MINT_PRICE = mintingPrice;
        }

        // Send the pepe token
        pepeStudioToken.transferFrom(msg.sender, address(this), mintingPrice * quantity);

        // burn the pepe studio token
        pepeStudioToken.burn(mintingPrice * quantity);

        for(uint256 i = 0; i < quantity; i++) {
            uint256 newTokenId = ++currentTokenId;
            // calculate the rarity level using randomness, 68.75% is common, 19.25% is rare, 10,25% is epic, 1,75% is legendary
            uint256 randomNumber = randomInRange(0, 10000, newTokenId);
            RarityLevel rarityLevel;
            uint256 hashRate;
            if (randomNumber < 5875) {
                rarityLevel = RarityLevel.COMMON;
                hashRate = randomInRange(10000, 100000, block.number * (i + 1));
            } else if (randomNumber < 8300) {
                rarityLevel = RarityLevel.RARE;
                hashRate = randomInRange(20000, 100000, block.number * (i + 1));
            } else if (randomNumber < 9625) {
                rarityLevel = RarityLevel.EPIC;
                hashRate = randomInRange(30000, 100000, block.number * (i + 1));
            } else {
                rarityLevel = RarityLevel.LEGENDARY;
                hashRate = randomInRange(1, 200000, block.number * (i + 1));
            }
            metadata[newTokenId] = NFTMetadata({
                rarityLevel: rarityLevel,
                hashRate: hashRate,
                stakedAt: 0,
                isStaked: false
            });
            _safeMint(recipient, newTokenId);
        }
    }

    function addLiquidity() public nonReentrant notContract returns (bool) {
        // send 2% of pepe to dev
        pepeToken.transfer(dev, pepeToken.balanceOf(address(this)) * 2 / 100);

        // reward to caller of this function 0.3% of the pepe balance
        pepeToken.transfer(msg.sender, pepeToken.balanceOf(address(this)) * 3 / 1000);

        uint256 amountB = pepeToken.balanceOf(address(this));
        uint256 amountA;

        if(uniswapV2Pair.totalSupply() == 0) {
            amountA = amountB;
        } else {
            // Calculate the amount of PEPESTUDIO token needed to add for the current liquidity
            amountA = (amountB * pepeStudioToken.balanceOf(address(uniswapV2Pair))) /
                pepeToken.balanceOf(address(uniswapV2Pair));
        }
        
        // Transfer the PEPESTUDIO token from the contract to the pair
        pepeStudioToken.mint(address(uniswapV2Pair), amountA);
        pepeToken.transfer(address(uniswapV2Pair), amountB);

        // Mint the LP token
        uniswapV2Pair.mint(address(this));

        // send the LP token to address dead
        uniswapV2Pair.transfer(BURN_ADDRESS, uniswapV2Pair.balanceOf(address(this)));

        return true;
    }


    // Function to claim referral rewards
    function claimReferralRewards() public nonReentrant returns (bool) {
        require(nextWithdrawTime[msg.sender] < block.timestamp, "You can only claim once every 3 days");
        uint256 amount = referralRewards[msg.sender];
        require(amount > 0, "No referral rewards to claim");
        if(amount > pepeToken.balanceOf(address(this))) {
            revert NotEnoughPepe();
        }
        referralRewards[msg.sender] = 0;
        pepeToken.transfer(msg.sender, amount);
        // lock for 3 days before next claim
        nextWithdrawTime[msg.sender] = block.timestamp + 3 days;
        return true;
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        if(metadata[tokenId].isStaked) {
            revert TransferStakedNFT();
        }
        super.transferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return (_to - _from);
    }

    // View function to see pending PEPESTUDIO on frontend.
    function pendingPepeStudio(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accPepeStudioPerShare = pool.accPepeStudioPerShare;
        uint256 totalHashRate = pool.currentHashRate;
        if (block.number > pool.lastRewardBlock && totalHashRate != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 pepeStudioReward = multiplier * EMISSION_RATE * pool.allocPoint / totalAllocPoint;
            accPepeStudioPerShare = accPepeStudioPerShare + (pepeStudioReward * 1e12 / totalHashRate);
        }
        return (user.hashRate * accPepeStudioPerShare / 1e12) - user.rewardDebt;
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
        uint256 totalHashRate = pool.currentHashRate;
        if (totalHashRate == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        // Calculate the reward to distribute
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 pepeStudioReward = multiplier * EMISSION_RATE * pool.allocPoint / totalAllocPoint;
        // Send the reward to the dev address
        pepeStudioToken.mint(dev, pepeStudioReward / 30);
        // Send the reward to the contract
        pepeStudioToken.mint(address(this), pepeStudioReward);
        // Update the pool
        pool.accPepeStudioPerShare = pool.accPepeStudioPerShare + (pepeStudioReward * 1e12 / totalHashRate);
        // Update the last reward block
        pool.lastRewardBlock = block.number;
    }

    // Stake NFT tokens to PepeStudio for PEPESTUDIO allocation.
    function stake(uint256 _pid, uint256[] memory _nfts) public startStake {
        require(_pid != 0, "deposit NFT by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        // Update the pool
        updatePool(_pid);
        if (user.hashRate > 0) {
            // Calculate the pending reward
            uint256 pending = (user.hashRate * pool.accPepeStudioPerShare / 1e12) - user.rewardDebt;
            if (pending > 0) {
                // Send the pending reward to the user
                safePepeStudioTransfer(msg.sender, pending);
            }
        }
        for (uint256 i = 0; i < _nfts.length; i++) {
            // Check ownership of the NFT
            require(ownerOf(_nfts[i]) == msg.sender, "You are not the owner of this token");
            // Check if the NFT is already staked
            require(!metadata[_nfts[i]].isStaked, "This token is already staked");
            // Check for minimum and maximum hash rate
            require(metadata[_nfts[i]].hashRate >= pool.minimumHashRate, "hash rate is too low");
            require(metadata[_nfts[i]].hashRate <= pool.maximumHashRate, "hash rate is too high");

            // Recalculate the hash rate
            pool.currentHashRate += metadata[_nfts[i]].hashRate;
            user.hashRate += metadata[_nfts[i]].hashRate;

            // Add the NFT to the user's staked NFTs
            user.stakedNFTs.push(_nfts[i]);

            // Set the metadata of the nft
            metadata[_nfts[i]].isStaked = true;

            emit Stake(_nfts[i]);
        }
        // Update the user's reward debt
        user.rewardDebt = user.hashRate * pool.accPepeStudioPerShare / 1e12;
    }

    // Withdraw NFT tokens from PepeStudio.
    function unstake(uint256 _pid, uint256[] memory _nfts) public {
        require(_pid != 0, "withdraw NFT by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.hashRate > 0, "no hash rate");
        require(user.stakedNFTs.length >= _nfts.length, "not enough nfts");
        updatePool(_pid);
        uint256 pending = (user.hashRate * pool.accPepeStudioPerShare / 1e12) - user.rewardDebt;
        if (pending > 0) {
            safePepeStudioTransfer(msg.sender, pending);
        }
        for (uint256 i = 0; i < _nfts.length; i++) {
            require(ownerOf(_nfts[i]) == msg.sender, "You are not the owner of this token");
            require(metadata[_nfts[i]].isStaked, "This token is not staked");
            require(metadata[_nfts[i]].stakedAt + pool.stakeTime < block.timestamp, "You cannot withdraw this token yet");
            pool.currentHashRate -= metadata[_nfts[i]].hashRate;
            user.hashRate -= metadata[_nfts[i]].hashRate;
            metadata[_nfts[i]].isStaked = false;
            for (uint256 j = 0; j < user.stakedNFTs.length; j++) {
                if (user.stakedNFTs[j] == _nfts[i]) {
                    user.stakedNFTs[j] = user.stakedNFTs[user.stakedNFTs.length - 1];
                    user.stakedNFTs.pop();
                    break;
                }
            }
            emit Unstake(_nfts[i], metadata[_nfts[i]].stakedAt, block.timestamp);
        }
        user.rewardDebt = user.hashRate * pool.accPepeStudioPerShare / 1e12;
    }

    // emergency unstake without caring about rewards. EMERGENCY ONLY.
    function emergencyUnstake(uint256 _pid, uint256[] memory _nfts) public {
        require(_pid != 0, "emergency withdraw NFT by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.hashRate > 0, "no hash rate");
        require(user.stakedNFTs.length >= _nfts.length, "not enough nfts");
        for (uint256 i = 0; i < _nfts.length; i++) {
            require(ownerOf(_nfts[i]) == msg.sender, "You are not the owner of this token");
            require(metadata[_nfts[i]].isStaked, "This token is not staked");
            pool.currentHashRate -= metadata[_nfts[i]].hashRate;
            user.hashRate -= metadata[_nfts[i]].hashRate;
            metadata[_nfts[i]].isStaked = false;
            for (uint256 j = 0; j < user.stakedNFTs.length; j++) {
                if (user.stakedNFTs[j] == _nfts[i]) {
                    user.stakedNFTs[j] = user.stakedNFTs[user.stakedNFTs.length - 1];
                    user.stakedNFTs.pop();
                    break;
                }
            }
        }
        user.rewardDebt = user.hashRate * pool.accPepeStudioPerShare / 1e12;
        emit EmergencyUnstake(msg.sender, _pid, _nfts);
    }

    function safePepeStudioTransfer(address _to, uint256 _amount) internal {
        uint256 pepeStudioBal = pepeStudioToken.balanceOf(address(this));
        if (_amount > pepeStudioBal) {
            pepeStudioToken.transfer(_to, pepeStudioBal);
        } else {
            pepeStudioToken.transfer(_to, _amount);
        }
    }

    function burnNFT(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
        require(!metadata[_tokenId].isStaked, "This token is staked");
        // return 50% of the price they minted the nft to the user, calculate the price at minting time
        pepeToken.transfer(msg.sender, calculateMintingPrice(_tokenId) / 2);
        _burn(_tokenId);
    }
}