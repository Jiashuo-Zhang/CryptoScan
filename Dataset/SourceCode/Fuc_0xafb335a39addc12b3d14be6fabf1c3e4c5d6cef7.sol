/**

 *Submitted for verification at Etherscan.io on 2023-05-01

*/



// File: operator-filter-registry/src/lib/Constants.sol





pragma solidity ^0.8.17;



address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;

address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;



// File: operator-filter-registry/src/IOperatorFilterRegistry.sol





pragma solidity ^0.8.13;



interface IOperatorFilterRegistry {

    /**

     * @notice Returns true if operator is not filtered for a given token, either by address or codeHash. Also returns

     *         true if supplied registrant address is not registered.

     */

    function isOperatorAllowed(address registrant, address operator) external view returns (bool);



    /**

     * @notice Registers an address with the registry. May be called by address itself or by EIP-173 owner.

     */

    function register(address registrant) external;



    /**

     * @notice Registers an address with the registry and "subscribes" to another address's filtered operators and codeHashes.

     */

    function registerAndSubscribe(address registrant, address subscription) external;



    /**

     * @notice Registers an address with the registry and copies the filtered operators and codeHashes from another

     *         address without subscribing.

     */

    function registerAndCopyEntries(address registrant, address registrantToCopy) external;



    /**

     * @notice Unregisters an address with the registry and removes its subscription. May be called by address itself or by EIP-173 owner.

     *         Note that this does not remove any filtered addresses or codeHashes.

     *         Also note that any subscriptions to this registrant will still be active and follow the existing filtered addresses and codehashes.

     */

    function unregister(address addr) external;



    /**

     * @notice Update an operator address for a registered address - when filtered is true, the operator is filtered.

     */

    function updateOperator(address registrant, address operator, bool filtered) external;



    /**

     * @notice Update multiple operators for a registered address - when filtered is true, the operators will be filtered. Reverts on duplicates.

     */

    function updateOperators(address registrant, address[] calldata operators, bool filtered) external;



    /**

     * @notice Update a codeHash for a registered address - when filtered is true, the codeHash is filtered.

     */

    function updateCodeHash(address registrant, bytes32 codehash, bool filtered) external;



    /**

     * @notice Update multiple codeHashes for a registered address - when filtered is true, the codeHashes will be filtered. Reverts on duplicates.

     */

    function updateCodeHashes(address registrant, bytes32[] calldata codeHashes, bool filtered) external;



    /**

     * @notice Subscribe an address to another registrant's filtered operators and codeHashes. Will remove previous

     *         subscription if present.

     *         Note that accounts with subscriptions may go on to subscribe to other accounts - in this case,

     *         subscriptions will not be forwarded. Instead the former subscription's existing entries will still be

     *         used.

     */

    function subscribe(address registrant, address registrantToSubscribe) external;



    /**

     * @notice Unsubscribe an address from its current subscribed registrant, and optionally copy its filtered operators and codeHashes.

     */

    function unsubscribe(address registrant, bool copyExistingEntries) external;



    /**

     * @notice Get the subscription address of a given registrant, if any.

     */

    function subscriptionOf(address addr) external returns (address registrant);



    /**

     * @notice Get the set of addresses subscribed to a given registrant.

     *         Note that order is not guaranteed as updates are made.

     */

    function subscribers(address registrant) external returns (address[] memory);



    /**

     * @notice Get the subscriber at a given index in the set of addresses subscribed to a given registrant.

     *         Note that order is not guaranteed as updates are made.

     */

    function subscriberAt(address registrant, uint256 index) external returns (address);



    /**

     * @notice Copy filtered operators and codeHashes from a different registrantToCopy to addr.

     */

    function copyEntriesOf(address registrant, address registrantToCopy) external;



    /**

     * @notice Returns true if operator is filtered by a given address or its subscription.

     */

    function isOperatorFiltered(address registrant, address operator) external returns (bool);



    /**

     * @notice Returns true if the hash of an address's code is filtered by a given address or its subscription.

     */

    function isCodeHashOfFiltered(address registrant, address operatorWithCode) external returns (bool);



    /**

     * @notice Returns true if a codeHash is filtered by a given address or its subscription.

     */

    function isCodeHashFiltered(address registrant, bytes32 codeHash) external returns (bool);



    /**

     * @notice Returns a list of filtered operators for a given address or its subscription.

     */

