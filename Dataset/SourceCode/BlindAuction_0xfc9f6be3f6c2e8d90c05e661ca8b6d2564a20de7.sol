/**

 *Submitted for verification at Etherscan.io on 2023-02-28

*/



// File: contracts/BlindContract/interfaces/IBlindAuctionInfo.sol





pragma solidity ^0.8.16;



interface IBlindAuctionInfo {

    function getUsersCountWillReceiveAirdrop() external view returns (uint256);



    function getMaxWinnersCount() external view returns (uint256);



    function getFinalPrice() external view returns (uint256);



    function getAuctionState() external view returns (uint8);



    function getSigner() external view returns (address);

}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol





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



// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol





// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)



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



// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol





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



// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol





// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



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



// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol





// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)



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

        _nonReentrantBefore();

        _;

        _nonReentrantAfter();

    }



    function _nonReentrantBefore() private {

        // On the first call to nonReentrant, _status will be _NOT_ENTERED

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _status = _ENTERED;

    }



    function _nonReentrantAfter() private {

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



// File: @openzeppelin/contracts/utils/Strings.sol





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



// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)



pragma solidity ^0.8.0;





/**

 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.

 *

 * These functions can be used to verify that a message was signed by the holder

 * of the private keys of a given address.

 */

library ECDSA {

    enum RecoverError {

        NoError,

        InvalidSignature,

        InvalidSignatureLength,

        InvalidSignatureS,

        InvalidSignatureV // Deprecated in v4.8

    }



    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {

            return; // no error: do nothing

        } else if (error == RecoverError.InvalidSignature) {

            revert("ECDSA: invalid signature");

        } else if (error == RecoverError.InvalidSignatureLength) {

            revert("ECDSA: invalid signature length");

        } else if (error == RecoverError.InvalidSignatureS) {

            revert("ECDSA: invalid signature 's' value");

        }

    }



    /**

     * @dev Returns the address that signed a hashed message (`hash`) with

     * `signature` or error string. This address can then be used for verification purposes.

     *

     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:

     * this function rejects them by requiring the `s` value to be in the lower

     * half order, and the `v` value to be either 27 or 28.

     *

     * IMPORTANT: `hash` _must_ be the result of a hash operation for the

     * verification to be secure: it is possible to craft signatures that

     * recover to arbitrary addresses for non-hashed data. A safe way to ensure

     * this is by receiving a hash of the original message (which may otherwise

     * be too long), and then calling {toEthSignedMessageHash} on it.

     *

     * Documentation for signature generation:

     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]

     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]

     *

     * _Available since v4.3._

     */

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {

            bytes32 r;

            bytes32 s;

            uint8 v;

            // ecrecover takes the signature parameters, and the only way to get them

            // currently is to use assembly.

            /// @solidity memory-safe-assembly

            assembly {

                r := mload(add(signature, 0x20))

                s := mload(add(signature, 0x40))

                v := byte(0, mload(add(signature, 0x60)))

            }

            return tryRecover(hash, v, r, s);

        } else {

            return (address(0), RecoverError.InvalidSignatureLength);

        }

    }



    /**

     * @dev Returns the address that signed a hashed message (`hash`) with

     * `signature`. This address can then be used for verification purposes.

     *

     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:

     * this function rejects them by requiring the `s` value to be in the lower

     * half order, and the `v` value to be either 27 or 28.

     *

     * IMPORTANT: `hash` _must_ be the result of a hash operation for the

     * verification to be secure: it is possible to craft signatures that

     * recover to arbitrary addresses for non-hashed data. A safe way to ensure

     * this is by receiving a hash of the original message (which may otherwise

     * be too long), and then calling {toEthSignedMessageHash} on it.

     */

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);

        _throwError(error);

        return recovered;

    }



    /**

     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.

     *

     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]

     *

     * _Available since v4.3._

     */

    function tryRecover(

        bytes32 hash,

        bytes32 r,

        bytes32 vs

    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);

        uint8 v = uint8((uint256(vs) >> 255) + 27);

        return tryRecover(hash, v, r, s);

    }



    /**

     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.

     *

     * _Available since v4.2._

     */

    function recover(

        bytes32 hash,

        bytes32 r,

        bytes32 vs

    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);

        _throwError(error);

        return recovered;

    }



    /**

     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,

     * `r` and `s` signature fields separately.

     *

     * _Available since v4.3._

     */

    function tryRecover(

        bytes32 hash,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) internal pure returns (address, RecoverError) {

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature

        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines

        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most

        // signatures from current libraries generate a unique signature with an s-value in the lower half order.

        //

        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value

        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or

        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept

        // these malleable signatures as well.

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {

            return (address(0), RecoverError.InvalidSignatureS);

        }



        // If the signature is valid (and not malleable), return the signer address

        address signer = ecrecover(hash, v, r, s);

        if (signer == address(0)) {

            return (address(0), RecoverError.InvalidSignature);

        }



        return (signer, RecoverError.NoError);

    }



    /**

     * @dev Overload of {ECDSA-recover} that receives the `v`,

     * `r` and `s` signature fields separately.

     */

    function recover(

        bytes32 hash,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);

        _throwError(error);

        return recovered;

    }



    /**

     * @dev Returns an Ethereum Signed Message, created from a `hash`. This

     * produces hash corresponding to the one signed with the

     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]

     * JSON-RPC method as part of EIP-191.

     *

     * See {recover}.

     */

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        // 32 is the length in bytes of hash,

        // enforced by the type signature above

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

    }



    /**

     * @dev Returns an Ethereum Signed Message, created from `s`. This

     * produces hash corresponding to the one signed with the

     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]

     * JSON-RPC method as part of EIP-191.

     *

     * See {recover}.

     */

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));

    }



    /**

     * @dev Returns an Ethereum Signed Typed Data, created from a

     * `domainSeparator` and a `structHash`. This produces hash corresponding

     * to the one signed with the

     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]

     * JSON-RPC method as part of EIP-712.

     *

     * See {recover}.

     */

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

    }

}



