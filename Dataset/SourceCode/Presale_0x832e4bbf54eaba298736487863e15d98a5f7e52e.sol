// Sources flattened with hardhat v2.17.0 https://hardhat.org



// File @openzeppelin/contracts/access/IAccessControl.sol@v4.9.3





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





// File @openzeppelin/contracts/utils/Context.sol@v4.9.3



// SPDX-License-Identifier: MIT

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





// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.9.3





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





// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.9.3





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





// File @openzeppelin/contracts/utils/math/Math.sol@v4.9.3





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





// File @openzeppelin/contracts/utils/math/SignedMath.sol@v4.9.3





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





// File @openzeppelin/contracts/utils/Strings.sol@v4.9.3





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





// File @openzeppelin/contracts/access/AccessControl.sol@v4.9.3





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





// File @openzeppelin/contracts/access/Ownable.sol@v4.9.3





// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)



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

     * `onlyOwner` functions. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby disabling any functionality that is only available to the owner.

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





// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3





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





// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.9.3





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





// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.9.3





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





// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v4.9.3





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)



pragma solidity ^0.8.0;



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





// File @openzeppelin/contracts/utils/Address.sol@v4.9.3





// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)



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

     *

     * Furthermore, `isContract` will also return true if the target contract within

     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,

     * which only has an effect at the end of a transaction.

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

     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].

     *

     * IMPORTANT: because control is transferred to `recipient`, care must be

     * taken to not create reentrancy vulnerabilities. Consider using

     * {ReentrancyGuard} or the

     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].

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

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

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





// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.9.3





// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)



pragma solidity ^0.8.0;







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



    /**

     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,

     * non-reverting calls are assumed to be successful.

     */

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    /**

     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the

     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.

     */

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    /**

     * @dev Deprecated. This function has issues similar to the ones found in

     * {IERC20-approve}, and its usage is discouraged.

     *

     * Whenever possible, use {safeIncreaseAllowance} and

     * {safeDecreaseAllowance} instead.

     */

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require(

            (value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    /**

     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,

     * non-reverting calls are assumed to be successful.

     */

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 oldAllowance = token.allowance(address(this), spender);

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));

    }



    /**

     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,

     * non-reverting calls are assumed to be successful.

     */

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {

            uint256 oldAllowance = token.allowance(address(this), spender);

            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");

            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));

        }

    }



    /**

     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,

     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval

     * to be set to zero before setting it to a non-zero value, such as USDT.

     */

    function forceApprove(IERC20 token, address spender, uint256 value) internal {

        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);



        if (!_callOptionalReturnBool(token, approvalCall)) {

            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));

            _callOptionalReturn(token, approvalCall);

        }

    }



    /**

     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.

     * Revert on invalid signature.

     */

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

        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     *

     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.

     */

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false

        // and not revert is the subcall reverts.



        (bool success, bytes memory returndata) = address(token).call(data);

        return

            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));

    }

}





// File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.9.3





// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)



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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a % b;

        }

    }

}





// File contracts/wBAI.sol







/*





██████╗  █████╗ ██╗      █████╗ ███╗   ██╗ ██████╗███████╗     █████╗ ██╗    

██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝██╔════╝    ██╔══██╗██║    

██████╔╝███████║██║     ███████║██╔██╗ ██║██║     █████╗      ███████║██║    

██╔══██╗██╔══██║██║     ██╔══██║██║╚██╗██║██║     ██╔══╝      ██╔══██║██║    

██████╔╝██║  ██║███████╗██║  ██║██║ ╚████║╚██████╗███████╗    ██║  ██║██║    

╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝    ╚═╝  ╚═╝╚═╝    

                                                                             

WWW: https://www.balancedao.io/

Twitter: https://twitter.com/Balance_AI

Telegram: https://t.me/Balance_AI

Discord: https://discord.gg/PgPkJPqXGG

Medium: https://balancedao.medium.com/





*/



pragma solidity ^0.8.19;











// Uncomment this line to use console.log

// import "hardhat/console.sol";



