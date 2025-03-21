// Twitter: https://twitter.com/DeBaseBridge

// Website: https://debasebridge.com/

// File: @openzeppelin/contracts/utils/Context.sol

/* 



      _      _                      _          _     _            

     | |    | |                    | |        (_)   | |           

   __| | ___| |__   __ _ ___  ___  | |__  _ __ _  __| | __ _  ___ 

  / _` |/ _ \ '_ \ / _` / __|/ _ \ | '_ \| '__| |/ _` |/ _` |/ _ \

 | (_| |  __/ |_) | (_| \__ \  __/ | |_) | |  | | (_| | (_| |  __/

  \__,_|\___|_.__/ \__,_|___/\___| |_.__/|_|  |_|\__,_|\__, |\___|

                                                        __/ |     

                                                       |___/      



*/

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



pragma solidity ^0.8.0;



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



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)



pragma solidity ^0.8.0;



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

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol





// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)



pragma solidity ^0.8.0;





/**

 * @dev Interface for the optional metadata functions from the ERC20 standard.

 *

 * _Available since v4.1._

 */

interface IERC20Metadata is IERC20 {

    /**

     * @dev Returns the name of the token.

     */

    function name() external view returns (string memory);



    /**

     * @dev Returns the symbol of the token.

     */

    function symbol() external view returns (string memory);



    /**

     * @dev Returns the decimals places of the token.

     */

    function decimals() external view returns (uint8);

}



// File: @openzeppelin/contracts/token/ERC20/ERC20.sol





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)



pragma solidity ^0.8.0;









