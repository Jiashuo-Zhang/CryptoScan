/**

 *Submitted for verification at Etherscan.io on 2023-11-19

*/



// SPDX-License-Identifier: MIT



/*



███╗░░░███╗░█████╗░░██████╗░██╗░█████╗░██╗░░░██╗███████╗██████╗░░██████╗███████╗

████╗░████║██╔══██╗██╔════╝░██║██╔══██╗██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝

██╔████╔██║███████║██║░░██╗░██║██║░░╚═╝╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░

██║╚██╔╝██║██╔══██║██║░░╚██╗██║██║░░██╗░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░

██║░╚═╝░██║██║░░██║╚██████╔╝██║╚█████╔╝░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗

╚═╝░░░░░╚═╝╚═╝░░╚═╝░╚═════╝░╚═╝░╚════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝



*/



pragma solidity ^0.8.18;







/**

 * @dev Provides information about the current execution context, including the

 * sender of the transaction and its data. While these are generally available

 * via msg.sender and msg.data, they should not be accessed in such a direct

 * manner, since when dealing with meta-transactions the account sending and

 * paying for execution may not be the actual sender (as far as an application

 * is concerned).

 *

 * This contract is only required for intermediate, library-like contracts.

 */

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}



/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";



    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory) {

        // Inspired by OraclizeAPI's implementation - MIT licence

        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol



        if (value == 0) {

            return "0";

        }

        uint256 temp = value;

        uint256 digits;

        while (temp != 0) {

            digits++;

            temp /= 10;

        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {

            digits -= 1;

            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));

            value /= 10;

        }

        return string(buffer);

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.

     */

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {

            return "0x00";

        }

        uint256 temp = value;

        uint256 length = 0;

        while (temp != 0) {

            length++;

            temp >>= 8;

        }

        return toHexString(value, length);

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

     */

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);

        buffer[0] = "0";

        buffer[1] = "x";

        for (uint256 i = 2 * length + 1; i > 1; --i) {

            buffer[i] = _HEX_SYMBOLS[value & 0xf];

            value >>= 4;

        }

        require(value == 0, "Strings: hex length insufficient");

        return string(buffer);

    }

}

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

     *

     * [IMPORTANT]

     * ====

     * You shouldn't rely on `isContract` to protect against flash loan attacks!

     *

     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets

     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract

     * constructor.

     * ====

     */

    function isContract(address account) internal view returns (bool) {

        // This method relies on extcodesize/address.code.length, which returns 0

        // for contracts in construction, since the code is only stored at the end

        // of the constructor execution.



        return account.code.length > 0;

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



        (bool success, ) = recipient.call{value: amount}("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



    /**

     * @dev Performs a Solidity function call using a low level `call`. A

     * plain `call` is an unsafe replacement for a function call: use this

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

    function functionCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);

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

    function functionCallWithValue(

        address target,

        bytes memory data,

        uint256 value

    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }



    /**

     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but

     * with `errorMessage` as a fallback revert reason when `target` reverts.

     *

     * _Available since v3.1._

     */

    function functionCallWithValue(

        address target,

        bytes memory data,

        uint256 value,

        string memory errorMessage

    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        require(isContract(target), "Address: call to non-contract");



        (bool success, bytes memory returndata) = target.call{value: value}(data);

        return verifyCallResult(success, returndata, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but performing a static call.

     *

     * _Available since v3.3._

     */

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],

     * but performing a static call.

     *

     * _Available since v3.3._

     */

    function functionStaticCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");



        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResult(success, returndata, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but performing a delegate call.

     *

     * _Available since v3.4._

     */

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],

     * but performing a delegate call.

     *

     * _Available since v3.4._

     */

    function functionDelegateCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");



        (bool success, bytes memory returndata) = target.delegatecall(data);

        return verifyCallResult(success, returndata, errorMessage);

    }



    /**

     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the

     * revert reason using the provided one.

     *

     * _Available since v4.3._

     */

    function verifyCallResult(

        bool success,

        bytes memory returndata,

        string memory errorMessage

    ) internal pure returns (bytes memory) {

        if (success) {

            return returndata;

        } else {

            // Look for revert reason and bubble it up if present

            if (returndata.length > 0) {

                // The easiest way to bubble the revert reason is using memory via assembly



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



/**

 * @dev Wrappers over Solidity's arithmetic operations.

 *

 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler

 * now has built in overflow checking.

 */

library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            uint256 c = a + b;

            if (c < a) return (false, 0);

            return (true, c);

        }

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b > a) return (false, 0);

            return (true, a - b);

        }

    }



    /**

     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

            // benefit is lost if 'b' is also tested.

            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

            if (a == 0) return (true, 0);

            uint256 c = a * b;

            if (c / a != b) return (false, 0);

            return (true, c);

        }

    }



    /**

     * @dev Returns the division of two unsigned integers, with a division by zero flag.

     *

     * _Available since v3.4._

     */

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b == 0) return (false, 0);

            return (true, a / b);

        }

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.

     *

     * _Available since v3.4._

     */

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b == 0) return (false, 0);

            return (true, a % b);

        }

    }



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

        return a + b;

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

        return a - b;

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

        return a * b;

    }



    /**

     * @dev Returns the integer division of two unsigned integers, reverting on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator.

     *

     * Requirements:

     *

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * reverting when dividing by zero.

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

        return a % b;

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on

     * overflow (when the result is negative).

     *

     * CAUTION: This function is deprecated because it requires allocating memory for the error

     * message unnecessarily. For custom revert reasons use {trySub}.

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     *

     * - Subtraction cannot overflow.

     */

    function sub(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        unchecked {

            require(b <= a, errorMessage);

            return a - b;

        }

    }



    /**

     * @dev Returns the integer division of two unsigned integers, reverting with custom message on

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

    function div(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a / b;

        }

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * reverting with custom message when dividing by zero.

     *

     * CAUTION: This function is deprecated because it requires allocating memory for the error

     * message unnecessarily. For custom revert reasons use {tryMod}.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     *

     * - The divisor cannot be zero.

     */

    function mod(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a % b;

        }

    }

}



