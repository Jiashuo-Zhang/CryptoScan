/**

 *Submitted for verification at Etherscan.io on 2024-05-08

*/



// File: /MaximizerStaking/SafeMath.sol



pragma solidity ^0.6.12;



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a, 'SafeMath:INVALID_ADD');

    }



    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a, 'SafeMath:OVERFLOW_SUB');

        c = a - b;

    }



    function mul(uint a, uint b, uint decimal) internal pure returns (uint) {

        uint dc = 10**decimal;

        uint c0 = a * b;

        require(a == 0 || c0 / a == b, "SafeMath: multiple overflow");

        uint c1 = c0 + (dc / 2);

        require(c1 >= c0, "SafeMath: multiple overflow");

        uint c2 = c1 / dc;

        return c2;

    }



    function div(uint256 a, uint256 b, uint decimal) internal pure returns (uint256) {

        require(b != 0, "SafeMath: division by zero");

        uint dc = 10**decimal;

        uint c0 = a * dc;

        require(a == 0 || c0 / a == dc, "SafeMath: division internal");

        uint c1 = c0 + (b / 2);

        require(c1 >= c0, "SafeMath: division internal");

        uint c2 = c1 / b;

        return c2;

    }

}



// File: /MaximizerStaking/TransferHelper.sol



pragma solidity 0.6.12;



// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false

library TransferHelper {

    function safeApprove(

        address token,

        address to,

        uint256 value

    ) internal {

        // bytes4(keccak256(bytes('approve(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));

        require(

            success && (data.length == 0 || abi.decode(data, (bool))),

            'TransferHelper::safeApprove: approve failed'

        );

    }



    function safeTransfer(

        address token,

        address to,

        uint256 value

    ) internal {

        // bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(

            success && (data.length == 0 || abi.decode(data, (bool))),

            'TransferHelper::safeTransfer: transfer failed'

        );

    }



    function safeTransferFrom(

        address token,

        address from,

        address to,

        uint256 value

    ) internal {

        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));

        require(

            success && (data.length == 0 || abi.decode(data, (bool))),

            'TransferHelper::transferFrom: transferFrom failed'

        );

    }



    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));

        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');

    }

}



// File: /MaximizerStaking/Staking.sol



pragma solidity 0.6.12;







