/**

 *Submitted for verification at Etherscan.io on 2023-02-20

*/



// SPDX-License-Identifier: MIT

// Creator: lohko.io



pragma solidity >=0.8.17;





// ERC721A Contracts v3.3.0

// Creator: Chiru Labs









// ERC721A Contracts v3.3.0

// Creator: Chiru Labs









// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)









// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)







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



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.

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

     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721

     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must

     * understand this adds an external call which potentially creates a reentrancy vulnerability.

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

     * @dev Returns the account approved for `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function getApproved(uint256 tokenId) external view returns (address operator);



    /**

     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

     *

     * See {setApprovalForAll}

     */

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}





// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)











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





/**

 * @dev Interface of an ERC721A compliant contract.

 */

interface IERC721A is IERC721, IERC721Metadata {

    /**

     * The caller must own the token or be an approved operator.

     */

    error ApprovalCallerNotOwnerNorApproved();



    /**

     * The token does not exist.

     */

    error ApprovalQueryForNonexistentToken();



    /**

     * The caller cannot approve to their own address.

     */

    error ApproveToCaller();



    /**

     * The caller cannot approve to the current owner.

     */

    error ApprovalToCurrentOwner();



    /**

     * Cannot query the balance for the zero address.

     */

    error BalanceQueryForZeroAddress();



    /**

     * Cannot mint to the zero address.

     */

    error MintToZeroAddress();



    /**

     * The quantity of tokens minted must be more than zero.

     */

    error MintZeroQuantity();



    /**

     * The token does not exist.

     */

    error OwnerQueryForNonexistentToken();



    /**

     * The caller must own the token or be an approved operator.

     */

    error TransferCallerNotOwnerNorApproved();



    /**

     * The token must be owned by `from`.

     */

    error TransferFromIncorrectOwner();



    /**

     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.

     */

    error TransferToNonERC721ReceiverImplementer();



    /**

     * Cannot transfer to the zero address.

     */

    error TransferToZeroAddress();



    /**

     * The token does not exist.

     */

    error URIQueryForNonexistentToken();



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



    /**

     * @dev Returns the total amount of tokens stored by the contract.

     * 

     * Burned tokens are calculated here, use `_totalMinted()` if you want to count just minted tokens.

     */

    function totalSupply() external view returns (uint256);

}



// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)







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

     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.

     */

    function onERC721Received(

        address operator,

        address from,

        uint256 tokenId,

        bytes calldata data

    ) external returns (bytes4);

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





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)









// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)







/**

 * @dev Standard math utilities missing in the Solidity language.

 */

library Math {

    enum Rounding {

        Down, // Toward negative infinity

        Up, // Toward infinity

        Zero // Toward zero

    }



    /**

     * @dev Returns the largest of two numbers.

     */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;

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

        // (a + b) / 2 can overflow.

        return (a & b) + (a ^ b) / 2;

    }



    /**

     * @dev Returns the ceiling of the division of two numbers.

     *

     * This differs from standard division with `/` in that it rounds up instead

     * of rounding down.

     */

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b - 1) / b can overflow on addition, so we distribute.

        return a == 0 ? 0 : (a - 1) / b + 1;

    }



    /**

     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0

     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)

     * with further edits by Uniswap Labs also under MIT license.

     */

    function mulDiv(

        uint256 x,

        uint256 y,

        uint256 denominator

    ) internal pure returns (uint256 result) {

        unchecked {

            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use

            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256

            // variables such that product = prod1 * 2^256 + prod0.

            uint256 prod0; // Least significant 256 bits of the product

            uint256 prod1; // Most significant 256 bits of the product

            assembly {

                let mm := mulmod(x, y, not(0))

                prod0 := mul(x, y)

                prod1 := sub(sub(mm, prod0), lt(mm, prod0))

            }



            // Handle non-overflow cases, 256 by 256 division.

            if (prod1 == 0) {

                return prod0 / denominator;

            }



            // Make sure the result is less than 2^256. Also prevents denominator == 0.

            require(denominator > prod1);



            ///////////////////////////////////////////////

            // 512 by 256 division.

            ///////////////////////////////////////////////



            // Make division exact by subtracting the remainder from [prod1 prod0].

            uint256 remainder;

            assembly {

                // Compute remainder using mulmod.

                remainder := mulmod(x, y, denominator)



                // Subtract 256 bit number from 512 bit number.

                prod1 := sub(prod1, gt(remainder, prod0))

                prod0 := sub(prod0, remainder)

            }



            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.

            // See https://cs.stackexchange.com/q/138556/92363.



            // Does not overflow because the denominator cannot be zero at this stage in the function.

            uint256 twos = denominator & (~denominator + 1);

            assembly {

                // Divide denominator by twos.

                denominator := div(denominator, twos)



                // Divide [prod1 prod0] by twos.

                prod0 := div(prod0, twos)



                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.

                twos := add(div(sub(0, twos), twos), 1)

            }



            // Shift in bits from prod1 into prod0.

            prod0 |= prod1 * twos;



            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such

            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for

            // four bits. That is, denominator * inv = 1 mod 2^4.

            uint256 inverse = (3 * denominator) ^ 2;



            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works

            // in modular arithmetic, doubling the correct bits in each step.

            inverse *= 2 - denominator * inverse; // inverse mod 2^8

            inverse *= 2 - denominator * inverse; // inverse mod 2^16

            inverse *= 2 - denominator * inverse; // inverse mod 2^32

            inverse *= 2 - denominator * inverse; // inverse mod 2^64

            inverse *= 2 - denominator * inverse; // inverse mod 2^128

            inverse *= 2 - denominator * inverse; // inverse mod 2^256



            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.

            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is

            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1

            // is no longer required.

            result = prod0 * inverse;

            return result;

        }

    }



    /**

     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.

     */

    function mulDiv(

        uint256 x,

        uint256 y,

        uint256 denominator,

        Rounding rounding

    ) internal pure returns (uint256) {

        uint256 result = mulDiv(x, y, denominator);

        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {

            result += 1;

        }

        return result;

    }



    /**

     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.

     *

     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).

     */

    function sqrt(uint256 a) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.

        //

        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have

        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.

        //

        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`

        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`

        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`

        //

        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.

        uint256 result = 1 << (log2(a) >> 1);



        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,

        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at

        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision

        // into the expected uint128 result.

        unchecked {

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            return min(result, a / result);

        }

    }



    /**

     * @notice Calculates sqrt(a), following the selected rounding direction.

     */

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = sqrt(a);

            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 2, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log2(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >> 128 > 0) {

                value >>= 128;

                result += 128;

            }

            if (value >> 64 > 0) {

                value >>= 64;

                result += 64;

            }

            if (value >> 32 > 0) {

                value >>= 32;

                result += 32;

            }

            if (value >> 16 > 0) {

                value >>= 16;

                result += 16;

            }

            if (value >> 8 > 0) {

                value >>= 8;

                result += 8;

            }

            if (value >> 4 > 0) {

                value >>= 4;

                result += 4;

            }

            if (value >> 2 > 0) {

                value >>= 2;

                result += 2;

            }

            if (value >> 1 > 0) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log2(value);

            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 10, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >= 10**64) {

                value /= 10**64;

                result += 64;

            }

            if (value >= 10**32) {

                value /= 10**32;

                result += 32;

            }

            if (value >= 10**16) {

                value /= 10**16;

                result += 16;

            }

            if (value >= 10**8) {

                value /= 10**8;

                result += 8;

            }

            if (value >= 10**4) {

                value /= 10**4;

                result += 4;

            }

            if (value >= 10**2) {

                value /= 10**2;

                result += 2;

            }

            if (value >= 10**1) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log10(value);

            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 256, rounded down, of a positive value.

     * Returns 0 if given 0.

     *

     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.

     */

    function log256(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >> 128 > 0) {

                value >>= 128;

                result += 16;

            }

            if (value >> 64 > 0) {

                value >>= 64;

                result += 8;

            }

            if (value >> 32 > 0) {

                value >>= 32;

                result += 4;

            }

            if (value >> 16 > 0) {

                value >>= 16;

                result += 2;

            }

            if (value >> 8 > 0) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log256(value);

            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);

        }

    }

}





