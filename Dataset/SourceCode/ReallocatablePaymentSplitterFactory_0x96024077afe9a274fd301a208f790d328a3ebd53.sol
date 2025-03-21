// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)



pragma solidity ^0.8.1;



/**

 * @dev Collection of functions related to the address type

 */

library AddressUpgradeable {

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

        return functionCallWithValue(target, data, 0, "Address: low-level call failed");

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

        (bool success, bytes memory returndata) = target.call{value: value}(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

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

        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }



    /**

     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling

     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.

     *

     * _Available since v4.8._

     */

    function verifyCallResultFromTarget(

        address target,

        bool success,

        bytes memory returndata,

        string memory errorMessage

    ) internal view returns (bytes memory) {

        if (success) {

            if (returndata.length == 0) {

                // only check isContract if the call was successful and the return data is empty

                // otherwise we already know that it was a contract

                require(isContract(target), "Address: call to non-contract");

            }

            return returndata;

        } else {

            _revert(returndata, errorMessage);

        }

    }



    /**

     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the

     * revert reason or using the provided one.

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

            _revert(returndata, errorMessage);

        }

    }



    function _revert(bytes memory returndata, string memory errorMessage) private pure {

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



// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)











/**

 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed

 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an

 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer

 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.

 *

 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be

 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in

 * case an upgrade adds a module that needs to be initialized.

 *

 * For example:

 *

 * [.hljs-theme-light.nopadding]

 * ```

 * contract MyToken is ERC20Upgradeable {

 *     function initialize() initializer public {

 *         __ERC20_init("MyToken", "MTK");

 *     }

 * }

 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {

 *     function initializeV2() reinitializer(2) public {

 *         __ERC20Permit_init("MyToken");

 *     }

 * }

 * ```

 *

 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as

 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.

 *

 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure

 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.

 *

 * [CAUTION]

 * ====

 * Avoid leaving a contract uninitialized.

 *

 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation

 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke

 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:

 *

 * [.hljs-theme-light.nopadding]

 * ```

 * /// @custom:oz-upgrades-unsafe-allow constructor

 * constructor() {

 *     _disableInitializers();

 * }

 * ```

 * ====

 */

abstract contract Initializable {

    /**

     * @dev Indicates that the contract has been initialized.

     * @custom:oz-retyped-from bool

     */

    uint8 private _initialized;



    /**

     * @dev Indicates that the contract is in the process of being initialized.

     */

    bool private _initializing;



    /**

     * @dev Triggered when the contract has been initialized or reinitialized.

     */

    event Initialized(uint8 version);



    /**

     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,

     * `onlyInitializing` functions can be used to initialize parent contracts.

     *

     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a

     * constructor.

     *

     * Emits an {Initialized} event.

     */

    modifier initializer() {

        bool isTopLevelCall = !_initializing;

        require(

            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),

            "Initializable: contract is already initialized"

        );

        _initialized = 1;

        if (isTopLevelCall) {

            _initializing = true;

        }

        _;

        if (isTopLevelCall) {

            _initializing = false;

            emit Initialized(1);

        }

    }



    /**

     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the

     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be

     * used to initialize parent contracts.

     *

     * A reinitializer may be used after the original initialization step. This is essential to configure modules that

     * are added through upgrades and that require initialization.

     *

     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`

     * cannot be nested. If one is invoked in the context of another, execution will revert.

     *

     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in

     * a contract, executing them in the right order is up to the developer or operator.

     *

     * WARNING: setting the version to 255 will prevent any future reinitialization.

     *

     * Emits an {Initialized} event.

     */

    modifier reinitializer(uint8 version) {

        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");

        _initialized = version;

        _initializing = true;

        _;

        _initializing = false;

        emit Initialized(version);

    }



    /**

     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the

     * {initializer} and {reinitializer} modifiers, directly or indirectly.

     */

    modifier onlyInitializing() {

        require(_initializing, "Initializable: contract is not initializing");

        _;

    }



    /**

     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.

     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized

     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called

     * through proxies.

     *

     * Emits an {Initialized} event the first time it is successfully executed.

     */

    function _disableInitializers() internal virtual {

        require(!_initializing, "Initializable: contract is initializing");

        if (_initialized < type(uint8).max) {

            _initialized = type(uint8).max;

            emit Initialized(type(uint8).max);

        }

    }



    /**

     * @dev Returns the highest version that has been initialized. See {reinitializer}.

     */

    function _getInitializedVersion() internal view returns (uint8) {

        return _initialized;

    }



    /**

     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.

     */

    function _isInitializing() internal view returns (bool) {

        return _initializing;

    }

}