    function filteredOperators(address addr) external returns (address[] memory);



    /**

     * @notice Returns the set of filtered codeHashes for a given address or its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashes(address addr) external returns (bytes32[] memory);



    /**

     * @notice Returns the filtered operator at the given index of the set of filtered operators for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredOperatorAt(address registrant, uint256 index) external returns (address);



    /**

     * @notice Returns the filtered codeHash at the given index of the list of filtered codeHashes for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashAt(address registrant, uint256 index) external returns (bytes32);



    /**

     * @notice Returns true if an address has registered

     */

    function isRegistered(address addr) external returns (bool);



    /**

     * @dev Convenience method to compute the code hash of an arbitrary contract

     */

    function codeHashOf(address addr) external returns (bytes32);

}



// File: operator-filter-registry/src/OperatorFilterer.sol





pragma solidity ^0.8.13;





/**

 * @title  OperatorFilterer

 * @notice Abstract contract whose constructor automatically registers and optionally subscribes to or copies another

 *         registrant's entries in the OperatorFilterRegistry.

 * @dev    This smart contract is meant to be inherited by token contracts so they can use the following:

 *         - `onlyAllowedOperator` modifier for `transferFrom` and `safeTransferFrom` methods.

 *         - `onlyAllowedOperatorApproval` modifier for `approve` and `setApprovalForAll` methods.

 *         Please note that if your token contract does not provide an owner with EIP-173, it must provide

 *         administration methods on the contract itself to interact with the registry otherwise the subscription

 *         will be locked to the options set during construction.

 */



abstract contract OperatorFilterer {

    /// @dev Emitted when an operator is not allowed.

    error OperatorNotAllowed(address operator);



    IOperatorFilterRegistry public constant OPERATOR_FILTER_REGISTRY =

        IOperatorFilterRegistry(CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS);



    /// @dev The constructor that is called when the contract is being deployed.

    constructor(address subscriptionOrRegistrantToCopy, bool subscribe) {

        // If an inheriting token contract is deployed to a network without the registry deployed, the modifier

        // will not revert, but the contract will need to be registered with the registry once it is deployed in

        // order for the modifier to filter addresses.

        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {

            if (subscribe) {

                OPERATOR_FILTER_REGISTRY.registerAndSubscribe(address(this), subscriptionOrRegistrantToCopy);

            } else {

                if (subscriptionOrRegistrantToCopy != address(0)) {

                    OPERATOR_FILTER_REGISTRY.registerAndCopyEntries(address(this), subscriptionOrRegistrantToCopy);

                } else {

                    OPERATOR_FILTER_REGISTRY.register(address(this));

                }

            }

        }

    }



    /**

     * @dev A helper function to check if an operator is allowed.

     */

    modifier onlyAllowedOperator(address from) virtual {

        // Allow spending tokens from addresses with balance

        // Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred

        // from an EOA.

        if (from != msg.sender) {

            _checkFilterOperator(msg.sender);

        }

        _;

    }



    /**

     * @dev A helper function to check if an operator approval is allowed.

     */

    modifier onlyAllowedOperatorApproval(address operator) virtual {

        _checkFilterOperator(operator);

        _;

    }



    /**

     * @dev A helper function to check if an operator is allowed.

     */

    function _checkFilterOperator(address operator) internal view virtual {

        // Check registry code length to facilitate testing in environments without a deployed registry.

        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {

            // under normal circumstances, this function will revert rather than return false, but inheriting contracts

            // may specify their own OperatorFilterRegistry implementations, which may behave differently

            if (!OPERATOR_FILTER_REGISTRY.isOperatorAllowed(address(this), operator)) {

                revert OperatorNotAllowed(operator);

            }

        }

    }

}



// File: operator-filter-registry/src/DefaultOperatorFilterer.sol





pragma solidity ^0.8.13;





/**

 * @title  DefaultOperatorFilterer

 * @notice Inherits from OperatorFilterer and automatically subscribes to the default OpenSea subscription.

 * @dev    Please note that if your token contract does not provide an owner with EIP-173, it must provide

 *         administration methods on the contract itself to interact with the registry otherwise the subscription

 *         will be locked to the options set during construction.

 */



abstract contract DefaultOperatorFilterer is OperatorFilterer {

    /// @dev The constructor that is called when the contract is being deployed.

    constructor() OperatorFilterer(CANONICAL_CORI_SUBSCRIPTION, true) {}

}



