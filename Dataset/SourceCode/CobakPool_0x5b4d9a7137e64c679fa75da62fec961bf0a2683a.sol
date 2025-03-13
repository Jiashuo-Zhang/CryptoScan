/**

 *Submitted for verification at Etherscan.io on 2024-04-30

*/



// File: interfaces/IOracle.sol







pragma solidity ^0.8.3;



interface IOracle {



    function requestRandom(uint256 _poolId) external;

}



// File: @openzeppelin/[email protected]/utils/Strings.sol





// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)



pragma solidity ^0.8.0;



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



// File: Signature.sol







pragma solidity ^0.8.1;





contract VerifySignature {

    using Strings for bool;

    using Strings for uint;

    using Strings for address;



    function verify(

        address _signer,

        address _buyer,

        address _pool,

        uint _poolId,

        uint _quantity,

        bytes memory signature

    ) internal pure returns (bool) {

        bytes32 messageHash = keccak256(abi.encodePacked(_pool, _poolId, _buyer, _quantity));

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        return ecrecover(messageHash, v, r, s) == _signer;

    }



    function splitSignature(bytes memory sig)

       internal  

        pure

        returns (

            bytes32 r,

            bytes32 s,

            uint8 v

        )

    {

        require(sig.length == 65, "invalid signature length");



        assembly {

            r := mload(add(sig, 32))

            // second 32 bytes

            s := mload(add(sig, 64))

            // final byte (first byte of the next 32 bytes)

            v := byte(0, mload(add(sig, 96)))

        }



    }

}



// File: @openzeppelin/[email protected]/token/ERC20/IERC20.sol





// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)



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

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

}



// File: @openzeppelin/[email protected]/utils/introspection/IERC165Upgradeable.sol





// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC165 standard, as defined in the

 * https://eips.ethereum.org/EIPS/eip-165[EIP].

 *

 * Implementers can declare support of contract interfaces, which can then be

 * queried by others ({ERC165Checker}).

 *

 * For an implementation, see {ERC165}.

 */

