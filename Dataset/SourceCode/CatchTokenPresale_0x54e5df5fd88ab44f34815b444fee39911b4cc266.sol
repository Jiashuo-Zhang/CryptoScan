/**

 *Submitted for verification at Etherscan.io on 2023-11-28

*/



// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol





pragma solidity ^0.8.0;



interface AggregatorV3Interface {

  function decimals() external view returns (uint8);



  function description() external view returns (string memory);



  function version() external view returns (uint256);



  // getRoundData and latestRoundData should both raise "No data present"

  // if they do not have data to report, instead of returning unset values

  // which could be misinterpreted as actual reported values.

  function getRoundData(uint80 _roundId)

    external

    view

    returns (

      uint80 roundId,

      int256 answer,

      uint256 startedAt,

      uint256 updatedAt,

      uint80 answeredInRound

    );



  function latestRoundData()

    external

    view

    returns (

      uint80 roundId,

      int256 answer,

      uint256 startedAt,

      uint256 updatedAt,

      uint80 answeredInRound

    );

}



// File: @openzeppelin/[email protected]/token/ERC20/IERC20.sol





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



// File: @openzeppelin/[email protected]/interfaces/IERC5267.sol





// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC5267.sol)



pragma solidity ^0.8.0;



interface IERC5267 {

    /**

     * @dev MAY be emitted to signal that the domain could have changed.

     */

    event EIP712DomainChanged();



    /**

     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712

     * signature.

     */

    function eip712Domain()

        external

        view

        returns (

            bytes1 fields,

            string memory name,

            string memory version,

            uint256 chainId,

            address verifyingContract,

            bytes32 salt,

            uint256[] memory extensions

        );

}



// File: @openzeppelin/[email protected]/utils/StorageSlot.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)

// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.



pragma solidity ^0.8.0;



/**

 * @dev Library for reading and writing primitive types to specific storage slots.

 *

 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.

 * This library helps with reading and writing to such slots without the need for inline assembly.

 *

 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.

 *

 * Example usage to set ERC1967 implementation slot:

 * ```solidity

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

 * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._

 * _Available since v4.9 for `string`, `bytes`._

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



    struct StringSlot {

        string value;

    }



    struct BytesSlot {

        bytes value;

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



    /**

     * @dev Returns an `StringSlot` with member `value` located at `slot`.

     */

    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := slot

        }

    }



    /**

     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.

     */

    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := store.slot

        }

    }



    /**

     * @dev Returns an `BytesSlot` with member `value` located at `slot`.

     */

    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := slot

        }

    }



    /**

     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.

     */

    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {

        /// @solidity memory-safe-assembly

        assembly {

            r.slot := store.slot

        }

    }

}



// File: @openzeppelin/[email protected]/utils/ShortStrings.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/ShortStrings.sol)



pragma solidity ^0.8.8;





// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |

// | length  | 0x                                                              BB |

type ShortString is bytes32;



/**

 * @dev This library provides functions to convert short memory strings

 * into a `ShortString` type that can be used as an immutable variable.

 *

 * Strings of arbitrary length can be optimized using this library if

 * they are short enough (up to 31 bytes) by packing them with their

 * length (1 byte) in a single EVM word (32 bytes). Additionally, a

 * fallback mechanism can be used for every other case.

 *

 * Usage example:

 *

 * ```solidity

 * contract Named {

 *     using ShortStrings for *;

 *

 *     ShortString private immutable _name;

 *     string private _nameFallback;

 *

 *     constructor(string memory contractName) {

 *         _name = contractName.toShortStringWithFallback(_nameFallback);

 *     }

 *

 *     function name() external view returns (string memory) {

 *         return _name.toStringWithFallback(_nameFallback);

 *     }

 * }

 * ```

 */

