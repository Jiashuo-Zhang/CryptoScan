/**

 *Submitted for verification at Etherscan.io on 2020-12-13

*/



/**

 *Submitted for verification at Etherscan.io on      09-16

*/



/***



 *    

 *    

 * https://pros.finance

                                  

* MIT License

* ===========

*

* Copyright (c) 2020 pros

*

* Permission is hereby granted, free of charge, to any person obtaining a copy

* of this software and associated documentation files (the "Software"), to deal

* in the Software without restriction, including without limitation the rights

* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

* copies of the Software, and to permit persons to whom the Software is

* furnished to do so, subject to the following conditions:

*

* The above copyright notice and this permission notice shall be included in all

* copies or substantial portions of the Software.

*

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

// File: @openzeppelin/contracts/math/Math.sol



pragma solidity ^0.5.0;



/**

 * @dev Standard math utilities missing in the Solidity language.

 */

library Math {

    /**

     * @dev Returns the largest of two numbers.

     */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;

    }



    /**

     * @dev Returns the smallest of two numbers.

     */

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    /**

     * @dev Returns the average of two numbers. The result is rounded towards

     * zero.

     */

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b) / 2 can overflow, so we distribute

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

    }

}



// File: @openzeppelin/contracts/math/SafeMath.sol



/*

 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.

 * Author: Mikhail Vladimirov <[email protected]>

 */





/**

 * Smart contract library of mathematical functions operating with signed

 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is

 * basically a simple fraction whose numerator is signed 128-bit integer and

 * denominator is 2^64.  As long as denominator is always the same, there is no

 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are

 * represented by int128 type holding only the numerator.

 */













pragma solidity ^0.5.0;



/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.

 *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 */

library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `+` operator.

     *

     * Requirements:

     * - Addition cannot overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     *

     * _Available since v2.4.0._

     */

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Returns the multiplication of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `*` operator.

     *

     * Requirements:

     * - Multiplication cannot overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0, errorMessage);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts with custom message when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



// File: @openzeppelin/contracts/GSN/Context.sol



pragma solidity ^0.5.0;



/*

 * @dev Provides information about the current execution context, including the

 * sender of the transaction and its data. While these are generally available

 * via msg.sender and msg.data, they should not be accessed in such a direct

 * manner, since when dealing with GSN meta-transactions the account sending and

 * paying for execution may not be the actual sender (as far as an application

 * is concerned).

 *

 * This contract is only required for intermediate, library-like contracts.

 */