interface IERC165Upgradeable {

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



// File: @openzeppelin/[email protected]/utils/StringsUpgradeable.sol





// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)



pragma solidity ^0.8.0;



/**

 * @dev String operations.

 */

library StringsUpgradeable {

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



// File: @openzeppelin/[email protected]/utils/AddressUpgradeable.sol





// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)



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



// File: @openzeppelin/[email protected]/proxy/utils/Initializable.sol





// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)



pragma solidity ^0.8.2;





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

     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.

     */

    modifier initializer() {

        bool isTopLevelCall = _setInitializedVersion(1);

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

     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original

     * initialization step. This is essential to configure modules that are added through upgrades and that require

     * initialization.

     *

     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in

     * a contract, executing them in the right order is up to the developer or operator.

     */

    modifier reinitializer(uint8 version) {

        bool isTopLevelCall = _setInitializedVersion(version);

        if (isTopLevelCall) {

            _initializing = true;

        }

        _;

        if (isTopLevelCall) {

            _initializing = false;

            emit Initialized(version);

        }

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

     */

    function _disableInitializers() internal virtual {

        _setInitializedVersion(type(uint8).max);

    }



    function _setInitializedVersion(uint8 version) private returns (bool) {

        // If the contract is initializing we ignore whether _initialized is set in order to support multiple

        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level

        // of initializers, because in other contexts the contract may have been reentered.

        if (_initializing) {

            require(

                version == 1 && !AddressUpgradeable.isContract(address(this)),

                "Initializable: contract is already initialized"

            );

            return false;

        } else {

            require(_initialized < version, "Initializable: contract is already initialized");

            _initialized = version;

            return true;

        }

    }

}



// File: @openzeppelin/[email protected]/security/ReentrancyGuardUpgradeable.sol





// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)



pragma solidity ^0.8.0;





/**

 * @dev Contract module that helps prevent reentrant calls to a function.

 *

 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier

 * available, which can be applied to functions to make sure there are no nested

 * (reentrant) calls to them.

 *

 * Note that because there is a single `nonReentrant` guard, functions marked as

 * `nonReentrant` may not call one another. This can be worked around by making

 * those functions `private`, and then adding `external` `nonReentrant` entry

 * points to them.

 *

 * TIP: If you would like to learn more about reentrancy and alternative ways

 * to protect against it, check out our blog post

 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].

 */

abstract contract ReentrancyGuardUpgradeable is Initializable {

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



    function __ReentrancyGuard_init() internal onlyInitializing {

        __ReentrancyGuard_init_unchained();

    }



    function __ReentrancyGuard_init_unchained() internal onlyInitializing {

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



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[49] private __gap;

}



// File: @openzeppelin/[email protected]/utils/introspection/ERC165Upgradeable.sol





// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)



pragma solidity ^0.8.0;







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

abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {

    function __ERC165_init() internal onlyInitializing {

    }



    function __ERC165_init_unchained() internal onlyInitializing {

    }

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165Upgradeable).interfaceId;

    }



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[50] private __gap;

}



// File: @openzeppelin/[email protected]/utils/ContextUpgradeable.sol





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



// File: @openzeppelin/[email protected]/access/IAccessControlUpgradeable.sol





// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)



pragma solidity ^0.8.0;



/**

 * @dev External interface of AccessControl declared to support ERC165 detection.

 */

interface IAccessControlUpgradeable {

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



// File: @openzeppelin/[email protected]/access/AccessControlUpgradeable.sol





// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)



pragma solidity ^0.8.0;













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

abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {

    function __AccessControl_init() internal onlyInitializing {

    }



    function __AccessControl_init_unchained() internal onlyInitializing {

    }

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

        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);

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

                        StringsUpgradeable.toHexString(uint160(account), 20),

                        " is missing role ",

                        StringsUpgradeable.toHexString(uint256(role), 32)

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



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[49] private __gap;

}



// File: CobakPool.sol







pragma solidity ^0.8.3;













contract CobakPool is AccessControlUpgradeable , VerifySignature,  ReentrancyGuardUpgradeable {



    bytes32 public constant POOL_MANAGER_ROLE = keccak256("POOL_MANAGER_ROLE");



    address public signer;



    uint public fee;



    struct Ticket {

        // ticket id 

        uint ticketId;



        // ticket quantity 

        uint quantity;

    }



    struct Pool {

        // use last blockhash to determine which ticket win the ido

        uint256 number;



        // total supply

        uint256 supply;



        // sellToken per ticket

        uint256 rewardPerTicket;



        // ticket count sold out

        uint ticketSold;



        // ticket price

        uint256 ticketPrice;



        // token to sell

        address sellToken ;



        // token to buy, 0x0000000000000000000000000000000000000000 means ETH

        address buyToken ;

        

        // start time

        uint startAt;



        // end time

        uint closedAt;



        address owner;

        

    }



    struct Result {

        bool isNeg;

        uint[] list;

    }



    Pool[] public pools;



    mapping(address => mapping(uint => uint)) public ticketBought;

    mapping(uint => mapping(address => Ticket[])) tickets;

    mapping(uint => Result) public poolResult;



    mapping(uint => mapping(address => bool)) public userClaimed;



    mapping(address => uint) public fees;



    mapping(uint256 => uint256) public hashes;



    address public oracle;



    mapping(uint => bool) public poolClaimed;



    event Created(address indexed sender, uint indexed index, Pool pool, uint startTime);

    event BuyTicket(address indexed sender, uint indexed poolId, Ticket ticket);

    event ClaimReward(address indexed sender, uint indexed poolId, uint reward, uint refund);

    event OwnerClaim(address indexed sender, uint indexed poolId, uint sell, uint buy);

    event ClaimFee(address indexed sender, address indexed token, uint amount);

    event Lottery(uint indexed poolId, bool isNeg, uint[] list);

    event ClosePool(uint indexed poolId, uint blocknumber);

    event HashGenerated(uint indexed poolId, uint256 hash);



    event FeeChanged(uint256 fee);

    event OracleChanged(address oracle);

    event SignerChanged(address signer);



    modifier isPoolExist(uint _poolId) {

        require(_poolId < pools.length, "invalid pool");

        _;

    }



    modifier isPoolStarted(uint _poolId) {

        require(pools[_poolId].startAt <= block.timestamp, "pool is not started yet");

        _;

    }



    modifier isPoolNotClosed(uint _poolId) {

        require(pools[_poolId].closedAt >= block.timestamp, "pool is closed");

        _;

    }



    modifier isPoolClosed(uint _poolId) {

        require(pools[_poolId].closedAt < block.timestamp, "pool is not closed yet");

        _;

    }





    function initialize(address owner) public initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, owner);

        _grantRole(POOL_MANAGER_ROLE, owner);

        fee = 3;

    }