// File: @openzeppelin/contracts/security/ReentrancyGuard.sol





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



// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol





// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)



pragma solidity ^0.8.0;



/**

 * @dev These functions deal with verification of Merkle Trees proofs.

 *

 * The proofs can be generated using the JavaScript library

 * https://github.com/miguelmota/merkletreejs[merkletreejs].

 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.

 *

 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.

 */

library MerkleProof {

    /**

     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree

     * defined by `root`. For this, a `proof` must be provided, containing

     * sibling hashes on the branch from the leaf to the root of the tree. Each

     * pair of leaves and each pair of pre-images are assumed to be sorted.

     */

    function verify(

        bytes32[] memory proof,

        bytes32 root,

        bytes32 leaf

    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;

    }



    /**

     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up

     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt

     * hash matches the root of the tree. When processing the proof, the pairs

     * of leafs & pre-images are assumed to be sorted.

     *

     * _Available since v4.4._

     */

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {

                // Hash(current computed hash + current element of the proof)

                computedHash = _efficientHash(computedHash, proofElement);

            } else {

                // Hash(current element of the proof + current computed hash)

                computedHash = _efficientHash(proofElement, computedHash);

            }

        }

        return computedHash;

    }



    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {

            mstore(0x00, a)

            mstore(0x20, b)

            value := keccak256(0x00, 0x40)

        }

    }

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



// File: @openzeppelin/contracts/utils/Context.sol





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



// File: @openzeppelin/contracts/utils/Address.sol





// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)



pragma solidity ^0.8.0;



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

        // This method relies on extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        assembly {

            size := extcodesize(account)

        }

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



// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol





// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)



pragma solidity ^0.8.0;



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

interface IERC721Receiver {

    /**

     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}

     * by `operator` from `from`, this function is called.

     *

     * It must return its Solidity selector to confirm the token transfer.

     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.

     *

     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.

     */

    function onERC721Received(

        address operator,

        address from,

        uint256 tokenId,

        bytes calldata data

    ) external returns (bytes4);

}



// File: @openzeppelin/contracts/utils/introspection/IERC165.sol





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



// File: @openzeppelin/contracts/utils/introspection/ERC165.sol





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

abstract contract ERC165 is IERC165 {

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}



// File: @openzeppelin/contracts/token/ERC721/IERC721.sol





// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)



pragma solidity ^0.8.0;





/**

 * @dev Required interface of an ERC721 compliant contract.

 */

interface IERC721 is IERC165 {

    /**

     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.

     */

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);



    /**

     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.

     */

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);



    /**

     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.

     */

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    /**

     * @dev Returns the number of tokens in ``owner``'s account.

     */

    function balanceOf(address owner) external view returns (uint256 balance);



    /**

     * @dev Returns the owner of the `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function ownerOf(uint256 tokenId) external view returns (address owner);



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) external;



    /**

     * @dev Transfers `tokenId` token from `from` to `to`.

     *

     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must be owned by `from`.

     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) external;



    /**

     * @dev Gives permission to `to` to transfer `tokenId` token to another account.

     * The approval is cleared when the token is transferred.

     *

     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.

     *

     * Requirements:

     *

     * - The caller must own the token or be an approved operator.

     * - `tokenId` must exist.

     *

     * Emits an {Approval} event.

     */

    function approve(address to, uint256 tokenId) external;



    /**

     * @dev Returns the account approved for `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function getApproved(uint256 tokenId) external view returns (address operator);



    /**

     * @dev Approve or remove `operator` as an operator for the caller.

     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.

     *

     * Requirements:

     *

     * - The `operator` cannot be the caller.

     *

     * Emits an {ApprovalForAll} event.

     */

    function setApprovalForAll(address operator, bool _approved) external;



    /**

     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

     *

     * See {setApprovalForAll}

     */

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes calldata data

    ) external;

}



// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol





// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)



pragma solidity ^0.8.0;





/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

interface IERC721Metadata is IERC721 {

    /**

     * @dev Returns the token collection name.

     */

    function name() external view returns (string memory);



    /**

     * @dev Returns the token collection symbol.

     */

    function symbol() external view returns (string memory);



    /**

     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.

     */

    function tokenURI(uint256 tokenId) external view returns (string memory);

}



// File: erc721a/contracts/ERC721A.sol





// Creator: Chiru Labs



pragma solidity ^0.8.4;

