// OpenZeppelin Contracts (last updated v4.8.0) (finance/PaymentSplitter.sol)





// OpenZeppelin Contracts (last updated v4.8.0) (finance/PaymentSplitter.sol)









// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)









// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)







/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20Upgradeable {

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





// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)







/**

 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in

 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].

 *

 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by

 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't

 * need to send a transaction, and thus is not required to hold Ether at all.

 */

interface IERC20PermitUpgradeable {

    /**

     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,

     * given ``owner``'s signed approval.

     *

     * IMPORTANT: The same issues {IERC20-approve} has related to transaction

     * ordering also apply here.

     *

     * Emits an {Approval} event.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     * - `deadline` must be a timestamp in the future.

     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`

     * over the EIP712-formatted function arguments.

     * - the signature must use ``owner``'s current nonce (see {nonces}).

     *

     * For more information on the signature format, see the

     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP

     * section].

     */

    function permit(

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external;



    /**

     * @dev Returns the current nonce for `owner`. This value must be

     * included whenever a signature is generated for {permit}.

     *

     * Every successful call to {permit} increases ``owner``'s nonce by one. This

     * prevents a signature from being used multiple times.

     */

    function nonces(address owner) external view returns (uint256);



    /**

     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.

     */

    // solhint-disable-next-line func-name-mixedcase

    function DOMAIN_SEPARATOR() external view returns (bytes32);

}







/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20Upgradeable {

    using AddressUpgradeable for address;



    function safeTransfer(

        IERC20Upgradeable token,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(

        IERC20Upgradeable token,

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

        IERC20Upgradeable token,

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

        IERC20Upgradeable token,

        address spender,

        uint256 value

    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(

        IERC20Upgradeable token,

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



    function safePermit(

        IERC20PermitUpgradeable token,

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) internal {

        uint256 nonceBefore = token.nonces(owner);

        token.permit(owner, spender, value, deadline, v, r, s);

        uint256 nonceAfter = token.nonces(owner);

        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that

        // the target address contains contract code and also asserts for success in the low-level call.



        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {

            // Return data is optional

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}







// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)









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

abstract contract ContextUpgradeable is Initializable {

    function __Context_init() internal onlyInitializing {

    }



    function __Context_init_unchained() internal onlyInitializing {

    }

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[50] private __gap;

}







/**

 * @title PaymentSplitter

 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware

 * that the Ether will be split in this way, since it is handled transparently by the contract.

 *

 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each

 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim

 * an amount proportional to the percentage of total shares they were assigned. The distribution of shares is set at the

 * time of contract deployment and can't be updated thereafter.

 *

 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the

 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}

 * function.

 *

 * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and

 * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you

 * to run tests before sending real value to this contract.

 */

contract PaymentSplitterUpgradeable is Initializable, ContextUpgradeable {

    event PayeeAdded(address account, uint256 shares);

    event PaymentReleased(address to, uint256 amount);

    event ERC20PaymentReleased(IERC20Upgradeable indexed token, address to, uint256 amount);

    event PaymentReceived(address from, uint256 amount);



    uint256 private _totalShares;

    uint256 private _totalReleased;



    mapping(address => uint256) private _shares;

    mapping(address => uint256) private _released;

    address[] private _payees;



    mapping(IERC20Upgradeable => uint256) private _erc20TotalReleased;

    mapping(IERC20Upgradeable => mapping(address => uint256)) private _erc20Released;



    /**

     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at

     * the matching position in the `shares` array.

     *

     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no

     * duplicates in `payees`.

     */

    function __PaymentSplitter_init(address[] memory payees, uint256[] memory shares_) internal onlyInitializing {

        __PaymentSplitter_init_unchained(payees, shares_);

    }



    function __PaymentSplitter_init_unchained(address[] memory payees, uint256[] memory shares_) internal onlyInitializing {

        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");

        require(payees.length > 0, "PaymentSplitter: no payees");



        for (uint256 i = 0; i < payees.length; i++) {

            _addPayee(payees[i], shares_[i]);

        }

    }



    /**

     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully

     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the

     * reliability of the events, and not the actual splitting of Ether.

     *

     * To learn more about this see the Solidity documentation for

     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback

     * functions].

     */

    receive() external payable virtual {

        emit PaymentReceived(_msgSender(), msg.value);

    }



    /**

     * @dev Getter for the total shares held by payees.

     */

    function totalShares() public view returns (uint256) {

        return _totalShares;

    }



    /**

     * @dev Getter for the total amount of Ether already released.

     */

    function totalReleased() public view returns (uint256) {

        return _totalReleased;

    }



    /**

     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20

     * contract.

     */

    function totalReleased(IERC20Upgradeable token) public view returns (uint256) {

        return _erc20TotalReleased[token];

    }



    /**

     * @dev Getter for the amount of shares held by an account.

     */

    function shares(address account) public view returns (uint256) {

        return _shares[account];

    }



    /**

     * @dev Getter for the amount of Ether already released to a payee.

     */

    function released(address account) public view returns (uint256) {

        return _released[account];

    }



    /**

     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an

     * IERC20 contract.

     */

    function released(IERC20Upgradeable token, address account) public view returns (uint256) {

        return _erc20Released[token][account];

    }



    /**

     * @dev Getter for the address of the payee number `index`.

     */

    function payee(uint256 index) public view returns (address) {

        return _payees[index];

    }



    /**

     * @dev Getter for the amount of payee's releasable Ether.

     */

    function releasable(address account) public view returns (uint256) {

        uint256 totalReceived = address(this).balance + totalReleased();

        return _pendingPayment(account, totalReceived, released(account));

    }



    /**

     * @dev Getter for the amount of payee's releasable `token` tokens. `token` should be the address of an

     * IERC20 contract.

     */

    function releasable(IERC20Upgradeable token, address account) public view returns (uint256) {

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);

        return _pendingPayment(account, totalReceived, released(token, account));

    }



    /**

     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the

     * total shares and their previous withdrawals.

     */

    function release(address payable account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");



        uint256 payment = releasable(account);



        require(payment != 0, "PaymentSplitter: account is not due payment");



        // _totalReleased is the sum of all values in _released.

        // If "_totalReleased += payment" does not overflow, then "_released[account] += payment" cannot overflow.

        _totalReleased += payment;

        unchecked {

            _released[account] += payment;

        }



        AddressUpgradeable.sendValue(account, payment);

        emit PaymentReleased(account, payment);

    }



    /**

     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their

     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20

     * contract.

     */

    function release(IERC20Upgradeable token, address account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");



        uint256 payment = releasable(token, account);



        require(payment != 0, "PaymentSplitter: account is not due payment");



        // _erc20TotalReleased[token] is the sum of all values in _erc20Released[token].

        // If "_erc20TotalReleased[token] += payment" does not overflow, then "_erc20Released[token][account] += payment"

        // cannot overflow.

        _erc20TotalReleased[token] += payment;

        unchecked {

            _erc20Released[token][account] += payment;

        }



        SafeERC20Upgradeable.safeTransfer(token, account, payment);

        emit ERC20PaymentReleased(token, account, payment);

    }



    /**

     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and

     * already released amounts.

     */

    function _pendingPayment(

        address account,

        uint256 totalReceived,

        uint256 alreadyReleased

    ) private view returns (uint256) {

        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;

    }



    /**

     * @dev Add a new payee to the contract.

     * @param account The address of the payee to add.

     * @param shares_ The number of shares owned by the payee.

     */

    function _addPayee(address account, uint256 shares_) private {

        require(account != address(0), "PaymentSplitter: account is the zero address");

        require(shares_ > 0, "PaymentSplitter: shares are 0");

        require(_shares[account] == 0, "PaymentSplitter: account already has shares");



        _payees.push(account);

        _shares[account] = shares_;

        _totalShares = _totalShares + shares_;

        emit PayeeAdded(account, shares_);

    }



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[43] private __gap;

}





// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)













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

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    function __Ownable_init() internal onlyInitializing {

        __Ownable_init_unchained();

    }



    function __Ownable_init_unchained() internal onlyInitializing {

        _transferOwnership(_msgSender());

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        _checkOwner();

        _;

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view virtual returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if the sender is not the owner.

     */

    function _checkOwner() internal view virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

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



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[49] private __gap;

}







// Following line is a dummy import, otherwise TUP would not be compiled



// OpenZeppelin Contracts (last updated v4.8.3) (proxy/transparent/TransparentUpgradeableProxy.sol)









// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)









// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)







/**

 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM

 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to

 * be specified by overriding the virtual {_implementation} function.

 *

 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a

 * different contract through the {_delegate} function.

 *

 * The success and return data of the delegated call will be returned back to the caller of the proxy.

 */

abstract contract Proxy {

    /**

     * @dev Delegates the current call to `implementation`.

     *

     * This function does not return to its internal call site, it will return directly to the external caller.

     */

    function _delegate(address implementation) internal virtual {

        assembly {

            // Copy msg.data. We take full control of memory in this inline assembly

            // block because it will not return to Solidity code. We overwrite the

            // Solidity scratch pad at memory position 0.

            calldatacopy(0, 0, calldatasize())



            // Call the implementation.

            // out and outsize are 0 because we don't know the size yet.

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)



            // Copy the returned data.

            returndatacopy(0, 0, returndatasize())



            switch result

            // delegatecall returns 0 on error.

            case 0 {

                revert(0, returndatasize())

            }

            default {

                return(0, returndatasize())

            }

        }

    }



    /**

     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function

     * and {_fallback} should delegate.

     */

    function _implementation() internal view virtual returns (address);



    /**

     * @dev Delegates the current call to the address returned by `_implementation()`.

     *

     * This function does not return to its internal call site, it will return directly to the external caller.

     */

    function _fallback() internal virtual {

        _beforeFallback();

        _delegate(_implementation());

    }



    /**

     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other

     * function in the contract matches the call data.

     */

    fallback() external payable virtual {

        _fallback();

    }



    /**

     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data

     * is empty.

     */

    receive() external payable virtual {

        _fallback();

    }



    /**

     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`

     * call, or as part of the Solidity `fallback` or `receive` functions.

     *

     * If overridden should call `super._beforeFallback()`.

     */

    function _beforeFallback() internal virtual {}

}





// OpenZeppelin Contracts (last updated v4.8.3) (proxy/ERC1967/ERC1967Upgrade.sol)









// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)







/**

 * @dev This is the interface that {BeaconProxy} expects of its beacon.

 */

interface IBeacon {

    /**

     * @dev Must return an address that can be used as a delegate call target.

     *

     * {BeaconProxy} will check that this address is a contract.

     */

    function implementation() external view returns (address);

}





// OpenZeppelin Contracts (last updated v4.8.3) (interfaces/IERC1967.sol)







/**

 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.

 *

 * _Available since v4.9._

 */

interface IERC1967 {

    /**

     * @dev Emitted when the implementation is upgraded.

     */

    event Upgraded(address indexed implementation);



    /**

     * @dev Emitted when the admin account has changed.

     */

    event AdminChanged(address previousAdmin, address newAdmin);



    /**

     * @dev Emitted when the beacon is changed.

     */

    event BeaconUpgraded(address indexed beacon);

}





// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)







/**

 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified

 * proxy whose upgrades are fully controlled by the current implementation.

 */

interface IERC1822Proxiable {

    /**

     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation

     * address.

     *

     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks

     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this

     * function revert if invoked through a proxy.

     */

    function proxiableUUID() external view returns (bytes32);

}





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)







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

        return functionCallWithValue(target, data, 0, "Address: low-level call failed");

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

        (bool success, bytes memory returndata) = target.call{value: value}(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

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

        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

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

        (bool success, bytes memory returndata) = target.delegatecall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }



    /**

     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling

     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.

     *

     * _Available since v4.8._

     */

    function verifyCallResultFromTarget(

        address target,

        bool success,

        bytes memory returndata,

        string memory errorMessage

    ) internal view returns (bytes memory) {

        if (success) {

            if (returndata.length == 0) {

                // only check isContract if the call was successful and the return data is empty

                // otherwise we already know that it was a contract

                require(isContract(target), "Address: call to non-contract");

            }

            return returndata;

        } else {

            _revert(returndata, errorMessage);

        }

    }



    /**

     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the

     * revert reason or using the provided one.

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

            _revert(returndata, errorMessage);

        }

    }



    function _revert(bytes memory returndata, string memory errorMessage) private pure {

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





// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)







/**

 * @dev Library for reading and writing primitive types to specific storage slots.

 *

 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.

 * This library helps with reading and writing to such slots without the need for inline assembly.

 *

 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.

 *

 * Example usage to set ERC1967 implementation slot:

 * ```

 * contract ERC1967 {

 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

 *

 *     function _getImplementation() internal view returns (address) {

 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;

 *     }

 *

 *     function _setImplementation(address newImplementation) internal {

 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");

 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;

 *     }

 * }

 * ```

 *

 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._

 */

library StorageSlot {

    struct AddressSlot {

        address value;

    }



    struct BooleanSlot {

        bool value;

    }



    struct Bytes32Slot {

        bytes32 value;

    }



    struct Uint256Slot {

        uint256 value;

    }



    /**

     * @dev Returns an `AddressSlot` with member `value` located at `slot`.

     */

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := slot

        }

    }



    /**

     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.

     */

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := slot

        }

    }



    /**

     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.

     */

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := slot

        }

    }



    /**

     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.

     */

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := slot

        }

    }

}





