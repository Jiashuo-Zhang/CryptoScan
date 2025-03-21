/**
 *Submitted for verification at Etherscan.io on 2022-09-09
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
//AE THER 

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**t
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


    // OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

    // File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


    // OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

    // File: @openzeppelin/contracts/finance/PaymentSplitter.sol


    // OpenZeppelin Contracts v4.4.1 (finance/PaymentSplitter.sol)


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

    // File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


    // OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

    pragma solidity ^0.8.0;


    /**
    * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
    * @dev See https://eips.ethereum.org/EIPS/eip-721
    */
    interface IERC721Enumerable is IERC721 {
        /**
        * @dev Returns the total amount of tokens stored by the contract.
        */
        function totalSupply() external view returns (uint256);

        /**
        * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
        * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
        */
        function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

        /**
        * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
        * Use along with {totalSupply} to enumerate all tokens.
        */
        function tokenByIndex(uint256 index) external view returns (uint256);
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
    error MintedQueryForZeroAddress();
    error BurnedQueryForZeroAddress();
    error AuxQueryForZeroAddress();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error OwnerIndexOutOfBounds();
    error OwnerQueryForNonexistentToken();
    error TokenIndexOutOfBounds();
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
            uint64 mintedInWhitelist;
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
        // An empty struct value does not necessarily mean the token is unowned. See ownershipOf implementation for details.
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
        * @dev See {IERC721Enumerable-totalSupply}.
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

        /**
        * Returns the number of tokens burned by or on behalf of `owner`.
        */
        function _numberBurned(address owner) internal view returns (uint256) {
            if (owner == address(0)) revert BurnedQueryForZeroAddress();
            return uint256(_addressData[owner].numberBurned);
        }

        /**
        * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
        */
        function _getNumberMintedInWhitelist(address owner) public view returns (uint64) {
            if (owner == address(0)) revert AuxQueryForZeroAddress();
            return _addressData[owner].mintedInWhitelist;
        }

        /**
        * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
        * If there are multiple variables, please pack them into a uint64.
        */
        function _increaseNumberMintedInWhitelist(address owner, uint64 aux) internal {
            if (owner == address(0)) revert AuxQueryForZeroAddress();
            _addressData[owner].mintedInWhitelist += aux;
        }

        /**
        * Gas spent here starts off proportional to the maximum mint batch size.
        * It gradually moves to O(1) as tokens get transferred around in the collection over time.
        */
        function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
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
            return ownershipOf(tokenId).addr;
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
        function approve(address to, uint256 tokenId) public override {
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
        function setApprovalForAll(address operator, bool approved) public override {
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
            return _startTokenId() <= tokenId && tokenId < _currentIndex &&
                !_ownerships[tokenId].burned;
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
        *0
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
            TokenOwnership memory prevOwnership = ownershipOf(tokenId);

            bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
                isApprovedForAll(prevOwnership.addr, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
            if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
            if (to == address(0)) revert TransferToZeroAddress();

            _beforeTokenTransfers(from, to, tokenId, 1);

            // Clear approvals from the previous owner
            _approve(address(0), tokenId, prevOwnership.addr);

            // Underflow of the sender's balance is impossible because we check for
            // ownership above and the recipient's balance can't realistically overflow.
            // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
            unchecked {
                _addressData[from].balance -= 1;
                _addressData[to].balance += 1;

                _ownerships[tokenId].addr = to;
                _ownerships[tokenId].startTimestamp = uint64(block.timestamp);

                // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
                // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
                uint256 nextTokenId = tokenId + 1;
                if (_ownerships[nextTokenId].addr == address(0)) {
                    // This will suffice for checking _exists(nextTokenId),
                    // as a burned slot cannot contain the zero address.
                    if (nextTokenId < _currentIndex) {
                        _ownerships[nextTokenId].addr = prevOwnership.addr;
                        _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                    }
                }
            }

            emit Transfer(from, to, tokenId);
            _afterTokenTransfers(from, to, tokenId, 1);
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
        function _burn(uint256 tokenId) internal virtual {
            TokenOwnership memory prevOwnership = ownershipOf(tokenId);

            _beforeTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

            // Clear approvals from the previous owner
            _approve(address(0), tokenId, prevOwnership.addr);

            // Underflow of the sender's balance is impossible because we check for
            // ownership above and the recipient's balance can't realistically overflow.
            // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
            unchecked {
                _addressData[prevOwnership.addr].balance -= 1;
                _addressData[prevOwnership.addr].numberBurned += 1;

                // Keep track of who burned the token, and the timestamp of burning.
                _ownerships[tokenId].addr = prevOwnership.addr;
                _ownerships[tokenId].startTimestamp = uint64(block.timestamp);
                _ownerships[tokenId].burned = true;

                // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
                // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
                uint256 nextTokenId = tokenId + 1;
                if (_ownerships[nextTokenId].addr == address(0)) {
                    // This will suffice for checking _exists(nextTokenId),
                    // as a burned slot cannot contain the zero address.
                    if (nextTokenId < _currentIndex) {
                        _ownerships[nextTokenId].addr = prevOwnership.addr;
                        _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                    }
                }
            }

            emit Transfer(prevOwnership.addr, address(0), tokenId);
            _afterTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

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

    // File: erc721a/contracts/extensions/ERC721ABurnable.sol


    // Creator: Chiru Labs

    pragma solidity ^0.8.4;



    /**
    * @title ERC721A Burnable Token
    * @dev ERC721A Token that can be irreversibly burned (destroyed).
    */
    abstract contract ERC721ABurnable is Context, ERC721A {

        /**
        * @dev Burns `tokenId`. See {ERC721A-_burn}.
        *
        * Requirements:
        *
        * - The caller must own `tokenId` or be an approved operator.
        */
        function burn(uint256 tokenId) public virtual {
            TokenOwnership memory prevOwnership = ownershipOf(tokenId);

            bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
                isApprovedForAll(prevOwnership.addr, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

            _burn(tokenId);
        }
    }
    // File: contracts/MDMA.sol


    pragma solidity ^0.8.4;




    //AE THER   

    contract Akyllers is ERC721A, Ownable, ReentrancyGuard , ERC721ABurnable {

    using Strings for uint256;
    uint256 public constant  maxSupply = 4444; 
    bytes32 public merkleRoot;
    string public  baseUri; 
    string public  obscurumuri;

    string public extension;  
    uint256 public cost;  

    uint256 public maxperaddress; 
    uint256 public supplyLimit; 
    bool public paused = true;
    bool public whitelistMintEnabled = true;
    bool public revealed = false;
    string public constant provenance = "d05ad6c8d7fb2569b8fe8e4942e6d3591eb6cf5bc75bcbc691613b4143587526";
    uint256 public startingIndex;
    //mapping ID=>address => number of minted nfts  
    mapping(address => uint256) public addresstxs;
    uint256 phaseTag=0;
    
    constructor(
        string memory _Name,
        string memory _Symbol,
        uint256 _cost,
        uint256 _maxperaddress,
        uint256 _supplyLimit,
        bytes32 _merkleRoot,
        string memory _obscurumUri, 
        string memory _extension
    
    ) ERC721A(_Name, _Symbol) {
        // deploy the contract with the PWL parameters
        cost= _cost;
        maxperaddress = _maxperaddress;
        obscurumuri = _obscurumUri;
        extension = _extension;  
        merkleRoot = _merkleRoot;
        require(supplyLimit<=maxSupply);
        supplyLimit = _supplyLimit;
    }

    //resets the amount of nft bought from whitelisted suer if the phase changes
    function _startTokenId() internal pure override returns (uint256){
        return 1;
    }

    function validateGreaterThanZero(uint256 _value) public pure {
        require(_value>0, "amount cannot be zero");
    }

    function validateAmount(uint256 _mintAmount, uint256 maxAmount) public view{
        validateGreaterThanZero(_mintAmount);
        require(_totalMinted() + _mintAmount <= maxAmount, 'Max supply in this phase exceeded');  
    }


    function validatePrice(uint256 value, uint256 _mintAmount) public view{
        validateGreaterThanZero(_mintAmount); //va;idates mint amount 
        if(cost > 0) {require(value == cost * _mintAmount, 'Incorrect amount ');}
    }
    function validateNotPaused() public view{
        require(!paused, "Still In phase"); 
    }    
    function validateWhitelistState(bool state) public view {
        require(whitelistMintEnabled==state);
    }

    function validateMintPerAddress(address sender, uint256 _mintAmount, uint256 addressT, uint256 whitelistT) public {
        //Address tag is the the phase tag that address is in
        uint256 value = addressT;
        /*
            addresstxs[sender]  tracks both amount and phase tag 
            addresstxs[sender] =  1        0
                                amount   phaseTag
            amount = addresstxs[sender]/10
            phaseTag = addresstxs[sender]%10
        */
        //checks if the address tag is the same as phase tag 
        if( (value%10) !=whitelistT ) {
            //checks if the amount entered is greater than max per address then updates 
            require(_mintAmount<=maxperaddress,"wallet limit exceeded");
            addresstxs[sender]=(_mintAmount*10)+whitelistT;
        } else {
            require((value/10) + _mintAmount <= maxperaddress, 'wallet limit exceeded ');
            addresstxs[sender] += (_mintAmount*10);
        }
    }

    function Presalemint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable nonReentrant {
        //verify that the supply is not exceeded by address in specifc whitelist phase
        validateAmount(_mintAmount, supplyLimit);
        validatePrice(msg.value, _mintAmount);
        // Verify whitelist requirements dont allow mints when public sale starts
        require(MerkleProof.verify(_merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), 'Invalid proof!');
        //verify that minting is not paused
        validateNotPaused();
        //verify that the smart contract in the whitelist phase
        validateWhitelistState(true);
        //change the phase 
        validateMintPerAddress(msg.sender,_mintAmount, addresstxs[msg.sender], phaseTag);
        //minting 
        _safeMint(msg.sender, _mintAmount);
        
    }
    //Normal minting allows minting on public sale satisfyign the necessary conditions

    
    
    function Airdrop(uint256[] memory  _mintAmount, address[] memory   _receivers) public nonReentrant  onlyOwner {
        require(_mintAmount.length == _receivers.length, "Arrays need to be equal and respective");
        for(uint i = 0; i < _mintAmount.length;) {
            validateAmount(_mintAmount[i], maxSupply);
            _safeMint(_receivers[i], _mintAmount[i]);
            unchecked{i++;}
        }
    }

    //Normal minting allows minting on public sale satisfyign the necessary conditions
    function mint(uint256 _mintAmount) public payable  nonReentrant {
        //verifies that the amount minted is within address limits and within max supply
        validateAmount(_mintAmount, maxSupply);
        //verifies price compliance
        validatePrice(msg.value,_mintAmount);
        //verifies that smart contract is in Public state
        validateWhitelistState(false);
        //verifiesthat Public Minting is not paused
        validateNotPaused();
        //validate amount minted per address in public sale
        validateMintPerAddress(msg.sender,_mintAmount, addresstxs[msg.sender], phaseTag);
        //minting
        _safeMint(msg.sender, _mintAmount);
    } 

    // get multiple ids that a owner owns  excluding burned tokens  this function is for future off or on chain data gathering 
    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = _startTokenId();
        uint256 ownedTokenIndex = 0;
        address latestOwnerAddress;
        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= _totalMinted() ) {
        TokenOwnership memory ownership = _ownerships[currentTokenId]; 
        if (!ownership.burned && ownership.addr != address(0)) {
            latestOwnerAddress = ownership.addr; 
        }
        if (latestOwnerAddress == _owner &&  !ownership.burned )  {
            ownedTokenIds[ownedTokenIndex] = currentTokenId;
            ownedTokenIndex++;
        }
        currentTokenId++;
        }
        return ownedTokenIds;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');
        if (revealed == false) {return obscurumuri;}
        return bytes(baseUri).length > 0 ? string(abi.encodePacked(baseUri, _tokenId.toString(), extension)) : '';
    }

    // SETTERS DONE BY OWNER ONLY

    function setWhitelistPhase(bytes32 _merkleRoot, uint256 _maxperaddress, uint256 _supplyLimit, uint256 _price) external onlyOwner {
        require(_supplyLimit<=maxSupply);
        setMerkleRoot(_merkleRoot);           
        setMaxPerAddress(_maxperaddress);
        setPaused(true);
        setCost(_price);
        phaseTag +=1; // set a new phase on every call
        supplyLimit +=_supplyLimit; // set the total supply limit on the whitelist phase
    }

    
    function setPublicSalePhase(uint256 _maxperaddress, uint256 _price) external onlyOwner {
        setMaxPerAddress(_maxperaddress);
        setPaused(true);
        setCost(_price);
        phaseTag+=1;
        whitelistMintEnabled= false; 
    }
    function setSupplyLimit(uint256 _supplyLimit) public onlyOwner nonReentrant{
        supplyLimit = _supplyLimit;
    }
    function setCost(uint256 _cost) public onlyOwner nonReentrant {
        cost = _cost;
    } 

    function setMaxPerAddress(uint256 _maxperaddress) public onlyOwner nonReentrant {
        maxperaddress = _maxperaddress;
    }
    
    function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner nonReentrant {
        obscurumuri = _hiddenMetadataUri;
    }

    function setUri(string memory _uri) public onlyOwner nonReentrant {
        baseUri = _uri;
    }

    // should be set before any minting starts 
    function setPaused(bool choice) public onlyOwner nonReentrant { 
        paused = choice;
    }
    
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner nonReentrant {
        merkleRoot = _merkleRoot;
    }

    function reveal(bool state ) public onlyOwner nonReentrant{
        revealed=state;
    }

    function setStartingIndex() public  nonReentrant onlyOwner {
            require(startingIndex == 0, "Starting index is already set");
            startingIndex = uint256(keccak256(abi.encodePacked(
                block.timestamp + block.difficulty + block.gaslimit + block.number +
                uint256(keccak256(abi.encodePacked(block.coinbase))) / block.timestamp
            ))) % maxSupply;
    }
        // release address based on shares.
    function withdrawEth() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}