contract Context {

    // Empty internal constructor, to prevent people from mistakenly deploying

    // an instance of this contract, which should be used via inheritance.

    constructor () internal { }

    // solhint-disable-previous-line no-empty-blocks



    function _msgSender() internal view returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



// File: @openzeppelin/contracts/ownership/Ownable.sol



pragma solidity ^0.5.0;



/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be applied to your functions to restrict their use to

 * the owner.

 */

contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        address msgSender = _msgSender();

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Returns true if the caller is the current owner.

     */

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



// File: contracts/interface/IERC20.sol



pragma solidity ^0.5.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see {ERC20Detailed}.

 */

interface IERC20 {

    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `recipient`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * Emits an {Approval} event.

     */

    function approve(address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `sender` to `recipient` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by

     * a call to {approve}. `value` is the new allowance.

     */

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: contracts/interface/IPlayerBook.sol



pragma solidity ^0.5.0;





interface IPlayerBook {

    function settleReward( address from,uint256 amount ) external returns (uint256);

    function bindRefer( address from,string calldata  affCode )  external returns (bool);

    function hasRefer(address from) external returns(bool);



}



// File: contracts/interface/IPool.sol



pragma solidity ^0.5.0;





interface IPool {

    function totalSupply( ) external view returns (uint256);

    function balanceOf( address player ) external view returns (uint256);

}



// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.5.5;



/**

 * @dev Collection of functions related to the address type

 */

library Address {

    /**

     * @dev Returns true if `account` is a contract.

     *

     * [IMPORTANT]

     * ====

     * It is unsafe to assume that an address for which this function returns

     * false is an externally-owned account (EOA) and not a contract.

     *

     * Among others, `isContract` will return false for the following 

     * types of addresses:

     *

     *  - an externally-owned account

     *  - a contract in construction

     *  - an address where a contract will be created

     *  - an address where a contract lived, but was destroyed

     * ====

     */

    function isContract(address account) internal view returns (bool) {

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts

        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned

        // for accounts without code, i.e. `keccak256('')`

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly

        assembly { codehash := extcodehash(account) }

        return (codehash != accountHash && codehash != 0x0);

    }



    /**

     * @dev Converts an `address` into `address payable`. Note that this is

     * simply a type cast: the actual underlying value is not changed.

     *

     * _Available since v2.4.0._

     */

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));

    }



    /**

     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to

     * `recipient`, forwarding all available gas and reverting on errors.

     *

     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost

     * of certain opcodes, possibly making contracts go over the 2300 gas limit

     * imposed by `transfer`, making them unable to receive funds via

     * `transfer`. {sendValue} removes this limitation.

     *

     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].

     *

     * IMPORTANT: because control is transferred to `recipient`, care must be

     * taken to not create reentrancy vulnerabilities. Consider using

     * {ReentrancyGuard} or the

     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].

     *

     * _Available since v2.4.0._

     */

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        // solhint-disable-next-line avoid-call-value

        (bool success, ) = recipient.call.value(amount)("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }

}



// File: contracts/library/SafeERC20.sol



pragma solidity ^0.5.0;











/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using SafeMath for uint256;

    using Address for address;



    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SELECTOR, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: TRANSFER_FAILED');

    }

    // function safeTransfer(IERC20 token, address to, uint256 value) internal {

    //     callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    // }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        // solhint-disable-next-line max-line-length

        require((value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves.



        // A Solidity high level call has three parts:

        //  1. The target address is checked to verify it contains contract code

        //  2. The call itself is made, and success asserted

        //  3. The return value is decoded, which in turn checks the size of the returned data.

        // solhint-disable-next-line max-line-length

        require(address(token).isContract(), "SafeERC20: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = address(token).call(data);

        require(success, "SafeERC20: low-level call failed");



        if (returndata.length > 0) { // Return data is optional

            // solhint-disable-next-line max-line-length

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}



// File: contracts/library/priMath.sol



pragma solidity ^0.5.0;





library prosMath {

  /**

   * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer

   * number.

   *

   * @param x unsigned 256-bit integer number

   * @return unsigned 128-bit integer number

   */

    function sqrt(uint256 x) public pure returns (uint256 y)  {

        uint256 z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }



}



// File: contracts/library/Governance.sol



pragma solidity ^0.5.0;



contract Governance {



    address public _governance;



    constructor() public {

        _governance = tx.origin;

    }



    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);



    modifier onlyGovernance {

        require(msg.sender == _governance, "not governance");

        _;

    }



    function setGovernance(address governance)  public  onlyGovernance

    {

        require(governance != address(0), "new governance the zero address");

        emit GovernanceTransferred(_governance, governance);

        _governance = governance;

    }





}



// File: contracts/interface/IPowerStrategy.sol



pragma solidity ^0.5.0;





interface IPowerStrategy {

    function lpIn(address sender, uint256 amount) external;

    function lpOut(address sender, uint256 amount) external;

    

    function getPower(address sender) view  external returns (uint256);

}



// File: contracts/library/LPTokenWrapper.sol



pragma solidity ^0.5.0;





















contract LPTokenWrapper is IPool,Governance {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 public _lpToken = IERC20(0x51D287C63301d574Eef7C7615bf02A19e9549B8A); //切换一下对应的LP_token的币地址就行



    address public _playerBook = address(0x21A4086a6Cdb332c851B76cccD21aCAB6428D9E4); //切换一下对应的邀请的记录



    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;



    uint256 private _totalPower;

    mapping(address => uint256) private _powerBalances;

    

    address public _powerStrategy = address(0x0);//token币的地址





    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }

    

    function setLp_token(address LP_token) public  onlyGovernance {

        //return _totalSupply;

        _lpToken = IERC20(LP_token);

    }



    function set_playBook(address playbook) public   onlyGovernance {

        //return _totalSupply;

        _playerBook = playbook;

    }



    function setPowerStragegy(address strategy)  public  onlyGovernance{

        _powerStrategy = strategy;

    }



    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }



    function balanceOfPower(address account) public view returns (uint256) {

        return _powerBalances[account];

    }







    function totalPower() public view returns (uint256) {

        return _totalPower;

    }





    function stake(uint256 amount, string memory affCode) public {

        _totalSupply = _totalSupply.add(amount);

        _balances[msg.sender] = _balances[msg.sender].add(amount);



        if( _powerStrategy != address(0x0)){ 

            _totalPower = _totalPower.sub(_powerBalances[msg.sender]);

            IPowerStrategy(_powerStrategy).lpIn(msg.sender, amount);



            _powerBalances[msg.sender] = IPowerStrategy(_powerStrategy).getPower(msg.sender);

            _totalPower = _totalPower.add(_powerBalances[msg.sender]);

        }else{

            _totalPower = _totalSupply;

            _powerBalances[msg.sender] = _balances[msg.sender];

        }



        _lpToken.safeTransferFrom(msg.sender, address(this), amount);





        if (!IPlayerBook(_playerBook).hasRefer(msg.sender)) {

            IPlayerBook(_playerBook).bindRefer(msg.sender, affCode);

        }



        

    }



    function withdraw(uint256 amount) public {

        require(amount > 0, "amout > 0");



        _totalSupply = _totalSupply.sub(amount);

        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        

        if( _powerStrategy != address(0x0)){ 

            _totalPower = _totalPower.sub(_powerBalances[msg.sender]);

            IPowerStrategy(_powerStrategy).lpOut(msg.sender, amount);

            _powerBalances[msg.sender] = IPowerStrategy(_powerStrategy).getPower(msg.sender);

            _totalPower = _totalPower.add(_powerBalances[msg.sender]);



        }else{

            _totalPower = _totalSupply;

            _powerBalances[msg.sender] = _balances[msg.sender];

        }



        _lpToken.safeTransfer( msg.sender, amount);

    }



    

}