/**

 * @dev This abstract contract provides getters and event emitting update functions for

 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.

 *

 * _Available since v4.1._

 *

 * @custom:oz-upgrades-unsafe-allow delegatecall

 */

abstract contract ERC1967Upgrade is IERC1967 {

    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1

    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;



    /**

     * @dev Storage slot with the address of the current implementation.

     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is

     * validated in the constructor.

     */

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;



    /**

     * @dev Returns the current implementation address.

     */

    function _getImplementation() internal view returns (address) {

        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;

    }



    /**

     * @dev Stores a new address in the EIP1967 implementation slot.

     */

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");

        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;

    }



    /**

     * @dev Perform implementation upgrade

     *

     * Emits an {Upgraded} event.

     */

    function _upgradeTo(address newImplementation) internal {

        _setImplementation(newImplementation);

        emit Upgraded(newImplementation);

    }



    /**

     * @dev Perform implementation upgrade with additional setup call.

     *

     * Emits an {Upgraded} event.

     */

    function _upgradeToAndCall(

        address newImplementation,

        bytes memory data,

        bool forceCall

    ) internal {

        _upgradeTo(newImplementation);

        if (data.length > 0 || forceCall) {

            Address.functionDelegateCall(newImplementation, data);

        }

    }



    /**

     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.

     *

     * Emits an {Upgraded} event.

     */

    function _upgradeToAndCallUUPS(

        address newImplementation,

        bytes memory data,

        bool forceCall

    ) internal {

        // Upgrades from old implementations will perform a rollback test. This test requires the new

        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing

        // this special case will break upgrade paths from old UUPS implementation to new ones.

        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {

            _setImplementation(newImplementation);

        } else {

            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {

                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");

            } catch {

                revert("ERC1967Upgrade: new implementation is not UUPS");

            }

            _upgradeToAndCall(newImplementation, data, forceCall);

        }

    }



    /**

     * @dev Storage slot with the admin of the contract.

     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is

     * validated in the constructor.

     */

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;



    /**

     * @dev Returns the current admin.

     */

    function _getAdmin() internal view returns (address) {

        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;

    }



    /**

     * @dev Stores a new address in the EIP1967 admin slot.

     */

    function _setAdmin(address newAdmin) private {

        require(newAdmin != address(0), "ERC1967: new admin is the zero address");

        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;

    }



    /**

     * @dev Changes the admin of the proxy.

     *

     * Emits an {AdminChanged} event.

     */

    function _changeAdmin(address newAdmin) internal {

        emit AdminChanged(_getAdmin(), newAdmin);

        _setAdmin(newAdmin);

    }



    /**

     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.

     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.

     */

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;



    /**

     * @dev Returns the current beacon.

     */

    function _getBeacon() internal view returns (address) {

        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;

    }



    /**

     * @dev Stores a new beacon in the EIP1967 beacon slot.

     */

    function _setBeacon(address newBeacon) private {

        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");

        require(

            Address.isContract(IBeacon(newBeacon).implementation()),

            "ERC1967: beacon implementation is not a contract"

        );

        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;

    }



    /**

     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does

     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).

     *

     * Emits a {BeaconUpgraded} event.

     */

    function _upgradeBeaconToAndCall(

        address newBeacon,

        bytes memory data,

        bool forceCall

    ) internal {

        _setBeacon(newBeacon);

        emit BeaconUpgraded(newBeacon);

        if (data.length > 0 || forceCall) {

            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);

        }

    }

}