abstract contract ReentrancyGuard {

    // Booleans are more expensive than uint256 or any type that takes up a full

    // word because each write operation emits an extra SLOAD to first read the

    // slot's contents, replace the bits taken up by the boolean, and then write

    // back. This is the compiler's defense against contract upgrades and

    // pointer aliasing, and it cannot be disabled.



    // The values being non-zero value makes deployment a bit more expensive,

    // but in exchange the refund on every call to nonReentrant will be lower in

    // amount. Since refunds are capped to a percentage of the total

    // transaction's gas, it is best to keep them low in cases like this one, to

    // increase the likelihood of the full refund coming into effect.

    uint256 private constant _NOT_ENTERED = 1;

    uint256 private constant _ENTERED = 2;



    uint256 private _status;



    constructor() {

        _status = _NOT_ENTERED;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and making it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        // On the first call to nonReentrant, _notEntered will be true

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _status = _ENTERED;



        _;



        // By storing the original value once again, a refund is triggered (see

        // https://eips.ethereum.org/EIPS/eip-2200)

        _status = _NOT_ENTERED;

    }

}

/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20 {

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



    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `to`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address to, uint256 amount) external returns (bool);



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

     * @dev Moves `amount` tokens from `from` to `to` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

}





library SafeERC20 {

    using Address for address;



    function safeTransfer(

        IERC20 token,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(

        IERC20 token,

        address from,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    /**

     * @dev Deprecated. This function has issues similar to the ones found in

     * {IERC20-approve}, and its usage is discouraged.

     *

     * Whenever possible, use {safeIncreaseAllowance} and

     * {safeDecreaseAllowance} instead.

     */

    function safeApprove(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require(

            (value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        unchecked {

            uint256 oldAllowance = token.allowance(address(this), spender);

            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");

            uint256 newAllowance = oldAllowance - value;

            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

        }

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

        if (returndata.length > 0) {

            // Return data is optional

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}









interface IERC165 {

    /**

     * @dev Returns true if this contract implements the interface defined by

     * `interfaceId`. See the corresponding

     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]

     * to learn more about how these ids are created.

     *

     * This function call must use less than 30 000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



/**

 * @dev Implementation of the {IERC165} interface.

 *

 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check

 * for the additional interface id that will be supported. For example:

 *

 * ```solidity

 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);

 * }

 * ```

 *

 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.

 */

abstract contract ERC165 is IERC165 {

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}



/**

 * @dev External interface of AccessControl declared to support ERC165 detection.

 */

interface IAccessControl {

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

     * bearer except when using {AccessControl-_setupRole}.

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

    function hasRole(bytes32 role, address account) external view returns (bool);



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {AccessControl-_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) external view returns (bytes32);



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

    function grantRole(bytes32 role, address account) external;



    /**

     * @dev Revokes `role` from `account`.

     *

     * If `account` had been granted `role`, emits a {RoleRevoked} event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function revokeRole(bytes32 role, address account) external;



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

    function renounceRole(bytes32 role, address account) external;

}

/**

 * @dev Contract module that allows children to implement role-based access

 * control mechanisms. This is a lightweight version that doesn't allow enumerating role

 * members except through off-chain means by accessing the contract event logs. Some

 * applications may benefit from on-chain enumerability, for those cases see

 * {AccessControlEnumerable}.

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

abstract contract AccessControl is Context, IAccessControl, ERC165 {

    struct RoleData {

        mapping(address => bool) members;

        bytes32 adminRole;

    }



    mapping(bytes32 => RoleData) private _roles;



    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;



    /**

     * @dev Modifier that checks that an account has a specific role. Reverts

     * with a standardized message including the required role.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/

     *

     * _Available since v4.1._

     */

    modifier onlyRole(bytes32 role) {

        _checkRole(role);

        _;

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {

        return _roles[role].members[account];

    }



    /**

     * @dev Revert with a standard message if `_msgSender()` is missing `role`.

     * Overriding this function changes the behavior of the {onlyRole} modifier.

     *

     * Format of the revert message is described in {_checkRole}.

     *

     * _Available since v4.6._

     */

    function _checkRole(bytes32 role) internal view virtual {

        _checkRole(role, _msgSender());

    }



    /**

     * @dev Revert with a standard message if `account` is missing `role`.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/

     */

    function _checkRole(bytes32 role, address account) internal view virtual {

        if (!hasRole(role, account)) {

            revert(

                string(

                    abi.encodePacked(

                        "AccessControl: account ",

                        Strings.toHexString(uint160(account), 20),

                        " is missing role ",

                        Strings.toHexString(uint256(role), 32)

                    )

                )

            );

        }

    }



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {

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

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {

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

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {

        _revokeRole(role, account);

    }



    /**

     * @dev Revokes `role` from the calling account.

     *

     * Roles are often managed via {grantRole} and {revokeRole}: this function's

     * purpose is to provide a mechanism for accounts to lose their privileges

     * if they are compromised (such as when a trusted device is misplaced).

     *

     * If the calling account had been revoked `role`, emits a {RoleRevoked}

     * event.

     *

     * Requirements:

     *

     * - the caller must be `account`.

     */

    function renounceRole(bytes32 role, address account) public virtual override {

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

     *

     * NOTE: This function is deprecated in favor of {_grantRole}.

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

        bytes32 previousAdminRole = getRoleAdmin(role);

        _roles[role].adminRole = adminRole;

        emit RoleAdminChanged(role, previousAdminRole, adminRole);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * Internal function without access restriction.

     */

    function _grantRole(bytes32 role, address account) internal virtual {

        if (!hasRole(role, account)) {

            _roles[role].members[account] = true;

            emit RoleGranted(role, account, _msgSender());

        }

    }



    /**

     * @dev Revokes `role` from `account`.

     *

     * Internal function without access restriction.

     */

    function _revokeRole(bytes32 role, address account) internal virtual {

        if (hasRole(role, account)) {

            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, _msgSender());

        }

    }

}

/**

 * @dev Required interface of an ERC1155 compliant contract, as defined in the

 * https://eips.ethereum.org/EIPS/eip-1155[EIP].

 *

 * _Available since v3.1._

 */

interface IERC1155 is IERC165 {

    /**

     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.

     */

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);



    /**

     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all

     * transfers.

     */

    event TransferBatch(

        address indexed operator,

        address indexed from,

        address indexed to,

        uint256[] ids,

        uint256[] values

    );



    /**

     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to

     * `approved`.

     */

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);



    /**

     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.

     *

     * If an {URI} event was emitted for `id`, the standard

     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value

     * returned by {IERC1155MetadataURI-uri}.

     */

    event URI(string value, uint256 indexed id);



    /**

     * @dev Returns the amount of tokens of token type `id` owned by `account`.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     */

    function balanceOf(address account, uint256 id) external view returns (uint256);



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.

     *

     * Requirements:

     *

     * - `accounts` and `ids` must have the same length.

     */

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)

        external

        view

        returns (uint256[] memory);



    /**

     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,

     *

     * Emits an {ApprovalForAll} event.

     *

     * Requirements:

     *

     * - `operator` cannot be the caller.

     */

    function setApprovalForAll(address operator, bool approved) external;



    /**

     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.

     *

     * See {setApprovalForAll}.

     */

    function isApprovedForAll(address account, address operator) external view returns (bool);



    /**

     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.

     *

     * Emits a {TransferSingle} event.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.

     * - `from` must have a balance of tokens of type `id` of at least `amount`.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the

     * acceptance magic value.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 id,

        uint256 amount,

        bytes calldata data

    ) external;



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.

     *

     * Emits a {TransferBatch} event.

     *

     * Requirements:

     *

     * - `ids` and `amounts` must have the same length.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the

     * acceptance magic value.

     */

    function safeBatchTransferFrom(

        address from,

        address to,

        uint256[] calldata ids,

        uint256[] calldata amounts,

        bytes calldata data

    ) external;

}



/**

 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined

 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].

 *

 * _Available since v3.1._

 */

interface IERC1155MetadataURI is IERC1155 {

    /**

     * @dev Returns the URI for token type `id`.

     *

     * If the `\{id\}` substring is present in the URI, it must be replaced by

     * clients with the actual token type ID.

     */

    function uri(uint256 id) external view returns (string memory);

}



/**

 * @dev _Available since v3.1._

 */

interface IERC1155Receiver is IERC165 {

    /**

     * @dev Handles the receipt of a single ERC1155 token type. This function is

     * called at the end of a `safeTransferFrom` after the balance has been updated.

     *

     * NOTE: To accept the transfer, this must return

     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`

     * (i.e. 0xf23a6e61, or its own function selector).

     *

     * @param operator The address which initiated the transfer (i.e. msg.sender)

     * @param from The address which previously owned the token

     * @param id The ID of the token being transferred

     * @param value The amount of tokens being transferred

     * @param data Additional data with no specified format

     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed

     */

    function onERC1155Received(

        address operator,

        address from,

        uint256 id,

        uint256 value,

        bytes calldata data

    ) external returns (bytes4);



    /**

     * @dev Handles the receipt of a multiple ERC1155 token types. This function

     * is called at the end of a `safeBatchTransferFrom` after the balances have

     * been updated.

     *

     * NOTE: To accept the transfer(s), this must return

     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`

     * (i.e. 0xbc197c81, or its own function selector).

     *

     * @param operator The address which initiated the batch transfer (i.e. msg.sender)

     * @param from The address which previously owned the token

     * @param ids An array containing ids of each token being transferred (order and length must match values array)

     * @param values An array containing amounts of each token being transferred (order and length must match ids array)

     * @param data Additional data with no specified format

     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed

     */

    function onERC1155BatchReceived(

        address operator,

        address from,

        uint256[] calldata ids,

        uint256[] calldata values,

        bytes calldata data

    ) external returns (bytes4);

}



/**

 * @dev Implementation of the basic standard multi-token.

 * See https://eips.ethereum.org/EIPS/eip-1155

 * Originally based on code by Enjin: https://github.com/enjin/erc-1155

 *

 * _Available since v3.1._

 */

contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;



    // Mapping from token ID to account balances

    mapping(uint256 => mapping(address => uint256)) private _balances;



    // Mapping from account to operator approvals

    mapping(address => mapping(address => bool)) private _operatorApprovals;



    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json

    string private _uri;



    /**

     * @dev See {_setURI}.

     */

    constructor(string memory uri_) {

        _setURI(uri_);

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC1155).interfaceId ||

            interfaceId == type(IERC1155MetadataURI).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC1155MetadataURI-uri}.

     *

     * This implementation returns the same URI for *all* token types. It relies

     * on the token type ID substitution mechanism

     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].

     *

     * Clients calling this function must replace the `\{id\}` substring with the

     * actual token type ID.

     */

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;

    }



    /**

     * @dev See {IERC1155-balanceOf}.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     */

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: address zero is not a valid owner");

        return _balances[id][account];

    }



    /**

     * @dev See {IERC1155-balanceOfBatch}.

     *

     * Requirements:

     *

     * - `accounts` and `ids` must have the same length.

     */

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)

        public

        view

        virtual

        override

        returns (uint256[] memory)

    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");



        uint256[] memory batchBalances = new uint256[](accounts.length);



        for (uint256 i = 0; i < accounts.length; ++i) {

            batchBalances[i] = balanceOf(accounts[i], ids[i]);

        }



        return batchBalances;

    }



    /**

     * @dev See {IERC1155-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC1155-isApprovedForAll}.

     */

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];

    }



    /**

     * @dev See {IERC1155-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 id,

        uint256 amount,

        bytes memory data

    ) public virtual override {

        require(

            from == _msgSender() || isApprovedForAll(from, _msgSender()),

            "ERC1155: caller is not owner nor approved"

        );

        _safeTransferFrom(from, to, id, amount, data);

    }



    /**

     * @dev See {IERC1155-safeBatchTransferFrom}.

     */

    function safeBatchTransferFrom(

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) public virtual override {

        require(

            from == _msgSender() || isApprovedForAll(from, _msgSender()),

            "ERC1155: transfer caller is not owner nor approved"

        );

        _safeBatchTransferFrom(from, to, ids, amounts, data);

    }



    /**

     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.

     *

     * Emits a {TransferSingle} event.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `from` must have a balance of tokens of type `id` of at least `amount`.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the

     * acceptance magic value.

     */

    function _safeTransferFrom(

        address from,

        address to,

        uint256 id,

        uint256 amount,

        bytes memory data

    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");



        address operator = _msgSender();

        uint256[] memory ids = _asSingletonArray(id);

        uint256[] memory amounts = _asSingletonArray(amount);



        _beforeTokenTransfer(operator, from, to, ids, amounts, data);



        uint256 fromBalance = _balances[id][from];

        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

        unchecked {

            _balances[id][from] = fromBalance - amount;

        }

        _balances[id][to] += amount;



        emit TransferSingle(operator, from, to, id, amount);



        _afterTokenTransfer(operator, from, to, ids, amounts, data);



        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);

    }



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.

     *

     * Emits a {TransferBatch} event.

     *

     * Requirements:

     *

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the

     * acceptance magic value.

     */

    function _safeBatchTransferFrom(

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        require(to != address(0), "ERC1155: transfer to the zero address");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, from, to, ids, amounts, data);



        for (uint256 i = 0; i < ids.length; ++i) {

            uint256 id = ids[i];

            uint256 amount = amounts[i];



            uint256 fromBalance = _balances[id][from];

            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

            unchecked {

                _balances[id][from] = fromBalance - amount;

            }

            _balances[id][to] += amount;

        }



        emit TransferBatch(operator, from, to, ids, amounts);



        _afterTokenTransfer(operator, from, to, ids, amounts, data);



        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);

    }



    /**

     * @dev Sets a new URI for all token types, by relying on the token type ID

     * substitution mechanism

     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].

     *

     * By this mechanism, any occurrence of the `\{id\}` substring in either the

     * URI or any of the amounts in the JSON file at said URI will be replaced by

     * clients with the token type ID.

     *

     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be

     * interpreted by clients as

     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`

     * for token type ID 0x4cce0.

     *

     * See {uri}.

     *

     * Because these URIs cannot be meaningfully represented by the {URI} event,

     * this function emits no events.

     */

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;

    }



    /**

     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.

     *

     * Emits a {TransferSingle} event.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the

     * acceptance magic value.

     */

    function _mint(

        address to,

        uint256 id,

        uint256 amount,

        bytes memory data

    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");



        address operator = _msgSender();

        uint256[] memory ids = _asSingletonArray(id);

        uint256[] memory amounts = _asSingletonArray(amount);



        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);



        _balances[id][to] += amount;

        emit TransferSingle(operator, address(0), to, id, amount);



        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);



        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);

    }



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.

     *

     * Emits a {TransferBatch} event.

     *

     * Requirements:

     *

     * - `ids` and `amounts` must have the same length.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the

     * acceptance magic value.

     */

    function _mintBatch(

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);



        for (uint256 i = 0; i < ids.length; i++) {

            _balances[ids[i]][to] += amounts[i];

        }



        emit TransferBatch(operator, address(0), to, ids, amounts);



        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);



        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);

    }



    /**

     * @dev Destroys `amount` tokens of token type `id` from `from`

     *

     * Emits a {TransferSingle} event.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `from` must have at least `amount` tokens of token type `id`.

     */

    function _burn(

        address from,

        uint256 id,

        uint256 amount

    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");



        address operator = _msgSender();

        uint256[] memory ids = _asSingletonArray(id);

        uint256[] memory amounts = _asSingletonArray(amount);



        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");



        uint256 fromBalance = _balances[id][from];

        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");

        unchecked {

            _balances[id][from] = fromBalance - amount;

        }



        emit TransferSingle(operator, from, address(0), id, amount);



        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");

    }



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.

     *

     * Emits a {TransferBatch} event.

     *

     * Requirements:

     *

     * - `ids` and `amounts` must have the same length.

     */

    function _burnBatch(

        address from,

        uint256[] memory ids,

        uint256[] memory amounts

    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");



        for (uint256 i = 0; i < ids.length; i++) {

            uint256 id = ids[i];

            uint256 amount = amounts[i];



            uint256 fromBalance = _balances[id][from];

            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");

            unchecked {

                _balances[id][from] = fromBalance - amount;

            }

        }



        emit TransferBatch(operator, from, address(0), ids, amounts);



        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");

    }



    /**

     * @dev Approve `operator` to operate on all of `owner` tokens

     *

     * Emits an {ApprovalForAll} event.

     */

    function _setApprovalForAll(

        address owner,

        address operator,

        bool approved

    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[owner][operator] = approved;

        emit ApprovalForAll(owner, operator, approved);

    }



    /**

     * @dev Hook that is called before any token transfer. This includes minting

     * and burning, as well as batched variants.

     *

     * The same hook is called on both single and batched variants. For single

     * transfers, the length of the `ids` and `amounts` arrays will be 1.

     *

     * Calling conditions (for each `id` and `amount` pair):

     *

     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * of token type `id` will be  transferred to `to`.

     * - When `from` is zero, `amount` tokens of token type `id` will be minted

     * for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`

     * will be burned.

     * - `from` and `to` are never both zero.

     * - `ids` and `amounts` have the same, non-zero length.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) internal virtual {}



    /**

     * @dev Hook that is called after any token transfer. This includes minting

     * and burning, as well as batched variants.

     *

     * The same hook is called on both single and batched variants. For single

     * transfers, the length of the `id` and `amount` arrays will be 1.

     *

     * Calling conditions (for each `id` and `amount` pair):

     *

     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * of token type `id` will be  transferred to `to`.

     * - When `from` is zero, `amount` tokens of token type `id` will be minted

     * for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`

     * will be burned.

     * - `from` and `to` are never both zero.

     * - `ids` and `amounts` have the same, non-zero length.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _afterTokenTransfer(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) internal virtual {}



    function _doSafeTransferAcceptanceCheck(

        address operator,

        address from,

        address to,

        uint256 id,

        uint256 amount,

        bytes memory data

    ) private {

        if (to.isContract()) {

            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {

                if (response != IERC1155Receiver.onERC1155Received.selector) {

                    revert("ERC1155: ERC1155Receiver rejected tokens");

                }

            } catch Error(string memory reason) {

                revert(reason);

            } catch {

                revert("ERC1155: transfer to non ERC1155Receiver implementer");

            }

        }

    }



    function _doSafeBatchTransferAcceptanceCheck(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) private {

        if (to.isContract()) {

            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (

                bytes4 response

            ) {

                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {

                    revert("ERC1155: ERC1155Receiver rejected tokens");

                }

            } catch Error(string memory reason) {

                revert(reason);

            } catch {

                revert("ERC1155: transfer to non ERC1155Receiver implementer");

            }

        }

    }



    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);

        array[0] = element;



        return array;

    }

}



/**

 * @dev Extension of {ERC1155} that allows token holders to destroy both their

 * own tokens and those that they have been approved to use.

 *

 * _Available since v3.1._

 */

