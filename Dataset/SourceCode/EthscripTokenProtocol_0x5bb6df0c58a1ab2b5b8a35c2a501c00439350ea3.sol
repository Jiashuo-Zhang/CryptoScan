// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;





// File: @openzeppelin/contracts/utils/math/Math.sol



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



// File: @openzeppelin/contracts/utils/Strings.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)





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



// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)





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



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





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



// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol





// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)





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



// File: @openzeppelin/contracts/security/ReentrancyGuard.sol





// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)



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



// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol





// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)



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

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        return processProof(proof, leaf) == root;

    }



    /**

     * @dev Calldata version of {verify}

     *

     * _Available since v4.7._

     */

    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

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

        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 proofLen = proof.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])

                : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            require(proofPos == proofLen, "MerkleProof: invalid multiproof");

            unchecked {

                return hashes[totalHashes - 1];

            }

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

        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by

        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the

        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of

        // the merkle tree.

        uint256 leavesLen = leaves.length;

        uint256 proofLen = proof.length;

        uint256 totalHashes = proofFlags.length;



        // Check proof validity.

        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");



        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using

        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".

        bytes32[] memory hashes = new bytes32[](totalHashes);

        uint256 leafPos = 0;

        uint256 hashPos = 0;

        uint256 proofPos = 0;

        // At each step, we compute the next hash using two values:

        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we

        //   get the next hash.

        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the

        //   `proof` array.

        for (uint256 i = 0; i < totalHashes; i++) {

            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])

                : proof[proofPos++];

            hashes[i] = _hashPair(a, b);

        }



        if (totalHashes > 0) {

            require(proofPos == proofLen, "MerkleProof: invalid multiproof");

            unchecked {

                return hashes[totalHashes - 1];

            }

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



// File: @openzeppelin/contracts/utils/Context.sol





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



// File: @openzeppelin/contracts/token/ERC20/ERC20.sol





// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)



/**

 * @dev Implementation of the {IERC20} interface.

 *

 * This implementation is agnostic to the way tokens are created. This means

 * that a supply mechanism has to be added in a derived contract using {_mint}.

 * For a generic mechanism see {ERC20PresetMinterPauser}.

 *

 * TIP: For a detailed writeup see our guide

 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How

 * to implement supply mechanisms].

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

     * The default value of {decimals} is 18. To select a different value for

     * {decimals} you should overload it.

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

     * Ether and Wei. This is the value {ERC20} uses, unless this function is

     * overridden;

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

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) public virtual override returns (bool) {

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

    function _transfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(from, to, amount);



        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {

            _balances[from] = fromBalance - amount;

        }

        _balances[to] += amount;



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

        _balances[account] += amount;

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

        }

        _totalSupply -= amount;



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

    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) internal virtual {

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

    function _spendAllowance(

        address owner,

        address spender,

        uint256 amount

    ) internal virtual {

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

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}



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

    function _afterTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}

}



// File: @openzeppelin/contracts/access/Ownable.sol





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

abstract contract EthscripOwnable is Context {

    address private _owner;



    bytes32 internal merkleRoot_og;

    address payable internal receiver;

    uint256 internal protocel_fee;

    address internal authorized_signer;

    bool internal isEnable_x_to_y;



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



    function setReceiver(address payable _rec)external onlyOwner {

        receiver = _rec;

    }



    function setProtocel_fee(uint256 _fee)external onlyOwner {

        protocel_fee = _fee;

    }



    function setMerkleRoot_og(bytes32 _mRoot_og)external onlyOwner {

        merkleRoot_og = _mRoot_og;

    }



    function setAuthorized_signer(address _authorized_signer)external onlyOwner {

        authorized_signer = _authorized_signer;

    }



    function setEnable_x_to_y(bool _isEnable)external onlyOwner {

        isEnable_x_to_y = _isEnable;

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

abstract contract TokenOwnable is Context {

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

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyEthscripOwner() {

        _checkOwner();

        _;

    }



            /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyTokenOwner() {

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



contract Ethscrip_Token is TokenOwnable, ReentrancyGuard, ERC20{



    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}



    /*

        EthscripTokenProtocol processing. Only holders of ethscrip have permission to operate.

            Splitting is based on Ethscriptions, such as Eths ethscriptions. 

            There are a total of 21,000 valid ethscriptions, with each ethscriptions corresponding to 1,000 tokens. 

            The maximum number of tokens that can be split is 21,000,000.

        EthscripTokenProtocol will automatically handle the inflow of assets.

    */

    function mint(address account, uint256 amount) public onlyEthscripOwner nonReentrant{

        _mint(account, amount);

    }



    

    /*

        EthscripTokenProtocol processing. Only holders of token have permission to operate.

            EthscripTokenProtocol supports reverse operations of assets.

            ethscrip -> token; token -> ethscrip;

            The Principle of Inverse Operation:

                1 ethscrip = x token;

                x token = 1 ethscrip;

        EthscripTokenProtocol will automatically handle the outflow of assets.

    */

    function burn(address account, uint256 amount) public onlyTokenOwner nonReentrant{

        _burn(account, amount);

    }

}