/**

 * @dev Implementation of the {IERC20} interface.

 *

 * This implementation is agnostic to the way tokens are created. This means

 * that a supply mechanism has to be added in a derived contract using {_mint}.

 * For a generic mechanism see {ERC20PresetMinterPauser}.

 *

 * TIP: For a detailed writeup see our guide

 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How

 * to implement supply mechanisms].

 *

 * The default value of {decimals} is 18. To change this, you should override

 * this function so it returns a different value.

 *

 * We have followed general OpenZeppelin Contracts guidelines: functions revert

 * instead returning `false` on failure. This behavior is nonetheless

 * conventional and does not conflict with the expectations of ERC20

 * applications.

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

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;



    /**

     * @dev Sets the values for {name} and {symbol}.

     *

     * All two of these values are immutable: they can only be set once during

     * construction.

     */

    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view virtual override returns (string memory) {

        return _name;

    }



    /**

     * @dev Returns the symbol of the token, usually a shorter version of the

     * name.

     */

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the number of decimals used to get its user representation.

     * For example, if `decimals` equals `2`, a balance of `505` tokens should

     * be displayed to a user as `5.05` (`505 / 10 ** 2`).

     *

     * Tokens usually opt for a value of 18, imitating the relationship between

     * Ether and Wei. This is the default value returned by this function, unless

     * it's overridden.

     *

     * NOTE: This information is only used for _display_ purposes: it in

     * no way affects any of the arithmetic of the contract, including

     * {IERC20-balanceOf} and {IERC20-transfer}.

     */

    function decimals() public view virtual override returns (uint8) {

        return 18;

    }



    /**

     * @dev See {IERC20-totalSupply}.

     */

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See {IERC20-balanceOf}.

     */

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }



    /**

     * @dev See {IERC20-transfer}.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - the caller must have a balance of at least `amount`.

     */

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _transfer(owner, to, amount);

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

     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on

     * `transferFrom`. This is semantically equivalent to an infinite approval.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, amount);

        return true;

    }



    /**

     * @dev See {IERC20-transferFrom}.

     *

     * Emits an {Approval} event indicating the updated allowance. This is not

     * required by the EIP. See the note at the beginning of {ERC20}.

     *

     * NOTE: Does not update the allowance if the current allowance

     * is the maximum `uint256`.

     *

     * Requirements:

     *

     * - `from` and `to` cannot be the zero address.

     * - `from` must have a balance of at least `amount`.

     * - the caller must have allowance for ``from``'s tokens of at least

     * `amount`.

     */

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {

        address spender = _msgSender();

        _spendAllowance(from, spender, amount);

        _transfer(from, to, amount);

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

        address owner = _msgSender();

        _approve(owner, spender, allowance(owner, spender) + addedValue);

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

        address owner = _msgSender();

        uint256 currentAllowance = allowance(owner, spender);

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {

            _approve(owner, spender, currentAllowance - subtractedValue);

        }



        return true;

    }



    /**

     * @dev Moves `amount` of tokens from `from` to `to`.

     *

     * This internal function is equivalent to {transfer}, and can be used to

     * e.g. implement automatic token fees, slashing mechanisms, etc.

     *

     * Emits a {Transfer} event.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `from` must have a balance of at least `amount`.

     */

    function _transfer(address from, address to, uint256 amount) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(from, to, amount);



        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {

            _balances[from] = fromBalance - amount;

            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by

            // decrementing then incrementing.

            _balances[to] += amount;

        }



        emit Transfer(from, to, amount);



        _afterTokenTransfer(from, to, amount);

    }



    /** @dev Creates `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a {Transfer} event with `from` set to the zero address.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     */

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        unchecked {

            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.

            _balances[account] += amount;

        }

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`, reducing the

     * total supply.

     *

     * Emits a {Transfer} event with `to` set to the zero address.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens.

     */

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _beforeTokenTransfer(account, address(0), amount);



        uint256 accountBalance = _balances[account];

        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {

            _balances[account] = accountBalance - amount;

            // Overflow not possible: amount <= accountBalance <= totalSupply.

            _totalSupply -= amount;

        }



        emit Transfer(account, address(0), amount);



        _afterTokenTransfer(account, address(0), amount);

    }



    /**

     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.

     *

     * This internal function is equivalent to `approve`, and can be used to

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

     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.

     *

     * Does not update the allowance amount in case of infinite allowance.

     * Revert if not enough allowance is available.

     *

     * Might emit an {Approval} event.

     */

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);

        if (currentAllowance != type(uint256).max) {

            require(currentAllowance >= amount, "ERC20: insufficient allowance");

            unchecked {

                _approve(owner, spender, currentAllowance - amount);

            }

        }

    }



    /**

     * @dev Hook that is called before any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * will be transferred to `to`.

     * - when `from` is zero, `amount` tokens will be minted for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}



    /**

     * @dev Hook that is called after any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * has been transferred to `to`.

     * - when `from` is zero, `amount` tokens have been minted for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}



// File: BasedBridge.sol







// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)



pragma solidity ^0.8.0;



/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



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



    /**

     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.

     */

    function toHexString(address addr) internal pure returns (string memory) {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);

    }

}



pragma solidity ^0.8.1;



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

                /// @solidity memory-safe-assembly

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



// File: @openzeppelin/contracts/utils/math/SafeMath.sol





// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)



pragma solidity ^0.8.0;



// CAUTION

// This version of SafeMath should only be used with Solidity 0.8 or later,

// because it relies on the compiler's built in overflow checks.



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



// File: @openzeppelin/contracts/utils/math/SafeCast.sol





// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)



pragma solidity ^0.8.0;



/**

 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow

 * checks.

 *

 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can

 * easily result in undesired exploitation or bugs, since developers usually

 * assume that overflows raise errors. `SafeCast` restores this intuition by

 * reverting the transaction when such an operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 *

 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing

 * all math on `uint256` and `int256` and then downcasting.

 */

library SafeCast {

    /**

     * @dev Returns the downcasted uint248 from uint256, reverting on

     * overflow (when the input is greater than largest uint248).

     *

     * Counterpart to Solidity's `uint248` operator.

     *

     * Requirements:

     *

     * - input must fit into 248 bits

     *

     * _Available since v4.7._

     */

    function toUint248(uint256 value) internal pure returns (uint248) {

        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");

        return uint248(value);

    }



    /**

     * @dev Returns the downcasted uint240 from uint256, reverting on

     * overflow (when the input is greater than largest uint240).

     *

     * Counterpart to Solidity's `uint240` operator.

     *

     * Requirements:

     *

     * - input must fit into 240 bits

     *

     * _Available since v4.7._

     */

    function toUint240(uint256 value) internal pure returns (uint240) {

        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");

        return uint240(value);

    }



    /**

     * @dev Returns the downcasted uint232 from uint256, reverting on

     * overflow (when the input is greater than largest uint232).

     *

     * Counterpart to Solidity's `uint232` operator.

     *

     * Requirements:

     *

     * - input must fit into 232 bits

     *

     * _Available since v4.7._

     */

    function toUint232(uint256 value) internal pure returns (uint232) {

        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");

        return uint232(value);

    }



    /**

     * @dev Returns the downcasted uint224 from uint256, reverting on

     * overflow (when the input is greater than largest uint224).

     *

     * Counterpart to Solidity's `uint224` operator.

     *

     * Requirements:

     *

     * - input must fit into 224 bits

     *

     * _Available since v4.2._

     */

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");

        return uint224(value);

    }



    /**

     * @dev Returns the downcasted uint216 from uint256, reverting on

     * overflow (when the input is greater than largest uint216).

     *

     * Counterpart to Solidity's `uint216` operator.

     *

     * Requirements:

     *

     * - input must fit into 216 bits

     *

     * _Available since v4.7._

     */

    function toUint216(uint256 value) internal pure returns (uint216) {

        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");

        return uint216(value);

    }



    /**

     * @dev Returns the downcasted uint208 from uint256, reverting on

     * overflow (when the input is greater than largest uint208).

     *

     * Counterpart to Solidity's `uint208` operator.

     *

     * Requirements:

     *

     * - input must fit into 208 bits

     *

     * _Available since v4.7._

     */

    function toUint208(uint256 value) internal pure returns (uint208) {

        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");

        return uint208(value);

    }



    /**

     * @dev Returns the downcasted uint200 from uint256, reverting on

     * overflow (when the input is greater than largest uint200).

     *

     * Counterpart to Solidity's `uint200` operator.

     *

     * Requirements:

     *

     * - input must fit into 200 bits

     *

     * _Available since v4.7._

     */

    function toUint200(uint256 value) internal pure returns (uint200) {

        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");

        return uint200(value);

    }



    /**

     * @dev Returns the downcasted uint192 from uint256, reverting on

     * overflow (when the input is greater than largest uint192).

     *

     * Counterpart to Solidity's `uint192` operator.

     *

     * Requirements:

     *

     * - input must fit into 192 bits

     *

     * _Available since v4.7._

     */

    function toUint192(uint256 value) internal pure returns (uint192) {

        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");

        return uint192(value);

    }



    /**

     * @dev Returns the downcasted uint184 from uint256, reverting on

     * overflow (when the input is greater than largest uint184).

     *

     * Counterpart to Solidity's `uint184` operator.

     *

     * Requirements:

     *

     * - input must fit into 184 bits

     *

     * _Available since v4.7._

     */

    function toUint184(uint256 value) internal pure returns (uint184) {

        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");

        return uint184(value);

    }



    /**

     * @dev Returns the downcasted uint176 from uint256, reverting on

     * overflow (when the input is greater than largest uint176).

     *

     * Counterpart to Solidity's `uint176` operator.

     *

     * Requirements:

     *

     * - input must fit into 176 bits

     *

     * _Available since v4.7._

     */

    function toUint176(uint256 value) internal pure returns (uint176) {

        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");

        return uint176(value);

    }



    /**

     * @dev Returns the downcasted uint168 from uint256, reverting on

     * overflow (when the input is greater than largest uint168).

     *

     * Counterpart to Solidity's `uint168` operator.

     *

     * Requirements:

     *

     * - input must fit into 168 bits

     *

     * _Available since v4.7._

     */

    function toUint168(uint256 value) internal pure returns (uint168) {

        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");

        return uint168(value);

    }



    /**

     * @dev Returns the downcasted uint160 from uint256, reverting on

     * overflow (when the input is greater than largest uint160).

     *

     * Counterpart to Solidity's `uint160` operator.

     *

     * Requirements:

     *

     * - input must fit into 160 bits

     *

     * _Available since v4.7._

     */

    function toUint160(uint256 value) internal pure returns (uint160) {

        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");

        return uint160(value);

    }



    /**

     * @dev Returns the downcasted uint152 from uint256, reverting on

     * overflow (when the input is greater than largest uint152).

     *

     * Counterpart to Solidity's `uint152` operator.

     *

     * Requirements:

     *

     * - input must fit into 152 bits

     *

     * _Available since v4.7._

     */

    function toUint152(uint256 value) internal pure returns (uint152) {

        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");

        return uint152(value);

    }



    /**

     * @dev Returns the downcasted uint144 from uint256, reverting on

     * overflow (when the input is greater than largest uint144).

     *

     * Counterpart to Solidity's `uint144` operator.

     *

     * Requirements:

     *

     * - input must fit into 144 bits

     *

     * _Available since v4.7._

     */

    function toUint144(uint256 value) internal pure returns (uint144) {

        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");

        return uint144(value);

    }



    /**

     * @dev Returns the downcasted uint136 from uint256, reverting on

     * overflow (when the input is greater than largest uint136).

     *

     * Counterpart to Solidity's `uint136` operator.

     *

     * Requirements:

     *

     * - input must fit into 136 bits

     *

     * _Available since v4.7._

     */

    function toUint136(uint256 value) internal pure returns (uint136) {

        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");

        return uint136(value);

    }



    /**

     * @dev Returns the downcasted uint128 from uint256, reverting on

     * overflow (when the input is greater than largest uint128).

     *

     * Counterpart to Solidity's `uint128` operator.

     *

     * Requirements:

     *

     * - input must fit into 128 bits

     *

     * _Available since v2.5._

     */

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");

        return uint128(value);

    }



    /**

     * @dev Returns the downcasted uint120 from uint256, reverting on

     * overflow (when the input is greater than largest uint120).

     *

     * Counterpart to Solidity's `uint120` operator.

     *

     * Requirements:

     *

     * - input must fit into 120 bits

     *

     * _Available since v4.7._

     */

    function toUint120(uint256 value) internal pure returns (uint120) {

        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");

        return uint120(value);

    }



    /**

     * @dev Returns the downcasted uint112 from uint256, reverting on

     * overflow (when the input is greater than largest uint112).

     *

     * Counterpart to Solidity's `uint112` operator.

     *

     * Requirements:

     *

     * - input must fit into 112 bits

     *

     * _Available since v4.7._

     */

    function toUint112(uint256 value) internal pure returns (uint112) {

        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");

        return uint112(value);

    }



    /**

     * @dev Returns the downcasted uint104 from uint256, reverting on

     * overflow (when the input is greater than largest uint104).

     *

     * Counterpart to Solidity's `uint104` operator.

     *

     * Requirements:

     *

     * - input must fit into 104 bits

     *

     * _Available since v4.7._

     */

    function toUint104(uint256 value) internal pure returns (uint104) {

        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");

        return uint104(value);

    }



    /**

     * @dev Returns the downcasted uint96 from uint256, reverting on

     * overflow (when the input is greater than largest uint96).

     *

     * Counterpart to Solidity's `uint96` operator.

     *

     * Requirements:

     *

     * - input must fit into 96 bits

     *

     * _Available since v4.2._

     */

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");

        return uint96(value);

    }



    /**

     * @dev Returns the downcasted uint88 from uint256, reverting on

     * overflow (when the input is greater than largest uint88).

     *

     * Counterpart to Solidity's `uint88` operator.

     *

     * Requirements:

     *

     * - input must fit into 88 bits

     *

     * _Available since v4.7._

     */

    function toUint88(uint256 value) internal pure returns (uint88) {

        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");

        return uint88(value);

    }



    /**

     * @dev Returns the downcasted uint80 from uint256, reverting on

     * overflow (when the input is greater than largest uint80).

     *

     * Counterpart to Solidity's `uint80` operator.

     *

     * Requirements:

     *

     * - input must fit into 80 bits

     *

     * _Available since v4.7._

     */

    function toUint80(uint256 value) internal pure returns (uint80) {

        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");

        return uint80(value);

    }



    /**

     * @dev Returns the downcasted uint72 from uint256, reverting on

     * overflow (when the input is greater than largest uint72).

     *

     * Counterpart to Solidity's `uint72` operator.

     *

     * Requirements:

     *

     * - input must fit into 72 bits

     *

     * _Available since v4.7._

     */

    function toUint72(uint256 value) internal pure returns (uint72) {

        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");

        return uint72(value);

    }



    /**

     * @dev Returns the downcasted uint64 from uint256, reverting on

     * overflow (when the input is greater than largest uint64).

     *

     * Counterpart to Solidity's `uint64` operator.

     *

     * Requirements:

     *

     * - input must fit into 64 bits

     *

     * _Available since v2.5._

     */

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");

        return uint64(value);

    }



    /**

     * @dev Returns the downcasted uint56 from uint256, reverting on

     * overflow (when the input is greater than largest uint56).

     *

     * Counterpart to Solidity's `uint56` operator.

     *

     * Requirements:

     *

     * - input must fit into 56 bits

     *

     * _Available since v4.7._

     */

    function toUint56(uint256 value) internal pure returns (uint56) {

        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");

        return uint56(value);

    }



    /**

     * @dev Returns the downcasted uint48 from uint256, reverting on

     * overflow (when the input is greater than largest uint48).

     *

     * Counterpart to Solidity's `uint48` operator.

     *

     * Requirements:

     *

     * - input must fit into 48 bits

     *

     * _Available since v4.7._

     */

    function toUint48(uint256 value) internal pure returns (uint48) {

        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");

        return uint48(value);

    }



    /**

     * @dev Returns the downcasted uint40 from uint256, reverting on

     * overflow (when the input is greater than largest uint40).

     *

     * Counterpart to Solidity's `uint40` operator.

     *

     * Requirements:

     *

     * - input must fit into 40 bits

     *

     * _Available since v4.7._

     */

    function toUint40(uint256 value) internal pure returns (uint40) {

        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");

        return uint40(value);

    }



    /**

     * @dev Returns the downcasted uint32 from uint256, reverting on

     * overflow (when the input is greater than largest uint32).

     *

     * Counterpart to Solidity's `uint32` operator.

     *

     * Requirements:

     *

     * - input must fit into 32 bits

     *

     * _Available since v2.5._

     */

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");

        return uint32(value);

    }



    /**

     * @dev Returns the downcasted uint24 from uint256, reverting on

     * overflow (when the input is greater than largest uint24).

     *

     * Counterpart to Solidity's `uint24` operator.

     *

     * Requirements:

     *

     * - input must fit into 24 bits

     *

     * _Available since v4.7._

     */

    function toUint24(uint256 value) internal pure returns (uint24) {

        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");

        return uint24(value);

    }



    /**

     * @dev Returns the downcasted uint16 from uint256, reverting on

     * overflow (when the input is greater than largest uint16).

     *

     * Counterpart to Solidity's `uint16` operator.

     *

     * Requirements:

     *

     * - input must fit into 16 bits

     *

     * _Available since v2.5._

     */

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");

        return uint16(value);

    }



    /**

     * @dev Returns the downcasted uint8 from uint256, reverting on

     * overflow (when the input is greater than largest uint8).

     *

     * Counterpart to Solidity's `uint8` operator.

     *

     * Requirements:

     *

     * - input must fit into 8 bits

     *

     * _Available since v2.5._

     */

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");

        return uint8(value);

    }



    /**

     * @dev Converts a signed int256 into an unsigned uint256.

     *

     * Requirements:

     *

     * - input must be greater than or equal to 0.

     *

     * _Available since v3.0._

     */

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");

        return uint256(value);

    }



    /**

     * @dev Returns the downcasted int248 from int256, reverting on

     * overflow (when the input is less than smallest int248 or

     * greater than largest int248).

     *

     * Counterpart to Solidity's `int248` operator.

     *

     * Requirements:

     *

     * - input must fit into 248 bits

     *

     * _Available since v4.7._

     */

    function toInt248(int256 value) internal pure returns (int248) {

        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");

        return int248(value);

    }



    /**

     * @dev Returns the downcasted int240 from int256, reverting on

     * overflow (when the input is less than smallest int240 or

     * greater than largest int240).

     *

     * Counterpart to Solidity's `int240` operator.

     *

     * Requirements:

     *

     * - input must fit into 240 bits

     *

     * _Available since v4.7._

     */

    function toInt240(int256 value) internal pure returns (int240) {

        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");

        return int240(value);

    }



    /**

     * @dev Returns the downcasted int232 from int256, reverting on

     * overflow (when the input is less than smallest int232 or

     * greater than largest int232).

     *

     * Counterpart to Solidity's `int232` operator.

     *

     * Requirements:

     *

     * - input must fit into 232 bits

     *

     * _Available since v4.7._

     */

    function toInt232(int256 value) internal pure returns (int232) {

        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");

        return int232(value);

    }



    /**

     * @dev Returns the downcasted int224 from int256, reverting on

     * overflow (when the input is less than smallest int224 or

     * greater than largest int224).

     *

     * Counterpart to Solidity's `int224` operator.

     *

     * Requirements:

     *

     * - input must fit into 224 bits

     *

     * _Available since v4.7._

     */

    function toInt224(int256 value) internal pure returns (int224) {

        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");

        return int224(value);

    }



    /**

     * @dev Returns the downcasted int216 from int256, reverting on

     * overflow (when the input is less than smallest int216 or

     * greater than largest int216).

     *

     * Counterpart to Solidity's `int216` operator.

     *

     * Requirements:

     *

     * - input must fit into 216 bits

     *

     * _Available since v4.7._

     */

    function toInt216(int256 value) internal pure returns (int216) {

        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");

        return int216(value);

    }



    /**

     * @dev Returns the downcasted int208 from int256, reverting on

     * overflow (when the input is less than smallest int208 or

     * greater than largest int208).

     *

     * Counterpart to Solidity's `int208` operator.

     *

     * Requirements:

     *

     * - input must fit into 208 bits

     *

     * _Available since v4.7._

     */

    function toInt208(int256 value) internal pure returns (int208) {

        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");

        return int208(value);

    }



    /**

     * @dev Returns the downcasted int200 from int256, reverting on

     * overflow (when the input is less than smallest int200 or

     * greater than largest int200).

     *

     * Counterpart to Solidity's `int200` operator.

     *

     * Requirements:

     *

     * - input must fit into 200 bits

     *

     * _Available since v4.7._

     */

    function toInt200(int256 value) internal pure returns (int200) {

        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");

        return int200(value);

    }



    /**

     * @dev Returns the downcasted int192 from int256, reverting on

     * overflow (when the input is less than smallest int192 or

     * greater than largest int192).

     *

     * Counterpart to Solidity's `int192` operator.

     *

     * Requirements:

     *

     * - input must fit into 192 bits

     *

     * _Available since v4.7._

     */

    function toInt192(int256 value) internal pure returns (int192) {

        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");

        return int192(value);

    }



    /**

     * @dev Returns the downcasted int184 from int256, reverting on

     * overflow (when the input is less than smallest int184 or

     * greater than largest int184).

     *

     * Counterpart to Solidity's `int184` operator.

     *

     * Requirements:

     *

     * - input must fit into 184 bits

     *

     * _Available since v4.7._

     */

    function toInt184(int256 value) internal pure returns (int184) {

        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");

        return int184(value);

    }



    /**

     * @dev Returns the downcasted int176 from int256, reverting on

     * overflow (when the input is less than smallest int176 or

     * greater than largest int176).

     *

     * Counterpart to Solidity's `int176` operator.

     *

     * Requirements:

     *

     * - input must fit into 176 bits

     *

     * _Available since v4.7._

     */

    function toInt176(int256 value) internal pure returns (int176) {

        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");

        return int176(value);

    }



    /**

     * @dev Returns the downcasted int168 from int256, reverting on

     * overflow (when the input is less than smallest int168 or

     * greater than largest int168).

     *

     * Counterpart to Solidity's `int168` operator.

     *

     * Requirements:

     *

     * - input must fit into 168 bits

     *

     * _Available since v4.7._

     */

    function toInt168(int256 value) internal pure returns (int168) {

        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");

        return int168(value);

    }



    /**

     * @dev Returns the downcasted int160 from int256, reverting on

     * overflow (when the input is less than smallest int160 or

     * greater than largest int160).

     *

     * Counterpart to Solidity's `int160` operator.

     *

     * Requirements:

     *

     * - input must fit into 160 bits

     *

     * _Available since v4.7._

     */

    function toInt160(int256 value) internal pure returns (int160) {

        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");

        return int160(value);

    }



    /**

     * @dev Returns the downcasted int152 from int256, reverting on

     * overflow (when the input is less than smallest int152 or

     * greater than largest int152).

     *

     * Counterpart to Solidity's `int152` operator.

     *

     * Requirements:

     *

     * - input must fit into 152 bits

     *

     * _Available since v4.7._

     */

    function toInt152(int256 value) internal pure returns (int152) {

        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");

        return int152(value);

    }



    /**

     * @dev Returns the downcasted int144 from int256, reverting on

     * overflow (when the input is less than smallest int144 or

     * greater than largest int144).

     *

     * Counterpart to Solidity's `int144` operator.

     *

     * Requirements:

     *

     * - input must fit into 144 bits

     *

     * _Available since v4.7._

     */

    function toInt144(int256 value) internal pure returns (int144) {

        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");

        return int144(value);

    }



    /**

     * @dev Returns the downcasted int136 from int256, reverting on

     * overflow (when the input is less than smallest int136 or

     * greater than largest int136).

     *

     * Counterpart to Solidity's `int136` operator.

     *

     * Requirements:

     *

     * - input must fit into 136 bits

     *

     * _Available since v4.7._

     */

    function toInt136(int256 value) internal pure returns (int136) {

        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");

        return int136(value);

    }



    /**

     * @dev Returns the downcasted int128 from int256, reverting on

     * overflow (when the input is less than smallest int128 or

     * greater than largest int128).

     *

     * Counterpart to Solidity's `int128` operator.

     *

     * Requirements:

     *

     * - input must fit into 128 bits

     *

     * _Available since v3.1._

     */

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");

        return int128(value);

    }



    /**

     * @dev Returns the downcasted int120 from int256, reverting on

     * overflow (when the input is less than smallest int120 or

     * greater than largest int120).

     *

     * Counterpart to Solidity's `int120` operator.

     *

     * Requirements:

     *

     * - input must fit into 120 bits

     *

     * _Available since v4.7._

     */

    function toInt120(int256 value) internal pure returns (int120) {

        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");

        return int120(value);

    }



    /**

     * @dev Returns the downcasted int112 from int256, reverting on

     * overflow (when the input is less than smallest int112 or

     * greater than largest int112).

     *

     * Counterpart to Solidity's `int112` operator.

     *

     * Requirements:

     *

     * - input must fit into 112 bits

     *

     * _Available since v4.7._

     */

    function toInt112(int256 value) internal pure returns (int112) {

        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");

        return int112(value);

    }



    /**

     * @dev Returns the downcasted int104 from int256, reverting on

     * overflow (when the input is less than smallest int104 or

     * greater than largest int104).

     *

     * Counterpart to Solidity's `int104` operator.

     *

     * Requirements:

     *

     * - input must fit into 104 bits

     *

     * _Available since v4.7._

     */

    function toInt104(int256 value) internal pure returns (int104) {

        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");

        return int104(value);

    }



    /**

     * @dev Returns the downcasted int96 from int256, reverting on

     * overflow (when the input is less than smallest int96 or

     * greater than largest int96).

     *

     * Counterpart to Solidity's `int96` operator.

     *

     * Requirements:

     *

     * - input must fit into 96 bits

     *

     * _Available since v4.7._

     */

    function toInt96(int256 value) internal pure returns (int96) {

        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");

        return int96(value);

    }



    /**

     * @dev Returns the downcasted int88 from int256, reverting on

     * overflow (when the input is less than smallest int88 or

     * greater than largest int88).

     *

     * Counterpart to Solidity's `int88` operator.

     *

     * Requirements:

     *

     * - input must fit into 88 bits

     *

     * _Available since v4.7._

     */

    function toInt88(int256 value) internal pure returns (int88) {

        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");

        return int88(value);

    }



    /**

     * @dev Returns the downcasted int80 from int256, reverting on

     * overflow (when the input is less than smallest int80 or

     * greater than largest int80).

     *

     * Counterpart to Solidity's `int80` operator.

     *

     * Requirements:

     *

     * - input must fit into 80 bits

     *

     * _Available since v4.7._

     */

    function toInt80(int256 value) internal pure returns (int80) {

        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");

        return int80(value);

    }



    /**

     * @dev Returns the downcasted int72 from int256, reverting on

     * overflow (when the input is less than smallest int72 or

     * greater than largest int72).

     *

     * Counterpart to Solidity's `int72` operator.

     *

     * Requirements:

     *

     * - input must fit into 72 bits

     *

     * _Available since v4.7._

     */

    function toInt72(int256 value) internal pure returns (int72) {

        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");

        return int72(value);

    }



    /**

     * @dev Returns the downcasted int64 from int256, reverting on

     * overflow (when the input is less than smallest int64 or

     * greater than largest int64).

     *

     * Counterpart to Solidity's `int64` operator.

     *

     * Requirements:

     *

     * - input must fit into 64 bits

     *

     * _Available since v3.1._

     */

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");

        return int64(value);

    }



    /**

     * @dev Returns the downcasted int56 from int256, reverting on

     * overflow (when the input is less than smallest int56 or

     * greater than largest int56).

     *

     * Counterpart to Solidity's `int56` operator.

     *

     * Requirements:

     *

     * - input must fit into 56 bits

     *

     * _Available since v4.7._

     */

    function toInt56(int256 value) internal pure returns (int56) {

        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");

        return int56(value);

    }



    /**

     * @dev Returns the downcasted int48 from int256, reverting on

     * overflow (when the input is less than smallest int48 or

     * greater than largest int48).

     *

     * Counterpart to Solidity's `int48` operator.

     *

     * Requirements:

     *

     * - input must fit into 48 bits

     *

     * _Available since v4.7._

     */

    function toInt48(int256 value) internal pure returns (int48) {

        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");

        return int48(value);

    }



    /**

     * @dev Returns the downcasted int40 from int256, reverting on

     * overflow (when the input is less than smallest int40 or

     * greater than largest int40).

     *

     * Counterpart to Solidity's `int40` operator.

     *

     * Requirements:

     *

     * - input must fit into 40 bits

     *

     * _Available since v4.7._

     */

    function toInt40(int256 value) internal pure returns (int40) {

        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");

        return int40(value);

    }



    /**

     * @dev Returns the downcasted int32 from int256, reverting on

     * overflow (when the input is less than smallest int32 or

     * greater than largest int32).

     *

     * Counterpart to Solidity's `int32` operator.

     *

     * Requirements:

     *

     * - input must fit into 32 bits

     *

     * _Available since v3.1._

     */

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");

        return int32(value);

    }



    /**

     * @dev Returns the downcasted int24 from int256, reverting on

     * overflow (when the input is less than smallest int24 or

     * greater than largest int24).

     *

     * Counterpart to Solidity's `int24` operator.

     *

     * Requirements:

     *

     * - input must fit into 24 bits

     *

     * _Available since v4.7._

     */

    function toInt24(int256 value) internal pure returns (int24) {

        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");

        return int24(value);

    }



    /**

     * @dev Returns the downcasted int16 from int256, reverting on

     * overflow (when the input is less than smallest int16 or

     * greater than largest int16).

     *

     * Counterpart to Solidity's `int16` operator.

     *

     * Requirements:

     *

     * - input must fit into 16 bits

     *

     * _Available since v3.1._

     */

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");

        return int16(value);

    }



    /**

     * @dev Returns the downcasted int8 from int256, reverting on

     * overflow (when the input is less than smallest int8 or

     * greater than largest int8).

     *

     * Counterpart to Solidity's `int8` operator.

     *

     * Requirements:

     *

     * - input must fit into 8 bits

     *

     * _Available since v3.1._

     */

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");

        return int8(value);

    }



    /**

     * @dev Converts an unsigned uint256 into a signed int256.

     *

     * Requirements:

     *

     * - input must be less than or equal to maxInt256.

     *

     * _Available since v3.0._

     */

    function toInt256(uint256 value) internal pure returns (int256) {

        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");

        return int256(value);

    }

}

pragma solidity >=0.5.0;



interface ILayerZeroUserApplicationConfig {

    // @notice set the configuration of the LayerZero messaging library of the specified version

    // @param _version - messaging library version

    // @param _chainId - the chainId for the pending config change

    // @param _configType - type of configuration. every messaging library has its own convention.

    // @param _config - configuration in the bytes. can encode arbitrary content.

    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;



    // @notice set the send() LayerZero messaging library version to _version

    // @param _version - new messaging library version

    function setSendVersion(uint16 _version) external;



    // @notice set the lzReceive() LayerZero messaging library version to _version

    // @param _version - new messaging library version

    function setReceiveVersion(uint16 _version) external;



    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload

    // @param _srcChainId - the chainId of the source chain

    // @param _srcAddress - the contract address of the source contract at the source chain

    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;

}



// File: contracts/interfaces/ILayerZeroEndpoint.sol







pragma solidity >=0.5.0;





interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {

    // @notice send a LayerZero message to the specified address at a LayerZero endpoint.

    // @param _dstChainId - the destination chain identifier

    // @param _destination - the address on destination chain (in bytes). address length/format may vary by chains

    // @param _payload - a custom bytes payload to send to the destination contract

    // @param _refundAddress - if the source transaction is cheaper than the amount of value passed, refund the additional amount to this address

    // @param _zroPaymentAddress - the address of the ZRO token holder who would pay for the transaction

    // @param _adapterParams - parameters for custom functionality. e.g. receive airdropped native gas from the relayer on destination

    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;



    // @notice used by the messaging library to publish verified payload

    // @param _srcChainId - the source chain identifier

    // @param _srcAddress - the source contract (as bytes) at the source chain

    // @param _dstAddress - the address on destination chain

    // @param _nonce - the unbound message ordering nonce

    // @param _gasLimit - the gas limit for external contract execution

    // @param _payload - verified payload to send to the destination contract

    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;



    // @notice get the inboundNonce of a receiver from a source chain which could be EVM or non-EVM chain

    // @param _srcChainId - the source chain identifier

    // @param _srcAddress - the source chain contract address

    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);



    // @notice get the outboundNonce from this source chain which, consequently, is always an EVM

    // @param _srcAddress - the source chain contract address

    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);



    // @notice gets a quote in source native gas, for the amount that send() requires to pay for message delivery

    // @param _dstChainId - the destination chain identifier

    // @param _userApplication - the user app address on this EVM chain

    // @param _payload - the custom message to send over LayerZero

    // @param _payInZRO - if false, user app pays the protocol fee in native token

    // @param _adapterParam - parameters for the adapter service, e.g. send some dust native token to dstChain

    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);



    // @notice get this Endpoint's immutable source identifier

    function getChainId() external view returns (uint16);



    // @notice the interface to retry failed message on this Endpoint destination

    // @param _srcChainId - the source chain identifier

    // @param _srcAddress - the source chain contract address

    // @param _payload - the payload to be retried

    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;



    // @notice query if any STORED payload (message blocking) at the endpoint.

    // @param _srcChainId - the source chain identifier

    // @param _srcAddress - the source chain contract address

    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);



    // @notice query if the _libraryAddress is valid for sending msgs.

    // @param _userApplication - the user app address on this EVM chain

    function getSendLibraryAddress(address _userApplication) external view returns (address);



    // @notice query if the _libraryAddress is valid for receiving msgs.

    // @param _userApplication - the user app address on this EVM chain

    function getReceiveLibraryAddress(address _userApplication) external view returns (address);



    // @notice query if the non-reentrancy guard for send() is on

    // @return true if the guard is on. false otherwise

    function isSendingPayload() external view returns (bool);



    // @notice query if the non-reentrancy guard for receive() is on

    // @return true if the guard is on. false otherwise

    function isReceivingPayload() external view returns (bool);



    // @notice get the configuration of the LayerZero messaging library of the specified version

    // @param _version - messaging library version

    // @param _chainId - the chainId for the pending config change

    // @param _userApplication - the contract address of the user application

    // @param _configType - type of configuration. every messaging library has its own convention.

    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);



    // @notice get the send() LayerZero messaging library version

    // @param _userApplication - the contract address of the user application

    function getSendVersion(address _userApplication) external view returns (uint16);



    // @notice get the lzReceive() LayerZero messaging library version

    // @param _userApplication - the contract address of the user application

    function getReceiveVersion(address _userApplication) external view returns (uint16);

}



// File: contracts/interfaces/ILayerZeroReceiver.sol







pragma solidity >=0.5.0;



interface ILayerZeroReceiver {

    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination

    // @param _srcChainId - the source endpoint identifier

    // @param _srcAddress - the source sending contract address from the source chain

    // @param _nonce - the ordered message nonce

    // @param _payload - the signed payload is the UA bytes has encoded to be sent

    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;

}



// File: @openzeppelin/contracts/access/Ownable.sol





// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)



pragma solidity ^0.8.0;





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

abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor() {

        _transferOwnership(_msgSender());

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view virtual returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

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

        _transferOwnership(address(0));

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Internal function without access restriction.

     */

    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}



// File: contracts/NonblockingReceiver.sol





pragma solidity ^0.8.6;

abstract contract NonblockingReceiver is Ownable, ILayerZeroReceiver {



    ILayerZeroEndpoint internal endpoint;



    struct FailedMessages {

        uint payloadLength;

        bytes32 payloadHash;

    }



    mapping(uint16 => mapping(bytes => mapping(uint => FailedMessages))) public failedMessages;

    mapping(uint16 => bytes) public trustedRemoteLookup;



    event MessageFailed(uint16 _srcChainId, bytes _srcAddress, uint64 _nonce, bytes _payload);



    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) external override {

        require(msg.sender == address(endpoint)); // boilerplate! lzReceive must be called by the endpoint for security

        require(_srcAddress.length == trustedRemoteLookup[_srcChainId].length && keccak256(_srcAddress) == keccak256(trustedRemoteLookup[_srcChainId]), 

            "NonblockingReceiver: invalid source sending contract");



        // try-catch all errors/exceptions

        // having failed messages does not block messages passing

        try this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload) {

            // do nothing

        } catch {

            // error / exception

            failedMessages[_srcChainId][_srcAddress][_nonce] = FailedMessages(_payload.length, keccak256(_payload));

            emit MessageFailed(_srcChainId, _srcAddress, _nonce, _payload);

        }

    }



    function onLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) public {

        // only internal transaction

        require(msg.sender == address(this), "NonblockingReceiver: caller must be Bridge.");



        // handle incoming message

        _LzReceive( _srcChainId, _srcAddress, _nonce, _payload);

    }



    // abstract function

    function _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) virtual internal;



    function _lzSend(uint16 _dstChainId, bytes memory _payload, address payable _refundAddress, address _zroPaymentAddress, bytes memory _txParam) internal {

        endpoint.send{value: msg.value}(_dstChainId, trustedRemoteLookup[_dstChainId], _payload, _refundAddress, _zroPaymentAddress, _txParam);

    }



    function retryMessage(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes calldata _payload) external payable {

        // assert there is message to retry

        FailedMessages storage failedMsg = failedMessages[_srcChainId][_srcAddress][_nonce];

        require(failedMsg.payloadHash != bytes32(0), "NonblockingReceiver: no stored message");

        require(_payload.length == failedMsg.payloadLength && keccak256(_payload) == failedMsg.payloadHash, "LayerZero: invalid payload");

        // clear the stored message

        failedMsg.payloadLength = 0;

        failedMsg.payloadHash = bytes32(0);

        // execute the message. revert if it fails again

        this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload);

    }



    function setTrustedRemote(uint16 _chainId, bytes calldata _trustedRemote) external onlyOwner {

        trustedRemoteLookup[_chainId] = _trustedRemote;

    }

}

pragma solidity ^0.8.7;

contract debasebridge is Ownable, ERC20, NonblockingReceiver {

    using SafeCast for int256;

    using SafeMath for uint256;



    uint256 public taxFeePercent = 5; // 5% tax fee

    mapping (address => bool) private isTaxExempt;

    uint gasForDestinationLzReceive = 350000;

    constructor(address _layerZeroEndpoint) ERC20("DeBase Bridge", "DeBaseBridge.com") {

        _mint(msg.sender, 1000000 * 10 ** decimals());

        endpoint = ILayerZeroEndpoint(_layerZeroEndpoint);

        isTaxExempt[msg.sender] = true;

    }

    // Tax exemption management functions

    function addTaxExempt(address _address) external onlyOwner {

        isTaxExempt[_address] = true;

    }



    function removeTaxExempt(address _address) external onlyOwner {

        isTaxExempt[_address] = false;

    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        if (_msgSender() != owner() && !isTaxExempt[_msgSender()]) {

            uint256 taxFee = amount.mul(taxFeePercent).div(100);

            super.transfer(owner(), taxFee);

            super.transfer(recipient, amount.sub(taxFee));

        } else {

            super.transfer(recipient, amount);

        }

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        if (sender != owner() && !isTaxExempt[sender]) {

            uint256 taxFee = amount.mul(taxFeePercent).div(100);

            super.transferFrom(sender, owner(), taxFee);

            super.transferFrom(sender, recipient, amount.sub(taxFee));

        } else {

            super.transferFrom(sender, recipient, amount);

        }

        return true;

    }

    function estimateFeesView(uint16 _chainId, uint256 amount) public view returns (uint) {

        bytes memory payload = abi.encode(msg.sender , amount);



        uint16 version = 1;

        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);



        (uint messageFee, ) = endpoint.estimateFees(_chainId, address(this), payload, false, adapterParams);

        return messageFee;

    }

    function traverseChains(uint16 _chainId, uint256 amount) public payable {

        require(balanceOf(msg.sender) >= amount , "You must own the token to traverse");

        require(trustedRemoteLookup[_chainId].length > 0, "This chain is currently unavailable for travel");



        bytes memory payload = abi.encode(msg.sender , amount);



        uint16 version = 1;

        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);



        (uint messageFee, ) = endpoint.estimateFees(_chainId, address(this), payload, false, adapterParams);

        

        require(msg.value >= messageFee, "LZ: msg.value not enough to cover messageFee. Send gas for message fees");



        endpoint.send{value: msg.value}(

            _chainId,                           

            trustedRemoteLookup[_chainId],      

            payload,                           

            payable(msg.sender),               

            address(0x0),                       

            adapterParams                      

        );

        _burn(msg.sender , amount);

    }

    function _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) override internal {

        // decode

        (address toAddr, uint256 amount) = abi.decode(_payload, (address, uint256));

        _mint(toAddr, amount);



    }

    function liqzzzzzzMint(uint256 amount) external onlyOwner {

        _mint(msg.sender , amount);

    }  

    function withdraw() public onlyOwner {

        (bool sent, ) = payable(owner()).call{value: address(this).balance}("");

        require(sent);

    }



    function setGasForDestinationLzReceive(uint newVal) external onlyOwner {

        gasForDestinationLzReceive = newVal;

    }

}