library ShortStrings {

    // Used as an identifier for strings longer than 31 bytes.

    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;



    error StringTooLong(string str);

    error InvalidShortString();



    /**

     * @dev Encode a string of at most 31 chars into a `ShortString`.

     *

     * This will trigger a `StringTooLong` error is the input string is too long.

     */

    function toShortString(string memory str) internal pure returns (ShortString) {

        bytes memory bstr = bytes(str);

        if (bstr.length > 31) {

            revert StringTooLong(str);

        }

        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));

    }



    /**

     * @dev Decode a `ShortString` back to a "normal" string.

     */

    function toString(ShortString sstr) internal pure returns (string memory) {

        uint256 len = byteLength(sstr);

        // using `new string(len)` would work locally but is not memory safe.

        string memory str = new string(32);

        /// @solidity memory-safe-assembly

        assembly {

            mstore(str, len)

            mstore(add(str, 0x20), sstr)

        }

        return str;

    }



    /**

     * @dev Return the length of a `ShortString`.

     */

    function byteLength(ShortString sstr) internal pure returns (uint256) {

        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;

        if (result > 31) {

            revert InvalidShortString();

        }

        return result;

    }



    /**

     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.

     */

    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {

        if (bytes(value).length < 32) {

            return toShortString(value);

        } else {

            StorageSlot.getStringSlot(store).value = value;

            return ShortString.wrap(_FALLBACK_SENTINEL);

        }

    }



    /**

     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.

     */

    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {

        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {

            return toString(value);

        } else {

            return store;

        }

    }



    /**

     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using {setWithFallback}.

     *

     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of

     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.

     */

    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {

        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {

            return byteLength(value);

        } else {

            return bytes(store).length;

        }

    }

}



// File: @openzeppelin/[email protected]/utils/introspection/IERC165.sol





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



// File: @openzeppelin/[email protected]/utils/introspection/ERC165.sol





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



// File: @openzeppelin/[email protected]/utils/math/SignedMath.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)



pragma solidity ^0.8.0;



/**

 * @dev Standard signed math utilities missing in the Solidity language.

 */

library SignedMath {

    /**

     * @dev Returns the largest of two signed numbers.

     */

    function max(int256 a, int256 b) internal pure returns (int256) {

        return a > b ? a : b;

    }



    /**

     * @dev Returns the smallest of two signed numbers.

     */

    function min(int256 a, int256 b) internal pure returns (int256) {

        return a < b ? a : b;

    }



    /**

     * @dev Returns the average of two signed numbers without overflow.

     * The result is rounded towards zero.

     */

    function average(int256 a, int256 b) internal pure returns (int256) {

        // Formula from the book "Hacker's Delight"

        int256 x = (a & b) + ((a ^ b) >> 1);

        return x + (int256(uint256(x) >> 255) & (a ^ b));

    }



    /**

     * @dev Returns the absolute unsigned value of a signed value.

     */

    function abs(int256 n) internal pure returns (uint256) {

        unchecked {

            // must be unchecked in order to support `n = type(int256).min`

            return uint256(n >= 0 ? n : -n);

        }

    }

}



// File: @openzeppelin/[email protected]/utils/math/Math.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)



pragma solidity ^0.8.0;



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

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {

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

                // Solidity will revert if denominator == 0, unlike the div opcode on its own.

                // The surrounding unchecked block does not change this fact.

                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.

                return prod0 / denominator;

            }



            // Make sure the result is less than 2^256. Also prevents denominator == 0.

            require(denominator > prod1, "Math: mulDiv overflow");



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

    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {

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

            if (value >= 10 ** 64) {

                value /= 10 ** 64;

                result += 64;

            }

            if (value >= 10 ** 32) {

                value /= 10 ** 32;

                result += 32;

            }

            if (value >= 10 ** 16) {

                value /= 10 ** 16;

                result += 16;

            }

            if (value >= 10 ** 8) {

                value /= 10 ** 8;

                result += 8;

            }

            if (value >= 10 ** 4) {

                value /= 10 ** 4;

                result += 4;

            }

            if (value >= 10 ** 2) {

                value /= 10 ** 2;

                result += 2;

            }

            if (value >= 10 ** 1) {

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

            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);

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

     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log256(value);

            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);

        }

    }

}



// File: @openzeppelin/[email protected]/utils/Strings.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)



pragma solidity ^0.8.0;







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

     * @dev Converts a `int256` to its ASCII `string` decimal representation.

     */

    function toString(int256 value) internal pure returns (string memory) {

        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));

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



    /**

     * @dev Returns true if the two strings are equal.

     */

    function equal(string memory a, string memory b) internal pure returns (bool) {

        return keccak256(bytes(a)) == keccak256(bytes(b));

    }

}