interface AllPool{

    function is_Re(address user) view external  returns(bool);

    // function set_user_isRe(address user,address pool,string calldata name) external;

    function get_Address_pool(address user) view external  returns(address);

}



// File: contracts/reward/UniswapReward.sol



pragma solidity ^0.5.0;

















contract UniswapReward is LPTokenWrapper{

    using SafeERC20 for IERC20;



    IERC20 public _pros = IERC20(0x306Dd7CD66d964f598B4D2ec92b5a9B275D7fEb3);

    address public _teamWallet = 0xde7a7E8Db75D56B095263c63ecB4CfE8157ee3dd;

    address public _rewardPool = 0xde7a7E8Db75D56B095263c63ecB4CfE8157ee3dd;

    address public _allpool = 0xC682bD99eE552B6f7d931aFee2A9425806e155E9;

    

    

    int128 private dayNums;

    int128 baseReward = 8000;

    // uint256 public constant DURATION = 7 days;

    // should do this ? 

    uint256 public  DURATION = 1 days;

    uint256 public _initReward = 0;

    

    uint256 public base_ = 30*10e3;

    uint256 public rate_forReward = 1;

    uint256 public base_Rate_Reward = 100;

    //init amount should be ?

    

    

    uint256 public _startTime =  now + 365 days;

    uint256 public _periodFinish = 0;

    uint256 public _rewardRate = 0;

    uint256 public _lastUpdateTime;

    uint256 public _rewardPerTokenStored;



    uint256 public _teamRewardRate = 0;

    uint256 public _poolRewardRate = 0;

    uint256 public _baseRate = 10000;

    uint256 public _punishTime = 10 days;



    mapping(address => uint256) public _userRewardPerTokenPaid;

    mapping(address => uint256) public _rewards;

    mapping(address => uint256) public _lastStakedTime;



    bool public _hasStart = false;



    event RewardAdded(uint256 reward);

    event Staked(address indexed user, uint256 amount);

    event Withdrawn(address indexed user, uint256 amount);

    event RewardPaid(address indexed user, uint256 reward);





    modifier updateReward(address account) {

        _rewardPerTokenStored = rewardPerToken();

        _lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {

            _rewards[account] = earned(account);

            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;

        }

        _;

    }

    

    function set_DURATION(uint256 _DURATION) public onlyGovernance{

        DURATION = _DURATION; 

    }

    

    function set_baseReward(int128 _baseReward) public onlyGovernance{

        baseReward = _baseReward;

    }

    

    function set_pros_address(address pri)public onlyGovernance{

        _pros = IERC20(pri);

    }

    function set_teamWallet(address team)public onlyGovernance{

        _teamWallet = team;

    }

    function set_rewardpool(address pool)public onlyGovernance{

        _rewardPool = pool;

    }

    //set the initamount for onwer

    function set_initReward(uint256 initamount) public onlyGovernance{

        _initReward = initamount;

    }

    /* Fee collection for any other token */

    function seize(IERC20 token, uint256 amount) external onlyGovernance{

        require(token != _pros, "reward");

        require(token != _lpToken, "stake");

        token.safeTransfer(_governance, amount);

    }



    function setTeamRewardRate( uint256 teamRewardRate ) public onlyGovernance{

        _teamRewardRate = teamRewardRate;

    }



    function setPoolRewardRate( uint256  poolRewardRate ) public onlyGovernance{

        _poolRewardRate = poolRewardRate;

    }



    function setWithDrawPunishTime( uint256  punishTime ) public onlyGovernance{

        _punishTime = punishTime;

    }



    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, _periodFinish);

    }

    

    

    function rewardPerToken() public view returns (uint256) { //to change to the address thing for dip problem 

        if (totalPower() == 0) { //totalPower change ----- totaldipost[token] 

            return _rewardPerTokenStored;

        }

        return

            _rewardPerTokenStored.add(

                lastTimeRewardApplicable() 

                    .sub(_lastUpdateTime)

                    .mul(_rewardRate) //change for the _rewardRate[token]

                    .mul(1e18)

                    .div(totalPower()) //change for the totalPower[token] ---- 

            );

    }



    //diposit funtion should define the pri address setprice interface also 

    //function 



    function earned(address account) public view returns (uint256) {

        return

            balanceOfPower(account)

                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))

                .div(1e18)

                .add(_rewards[account]);

    }



    // stake visibility is public as overriding LPTokenWrapper's stake() function

    function stake(uint256 amount, string memory affCode)

        public

        updateReward(msg.sender)

        checkHalve

        checkStart

        isRegister

    {

        require(amount > 0, "Cannot stake 0");

        super.stake(amount, affCode);



        _lastStakedTime[msg.sender] = now;



        emit Staked(msg.sender, amount);

    }



    function withdraw(uint256 amount)

        public

        updateReward(msg.sender)

        checkHalve

        checkStart

    {

        require(amount > 0, "Cannot withdraw 0");

        super.withdraw(amount);

        emit Withdrawn(msg.sender, amount);

    }



    function exit() external {

        withdraw(balanceOf(msg.sender));

        getReward();

    }



    function getReward() public updateReward(msg.sender) checkHalve checkStart {

        uint256 reward = earned(msg.sender);

        if (reward > 0) {

            _rewards[msg.sender] = 0;

            

            address set_play = AllPool(_allpool).get_Address_pool(msg.sender)==0x0000000000000000000000000000000000000000?_playerBook:AllPool(_allpool).get_Address_pool(msg.sender);

            uint256 fee = IPlayerBook(set_play).settleReward(msg.sender,reward);

            // uint256 fee = IPlayerBook(_playerBook).settleReward(msg.sender, reward);

            if(fee > 0){

                _pros.safeTransfer(set_play, fee);

            }

            

            uint256 teamReward = reward.mul(_teamRewardRate).div(_baseRate);

            if(teamReward>0){

                _pros.safeTransfer(_teamWallet, teamReward);

            }

            uint256 leftReward = reward.sub(fee).sub(teamReward);

            uint256 poolReward = 0;



            //withdraw time check



            if(now  < (_lastStakedTime[msg.sender] + _punishTime) ){

                poolReward = leftReward.mul(_poolRewardRate).div(_baseRate);

            }

            if(poolReward>0){

                _pros.safeTransfer(_rewardPool, poolReward);

                leftReward = leftReward.sub(poolReward);

            }



            if(leftReward>0){

                _pros.safeTransfer(msg.sender, leftReward );

            }

      

            emit RewardPaid(msg.sender, leftReward);

        }

    }



    modifier checkHalve() {

        if (block.timestamp >= _periodFinish) {

            // _initReward = _initReward.mul(50).div(100);

            update_initreward();

            _pros.mint(address(this), _initReward);

            _rewardRate = _initReward.div(DURATION);

            _periodFinish = block.timestamp.add(DURATION);

            emit RewardAdded(_initReward);

        }

        _;

    }

    

    modifier checkStart() {

        require(block.timestamp > _startTime, "not start");

        _;

    }

    

    modifier isRegister(){

        require(AllPool(_allpool).is_Re(msg.sender)==true,"address not register or name already register");

        _;

    }

    

    function update_initreward() private {

	    dayNums = dayNums + 1;

        uint256 thisreward = base_.mul(rate_forReward).mul(10**18).mul((base_Rate_Reward.sub(rate_forReward))**(uint256(dayNums-1))).div(base_Rate_Reward**(uint256(dayNums)));

	    _initReward = uint256(thisreward);

	}