contract wBAI is ERC20, Ownable, AccessControl {

    using SafeMath for uint256;



    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");



    uint256 public BALANCE_FEE = 123000321; // 0.123 wBAI



    uint256 public _nonce = 0;



    uint256 public cumulative_bridged = 0;

    uint256 public cumulative_bridged_back = 0;



    bool public bridge_back_active = false;



    event Mint(address indexed to, uint256 amount);

    event BridgedTo(string from, address indexed to, uint256 amount, uint256 nonce);

    event BridgedBack(address indexed from, uint256 amount, string to, uint256 nonce);

    event BridgeSet(address indexed bridge);

    event BridgeBackEnabled();

    



    constructor() ERC20("Wrapped Balance AI", "wBAI") {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    }



    function decimals() public view virtual override returns (uint8) {

        return 9;

    }



    function setBridge(address _bridge) external onlyOwner returns(bool) {

        _setupRole(BRIDGE_ROLE, _bridge);

        emit BridgeSet(_bridge);

        return true;

    }



    function enableBridgeBack() external onlyOwner returns(bool) {

        bridge_back_active = true;

        emit BridgeBackEnabled();

        return true;

    }



    function adjustFee(uint256 _fee) external onlyOwner returns(bool) {

        require(_fee < 123000321, "Fee can not be higher then initial setup.");

        BALANCE_FEE = _fee;

        return true;

    }



    function bridgedTo(string[] memory _froms, address[] memory _tos, uint256[] memory _amounts) public returns(bool) {

        require(hasRole(BRIDGE_ROLE, _msgSender()), "Caller is not the bridge");

        // require all arrays are the same length

        require(_froms.length == _tos.length && _froms.length == _amounts.length, "Arrays are not the same length");

        // loop through arrays and mint

        for (uint256 i = 0; i < _froms.length; i++) {

            _mint(_tos[i], _amounts[i]);

            cumulative_bridged = cumulative_bridged.add(_amounts[i]);

            emit BridgedTo(_froms[i], _tos[i], _amounts[i], _nonce);

            _nonce++;

        }

        return true;

    }



    function bridgeBack(uint256 _amount, string memory _to) public returns(bool) {

        require(bridge_back_active, "Bridge back is not active yet.");

        require(_amount <= balanceOf(_msgSender()), "Not enough balance");

        // require greater than 0.123000321 wBAI for gas purposes.

        require(_amount > BALANCE_FEE, "Does not meet minimum amount for gas (0.123000321 wBAI)");

        _burn(msg.sender, _amount);

        _nonce++;

        cumulative_bridged_back = cumulative_bridged_back.add(_amount);

        emit BridgedBack(_msgSender(), _amount, _to, _nonce);

        return true;

    }



    function deployer() public view returns (address) {

        return owner();

    }



    // reclaim stuck sent tokens

    function reclaimToken(address _token) public onlyOwner {

        ERC20 token = ERC20(_token);

        uint256 balance = token.balanceOf(address(this));

        token.transfer(owner(), balance);

        payable(owner()).transfer(address(this).balance);

    }







}





// File contracts/balance_seed.sol





pragma solidity ^0.8.0;