contract Staking {

    using SafeMath for uint;



    uint constant DECIMAL = 18;



    struct PoolInfo {

        address lpTokenAddress; // the LP token pair address

        uint accLpStaked;       // accumulate number of LP token user staked

        uint accLastBlockNo;    // record last pass in block number

        uint accTokenPerShare;  // accumulated token per share

        uint tfarmPid;          // main staking contract Pool ID

        bool locked;            // pool is locked

        bool finished;          // pool is stop mint token. disable deposit. only allow claim

    }



    struct UserPoolInfo {

        uint lpStaked;       // user staked LP

        uint rewardDebt;     // user debt

        uint lastClaimBlock; // last block number user retrieve reward

    }



    mapping(uint => PoolInfo) public pools; // dynamic pool container (pool ID => pool related data)

    mapping(address => uint[]) poolIdByLp;  // pool ids recorder (LP token => pool ids)



    // user pool allocate (user addr => (<pool ID> => user pool data))

    mapping(address => mapping(uint => UserPoolInfo)) private users;



    address public owner;      // owner of tube chief

    address public tube;       // the TUBE token

    address public tubeChief;  // TUBE main staking farm

    address public jackpot;    // defarm jackpot contract

    uint public poolLength;    // next pool id. current length is (poolLength - 1)



    event CreatePool(address lpTokenAddress, uint pool_id, uint tfarmPid);

    event UpdatePool(uint poolId, uint tfarmPid, bool locked);

    event UpdateTubeChief(address tubeChief);

    event UpdateJackpot(address jackpot);

    event Stake(uint poolId, uint amount, address sender);

    event Claim(uint poolId, uint amount, uint claimable, address sender);

    event TransferCompany(address old_owner, address new_owner);



    modifier onlyOwner {

        require(msg.sender == owner, 'NOT OWNER');

        _;

    }



    constructor (address _tube, address _tubeChief) public {

        owner     = msg.sender;

        tube      = _tube;

        tubeChief = _tubeChief;

    }



    // create new pool. only owner executable

    // XX do not create twice on same LP token. reward will mess up if you do

    // XX one maximizer is link to one main staking pool ID only

    // XX `lpTokenAddress` must match with main staking pool

    function createPool(address _lpTokenAddress, uint _tfarmPid) public onlyOwner {

        require(_lpTokenAddress != address(0), 'CREATE_POOL_EMPTY_ADDRESS');

    

        emit CreatePool(_lpTokenAddress, poolLength, _tfarmPid);

        pools[poolLength].lpTokenAddress = _lpTokenAddress;

        pools[poolLength].tfarmPid       = _tfarmPid;

        pools[poolLength].accLastBlockNo = block.number;

        poolIdByLp[_lpTokenAddress].push(poolLength);

        poolLength = poolLength.add(1);

    }



    // update pool setting, edit wisely. only owner executable

    function updatePool(uint poolId, uint _tfarmPid, bool _locked) public onlyOwner {

        _updateAccTokenPerShare(poolId);

        pools[poolId].tfarmPid = _tfarmPid;

        pools[poolId].locked   = _locked;

        emit UpdatePool(poolId, _tfarmPid, _locked);

    }



    // stake LP token to earn

    function stake(uint poolId, uint amount) public {

        require(pools[poolId].lpTokenAddress != address(0), 'STAKE_POOL_NOT_EXIST');

        require(pools[poolId].locked == false, 'STAKE_POOL_LOCKED');

        require(pools[poolId].finished == false, 'STAKE_POOL_FINISHED');



        claim(poolId, 0);

        TransferHelper.safeTransferFrom(pools[poolId].lpTokenAddress, msg.sender, address(this), amount);

        TransferHelper.safeApprove(pools[poolId].lpTokenAddress, tubeChief, amount);

        ITubeChief(tubeChief).stake(pools[poolId].tfarmPid, amount);

        pools[poolId].accLpStaked = pools[poolId].accLpStaked.add(amount);

        users[msg.sender][poolId].lpStaked       = users[msg.sender][poolId].lpStaked.add(amount);

        users[msg.sender][poolId].lastClaimBlock = block.number;

        users[msg.sender][poolId].rewardDebt     = pools[poolId].accTokenPerShare.mul(users[msg.sender][poolId].lpStaked, DECIMAL);

        

        emit Stake(poolId, amount, msg.sender);

    }



    // claim TUBE token. input LP token to exit pool

    function claim(uint poolId, uint amount) public {

        require(pools[poolId].lpTokenAddress != address(0), 'CLAIM_POOL_NOT_EXIST');

        require(pools[poolId].locked == false, 'CLAIM_POOL_LOCKED');

        

        // if unstake, require user did not join the current session jackpot

        if (amount > 0) {

            require(!IJackpot(jackpot).getCurrentSessionJoined(msg.sender), "jackpot not end");

        }



        _updateAccTokenPerShare(poolId);



        uint claimable = _getRewardAmount(poolId);

        if (claimable > 0) {

            TransferHelper.safeTransfer(tube, msg.sender, claimable);

            users[msg.sender][poolId].lastClaimBlock = block.number;

        }



        if (amount > 0) {

            ITubeChief(tubeChief).claim(pools[poolId].tfarmPid, amount);

            TransferHelper.safeTransfer(pools[poolId].lpTokenAddress, msg.sender, amount);

            users[msg.sender][poolId].lpStaked = users[msg.sender][poolId].lpStaked.sub(amount);

            pools[poolId].accLpStaked = pools[poolId].accLpStaked.sub(amount);

        }



        // emit if necessary. cost saving

        if (claimable > 0 || amount > 0) {

            emit Claim(poolId, amount, claimable, msg.sender);

        }



        // update the user reward debt at this moment

        users[msg.sender][poolId].rewardDebt = pools[poolId].accTokenPerShare.mul(users[msg.sender][poolId].lpStaked, DECIMAL);

    }



    // get token per share with current block number

    function getAccTokenInfo(uint poolId) public view returns (uint) {

        if (pools[poolId].accLpStaked <= 0) {

            return 0;

        }



        uint result       = 0;

        uint total_staked = pools[poolId].accLpStaked;



        // retrieve the extra bonus from main staking contract

        uint mintable = ITubeChief(tubeChief).getExMintable(poolId, keccak256("STAKING"));



        // maximizer contract harvest amount atm

        (,uint harvestable,,,) = ITubeChief(tubeChief).getUserReward(pools[poolId].tfarmPid);

        

        result = result.add(mintable).add(harvestable);



        return result.div(total_staked, DECIMAL);

    }



    // emergency collect token from the contract. only owner executable

    function emergencyCollectToken(address token, uint amount) public onlyOwner {

        TransferHelper.safeTransfer(token, owner, amount);

    }



    // emergency collect eth from the contract. only owner executable

    function emergencyCollectEth(uint amount) public onlyOwner {

        address payable owner_address = payable(owner);

        TransferHelper.safeTransferETH(owner_address, amount);

    }



    // transfer ownership. proceed wisely. only owner executable

    function transferCompany(address new_owner) public onlyOwner {

        owner = new_owner;

        emit TransferCompany(owner, new_owner);

    }



    // retrieve pool ids by LP token address

    function getPidByLpToken(address _lpTokenAddress) public view returns (uint[] memory) {

        return poolIdByLp[_lpTokenAddress];

    }



    // retrieve user reward info on the pool with current block number

    function getUserReward(uint poolId) public view returns (uint, uint, uint, uint, uint) {

        return getUserRewardByAddress(poolId, msg.sender);

    }

    

    // retrieve user reward info on the pool with current block number by address

    function getUserRewardByAddress(uint poolId, address _address) public view returns (uint, uint, uint, uint, uint) {

        uint accTokenPerShare = getAccTokenInfo(poolId);

        accTokenPerShare      = accTokenPerShare.add(pools[poolId].accTokenPerShare);

        

        uint claimable = accTokenPerShare.mul(users[_address][poolId].lpStaked, DECIMAL).sub(users[_address][poolId].rewardDebt);

        return (block.number, claimable, accTokenPerShare, users[_address][poolId].lpStaked, users[_address][poolId].rewardDebt);

    }

    

    // retrieve user staked in the pool

    function getUser(address _address, uint pool_id) public view returns (uint, uint, uint) {

        return (

            users[_address][pool_id].lpStaked, 

            users[_address][pool_id].rewardDebt,  

            users[_address][pool_id].lastClaimBlock

        );    

    }

    

    // update tube main farm contract

    function updateTubeChief(address _tubeChief) public onlyOwner {

        tubeChief = _tubeChief;

        emit UpdateTubeChief(tubeChief);

    }

    

    // update jackpot contract

    function updateJackpot(address _jackpot) public onlyOwner {

        jackpot = _jackpot;

        emit UpdateJackpot(jackpot);

    }

    

    function _updateAccTokenPerShare(uint poolId) internal {

        // we need update all pools at once to sync the reward

        uint result = getAccTokenInfo(poolId);

        pools[poolId].accTokenPerShare = pools[poolId].accTokenPerShare.add(result);

        pools[poolId].accLastBlockNo   = block.number;  

        

        // transfer extra reward from main contract

        ITubeChief(tubeChief).transferStaking(poolId);

        

        // harvest from main contract

        ITubeChief(tubeChief).claim(poolId, 0);

    }



    function _getRewardAmount(uint poolId) view internal returns (uint) {

        if (pools[poolId].accLpStaked <= 0) {

            return (0);

        }



        uint user_staked = users[msg.sender][poolId].lpStaked;

        uint user_debt   = users[msg.sender][poolId].rewardDebt;

        uint claimable   = pools[poolId].accTokenPerShare.mul(user_staked, DECIMAL).sub(user_debt);



        return (claimable);

    }



    fallback() external payable {

    }

}



interface ITubeChief {

    function stake(uint poolId, uint amount) external;

    function claim(uint poolId, uint amount) external;

    function getExMintable(uint poolId, bytes32 category) external view returns (uint);

    function getUserReward(uint poolId) external view returns (uint, uint, uint, uint, uint);

    function transferStaking(uint poolId) external;

}



interface IJackpot {

    function getCurrentSessionJoined(address _address) external view returns (bool);

}