abstract contract ERC1155Burnable is ERC1155 {

    function burn(

        address account,

        uint256 id,

        uint256 value

    ) public virtual {

        require(

            account == _msgSender() || isApprovedForAll(account, _msgSender()),

            "ERC1155: caller is not owner nor approved"

        );



        _burn(account, id, value);

    }



    function burnBatch(

        address account,

        uint256[] memory ids,

        uint256[] memory values

    ) public virtual {

        require(

            account == _msgSender() || isApprovedForAll(account, _msgSender()),

            "ERC1155: caller is not owner nor approved"

        );



        _burnBatch(account, ids, values);

    }

}



/**

 * @dev Extension of ERC1155 that adds tracking of total supply per id.

 *

 * Useful for scenarios where Fungible and Non-fungible tokens have to be

 * clearly identified. Note: While a totalSupply of 1 might mean the

 * corresponding is an NFT, there is no guarantees that no other token with the

 * same id are not going to be minted.

 */

abstract contract ERC1155Supply is ERC1155 {

    mapping(uint256 => uint256) private _totalSupply;



    /**

     * @dev Total amount of tokens in with a given id.

     */

    function totalSupply(uint256 id) public view virtual returns (uint256) {

        return _totalSupply[id];

    }



    /**

     * @dev Indicates whether any token exist with a given id, or not.

     */

    function exists(uint256 id) public view virtual returns (bool) {

        return ERC1155Supply.totalSupply(id) > 0;

    }



    /**

     * @dev See {ERC1155-_beforeTokenTransfer}.

     */

    function _beforeTokenTransfer(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) internal virtual override {

        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);



        if (from == address(0)) {

            for (uint256 i = 0; i < ids.length; ++i) {

                _totalSupply[ids[i]] += amounts[i];

            }

        }



        if (to == address(0)) {

            for (uint256 i = 0; i < ids.length; ++i) {

                uint256 id = ids[i];

                uint256 amount = amounts[i];

                uint256 supply = _totalSupply[id];

                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");

                unchecked {

                    _totalSupply[id] = supply - amount;

                }

            }

        }

    }

}