    /* ============ onlyRole(DEFAULT_ADMIN_ROLE) ================== */



    /**

     * @notice create new pool

     * @param _price token per ticket

     * @param _sell token to sell

     * @param _buy token to buy ticket



     */

    function newPool(

        uint256 _price,

        uint256 _supply,

        uint256 _rewardPerTicket,

        address _sell,

        address _buy,

        uint _start,

        uint _duration,

        address _owner

    ) external onlyRole(POOL_MANAGER_ROLE) returns (uint256){

        // check sell token

        require(_sell != address(0), "invalid sell token");

        require(_owner != address(0), "invalid owner address");

        require(_supply != 0, "invalid token supply");

        require(IERC20(_sell).totalSupply() > 0, "sell token didn't mint yet");



        // check buy token

        if (_buy != address(0)) {

            require(IERC20(_buy).totalSupply() > 0, "buy token didn't mint yet");

        }



        require(IERC20(_sell).transferFrom(msg.sender, address(this), _supply), "insufficient token");



        // new pool

        Pool memory pool;

        pool.ticketPrice = _price;

        pool.sellToken = _sell;

        pool.supply = _supply;

        pool.buyToken = _buy;

        pool.startAt = _start;

        pool.closedAt = pool.startAt + _duration;

        pool.rewardPerTicket = _rewardPerTicket;

        pool.owner = _owner;



        pools.push(pool);



        emit Created(msg.sender, pools.length - 1, pool, pool.startAt);

        return pools.length - 1;

    }



    /**

     * @notice set the number of pool

     * @param _poolId Index of pools



     **/

    function lottery(uint256 _poolId) external

        isPoolExist(_poolId)

        isPoolClosed(_poolId)

        onlyRole(POOL_MANAGER_ROLE)

    {

        Pool storage pool = pools[_poolId];

        uint rewardCount = pool.supply / pool.rewardPerTicket;

        require(pool.number == 0, "already lotteried");

        pool.number = block.number;

        emit ClosePool(_poolId, block.number);

        if (pool.ticketSold <= rewardCount) {

            return;

        }



        if (rewardCount * 100 / pool.ticketSold > 50) {

            poolResult[_poolId].isNeg = true;

        } else {

            poolResult[_poolId].isNeg = false;

        }



        IOracle(oracle).requestRandom(_poolId);

    }



    function calcResult(uint _poolId) external

        onlyRole(POOL_MANAGER_ROLE)

    {

        require(hashes[_poolId] > 0, "waiting for random hash");

        require(poolResult[_poolId].list.length == 0, "alrealy generated lucky numbers");



        Pool storage pool = pools[_poolId];

        uint rewardCount = pool.supply / pool.rewardPerTicket;



        if (poolResult[_poolId].isNeg) {

            rewardCount = pool.ticketSold - rewardCount;

        }



        _calcResult(_poolId, hashes[_poolId], pool.ticketSold, rewardCount);

        emit Lottery(_poolId, poolResult[_poolId].isNeg, poolResult[_poolId].list);

    }