// File: contracts/BlindContract/blind.sol







pragma solidity ^0.8.16;













contract BlindAuction is

    Initializable,

    ReentrancyGuardUpgradeable,

    OwnableUpgradeable,

    IBlindAuctionInfo

{

    uint256 public DEPOSIT_AMOUNT; // = 0.1ether;

    uint256 public MAX_WINNERS_COUNT; // 222

    uint256 public finalPrice;

    uint8 public auctionState;

    address public signer;



    uint256 public depositedUserCount;

    mapping(address => bool) public isUserDeposited;

    address[] public usersWillReceiveAirdrop;

    mapping(address => bool) public isUserWillReceiveAirdrop;

    uint256 public refundedUserCount;

    mapping(address => bool) public isUserRefunded;



    uint256 public winnersCount;



    event UserDeposited(address indexed user);

    event UserWillReceiveAirdrop(address indexed user);

    event UserRefunded(address indexed user);



    function initialize(address _signer) public initializer {

        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

        OwnableUpgradeable.__Ownable_init();

        DEPOSIT_AMOUNT = 0.1 ether;

        MAX_WINNERS_COUNT = 222;

        signer = _signer;

    }



    function checkValidity(bytes calldata signature, string memory action)

        public

        view

        returns (bool)

    {

        require(

            ECDSA.recover(

                ECDSA.toEthSignedMessageHash(

                    keccak256(abi.encodePacked(msg.sender, action))

                ),

                signature

            ) == signer,

            "invalid signature"

        );

        return true;

    }



    function verify(bytes32 messageHash, bytes memory signature, address usersigner) public pure returns (bool) {

        require(usersigner != address(0), "SignatureVerifier: invalid signer address");



        address recoveredSigner = ECDSA.recover(messageHash, signature);

        return (recoveredSigner == usersigner);

    }

    

    function deposit() external payable {

        require(auctionState == 1, "Auction not in bidding state");

        require(msg.value == DEPOSIT_AMOUNT, "Invalid ETH amount");

        require(!isUserDeposited[msg.sender], "Already deposited");

        isUserDeposited[msg.sender] = true;

        depositedUserCount++;

        emit UserDeposited(msg.sender);

    }



    function winnerDepositExtra(bytes calldata signature) external payable {

        require(auctionState == 2, "Auction not in concluding state");

        require(finalPrice >= DEPOSIT_AMOUNT, "finalPrice not yet set");

        require(msg.value == finalPrice - DEPOSIT_AMOUNT, "Invalid ETH amount");

        require(

            !isUserWillReceiveAirdrop[msg.sender],

            "Already deposited extra"

        );

        require(!isUserRefunded[msg.sender], "Already refunded");

        checkValidity(signature, "winner");

        isUserWillReceiveAirdrop[msg.sender] = true;

        usersWillReceiveAirdrop.push(msg.sender);

        emit UserWillReceiveAirdrop(msg.sender);

    }



    function refund(bytes calldata signature) external nonReentrant {

        require(

            auctionState == 2 || auctionState == 3,

            "Auction not in concluding or finished state"

        );

        require(isUserDeposited[msg.sender], "No deposit record");

        require(!isUserWillReceiveAirdrop[msg.sender], "Is a winner");

        require(!isUserRefunded[msg.sender], "Already refunded");

        checkValidity(signature, "refund");

        isUserRefunded[msg.sender] = true;

        refundedUserCount++;

        _withdraw(msg.sender, DEPOSIT_AMOUNT);

    }



    // =============== Admin ===============

    function setSigner(address _signer) external onlyOwner {

        signer = _signer;

    }



    function withdrawSales() public onlyOwner {

        require(

            auctionState == 2 || auctionState == 3,

            "Auction not in concluding or finished state"

        );

        uint256 balance = address(this).balance;



        uint256 nonWinnersCount = depositedUserCount - winnersCount;

        uint256 refundReserveAmount = (nonWinnersCount - refundedUserCount) *

            DEPOSIT_AMOUNT;

        uint256 balanceCanWithdraw = balance - refundReserveAmount;

        require(balanceCanWithdraw > 0, "No balance to withdraw");

        _withdraw(owner(), balanceCanWithdraw);

    }



    function _withdraw(address _address, uint256 _amount) private {

        (bool success, ) = _address.call{value: _amount}("");

        require(success, "cant withdraw");

    }



    function changeDepositAmount(uint256 amount) external onlyOwner {

        require(auctionState == 0, "Auction already started");

        DEPOSIT_AMOUNT = amount;

    }



    function changeMaxWinnersCount(uint256 count) external onlyOwner {

        require(auctionState == 0, "Auction already started");

        MAX_WINNERS_COUNT = count;

    }



    function setFinalPrice(uint256 price) external onlyOwner {

        finalPrice = price;

    }



    // usually 222

    function setWinnersCount(uint256 _winnersCount) external onlyOwner {

        require(_winnersCount <= MAX_WINNERS_COUNT, "Too many winners");

        winnersCount = _winnersCount;

    }



    // 0 = not started

    // 1 = started, bidding

    // 2 = final price announced | winners should pay finalPrice - 0.5e | non-winners can refund | waitlist starts

    // 3 = auction end | receive unpaid winner deposits | non-winners can still refund | waitlist concludes + can refund

    function setAuctionState(uint8 state) external onlyOwner {

        auctionState = state;

    }



    function getUsersWillReceiveAirdrop()

        external

        view

        returns (address[] memory)

    {

        return usersWillReceiveAirdrop;

    }



    // =============== IBlindAuctionInfo ===============

    function getUsersCountWillReceiveAirdrop() external view returns (uint256) {

        return usersWillReceiveAirdrop.length;

    }



    function getMaxWinnersCount() external view returns (uint256) {

        return MAX_WINNERS_COUNT;

    }



    function getFinalPrice() external view returns (uint256) {

        return finalPrice;

    }



    function getAuctionState() external view returns (uint8) {

        return auctionState;

    }



    function getSigner() external view returns (address) {

        return signer;

    }

}