// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



// SPDX-License-Identifier: MIT



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



// File: @openzeppelin/contracts/utils/EnumerableSet.sol







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

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

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



// File: @openzeppelin/contracts/access/AccessControl.sol







pragma solidity ^0.6.0;









/**

 * @dev Contract module that allows children to implement role-based access

 * control mechanisms.

 *

 * Roles are referred to by their `bytes32` identifier. These should be exposed

 * in the external API and be unique. The best way to achieve this is by

 * using `public constant` hash digests:

 *

 * ```

 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");

 * ```

 *

 * Roles can be used to represent a set of permissions. To restrict access to a

 * function call, use {hasRole}:

 *

 * ```

 * function foo() public {

 *     require(hasRole(MY_ROLE, msg.sender));

 *     ...

 * }

 * ```

 *

 * Roles can be granted and revoked dynamically via the {grantRole} and

 * {revokeRole} functions. Each role has an associated admin role, and only

 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.

 *

 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means

 * that only accounts with this role will be able to grant or revoke other

 * roles. More complex role relationships can be created by using

 * {_setRoleAdmin}.

 *

 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to

 * grant and revoke this role. Extra precautions should be taken to secure

 * accounts that have been granted it.

 */

abstract contract AccessControl is Context {

    using EnumerableSet for EnumerableSet.AddressSet;

    using Address for address;



    struct RoleData {

        EnumerableSet.AddressSet members;

        bytes32 adminRole;

    }



    mapping (bytes32 => RoleData) private _roles;



    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;



    /**

     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`

     *

     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite

     * {RoleAdminChanged} not being emitted signaling this.

     *

     * _Available since v3.1._

     */

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);



    /**

     * @dev Emitted when `account` is granted `role`.

     *

     * `sender` is the account that originated the contract call, an admin role

     * bearer except when using {_setupRole}.

     */

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Emitted when `account` is revoked `role`.

     *

     * `sender` is the account that originated the contract call:

     *   - if using `revokeRole`, it is the admin role bearer

     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)

     */

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) public view returns (bool) {

        return _roles[role].members.contains(account);

    }



    /**

     * @dev Returns the number of accounts that have `role`. Can be used

     * together with {getRoleMember} to enumerate all bearers of a role.

     */

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {

        return _roles[role].members.length();

    }



    /**

     * @dev Returns one of the accounts that have `role`. `index` must be a

     * value between 0 and {getRoleMemberCount}, non-inclusive.

     *

     * Role bearers are not sorted in any particular way, and their ordering may

     * change at any point.

     *

     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure

     * you perform all queries on the same block. See the following

     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]

     * for more information.

     */

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {

        return _roles[role].members.at(index);

    }



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {

        return _roles[role].adminRole;

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function grantRole(bytes32 role, address account) public virtual {

        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");



        _grantRole(role, account);

    }



    /**

     * @dev Revokes `role` from `account`.

     *

     * If `account` had been granted `role`, emits a {RoleRevoked} event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function revokeRole(bytes32 role, address account) public virtual {

        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");



        _revokeRole(role, account);

    }



    /**

     * @dev Revokes `role` from the calling account.

     *

     * Roles are often managed via {grantRole} and {revokeRole}: this function's

     * purpose is to provide a mechanism for accounts to lose their privileges

     * if they are compromised (such as when a trusted device is misplaced).

     *

     * If the calling account had been granted `role`, emits a {RoleRevoked}

     * event.

     *

     * Requirements:

     *

     * - the caller must be `account`.

     */

    function renounceRole(bytes32 role, address account) public virtual {

        require(account == _msgSender(), "AccessControl: can only renounce roles for self");



        _revokeRole(role, account);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event. Note that unlike {grantRole}, this function doesn't perform any

     * checks on the calling account.

     *

     * [WARNING]

     * ====

     * This function should only be called from the constructor when setting

     * up the initial roles for the system.

     *

     * Using this function in any other way is effectively circumventing the admin

     * system imposed by {AccessControl}.

     * ====

     */

    function _setupRole(bytes32 role, address account) internal virtual {

        _grantRole(role, account);

    }



    /**

     * @dev Sets `adminRole` as ``role``'s admin role.

     *

     * Emits a {RoleAdminChanged} event.

     */

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {

        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);

        _roles[role].adminRole = adminRole;

    }



    function _grantRole(bytes32 role, address account) private {

        if (_roles[role].members.add(account)) {

            emit RoleGranted(role, account, _msgSender());

        }

    }



    function _revokeRole(bytes32 role, address account) private {

        if (_roles[role].members.remove(account)) {

            emit RoleRevoked(role, account, _msgSender());

        }

    }

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



// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol



pragma solidity >=0.6.2;



interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);



    function addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);



    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol



pragma solidity >=0.6.2;





interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountETH);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}



// File: contracts/interfaces/IToken.sol







pragma solidity ^0.6.0;



interface IToken {

    function mint(address to, uint256 amount) external;



    function burn(address from, uint256 amount) external;

}



// File: contracts/interfaces/IAuction.sol







pragma solidity ^0.6.0;



interface IAuction {

    function callIncomeDailyTokensTrigger(uint256 amount) external;



    function callIncomeWeeklyTokensTrigger(uint256 amount) external;

}



// File: contracts/interfaces/IStaking.sol







pragma solidity ^0.6.0;



interface IStaking {

    function externalStake(

        uint256 amount,

        uint256 stakingDays,

        address staker

    ) external;

}



// File: contracts/Auction.sol







pragma solidity >=0.4.25 <0.7.0;

















contract Auction is IAuction, AccessControl {

    using SafeMath for uint256;



    event Bet(

        address indexed account,

        uint256 value,

        uint256 indexed auctionId,

        uint256 indexed time

    );



    event Withdraval(

        address indexed account,

        uint256 value,

        uint256 indexed auctionId,

        uint256 indexed time

    );



    event AuctionIsOver(uint256 eth, uint256 token, uint256 indexed auctionId);



    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    bytes32 public constant CALLER_ROLE = keccak256("CALLER_ROLE");



    struct AuctionReserves {

        uint256 eth;

        uint256 token;

        uint256 uniswapLastPrice;

        uint256 uniswapMiddlePrice;

    }



    struct UserBet {

        uint256 eth;

        address ref;

    }



    mapping(uint256 => AuctionReserves) public reservesOf;

    mapping(address => uint256[]) public auctionsOf;

    mapping(uint256 => mapping(address => UserBet)) public auctionBetOf;

    mapping(uint256 => mapping(address => bool)) public existAuctionsOf;



    uint256 public lastAuctionEventId;

    uint256 public start;

    uint256 public stepTimestamp;

    uint256 public uniswapPercent;

    address public mainToken;

    address public staking;

    address payable public uniswap;

    address payable public recipient;

    bool public init_;



    modifier onlyCaller() {

        require(

            hasRole(CALLER_ROLE, _msgSender()),

            "Caller is not a caller role"

        );

        _;

    }



    modifier onlyManager() {

        require(

            hasRole(MANAGER_ROLE, _msgSender()),

            "Caller is not a caller role"

        );

        _;

    }



    constructor() public {

        init_ = false;

    }



    function init(

        uint256 _stepTimestamp,

        address _manager,

        address _mainToken,

        address _staking,

        address payable _uniswap,

        address payable _recipient,

        address _nativeSwap,

        address _foreignSwap,

        address _subbalances

    ) external {

        require(!init_, "init is active");

        _setupRole(MANAGER_ROLE, _manager);

        _setupRole(CALLER_ROLE, _nativeSwap);

        _setupRole(CALLER_ROLE, _foreignSwap);

        _setupRole(CALLER_ROLE, _staking);

        _setupRole(CALLER_ROLE, _subbalances);

        start = now;

        stepTimestamp = _stepTimestamp;

        uniswapPercent = 20;

        mainToken = _mainToken;

        staking = _staking;

        uniswap = _uniswap;

        recipient = _recipient;

        init_ = true;

    }



    function auctionsOf_(address account)

        public

        view

        returns (uint256[] memory)

    {

        return auctionsOf[account];

    }



    function setUniswapPercent(uint256 percent) external onlyManager {

        uniswapPercent = percent;

    }



    function getUniswapLastPrice() public view returns (uint256) {

        address[] memory path = new address[](2);



        path[0] = IUniswapV2Router02(uniswap).WETH();

        path[1] = mainToken;



        uint256 price = IUniswapV2Router02(uniswap).getAmountsOut(

            1e18,

            path

        )[1];



        return price;

    }



    function getUniswapMiddlePriceForSevenDays() public view returns (uint256) {

        uint256 stepsFromStart = calculateStepsFromStart();



        uint256 index = stepsFromStart;

        uint256 sum;

        uint256 points;



        while (points != 7) {

            if (reservesOf[index].uniswapLastPrice != 0) {

                sum = sum.add(reservesOf[index].uniswapLastPrice);

                points = points.add(1);

            }



            if (index == 0) break;



            index = index.sub(1);

        }



        if (sum == 0) return getUniswapLastPrice();

        else return sum.div(points);

    }



    function _updatePrice() internal {

        uint256 stepsFromStart = calculateStepsFromStart();



        reservesOf[stepsFromStart].uniswapLastPrice = getUniswapLastPrice();



        reservesOf[stepsFromStart]

            .uniswapMiddlePrice = getUniswapMiddlePriceForSevenDays();

    }



    function bet(uint256 deadline, address ref) external payable {

        _saveAuctionData();

        _updatePrice();



        require(_msgSender() != ref, "msg.sender == ref");



        (

            uint256 toRecipient,

            uint256 toUniswap

        ) = _calculateRecipientAndUniswapAmountsToSend();



        _swapEth(toUniswap, deadline);



        uint256 stepsFromStart = calculateStepsFromStart();



        auctionBetOf[stepsFromStart][_msgSender()].ref = ref;



        auctionBetOf[stepsFromStart][_msgSender()]

            .eth = auctionBetOf[stepsFromStart][_msgSender()].eth.add(

            msg.value

        );



        if (!existAuctionsOf[stepsFromStart][_msgSender()]) {

            auctionsOf[_msgSender()].push(stepsFromStart);

            existAuctionsOf[stepsFromStart][_msgSender()] = true;

        }



        reservesOf[stepsFromStart].eth = reservesOf[stepsFromStart].eth.add(

            msg.value

        );



        recipient.transfer(toRecipient);



        emit Bet(msg.sender, msg.value, stepsFromStart, now);

    }



    function withdraw(uint256 auctionId) external {

        _saveAuctionData();

        _updatePrice();



        uint256 stepsFromStart = calculateStepsFromStart();



        require(stepsFromStart > auctionId, "auction is active");



        uint256 auctionETHUserBalance = auctionBetOf[auctionId][_msgSender()]

            .eth;



        auctionBetOf[auctionId][_msgSender()].eth = 0;



        require(auctionETHUserBalance > 0, "zero balance in auction");



        uint256 payout = _calculatePayout(auctionId, auctionETHUserBalance);



        uint256 uniswapPayoutWithPercent = _calculatePayoutWithUniswap(

            auctionId,

            auctionETHUserBalance,

            payout

        );



        if (payout > uniswapPayoutWithPercent) {

            uint256 nextWeeklyAuction = calculateNearestWeeklyAuction();



            reservesOf[nextWeeklyAuction].token = reservesOf[nextWeeklyAuction]

                .token

                .add(payout.sub(uniswapPayoutWithPercent));



            payout = uniswapPayoutWithPercent;

        }



        if (address(auctionBetOf[auctionId][_msgSender()].ref) == address(0)) {

            IToken(mainToken).burn(address(this), payout);



            IStaking(staking).externalStake(payout, 14, _msgSender());



            emit Withdraval(msg.sender, payout, stepsFromStart, now);

        } else {

            IToken(mainToken).burn(address(this), payout);



            (

                uint256 toRefMintAmount,

                uint256 toUserMintAmount

            ) = _calculateRefAndUserAmountsToMint(payout);



            payout = payout.add(toUserMintAmount);



            IStaking(staking).externalStake(payout, 14, _msgSender());



            emit Withdraval(msg.sender, payout, stepsFromStart, now);



            IStaking(staking).externalStake(

                toRefMintAmount,

                14,

                auctionBetOf[auctionId][_msgSender()].ref

            );

        }

    }



    function callIncomeDailyTokensTrigger(uint256 amount)

        external

        override

        onlyCaller

    {

        uint256 stepsFromStart = calculateStepsFromStart();

        uint256 nextAuctionId = stepsFromStart.add(1);



        reservesOf[nextAuctionId].token = reservesOf[nextAuctionId].token.add(

            amount

        );

    }



    function callIncomeWeeklyTokensTrigger(uint256 amount)

        external

        override

        onlyCaller

    {

        uint256 nearestWeeklyAuction = calculateNearestWeeklyAuction();



        reservesOf[nearestWeeklyAuction]

            .token = reservesOf[nearestWeeklyAuction].token.add(amount);

    }



    function calculateNearestWeeklyAuction() public view returns (uint256) {

        uint256 stepsFromStart = calculateStepsFromStart();

        return stepsFromStart.add(uint256(7).sub(stepsFromStart.mod(7)));

    }



    function calculateStepsFromStart() public view returns (uint256) {

        return now.sub(start).div(stepTimestamp);

    }



    function _calculatePayoutWithUniswap(

        uint256 auctionId,

        uint256 amount,

        uint256 payout

    ) internal view returns (uint256) {

        uint256 uniswapPayout = reservesOf[auctionId]

            .uniswapMiddlePrice

            .mul(amount)

            .div(1e18);



        uint256 uniswapPayoutWithPercent = uniswapPayout.add(

            uniswapPayout.mul(uniswapPercent).div(100)

        );



        if (payout > uniswapPayoutWithPercent) {

            return uniswapPayoutWithPercent;

        } else {

            return payout;

        }

    }



    function _calculatePayout(uint256 auctionId, uint256 amount)

        internal

        view

        returns (uint256)

    {

        return

            amount.mul(reservesOf[auctionId].token).div(

                reservesOf[auctionId].eth

            );

    }



    function _calculateRecipientAndUniswapAmountsToSend()

        private

        returns (uint256, uint256)

    {

        uint256 toRecipient = msg.value.mul(20).div(100);

        uint256 toUniswap = msg.value.sub(toRecipient);



        return (toRecipient, toUniswap);

    }



    function _calculateRefAndUserAmountsToMint(uint256 amount)

        private

        pure

        returns (uint256, uint256)

    {

        uint256 toRefMintAmount = amount.mul(20).div(100);

        uint256 toUserMintAmount = amount.mul(10).div(100);



        return (toRefMintAmount, toUserMintAmount);

    }



    function _swapEth(uint256 amount, uint256 deadline) private {

        address[] memory path = new address[](2);



        path[0] = IUniswapV2Router02(uniswap).WETH();

        path[1] = mainToken;



        IUniswapV2Router02(uniswap).swapExactETHForTokens{value: amount}(

            0,

            path,

            staking,

            deadline

        );

    }



    function _saveAuctionData() internal {

        uint256 stepsFromStart = calculateStepsFromStart();

        AuctionReserves memory reserves = reservesOf[stepsFromStart];



        if (lastAuctionEventId < stepsFromStart) {

            emit AuctionIsOver(reserves.eth, reserves.token, stepsFromStart);

            lastAuctionEventId = stepsFromStart;

        }

    }

}