/**

 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an

 * implementation address that can be changed. This address is stored in storage in the location specified by

 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the

 * implementation behind the proxy.

 */

contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    /**

     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.

     *

     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded

     * function call, and allows initializing the storage of the proxy like a Solidity constructor.

     */

    constructor(address _logic, bytes memory _data) payable {

        _upgradeToAndCall(_logic, _data, false);

    }



    /**

     * @dev Returns the current implementation address.

     */

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();

    }

}





/**

 * @dev Interface for {TransparentUpgradeableProxy}. In order to implement transparency, {TransparentUpgradeableProxy}

 * does not implement this interface directly, and some of its functions are implemented by an internal dispatch

 * mechanism. The compiler is unaware that these functions are implemented by {TransparentUpgradeableProxy} and will not

 * include them in the ABI so this interface must be used to interact with it.

 */

interface ITransparentUpgradeableProxy is IERC1967 {

    function admin() external view returns (address);



    function implementation() external view returns (address);



    function changeAdmin(address) external;



    function upgradeTo(address) external;



    function upgradeToAndCall(address, bytes memory) external payable;

}



/**

 * @dev This contract implements a proxy that is upgradeable by an admin.

 *

 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector

 * clashing], which can potentially be used in an attack, this contract uses the

 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two

 * things that go hand in hand:

 *

 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if

 * that call matches one of the admin functions exposed by the proxy itself.

 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the

 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says

 * "admin cannot fallback to proxy target".

 *

 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing

 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due

 * to sudden errors when trying to call a function from the proxy implementation.

 *

 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,

 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.

 *

 * NOTE: The real interface of this proxy is that defined in `ITransparentUpgradeableProxy`. This contract does not

 * inherit from that interface, and instead the admin functions are implicitly implemented using a custom dispatch

 * mechanism in `_fallback`. Consequently, the compiler will not produce an ABI for this contract. This is necessary to

 * fully implement transparency without decoding reverts caused by selector clashes between the proxy and the

 * implementation.

 *

 * WARNING: It is not recommended to extend this contract to add additional external functions. If you do so, the compiler

 * will not check that there are no selector conflicts, due to the note above. A selector clash between any new function

 * and the functions declared in {ITransparentUpgradeableProxy} will be resolved in favor of the new one. This could

 * render the admin operations inaccessible, which could prevent upgradeability. Transparency may also be compromised.

 */

