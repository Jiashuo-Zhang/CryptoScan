/**

 *Submitted for verification at Etherscan.io on 2023-04-01

*/



// Dependency file: @openzeppelin/contracts/utils/introspection/IERC165.sol



// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)



// pragma solidity ^0.8.0;



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





// Dependency file: @openzeppelin/contracts/token/ERC721/IERC721.sol



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/introspection/IERC165.sol";



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





// Dependency file: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol



// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)



// pragma solidity ^0.8.0;



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





// Dependency file: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol



// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



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





// Dependency file: @openzeppelin/contracts/utils/Address.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)



// pragma solidity ^0.8.1;



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





// Dependency file: @openzeppelin/contracts/utils/Context.sol



// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



// pragma solidity ^0.8.0;



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





// Dependency file: @openzeppelin/contracts/utils/math/Math.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)



// pragma solidity ^0.8.0;



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





// Dependency file: @openzeppelin/contracts/utils/Strings.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/math/Math.sol";



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





// Dependency file: @openzeppelin/contracts/utils/introspection/ERC165.sol



// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/introspection/IERC165.sol";



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





// Dependency file: @openzeppelin/contracts/token/ERC721/ERC721.sol



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

// import "@openzeppelin/contracts/utils/Address.sol";

// import "@openzeppelin/contracts/utils/Context.sol";

// import "@openzeppelin/contracts/utils/Strings.sol";

// import "@openzeppelin/contracts/utils/introspection/ERC165.sol";



/**

 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including

 * the Metadata extension, but not including the Enumerable extension, which is available separately as

 * {ERC721Enumerable}.

 */

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;

    using Strings for uint256;



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Mapping from token ID to owner address

    mapping(uint256 => address) private _owners;



    // Mapping owner address to token count

    mapping(address => uint256) private _balances;



    // Mapping from token ID to approved address

    mapping(uint256 => address) private _tokenApprovals;



    // Mapping from owner to operator approvals

    mapping(address => mapping(address => bool)) private _operatorApprovals;



    /**

     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.

     */

    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

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

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: address zero is not a valid owner");

        return _balances[owner];

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _ownerOf(tokenId);

        require(owner != address(0), "ERC721: invalid token ID");

        return owner;

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

        _requireMinted(tokenId);



        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";

    }



    /**

     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each

     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty

     * by default, can be overridden in child contracts.

     */

    function _baseURI() internal view virtual returns (string memory) {

        return "";

    }



    /**

     * @dev See {IERC721-approve}.

     */

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);

        require(to != owner, "ERC721: approval to current owner");



        require(

            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),

            "ERC721: approve caller is not token owner or approved for all"

        );



        _approve(to, tokenId);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        _requireMinted(tokenId);



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);

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

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");



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

        safeTransferFrom(from, to, tokenId, "");

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _safeTransfer(from, to, tokenId, data);

    }



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * `data` is additional data, it has no specified format and it is sent in call to `to`.

     *

     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.

     * implement alternative mechanisms to perform token transfer, such as signature-based.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function _safeTransfer(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) internal virtual {

        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");

    }



    /**

     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist

     */

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {

        return _owners[tokenId];

    }



    /**

     * @dev Returns whether `tokenId` exists.

     *

     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

     *

     * Tokens start existing when they are minted (`_mint`),

     * and stop existing when they are burned (`_burn`).

     */

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _ownerOf(tokenId) != address(0);

    }



    /**

     * @dev Returns whether `spender` is allowed to manage `tokenId`.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        address owner = ERC721.ownerOf(tokenId);

        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);

    }



    /**

     * @dev Safely mints `tokenId` and transfers it to `to`.

     *

     * Requirements:

     *

     * - `tokenId` must not exist.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");

    }



    /**

     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is

     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.

     */

    function _safeMint(

        address to,

        uint256 tokenId,

        bytes memory data

    ) internal virtual {

        _mint(to, tokenId);

        require(

            _checkOnERC721Received(address(0), to, tokenId, data),

            "ERC721: transfer to non ERC721Receiver implementer"

        );

    }



    /**

     * @dev Mints `tokenId` and transfers it to `to`.

     *

     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible

     *

     * Requirements:

     *

     * - `tokenId` must not exist.

     * - `to` cannot be the zero address.

     *

     * Emits a {Transfer} event.

     */

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");

        require(!_exists(tokenId), "ERC721: token already minted");



        _beforeTokenTransfer(address(0), to, tokenId, 1);



        // Check that tokenId was not minted by `_beforeTokenTransfer` hook

        require(!_exists(tokenId), "ERC721: token already minted");



        unchecked {

            // Will not overflow unless all 2**256 token ids are minted to the same owner.

            // Given that tokens are minted one by one, it is impossible in practice that

            // this ever happens. Might change if we allow batch minting.

            // The ERC fails to describe this case.

            _balances[to] += 1;

        }



        _owners[tokenId] = to;



        emit Transfer(address(0), to, tokenId);



        _afterTokenTransfer(address(0), to, tokenId, 1);

    }



    /**

     * @dev Destroys `tokenId`.

     * The approval is cleared when the token is burned.

     * This is an internal function that does not check if the sender is authorized to operate on the token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     *

     * Emits a {Transfer} event.

     */

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);



        _beforeTokenTransfer(owner, address(0), tokenId, 1);



        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook

        owner = ERC721.ownerOf(tokenId);



        // Clear approvals

        delete _tokenApprovals[tokenId];



        unchecked {

            // Cannot overflow, as that would require more tokens to be burned/transferred

            // out than the owner initially received through minting and transferring in.

            _balances[owner] -= 1;

        }

        delete _owners[tokenId];



        emit Transfer(owner, address(0), tokenId);



        _afterTokenTransfer(owner, address(0), tokenId, 1);

    }



    /**

     * @dev Transfers `tokenId` from `from` to `to`.

     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.

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

    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        require(to != address(0), "ERC721: transfer to the zero address");



        _beforeTokenTransfer(from, to, tokenId, 1);



        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");



        // Clear approvals from the previous owner

        delete _tokenApprovals[tokenId];



        unchecked {

            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:

            // `from`'s balance is the number of token held, which is at least one before the current

            // transfer.

            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require

            // all 2**256 token ids to be minted, which in practice is impossible.

            _balances[from] -= 1;

            _balances[to] += 1;

        }

        _owners[tokenId] = to;



        emit Transfer(from, to, tokenId);



        _afterTokenTransfer(from, to, tokenId, 1);

    }



    /**

     * @dev Approve `to` to operate on `tokenId`

     *

     * Emits an {Approval} event.

     */

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;

        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);

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

        require(owner != operator, "ERC721: approve to caller");

        _operatorApprovals[owner][operator] = approved;

        emit ApprovalForAll(owner, operator, approved);

    }



    /**

     * @dev Reverts if the `tokenId` has not been minted yet.

     */

    function _requireMinted(uint256 tokenId) internal view virtual {

        require(_exists(tokenId), "ERC721: invalid token ID");

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.

     * The call is not executed if the target address is not a contract.

     *

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) private returns (bool) {

        if (to.isContract()) {

            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {

                return retval == IERC721Receiver.onERC721Received.selector;

            } catch (bytes memory reason) {

                if (reason.length == 0) {

                    revert("ERC721: transfer to non ERC721Receiver implementer");

                } else {

                    /// @solidity memory-safe-assembly

                    assembly {

                        revert(add(32, reason), mload(reason))

                    }

                }

            }

        } else {

            return true;

        }

    }



    /**

     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is

     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.

     * - When `from` is zero, the tokens will be minted for `to`.

     * - When `to` is zero, ``from``'s tokens will be burned.

     * - `from` and `to` are never both zero.

     * - `batchSize` is non-zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256, /* firstTokenId */

        uint256 batchSize

    ) internal virtual {

        if (batchSize > 1) {

            if (from != address(0)) {

                _balances[from] -= batchSize;

            }

            if (to != address(0)) {

                _balances[to] += batchSize;

            }

        }

    }



    /**

     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is

     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.

     * - When `from` is zero, the tokens were minted for `to`.

     * - When `to` is zero, ``from``'s tokens were burned.

     * - `from` and `to` are never both zero.

     * - `batchSize` is non-zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _afterTokenTransfer(

        address from,

        address to,

        uint256 firstTokenId,

        uint256 batchSize

    ) internal virtual {}

}





// Dependency file: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol



// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



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





// Dependency file: @openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";



/**

 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds

 * enumerability of all the token ids in the contract as well as all token ids owned by each

 * account.

 */

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {

    // Mapping from owner to list of owned token IDs

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;



    // Mapping from token ID to index of the owner tokens list

    mapping(uint256 => uint256) private _ownedTokensIndex;



    // Array with all token ids, used for enumeration

    uint256[] private _allTokens;



    // Mapping from token id to position in the allTokens array

    mapping(uint256 => uint256) private _allTokensIndex;



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {

        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.

     */

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");

        return _ownedTokens[owner][index];

    }



    /**

     * @dev See {IERC721Enumerable-totalSupply}.

     */

    function totalSupply() public view virtual override returns (uint256) {

        return _allTokens.length;

    }



    /**

     * @dev See {IERC721Enumerable-tokenByIndex}.

     */

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");

        return _allTokens[index];

    }



    /**

     * @dev See {ERC721-_beforeTokenTransfer}.

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 firstTokenId,

        uint256 batchSize

    ) internal virtual override {

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);



        if (batchSize > 1) {

            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.

            revert("ERC721Enumerable: consecutive transfers not supported");

        }



        uint256 tokenId = firstTokenId;



        if (from == address(0)) {

            _addTokenToAllTokensEnumeration(tokenId);

        } else if (from != to) {

            _removeTokenFromOwnerEnumeration(from, tokenId);

        }

        if (to == address(0)) {

            _removeTokenFromAllTokensEnumeration(tokenId);

        } else if (to != from) {

            _addTokenToOwnerEnumeration(to, tokenId);

        }

    }



    /**

     * @dev Private function to add a token to this extension's ownership-tracking data structures.

     * @param to address representing the new owner of the given token ID

     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

     */

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        uint256 length = ERC721.balanceOf(to);

        _ownedTokens[to][length] = tokenId;

        _ownedTokensIndex[tokenId] = length;

    }



    /**

     * @dev Private function to add a token to this extension's token tracking data structures.

     * @param tokenId uint256 ID of the token to be added to the tokens list

     */

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;

        _allTokens.push(tokenId);

    }



    /**

     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that

     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for

     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).

     * This has O(1) time complexity, but alters the order of the _ownedTokens array.

     * @param from address representing the previous owner of the given token ID

     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address

     */

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and

        // then delete the last slot (swap and pop).



        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;

        uint256 tokenIndex = _ownedTokensIndex[tokenId];



        // When the token to delete is the last token, the swap operation is unnecessary

        if (tokenIndex != lastTokenIndex) {

            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];



            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        }



        // This also deletes the contents at the last position of the array

        delete _ownedTokensIndex[tokenId];

        delete _ownedTokens[from][lastTokenIndex];

    }



    /**

     * @dev Private function to remove a token from this extension's token tracking data structures.

     * This has O(1) time complexity, but alters the order of the _allTokens array.

     * @param tokenId uint256 ID of the token to be removed from the tokens list

     */

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and

        // then delete the last slot (swap and pop).



        uint256 lastTokenIndex = _allTokens.length - 1;

        uint256 tokenIndex = _allTokensIndex[tokenId];



        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so

        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding

        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)

        uint256 lastTokenId = _allTokens[lastTokenIndex];



        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index



        // This also deletes the contents at the last position of the array

        delete _allTokensIndex[tokenId];

        _allTokens.pop();

    }

}