contract EthscripTokenProtocol is EthscripOwnable, ReentrancyGuard{



    enum EthscripState { Enter, Signed, Withdraw }



    struct Ethscription{

        address owner;

        bytes32 e_id;

        bool isSplit;

        EthscripState state;

    }

    mapping(bytes32 => Ethscription) public ethscriptions;



    struct EthscripToken {

        string name;

        uint256 eTotal;

        uint256 tAmount;

        address cAddress;

    }

    mapping(bytes32 => EthscripToken) public ethscripTokens;



    event EthscripCategory(bytes32 indexed _mRoot, string _name, uint256 _eTotal, uint256 _tAmount);



    event EthscripInitializes(address indexed owner, bytes32 indexed _e_id, bool state, EthscripState e_state, address indexed e_sender);

    event EthscripSign(address indexed owner, bytes32 indexed _e_id, bool state, EthscripState e_state);

    event EthscripToToken(address indexed owner, bytes32 _e_id, bool state, bytes32 indexed root, address indexed c_address); 

    event TokenToEthscrip(address indexed owner, bytes32 indexed _e_id, bool state, EthscripState e_state); 

    event EthscripWithdrawn(address indexed owner, bytes32 indexed _e_id, bool state , EthscripState e_state);



    event ethscriptions_protocol_TransferEthscription(address indexed recipient,bytes32 indexed ethscriptionId);

    event ethscriptions_protocol_TransferEthscriptionForPreviousOwner(

        address indexed previousOwner,

        address indexed recipient,

        bytes32 indexed ethscriptionId

    );



    constructor(address payable _receiver, address _authorized_signer,bytes32 _merkleRoot_og) {

        receiver = _receiver;

        protocel_fee = 0.005 ether;

        merkleRoot_og = _merkleRoot_og;

        authorized_signer = _authorized_signer;

        isEnable_x_to_y = false;

    }



    function ethscripInitializes(bytes32 _e_id) private nonReentrant{

        require(ethscriptions[_e_id].owner == address(0), "Error: Order already exists");

        Ethscription memory newEthscrip = Ethscription(address(0), _e_id, false, EthscripState.Enter);

        ethscriptions[_e_id] = newEthscrip;



        emit EthscripInitializes(address(0), _e_id, false, EthscripState.Enter, msg.sender);

    }



    /*

        Once the rules take effect, the administrator does not have the permission to modify them.

    */

    function ethscripCategory(bytes32 _mRoot, string memory _name, uint256 _eTotal, uint256 _tAmount)external onlyOwner {

        require(ethscripTokens[_mRoot].cAddress == address(0x0),"Error: Executed in a decentralized manner, no longer supports modifications ");



        ethscripTokens[_mRoot] = EthscripToken({

            name: _name,

            eTotal: _eTotal,

            tAmount: _tAmount,

            cAddress: ethscripTokens[_mRoot].cAddress

        });



        emit EthscripCategory(_mRoot, _name, _eTotal, _tAmount);

    }



    function getEthscripHash(address _address, bytes32 _e_id, string memory _nonce) internal pure returns (bytes32) {

        bytes32 message = keccak256(abi.encodePacked(_address, _e_id, _nonce));

        bytes32 ethSignedMessage = ECDSA.toEthSignedMessageHash(message);

        return ethSignedMessage;

    }



    function ethscripSign(address _from, bytes32 _e_id , string memory _nonce, bytes memory _signature)external nonReentrant {

        require(ethscriptions[_e_id].e_id == _e_id, "Error: No exist ");

        require(ethscriptions[_e_id].owner == address(0x0), "Error: owner exist ");



        bytes32 messageHash = getEthscripHash(_from, _e_id, _nonce);

        address signer = ECDSA.recover(messageHash, _signature);

        require(signer == authorized_signer,"Error: invalid signature");

        require(msg.sender == _from, "Error: No permissions");



        ethscriptions[_e_id].owner = _from;

        ethscriptions[_e_id].state = EthscripState.Signed;



        emit EthscripSign(_from, _e_id, false, EthscripState.Signed);

    }



    function ethscripToToken(bytes32 _e_id, bytes32[] calldata _merkleProof, bytes32 _root, bytes32[] calldata _merkleProof_og)external payable nonReentrant{

        require(ethscriptions[_e_id].owner == msg.sender, "Error: No permissions");

        require(MerkleProof.verify(_merkleProof, _root, _e_id) == true , "Error: Parameter error ");

        require(ethscripTokens[_root].eTotal != 0,"Error: Data error ");

        require(ethscriptions[_e_id].isSplit == false,"Error: The balance is insufficient ");

        uint256 protocel_fee_result = MerkleProof.verify(_merkleProof_og, merkleRoot_og, toBytes32(msg.sender)) == true ? (protocel_fee * 70 / 100) : (protocel_fee);

        require(msg.value >= protocel_fee_result, "Incorrect payment amount");

        receiver.transfer(msg.value);



        if(ethscripTokens[_root].cAddress == address(0x0)){

            Ethscrip_Token cToken = new Ethscrip_Token(ethscripTokens[_root].name,ethscripTokens[_root].name);

            ethscripTokens[_root].cAddress = address(cToken);

            cToken.mint(msg.sender, ethscripTokens[_root].tAmount);

            ethscriptions[_e_id].isSplit = true;

        }else{

            Ethscrip_Token cToken = Ethscrip_Token(ethscripTokens[_root].cAddress);

            cToken.mint(msg.sender, ethscripTokens[_root].tAmount);

            ethscriptions[_e_id].isSplit = true;

        }



        emit EthscripToToken(msg.sender, _e_id, true, _root, ethscripTokens[_root].cAddress);

    }





    function tokenToEthscrip(bytes32 _e_id, bytes32[] calldata _merkleProof, bytes32 _root, bytes32[] calldata _merkleProof_og )external payable nonReentrant{

            require(ethscriptions[_e_id].owner != address(0x0), "Error: No exist ");

            require(MerkleProof.verify(_merkleProof, _root, _e_id) == true , "Error: Parameter error ");

            require(ethscripTokens[_root].eTotal != 0,"Error: Data error ");

            require(ethscriptions[_e_id].isSplit == true,"Error: State error .");

             uint256 protocel_fee_result = MerkleProof.verify(_merkleProof_og, merkleRoot_og, toBytes32(msg.sender)) == true ? (protocel_fee * 70 / 100) : (protocel_fee);

            require(msg.value >= protocel_fee_result, "Incorrect payment amount");

            receiver.transfer(msg.value);



            Ethscrip_Token eToken = Ethscrip_Token(ethscripTokens[_root].cAddress);

            uint256 approveAmount = eToken.allowance(msg.sender,address(this));

            require(approveAmount >= ethscripTokens[_root].tAmount,"Error: approve error ");

            require(eToken.balanceOf(msg.sender) >= ethscripTokens[_root].tAmount,"Error: insufficient balance ");



            eToken.burn(msg.sender,ethscripTokens[_root].tAmount);



            ethscriptions[_e_id].isSplit = false;



            if(isEnable_x_to_y){

                emit ethscriptions_protocol_TransferEthscriptionForPreviousOwner(ethscriptions[_e_id].owner, msg.sender, _e_id);

            }else{

                emit ethscriptions_protocol_TransferEthscription(msg.sender,_e_id);

            }



            ethscriptions[_e_id].owner = address(0x0);



            emit TokenToEthscrip(address(0x0), _e_id, false,EthscripState.Withdraw);

    }



    function withdrawn(bytes32 _e_id) public nonReentrant{

        require(ethscriptions[_e_id].owner == msg.sender, "Error: No permissions");

        require(ethscriptions[_e_id].isSplit == false,"Error: State error .");



        if(isEnable_x_to_y){

            emit ethscriptions_protocol_TransferEthscriptionForPreviousOwner(ethscriptions[_e_id].owner, msg.sender, _e_id);

        }else{

            emit ethscriptions_protocol_TransferEthscription(msg.sender, _e_id);

        }



        ethscriptions[_e_id].owner = address(0x0);

        

        emit EthscripWithdrawn(address(0x0), _e_id, false, EthscripState.Withdraw);

    }



    function toBytes32(address addr) pure internal returns (bytes32) {

        return bytes32(uint256(uint160(addr)));

    }



    fallback() external {

        bytes memory data = msg.data;

        if(data.length >= 32){

            bytes32 result;

            assembly {

                result := mload(add(data, 32))

            }

            ethscripInitializes(result);   

        }

    }



}