contract TransparentUpgradeableProxy is ERC1967Proxy {

    /**

     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and

     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.

     */

    constructor(

        address _logic,

        address admin_,

        bytes memory _data

    ) payable ERC1967Proxy(_logic, _data) {

        _changeAdmin(admin_);

    }



    /**

     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.

     *

     * CAUTION: This modifier is deprecated, as it could cause issues if the modified function has arguments, and the

     * implementation provides a function with the same selector.

     */

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {

            _;

        } else {

            _fallback();

        }

    }



    /**

     * @dev If caller is the admin process the call internally, otherwise transparently fallback to the proxy behavior

     */

    function _fallback() internal virtual override {

        if (msg.sender == _getAdmin()) {

            bytes memory ret;

            bytes4 selector = msg.sig;

            if (selector == ITransparentUpgradeableProxy.upgradeTo.selector) {

                ret = _dispatchUpgradeTo();

            } else if (selector == ITransparentUpgradeableProxy.upgradeToAndCall.selector) {

                ret = _dispatchUpgradeToAndCall();

            } else if (selector == ITransparentUpgradeableProxy.changeAdmin.selector) {

                ret = _dispatchChangeAdmin();

            } else if (selector == ITransparentUpgradeableProxy.admin.selector) {

                ret = _dispatchAdmin();

            } else if (selector == ITransparentUpgradeableProxy.implementation.selector) {

                ret = _dispatchImplementation();

            } else {

                revert("TransparentUpgradeableProxy: admin cannot fallback to proxy target");

            }

            assembly {

                return(add(ret, 0x20), mload(ret))

            }

        } else {

            super._fallback();

        }

    }



    /**

     * @dev Returns the current admin.

     *

     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the

     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.

     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`

     */

    function _dispatchAdmin() private returns (bytes memory) {

        _requireZeroValue();



        address admin = _getAdmin();

        return abi.encode(admin);

    }



    /**

     * @dev Returns the current implementation.

     *

     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the

     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.

     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`

     */

    function _dispatchImplementation() private returns (bytes memory) {

        _requireZeroValue();



        address implementation = _implementation();

        return abi.encode(implementation);

    }



    /**

     * @dev Changes the admin of the proxy.

     *

     * Emits an {AdminChanged} event.

     */

    function _dispatchChangeAdmin() private returns (bytes memory) {

        _requireZeroValue();



        address newAdmin = abi.decode(msg.data[4:], (address));

        _changeAdmin(newAdmin);



        return "";

    }



    /**

     * @dev Upgrade the implementation of the proxy.

     */

    function _dispatchUpgradeTo() private returns (bytes memory) {

        _requireZeroValue();



        address newImplementation = abi.decode(msg.data[4:], (address));

        _upgradeToAndCall(newImplementation, bytes(""), false);



        return "";

    }



    /**

     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified

     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the

     * proxied contract.

     */

    function _dispatchUpgradeToAndCall() private returns (bytes memory) {

        (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));

        _upgradeToAndCall(newImplementation, data, true);



        return "";

    }



    /**

     * @dev Returns the current admin.

     */

    function _admin() internal view virtual returns (address) {

        return _getAdmin();

    }



    /**

     * @dev To keep this contract fully transparent, all `ifAdmin` functions must be payable. This helper is here to

     * emulate some proxy functions being non-payable while still allowing value to pass through.

     */

    function _requireZeroValue() private {

        require(msg.value == 0);

    }

}