// Dependency file: @openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Burnable.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/utils/Context.sol";



/**

 * @title ERC721 Burnable Token

 * @dev ERC721 Token that can be burned (destroyed).

 */

abstract contract ERC721Burnable is Context, ERC721 {

    /**

     * @dev Burns `tokenId`. See {ERC721-_burn}.

     *

     * Requirements:

     *

     * - The caller must own `tokenId` or be an approved operator.

     */

    function burn(uint256 tokenId) public virtual {

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _burn(tokenId);

    }

}





// Dependency file: @openzeppelin/contracts/interfaces/IERC2981.sol



// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/introspection/IERC165.sol";



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





// Dependency file: @openzeppelin/contracts/token/common/ERC2981.sol



// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/interfaces/IERC2981.sol";

// import "@openzeppelin/contracts/utils/introspection/ERC165.sol";



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





// Dependency file: operator-filter-registry/src/IOperatorFilterRegistry.sol



// pragma solidity ^0.8.13;



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





// Dependency file: operator-filter-registry/src/lib/Constants.sol



// pragma solidity ^0.8.17;



address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;

address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;





// Dependency file: operator-filter-registry/src/OperatorFilterer.sol



// pragma solidity ^0.8.13;



// import {IOperatorFilterRegistry} from "operator-filter-registry/src/IOperatorFilterRegistry.sol";

// import {CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS} from "operator-filter-registry/src/lib/Constants.sol";

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





// Dependency file: operator-filter-registry/src/DefaultOperatorFilterer.sol



// pragma solidity ^0.8.13;



// import {OperatorFilterer} from "operator-filter-registry/src/OperatorFilterer.sol";

// import {CANONICAL_CORI_SUBSCRIPTION} from "operator-filter-registry/src/lib/Constants.sol";

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





// Dependency file: @openzeppelin/contracts/utils/cryptography/ECDSA.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/Strings.sol";



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





// Dependency file: @openzeppelin/contracts/utils/cryptography/EIP712.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



/**

 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.

 *

 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,

 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding

 * they need in their contracts using a combination of `abi.encode` and `keccak256`.

 *

 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding

 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA

 * ({_hashTypedDataV4}).

 *

 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating

 * the chain id to protect against replay attacks on an eventual fork of the chain.

 *

 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method

 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].

 *

 * _Available since v3.4._

 */

abstract contract EIP712 {

    /* solhint-disable var-name-mixedcase */

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to

    // invalidate the cached domain separator if the chain id changes.

    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;

    uint256 private immutable _CACHED_CHAIN_ID;

    address private immutable _CACHED_THIS;



    bytes32 private immutable _HASHED_NAME;

    bytes32 private immutable _HASHED_VERSION;

    bytes32 private immutable _TYPE_HASH;



    /* solhint-enable var-name-mixedcase */



    /**

     * @dev Initializes the domain separator and parameter caches.

     *

     * The meaning of `name` and `version` is specified in

     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:

     *

     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.

     * - `version`: the current major version of the signing domain.

     *

     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart

     * contract upgrade].

     */

    constructor(string memory name, string memory version) {

        bytes32 hashedName = keccak256(bytes(name));

        bytes32 hashedVersion = keccak256(bytes(version));

        bytes32 typeHash = keccak256(

            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"

        );

        _HASHED_NAME = hashedName;

        _HASHED_VERSION = hashedVersion;

        _CACHED_CHAIN_ID = block.chainid;

        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);

        _CACHED_THIS = address(this);

        _TYPE_HASH = typeHash;

    }



    /**

     * @dev Returns the domain separator for the current chain.

     */

    function _domainSeparatorV4() internal view returns (bytes32) {

        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {

            return _CACHED_DOMAIN_SEPARATOR;

        } else {

            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);

        }

    }



    function _buildDomainSeparator(

        bytes32 typeHash,

        bytes32 nameHash,

        bytes32 versionHash

    ) private view returns (bytes32) {

        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));

    }



    /**

     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this

     * function returns the hash of the fully encoded EIP712 message for this domain.

     *

     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:

     *

     * ```solidity

     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(

     *     keccak256("Mail(address to,string contents)"),

     *     mailTo,

     *     keccak256(bytes(mailContents))

     * )));

     * address signer = ECDSA.recover(digest, signature);

     * ```

     */

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {

        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);

    }

}





// Dependency file: @openzeppelin/contracts/utils/cryptography/draft-EIP712.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)



// pragma solidity ^0.8.0;



// EIP-712 is Final as of 2022-08-11. This file is deprecated.



// import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";





// Dependency file: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)



// pragma solidity ^0.8.0;



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