    function claimFee(address _tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {

        if (_tokenAddress == address(0)) {

            payable(msg.sender).transfer(fees[address(0)]);

        } else {

            require(IERC20(_tokenAddress).transfer(msg.sender, fees[_tokenAddress]), "insufficient fee");

        }

        emit ClaimFee(msg.sender, _tokenAddress, fees[_tokenAddress]);

        fees[_tokenAddress] = 0;

    }



    function setFee(uint _fee) external onlyRole(DEFAULT_ADMIN_ROLE) {

        fee = _fee;

        emit FeeChanged(_fee);

    }



    function setOracle(address _oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {

        oracle = _oracle;

        emit OracleChanged(_oracle);

    }



    function setSigner(address _signer) external onlyRole(DEFAULT_ADMIN_ROLE) {

        signer = _signer;

        emit SignerChanged(_signer);

    }



    /**

     * @notice claim Reward

     * @param _poolId index of pools

     

     **/  

    function claimReward(uint _poolId) external

        isPoolExist(_poolId)

        isPoolClosed(_poolId)

    {



        Pool storage pool = pools[_poolId];

        require(pool.number > 0, "didn't lottery yet");

        require(userClaimed[_poolId][msg.sender] == false, "already claimed reward from this pool");



        uint rewardCount = pool.supply / pool.rewardPerTicket;



        if (pool.ticketSold > rewardCount) {

            require(getPoolResultLength(_poolId) > 0, "waiting calculate lucky number");

        }



        (uint256 rewardAmount, uint256 refundAmount) = calcReward(msg.sender, _poolId);



        userClaimed[_poolId][msg.sender] = true;



        if (rewardAmount > 0) {

            require(IERC20(pool.sellToken).transfer(msg.sender, rewardAmount), "insufficient token");

        } 



        if (refundAmount > 0) {

            if (pool.buyToken == address(0)) {

                payable(msg.sender).transfer(refundAmount);

            } else {

                require(IERC20(pool.buyToken).transferFrom(address(this), msg.sender, refundAmount), "insufficient token");

            }

        }



        emit ClaimReward(msg.sender, _poolId, rewardAmount, refundAmount);

    }





    function ownerClaim(uint _poolId) external 

        isPoolExist(_poolId)

        isPoolClosed(_poolId)

    {

        Pool storage pool = pools[_poolId];



        require(pool.owner == msg.sender, "only pool owner can claim tokens");

        require(poolClaimed[_poolId] == false, "already claimed");



        uint rewardCount = pool.supply / pool.rewardPerTicket;

        uint sellBalance;

        uint buyBalance;

        if (rewardCount > pool.ticketSold) {

            // claim both buy and sell token

            sellBalance = (rewardCount - pool.ticketSold) * pool.rewardPerTicket;

        }



        uint ticketCount = rewardCount;

        if (rewardCount > pool.ticketSold) {

            ticketCount = pool.ticketSold;

        }

        buyBalance = ticketCount * pool.ticketPrice;



        poolClaimed[_poolId] = true;



        uint devFee = buyBalance * fee * 100 / 10000;



        if (sellBalance > 0) {

            require(IERC20(pool.sellToken).transfer(pool.owner, sellBalance), "insufficient sell token");

        }



        if (buyBalance > 0) {

            if (pool.buyToken == address(0)) {

                payable(pool.owner).transfer(buyBalance - devFee);

            } else {

                require(IERC20(pool.buyToken).transfer(pool.owner, buyBalance - devFee), "insufficient buy token");

            }

        }

        if (devFee > 0) {

            fees[pool.buyToken] += devFee;

        }

        emit OwnerClaim(msg.sender, _poolId, sellBalance, buyBalance - devFee);

    }





    function getOwnerAvailableClaim(uint _poolId) public view returns(uint256, uint256) 

    {

        uint rewardCount = pools[_poolId].supply / pools[_poolId].rewardPerTicket;

        uint sellBalance;

        uint buyBalance;

        if (rewardCount > pools[_poolId].ticketSold) {

            sellBalance = (rewardCount - pools[_poolId].ticketSold) * pools[_poolId].rewardPerTicket;

        }



        uint ticketCount = rewardCount;

        if (rewardCount > pools[_poolId].ticketSold) {

            ticketCount = pools[_poolId].ticketSold;

        }

        buyBalance = ticketCount * pools[_poolId].ticketPrice;



        uint devFee = buyBalance * fee * 100 / 10000;



        return (sellBalance, buyBalance - devFee);

    }



    function getTicketReward(address _user, uint _poolId) public view returns (uint256, uint256){

        return calcReward(_user, _poolId);

    }

    

    function getTicketLength(address _user, uint _poolId) public view returns (uint256) {

        return tickets[_poolId][_user].length;

    }



    function getPoolNumber(uint _poolId) public view returns(uint256) {

        return pools[_poolId].number;

    }



    function getPool(uint _poolId) public view returns(Pool memory) {

        return pools[_poolId];

    }



    function getPoolResultLength(uint _poolId) public view returns(uint) {

        return poolResult[_poolId].list.length;

    }



    function getPoolResult(uint _poolId) public 

        view returns(bool, uint[] memory) 

    {

        return (poolResult[_poolId].isNeg ,poolResult[_poolId].list);

    }



    function getClaimable(uint _poolId, address _user) public view returns (bool) {

        if (userClaimed[_poolId][_user] == true) {

            return false;

        }



        if (pools[_poolId].number == 0) {

            return false;

        }



        uint rewardCount = pools[_poolId].supply / pools[_poolId].rewardPerTicket;



        if (pools[_poolId].ticketSold <= rewardCount) {

            return true;

        } else {

            if (poolResult[_poolId].list.length == 0) {

                return false;

            } else {

                return true;

            }

        }

    }



    function getBought(uint _poolId, address _user) public 

        view returns(uint) 

    {

        return ticketBought[_user][_poolId];

    }



    function isUserClaimed(uint _poolId, address _user) public view returns(bool)  {

        return userClaimed[_poolId][_user];

    }



    function getPoolLength() public view returns(uint) {

        return pools.length;

    }



    function getTicket(address _user, uint _poolId, uint _index) public view returns (Ticket memory) {

        return tickets[_poolId][_user][_index];

    }





    /* =========== internal functions ============= */





    function getNumber(uint256 value, uint size, uint offset) internal pure returns (uint y) {

        require(size > 0, "invalid size");

        require(offset > 0, "invalid offset");

        assembly {

            value := div(value, exp(10, sub(offset, 1)))

            switch size case 1 { 

                y := mod(value, 10) 

            }

            default { y := mod(value, exp(10, size)) }

        }

    }



    function verifyResult(uint ticketId, uint result) internal pure returns (bool x) {

        assembly {

            x := false

            let size := shr(31, result)

            let qn := and(result, 0xffff)

            let tn := mod(ticketId, exp(10, size))

            if eq(qn, tn) { x := true }

        }

    }



    function calcReward(address _user, uint _poolId) internal view returns (uint rewardAmount, uint refundAmount) {

        Pool storage pool = pools[_poolId];



        // waiting lottery

        if (pool.number == 0) {

            return (0, 0);

        }



        uint ticketLen = tickets[_poolId][_user].length;

        uint rewardCount = pool.supply / pool.rewardPerTicket;



        // waiting calculate final result

        if (rewardCount < pool.ticketSold && poolResult[_poolId].list.length == 0) {

            return (0, 0);

        }

        uint poolId = _poolId;

        bool neg = poolResult[_poolId].isNeg;

        uint[] storage list = poolResult[_poolId].list;

        for (uint i = 0; i < ticketLen ; i ++) {

            Ticket storage ticket = tickets[poolId][_user][i];

            if (pool.ticketSold <= rewardCount) {

                rewardAmount += pool.rewardPerTicket * ticket.quantity;

                continue;

            }



            for (uint k = 0; k < ticket.quantity; k ++ ) {

                uint ticketId = ticket.ticketId + k;

                bool valid = false;

                for (uint j = 0; j < list.length; j ++ ) {

                    valid = verifyResult(ticketId, list[j]);

                    if (valid) {

                        break;

                    }

                }

                if (neg) valid = !valid;

                if (valid) {

                    rewardAmount += pool.rewardPerTicket;

                } else {

                    refundAmount += pool.ticketPrice;

                }

            }

        }

    }



    /* ======================== public ================== */





    /**

     * @notice buy ticket

     * @param _poolId Index of pools

     * @param _quantity quantity to buy



     **/

    function buyTicket(uint _poolId, uint _quantity, bytes memory _signature, uint _max_quantity) external payable

        isPoolExist(_poolId)

        isPoolStarted(_poolId)

        isPoolNotClosed(_poolId)

    {

        Pool storage pool = pools[_poolId];



        require(_quantity> 0, "ticket quantity can not be 0");

        require(verify(signer, msg.sender, address(this), _poolId, _max_quantity, _signature), "invalid signature");

        require(ticketBought[msg.sender][_poolId] + _quantity <= _max_quantity, "limit exceeded");



        uint rewardCount = pool.supply / pool.rewardPerTicket;

        require(pool.ticketSold + _quantity <= rewardCount * 25, "25 times oversold limit");



        uint256 price = pool.ticketPrice;



        uint256 amount = _quantity * price;



        // payment 

        if (pool.buyToken == address(0)) {

            require(amount == msg.value, "invalid payment ETH amount");

        } else {

            require(IERC20(pool.buyToken).transferFrom(msg.sender, address(this), amount), "insufficient token");

        }



        Ticket[] storage userTickets = tickets[_poolId][msg.sender];



        // create ticket

        Ticket memory ticket;

        ticket.ticketId = pool.ticketSold +1;

        ticket.quantity = _quantity;

        userTickets.push(ticket);



        pool.ticketSold += _quantity;

        ticketBought[msg.sender][_poolId] += _quantity;

        emit BuyTicket(msg.sender, _poolId, ticket);

    }





    function _calcResult(uint poolId, uint256 value, uint256 ticketSold, uint rewardCount) internal {

        uint size = 1;

        uint offset = 1;

        uint[] storage result =  poolResult[poolId].list;

        uint total = rewardCount;

        uint sold = ticketSold;

        uint hash = value; 

        while (total > 0) {

            uint num = ((total * (10 ** (size +1)) / sold) % 100) / 10;

            uint t;

            uint mantissa = sold % (10 ** size);

            while (num > 0 && total > 0) {

                t = getNumber(hash, size, offset);

                bool valid = true;

                uint reward = sold / (10 ** size);

                if (reward == 0 && t > mantissa) t = t % mantissa;

                for (uint i = 0; i < result.length ; i++){

                    if (t % (10 ** (result[i] >> 31)) == result[i] & 0xffff) 

                        valid = false; 

                }

                if (valid) {

                    if (t > 0 && t <= mantissa)  reward += 1;

                    if (reward <= total)  {

                        num = num - 1;

                        total = total - reward;

                        result.push(t | size << 31);

                    } else {

                        break;

                    }

                } 

                offset += 1;

            }

            num = ((total * (10 ** (size +1)) / sold) % 100) / 10;

            if (num == 0)

                size += 1;

        }

    }



    function setHash(uint256 _poolId, uint256 randomness) external {

        require(msg.sender == oracle, "only oracle");

        hashes[_poolId] = randomness;

        emit HashGenerated(_poolId, randomness);

    }

}