/**

 * @title ReallocatablePaymentSplitter

 * @dev This contract allows to split Ether payments among a group of accounts accourding to openzeppelin's PaymentSplitter.

 *

 * In addition, this contract allowes to transfer shares between investors.

 */

contract ReallocatablePaymentSplitterUpgradeable is PaymentSplitterUpgradeable, OwnableUpgradeable {

	uint256 private _totalReceieved;



	event sharesTransferred(address from, address to, uint256 shares);



	function initialize(address[] memory payees, uint256[] memory shares_) external initializer {

		__PaymentSplitter_init_unchained(payees, shares_);

		__Ownable_init_unchained();

	}



	/**

	 * @dev Triggers a transfer to `msg.sender` of the amount of Ether they are owed, according to their percentage of the

	 * total shares and their previous withdrawals.

	 */

	function releaseMyETH() external {

		release(payable(msg.sender));

	}



	/**

	 * @dev releases funds first, then transfers all shares `from` one account to another one (`to`)

	 */

	function reallocate(address payable from, address payable to) external onlyOwner {



		require(from != to, "ReallocatablePaymentSplitterUpgradeable: reallocate to same account");



		uint256 sharesFrom;

		uint256 sharesTo;



		uint256 sharesFromSlot;

		uint256 sharesToSlot;



		//cleanup: release funds first

		if(releasable(from) > 0) {

			release(from);

		}

		if(releasable(to) > 0) {

			release(to);

		}



		//load mappings

		assembly {

			let _sharesSlot := 53

			mstore(32, _sharesSlot)



			//shareFrom = _share[from]

			mstore(0, from)

			sharesFromSlot := keccak256(0, 64)

			sharesFrom := sload(sharesFromSlot)



			//shareTo = _share[to]

			mstore(0, to)

			sharesToSlot := keccak256(0, 64)

			sharesTo := sload(sharesToSlot)

		}



		sharesTo += sharesFrom;

		sharesFrom = 0;



		//write back to storage

		assembly {

			sstore(sharesFromSlot, sharesFrom) //_share[from] = shareFrom

			sstore(sharesToSlot, sharesTo) //_share[to] = shareTo

		}



		// adapt released values

		uint256 releasedFrom;

		uint256 releasedTo;



		uint256 releasedFromSlot;

		uint256 releasedToSlot;



		//load mappings

		assembly {

			let _releasedSlot := 54

			mstore(32, _releasedSlot)



			//releasedFrom = _released[from]

			mstore(0, from)

			releasedFromSlot := keccak256(0, 64)

			releasedFrom := sload(releasedFromSlot)



			//releasedTo = _released[to]

			mstore(0, to)

			releasedToSlot := keccak256(0, 64)

			releasedTo := sload(releasedToSlot)

		}



		// uint256 totalPool = (totalReleased() + address(this).balance);

		// uint256 sharesBoth = sharesFrom + sharesTo;



		releasedTo += releasedFrom;

		releasedFrom = 0;



		//write back to storage

		assembly {

			sstore(releasedFromSlot, releasedFrom) // share[from] = shareFrom

			sstore(releasedToSlot, releasedTo) // share[to] = shareTo

		}



		emit sharesTransferred(from, to, sharesFrom);

	}



	/**

	 * @dev rescue function if something goes wrong: transfers contract balance to owner

	 */

	function rescue() external onlyOwner {

        AddressUpgradeable.sendValue(payable(owner()), address(this).balance);

	}



	function getContract() external pure returns (bytes32) {

		return keccak256("ReallocatablePaymentSplitterUpgradeable");

	}



    receive() external payable virtual override {

    	_totalReceieved += msg.value;



		emit PaymentReceived(_msgSender(), msg.value);

    }



    function payeesCount() external view returns (uint256) {

    	// uint256 index = 0;

    	// while(payee(index) == address(0)) {

    	// 	index++;

    	// }

    	// return index;



    	uint256 length;

    	assembly{

    		let _payeesSlot := 55

    		length := sload(_payeesSlot)

    	}

    	return length;

    }

}



// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)







/**

 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for

 * deploying minimal proxy contracts, also known as "clones".

 *

 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies

 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.

 *

 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`

 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the

 * deterministic method.

 *

 * _Available since v3.4._

 */

library Clones {

    /**

     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.

     *

     * This function uses the create opcode, which should never revert.

     */

    function clone(address implementation) internal returns (address instance) {

        /// @solidity memory-safe-assembly

        assembly {

            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes

            // of the `implementation` address with the bytecode before the address.

            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))

            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.

            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

            instance := create(0, 0x09, 0x37)

        }

        require(instance != address(0), "ERC1167: create failed");

    }



    /**

     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.

     *

     * This function uses the create2 opcode and a `salt` to deterministically deploy

     * the clone. Using the same `implementation` and `salt` multiple time will revert, since

     * the clones cannot be deployed twice at the same address.

     */

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        /// @solidity memory-safe-assembly

        assembly {

            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes

            // of the `implementation` address with the bytecode before the address.

            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))

            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.

            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

            instance := create2(0, 0x09, 0x37, salt)

        }

        require(instance != address(0), "ERC1167: create2 failed");

    }



    /**

     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.

     */

    function predictDeterministicAddress(

        address implementation,

        bytes32 salt,

        address deployer

    ) internal pure returns (address predicted) {

        /// @solidity memory-safe-assembly

        assembly {

            let ptr := mload(0x40)

            mstore(add(ptr, 0x38), deployer)

            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)

            mstore(add(ptr, 0x14), implementation)

            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)

            mstore(add(ptr, 0x58), salt)

            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))

            predicted := keccak256(add(ptr, 0x43), 0x55)

        }

    }



    /**

     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.

     */

    function predictDeterministicAddress(address implementation, bytes32 salt)

        internal

        view

        returns (address predicted)

    {

        return predictDeterministicAddress(implementation, salt, address(this));

    }

}





// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)









// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)







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

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        _checkOwner();

        _;

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view virtual returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if the sender is not the owner.

     */

    function _checkOwner() internal view virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

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





/**

 * @title ReallocatablePaymentSplitterFactory

 * @dev creates and manages ReallocatablePaymentSplitter

 *

 * This contract is able to release funds in a bulk for shareholders who have stakes in multiple ReallocatablePaymentSplitters at once

 */

contract ReallocatablePaymentSplitterFactory is Ownable {

	event newReallocatablePaymentSplitter(address reallocatablePaymentSplitter);



	address public rpsImpl;

	mapping(address => address payable[]) public validators;



	constructor(address _rpsImpl) Ownable() {

		rpsImpl = _rpsImpl;

	}



	/**

	 * @dev creates a new ReallocatablePaymentSplitter with given args and transfers the ownership to the owner of this contract

	 */

	function create(address[] memory _payees, uint256[] memory _shares) external onlyOwner returns(address) {

		address payable rpsAddr = payable(Clones.clone(rpsImpl));

		ReallocatablePaymentSplitterUpgradeable rpsInst = ReallocatablePaymentSplitterUpgradeable(rpsAddr);

		rpsInst.initialize(_payees, _shares);

		rpsInst.transferOwnership(owner());



		for(uint256 i = 0; i < _payees.length; i++) {

			validators[_payees[i]].push(rpsAddr);

		}



		emit newReallocatablePaymentSplitter(rpsAddr);

		return rpsAddr;

	}



	/**

	 * @dev change impl address used by Factory

	 */

	function changeImplAddr(address _rpsImpl) external onlyOwner {

		rpsImpl = _rpsImpl;

	}



	/**

	 * @dev bulk release of funds for `_account`

	 */

	function release(address payable _account) public {

		address payable[] storage accountValidators = validators[_account];



		for(uint256 i = 0; i < accountValidators.length; i++){

			if(ReallocatablePaymentSplitterUpgradeable(accountValidators[i]).releasable(_account) > 0){

				ReallocatablePaymentSplitterUpgradeable(accountValidators[i]).release(_account);

			}

		}

	}



	/**

	 * @dev bulk release of funds for `msg.sender`

	 */

	function releaseMyETH() external {

		release(payable(msg.sender));

	}



	function getContract() external pure returns (bytes32) {

		return keccak256("ReallocatablePaymentSplitterFactory");

	}

}