contract Oracle {

    address admin;

    uint public rand;

    constructor(uint _rand)  {

        admin = msg.sender;

        rand = _rand;

    }



    function createrandomness(uint _rand) external {

        require(msg.sender == admin);

        rand = _rand;

    }

}





contract MagicAssets is ERC1155, AccessControl, ERC1155Burnable,ERC1155Supply,ReentrancyGuard {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    Oracle private oracle;

    

    string public name = "Magic Assets";

    string public symbol = "MA";

    uint public UnstakePen = 5;

    address payable private Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 

    uint public CombineshardsMultiplier = 50;

    uint256 public accPointsperShare;

    uint256 public timePoolLastUpdate;

    uint256 public PoolPointsMulti = 1; 

    uint256 public PoolFee = 50;

    uint256 public totalnfts = 0;

    uint256 public totaltomint = 2000;

    uint256 public MINT_PRICE = 1000000*1e18;

    IERC20 public Orb;

    uint256 nonce;

    

    constructor(address _Orb, address oracleaddress) ERC1155("https://gateway.pinata.cloud/ipfs/QmYmBh6t3Sxx4ksSeNTekocYzccKVgr1Dd6mq84DMzprGy/{id}.json") {

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _grantRole(MINTER_ROLE, msg.sender);

        Orb = IERC20(_Orb);

        oracle = Oracle(oracleaddress);

    }

    

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)

        internal

        override(ERC1155, ERC1155Supply)

    {

        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

    }



     function supportsInterface(bytes4 interfaceId)

        public

        view

        override(ERC1155, AccessControl)

        returns (bool)

    {

        return super.supportsInterface(interfaceId);

    }



    event _Combineresult (

        address indexed reciever,

        uint256 indexed tokenId

     );



    struct Staker { 

    uint256 initialtimestamp;

    uint256 rewardDebt;

    uint256 points;

    uint256 staked;

    }



    mapping (address => Staker) public Stakers;

    

    

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {

        _setURI(newuri);

    }

    

    function mintMagicAssets(address account, uint256 id, uint256 amount) external onlyRole(MINTER_ROLE) {

        _mint(account, id, amount, "");

    }   

    

    function mintMagicAssetsBanch(address account, uint256[] memory ids, uint256[] memory amounts) external onlyRole(MINTER_ROLE) {

       for(uint i=0;i<ids.length;i++){

        _mint(account, ids[i], amounts[i], "");

       }

    }   

    

    function burnMagicAssetsBanch(address account, uint256[] memory ids, uint256[] memory amounts) external onlyRole(MINTER_ROLE) {

       for(uint i=0;i<ids.length;i++){

       _burn(account,ids[i],amounts[i]);

       }

    }   



    function OpenMagicBox(uint256 amount) public {   

        require((totalnfts + amount) <= totaltomint, "All Minted");

        uint256 TotalPirce = amount.mul(MINT_PRICE);

        require(Orb.balanceOf(msg.sender) >= TotalPirce, "Not enough Orb tokens");

        uint256 Poolamount = TotalPirce.mul(PoolFee).div(100);

        uint256 Burnamount = TotalPirce - Poolamount;

        nonce ++;

        uint256 rand;

        uint[] memory Idamount = new uint[](5);

        for (uint i=0;i<amount;i++){ 

        rand = uint256 (keccak256(abi.encodePacked(nonce, oracle.rand(),rand,i, block.timestamp, msg.sender)))%100;

         if (rand >=0 && rand <=53) {

        Idamount[0] ++;

        }

        if (rand >=54 && rand <=79) {

        Idamount[1] ++;

        }

        if (rand >=80 && rand <=93) {

        Idamount[2] ++;

        }

        if (rand >=94 && rand <=98) {

        Idamount[3] ++;

        }

         if (rand == 99) {

        Idamount[4] ++;

        }

        }

        uint len;

        for (uint y=0;y<5;y++){

            if(Idamount[y]>0){

                len++;

            }

        }

        uint[] memory ids = new uint[](len);

        uint[] memory idamounts = new uint[](len);

        uint counter;

        for (uint z=0;z<5;z++){

            if(Idamount[z]>0){

               ids[counter] = z;

               idamounts[counter] = Idamount[z]; 

               counter ++;

            }

        }

        totalnfts = totalnfts + amount;

        Orb.safeTransferFrom(msg.sender,Wallet_Burn, Burnamount);

        Orb.safeTransferFrom(msg.sender,address(Orb), Poolamount);

        _mintBatch(msg.sender,ids,idamounts,"");

    }

    

   function changeavailableNFTs(uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {

       totaltomint = amount;

   }

 

    function setMintPrice(uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {

        MINT_PRICE = amount;

    }



    function setCombineshardsMultiplier(uint amount) public onlyRole(DEFAULT_ADMIN_ROLE) {

        CombineshardsMultiplier = amount;

    }



    function changeMintToken(address newtoken) public onlyRole(DEFAULT_ADMIN_ROLE) {

        Orb = IERC20(newtoken);

    }

    

    function changePoolFee(uint256 newPoolFee) public onlyRole(DEFAULT_ADMIN_ROLE) {

        PoolFee = newPoolFee;

    }



    function changeUnstakePen(uint256 newUnstakePen) public onlyRole(DEFAULT_ADMIN_ROLE) {

        UnstakePen = newUnstakePen;

    }



    function changePointsMulti(uint256 _PoolPointsMulti) public onlyRole(DEFAULT_ADMIN_ROLE) {

        updatePool();

        PoolPointsMulti = _PoolPointsMulti;

    }



    function combine(uint256 id,uint packOfMagicShards) public {

        require (packOfMagicShards < 5);

        require (id<4, "Can't use Sun Runes");

        require (balanceOf(msg.sender,id) >= 5, "not enough NFTs");

        

        uint256 rand = uint256 (keccak256(abi.encodePacked(nonce, oracle.rand(), block.timestamp, msg.sender)))%100;

        

        uint amountOfMagicShards = packOfMagicShards.mul(CombineshardsMultiplier);

        uint boost = (packOfMagicShards.mul(20)).add(20);



        uint chanceOf2tiersup = boost;



        if (id<3){ 



          if (rand >= chanceOf2tiersup) {

           _burn(msg.sender,id,5);

           _burn(msg.sender,5,amountOfMagicShards);

           _mint(msg.sender,id+1,1,"");

           emit _Combineresult(

             msg.sender,

             id+1

           );

          }



          if (rand < chanceOf2tiersup) {

           _burn(msg.sender,id,5);

           _burn(msg.sender,5,amountOfMagicShards);

           _mint(msg.sender,id+2,1,"");

           emit _Combineresult(

             msg.sender,

             id+2

           );

          }



        }



        if (id==3) {

           _burn(msg.sender,id,5);

           _mint(msg.sender,id+1,1,"");

           emit _Combineresult(

             msg.sender,

             id+1

           );

        }

       

    }

    

    uint256 PointsPerMagicShard = 500000000000;



    function Change_PointsPerMagicShard (uint256 new_PointsPerMagicShard) external onlyRole(DEFAULT_ADMIN_ROLE) {

    PointsPerMagicShard = new_PointsPerMagicShard;

    }



    function deposit (uint256 amount) public nonReentrant{

        require(Orb.balanceOf(msg.sender)>=amount);

        Staker storage staker = Stakers[msg.sender];

        claim_magicshards();

        

        

        staker.initialtimestamp = block.timestamp;

        

        staker.staked = staker.staked.add(amount);

        

        staker.rewardDebt = accPointsperShare * staker.staked / 1e18; 

        

        Orb.safeTransferFrom(msg.sender,address(this),amount);

    }

    

    function withdraw (uint256 amount) public nonReentrant{

         Staker storage staker = Stakers[msg.sender];

         require (staker.staked>=amount);



         claim_magicshards();

         staker.staked = staker.staked - amount;

         staker.rewardDebt = accPointsperShare * staker.staked / 1e18; 

         

         uint256 amounttowithdraw = amount;

         uint256 timeStaked = block.timestamp - staker.initialtimestamp;

         if (timeStaked < 30 days && UnstakePen > 0){

          uint256 penalty = amount.mul(UnstakePen).div(100);

          uint256 amountforContract = penalty.div(2);

          uint256 amountforBurn = penalty.sub(amountforContract);

          amounttowithdraw = amount.sub(penalty);

          Orb.safeTransfer(address(Orb), amountforContract);

          Orb.safeTransfer(Wallet_Burn, amountforBurn);

         }

         Orb.safeTransfer(msg.sender, amounttowithdraw);

    }

    

    function claim_magicshards() public {

         updatePool();

         Staker storage staker = Stakers[msg.sender];

         uint256 newPointsForUser = (accPointsperShare * staker.staked / 1e18) - staker.rewardDebt;

         if (newPointsForUser == 0) {

            staker.rewardDebt = accPointsperShare * staker.staked / 1e18; 

            return;

        }

        staker.rewardDebt = accPointsperShare * staker.staked / 1e18;   

        uint256 userTotalPoints = staker.points + newPointsForUser;

        if (userTotalPoints < PointsPerMagicShard){

             staker.points = userTotalPoints;

             return;

        }



        uint magicshards = userTotalPoints.div(PointsPerMagicShard);



         staker.points = userTotalPoints.mod(PointsPerMagicShard);



         _mint(msg.sender,5,magicshards,"");   

    }

    function updatePool () public {

        if (block.timestamp <= timePoolLastUpdate){

            return;

        }

        uint256 TotalOrbBalance = Orb.balanceOf(address(this));

        if (TotalOrbBalance == 0) {

            timePoolLastUpdate = block.timestamp; 

            return;

        }

        uint256 newPointsToReward = (block.timestamp.sub(timePoolLastUpdate)).mul(PoolPointsMulti); 

        timePoolLastUpdate = block.timestamp;  

        accPointsperShare = accPointsperShare + newPointsToReward;  

    }



    function checkpendingpoints () public view returns(uint256) {

        Staker storage staker = Stakers[msg.sender];

        uint256 newPointsToReward = (block.timestamp.sub(timePoolLastUpdate)).mul(PoolPointsMulti); 

        uint256 newaccPointsPerShare = accPointsperShare + newPointsToReward; 

        uint256 newPointsForUser = (newaccPointsPerShare * staker.staked / 1e18) - staker.rewardDebt;

        uint256 pending_reward = staker.points + newPointsForUser;

        return  pending_reward;

    }



    function onERC1155Received(

        address operator,

        address from,

        uint256 id,

        uint256 value,

        bytes calldata data

    ) external returns (bytes4) {

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));

    }

  

    

}