contract Presale is Ownable {

  using SafeMath for uint256;

  using SafeERC20 for ERC20;



  // ERC20 tokens

  ERC20 public wbai;

  ERC20 public usd;



  // Structure of each vest

  struct Vest {

    uint256 amount; // the amount of WOTB the beneficiary will recieve

    uint256 released; // the amount of WOTB released to the beneficiary

    bool usdTransferred; // whether the beneficiary has transferred the eth into the contract

  }



  // All vested tokens in the contract

  uint256 public allVestedAmount;



  // The mapping of vested beneficiary (beneficiary address => Vest)

  mapping(address => Vest) public vestedBeneficiaries;



  // beneficiary => usd deposited

  mapping(address => uint256) public usdDeposits;



  // Array of beneficiaries

  address[] public beneficiaries;



  // No. of beneficiaries

  uint256 public noOfBeneficiaries;



  // Whether the contract has been bootstrapped with the WOTB

  bool public bootstrapped;



  // Start time of the the vesting

  uint256 public startTime = 0;



  // The duration of the vesting

  uint256 public duration;



  // Price of each OTB token in usd (1e8 precision)

  uint256 public otbPrice;







  constructor(uint256 _otbPrice) {

    require(_otbPrice > 0, 'OTB price has to be higher than 0');



    otbPrice = _otbPrice;

    

  }



  /*---- EXTERNAL FUNCTIONS FOR OWNER ----*/



  /**

   * @notice Bootstraps the presale contract 

   * @param _duration duration in seconds of the period in which the tokens will vest

   * @param _otbAddress address of wBAI erc20 token

   * @param _stableAddress addres of usd stable

   */

  function bootstrap(

    uint256 _duration,

    address _otbAddress, 

    address _stableAddress

  ) external onlyOwner returns (bool) {

    require(!bootstrapped, 'Already bootstrapped');

    require(_otbAddress != address(0), 'OTB address is 0');

    require(_duration > 0, 'Duration passed cannot be 0');

    

    duration = _duration;



    wbai = wBAI(_otbAddress);

    usd = ERC20(_stableAddress);



    uint256 totalOTBRequired;



    for (uint256 i = 0; i < beneficiaries.length; i = i + 1) {

        totalOTBRequired = totalOTBRequired.add(vestedBeneficiaries[beneficiaries[i]].amount);

    }



    require(totalOTBRequired > 0, 'Total OTB required cannot be 0');



    wbai.safeTransferFrom(msg.sender, address(this), totalOTBRequired*10**wbai.decimals()); 



    bootstrapped = true;



    emit Bootstrap(totalOTBRequired);



    return bootstrapped;

  }



  /**

  * @notice Sets the vesting start. Only owner can call this.

  * @param _startTime the time (as Unix time) at which point vesting starts

  */



  function setStartTime(uint256 _startTime) public onlyOwner returns (bool) {

    require(startTime == 0, "Start time already set.");

    require(_startTime >= block.timestamp, 'Start time cannot be before current time');

    startTime = _startTime;



    emit Start(_startTime);



    return true;

  }



  /**

   * @notice Adds a beneficiary to the contract. Only owner can call this.

   * @param _beneficiary the address of the beneficiary

   * @param _amount amount of OTB to be vested for the beneficiary

   */

  function addBeneficiary(address _beneficiary, uint256 _amount) public onlyOwner returns (bool) {

    require(_beneficiary != address(0), 'Beneficiary cannot be a 0 address');

    require(_amount > 0, 'Amount should be larger than 0');

    require(!bootstrapped, 'Cannot add beneficiary as contract has been bootstrapped');

    require(vestedBeneficiaries[_beneficiary].amount == 0, 'Cannot add the same beneficiary again');



    beneficiaries.push(_beneficiary);



    vestedBeneficiaries[_beneficiary].amount = _amount;



    allVestedAmount = allVestedAmount + _amount;



    noOfBeneficiaries = noOfBeneficiaries.add(1);



    emit AddBeneficiary(_beneficiary, _amount);



    return true;

  }



  /**

   * @notice Updates beneficiary amount. Only owner can call this.

   * @param _beneficiary the address of the beneficiary

   * @param _amount amount of OTB to be vested for the beneficiary

   */

  function updateBeneficiary(address _beneficiary, uint256 _amount) external onlyOwner {

    require(_beneficiary != address(0), 'Beneficiary cannot be a 0 address');

    require(!bootstrapped, 'Cannot update beneficiary as contract has been bootstrapped');

    require(

      vestedBeneficiaries[_beneficiary].amount != _amount,

      'New amount cannot be the same as old amount'

    );

    require(

      !vestedBeneficiaries[_beneficiary].usdTransferred,

      'Beneficiary should have not transferred USD'

    );

    require(_amount > 0, 'Amount cannot be smaller or equal to 0');

    require(vestedBeneficiaries[_beneficiary].amount != 0, 'Beneficiary has not been added');



    vestedBeneficiaries[_beneficiary].amount = _amount;



    emit UpdateBeneficiary(_beneficiary, _amount);

  }



  /**

   * @notice Removes a beneficiary from the contract. Only owner can call this.

   * @param _beneficiary the address of the beneficiary

   * @return whether beneficiary was deleted

   */

  function removeBeneficiary(address payable _beneficiary) external onlyOwner returns (bool) {

    require(_beneficiary != address(0), 'Beneficiary cannot be a 0 address');

    require(!bootstrapped, 'Cannot remove beneficiary as contract has been bootstrapped');

    if (vestedBeneficiaries[_beneficiary].usdTransferred) {

      _beneficiary.transfer(usdDeposits[_beneficiary]);

    }

    for (uint256 i = 0; i < beneficiaries.length; i = i + 1) {

      if (beneficiaries[i] == _beneficiary) {

        noOfBeneficiaries = noOfBeneficiaries.sub(1);



        delete beneficiaries[i];

        delete vestedBeneficiaries[_beneficiary];



        emit RemoveBeneficiary(_beneficiary);



        return true;

      }

    }

    return false;

  }



  /**

   * @notice Withdraws USD tokens deposited into the contract. Only owner can call this.

   */

  function withdraw() external onlyOwner {

    uint256 usdBalance = usd.balanceOf(address(this));

    usd.safeTransfer(msg.sender, usdBalance);

    



    emit WithdrawUsd(usdBalance);

  }



  /*---- EXTERNAL FUNCTIONS ----*/



  /**

   * @notice Transfers usd from beneficiary to the contract.

   */

  function transferUsd() external  {

    require(

      !vestedBeneficiaries[msg.sender].usdTransferred,

      'Beneficiary has already transferred USD'

    );

    require(vestedBeneficiaries[msg.sender].amount > 0, 'Sender is not a beneficiary');



    uint256 usdAmount = vestedBeneficiaries[msg.sender].amount.mul(otbPrice);



    usd.safeTransferFrom(msg.sender, address(this), usdAmount);



    usdDeposits[msg.sender] = usdAmount;



    vestedBeneficiaries[msg.sender].usdTransferred = true;



    emit TransferredUsd(msg.sender, usdAmount);

  }



  /**

   * @notice Transfers vested tokens to beneficiary.

   */

  function release() external returns (uint256 unreleased) {

    require(bootstrapped, 'Contract has not been bootstrapped');

    require(startTime > 0, 'Start time is not set yet');

    require(vestedBeneficiaries[msg.sender].usdTransferred, 'Beneficiary has not transferred funds');

    unreleased = releasableAmount(msg.sender);



    require(unreleased > 0, 'No releasable amount');



    vestedBeneficiaries[msg.sender].released = vestedBeneficiaries[msg.sender].released.add(

      unreleased

    );



    wbai.transfer(msg.sender, unreleased*10**wbai.decimals()); 



    emit TokensReleased(msg.sender, unreleased);

  }



  /*---- VIEWS ----*/

  /**

   * @notice Calculates the amount to invest in USD.

   * @param beneficiary address of the beneficiary

   */

  function investmentAmount(address beneficiary) public view returns (uint256) {

    return vestedBeneficiaries[beneficiary].amount.mul(otbPrice);

  }



  /**

   * @notice Calculates the amount that has already vested but hasn't been released yet.

   * @param beneficiary address of the beneficiary

   */

  function releasableAmount(address beneficiary) public view returns (uint256) {

    return vestedAmount(beneficiary).sub(vestedBeneficiaries[beneficiary].released);

  }



  /**

   * @notice Calculates the amount that has already vested.

   * @param beneficiary address of the beneficiary

   */

  function vestedAmount(address beneficiary) public view returns (uint256) {

    uint256 totalBalance = vestedBeneficiaries[beneficiary].amount;



    if (block.timestamp < startTime || startTime == 0) {

      return 0;

    } else if (block.timestamp >= startTime.add(duration)) {

      return totalBalance;

    } else {

      uint256 imidiateBalance = totalBalance.div(3);

      return

      totalBalance.sub(imidiateBalance).mul(block.timestamp.sub(startTime)).div(duration).add(imidiateBalance);

    }

  }







  /*---- EVENTS ----*/



  event TokensReleased(address beneficiary, uint256 amount);



  event AddBeneficiary(address beneficiary, uint256 amount);



  event RemoveBeneficiary(address beneficiary);



  event UpdateBeneficiary(address beneficiary, uint256 amount);



  event TransferredUsd(address beneficiary, uint256 usdAmount);



  event WithdrawUsd(uint256 amount);



  event Bootstrap(uint256 totalOTBRequired);



  event Start(uint256 timestamp);

}