/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory) {

        unchecked {

            uint256 length = Math.log10(value) + 1;

            string memory buffer = new string(length);

            uint256 ptr;

            /// @solidity memory-safe-assembly

            assembly {

                ptr := add(buffer, add(32, length))

            }

            while (true) {

                ptr--;

                /// @solidity memory-safe-assembly

                assembly {

                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))

                }

                value /= 10;

                if (value == 0) break;

            }

            return buffer;

        }

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.

     */

    function toHexString(uint256 value) internal pure returns (string memory) {

        unchecked {

            return toHexString(value, Math.log256(value) + 1);

        }

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

     */

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);

        buffer[0] = "0";

        buffer[1] = "x";

        for (uint256 i = 2 * length + 1; i > 1; --i) {

            buffer[i] = _SYMBOLS[value & 0xf];

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





// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)











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

 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including

 * the Metadata extension. Built to optimize for lower gas during batch mints.

 *

 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).

 *

 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.

 *

 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).

 */

contract ERC721A is Context, ERC165, IERC721A {

    using Address for address;

    using Strings for uint256;



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

    function totalSupply() public view override returns (uint256) {

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

            if (_startTokenId() <= curr) if (curr < _currentIndex) {

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

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);

        if (to == owner) revert ApprovalToCurrentOwner();



        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {

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

        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {

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



    /**

     * @dev Equivalent to `_safeMint(to, quantity, '')`.

     */

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');

    }



    /**

     * @dev Safely mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - If `to` refers to a smart contract, it must implement

     *   {IERC721Receiver-onERC721Received}, which is called for each safe transfer.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _safeMint(

        address to,

        uint256 quantity,

        bytes memory _data

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



            if (to.isContract()) {

                do {

                    emit Transfer(address(0), to, updatedIndex);

                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {

                        revert TransferToNonERC721ReceiverImplementer();

                    }

                } while (updatedIndex < end);

                // Reentrancy protection

                if (_currentIndex != startTokenId) revert();

            } else {

                do {

                    emit Transfer(address(0), to, updatedIndex++);

                } while (updatedIndex < end);

            }

            _currentIndex = updatedIndex;

        }

        _afterTokenTransfers(address(0), to, startTokenId, quantity);

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

    function _mint(address to, uint256 quantity) internal {

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



            do {

                emit Transfer(address(0), to, updatedIndex++);

            } while (updatedIndex < end);



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

     * @dev Equivalent to `_burn(tokenId, false)`.

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



// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)









// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)











/**

 * @dev Interface for the NFT Royalty Standard.

 *

 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal

 * support for royalty payments across all NFT marketplaces and ecosystem participants.

 *

 * _Available since v4.5._

 */

interface IERC2981 is IERC165 {

    /**

     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of

     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.

     */

    function royaltyInfo(uint256 tokenId, uint256 salePrice)

        external

        view

        returns (address receiver, uint256 royaltyAmount);

}







/**

 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.

 *

 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for

 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.

 *

 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the

 * fee is specified in basis points by default.

 *

 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See

 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to

 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.

 *

 * _Available since v4.5._

 */

abstract contract ERC2981 is IERC2981, ERC165 {

    struct RoyaltyInfo {

        address receiver;

        uint96 royaltyFraction;

    }



    RoyaltyInfo private _defaultRoyaltyInfo;

    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {

        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @inheritdoc IERC2981

     */

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {

        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];



        if (royalty.receiver == address(0)) {

            royalty = _defaultRoyaltyInfo;

        }



        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();



        return (royalty.receiver, royaltyAmount);

    }



    /**

     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a

     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an

     * override.

     */

    function _feeDenominator() internal pure virtual returns (uint96) {

        return 10000;

    }



    /**

     * @dev Sets the royalty information that all ids in this contract will default to.

     *

     * Requirements:

     *

     * - `receiver` cannot be the zero address.

     * - `feeNumerator` cannot be greater than the fee denominator.

     */

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {

        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");

        require(receiver != address(0), "ERC2981: invalid receiver");



        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);

    }



    /**

     * @dev Removes default royalty information.

     */

    function _deleteDefaultRoyalty() internal virtual {

        delete _defaultRoyaltyInfo;

    }



    /**

     * @dev Sets the royalty information for a specific token id, overriding the global default.

     *

     * Requirements:

     *

     * - `receiver` cannot be the zero address.

     * - `feeNumerator` cannot be greater than the fee denominator.

     */

    function _setTokenRoyalty(

        uint256 tokenId,

        address receiver,

        uint96 feeNumerator

    ) internal virtual {

        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");

        require(receiver != address(0), "ERC2981: Invalid parameters");



        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);

    }



    /**

     * @dev Resets royalty information for the token id back to the global default.

     */

    function _resetTokenRoyalty(uint256 tokenId) internal virtual {

        delete _tokenRoyaltyInfo[tokenId];

    }

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







// OpenZeppelin Contracts (last updated v4.8.0) (finance/PaymentSplitter.sol)









// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)









// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)







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





// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)







/**

 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in

 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].

 *

 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by

 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't

 * need to send a transaction, and thus is not required to hold Ether at all.

 */

interface IERC20Permit {

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



    function safePermit(

        IERC20Permit token,

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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

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

contract PaymentSplitter is Context {

    event PayeeAdded(address account, uint256 shares);

    event PaymentReleased(address to, uint256 amount);

    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);

    event PaymentReceived(address from, uint256 amount);



    uint256 private _totalShares;

    uint256 private _totalReleased;



    mapping(address => uint256) private _shares;

    mapping(address => uint256) private _released;

    address[] private _payees;



    mapping(IERC20 => uint256) private _erc20TotalReleased;

    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;



    /**

     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at

     * the matching position in the `shares` array.

     *

     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no

     * duplicates in `payees`.

     */

    constructor(address[] memory payees, uint256[] memory shares_) payable {

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

    function totalReleased(IERC20 token) public view returns (uint256) {

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

    function released(IERC20 token, address account) public view returns (uint256) {

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

    function releasable(IERC20 token, address account) public view returns (uint256) {

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



        Address.sendValue(account, payment);

        emit PaymentReleased(account, payment);

    }



    /**

     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their

     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20

     * contract.

     */

    function release(IERC20 token, address account) public virtual {

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



        SafeERC20.safeTransfer(token, account, payment);

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

}





// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)







/**

 * @dev These functions deal with verification of Merkle Tree proofs.

 *

 * The tree and the proofs can be generated using our

 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].

 * You will find a quickstart guide in the readme.

 *

 * WARNING: You should avoid using leaf values that are 64 bytes long prior to

 * hashing, or use a hash function other than keccak256 for hashing leaves.

 * This is because the concatenation of a sorted pair of internal nodes in

 * the merkle tree could be reinterpreted as a leaf value.

 * OpenZeppelin's JavaScript library generates merkle trees that are safe

 * against this attack out of the box.

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

     * @dev Calldata version of {verify}

     *

     * _Available since v4.7._

     */

    function verifyCalldata(

        bytes32[] calldata proof,

        bytes32 root,

        bytes32 leaf

    ) internal pure returns (bool) {

        return processProofCalldata(proof, leaf) == root;

    }



    /**

     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up

     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt

     * hash matches the root of the tree. When processing the proof, the pairs

     * of leafs & pre-images are assumed to be sorted.

     *

     * _Available since v4.4._

     */

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Calldata version of {processProof}

     *

     * _Available since v4.7._

     */

    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by

     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function multiProofVerify(

        bytes32[] memory proof,

        bool[] memory proofFlags,

        bytes32 root,

        bytes32[] memory leaves

    ) internal pure returns (bool) {

        return processMultiProof(proof, proofFlags, leaves) == root;

    }



    /**

     * @dev Calldata version of {multiProofVerify}

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function multiProofVerifyCalldata(

        bytes32[] calldata proof,

        bool[] calldata proofFlags,

        bytes32 root,

        bytes32[] memory leaves

    ) internal pure returns (bool) {

        return processMultiProofCalldata(proof, proofFlags, leaves) == root;

    }



    /**

     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction

     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another

     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false

     * respectively.

     *

     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree

     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the

     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).

     *

     * _Available since v4.7._

     */

    function processMultiProof(

        bytes32[] memory proof,

        bool[] memory proofFlags,

        bytes32[] memory leaves

    ) internal pure returns (bytes32 merkleRoot) {

        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            return hashes[totalHashes - 1];

        } else if (leavesLen > 0) {

            return leaves[0];

        } else {

            return proof[0];

        }

    }



    /**

     * @dev Calldata version of {processMultiProof}.

     *

     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.

     *

     * _Available since v4.7._

     */

    function processMultiProofCalldata(

        bytes32[] calldata proof,

        bool[] calldata proofFlags,

        bytes32[] memory leaves

    ) internal pure returns (bytes32 merkleRoot) {

        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            return hashes[totalHashes - 1];

        } else if (leavesLen > 0) {

            return leaves[0];

        } else {

            return proof[0];

        }

    }



    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {

        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);

    }



    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        /// @solidity memory-safe-assembly

        assembly {

            mstore(0x00, a)

            mstore(0x20, b)

            value := keccak256(0x00, 0x40)

        }

    }

}





contract Seelies is Ownable, ERC721A, ERC2981, PaymentSplitter {

    using Strings for uint256;



    /*//////////////////////////////////////////////////////////////

                                CONSTANTS

    //////////////////////////////////////////////////////////////*/



    uint256 public constant maxSupplyCap = 3888;



    uint256 public constant publicSupplyCap = 3700;

    uint256 public constant maxTokensPerTx = 3;

    uint256 public constant price = 0.019 ether;



    uint256 public constant whitelistSupplyCap = 3000;

    uint256 public constant maxWhitelistTokensPerAddr = 3;

    uint256 public constant whitelistPrice = 0.014 ether;



    /*//////////////////////////////////////////////////////////////

                                VARIABLES

    //////////////////////////////////////////////////////////////*/



    uint32 public whitelistSaleStart;

    uint32 public publicSaleStart;

    uint32 public enchantedClaimStart;

    uint32 public enchantedClaimEnd;



    bytes32 public merkleRoot;



    bool public revealed;



    string private _baseTokenURI;

    string private notRevealedUri;



    mapping(address => bool) public enchantedClaimed;



    /*//////////////////////////////////////////////////////////////

                                 ERRORS

    //////////////////////////////////////////////////////////////*/



    error SaleNotStarted();

    error ClaimClosed();

    error InvalidProof();

    error QuantityOffLimits();

    error MaxSupplyReached();

    error InsufficientFunds();

    error AlreadyClaimed();

    error InvalidInput();

    error NonExistentTokenURI();



    /*//////////////////////////////////////////////////////////////

                               CONSTRUCTOR

    //////////////////////////////////////////////////////////////*/



    constructor(

        string memory _initNotRevealedUri,

        address[] memory payees_,

        uint256[] memory shares_

    ) ERC721A("Seelies", "SEELIES") PaymentSplitter(payees_, shares_) {

        notRevealedUri = _initNotRevealedUri;

        _mint(msg.sender, 1);

    }



    /*//////////////////////////////////////////////////////////////

                            MINTING LOGIC

    //////////////////////////////////////////////////////////////*/



    function whitelistMint(uint256 quantity, bytes32[] memory proof)

        external

        payable

    {

        // If minting has not started, revert.

        if (block.timestamp < whitelistSaleStart) revert SaleNotStarted();



        // If provided proof is invalid, revert.

        if (

            !(

                MerkleProof.verify(

                    proof,

                    merkleRoot,

                    keccak256(abi.encodePacked(msg.sender))

                )

            )

        ) revert InvalidProof();



        // If supply cap is reached, revert.

        if (_totalMinted() + quantity > whitelistSupplyCap)

            revert MaxSupplyReached();



        // If provided value doesn't match with the price, revert.

        if (msg.value != whitelistPrice * quantity) revert InsufficientFunds();



        // If provided quantity is outside of predefined limits, revert.

        if (quantity == 0 || quantity > maxTokensPerTx)

            revert QuantityOffLimits();



        // If the user has already claimed their tokens, revert.

        uint64 _mintSlotsUsed = _getAux(msg.sender) + uint64(quantity);

        if (_mintSlotsUsed > maxWhitelistTokensPerAddr) revert AlreadyClaimed();



        _setAux(msg.sender, _mintSlotsUsed);



        _mint(msg.sender, quantity);

    }



    function publicMint(uint256 quantity) external payable {

        // If public minting has not started by reaching timestamp or minting out the whitelist supply, revert.

        if (

            _totalMinted() < whitelistSupplyCap &&

            block.timestamp < publicSaleStart

        ) {

            revert SaleNotStarted();

        }



        // If provided value doesn't match with the price, revert.

        if (msg.value != price * quantity) revert InsufficientFunds();



        // If provided quantity is outside of predefined limits, revert.

        if (quantity == 0 || quantity > maxTokensPerTx)

            revert QuantityOffLimits();



        // If enchanted claim is not ended, cap the supply to public max. If yes, free the rest of the supply for public.

        if (block.timestamp < enchantedClaimEnd) {

            if (_totalMinted() + quantity > publicSupplyCap)

                revert MaxSupplyReached();

        } else {

            if (_totalMinted() + quantity > maxSupplyCap)

                revert MaxSupplyReached();

        }



        _mint(msg.sender, quantity);

    }



    function enchantedClaim(bytes32[] memory proof) external payable {

        // If claiming has not started, revert.

        if (

            block.timestamp < enchantedClaimStart ||

            block.timestamp > enchantedClaimEnd

        ) revert ClaimClosed();



        // If provided proof is invalid, revert.

        if (

            !(

                MerkleProof.verify(

                    proof,

                    merkleRoot,

                    keccak256(abi.encodePacked(msg.sender))

                )

            )

        ) revert InvalidProof();



        // If supply cap is reached, revert.

        if (_totalMinted() + 1 > maxSupplyCap) revert MaxSupplyReached();



        // If the user has already claimed their tokens, revert.

        if (enchantedClaimed[msg.sender]) revert AlreadyClaimed();



        enchantedClaimed[msg.sender] = true;



        _mint(msg.sender, 1);

    }



    /*//////////////////////////////////////////////////////////////

                            FRONTEND HELPERS

    //////////////////////////////////////////////////////////////*/



    function isWhitelistOpen() public view returns (bool) {

        return block.timestamp < whitelistSaleStart ? false : true;

    }



    function isPublicOpen() public view returns (bool) {

        return block.timestamp < publicSaleStart ? false : true;

    }



    function isEnchantedStarted() public view returns (bool) {

        return block.timestamp < enchantedClaimStart ? false : true;

    }



    function isEnchantedOver() public view returns (bool) {

        return block.timestamp < enchantedClaimEnd ? false : true;

    }



    function earlyClaimed(address user) public view returns (uint256) {

        return _getAux(user);

    }



    function mintedByAddr(address addr) external view returns (uint256) {

        return _numberMinted(addr);

    }



    function totalMinted() external view virtual returns (uint256) {

        return _totalMinted();

    }



    /*//////////////////////////////////////////////////////////////

                                ADMIN

    //////////////////////////////////////////////////////////////*/



    function rewardCollaborators(

        address[] calldata receivers,

        uint256[] calldata amounts

    ) external onlyOwner {

        // If there is a mismatch between receivers and amounts lengths, revert.

        if (receivers.length != amounts.length || receivers.length == 0)

            revert InvalidInput();



        for (uint256 i; i < receivers.length; ) {

            // If the supply cap is reached, revert.

            if (_totalMinted() + amounts[i] > maxSupplyCap)

                revert MaxSupplyReached();



            _mint(receivers[i], amounts[i]);



            unchecked {

                ++i;

            }

        }

    }



    function setSaleTimes(

        uint32 _whitelistSaleStart,

        uint32 _publicSaleStart,

        uint32 _enchantedClaimStart,

        uint32 _enchantedClaimEnd

    ) external onlyOwner {

        whitelistSaleStart = _whitelistSaleStart;

        publicSaleStart = _publicSaleStart;

        enchantedClaimStart = _enchantedClaimStart;

        enchantedClaimEnd = _enchantedClaimEnd;

    }



    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {

        notRevealedUri = _notRevealedURI;

    }



    function setBaseURI(string calldata baseURI) external onlyOwner {

        _baseTokenURI = baseURI;

    }



    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {

        merkleRoot = _merkleRoot;

    }



    function reveal() external onlyOwner {

        revealed = true;

    }



    function setDefaultRoyalty(address receiver, uint96 feeNumerator)

        external

        onlyOwner

    {

        _setDefaultRoyalty(receiver, feeNumerator);

    }



    function deleteDefaultRoyalty() external onlyOwner {

        _deleteDefaultRoyalty();

    }



    /*//////////////////////////////////////////////////////////////

                                OVERRIDES

    //////////////////////////////////////////////////////////////*/



    function _baseURI() internal view virtual override returns (string memory) {

        return _baseTokenURI;

    }



    function _startTokenId() internal view virtual override returns (uint256) {

        return 1;

    }



    function tokenURI(uint256 tokenId)

        public

        view

        virtual

        override

        returns (string memory)

    {

        if (!_exists(tokenId)) revert NonExistentTokenURI();

        if (revealed == false) {

            return notRevealedUri;

        }

        string memory baseURI = _baseURI();

        return

            bytes(baseURI).length > 0

                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))

                : "";

    }



    function supportsInterface(bytes4 interfaceId)

        public

        view

        virtual

        override(ERC721A, ERC2981)

        returns (bool)

    {

        return

            ERC721A.supportsInterface(interfaceId) ||

            ERC2981.supportsInterface(interfaceId);

    }

}