// File: @openzeppelin/[email protected]/utils/cryptography/ECDSA.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)



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

    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);

        uint8 v = uint8((uint256(vs) >> 255) + 27);

        return tryRecover(hash, v, r, s);

    }



    /**

     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.

     *

     * _Available since v4.2._

     */

    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {

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

    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {

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

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

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

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {

        // 32 is the length in bytes of hash,

        // enforced by the type signature above

        /// @solidity memory-safe-assembly

        assembly {

            mstore(0x00, "\x19Ethereum Signed Message:\n32")

            mstore(0x1c, hash)

            message := keccak256(0x00, 0x3c)

        }

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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {

        /// @solidity memory-safe-assembly

        assembly {

            let ptr := mload(0x40)

            mstore(ptr, "\x19\x01")

            mstore(add(ptr, 0x02), domainSeparator)

            mstore(add(ptr, 0x22), structHash)

            data := keccak256(ptr, 0x42)

        }

    }



    /**

     * @dev Returns an Ethereum Signed Data with intended validator, created from a

     * `validator` and `data` according to the version 0 of EIP-191.

     *

     * See {recover}.

     */

    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x00", validator, data));

    }

}



// File: @openzeppelin/[email protected]/utils/cryptography/EIP712.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/EIP712.sol)



pragma solidity ^0.8.8;









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

 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain

 * separator of the implementation contract. This will cause the `_domainSeparatorV4` function to always rebuild the

 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.

 *

 * _Available since v3.4._

 *

 * @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment

 */

abstract contract EIP712 is IERC5267 {

    using ShortStrings for *;



    bytes32 private constant _TYPE_HASH =

        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");



    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to

    // invalidate the cached domain separator if the chain id changes.

    bytes32 private immutable _cachedDomainSeparator;

    uint256 private immutable _cachedChainId;

    address private immutable _cachedThis;



    bytes32 private immutable _hashedName;

    bytes32 private immutable _hashedVersion;



    ShortString private immutable _name;

    ShortString private immutable _version;

    string private _nameFallback;

    string private _versionFallback;



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

        _name = name.toShortStringWithFallback(_nameFallback);

        _version = version.toShortStringWithFallback(_versionFallback);

        _hashedName = keccak256(bytes(name));

        _hashedVersion = keccak256(bytes(version));



        _cachedChainId = block.chainid;

        _cachedDomainSeparator = _buildDomainSeparator();

        _cachedThis = address(this);

    }



    /**

     * @dev Returns the domain separator for the current chain.

     */

    function _domainSeparatorV4() internal view returns (bytes32) {

        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {

            return _cachedDomainSeparator;

        } else {

            return _buildDomainSeparator();

        }

    }



    function _buildDomainSeparator() private view returns (bytes32) {

        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));

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



    /**

     * @dev See {EIP-5267}.

     *

     * _Available since v4.9._

     */

    function eip712Domain()

        public

        view

        virtual

        override

        returns (

            bytes1 fields,

            string memory name,

            string memory version,

            uint256 chainId,

            address verifyingContract,

            bytes32 salt,

            uint256[] memory extensions

        )

    {

        return (

            hex"0f", // 01111

            _name.toStringWithFallback(_nameFallback),

            _version.toStringWithFallback(_versionFallback),

            block.chainid,

            address(this),

            bytes32(0),

            new uint256[](0)

        );

    }

}



// File: @openzeppelin/[email protected]/utils/Context.sol





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



// File: @openzeppelin/[email protected]/access/IAccessControl.sol





// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)



pragma solidity ^0.8.0;



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



// File: @openzeppelin/[email protected]/access/AccessControl.sol





// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)



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

 * ```solidity

 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");

 * ```

 *

 * Roles can be used to represent a set of permissions. To restrict access to a

 * function call, use {hasRole}:

 *

 * ```solidity

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

 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}

 * to enforce additional security measures for this role.

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

                        Strings.toHexString(account),

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

     *

     * May emit a {RoleGranted} event.

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

     *

     * May emit a {RoleRevoked} event.

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

     *

     * May emit a {RoleRevoked} event.

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

     * May emit a {RoleGranted} event.

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

     *

     * May emit a {RoleGranted} event.

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

     *

     * May emit a {RoleRevoked} event.

     */

    function _revokeRole(bytes32 role, address account) internal virtual {

        if (hasRole(role, account)) {

            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, _msgSender());

        }

    }

}



// File: CatchTokenPresale.sol





pragma solidity 0.8.19;











contract CatchTokenPresale is AccessControl, EIP712 {

	bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");



	event Bought(address user, uint256 tokenAmount);

	event PhaseChanged(Phase phase);

	event ClaimedTGE(address user, uint256 tokenAmount);

	event ClaimedVesting(address user, uint256 tokenAmount);



	enum Phase {

		INIT,

		BUY,

		CLAIM

	}



	address payable immutable public buyRecipient;

	IERC20 immutable public catchToken;

	AggregatorV3Interface immutable public priceFeed;

	IERC20 immutable public usdt;



	/// @notice 8 decimals; e.g. value `100000000` represents $1.00 for 1 full CATCH token

	uint256 immutable public tokenPriceUsd;



	/// @notice 8 decimals; e.g. value `5000000000` represents $50.00 minimal USDT amount

	uint256 immutable public minUsdAmount;



	/// @notice 0 decimals, e.g. value `10` represents 10% discount

	uint8 immutable public nftHolderDiscountPercent;



	uint256 immutable public presaleSupply;



	/// @notice 0 decimals, e.g. value `10` represents 10% unlock at TGE

	uint8 immutable public unlockPercentAtTGE;

	uint8 immutable public cliffMonths;

	uint8 immutable public linearVestingMonths;



	Phase public currentPhase;



	mapping(bytes32 => bool) public usedNonces;



	uint256 public vestingStartDate;

	uint256 public vestingEndDate;



	mapping(address user => uint256 tokens) public totalTGETokensByUser;

	mapping(address user => uint256 tokens) public totalVestingTokensByUser;

	mapping(address user => uint256 tokens) public claimedTGETokensByUser;

	mapping(address user => uint256 tokens) public claimedVestingTokensByUser;



	uint256 public totalTokensBought;



	uint256[4] private volumeThresholds = [50000000000, 150100000000, 300100000000, 500100000000];

	uint8[4] private volumeBonuses = [3, 5, 7, 12];



	modifier onlyCurrentPhase(Phase _phase) {

		require(currentPhase == _phase, "CatchTokenPresale: Unexpected current phase");

		_;

	}



	struct PresaleParams {

		address payable _buyRecipient;

		uint256 _tokenPriceUsd;

		uint256 _minUsdAmount;

		uint8 _nftHolderDiscountPercent;

		uint256 _presaleSupply;

		uint8 _unlockPercentAtTGE;

		uint8 _cliffMonths;

		uint8 _linearVestingMonths;

	}



	constructor(

		address[] memory admins,

		address[] memory signers,

		IERC20 _catchToken,

		AggregatorV3Interface _priceFeed,

		IERC20 _usdt,

		PresaleParams memory presaleParams

	) EIP712("CatchTokenPresale", "1") {

		for (uint i; i < admins.length; i++) {

			_grantRole(DEFAULT_ADMIN_ROLE, admins[i]);

		}

		for (uint i; i < admins.length; i++) {

			_grantRole(SIGNER_ROLE, signers[i]);

		}



		catchToken = _catchToken;

		priceFeed = _priceFeed;

		usdt = _usdt;



		buyRecipient = presaleParams._buyRecipient;

		tokenPriceUsd = presaleParams._tokenPriceUsd;

		minUsdAmount = presaleParams._minUsdAmount;

		nftHolderDiscountPercent = presaleParams._nftHolderDiscountPercent;

		presaleSupply = presaleParams._presaleSupply;

		unlockPercentAtTGE = presaleParams._unlockPercentAtTGE;

		cliffMonths = presaleParams._cliffMonths;

		linearVestingMonths = presaleParams._linearVestingMonths;

	}



	function buyWithEth(uint256 tokenAmount) external payable onlyCurrentPhase(Phase.BUY) {

		require(this.getUsdAmount(tokenAmount) >= minUsdAmount, "CatchTokenPresale: Below min amount");

		_buyWithEth(tokenAmount, false);

	}



	function buyWithUsdt(uint256 tokenAmount) external onlyCurrentPhase(Phase.BUY) {

		require(this.getUsdAmount(tokenAmount) >= minUsdAmount, "CatchTokenPresale: Below min amount");

		_buyWithUsdt(tokenAmount, false);

	}



	function buyWithEthNftHolder(uint256 tokenAmount, bytes32 nonce, bytes memory signature) external payable onlyCurrentPhase(Phase.BUY) {

		require(this.getUsdAmount(tokenAmount) >= minUsdAmount, "CatchTokenPresale: Below min amount");

		bytes32 digest = _hashTypedDataV4(

			keccak256(abi.encode(keccak256("BuyWithEthNftHolder(bytes32 nonce)"), nonce))

		);

		address recoveredSigner = ECDSA.recover(digest, signature);

		require(hasRole(SIGNER_ROLE, recoveredSigner), "CatchTokenPresale: Invalid signature");

		require(!usedNonces[nonce], "CatchTokenPresale: Nonce already used");

		usedNonces[nonce] = true;

		_buyWithEth(tokenAmount, true);

	}



	function buyWithUsdtNftHolder(uint256 tokenAmount, bytes32 nonce, bytes memory signature) external onlyCurrentPhase(Phase.BUY) {

		require(this.getUsdAmount(tokenAmount) >= minUsdAmount, "CatchTokenPresale: Below min amount");

		bytes32 digest = _hashTypedDataV4(

			keccak256(abi.encode(keccak256("BuyWithUsdtNftHolder(bytes32 nonce)"), nonce))

		);

		address recoveredSigner = ECDSA.recover(digest, signature);

		require(hasRole(SIGNER_ROLE, recoveredSigner), "CatchTokenPresale: Invalid signature");

		require(!usedNonces[nonce], "CatchTokenPresale: Nonce already used");

		usedNonces[nonce] = true;

		_buyWithUsdt(tokenAmount, true);

	}



	function availableTGETokensToClaim(address user) public view returns (uint256) {

		if (currentPhase != Phase.CLAIM) {

			return 0;

		}



		return totalTGETokensByUser[user] - claimedTGETokensByUser[user];

	}



	function availableVestingTokensToClaim(address user) public view returns (uint256) {

		if (currentPhase != Phase.CLAIM) {

			return 0;

		}



		uint256 vestingDays = (vestingEndDate - vestingStartDate) / 1 days;

		uint256 tokensPerDay = totalVestingTokensByUser[user] / vestingDays;

		uint256 daysSinceVestingStart = block.timestamp > vestingStartDate

			? (block.timestamp - vestingStartDate) / 1 days

			: 0;

		return (daysSinceVestingStart * tokensPerDay) - claimedVestingTokensByUser[user];

	}



	function claimTGETokens() external {

		uint256 tokenAmount = availableTGETokensToClaim(msg.sender);

		claimedTGETokensByUser[msg.sender] = tokenAmount;

		catchToken.transfer(msg.sender, tokenAmount);

		emit ClaimedTGE(msg.sender, tokenAmount);

	}



	function claimVestingTokens() external {

		uint256 tokenAmount = availableVestingTokensToClaim(msg.sender);

		claimedVestingTokensByUser[msg.sender] += tokenAmount;

		catchToken.transfer(msg.sender, tokenAmount);

		emit ClaimedVesting(msg.sender, tokenAmount);

	}



	function calculateEthAmountRequired(uint256 tokenAmount, bool isNftHolder) external view returns (uint256) {

		uint256 usdAmount = this.tokenAmountToUsdAmount(tokenAmount, isNftHolder);

		(,int256 ethUsdPrice,,,) = priceFeed.latestRoundData();

		uint256 ethAmount = (usdAmount * 1e18) / uint256(ethUsdPrice);

		return ethAmount;

	}



	function calculateUsdtAmountRequired(uint256 tokenAmount, bool isNftHolder) external view returns (uint256) {

		uint256 usdAmount = this.tokenAmountToUsdAmount(tokenAmount, isNftHolder);

		uint256 usdtAmount = usdAmount / 1e2;

		return usdtAmount;

	}



	function calculateTokenAmountByEth(uint256 ethAmount, bool isNftHolder) public view returns (uint256) {

		(,int256 ethUsdPrice,,,) = priceFeed.latestRoundData();

		uint256 usdAmount = (ethAmount * uint256(ethUsdPrice)) / 1e18;

		uint256 tokenAmount = this.usdAmountToTokenAmount(usdAmount, isNftHolder);

		return tokenAmount;

	}



	function calculateTokenAmountByUsdt(uint256 usdtAmount, bool isNftHolder) public view returns (uint256) {

		uint256 usdAmount = usdtAmount * 1e2;

		uint256 tokenAmount = this.usdAmountToTokenAmount(usdAmount, isNftHolder);

		return tokenAmount;

	}



	function usdAmountToTokenAmount(uint256 usdAmount, bool isNftHolder) external view returns (uint256) {

		uint256 volumeDiscount = getVolumeDiscount(usdAmount);

		uint256 discountedTokenPriceUsd = (tokenPriceUsd * (100 - volumeDiscount)) / 100;



		if (isNftHolder) {

			discountedTokenPriceUsd = (discountedTokenPriceUsd * (100 - nftHolderDiscountPercent)) / 100;

		}



		uint256 tokenAmount = (usdAmount * 1e18) / discountedTokenPriceUsd;

		return tokenAmount;

	}



	function tokenAmountToUsdAmount(uint256 tokenAmount, bool isNftHolder) external view returns (uint256) {

		uint256 usdAmountBeforeDiscount = (tokenAmount * tokenPriceUsd) / 1e18;

		uint256 volumeDiscount = getVolumeDiscount(usdAmountBeforeDiscount);

		uint256 discountedUsdAmount = (usdAmountBeforeDiscount * (100 - volumeDiscount)) / 100;



		if (isNftHolder) {

			discountedUsdAmount = (discountedUsdAmount * (100 - nftHolderDiscountPercent)) / 100;

		}



		return discountedUsdAmount;

	}



	function startBuyPhase() external onlyCurrentPhase(Phase.INIT) onlyRole(DEFAULT_ADMIN_ROLE) {

		require(catchToken.balanceOf(address(this)) >= presaleSupply, "CatchTokenPresale: Not enough supply. Send first.");

		_changeCurrentPhase(Phase.BUY);

	}



	function startClaimPhase() external onlyCurrentPhase(Phase.BUY) onlyRole(DEFAULT_ADMIN_ROLE) {

		_changeCurrentPhase(Phase.CLAIM);

		vestingStartDate = block.timestamp + (uint256(cliffMonths) * (30 days));

		vestingEndDate = vestingStartDate + (uint256(linearVestingMonths) * (30 days));

	}



	function _buyWithEth(uint256 tokenAmount, bool isNftHolder) internal {

		uint256 currentBalance = catchToken.balanceOf(address(this));

		if (tokenAmount >= currentBalance) {

			tokenAmount = currentBalance;

		}



		uint256 ethAmountRequired = this.calculateEthAmountRequired(tokenAmount, isNftHolder);

		require(msg.value >= ethAmountRequired, "CatchTokenPresale: Insufficient value");



		totalTokensBought += tokenAmount;



		uint256 TGEAmount = (tokenAmount / 100) * unlockPercentAtTGE;

		totalTGETokensByUser[msg.sender] += TGEAmount;

		totalVestingTokensByUser[msg.sender] += tokenAmount - TGEAmount;

		emit Bought(msg.sender, tokenAmount);



		if (msg.value > ethAmountRequired) {

			// return overpaid ETH back to the sender

			uint256 overpaid = msg.value - ethAmountRequired;

			payable(msg.sender).transfer(overpaid);

		}



		buyRecipient.transfer(ethAmountRequired);

	}



	function _buyWithUsdt(uint256 tokenAmount, bool isNftHolder) internal {

		uint256 currentBalance = catchToken.balanceOf(address(this));

		if (tokenAmount >= currentBalance) {

			tokenAmount = currentBalance;

		}



		totalTokensBought += tokenAmount;

		uint256 usdtAmountRequired = this.calculateUsdtAmountRequired(tokenAmount, isNftHolder);



		(bool success, ) = address(usdt).call(

			abi.encodeWithSignature(

				"transferFrom(address,address,uint256)",

				msg.sender,

				buyRecipient,

				usdtAmountRequired

			)

		);

		require(success, "CatchTokenPresale: Could not transfer usdt");



		uint256 TGEAmount = (tokenAmount / 100) * unlockPercentAtTGE;

		totalTGETokensByUser[msg.sender] += TGEAmount;

		totalVestingTokensByUser[msg.sender] += tokenAmount - TGEAmount;

		emit Bought(msg.sender, tokenAmount);

	}



	function getUsdAmount(uint256 tokenAmount) external view returns (uint256) {

		return (tokenAmount * tokenPriceUsd) / 1e18;

	}



	function getVolumeDiscount(uint256 amountInUsd) internal pure returns (uint256) {

		if (amountInUsd >= 5001 * 1e8) {

			return 12;

		} else if (amountInUsd >= 3001 * 1e8) {

			return 7;

		} else if (amountInUsd >= 1501 * 1e8) {

			return 5;

		} else if (amountInUsd >= 500 * 1e8) {

			return 3;

		}



		return 0;

	}



	function _changeCurrentPhase(Phase _phase) internal {

		currentPhase = _phase;

		emit PhaseChanged(_phase);

	}

}