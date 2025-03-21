// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using SafeMath for uint256;

    using Address for address;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    /**

     * @dev Deprecated. This function has issues similar to the ones found in

     * {IERC20-approve}, and its usage is discouraged.

     *

     * Whenever possible, use {safeIncreaseAllowance} and

     * {safeDecreaseAllowance} instead.

     */

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        // solhint-disable-next-line max-line-length

        require((value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that

        // the target address contains contract code and also asserts for success in the low-level call.



        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional

            // solhint-disable-next-line max-line-length

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}





pragma solidity ^0.6.0;



/**

 * @dev Library for managing

 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive

 * types.

 *

 * Sets have the following properties:

 *

 * - Elements are added, removed, and checked for existence in constant time

 * (O(1)).

 * - Elements are enumerated in O(n). No guarantees are made on the ordering.

 *

 * ```

 * contract Example {

 *     // Add the library methods

 *     using EnumerableSet for EnumerableSet.AddressSet;

 *

 *     // Declare a set state variable

 *     EnumerableSet.AddressSet private mySet;

 * }

 * ```

 *

 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`

 * (`UintSet`) are supported.

 */

library EnumerableSet {

    // To implement this library for multiple types with as little code

    // repetition as possible, we write it in terms of a generic Set type with

    // bytes32 values.

    // The Set implementation uses private functions, and user-facing

    // implementations (such as AddressSet) are just wrappers around the

    // underlying Set.

    // This means that we can only create new EnumerableSets for types that fit

    // in bytes32.



    struct Set {

        // Storage of set values

        bytes32[] _values;



        // Position of the value in the `values` array, plus 1 because index 0

        // means a value is not in the set.

        mapping (bytes32 => uint256) _indexes;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {

            set._values.push(value);

            // The value is stored at length-1, but we add 1 to all indexes

            // and use 0 as a sentinel value

            set._indexes[value] = set._values.length;

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        // We read and store the value's index to prevent multiple reads from the same storage slot

        uint256 valueIndex = set._indexes[value];



        if (valueIndex != 0) { // Equivalent to contains(set, value)

            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in

            // the array, and then remove the last element (sometimes called as 'swap and pop').

            // This modifies the order of the array, as noted in {at}.



            uint256 toDeleteIndex = valueIndex - 1;

            uint256 lastIndex = set._values.length - 1;



            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs

            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.



            bytes32 lastvalue = set._values[lastIndex];



            // Move the last value to the index where the value to delete is

            set._values[toDeleteIndex] = lastvalue;

            // Update the index for the moved value

            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based



            // Delete the slot where the moved value was stored

            set._values.pop();



            // Delete the index for the deleted slot

            delete set._indexes[value];



            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;

    }



   /**

    * @dev Returns the value stored at position `index` in the set. O(1).

    *

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");

        return set._values[index];

    }



    // AddressSet



    struct AddressSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



   /**

    * @dev Returns the value stored at position `index` in the set. O(1).

    *

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));

    }





    // UintSet



    struct UintSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



   /**

    * @dev Returns the value stored at position `index` in the set. O(1).

    *

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));

    }

}





pragma solidity ^0.6.12;





interface IMigratorChef {

    function migrate(IERC20 token) external returns (IERC20);

}





// ***************************************************************



/**

 *Submitted for verification at Etherscan.io on 2020-08-26

*/



// File: @openzeppelin/contracts/GSN/Context.sol





pragma solidity ^0.6.0;



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

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol







pragma solidity ^0.6.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

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



// File: @openzeppelin/contracts/math/SafeMath.sol







pragma solidity ^0.6.0;



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

     *

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

     *

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

     *

     * - Subtraction cannot overflow.

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

     *

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

     *

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

     *

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

     *

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

     *

     * - The divisor cannot be zero.

     */

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



// File: @openzeppelin/contracts/utils/Address.sol







pragma solidity ^0.6.2;



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

     */

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value

        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



    /**

     * @dev Performs a Solidity function call using a low level `call`. A

     * plain`call` is an unsafe replacement for a function call: use this

     * function instead.

     *

     * If `target` reverts with a revert reason, it is bubbled up by this

     * function (like regular Solidity function calls).

     *

     * Returns the raw returned data. To convert to the expected return value,

     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].

     *

     * Requirements:

     *

     * - `target` must be a contract.

     * - calling `target` with `data` must not revert.

     *

     * _Available since v3.1._

     */

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with

     * `errorMessage` as a fallback revert reason when `target` reverts.

     *

     * _Available since v3.1._

     */

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but also transferring `value` wei to `target`.

     *

     * Requirements:

     *

     * - the calling contract must have an ETH balance of at least `value`.

     * - the called Solidity function must be `payable`.

     *

     * _Available since v3.1._

     */

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }



    /**

     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but

     * with `errorMessage` as a fallback revert reason when `target` reverts.

     *

     * _Available since v3.1._

     */

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        return _functionCallWithValue(target, data, value, errorMessage);

    }



    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);

        if (success) {

            return returndata;

        } else {

            // Look for revert reason and bubble it up if present

            if (returndata.length > 0) {

                // The easiest way to bubble the revert reason is using memory via assembly



                // solhint-disable-next-line no-inline-assembly

                assembly {

                    let returndata_size := mload(returndata)

                    revert(add(32, returndata), returndata_size)

                }

            } else {

                revert(errorMessage);

            }

        }

    }

}