error ApprovalCallerNotOwnerNorApproved();

error ApprovalQueryForNonexistentToken();

error ApproveToCaller();

error ApprovalToCurrentOwner();

error BalanceQueryForZeroAddress();

error MintToZeroAddress();

error MintZeroQuantity();

error OwnerQueryForNonexistentToken();

error TransferCallerNotOwnerNorApproved();

error TransferFromIncorrectOwner();

error TransferToNonERC721ReceiverImplementer();

error TransferToZeroAddress();

error URIQueryForNonexistentToken();



/**

 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including

 * the Metadata extension. Built to optimize for lower gas during batch mints.

 *

 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).

 *

 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.

 *

 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).

 */

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;

    using Strings for uint256;



    // Compiler will pack this into a single 256bit word.

    struct TokenOwnership {

        // The address of the owner.

        address addr;

        // Keeps track of the start time of ownership with minimal overhead for tokenomics.

        uint64 startTimestamp;

        // Whether the token has been burned.

        bool burned;

    }



    // Compiler will pack this into a single 256bit word.

    struct AddressData {

        // Realistically, 2**64-1 is more than enough.

        uint64 balance;

        // Keeps track of mint count with minimal overhead for tokenomics.

        uint64 numberMinted;

        // Keeps track of burn count with minimal overhead for tokenomics.

        uint64 numberBurned;

        // For miscellaneous variable(s) pertaining to the address

        // (e.g. number of whitelist mint slots used).

        // If there are multiple variables, please pack them into a uint64.

        uint64 aux;

    }



    // The tokenId of the next token to be minted.

    uint256 internal _currentIndex;



    // The number of tokens burned.

    uint256 internal _burnCounter;



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Mapping from token ID to ownership details

    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.

    mapping(uint256 => TokenOwnership) internal _ownerships;



    // Mapping owner address to address data

    mapping(address => AddressData) private _addressData;



    // Mapping from token ID to approved address

    mapping(uint256 => address) private _tokenApprovals;



    // Mapping from owner to operator approvals

    mapping(address => mapping(address => bool)) private _operatorApprovals;



    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

        _currentIndex = _startTokenId();

    }



    /**

     * To change the starting tokenId, please override this function.

     */

    function _startTokenId() internal view virtual returns (uint256) {

        return 0;

    }



    /**

     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.

     */

    function totalSupply() public view returns (uint256) {

        // Counter underflow is impossible as _burnCounter cannot be incremented

        // more than _currentIndex - _startTokenId() times

        unchecked {

            return _currentIndex - _burnCounter - _startTokenId();

        }

    }



    /**

     * Returns the total amount of tokens minted in the contract.

     */

    function _totalMinted() internal view returns (uint256) {

        // Counter underflow is impossible as _currentIndex does not decrement,

        // and it is initialized to _startTokenId()

        unchecked {

            return _currentIndex - _startTokenId();

        }

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721-balanceOf}.

     */

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        return uint256(_addressData[owner].balance);

    }



    /**

     * Returns the number of tokens minted by `owner`.

     */

    function _numberMinted(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberMinted);

    }



    /**

     * Returns the number of tokens burned by or on behalf of `owner`.

     */

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);

    }



    /**

     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).

     */

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;

    }



    /**

     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).

     * If there are multiple variables, please pack them into a uint64.

     */

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;

    }



    /**

     * Gas spent here starts off proportional to the maximum mint batch size.

     * It gradually moves to O(1) as tokens get transferred around in the collection over time.

     */

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;



        unchecked {

            if (_startTokenId() <= curr && curr < _currentIndex) {

                TokenOwnership memory ownership = _ownerships[curr];

                if (!ownership.burned) {

                    if (ownership.addr != address(0)) {

                        return ownership;

                    }

                    // Invariant:

                    // There will always be an ownership that has an address and is not burned

                    // before an ownership that does not have an address and is not burned.

                    // Hence, curr will not underflow.

                    while (true) {

                        curr--;

                        ownership = _ownerships[curr];

                        if (ownership.addr != address(0)) {

                            return ownership;

                        }

                    }

                }

            }

        }

        revert OwnerQueryForNonexistentToken();

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _ownershipOf(tokenId).addr;

    }



    /**

     * @dev See {IERC721Metadata-name}.

     */

    function name() public view virtual override returns (string memory) {

        return _name;

    }



    /**

     * @dev See {IERC721Metadata-symbol}.

     */

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    /**

     * @dev See {IERC721Metadata-tokenURI}.

     */

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();



        string memory baseURI = _baseURI();

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';

    }



    /**

     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each

     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty

     * by default, can be overriden in child contracts.

     */

    function _baseURI() internal view virtual returns (string memory) {

        return '';

    }



    /**

     * @dev See {IERC721-approve}.

     */

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721A.ownerOf(tokenId);

        if (to == owner) revert ApprovalToCurrentOwner();



        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {

            revert ApprovalCallerNotOwnerNorApproved();

        }



        _approve(to, tokenId, owner);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSender()) revert ApproveToCaller();



        _operatorApprovals[_msgSender()][operator] = approved;

        emit ApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC721-isApprovedForAll}.

     */

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev See {IERC721-transferFrom}.

     */

    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public virtual override {

        _transfer(from, to, tokenId);

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) public virtual override {

        _transfer(from, to, tokenId);

        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {

            revert TransferToNonERC721ReceiverImplementer();

        }

    }



    /**

     * @dev Returns whether `tokenId` exists.

     *

     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

     *

     * Tokens start existing when they are minted (`_mint`),

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;

    }



    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');

    }



    /**

     * @dev Safely mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _safeMint(

        address to,

        uint256 quantity,

        bytes memory _data

    ) internal {

        _mint(to, quantity, _data, true);

    }



    /**

     * @dev Mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _mint(

        address to,

        uint256 quantity,

        bytes memory _data,

        bool safe

    ) internal {

        uint256 startTokenId = _currentIndex;

        if (to == address(0)) revert MintToZeroAddress();

        if (quantity == 0) revert MintZeroQuantity();



        _beforeTokenTransfers(address(0), to, startTokenId, quantity);



        // Overflows are incredibly unrealistic.

        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1

        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1

        unchecked {

            _addressData[to].balance += uint64(quantity);

            _addressData[to].numberMinted += uint64(quantity);



            _ownerships[startTokenId].addr = to;

            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);



            uint256 updatedIndex = startTokenId;

            uint256 end = updatedIndex + quantity;



            if (safe && to.isContract()) {

                do {

                    emit Transfer(address(0), to, updatedIndex);

                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {

                        revert TransferToNonERC721ReceiverImplementer();

                    }

                } while (updatedIndex != end);

                // Reentrancy protection

                if (_currentIndex != startTokenId) revert();

            } else {

                do {

                    emit Transfer(address(0), to, updatedIndex++);

                } while (updatedIndex != end);

            }

            _currentIndex = updatedIndex;

        }

        _afterTokenTransfers(address(0), to, startTokenId, quantity);

    }



    /**

     * @dev Transfers `tokenId` from `from` to `to`.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `tokenId` token must be owned by `from`.

     *

     * Emits a {Transfer} event.

     */

    function _transfer(

        address from,

        address to,

        uint256 tokenId

    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);



        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();



        bool isApprovedOrOwner = (_msgSender() == from ||

            isApprovedForAll(from, _msgSender()) ||

            getApproved(tokenId) == _msgSender());



        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        if (to == address(0)) revert TransferToZeroAddress();



        _beforeTokenTransfers(from, to, tokenId, 1);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId, from);



        // Underflow of the sender's balance is impossible because we check for

        // ownership above and the recipient's balance can't realistically overflow.

        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.

        unchecked {

            _addressData[from].balance -= 1;

            _addressData[to].balance += 1;



            TokenOwnership storage currSlot = _ownerships[tokenId];

            currSlot.addr = to;

            currSlot.startTimestamp = uint64(block.timestamp);



            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.

            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.

            uint256 nextTokenId = tokenId + 1;

            TokenOwnership storage nextSlot = _ownerships[nextTokenId];

            if (nextSlot.addr == address(0)) {

                // This will suffice for checking _exists(nextTokenId),

                // as a burned slot cannot contain the zero address.

                if (nextTokenId != _currentIndex) {

                    nextSlot.addr = from;

                    nextSlot.startTimestamp = prevOwnership.startTimestamp;

                }

            }

        }



        emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId, 1);

    }



    /**

     * @dev This is equivalent to _burn(tokenId, false)

     */

    function _burn(uint256 tokenId) internal virtual {

        _burn(tokenId, false);

    }



    /**

     * @dev Destroys `tokenId`.

     * The approval is cleared when the token is burned.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     *

     * Emits a {Transfer} event.

     */

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);



        address from = prevOwnership.addr;



        if (approvalCheck) {

            bool isApprovedOrOwner = (_msgSender() == from ||

                isApprovedForAll(from, _msgSender()) ||

                getApproved(tokenId) == _msgSender());



            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        }



        _beforeTokenTransfers(from, address(0), tokenId, 1);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId, from);



        // Underflow of the sender's balance is impossible because we check for

        // ownership above and the recipient's balance can't realistically overflow.

        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.

        unchecked {

            AddressData storage addressData = _addressData[from];

            addressData.balance -= 1;

            addressData.numberBurned += 1;



            // Keep track of who burned the token, and the timestamp of burning.

            TokenOwnership storage currSlot = _ownerships[tokenId];

            currSlot.addr = from;

            currSlot.startTimestamp = uint64(block.timestamp);

            currSlot.burned = true;



            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.

            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.

            uint256 nextTokenId = tokenId + 1;

            TokenOwnership storage nextSlot = _ownerships[nextTokenId];

            if (nextSlot.addr == address(0)) {

                // This will suffice for checking _exists(nextTokenId),

                // as a burned slot cannot contain the zero address.

                if (nextTokenId != _currentIndex) {

                    nextSlot.addr = from;

                    nextSlot.startTimestamp = prevOwnership.startTimestamp;

                }

            }

        }



        emit Transfer(from, address(0), tokenId);

        _afterTokenTransfers(from, address(0), tokenId, 1);



        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.

        unchecked {

            _burnCounter++;

        }

    }



    /**

     * @dev Approve `to` to operate on `tokenId`

     *

     * Emits a {Approval} event.

     */

    function _approve(

        address to,

        uint256 tokenId,

        address owner

    ) private {

        _tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.

     *

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkContractOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) private returns (bool) {

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {

            return retval == IERC721Receiver(to).onERC721Received.selector;

        } catch (bytes memory reason) {

            if (reason.length == 0) {

                revert TransferToNonERC721ReceiverImplementer();

            } else {

                assembly {

                    revert(add(32, reason), mload(reason))

                }

            }

        }

    }



    /**

     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.

     * And also called before burning one token.

     *

     * startTokenId - the first token id to be transferred

     * quantity - the amount to be transferred

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be

     * transferred to `to`.

     * - When `from` is zero, `tokenId` will be minted for `to`.

     * - When `to` is zero, `tokenId` will be burned by `from`.

     * - `from` and `to` are never both zero.

     */

    function _beforeTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual {}



    /**

     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes

     * minting.

     * And also called after one token has been burned.

     *

     * startTokenId - the first token id to be transferred

     * quantity - the amount to be transferred

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been

     * transferred to `to`.

     * - When `from` is zero, `tokenId` has been minted for `to`.

     * - When `to` is zero, `tokenId` has been burned by `from`.

     * - `from` and `to` are never both zero.

     */

    function _afterTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual {}

}