//     function update_initreward() private {

// 	    dayNums = dayNums + 1;

//         int128 precision = 10000000;

//         int256 thisreward;

//         int128 BASE_Rate = precision-precision*dayNums/60; 

//         uint256 count = 0;

//         int128[] memory list = new int128[](15);

//         int128 Yun_number = BASE_Rate;

//         int128 d = 0;

//         if(dayNums<=180){

//         for(int128 i=0;i<15;i++){ 

//         	Yun_number = Yun_number*2;

//         	int128 A = 1;

        	

//         	if(Yun_number>precision){ 

//         		d = d+(A<<(63-count));

//         		Yun_number-=precision;

//         		list[count] = int128(1);

//         		count+=1;

//         	}else{

//         		//d = d+(B<<(63-count));

//         		list[count] = int128(0);

//         		count+=1;

//         	}

        	

//         }



// 		thisreward = int256(ABDKMath64x64.toInt(ABDKMath64x64.exp(d)*baseReward));



// 		}else if(dayNums<=25*365){

// 		    thisreward = int256(1000);

// 		}

// 	    thisreward = thisreward*10**18;

// 	    _initReward = uint256(thisreward);

// 	}





    

    

    

    

    // set fix time to start reward

    function startReward(uint256 startTime)

        external

        onlyGovernance

        updateReward(address(0))

    {

        require(_hasStart == false, "has started");

        _hasStart = true;

        _startTime = startTime;

        update_initreward();

        _rewardRate = _initReward.div(DURATION); 

        _pros.mint(address(this), _initReward);

        _lastUpdateTime = _startTime;

        _periodFinish = _startTime.add(DURATION);



        emit RewardAdded(_initReward);

    }



    //



    //for extra reward

    function notifyRewardAmount(uint256 reward)

        external

        onlyGovernance

        updateReward(address(0))

    {

        IERC20(_pros).safeTransferFrom(msg.sender, address(this), reward);

        if (block.timestamp >= _periodFinish) {

            _rewardRate = reward.div(DURATION);

        } else {

            uint256 remaining = _periodFinish.sub(block.timestamp);

            uint256 leftover = remaining.mul(_rewardRate);

            _rewardRate = reward.add(leftover).div(DURATION);

        }

        _lastUpdateTime = block.timestamp;

        _periodFinish = block.timestamp.add(DURATION);

        emit RewardAdded(reward);

    }

}