// Dependency file: @openzeppelin/contracts/utils/Counters.sol



// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)



// pragma solidity ^0.8.0;



/**

 * @title Counters

 * @author Matt Condon (@shrugs)

 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number

 * of elements in a mapping, issuing ERC721 ids, or counting request ids.

 *

 * Include with `using Counters for Counters.Counter;`

 */

library Counters {

    struct Counter {

        // This variable should never be directly accessed by users of the library: interactions must be restricted to

        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add

        // this feature: see https://github.com/ethereum/solidity/issues/4637

        uint256 _value; // default: 0

    }



    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;

    }



    function increment(Counter storage counter) internal {

        unchecked {

            counter._value += 1;

        }

    }



    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;

        require(value > 0, "Counter: decrement overflow");

        unchecked {

            counter._value = value - 1;

        }

    }



    function reset(Counter storage counter) internal {

        counter._value = 0;

    }

}





// Dependency file: @openzeppelin/contracts/utils/math/SafeCast.sol



// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)

// This file was procedurally generated from scripts/generate/templates/SafeCast.js.



// pragma solidity ^0.8.0;



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

    function toInt248(int256 value) internal pure returns (int248 downcasted) {

        downcasted = int248(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");

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

    function toInt240(int256 value) internal pure returns (int240 downcasted) {

        downcasted = int240(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");

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

    function toInt232(int256 value) internal pure returns (int232 downcasted) {

        downcasted = int232(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");

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

    function toInt224(int256 value) internal pure returns (int224 downcasted) {

        downcasted = int224(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");

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

    function toInt216(int256 value) internal pure returns (int216 downcasted) {

        downcasted = int216(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");

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

    function toInt208(int256 value) internal pure returns (int208 downcasted) {

        downcasted = int208(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");

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

    function toInt200(int256 value) internal pure returns (int200 downcasted) {

        downcasted = int200(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");

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

    function toInt192(int256 value) internal pure returns (int192 downcasted) {

        downcasted = int192(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");

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

    function toInt184(int256 value) internal pure returns (int184 downcasted) {

        downcasted = int184(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");

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

    function toInt176(int256 value) internal pure returns (int176 downcasted) {

        downcasted = int176(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");

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

    function toInt168(int256 value) internal pure returns (int168 downcasted) {

        downcasted = int168(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");

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

    function toInt160(int256 value) internal pure returns (int160 downcasted) {

        downcasted = int160(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");

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

    function toInt152(int256 value) internal pure returns (int152 downcasted) {

        downcasted = int152(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");

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

    function toInt144(int256 value) internal pure returns (int144 downcasted) {

        downcasted = int144(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");

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

    function toInt136(int256 value) internal pure returns (int136 downcasted) {

        downcasted = int136(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");

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

    function toInt128(int256 value) internal pure returns (int128 downcasted) {

        downcasted = int128(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");

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

    function toInt120(int256 value) internal pure returns (int120 downcasted) {

        downcasted = int120(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");

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

    function toInt112(int256 value) internal pure returns (int112 downcasted) {

        downcasted = int112(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");

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

    function toInt104(int256 value) internal pure returns (int104 downcasted) {

        downcasted = int104(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");

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

    function toInt96(int256 value) internal pure returns (int96 downcasted) {

        downcasted = int96(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");

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

    function toInt88(int256 value) internal pure returns (int88 downcasted) {

        downcasted = int88(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");

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

    function toInt80(int256 value) internal pure returns (int80 downcasted) {

        downcasted = int80(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");

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

    function toInt72(int256 value) internal pure returns (int72 downcasted) {

        downcasted = int72(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");

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

    function toInt64(int256 value) internal pure returns (int64 downcasted) {

        downcasted = int64(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");

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

    function toInt56(int256 value) internal pure returns (int56 downcasted) {

        downcasted = int56(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");

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

    function toInt48(int256 value) internal pure returns (int48 downcasted) {

        downcasted = int48(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");

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

    function toInt40(int256 value) internal pure returns (int40 downcasted) {

        downcasted = int40(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");

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

    function toInt32(int256 value) internal pure returns (int32 downcasted) {

        downcasted = int32(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");

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

    function toInt24(int256 value) internal pure returns (int24 downcasted) {

        downcasted = int24(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");

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

    function toInt16(int256 value) internal pure returns (int16 downcasted) {

        downcasted = int16(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");

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

    function toInt8(int256 value) internal pure returns (int8 downcasted) {

        downcasted = int8(value);

        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");

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





// Dependency file: @openzeppelin/contracts/utils/Checkpoints.sol



// OpenZeppelin Contracts (last updated v4.8.1) (utils/Checkpoints.sol)

// This file was procedurally generated from scripts/generate/templates/Checkpoints.js.



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/math/Math.sol";

// import "@openzeppelin/contracts/utils/math/SafeCast.sol";



/**

 * @dev This library defines the `History` struct, for checkpointing values as they change at different points in

 * time, and later looking up past values by block number. See {Votes} as an example.

 *

 * To create a history of checkpoints define a variable type `Checkpoints.History` in your contract, and store a new

 * checkpoint for the current transaction block using the {push} function.

 *

 * _Available since v4.5._

 */

library Checkpoints {

    struct History {

        Checkpoint[] _checkpoints;

    }



    struct Checkpoint {

        uint32 _blockNumber;

        uint224 _value;

    }



    /**

     * @dev Returns the value at a given block number. If a checkpoint is not available at that block, the closest one

     * before it is returned, or zero otherwise. Because the number returned corresponds to that at the end of the

     * block, the requested block number must be in the past, excluding the current block.

     */

    function getAtBlock(History storage self, uint256 blockNumber) internal view returns (uint256) {

        require(blockNumber < block.number, "Checkpoints: block not yet mined");

        uint32 key = SafeCast.toUint32(blockNumber);



        uint256 len = self._checkpoints.length;

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Returns the value at a given block number. If a checkpoint is not available at that block, the closest one

     * before it is returned, or zero otherwise. Similar to {upperLookup} but optimized for the case when the searched

     * checkpoint is probably "recent", defined as being among the last sqrt(N) checkpoints where N is the number of

     * checkpoints.

     */

    function getAtProbablyRecentBlock(History storage self, uint256 blockNumber) internal view returns (uint256) {

        require(blockNumber < block.number, "Checkpoints: block not yet mined");

        uint32 key = SafeCast.toUint32(blockNumber);



        uint256 len = self._checkpoints.length;



        uint256 low = 0;

        uint256 high = len;



        if (len > 5) {

            uint256 mid = len - Math.sqrt(len);

            if (key < _unsafeAccess(self._checkpoints, mid)._blockNumber) {

                high = mid;

            } else {

                low = mid + 1;

            }

        }



        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);



        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Pushes a value onto a History so that it is stored as the checkpoint for the current block.

     *

     * Returns previous value and new value.

     */

    function push(History storage self, uint256 value) internal returns (uint256, uint256) {

        return _insert(self._checkpoints, SafeCast.toUint32(block.number), SafeCast.toUint224(value));

    }



    /**

     * @dev Pushes a value onto a History, by updating the latest value using binary operation `op`. The new value will

     * be set to `op(latest, delta)`.

     *

     * Returns previous value and new value.

     */

    function push(

        History storage self,

        function(uint256, uint256) view returns (uint256) op,

        uint256 delta

    ) internal returns (uint256, uint256) {

        return push(self, op(latest(self), delta));

    }



    /**

     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.

     */

    function latest(History storage self) internal view returns (uint224) {

        uint256 pos = self._checkpoints.length;

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value

     * in the most recent checkpoint.

     */

    function latestCheckpoint(History storage self)

        internal

        view

        returns (

            bool exists,

            uint32 _blockNumber,

            uint224 _value

        )

    {

        uint256 pos = self._checkpoints.length;

        if (pos == 0) {

            return (false, 0, 0);

        } else {

            Checkpoint memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);

            return (true, ckpt._blockNumber, ckpt._value);

        }

    }



    /**

     * @dev Returns the number of checkpoint.

     */

    function length(History storage self) internal view returns (uint256) {

        return self._checkpoints.length;

    }



    /**

     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,

     * or by updating the last one.

     */

    function _insert(

        Checkpoint[] storage self,

        uint32 key,

        uint224 value

    ) private returns (uint224, uint224) {

        uint256 pos = self.length;



        if (pos > 0) {

            // Copying to memory is important here.

            Checkpoint memory last = _unsafeAccess(self, pos - 1);



            // Checkpoints keys must be increasing.

            require(last._blockNumber <= key, "Checkpoint: invalid key");



            // Update or push new checkpoint

            if (last._blockNumber == key) {

                _unsafeAccess(self, pos - 1)._value = value;

            } else {

                self.push(Checkpoint({_blockNumber: key, _value: value}));

            }

            return (last._value, value);

        } else {

            self.push(Checkpoint({_blockNumber: key, _value: value}));

            return (0, value);

        }

    }



    /**

     * @dev Return the index of the oldest checkpoint whose key is greater than the search key, or `high` if there is none.

     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.

     *

     * WARNING: `high` should not be greater than the array's length.

     */

    function _upperBinaryLookup(

        Checkpoint[] storage self,

        uint32 key,

        uint256 low,

        uint256 high

    ) private view returns (uint256) {

        while (low < high) {

            uint256 mid = Math.average(low, high);

            if (_unsafeAccess(self, mid)._blockNumber > key) {

                high = mid;

            } else {

                low = mid + 1;

            }

        }

        return high;

    }



    /**

     * @dev Return the index of the oldest checkpoint whose key is greater or equal than the search key, or `high` if there is none.

     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.

     *

     * WARNING: `high` should not be greater than the array's length.

     */

    function _lowerBinaryLookup(

        Checkpoint[] storage self,

        uint32 key,

        uint256 low,

        uint256 high

    ) private view returns (uint256) {

        while (low < high) {

            uint256 mid = Math.average(low, high);

            if (_unsafeAccess(self, mid)._blockNumber < key) {

                low = mid + 1;

            } else {

                high = mid;

            }

        }

        return high;

    }



    /**

     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.

     */

    function _unsafeAccess(Checkpoint[] storage self, uint256 pos) private pure returns (Checkpoint storage result) {

        assembly {

            mstore(0, self.slot)

            result.slot := add(keccak256(0, 0x20), pos)

        }

    }



    struct Trace224 {

        Checkpoint224[] _checkpoints;

    }



    struct Checkpoint224 {

        uint32 _key;

        uint224 _value;

    }



    /**

     * @dev Pushes a (`key`, `value`) pair into a Trace224 so that it is stored as the checkpoint.

     *

     * Returns previous value and new value.

     */

    function push(

        Trace224 storage self,

        uint32 key,

        uint224 value

    ) internal returns (uint224, uint224) {

        return _insert(self._checkpoints, key, value);

    }



    /**

     * @dev Returns the value in the oldest checkpoint with key greater or equal than the search key, or zero if there is none.

     */

    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {

        uint256 len = self._checkpoints.length;

        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);

        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;

    }



    /**

     * @dev Returns the value in the most recent checkpoint with key lower or equal than the search key.

     */

    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {

        uint256 len = self._checkpoints.length;

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.

     */

    function latest(Trace224 storage self) internal view returns (uint224) {

        uint256 pos = self._checkpoints.length;

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value

     * in the most recent checkpoint.

     */

    function latestCheckpoint(Trace224 storage self)

        internal

        view

        returns (

            bool exists,

            uint32 _key,

            uint224 _value

        )

    {

        uint256 pos = self._checkpoints.length;

        if (pos == 0) {

            return (false, 0, 0);

        } else {

            Checkpoint224 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);

            return (true, ckpt._key, ckpt._value);

        }

    }



    /**

     * @dev Returns the number of checkpoint.

     */

    function length(Trace224 storage self) internal view returns (uint256) {

        return self._checkpoints.length;

    }



    /**

     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,

     * or by updating the last one.

     */

    function _insert(

        Checkpoint224[] storage self,

        uint32 key,

        uint224 value

    ) private returns (uint224, uint224) {

        uint256 pos = self.length;



        if (pos > 0) {

            // Copying to memory is important here.

            Checkpoint224 memory last = _unsafeAccess(self, pos - 1);



            // Checkpoints keys must be increasing.

            require(last._key <= key, "Checkpoint: invalid key");



            // Update or push new checkpoint

            if (last._key == key) {

                _unsafeAccess(self, pos - 1)._value = value;

            } else {

                self.push(Checkpoint224({_key: key, _value: value}));

            }

            return (last._value, value);

        } else {

            self.push(Checkpoint224({_key: key, _value: value}));

            return (0, value);

        }

    }



    /**

     * @dev Return the index of the oldest checkpoint whose key is greater than the search key, or `high` if there is none.

     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.

     *

     * WARNING: `high` should not be greater than the array's length.

     */

    function _upperBinaryLookup(

        Checkpoint224[] storage self,

        uint32 key,

        uint256 low,

        uint256 high

    ) private view returns (uint256) {

        while (low < high) {

            uint256 mid = Math.average(low, high);

            if (_unsafeAccess(self, mid)._key > key) {

                high = mid;

            } else {

                low = mid + 1;

            }

        }

        return high;

    }



    /**

     * @dev Return the index of the oldest checkpoint whose key is greater or equal than the search key, or `high` if there is none.

     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.

     *

     * WARNING: `high` should not be greater than the array's length.

     */

    function _lowerBinaryLookup(

        Checkpoint224[] storage self,

        uint32 key,

        uint256 low,

        uint256 high

    ) private view returns (uint256) {

        while (low < high) {

            uint256 mid = Math.average(low, high);

            if (_unsafeAccess(self, mid)._key < key) {

                low = mid + 1;

            } else {

                high = mid;

            }

        }

        return high;

    }



    /**

     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.

     */

    function _unsafeAccess(Checkpoint224[] storage self, uint256 pos)

        private

        pure

        returns (Checkpoint224 storage result)

    {

        assembly {

            mstore(0, self.slot)

            result.slot := add(keccak256(0, 0x20), pos)

        }

    }



    struct Trace160 {

        Checkpoint160[] _checkpoints;

    }



    struct Checkpoint160 {

        uint96 _key;

        uint160 _value;

    }



    /**

     * @dev Pushes a (`key`, `value`) pair into a Trace160 so that it is stored as the checkpoint.

     *

     * Returns previous value and new value.

     */

    function push(

        Trace160 storage self,

        uint96 key,

        uint160 value

    ) internal returns (uint160, uint160) {

        return _insert(self._checkpoints, key, value);

    }



    /**

     * @dev Returns the value in the oldest checkpoint with key greater or equal than the search key, or zero if there is none.

     */

    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {

        uint256 len = self._checkpoints.length;

        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);

        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;

    }



    /**

     * @dev Returns the value in the most recent checkpoint with key lower or equal than the search key.

     */

    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {

        uint256 len = self._checkpoints.length;

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.

     */

    function latest(Trace160 storage self) internal view returns (uint160) {

        uint256 pos = self._checkpoints.length;

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;

    }



    /**

     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value

     * in the most recent checkpoint.

     */

    function latestCheckpoint(Trace160 storage self)

        internal

        view

        returns (

            bool exists,

            uint96 _key,

            uint160 _value

        )

    {

        uint256 pos = self._checkpoints.length;

        if (pos == 0) {

            return (false, 0, 0);

        } else {

            Checkpoint160 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);

            return (true, ckpt._key, ckpt._value);

        }

    }



    /**

     * @dev Returns the number of checkpoint.

     */

    function length(Trace160 storage self) internal view returns (uint256) {

        return self._checkpoints.length;

    }



    /**

     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,

     * or by updating the last one.

     */

    function _insert(

        Checkpoint160[] storage self,

        uint96 key,

        uint160 value

    ) private returns (uint160, uint160) {

        uint256 pos = self.length;



        if (pos > 0) {

            // Copying to memory is important here.

            Checkpoint160 memory last = _unsafeAccess(self, pos - 1);



            // Checkpoints keys must be increasing.

            require(last._key <= key, "Checkpoint: invalid key");



            // Update or push new checkpoint

            if (last._key == key) {

                _unsafeAccess(self, pos - 1)._value = value;

            } else {

                self.push(Checkpoint160({_key: key, _value: value}));

            }

            return (last._value, value);

        } else {

            self.push(Checkpoint160({_key: key, _value: value}));

            return (0, value);

        }

    }



    /**

     * @dev Return the index of the oldest checkpoint whose key is greater than the search key, or `high` if there is none.

     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.

     *

     * WARNING: `high` should not be greater than the array's length.

     */

    function _upperBinaryLookup(

        Checkpoint160[] storage self,

        uint96 key,

        uint256 low,

        uint256 high

    ) private view returns (uint256) {

        while (low < high) {

            uint256 mid = Math.average(low, high);

            if (_unsafeAccess(self, mid)._key > key) {

                high = mid;

            } else {

                low = mid + 1;

            }

        }

        return high;

    }



    /**

     * @dev Return the index of the oldest checkpoint whose key is greater or equal than the search key, or `high` if there is none.

     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.

     *

     * WARNING: `high` should not be greater than the array's length.

     */

    function _lowerBinaryLookup(

        Checkpoint160[] storage self,

        uint96 key,

        uint256 low,

        uint256 high

    ) private view returns (uint256) {

        while (low < high) {

            uint256 mid = Math.average(low, high);

            if (_unsafeAccess(self, mid)._key < key) {

                low = mid + 1;

            } else {

                high = mid;

            }

        }

        return high;

    }



    /**

     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.

     */

    function _unsafeAccess(Checkpoint160[] storage self, uint256 pos)

        private

        pure

        returns (Checkpoint160 storage result)

    {

        assembly {

            mstore(0, self.slot)

            result.slot := add(keccak256(0, 0x20), pos)

        }

    }

}





// Dependency file: @openzeppelin/contracts/governance/utils/IVotes.sol



// OpenZeppelin Contracts (last updated v4.5.0) (governance/utils/IVotes.sol)

// pragma solidity ^0.8.0;



/**

 * @dev Common interface for {ERC20Votes}, {ERC721Votes}, and other {Votes}-enabled contracts.

 *

 * _Available since v4.5._

 */

interface IVotes {

    /**

     * @dev Emitted when an account changes their delegate.

     */

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);



    /**

     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.

     */

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);



    /**

     * @dev Returns the current amount of votes that `account` has.

     */

    function getVotes(address account) external view returns (uint256);



    /**

     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).

     */

    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);



    /**

     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).

     *

     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.

     * Votes that have not been delegated are still part of total supply, even though they would not participate in a

     * vote.

     */

    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);



    /**

     * @dev Returns the delegate that `account` has chosen.

     */

    function delegates(address account) external view returns (address);



    /**

     * @dev Delegates votes from the sender to `delegatee`.

     */

    function delegate(address delegatee) external;



    /**

     * @dev Delegates votes from signer to `delegatee`.

     */

    function delegateBySig(

        address delegatee,

        uint256 nonce,

        uint256 expiry,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external;

}





// Dependency file: @openzeppelin/contracts/governance/utils/Votes.sol



// OpenZeppelin Contracts (last updated v4.8.0) (governance/utils/Votes.sol)

// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/Context.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";

// import "@openzeppelin/contracts/utils/Checkpoints.sol";

// import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

// import "@openzeppelin/contracts/governance/utils/IVotes.sol";



/**

 * @dev This is a base abstract contract that tracks voting units, which are a measure of voting power that can be

 * transferred, and provides a system of vote delegation, where an account can delegate its voting units to a sort of

 * "representative" that will pool delegated voting units from different accounts and can then use it to vote in

 * decisions. In fact, voting units _must_ be delegated in order to count as actual votes, and an account has to

 * delegate those votes to itself if it wishes to participate in decisions and does not have a trusted representative.

 *

 * This contract is often combined with a token contract such that voting units correspond to token units. For an

 * example, see {ERC721Votes}.

 *

 * The full history of delegate votes is tracked on-chain so that governance protocols can consider votes as distributed

 * at a particular block number to protect against flash loans and double voting. The opt-in delegate system makes the

 * cost of this history tracking optional.

 *

 * When using this module the derived contract must implement {_getVotingUnits} (for example, make it return

 * {ERC721-balanceOf}), and can use {_transferVotingUnits} to track a change in the distribution of those units (in the

 * previous example, it would be included in {ERC721-_beforeTokenTransfer}).

 *

 * _Available since v4.5._

 */

abstract contract Votes is IVotes, Context, EIP712 {

    using Checkpoints for Checkpoints.History;

    using Counters for Counters.Counter;



    bytes32 private constant _DELEGATION_TYPEHASH =

        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");



    mapping(address => address) private _delegation;

    mapping(address => Checkpoints.History) private _delegateCheckpoints;

    Checkpoints.History private _totalCheckpoints;



    mapping(address => Counters.Counter) private _nonces;



    /**

     * @dev Returns the current amount of votes that `account` has.

     */

    function getVotes(address account) public view virtual override returns (uint256) {

        return _delegateCheckpoints[account].latest();

    }



    /**

     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).

     *

     * Requirements:

     *

     * - `blockNumber` must have been already mined

     */

    function getPastVotes(address account, uint256 blockNumber) public view virtual override returns (uint256) {

        return _delegateCheckpoints[account].getAtProbablyRecentBlock(blockNumber);

    }



    /**

     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).

     *

     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.

     * Votes that have not been delegated are still part of total supply, even though they would not participate in a

     * vote.

     *

     * Requirements:

     *

     * - `blockNumber` must have been already mined

     */

    function getPastTotalSupply(uint256 blockNumber) public view virtual override returns (uint256) {

        require(blockNumber < block.number, "Votes: block not yet mined");

        return _totalCheckpoints.getAtProbablyRecentBlock(blockNumber);

    }



    /**

     * @dev Returns the current total supply of votes.

     */

    function _getTotalSupply() internal view virtual returns (uint256) {

        return _totalCheckpoints.latest();

    }



    /**

     * @dev Returns the delegate that `account` has chosen.

     */

    function delegates(address account) public view virtual override returns (address) {

        return _delegation[account];

    }



    /**

     * @dev Delegates votes from the sender to `delegatee`.

     */

    function delegate(address delegatee) public virtual override {

        address account = _msgSender();

        _delegate(account, delegatee);

    }



    /**

     * @dev Delegates votes from signer to `delegatee`.

     */

    function delegateBySig(

        address delegatee,

        uint256 nonce,

        uint256 expiry,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) public virtual override {

        require(block.timestamp <= expiry, "Votes: signature expired");

        address signer = ECDSA.recover(

            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),

            v,

            r,

            s

        );

        require(nonce == _useNonce(signer), "Votes: invalid nonce");

        _delegate(signer, delegatee);

    }



    /**

     * @dev Delegate all of `account`'s voting units to `delegatee`.

     *

     * Emits events {IVotes-DelegateChanged} and {IVotes-DelegateVotesChanged}.

     */

    function _delegate(address account, address delegatee) internal virtual {

        address oldDelegate = delegates(account);

        _delegation[account] = delegatee;



        emit DelegateChanged(account, oldDelegate, delegatee);

        _moveDelegateVotes(oldDelegate, delegatee, _getVotingUnits(account));

    }



    /**

     * @dev Transfers, mints, or burns voting units. To register a mint, `from` should be zero. To register a burn, `to`

     * should be zero. Total supply of voting units will be adjusted with mints and burns.

     */

    function _transferVotingUnits(

        address from,

        address to,

        uint256 amount

    ) internal virtual {

        if (from == address(0)) {

            _totalCheckpoints.push(_add, amount);

        }

        if (to == address(0)) {

            _totalCheckpoints.push(_subtract, amount);

        }

        _moveDelegateVotes(delegates(from), delegates(to), amount);

    }



    /**

     * @dev Moves delegated votes from one delegate to another.

     */

    function _moveDelegateVotes(

        address from,

        address to,

        uint256 amount

    ) private {

        if (from != to && amount > 0) {

            if (from != address(0)) {

                (uint256 oldValue, uint256 newValue) = _delegateCheckpoints[from].push(_subtract, amount);

                emit DelegateVotesChanged(from, oldValue, newValue);

            }

            if (to != address(0)) {

                (uint256 oldValue, uint256 newValue) = _delegateCheckpoints[to].push(_add, amount);

                emit DelegateVotesChanged(to, oldValue, newValue);

            }

        }

    }



    function _add(uint256 a, uint256 b) private pure returns (uint256) {

        return a + b;

    }



    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {

        return a - b;

    }



    /**

     * @dev Consumes a nonce.

     *

     * Returns the current value and increments nonce.

     */

    function _useNonce(address owner) internal virtual returns (uint256 current) {

        Counters.Counter storage nonce = _nonces[owner];

        current = nonce.current();

        nonce.increment();

    }



    /**

     * @dev Returns an address nonce.

     */

    function nonces(address owner) public view virtual returns (uint256) {

        return _nonces[owner].current();

    }



    /**

     * @dev Returns the contract's {EIP712} domain separator.

     */

    // solhint-disable-next-line func-name-mixedcase

    function DOMAIN_SEPARATOR() external view returns (bytes32) {

        return _domainSeparatorV4();

    }



    /**

     * @dev Must return the voting units held by an account.

     */

    function _getVotingUnits(address) internal view virtual returns (uint256);

}





// Dependency file: @openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Votes.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/governance/utils/Votes.sol";



/**

 * @dev Extension of ERC721 to support voting and delegation as implemented by {Votes}, where each individual NFT counts

 * as 1 vote unit.

 *

 * Tokens do not count as votes until they are delegated, because votes must be tracked which incurs an additional cost

 * on every transfer. Token holders can either delegate to a trusted representative who will decide how to make use of

 * the votes in governance decisions, or they can delegate to themselves to be their own representative.

 *

 * _Available since v4.5._

 */

abstract contract ERC721Votes is ERC721, Votes {

    /**

     * @dev See {ERC721-_afterTokenTransfer}. Adjusts votes when tokens are transferred.

     *

     * Emits a {IVotes-DelegateVotesChanged} event.

     */

    function _afterTokenTransfer(

        address from,

        address to,

        uint256 firstTokenId,

        uint256 batchSize

    ) internal virtual override {

        _transferVotingUnits(from, to, batchSize);

        super._afterTokenTransfer(from, to, firstTokenId, batchSize);

    }



    /**

     * @dev Returns the balance of `account`.

     */

    function _getVotingUnits(address account) internal view virtual override returns (uint256) {

        return balanceOf(account);

    }

}





// Dependency file: @openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/draft-ERC721Votes.sol)



// pragma solidity ^0.8.0;



// ERC721Votes was marked as draft due to the EIP-712 dependency.

// EIP-712 is Final as of 2022-08-11. This file is deprecated.



// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";





// Dependency file: @openzeppelin/contracts/access/Ownable.sol



// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



// pragma solidity ^0.8.0;



// import "@openzeppelin/contracts/utils/Context.sol";



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





// Dependency file: @openzeppelin/contracts/security/ReentrancyGuard.sol



// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)



// pragma solidity ^0.8.0;



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

}





// Dependency file: contracts/CashRushNftDataStore.sol



// pragma solidity 0.8.17;



abstract contract CashRushNftDataStore {

    uint8 private constant TOTAL_CARDS = 14;



    bool public dataIsFrozen;

    mapping(uint256 => uint8) public tokenType;



    event DataFrozen(bool isFrozen);

    event TypeUpdated(uint256 indexed tokenId, uint8 prevValue, uint8 newValue);



    error ErrorIsFrozen();



    function _uploadTypes(uint256 shift, bytes memory types) internal {

        if (dataIsFrozen) revert ErrorIsFrozen();

        for (uint256 i = 0; i < types.length; i++) {

            uint256 tokenId = shift + i;

            uint8 value = uint8(types[i]);

            emit TypeUpdated(tokenId, tokenType[tokenId], value);

            tokenType[tokenId] = value;

        }

    }



    function _freezeData() internal {

        emit DataFrozen(true);

        dataIsFrozen = true;

    }



    function tokenRate(uint256 tokenId) public view returns (uint256) {

        uint8 ttype = tokenType[tokenId];

        // 100/10000 = 0.01 = 1.00%

        if (ttype == uint8(0)) {

            return 0; // Undefined NFTs - 0.00%

        }

        if (ttype >= uint8(1) && ttype <= uint8(2)) {

            return 20; // Legendary NFTs - 0.20%

        }

        if (ttype >= uint8(3) && ttype <= uint8(5)) {

            return 10; // Rare NFTs - 0.10%

        }

        if (ttype >= uint8(6) && ttype <= uint8(TOTAL_CARDS)) {

            return 5; // Common NFTs - 0.05%

        }

        return 0; // Undefined NFTs - 0.00%

    }



    function tokensMaxRate(

        uint256[] memory tokenIds

    ) public view returns (uint256 maxRate) {

        uint256 tokenMaxRate = 0; // 0 - 20

        bool[] memory set = new bool[](TOTAL_CARDS + 1);

        for (uint256 i = 0; i < tokenIds.length; i++) {

            uint256 tokenId = tokenIds[i];

            uint256 trate = tokenRate(tokenId); // 0 - 20

            uint8 ttype = tokenType[tokenId];

            set[ttype] = true;

            tokenMaxRate = _max(trate, tokenMaxRate);

        }



        // sets

        if (

            set[1] &&

            set[2] &&

            set[3] &&

            set[4] &&

            set[5] &&

            set[6] &&

            set[7] &&

            set[8] &&

            set[9] &&

            set[10] &&

            set[11] &&

            set[12] &&

            set[13] &&

            set[14]

        ) {

            return 100; // Fully-Stacked Deck - 1.00%

        }

        if (set[1] && set[2]) {

            return 30; // Set of Legendary NFTs - 0.30%

        }



        // 0.20% + 0.10%

        if (set[1] && set[5]) {

            return 30;

        }

        // 0.20% + 0.05%

        if (set[1] && set[10]) {

            return 25;

        }



        // 0.10% + 0.10%

        if (set[3] && set[5]) {

            return 20;

        }



        if (set[3] && set[4] && set[5]) {

            return 20; // Set of Rare NFTs - 0.20%

        }



        // 0.10% + 0.05%

        if (set[4] && set[10]) {

            return _max(15, tokenMaxRate);

        }

        // 0.10% +

        if (set[5]) {

            // 0.05% || 0.05%

            if (set[8] || set[11]) {

                return _max(15, tokenMaxRate);

            }

        }



        if (

            set[6] &&

            set[7] &&

            set[8] &&

            set[9] &&

            set[10] &&

            set[11] &&

            set[12] &&

            set[13] &&

            set[14]

        ) {

            return _max(15, tokenMaxRate); // Set of Common NFTs - 0.15%

        }



        // 0.05% + 0.05%

        if (set[9] && set[12]) {

            return _max(10, tokenMaxRate);

        }



        return tokenMaxRate; // cards max rate

    }



    function _max(uint256 a, uint256 b) private pure returns (uint256) {

        return a > b ? a : b;

    }

}





// Dependency file: contracts/CashRushNftStaking.sol



// pragma solidity 0.8.17;



// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// import "contracts/CashRushNftDataStore.sol";



abstract contract CashRushNftStaking is

    ERC721,

    ERC721Enumerable,

    CashRushNftDataStore

{

    mapping(uint256 => bool) public isStaked;

    mapping(address => uint256) public extraRate;



    event Staked(uint256 indexed tokenId);

    event Unstaked(uint256 indexed tokenId);

    event ExtraRateSetted(address indexed account, uint256 extraRate);



    error DuplicateTokenId();

    error NotTokenOwner();



    function stake(uint256[] memory tokenIds) external {

        _stake(tokenIds, true);

    }



    function unstake(uint256[] memory tokenIds) external {

        _stake(tokenIds, false);

    }



    function _stake(uint256[] memory tokenIds, bool state) private {

        if (!dataIsFrozen) revert ErrorIsFrozen();

        for (uint256 i = 0; i < tokenIds.length; i++) {

            uint256 tokenId = tokenIds[i];

            for (uint256 j = i + 1; j < tokenIds.length; j++) {

                if (tokenId == tokenIds[j]) revert DuplicateTokenId();

            }

            if (ownerOf(tokenId) != msg.sender) revert NotTokenOwner();

            if (isStaked[tokenId] != state) {

                if (state) emit Staked(tokenId);

                else emit Unstaked(tokenId);

            }

            isStaked[tokenId] = state;

        }



        extraRate[msg.sender] = accountRate(msg.sender);

        emit ExtraRateSetted(msg.sender, extraRate[msg.sender]);

    }



    function accountRate(address account) public view returns (uint256) {

        return tokensMaxRate(tokensStakedOfOwner(account));

    }



    function tokensStakedOfOwner(

        address owner

    ) public view returns (uint256[] memory) {

        uint256 tokenCount = balanceOf(owner);

        require(0 < tokenCount, "ERC721Enumerable: owner index out of bounds");

        uint256 stakedCount = 0;

        for (uint256 i = 0; i < tokenCount; i++) {

            if (isStaked[tokenOfOwnerByIndex(owner, i)]) {

                stakedCount++;

            }

        }



        uint256[] memory tokenIds = new uint256[](stakedCount);

        stakedCount = 0;

        for (uint256 i = 0; i < tokenCount; i++) {

            uint256 tokenId = tokenOfOwnerByIndex(owner, i);

            if (isStaked[tokenId]) {

                tokenIds[stakedCount] = tokenId;

                stakedCount++;

            }

        }

        return tokenIds;

    }



    modifier whenNotStaked(uint256 tokenId) {

        _requireMinted(tokenId);

        require(!isStaked[tokenId], "Token is staked");

        _;

    }



    // Override

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 tokenId,

        uint256 batchSize

    ) internal virtual override(ERC721, ERC721Enumerable) {

        super._beforeTokenTransfer(from, to, tokenId, batchSize);

    }



    function supportsInterface(

        bytes4 interfaceId

    ) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {

        return super.supportsInterface(interfaceId);

    }

}





// Root file: contracts/CashRushNft.sol



pragma solidity 0.8.17;



// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

// import "@openzeppelin/contracts/token/common/ERC2981.sol";

// import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

// import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "@openzeppelin/contracts/utils/Strings.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";

// import "contracts/CashRushNftStaking.sol";



interface ITraitsShort {

    function contractURI() external view returns (string memory);



    function tokenURI(uint256 tokenId) external view returns (string memory);

}



contract CashRushNft is

    ERC721,

    ERC721Enumerable,

    ERC721Burnable,

    CashRushNftStaking,

    ERC2981,

    DefaultOperatorFilterer,

    EIP712,

    ERC721Votes,

    ReentrancyGuard,

    Ownable

{

    using Strings for uint256;

    using Counters for Counters.Counter;



    uint256 private constant DAY = 86_400;

    uint256 private constant MAX_SUPPLY = 4000;

    uint256 public FREE_MINT = 170;

    uint256 private totalMinted;

    Counters.Counter private _tokenIdCounter;



    // Metadata

    address public TRAITS;

    string private _contractURI = "https://cashrush.gg/metadata/contract.json";

    string private _baseURL = "https://cashrush.gg/metadata/";

    string private _baseExtension = ".json";

    bool private _revealed = false;

    string private _notRevealedURI =

        "https://cashrush.gg/metadata/unrevealed.json";



    // Mints

    address payable public wallet;

    // Free Mint

    bool public isActiveFreeMint = false;

    bytes32 public merkleRoot1;

    mapping(address => uint256) public minted1;

    // WL Mint

    bool public isActiveWhitelistMint = false;

    bytes32 public merkleRoot2;

    mapping(address => uint256) public minted2;

    uint256 public price2 = 0.03 ether;

    // Public Mint

    bool public isActivePublicMint = false;

    uint256 public price3 = 0.04 ether;



    uint256 public totalRewards;

    mapping(uint256 => uint256) public rewards;

    mapping(uint256 => uint256) public rewardsLastClaim;



    address public killer;

    address public killSigner;

    uint256 public immutable chainId;



    event Received(address indexed account, uint256 value);



    event Killed(uint256 indexed tokenId);

    event KillerChanged(address indexed oldKiller, address indexed newKiller);

    event KillSignerChanged(

        address indexed oldKillSigner,

        address indexed newKillSigner

    );



    error IndexOutOfBounds();

    error MintNotActive();

    error MintLimit();

    error NotAuthorized();

    error IncorrectValue();



    constructor()

        public

        ERC721("CASH RUSH", "CASHRUSH")

        EIP712("CASH RUSH", "1")

    {

        wallet = payable(0x8fa9873B72caF6215EbB5f9956d3CC67aa91F951);

        _setDefaultRoyalty(0x8fa9873B72caF6215EbB5f9956d3CC67aa91F951, 500);



        // Setting start from 1.

        _tokenIdCounter.increment();



        chainId = block.chainid;

        emit KillerChanged(killer, _msgSender());

        killer = _msgSender();

        //emit KillSignerChanged(killSigner, _msgSender());

        //killSigner = _msgSender();

    }



    // CashRush - kill

    function kill(

        uint256 tokenId,

        bytes memory signature

    ) external whenNotStaked(tokenId) {

        require(_msgSender() == killer, "Access denied");



        if (killSigner != address(0)) {

            _checkSignature(tokenId, signature);

        }



        _burn(tokenId);

        emit Killed(tokenId);

    }



    function setKiller(address newKiller) external onlyOwner {

        emit KillerChanged(killer, newKiller);

        killer = newKiller;

    }



    function setKillSigner(address newKillSigner) external onlyOwner {

        emit KillSignerChanged(killSigner, newKillSigner);

        killSigner = newKillSigner;

    }



    function _checkSignature(

        uint256 tokenId,

        bytes memory signature

    ) internal view {

        address tokenOwner = _ownerOf(tokenId);

        if (_signatureWallet(tokenId, tokenOwner, signature) != killSigner)

            revert NotAuthorized();

    }



    function _signatureWallet(

        uint256 tokenId,

        address tokenOwner,

        bytes memory signature

    ) private view returns (address) {

        return

            ECDSA.recover(

                keccak256(abi.encode(chainId, tokenId, tokenOwner)),

                signature

            );

    }



    // CashRush - Game fees distribution

    function accumulated(

        uint256[] memory tokenIds

    ) external view returns (uint256) {

        uint256 share = (totalRewards + address(this).balance) / totalMinted;

        uint256 total;

        for (uint256 i = 0; i < tokenIds.length; i++) {

            uint256 tokenId = tokenIds[i];

            if (tokenId < 1 || tokenId > totalMinted) revert IndexOutOfBounds();

            for (uint256 j = i + 1; j < tokenIds.length; j++) {

                if (tokenId == tokenIds[j]) revert DuplicateTokenId();

            }

            uint256 payedRewards = rewards[tokenId];

            if (payedRewards < share) {

                total += (share - payedRewards);

            }

        }

        return total;

    }



    function claim(uint256[] memory tokenIds) external nonReentrant {

        uint256 share = (totalRewards + address(this).balance) / totalMinted;

        uint256 total;

        for (uint256 i = 0; i < tokenIds.length; i++) {

            uint256 tokenId = tokenIds[i];

            for (uint256 j = i + 1; j < tokenIds.length; j++) {

                if (tokenId == tokenIds[j]) revert DuplicateTokenId();

            }

            if (ownerOf(tokenId) != _msgSender()) revert NotTokenOwner();

            uint256 payedRewards = rewards[tokenId];

            if (payedRewards < share) {

                uint256 toPay = share - payedRewards;

                rewards[tokenId] += toPay;

                rewardsLastClaim[tokenId] = block.timestamp;

                total += toPay;

            }

        }

        if (total > 0) {

            _sendEth(payable(_msgSender()), total);

            totalRewards += total;

        }

    }



    function claimByOwner(

        uint256[] memory tokenIds

    ) external nonReentrant onlyOwner {

        uint256 share = (totalRewards + address(this).balance) / totalMinted;

        uint256 total;

        for (uint256 i = 0; i < tokenIds.length; i++) {

            uint256 tokenId = tokenIds[i];

            if (tokenId < 1 || tokenId > totalMinted) revert IndexOutOfBounds();

            for (uint256 j = i + 1; j < tokenIds.length; j++) {

                if (tokenId == tokenIds[j]) revert DuplicateTokenId();

            }

            require(

                (rewardsLastClaim[tokenId] + DAY * 90) <= block.timestamp,

                "Not allowed"

            );

            uint256 payedRewards = rewards[tokenId];

            if (payedRewards < share) {

                uint256 toPay = share - payedRewards;

                rewards[tokenId] += toPay;

                rewardsLastClaim[tokenId] = block.timestamp;

                total += toPay;

            }

        }

        if (total > 0) {

            _sendEth(payable(_msgSender()), total);

            totalRewards += total;

        }

    }



    // CashRush - Mint

    function safeMint(

        address to,

        uint256 tokenCount

    ) external nonReentrant onlyOwner {

        require((totalSupply() + tokenCount) <= MAX_SUPPLY, "MAX_SUPPLY");

        totalMinted += tokenCount;

        for (uint256 i = 0; i < tokenCount; i++) {

            uint256 tokenId = _tokenIdCounter.current();

            _tokenIdCounter.increment();

            _safeMint(to, tokenId);

        }

    }



    function setWallet(address _wallet) external onlyOwner {

        wallet = payable(_wallet);

    }



    function setActiveFreeMint(bool status) external onlyOwner {

        isActiveFreeMint = status;

    }



    function setActiveWhitelistMint(bool status) external onlyOwner {

        isActiveWhitelistMint = status;

    }



    function setActivePublicMint(bool status) external onlyOwner {

        isActivePublicMint = status;

    }



    function freeMint(

        address account,

        bytes32[] calldata merkleProof

    ) external nonReentrant {

        if (!isActiveFreeMint || FREE_MINT == 0) revert MintNotActive();

        if (minted1[account] >= 1) revert MintLimit();

        require(

            _verify1(_leaf(account, 1), merkleProof),

            "MerkleDistributor: Invalid  merkle proof"

        );

        FREE_MINT--;

        minted1[account]++;

        totalMinted++;

        uint256 tokenId = _tokenIdCounter.current();

        _tokenIdCounter.increment();

        _safeMint(account, tokenId);

    }



    function whitelistMint(

        address account,

        uint256 tokenCount,

        bytes32[] calldata merkleProof

    ) external payable nonReentrant {

        if (!isActiveWhitelistMint) revert MintNotActive();

        if ((minted2[account] + tokenCount) > 5) revert MintLimit();

        require(

            _verify2(_leaf(account, 1), merkleProof),

            "MerkleDistributor: Invalid  merkle proof"

        );

        require((totalSupply() + tokenCount) <= MAX_SUPPLY, "MAX_SUPPLY");

        if (msg.value != tokenCount * price2) revert IncorrectValue();

        _sendEth(wallet, msg.value);

        minted2[account] += tokenCount;

        totalMinted += tokenCount;

        for (uint256 i = 0; i < tokenCount; i++) {

            uint256 tokenId = _tokenIdCounter.current();

            _tokenIdCounter.increment();

            _safeMint(account, tokenId);

        }

    }



    function publicMint(uint256 tokenCount) external payable nonReentrant {

        if (!isActivePublicMint) revert MintNotActive();

        require((totalSupply() + tokenCount) <= MAX_SUPPLY, "MAX_SUPPLY");

        if (msg.value != tokenCount * price3) revert IncorrectValue();

        _sendEth(wallet, msg.value);

        totalMinted += tokenCount;

        for (uint256 i = 0; i < tokenCount; i++) {

            uint256 tokenId = _tokenIdCounter.current();

            _tokenIdCounter.increment();

            _safeMint(_msgSender(), tokenId);

        }

    }



    function _sendEth(address payable recipient, uint256 amount) private {

        (bool success, ) = recipient.call{value: amount}("");

        require(success, "ETH_TRANSFER_FAILED");

    }



    function _leaf(

        address account,

        uint256 amount

    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(account, amount));

    }



    function _verify1(

        bytes32 leaf,

        bytes32[] memory merkleProof

    ) internal view returns (bool) {

        return MerkleProof.verify(merkleProof, merkleRoot1, leaf);

    }



    function _verify2(

        bytes32 leaf,

        bytes32[] memory merkleProof

    ) internal view returns (bool) {

        return MerkleProof.verify(merkleProof, merkleRoot2, leaf);

    }



    function setRoot1(bytes32 merkleRoot_) external onlyOwner {

        merkleRoot1 = merkleRoot_;

    }



    function setRoot2(bytes32 merkleRoot_) external onlyOwner {

        merkleRoot2 = merkleRoot_;

    }



    receive() external payable {

        emit Received(msg.sender, msg.value);

    }



    // Extra

    function rawOwnerOf(uint256 tokenId) external view returns (address) {

        return _ownerOf(tokenId);

    }



    function tokensOfOwner(

        address owner

    ) external view returns (uint256[] memory) {

        uint256 tokenCount = balanceOf(owner);

        require(0 < tokenCount, "ERC721Enumerable: owner index out of bounds");

        uint256[] memory tokenIds = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {

            tokenIds[i] = tokenOfOwnerByIndex(owner, i);

        }

        return tokenIds;

    }



    // NFTs Types

    function uploadTypes(uint256 shift, bytes memory types) external onlyOwner {

        _uploadTypes(shift, types);

    }



    function freezeData() external onlyOwner {

        _freezeData();

    }



    // Metadata

    function reveal() external onlyOwner {

        _revealed = true;

    }



    function setNotRevealedURI(string memory uri_) external onlyOwner {

        _notRevealedURI = uri_;

    }



    function contractURI() external view returns (string memory) {

        if (TRAITS != address(0)) return ITraitsShort(TRAITS).contractURI();

        return _contractURI;

    }



    function setContractURI(string memory uri_) external onlyOwner {

        _contractURI = uri_;

    }



    function tokenURI(

        uint256 tokenId

    ) public view override returns (string memory) {

        _requireMinted(tokenId);



        if (!_revealed) return _notRevealedURI;



        if (TRAITS != address(0)) return ITraitsShort(TRAITS).tokenURI(tokenId);



        return

            string(

                abi.encodePacked(_baseURL, tokenId.toString(), _baseExtension)

            );

    }



    function setBaseURI(string memory uri_) external onlyOwner {

        _baseURL = uri_;

    }



    function setBaseExtension(string memory fileExtension) external onlyOwner {

        _baseExtension = fileExtension;

    }



    function setTraits(address traits_) external onlyOwner {

        TRAITS = traits_;

    }



    // Royalty

    function setDefaultRoyalty(

        address royaltyReceiver,

        uint96 royaltyNumerator

    ) external onlyOwner {

        _setDefaultRoyalty(royaltyReceiver, royaltyNumerator);

    }



    function deleteDefaultRoyalty() external onlyOwner {

        _deleteDefaultRoyalty();

    }



    // Override

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 tokenId,

        uint256 batchSize

    ) internal override(ERC721, ERC721Enumerable, CashRushNftStaking) {

        super._beforeTokenTransfer(from, to, tokenId, batchSize);

    }



    function _afterTokenTransfer(

        address from,

        address to,

        uint256 tokenId,

        uint256 batchSize

    ) internal override(ERC721, ERC721Votes) {

        super._afterTokenTransfer(from, to, tokenId, batchSize);

    }



    function setApprovalForAll(

        address operator,

        bool approved

    ) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {

        super.setApprovalForAll(operator, approved);

    }



    function approve(

        address operator,

        uint256 tokenId

    ) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {

        super.approve(operator, tokenId);

    }



    function burn(uint256 tokenId) public override whenNotStaked(tokenId) {

        super.burn(tokenId);

    }



    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    )

        public

        override(ERC721, IERC721)

        whenNotStaked(tokenId)

        onlyAllowedOperator(from)

    {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    )

        public

        override(ERC721, IERC721)

        whenNotStaked(tokenId)

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    )

        public

        override(ERC721, IERC721)

        whenNotStaked(tokenId)

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    function supportsInterface(

        bytes4 interfaceId

    )

        public

        view

        override(ERC721, ERC721Enumerable, CashRushNftStaking, ERC2981)

        returns (bool)

    {

        return super.supportsInterface(interfaceId);

    }

}