// File: @openzeppelin/contracts/token/ERC20/ERC20.sol







pragma solidity ^0.6.0;











/**

 * @dev Implementation of the {IERC20} interface.

 *

 * This implementation is agnostic to the way tokens are created. This means

 * that a supply mechanism has to be added in a derived contract using {_mint}.

 * For a generic mechanism see {ERC20PresetMinterPauser}.

 *

 * TIP: For a detailed writeup see our guide

 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How

 * to implement supply mechanisms].

 *

 * We have followed general OpenZeppelin guidelines: functions revert instead

 * of returning `false` on failure. This behavior is nonetheless conventional

 * and does not conflict with the expectations of ERC20 applications.

 *

 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.

 * This allows applications to reconstruct the allowance for all accounts just

 * by listening to said events. Other implementations of the EIP may not emit

 * these events, as it isn't required by the specification.

 *

 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}

 * functions have been added to mitigate the well-known issues around setting

 * allowances. See {IERC20-approve}.

 */

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    using Address for address;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;

    uint8 private _decimals;



    /**

     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with

     * a default value of 18.

     *

     * To select a different value for {decimals}, use {_setupDecimals}.

     *

     * All three of these values are immutable: they can only be set once during

     * construction.

     */

    constructor (string memory name, string memory symbol) public {

        _name = name;

        _symbol = symbol;

        _decimals = 18;

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @dev Returns the symbol of the token, usually a shorter version of the

     * name.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the number of decimals used to get its user representation.

     * For example, if `decimals` equals `2`, a balance of `505` tokens should

     * be displayed to a user as `5,05` (`505 / 10 ** 2`).

     *

     * Tokens usually opt for a value of 18, imitating the relationship between

     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is

     * called.

     *

     * NOTE: This information is only used for _display_ purposes: it in

     * no way affects any of the arithmetic of the contract, including

     * {IERC20-balanceOf} and {IERC20-transfer}.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }



    /**

     * @dev See {IERC20-totalSupply}.

     */

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See {IERC20-balanceOf}.

     */

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];

    }



    /**

     * @dev See {IERC20-transfer}.

     *

     * Requirements:

     *

     * - `recipient` cannot be the zero address.

     * - the caller must have a balance of at least `amount`.

     */

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    /**

     * @dev See {IERC20-allowance}.

     */

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    /**

     * @dev See {IERC20-approve}.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    /**

     * @dev See {IERC20-transferFrom}.

     *

     * Emits an {Approval} event indicating the updated allowance. This is not

     * required by the EIP. See the note at the beginning of {ERC20};

     *

     * Requirements:

     * - `sender` and `recipient` cannot be the zero address.

     * - `sender` must have a balance of at least `amount`.

     * - the caller must have allowance for ``sender``'s tokens of at least

     * `amount`.

     */

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }



    /**

     * @dev Atomically increases the allowance granted to `spender` by the caller.

     *

     * This is an alternative to {approve} that can be used as a mitigation for

     * problems described in {IERC20-approve}.

     *

     * Emits an {Approval} event indicating the updated allowance.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;

    }



    /**

     * @dev Atomically decreases the allowance granted to `spender` by the caller.

     *

     * This is an alternative to {approve} that can be used as a mitigation for

     * problems described in {IERC20-approve}.

     *

     * Emits an {Approval} event indicating the updated allowance.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     * - `spender` must have allowance for the caller of at least

     * `subtractedValue`.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    /**

     * @dev Moves tokens `amount` from `sender` to `recipient`.

     *

     * This is internal function is equivalent to {transfer}, and can be used to

     * e.g. implement automatic token fees, slashing mechanisms, etc.

     *

     * Emits a {Transfer} event.

     *

     * Requirements:

     *

     * - `sender` cannot be the zero address.

     * - `recipient` cannot be the zero address.

     * - `sender` must have a balance of at least `amount`.

     */

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(sender, recipient, amount);



        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    /** @dev Creates `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a {Transfer} event with `from` set to the zero address.

     *

     * Requirements

     *

     * - `to` cannot be the zero address.

     */

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`, reducing the

     * total supply.

     *

     * Emits a {Transfer} event with `to` set to the zero address.

     *

     * Requirements

     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens.

     */

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _beforeTokenTransfer(account, address(0), amount);



        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

    }



    /**

     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.

     *

     * This is internal function is equivalent to `approve`, and can be used to

     * e.g. set automatic allowances for certain subsystems, etc.

     *

     * Emits an {Approval} event.

     *

     * Requirements:

     *

     * - `owner` cannot be the zero address.

     * - `spender` cannot be the zero address.

     */

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    /**

     * @dev Sets {decimals} to a value other than the default one of 18.

     *

     * WARNING: This function should only be called from the constructor. Most

     * applications that interact with token contracts will not expect

     * {decimals} to ever change, and may work incorrectly if it does.

     */

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;

    }



    /**

     * @dev Hook that is called before any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * will be to transferred to `to`.

     * - when `from` is zero, `amount` tokens will be minted for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}



// File: @openzeppelin/contracts/access/Ownable.sol







pragma solidity ^0.6.0;



/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * By default, the owner account will be the one that deploys the contract. This

 * can later be changed with {transferOwnership}.

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

        require(_owner == _msgSender(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



pragma solidity ^0.6.12;





// MGToken with Governance.

contract MGToken is ERC20("MGToken", "MG"), Ownable {

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).

    function mint(address _to, uint256 _amount) public onlyOwner {

        _mint(_to, _amount);

        _moveDelegates(address(0), _delegates[_to], _amount);

    }



    // Copied and modified from YAM code:

    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol

    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol

    // Which is copied and modified from COMPOUND:

    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol



    /// @dev A record of each accounts delegate

    mapping (address => address) internal _delegates;



    /// @notice A checkpoint for marking number of votes from a given block

    struct Checkpoint {

        uint32 fromBlock;

        uint256 votes;

    }



    /// @notice A record of votes checkpoints for each account, by index

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;



    /// @notice The number of checkpoints for each account

    mapping (address => uint32) public numCheckpoints;



    /// @notice The EIP-712 typehash for the contract's domain

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");



    /// @notice The EIP-712 typehash for the delegation struct used by the contract

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");



    /// @notice A record of states for signing / validating signatures

    mapping (address => uint) public nonces;



      /// @notice An event thats emitted when an account changes its delegate

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);



    /// @notice An event thats emitted when a delegate account's vote balance changes

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);



    /**

     * @notice Delegate votes from `msg.sender` to `delegatee`

     * @param delegator The address to get delegatee for

     */

    function delegates(address delegator)

        external

        view

        returns (address)

    {

        return _delegates[delegator];

    }



   /**

    * @notice Delegate votes from `msg.sender` to `delegatee`

    * @param delegatee The address to delegate votes to

    */

    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);

    }



    /**

     * @notice Delegates votes from signatory to `delegatee`

     * @param delegatee The address to delegate votes to

     * @param nonce The contract state required to match the signature

     * @param expiry The time at which to expire the signature

     * @param v The recovery byte of the signature

     * @param r Half of the ECDSA signature pair

     * @param s Half of the ECDSA signature pair

     */

    function delegateBySig(

        address delegatee,

        uint nonce,

        uint expiry,

        uint8 v,

        bytes32 r,

        bytes32 s

    )

        external

    {

        bytes32 domainSeparator = keccak256(

            abi.encode(

                DOMAIN_TYPEHASH,

                keccak256(bytes(name())),

                getChainId(),

                address(this)

            )

        );



        bytes32 structHash = keccak256(

            abi.encode(

                DELEGATION_TYPEHASH,

                delegatee,

                nonce,

                expiry

            )

        );



        bytes32 digest = keccak256(

            abi.encodePacked(

                "\x19\x01",

                domainSeparator,

                structHash

            )

        );



        address signatory = ecrecover(digest, v, r, s);

        require(signatory != address(0), "MG::delegateBySig: invalid signature");

        require(nonce == nonces[signatory]++, "MG::delegateBySig: invalid nonce");

        require(now <= expiry, "MG::delegateBySig: signature expired");

        return _delegate(signatory, delegatee);

    }



    /**

     * @notice Gets the current votes balance for `account`

     * @param account The address to get votes balance

     * @return The number of current votes for `account`

     */

    function getCurrentVotes(address account)

        external

        view

        returns (uint256)

    {

        uint32 nCheckpoints = numCheckpoints[account];

        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;

    }



    /**

     * @notice Determine the prior number of votes for an account as of a block number

     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.

     * @param account The address of the account to check

     * @param blockNumber The block number to get the vote balance at

     * @return The number of votes the account had as of the given block

     */

    function getPriorVotes(address account, uint blockNumber)

        external

        view

        returns (uint256)

    {

        require(blockNumber < block.number, "MG::getPriorVotes: not yet determined");



        uint32 nCheckpoints = numCheckpoints[account];

        if (nCheckpoints == 0) {

            return 0;

        }



        // First check most recent balance

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {

            return checkpoints[account][nCheckpoints - 1].votes;

        }



        // Next check implicit zero balance

        if (checkpoints[account][0].fromBlock > blockNumber) {

            return 0;

        }



        uint32 lower = 0;

        uint32 upper = nCheckpoints - 1;

        while (upper > lower) {

            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow

            Checkpoint memory cp = checkpoints[account][center];

            if (cp.fromBlock == blockNumber) {

                return cp.votes;

            } else if (cp.fromBlock < blockNumber) {

                lower = center;

            } else {

                upper = center - 1;

            }

        }

        return checkpoints[account][lower].votes;

    }



    function _delegate(address delegator, address delegatee)

        internal

    {

        address currentDelegate = _delegates[delegator];

        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying MGs (not scaled);

        _delegates[delegator] = delegatee;



        emit DelegateChanged(delegator, currentDelegate, delegatee);



        _moveDelegates(currentDelegate, delegatee, delegatorBalance);

    }



    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {

            if (srcRep != address(0)) {

                // decrease old representative

                uint32 srcRepNum = numCheckpoints[srcRep];

                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;

                uint256 srcRepNew = srcRepOld.sub(amount);

                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);

            }



            if (dstRep != address(0)) {

                // increase new representative

                uint32 dstRepNum = numCheckpoints[dstRep];

                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;

                uint256 dstRepNew = dstRepOld.add(amount);

                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);

            }

        }

    }



    function _writeCheckpoint(

        address delegatee,

        uint32 nCheckpoints,

        uint256 oldVotes,

        uint256 newVotes

    )

        internal

    {

        uint32 blockNumber = safe32(block.number, "MG::_writeCheckpoint: block number exceeds 32 bits");



        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {

            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;

        } else {

            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);

            numCheckpoints[delegatee] = nCheckpoints + 1;

        }



        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);

    }



    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);

        return uint32(n);

    }



    function getChainId() internal pure returns (uint) {

        uint256 chainId;

        assembly { chainId := chainid() }

        return chainId;

    }

}

// ***************************************************************



interface IPlayerBook {

    function bindRefer( address from,string calldata  affCode )  external returns (bool);

    function hasRefer(address from) external returns(bool);

    function getPlayerLaffAddress(address from) external view returns(address);

    function _referLaffRewardRate() external view returns(uint256);

    function _referDevRewardRate() external view returns(uint256);

    function _baseRate() external view returns(uint256);

    function _teamWallet() external view returns(address);



}





// MasterChef is the master of MG. He can make MG and he is a fair guy.

//

// Note that it's ownable and the owner wields tremendous power. The ownership

// will be transferred to a governance smart contract once MG is sufficiently

// distributed and the community can show to govern itself.

//

// Have fun reading it. Hopefully it's bug-free. God bless.

contract MasterChef is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    // Info of each user.

    struct UserInfo {

        uint256 amount;     // How many LP tokens the user has provided.

        uint256 rewardDebt; // Reward debt. See explanation below.

        uint256 lastLockRewardBlock;

        uint256 haveReceivedReward;

        uint256 totalLockReward;

        //

        // We do some fancy math here. Basically, any point in time, the amount of MGs

        // entitled to a user but is pending to be distributed is:

        //

        //   pending reward = (user.amount * pool.accMGPerShare) - user.rewardDebt

        //

        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:

        //   1. The pool's `accMGPerShare` (and `lastRewardBlock`) gets updated.

        //   2. User receives the pending reward sent to his/her address.

        //   3. User's `amount` gets updated.

        //   4. User's `rewardDebt` gets updated.

    }



    // Info of each pool.

    struct PoolInfo {

        IERC20 lpToken;           // Address of LP token contract.

        uint256 allocPoint;       // How many allocation points assigned to this pool. MGs to distribute per block.

        uint256 lastRewardBlock;  // Last block number that MGs distribution occurs.

        uint256 accMGPerShare; // Accumulated MGs per share, times 1e12. See below.

    }



    // The MG TOKEN!

    MGToken public mg;



    // Block number when bonus MG period ends.

    uint256 public bonusEndBlock;

    // MG tokens created per block.

    uint256 public mgPerBlock;

    // The migrator contract. It has a lot of power. Can only be set through governance (owner).

    IMigratorChef public migrator;



    // Info of each pool.

    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    // Total allocation poitns. Must be the sum of all allocation points in all pools.

    uint256 public totalAllocPoint = 0;

    // The block number when MG mining starts.

    uint256 public startBlock;

    uint256 public weekBlock = 40320;

    uint256 public oneYearBlock = 2102400;

    uint256 public weeksBlock16 = 645120;

    uint256 public molecular = 7500;

    uint256 public rate = 9000;

    uint256 public denominator = 10000;



    uint256 public oneTwoBlock; // 1,2 end

    uint256 public threeBlock;  // 3 end

    uint256 public fourBlock;   // 4 end 

    uint256 public fiveBlock;   // 5 end

    uint256 public sixBlock;    // 6 end

    uint256 public sevenBlock;  // 7 end



    IPlayerBook public playerBook;

    

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);

    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);



    constructor(

        MGToken _mg,

        uint256 _mgPerBlock,

        uint256 _startBlock,

        uint256 _bonusEndBlock,

        address _playerBook

    ) public {

        require(_bonusEndBlock >= _startBlock.add(weekBlock.mul(9)), "_bonusEndBlock err");

        mg = _mg;

        mgPerBlock = _mgPerBlock;

        bonusEndBlock = _bonusEndBlock;

        startBlock = _startBlock;

        playerBook = IPlayerBook(_playerBook);



        oneTwoBlock = startBlock + 2*weekBlock;

        threeBlock = startBlock + 3*weekBlock; 

        fourBlock = startBlock + 4*weekBlock;  

        fiveBlock = startBlock + 5*weekBlock;  

        sixBlock = startBlock + 6*weekBlock;   

        sevenBlock = startBlock + 7*weekBlock; 

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

            accMGPerShare: 0

        }));

    }



    // Update the given pool's MG allocation point. Can only be called by the owner.

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {

            massUpdatePools();

        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);

        poolInfo[_pid].allocPoint = _allocPoint;

    }



    // Set the migrator contract. Can only be called by the owner.

    function setMigrator(IMigratorChef _migrator) public onlyOwner {

        migrator = _migrator;

    }



    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");

        PoolInfo storage pool = poolInfo[_pid];

        IERC20 lpToken = pool.lpToken;

        uint256 bal = lpToken.balanceOf(address(this));

        lpToken.safeApprove(address(migrator), bal);

        IERC20 newLpToken = migrator.migrate(lpToken);

        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");

        pool.lpToken = newLpToken;

    }



    // View function to see pending MGs on frontend.

    function pendingMG(uint256 _pid, address _user) public view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][_user];

        uint256 accMGPerShare = pool.accMGPerShare;

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {

            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

            uint256 mgReward = multiplier.mul(mgPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            accMGPerShare = accMGPerShare.add(mgReward.mul(1e12).div(lpSupply));

        }

        return user.amount.mul(accMGPerShare).div(1e12).sub(user.rewardDebt);

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

        uint256 mgReward = multiplier.mul(mgPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        mg.mint(address(this), mgReward);

        pool.accMGPerShare = pool.accMGPerShare.add(mgReward.mul(1e12).div(lpSupply));

        pool.lastRewardBlock = block.number;

    }



    // Deposit LP tokens to MasterChef for MG allocation.

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];



        if (user.amount > 0) {

            _withdraw(_pid, 0);

        } else {

            updatePool(_pid);

        }

        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        user.amount = user.amount.add(_amount);

        user.rewardDebt = user.amount.mul(pool.accMGPerShare).div(1e12);

        if(user.lastLockRewardBlock == 0  && block.number <= sevenBlock) {

            user.lastLockRewardBlock = block.number;

        }



        emit Deposit(msg.sender, _pid, _amount);

    }





    // Withdraw LP tokens from MasterChef.

    function withdraw(uint256 _pid, uint256 _amount) public {

        _withdraw(_pid, _amount);

        userInfo[_pid][msg.sender].amount = userInfo[_pid][msg.sender].amount.sub(_amount);

        userInfo[_pid][msg.sender].rewardDebt = userInfo[_pid][msg.sender].amount.mul(poolInfo[_pid].accMGPerShare).div(1e12);

        poolInfo[_pid].lpToken.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _pid, _amount);

    }





    function _withdraw(uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accMGPerShare).div(1e12).sub(user.rewardDebt);

        ///add

        address laffAddress = playerBook.getPlayerLaffAddress(msg.sender); // laff address

        address devAddress = playerBook._teamWallet(); //dev address

        uint256 laffRewardRate = playerBook._referLaffRewardRate(); //laff rate

        uint256 devRewardRate = playerBook._referDevRewardRate();

        uint256 baseRate = playerBook._baseRate();

        uint256 toLaff = pending.mul(laffRewardRate).div(baseRate);

        uint256 toDev = pending.mul(devRewardRate).div(baseRate);



        // 0 ~ 7 weeks

        if(block.number >= startBlock && block.number <= sevenBlock) {

            uint256 remain = pending.sub(toLaff).sub(toDev);

            uint256 lockAmount = remain.mul(molecular).div(denominator);



            safeMGTransfer(msg.sender, remain.sub(lockAmount));

            if(devAddress == laffAddress){

                safeMGTransfer(devAddress, toLaff.add(toDev));

            } else {

                safeMGTransfer(devAddress, toDev);

                safeMGTransfer(laffAddress, toLaff);

            }

            user.totalLockReward = user.totalLockReward.add(lockAmount);

            user.lastLockRewardBlock = block.number;

        } else if (block.number > sevenBlock && user.lastLockRewardBlock <= sevenBlock)  {

            uint256 comBlock = block.number.sub(user.lastLockRewardBlock);

            uint256 needBlock = sevenBlock.sub(user.lastLockRewardBlock);

            uint256 remain = pending.sub(toLaff).sub(toDev);

            uint256 lockAmount = remain.mul(molecular).mul(needBlock).div(comBlock).div(denominator);



            safeMGTransfer(msg.sender, remain.sub(lockAmount));

            if(devAddress == laffAddress){

                safeMGTransfer(devAddress, toLaff.add(toDev));

            } else {

                safeMGTransfer(devAddress, toDev);

                safeMGTransfer(laffAddress, toLaff);

            }

            user.totalLockReward = user.totalLockReward.add(lockAmount);

            user.lastLockRewardBlock = block.number;

        } else {

            /// send mg

            if(devAddress == laffAddress){

                safeMGTransfer(msg.sender, pending.sub(toLaff).sub(toDev));

                safeMGTransfer(devAddress, toLaff.add(toDev));

            } else {

                safeMGTransfer(msg.sender, pending.sub(toLaff).sub(toDev));

                safeMGTransfer(devAddress, toDev);

                safeMGTransfer(laffAddress, toLaff);

            }

        } 

    }



    function receiveLockedRewards(uint256 _pid) public {

        require(block.number >= startBlock.add(weeksBlock16), "not receive time");



        // after one year + 16 weeks

        if(block.number >= startBlock.add(oneYearBlock).add(weeksBlock16)) {

            safeMGTransfer(msg.sender, (userInfo[_pid][msg.sender].totalLockReward).sub(userInfo[_pid][msg.sender].haveReceivedReward));

            userInfo[_pid][msg.sender].haveReceivedReward = userInfo[_pid][msg.sender].totalLockReward;

            userInfo[_pid][msg.sender].lastLockRewardBlock = block.number;

        } else {

            if(userInfo[_pid][msg.sender].lastLockRewardBlock < startBlock.add(weeksBlock16)) {

                uint256 reward = userInfo[_pid][msg.sender].totalLockReward.mul(block.number.sub(startBlock.add(weeksBlock16))).div(oneYearBlock);

                safeMGTransfer(msg.sender, reward);

                userInfo[_pid][msg.sender].haveReceivedReward = userInfo[_pid][msg.sender].haveReceivedReward.add(reward);

                userInfo[_pid][msg.sender].lastLockRewardBlock = block.number;

            } else {

                uint256 reward = userInfo[_pid][msg.sender].totalLockReward.mul(block.number.sub(userInfo[_pid][msg.sender].lastLockRewardBlock)).div(oneYearBlock);

                safeMGTransfer(msg.sender, reward);

                userInfo[_pid][msg.sender].haveReceivedReward = userInfo[_pid][msg.sender].haveReceivedReward.add(reward);

                userInfo[_pid][msg.sender].lastLockRewardBlock = block.number;

            }

        }

    }



    // Withdraw without caring about rewards. EMERGENCY ONLY.

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][msg.sender];

        pool.lpToken.safeTransfer(address(msg.sender), user.amount);

        emit EmergencyWithdraw(msg.sender, _pid, user.amount);

        user.amount = 0;

        user.rewardDebt = 0;

    }



    // Safe mg transfer function, just in case if rounding error causes pool to not have enough MGs.

    function safeMGTransfer(address _to, uint256 _amount) internal {

            uint256 mgBal = mg.balanceOf(address(this));

        if (_amount > mgBal) {

            mg.transfer(_to, mgBal);

        } else {

            mg.transfer(_to, _amount);

        }

    }



    // Return reward multiplier over the given _from to _to block.

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        uint8 fromPeriod = getTimeInPeriod(_from);

        uint8 toPeriod = getTimeInPeriod(_to);



        uint256 _oneTwo;

        uint256 _three;

        uint256 _four;

        uint256 _five;

        uint256 _six;

        uint256 _seven;

        uint256 _eight;



        // 1,2 period, 1,2 period

        if(fromPeriod == 1 && toPeriod == 1) {

            return _to.sub(_from).mul(64);



        // 3 period, 3 period 

        } else if(fromPeriod == 2 && toPeriod == 2) {

            return _to.sub(_from).mul(32);



        // 4 period, 4 period 

        } else if(fromPeriod == 3 && toPeriod == 3) {

            return _to.sub(_from).mul(16);



        // 5 period, 5 period             

        } else if(fromPeriod == 4 && toPeriod == 4) {

            return _to.sub(_from).mul(8);



        // 6 period, 6 period            

        } else if(fromPeriod == 5 && toPeriod == 5) {

            return _to.sub(_from).mul(4);



        // 7 period, 7 period 

        } else if(fromPeriod == 6 && toPeriod == 6) {

            return _to.sub(_from).mul(2);



        // 8 period, 8 period             

        } else if(fromPeriod == 7 && toPeriod == 7) {

            return _to.sub(_from);



        // 8 period, out end period 

        } else if(fromPeriod == 7 && toPeriod == 8) {

            return bonusEndBlock.sub(_from);

            

        // 1,2 period, 3 period            

        } else if(fromPeriod == 1 && toPeriod == 2) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three = _to.sub(oneTwoBlock).mul(32);

            return _oneTwo.add(_three);



        // 1,2 period, 4 period  

        } else if(fromPeriod == 1 && toPeriod == 3) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three =  weekBlock.mul(32);

            _four = _to.sub(threeBlock).mul(16);

            return _oneTwo.add(_three).add(_four);



        // 1,2 period, 5 period  

        } else if(fromPeriod == 1 && toPeriod == 4) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three =  weekBlock.mul(32);

            _four = weekBlock.mul(16);

            _five = _to.sub(fourBlock).mul(8);

            return _oneTwo.add(_three).add(_four).add(_five);



        // 1,2 period, 6 period

        } else if(fromPeriod == 1 && toPeriod == 5) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three =  weekBlock.mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = _to.sub(fiveBlock).mul(4);

            return _oneTwo.add(_three).add(_four).add(_five).add(_six);



         // 1,2 period, 7 period           

        } else if(fromPeriod == 1 && toPeriod == 6) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three =  weekBlock.mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = _to.sub(sixBlock).mul(2);

            uint256 a = _oneTwo.add(_three).add(_four).add(_five);

            return a.add(_six).add(_seven);



        // 1,2 period, 8 ~ end period   

        }  else if(fromPeriod == 1 && toPeriod == 7) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three =  weekBlock.mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = _to.sub(sevenBlock);

            uint256 a = _oneTwo.add(_three).add(_four).add(_five).add(_six);

            return a.add(_seven).add(_eight);



        //1,2 period, out end period   

        } else if(fromPeriod == 1 && toPeriod == 8) {

            _oneTwo = oneTwoBlock.sub(_from).mul(64);

            _three =  weekBlock.mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = bonusEndBlock.sub(sevenBlock);

            uint256 a = _oneTwo.add(_three).add(_four).add(_five).add(_six);

            return a.add(_seven).add(_eight);



        // 3 period, 4 period           

        } else if(fromPeriod == 2 && toPeriod == 3) {

            _three = threeBlock.sub(_from).mul(32);

            _four = _to.sub(threeBlock).mul(16); 

            return _three.add(_four);



        // 3 period, 5 period             

        } else if(fromPeriod == 2 && toPeriod == 4) {

            _three = threeBlock.sub(_from).mul(32);

            _four = weekBlock.mul(16);

            _five = _to.sub(fourBlock).mul(8);

            return _three.add(_four).add(_five);



        // 3 period, 6 period    

        } else if(fromPeriod == 2 && toPeriod == 5) {

            _three = threeBlock.sub(_from).mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = _to.sub(fiveBlock).mul(4);

            return _three.add(_four).add(_five).add(_six);



        // 3 period, 7 period  

        } else if(fromPeriod == 2 && toPeriod == 6) {

            _three = threeBlock.sub(_from).mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = _to.sub(sixBlock).mul(2);

            return _three.add(_four).add(_five).add(_six).add(_seven);



        // 3 period, 8 ~ end period                

        } else if(fromPeriod == 2 && toPeriod == 7) {

            _three = threeBlock.sub(_from).mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = _to.sub(sevenBlock);

            return _three.add(_four).add(_five).add(_six).add(_seven).add(_eight);



        // 3 period,, out end period  

        } else if(fromPeriod == 2 && toPeriod == 8) {

            _three = threeBlock.sub(_from).mul(32);

            _four = weekBlock.mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = bonusEndBlock.sub(sevenBlock);

            return _three.add(_four).add(_five).add(_six).add(_seven).add(_eight);



         // 4 period, 5 period            

        } else if(fromPeriod == 3 && toPeriod == 4) {

            _four = fourBlock.sub(_from).mul(16);

            _five = _to.sub(fourBlock).mul(8);

            return _four.add(_five);



         // 4 period, 6 period              

        } else if(fromPeriod == 3 && toPeriod == 5) {

            _four = fourBlock.sub(_from).mul(16);

            _five = weekBlock.mul(8);

            _six = _to.sub(fiveBlock).mul(4);

            return _four.add(_five).add(_six);



         // 4 period, 7 period                

        } else if(fromPeriod == 3 && toPeriod == 6) {

            _four = fourBlock.sub(_from).mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = _to.sub(sixBlock).mul(2);

            return _four.add(_five).add(_six).add(_seven);



         // 4 period, 8 period              

        } else if(fromPeriod == 3 && toPeriod == 7) {

            _four = fourBlock.sub(_from).mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = _to.sub(sevenBlock);

            return _four.add(_five).add(_six).add(_seven).add(_eight);



         // 4 period, out end period           

        } else if(fromPeriod == 3 && toPeriod == 8) {

            _four = fourBlock.sub(_from).mul(16);

            _five = weekBlock.mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = bonusEndBlock.sub(sevenBlock);

            return _four.add(_five).add(_six).add(_seven).add(_eight);



        // 5 period, 6 period                 

        } else if(fromPeriod == 4 && toPeriod == 5) {

            _five = fiveBlock.sub(_from).mul(8);

            _six = _to.sub(fiveBlock).mul(4);

            return _five.add(_six);



        // 5 period, 7 period               

        } else if(fromPeriod == 4 && toPeriod == 6) {

            _five = fiveBlock.sub(_from).mul(8);

            _six = weekBlock.mul(4);

            _seven = _to.sub(sixBlock).mul(2);

            return _five.add(_six).add(_seven);



        // 5 period, 8 ~ end period                  

        } else if(fromPeriod == 4 && toPeriod == 7) {

            _five = fiveBlock.sub(_from).mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = _to.sub(sevenBlock);

            return _five.add(_six).add(_seven).add(_eight);



        //5 period, out end period       

        }  else if(fromPeriod == 4 && toPeriod == 8) {

            _five = fiveBlock.sub(_from).mul(8);

            _six = weekBlock.mul(4);

            _seven = weekBlock.mul(2);

            _eight = bonusEndBlock.sub(sevenBlock);

            return _five.add(_six).add(_seven).add(_eight);



        // 6 period, 7 period  

        } else if(fromPeriod == 5 && toPeriod == 6) {

            _six = sixBlock.sub(_from).mul(4);

            _seven = _to.sub(sixBlock).mul(2);

            return _six.add(_seven);



        // 6 period, 8 ~ end period               

        } else if(fromPeriod == 5 && toPeriod == 7) {

            _six = sixBlock.sub(_from).mul(4);

            _seven = weekBlock.mul(2);

            _eight = _to.sub(sevenBlock);

            return _six.add(_seven).add(_eight);



        //6 period, out end period  

        } else if(fromPeriod == 5 && toPeriod == 8) {

            _six = sixBlock.sub(_from).mul(4);

            _seven = weekBlock.mul(2);

            _eight = bonusEndBlock.sub(sevenBlock);

            return _six.add(_seven).add(_eight);



        // 7 period, 8 ~ end period                 

        } else if(fromPeriod == 6 && toPeriod == 7) {

            _seven = sevenBlock.sub(_from).mul(2);

            _eight = _to.sub(sevenBlock);

            return _seven.add(_eight);



        // 7 period, out end period   

        } else if(fromPeriod == 6 && toPeriod == 8) {

            _seven = sevenBlock.sub(_from).mul(2);

            _eight = bonusEndBlock.sub(sevenBlock);

            return _seven.add(_eight);



        } else {

            return 0;

        }



    }



    // Get period through block

    function getTimeInPeriod(uint256 _time) public view returns(uint8 _period) {

        // 1,2 period

        if(startBlock <= _time && _time < startBlock.add(weekBlock.mul(2))) {

            _period = 1; 

        // 3

        } else if(_time >= startBlock.add(weekBlock.mul(2)) &&  _time < startBlock.add(weekBlock.mul(3))) {

            _period = 2; 

        // 4

        } else if(_time >= startBlock.add(weekBlock.mul(3)) &&  _time < startBlock.add(weekBlock.mul(4))) {

            _period = 3;  

        // 5

        } else if(_time >= startBlock.add(weekBlock.mul(4)) &&  _time < startBlock.add(weekBlock.mul(5))) {

            _period = 4;  

        // 6 

        } else if(_time >= startBlock.add(weekBlock.mul(5)) &&  _time < startBlock.add(weekBlock.mul(6))) {

            _period = 5; 

        // 7 

        } else if(_time >= startBlock.add(weekBlock.mul(6)) &&  _time < startBlock.add(weekBlock.mul(7))) {

            _period = 6; 

        // 8 ~ end

        } else if(_time >= startBlock.add(weekBlock.mul(7)) &&  _time < bonusEndBlock) {

            _period = 7; 

        // > out end

        } else if(_time >= bonusEndBlock) {

            _period = 8; 

        } else {

            _period = 0; 

        }

    }



    function getCurrentPerBlock() public view returns(uint256) {

        uint8 period = getTimeInPeriod(block.number);

        if(period == 1) {

            return mgPerBlock.mul(64);

        }

        if(period == 2) {

            return mgPerBlock.mul(32);

        }

        if(period == 3) {

            return mgPerBlock.mul(16);

        }

        if(period == 4) {

            return mgPerBlock.mul(8);

        }

        if(period == 5) {

            return mgPerBlock.mul(4);

        }

        if(period == 6) {

            return mgPerBlock.mul(2);

        }

        if(period == 7) {

            return mgPerBlock;

        }



        return 0;

    }



    function getLockAmount(uint256 _pid, address _user) public view returns(uint256) {

        uint256 earn = pendingMG(_pid, _user);

        UserInfo storage user = userInfo[_pid][_user];

    

        // 0 ~ 7 weeks

        if(block.number >= startBlock && block.number <= sevenBlock) {

            uint256 lockAmount = earn.mul(rate).mul(molecular).div(denominator).div(denominator); 

            return lockAmount.add(user.totalLockReward);

        }



        if(block.number > sevenBlock && user.lastLockRewardBlock <= sevenBlock) {

            uint256 comBlock = block.number.sub(user.lastLockRewardBlock);

            uint256 needBlock = sevenBlock.sub(user.lastLockRewardBlock);

            uint256 amount = earn.mul(needBlock).div(comBlock);

            uint256 lockAmount = amount.mul(rate).mul(molecular).div(denominator).div(denominator);

            return lockAmount.add(user.totalLockReward);

        }



        return user.totalLockReward.sub(user.haveReceivedReward);

    }

    

    function getCurrBlockNumber() public view returns(uint256) {

        return block.number;

    }

}