// File: contracts/FucContract/fuc.sol







pragma solidity ^0.8.17;













/////////////////////////////////////////////////////////////////////////////

//                                                                         //

//                                                                         //

//    ░░░░░░░░░█████████░░░░░░░░░██░░░░░░██░░░░░░░░░░░░░█████████░░░░░░    //

//    ░░░░░░░░░██░░░░░░░░░░░░░░░░██░░░░░░██░░░░░░░░░░░██░░░░░░░░░░░░░░░    //

//    ░░░░░░░░░█████████░░░░░░░░░██░░░░░░██░░░░░░░░░░░██░░░░░░░░░░░░░░░    //

//    ░░░░░░░░░██░░░░░░░░░░░░░░░░██░░░░░░██░░░░░░░░░░░██░░░░░░░░░░░░░░░    //

//    ░░░░░░░░░██░░░░░░░░░░░░░░░░██░░░░░░██░░░░░░░░░░░██░░░░░░░░░░░░░░░    //

//    ░░░░░░░░░██░░░░░░░░░░░░░░░░██████████░░░░░░░░░░░░░█████████░░░░░░    //

//                                                                         //

//                                                                         //

/////////////////////////////////////////////////////////////////////////////



contract Fuc is ERC721A, Ownable, ReentrancyGuard ,DefaultOperatorFilterer{



    string public baseUri;



    bool public paused = false;



    string public contractURI;



    uint64 public count = 7777;



    mapping(uint8 => uint8) public tokenLimit;



    mapping(uint8 => uint256) public priceType;



    mapping(uint8 => bytes32) public rootType;



    mapping(uint8 => bool) public levelStatu;



    mapping(address => bool)  public marketPlace;



    address private withdrawAddress;



    TimeConfig public timeConfig;



    constructor(

        string memory _tokenName,

        string memory _tokenSymbol,

        string memory _baseUri,

        string memory _contractURI,

        address _address

    ) ERC721A(_tokenName, _tokenSymbol) {

        baseUri = _baseUri;

        contractURI = _contractURI;

        withdrawAddress = _address;

    }



    struct TimeConfig {

        uint256 partnerStartTime;

        uint256 partnerEndTime;

        uint256 fucthelistStartTime;

        uint256 fucthelistEndTime;

        uint256 whitelistStartTime;

        uint256 whitelistEndTime;

    }

    //--------add--------

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {

        require(marketPlace[operator] == true, "Not allowed");

        super.setApprovalForAll(operator, approved);

    }



    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {

        require(marketPlace[operator] == true, "Not allowed");

        super.approve(operator, tokenId);

    }



    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)

        public

        override

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId, data);

    }

    //--------add--------

    function setAllowMarket(address market) public onlyOwner{

        marketPlace[market] = true;

    }



    modifier onlyAccounts() {

        require(msg.sender == tx.origin, "Not allowed origin");

        _;

    }



    modifier fucStatus() {

        require(paused == true, "Sale not started");

        _;

    }



    function setLevelStatu(uint8 ltype , bool status) public onlyOwner{

        require(ltype <= 3,"Type error");

        for (uint8 i = 0; i <= 3; i++) {

            levelStatu[i] = false;

        }

        levelStatu[ltype-1] = status;

    }



    function setPausedStatu() public onlyOwner{

        paused = !paused;

    }

    /**

     * method setTokenLimit

     * param detail

     * ttype == 1 set partner token limit 

     * ttype == 2 set fucthelist token limit 

     * ttype == 3 set whitelist token limit 

     * ttype == 4 set open token limit

     */

    function setTokenLimit(uint8 _account , uint8 ttype) public onlyOwner fucStatus{

        require(ttype <= 4 && _account < 10,"Param error");

        // require(_account < 10,"Upper limit exceeded");

        tokenLimit[ttype-1] = _account;

    }



    /**

     * method setTime

     * param detail

     * timeType == 1 set partner time

     * timeType == 2 set fucthelist time 

     * timeType == 3 set whitelist time

     */

    function setTime(uint256 startTime , uint256 endTime ,int8 timeType) public onlyOwner fucStatus{

        // require(timeType <= 3,"Type error");

        if(timeType == 1){

            timeConfig.partnerStartTime = startTime;

            timeConfig.partnerEndTime = endTime;

        }

        if(timeType == 2) {

            timeConfig.fucthelistStartTime = startTime;

            timeConfig.fucthelistEndTime = endTime;

        }



        if(timeType == 3) {

            timeConfig.whitelistStartTime = startTime;

            timeConfig.whitelistEndTime = endTime;

        }

    }

    /**

     * method setPrice

     * param detail

     * ptype == 1 set partner token price 

     * ptype == 2 set fucthelist token price 

     * ptype == 3 set whitelist token price 

     * ptype == 4 set open token price 

     */

    function setPrice(uint256 price , uint8 ptype) public onlyOwner fucStatus{

        require(ptype <= 4,"Type error");

        priceType[ptype - 1] = price;

    }



    /**

     * method setRoot

     * param detail

     * rtype == 1 set partner merkleRoot

     * rtype == 2 set fucthelist merkleRoot 

     * rtype == 3 set whitelist merkleRoot

     */

    function setRoot(bytes32 _root , uint8 rtype) public onlyOwner {

        require(rtype <= 3,"Type error");

        rootType[rtype - 1] = _root;

    }



    function isValid(bytes32[] memory proof ,bytes32 _root) internal view returns (bool) {

        return MerkleProof.verify(proof, _root ,keccak256(abi.encodePacked(msg.sender)));

    }



    function SafeMint(uint8 amount , bytes32[] memory proof) external payable fucStatus onlyAccounts {

        require(amount > 0 && amount <= 6, "Amount must in 0-6");

        uint64 aux = _getAux(msg.sender);

        if(levelStatu[0] == true) {

            require(block.timestamp >= timeConfig.partnerStartTime && block.timestamp <= timeConfig.partnerEndTime && priceType[0] > 0,"sale not started");

            require(msg.value >= priceType[0] * amount, "Insufficient funds!");

            require(isValid(proof ,rootType[0]), "Not Allowlist");

            require(amount + _numberMinted(msg.sender) <= tokenLimit[0], "Upper limit exceeded");

            _setAux(msg.sender, aux + amount);

        } else if(levelStatu[1] == true) {

            require(block.timestamp >= timeConfig.fucthelistStartTime && block.timestamp <= timeConfig.fucthelistEndTime && priceType[1] > 0  ,"sale not started");

            require(msg.value >= priceType[1] * amount, "Insufficient funds!");

            if(aux < 10) {

                aux = 10;

            }

            require(aux + amount - 10 <= tokenLimit[1], "Upper limit exceeded");

            require(isValid(proof ,rootType[1]), "Not Allowlist");

            setAux(1,msg.sender, amount , aux);

        } else if(levelStatu[2] == true) {

            require(block.timestamp >= timeConfig.whitelistStartTime && block.timestamp <= timeConfig.whitelistEndTime && priceType[2] > 0  ,"sale not started");

            require(msg.value >= priceType[2] * amount, "Insufficient funds!");

            if(aux < 20) {

                aux = 20;

            }

            require(aux + amount - 20 <= tokenLimit[2], "Upper limit exceeded");

            require(isValid(proof ,rootType[2]), "Not Allowlist");

            setAux(2,msg.sender, amount, aux);

        } else {

            require(block.timestamp > timeConfig.whitelistEndTime && timeConfig.whitelistEndTime != 0 ,"sale not started") ;

            if(aux < 30) {

                aux = 30;

            }

            require(aux + amount - 30 <= tokenLimit[3], "Upper limit exceeded");

            require(priceType[3] > 0 && msg.value >= priceType[3] * amount , "Insufficient funds!");

            setAux(3,msg.sender, amount, aux);

        }

        count = count - amount;

        require(count >= 0, "count out of range");

        

        _safeMint(msg.sender, amount);

    }



    //  function geTime() public view returns(uint256){

    //     return block.timestamp;

    // }



    function setAux(uint8 ctype , address ads , uint8 amount ,uint64 aux) private {

        if(ctype == aux/10){

            _setAux(ads, aux + amount);

        }

    }



    function getAux(address owner) public view returns(uint64){

        return _getAux(owner);

    }



    function getPrice() public view returns(uint256, uint8){

        uint256 _price;

        uint8 _type;

        if(levelStatu[0] == true) {

            _price = priceType[0];

            _type = 1;

        } else if(levelStatu[1] == true) {

            _price = priceType[1];

            _type = 2;

        } else if(levelStatu[2] == true) {

            _price = priceType[2];

            _type = 3;

        } else {

            _price = priceType[3];

            _type = 4;

        }

        return (_price , _type);

    }



    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId) && bytes(baseUri).length > 0, "Metadata: nonexistent token");

        // require(bytes(baseUri).length > 0, "no set baseUri");

        return string(abi.encodePacked(baseUri, Strings.toString(tokenId), ".json"));

    }



    function changeBaseURI(string memory baseURI_) public onlyOwner fucStatus {

        baseUri = baseURI_;

    }

    

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {

        uint256 ownerTokenCount = balanceOf(_owner);

        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);

        uint256 currentTokenId = _startTokenId();

        uint256 ownedTokenIndex = 0;

        address latestOwnerAddress;



        while (ownedTokenIndex < ownerTokenCount) {

            TokenOwnership memory ownership = _ownerships[currentTokenId];



            if (!ownership.burned && ownership.addr != address(0)) {

                latestOwnerAddress = ownership.addr; 

            }



            if (latestOwnerAddress == _owner) {

                ownedTokenIds[ownedTokenIndex] = currentTokenId;



                ownedTokenIndex++;

            }



            currentTokenId++;

        }



        return ownedTokenIds;

    }

    

    function withdrawMoney() external nonReentrant onlyAccounts {

        require(msg.sender == withdrawAddress, "Not allowed origin");

        (bool success, ) = withdrawAddress.call{value: address(this).balance}("");

        require(success, "Transfer failed.");

    }



}