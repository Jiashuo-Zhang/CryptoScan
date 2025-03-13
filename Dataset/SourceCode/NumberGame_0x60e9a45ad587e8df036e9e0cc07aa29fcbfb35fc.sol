// SPDX-License-Identifier: MIT



/*



Telegram - https://t.me/the_number_game 

Twitter - https://twitter.com/numberscoin

Website - https://numberscoin.info



    _______ _            _   _                 _                  _____                      

   |__   __| |          | \ | |               | |                / ____|                     

      | |  | |__   ___  |  \| |_   _ _ __ ___ | |__   ___ _ __  | |  __  __ _ _ __ ___   ___ 

      | |  | '_ \ / _ \ | . ` | | | | '_ ` _ \| '_ \ / _ \ '__| | | |_ |/ _` | '_ ` _ \ / _ \

      | |  | | | |  __/ | |\  | |_| | | | | | | |_) |  __/ |    | |__| | (_| | | | | | |  __/

      |_|  |_| |_|\___| |_| \_|\__,_|_| |_| |_|_.__/ \___|_|     \_____|\__,_|_| |_| |_|\___|



Welcome to The Number Game. Here are the rules:



▶ There are 10 levels. Each level gets 10x harder to guess the number correctly than the last.

  For example, on level 1 the chances of guessing correctly are 1/10.

  On level 2 the chances of guessing correctly are 1/100.

  On level 3 the chances of guessing correctly are 1/1000.

  And so on...



▶ Anyone can guess a number using the guessNumber() function. 

  Each player's guesses are unique to their public address, so MEV is not an issue.



▶ If a player guesses the number correctly, the player will be able to successfully claim 1% of the total supply of tokens.

  The game will then proceed to the next level each time a prize is claimed until the game is over after level 10.



▶ Finally, in order to claim the prize a player must own at least 0.1% of the total supply.



Good luck!



*/



pragma solidity ^0.8.21;



interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);



    function feeTo() external view returns (address);



    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);



    function allPairs(uint256) external view returns (address pair);



    function allPairsLength() external view returns (uint256);



    function createPair(address tokenA, address tokenB) external returns (address pair);



    function setFeeTo(address) external;



    function setFeeToSetter(address) external;

}



pragma solidity ^0.8.21;



interface IUniswapV2Router02 {

    function factory() external pure returns (address);



    function WETH() external pure returns (address);



    function addLiquidity(

        address tokenA,

        address tokenB,

        uint256 amountADesired,

        uint256 amountBDesired,

        uint256 amountAMin,

        uint256 amountBMin,

        address to,

        uint256 deadline

    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);



    function addLiquidityETH(

        address token,

        uint256 amountTokenDesired,

        uint256 amountTokenMin,

        uint256 amountETHMin,

        address to,

        uint256 deadline

    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;



    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external payable;



    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint256 amountIn,

        uint256 amountOutMin,

        address[] calldata path,

        address to,

        uint256 deadline

    ) external;

}



pragma solidity ^0.8.21;



library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            uint256 c = a + b;

            if (c < a) return (false, 0);

            return (true, c);

        }

    }



    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b > a) return (false, 0);

            return (true, a - b);

        }

    }



    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (a == 0) return (true, 0);

            uint256 c = a * b;

            if (c / a != b) return (false, 0);

            return (true, c);

        }

    }



    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b == 0) return (false, 0);

            return (true, a / b);

        }

    }



    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {

            if (b == 0) return (false, 0);

            return (true, a % b);

        }

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;

    }



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;

    }



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;

    }



    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {

            require(b <= a, errorMessage);

            return a - b;

        }

    }



    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a / b;

        }

    }



    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a % b;

        }

    }

}



pragma solidity ^0.8.4;



/// @notice Library for converting numbers into strings and other string operations.

/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)

/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)

library LibString {

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/

    /*                        CUSTOM ERRORS                       */

    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/



    /// @dev The `length` of the output is too small to contain all the hex digits.

    error HexLengthInsufficient();



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/

    /*                         CONSTANTS                          */

    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/



    /// @dev The constant returned when the `search` is not found in the string.

    uint256 internal constant NOT_FOUND = type(uint256).max;



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/

    /*                     DECIMAL OPERATIONS                     */

    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/



    /// @dev Returns the base 10 decimal representation of `value`.

    function toString(uint256 value) internal pure returns (string memory str) {

        /// @solidity memory-safe-assembly

        assembly {

            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but

            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.

            // We will need 1 word for the trailing zeros padding, 1 word for the length,

            // and 3 words for a maximum of 78 digits.

            str := add(mload(0x40), 0x80)

            // Update the free memory pointer to allocate.

            mstore(0x40, add(str, 0x20))

            // Zeroize the slot after the string.

            mstore(str, 0)



            // Cache the end of the memory to calculate the length later.

            let end := str



            let w := not(0) // Tsk.

            // We write the string from rightmost digit to leftmost digit.

            // The following is essentially a do-while loop that also handles the zero case.

            for { let temp := value } 1 {} {

                str := add(str, w) // `sub(str, 1)`.

                // Write the character to the pointer.

                // The ASCII index of the '0' character is 48.

                mstore8(str, add(48, mod(temp, 10)))

                // Keep dividing `temp` until zero.

                temp := div(temp, 10)

                if iszero(temp) { break }

            }



            let length := sub(end, str)

            // Move the pointer 32 bytes leftwards to make room for the length.

            str := sub(str, 0x20)

            // Store the length.

            mstore(str, length)

        }

    }



    /// @dev Returns the base 10 decimal representation of `value`.

    function toString(int256 value) internal pure returns (string memory str) {

        if (value >= 0) {

            return toString(uint256(value));

        }

        unchecked {

            str = toString(uint256(-value));

        }

        /// @solidity memory-safe-assembly

        assembly {

            // We still have some spare memory space on the left,

            // as we have allocated 3 words (96 bytes) for up to 78 digits.

            let length := mload(str) // Load the string length.

            mstore(str, 0x2d) // Store the '-' character.

            str := sub(str, 1) // Move back the string pointer by a byte.

            mstore(str, add(length, 1)) // Update the string length.

        }

    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/

    /*                   HEXADECIMAL OPERATIONS                   */

    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/



    /// @dev Returns the hexadecimal representation of `value`,

    /// left-padded to an input length of `length` bytes.

    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,

    /// giving a total length of `length * 2 + 2` bytes.

    /// Reverts if `length` is too small for the output to contain all the digits.

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory str) {

        str = toHexStringNoPrefix(value, length);

        /// @solidity memory-safe-assembly

        assembly {

            let strLength := add(mload(str), 2) // Compute the length.

            mstore(str, 0x3078) // Write the "0x" prefix.

            str := sub(str, 2) // Move the pointer.

            mstore(str, strLength) // Write the length.

        }

    }



    /// @dev Returns the hexadecimal representation of `value`,

    /// left-padded to an input length of `length` bytes.

    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,

    /// giving a total length of `length * 2` bytes.

    /// Reverts if `length` is too small for the output to contain all the digits.

    function toHexStringNoPrefix(uint256 value, uint256 length)

        internal

        pure

        returns (string memory str)

    {

        /// @solidity memory-safe-assembly

        assembly {

            // We need 0x20 bytes for the trailing zeros padding, `length * 2` bytes

            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.

            // We add 0x20 to the total and round down to a multiple of 0x20.

            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.

            str := add(mload(0x40), and(add(shl(1, length), 0x42), not(0x1f)))

            // Allocate the memory.

            mstore(0x40, add(str, 0x20))

            // Zeroize the slot after the string.

            mstore(str, 0)



            // Cache the end to calculate the length later.

            let end := str

            // Store "0123456789abcdef" in scratch space.

            mstore(0x0f, 0x30313233343536373839616263646566)



            let start := sub(str, add(length, length))

            let w := not(1) // Tsk.

            let temp := value

            // We write the string from rightmost digit to leftmost digit.

            // The following is essentially a do-while loop that also handles the zero case.

            for {} 1 {} {

                str := add(str, w) // `sub(str, 2)`.

                mstore8(add(str, 1), mload(and(temp, 15)))

                mstore8(str, mload(and(shr(4, temp), 15)))

                temp := shr(8, temp)

                if iszero(xor(str, start)) { break }

            }



            if temp {

                // Store the function selector of `HexLengthInsufficient()`.

                mstore(0x00, 0x2194895a)

                // Revert with (offset, size).

                revert(0x1c, 0x04)

            }



            // Compute the string's length.

            let strLength := sub(end, str)

            // Move the pointer and write the length.

            str := sub(str, 0x20)

            mstore(str, strLength)

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.

    /// As address are 20 bytes long, the output will left-padded to have

    /// a length of `20 * 2 + 2` bytes.

    function toHexString(uint256 value) internal pure returns (string memory str) {

        str = toHexStringNoPrefix(value);

        /// @solidity memory-safe-assembly

        assembly {

            let strLength := add(mload(str), 2) // Compute the length.

            mstore(str, 0x3078) // Write the "0x" prefix.

            str := sub(str, 2) // Move the pointer.

            mstore(str, strLength) // Write the length.

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output is prefixed with "0x".

    /// The output excludes leading "0" from the `toHexString` output.

    /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.

    function toMinimalHexString(uint256 value) internal pure returns (string memory str) {

        str = toHexStringNoPrefix(value);

        /// @solidity memory-safe-assembly

        assembly {

            let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.

            let strLength := add(mload(str), 2) // Compute the length.

            mstore(add(str, o), 0x3078) // Write the "0x" prefix, accounting for leading zero.

            str := sub(add(str, o), 2) // Move the pointer, accounting for leading zero.

            mstore(str, sub(strLength, o)) // Write the length, accounting for leading zero.

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output excludes leading "0" from the `toHexStringNoPrefix` output.

    /// `0x00: "0", 0x01: "1", 0x12: "12", 0x123: "123"`.

    function toMinimalHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {

        str = toHexStringNoPrefix(value);

        /// @solidity memory-safe-assembly

        assembly {

            let o := eq(byte(0, mload(add(str, 0x20))), 0x30) // Whether leading zero is present.

            let strLength := mload(str) // Get the length.

            str := add(str, o) // Move the pointer, accounting for leading zero.

            mstore(str, sub(strLength, o)) // Write the length, accounting for leading zero.

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output is encoded using 2 hexadecimal digits per byte.

    /// As address are 20 bytes long, the output will left-padded to have

    /// a length of `20 * 2` bytes.

    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory str) {

        /// @solidity memory-safe-assembly

        assembly {

            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,

            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.

            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.

            str := add(mload(0x40), 0x80)

            // Allocate the memory.

            mstore(0x40, add(str, 0x20))

            // Zeroize the slot after the string.

            mstore(str, 0)



            // Cache the end to calculate the length later.

            let end := str

            // Store "0123456789abcdef" in scratch space.

            mstore(0x0f, 0x30313233343536373839616263646566)



            let w := not(1) // Tsk.

            // We write the string from rightmost digit to leftmost digit.

            // The following is essentially a do-while loop that also handles the zero case.

            for { let temp := value } 1 {} {

                str := add(str, w) // `sub(str, 2)`.

                mstore8(add(str, 1), mload(and(temp, 15)))

                mstore8(str, mload(and(shr(4, temp), 15)))

                temp := shr(8, temp)

                if iszero(temp) { break }

            }



            // Compute the string's length.

            let strLength := sub(end, str)

            // Move the pointer and write the length.

            str := sub(str, 0x20)

            mstore(str, strLength)

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,

    /// and the alphabets are capitalized conditionally according to

    /// https://eips.ethereum.org/EIPS/eip-55

    function toHexStringChecksummed(address value) internal pure returns (string memory str) {

        str = toHexString(value);

        /// @solidity memory-safe-assembly

        assembly {

            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`

            let o := add(str, 0x22)

            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `

            let t := shl(240, 136) // `0b10001000 << 240`

            for { let i := 0 } 1 {} {

                mstore(add(i, i), mul(t, byte(i, hashed)))

                i := add(i, 1)

                if eq(i, 20) { break }

            }

            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))

            o := add(o, 0x20)

            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.

    function toHexString(address value) internal pure returns (string memory str) {

        str = toHexStringNoPrefix(value);

        /// @solidity memory-safe-assembly

        assembly {

            let strLength := add(mload(str), 2) // Compute the length.

            mstore(str, 0x3078) // Write the "0x" prefix.

            str := sub(str, 2) // Move the pointer.

            mstore(str, strLength) // Write the length.

        }

    }



    /// @dev Returns the hexadecimal representation of `value`.

    /// The output is encoded using 2 hexadecimal digits per byte.

    function toHexStringNoPrefix(address value) internal pure returns (string memory str) {

        /// @solidity memory-safe-assembly

        assembly {

            str := mload(0x40)



            // Allocate the memory.

            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,

            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.

            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.

            mstore(0x40, add(str, 0x80))



            // Store "0123456789abcdef" in scratch space.

            mstore(0x0f, 0x30313233343536373839616263646566)



            str := add(str, 2)

            mstore(str, 40)



            let o := add(str, 0x20)

            mstore(add(o, 40), 0)



            value := shl(96, value)



            // We write the string from rightmost digit to leftmost digit.

            // The following is essentially a do-while loop that also handles the zero case.

            for { let i := 0 } 1 {} {

                let p := add(o, add(i, i))

                let temp := byte(i, value)

                mstore8(add(p, 1), mload(and(temp, 15)))

                mstore8(p, mload(shr(4, temp)))

                i := add(i, 1)

                if eq(i, 20) { break }

            }

        }

    }



    /// @dev Returns the hex encoded string from the raw bytes.

    /// The output is encoded using 2 hexadecimal digits per byte.

    function toHexString(bytes memory raw) internal pure returns (string memory str) {

        str = toHexStringNoPrefix(raw);

        /// @solidity memory-safe-assembly

        assembly {

            let strLength := add(mload(str), 2) // Compute the length.

            mstore(str, 0x3078) // Write the "0x" prefix.

            str := sub(str, 2) // Move the pointer.

            mstore(str, strLength) // Write the length.

        }

    }



    /// @dev Returns the hex encoded string from the raw bytes.

    /// The output is encoded using 2 hexadecimal digits per byte.

    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory str) {

        /// @solidity memory-safe-assembly

        assembly {

            let length := mload(raw)

            str := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.

            mstore(str, add(length, length)) // Store the length of the output.



            // Store "0123456789abcdef" in scratch space.

            mstore(0x0f, 0x30313233343536373839616263646566)



            let o := add(str, 0x20)

            let end := add(raw, length)



            for {} iszero(eq(raw, end)) {} {

                raw := add(raw, 1)

                mstore8(add(o, 1), mload(and(mload(raw), 15)))

                mstore8(o, mload(and(shr(4, mload(raw)), 15)))

                o := add(o, 2)

            }

            mstore(o, 0) // Zeroize the slot after the string.

            mstore(0x40, add(o, 0x20)) // Allocate the memory.

        }

    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/

    /*                   RUNE STRING OPERATIONS                   */

    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/



    /// @dev Returns the number of UTF characters in the string.

    function runeCount(string memory s) internal pure returns (uint256 result) {

        /// @solidity memory-safe-assembly

        assembly {

            if mload(s) {

                mstore(0x00, div(not(0), 255))

                mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)

                let o := add(s, 0x20)

                let end := add(o, mload(s))

                for { result := 1 } 1 { result := add(result, 1) } {

                    o := add(o, byte(0, mload(shr(250, mload(o)))))

                    if iszero(lt(o, end)) { break }

                }

            }

        }

    }



    /// @dev Returns if this string is a 7-bit ASCII string.

    /// (i.e. all characters codes are in [0..127])

    function is7BitASCII(string memory s) internal pure returns (bool result) {

        /// @solidity memory-safe-assembly

        assembly {

            let mask := shl(7, div(not(0), 255))

            result := 1

            let n := mload(s)

            if n {

                let o := add(s, 0x20)

                let end := add(o, n)

                let last := mload(end)

                mstore(end, 0)

                for {} 1 {} {

                    if and(mask, mload(o)) {

                        result := 0

                        break

                    }

                    o := add(o, 0x20)

                    if iszero(lt(o, end)) { break }

                }

                mstore(end, last)

            }

        }

    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/

    /*                   BYTE STRING OPERATIONS                   */

    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/



    // For performance and bytecode compactness, all indices of the following operations

    // are byte (ASCII) offsets, not UTF character offsets.



    /// @dev Returns `subject` all occurrences of `search` replaced with `replacement`.

    function replace(string memory subject, string memory search, string memory replacement)

        internal

        pure

        returns (string memory result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let subjectLength := mload(subject)

            let searchLength := mload(search)

            let replacementLength := mload(replacement)



            subject := add(subject, 0x20)

            search := add(search, 0x20)

            replacement := add(replacement, 0x20)

            result := add(mload(0x40), 0x20)



            let subjectEnd := add(subject, subjectLength)

            if iszero(gt(searchLength, subjectLength)) {

                let subjectSearchEnd := add(sub(subjectEnd, searchLength), 1)

                let h := 0

                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }

                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))

                let s := mload(search)

                for {} 1 {} {

                    let t := mload(subject)

                    // Whether the first `searchLength % 32` bytes of

                    // `subject` and `search` matches.

                    if iszero(shr(m, xor(t, s))) {

                        if h {

                            if iszero(eq(keccak256(subject, searchLength), h)) {

                                mstore(result, t)

                                result := add(result, 1)

                                subject := add(subject, 1)

                                if iszero(lt(subject, subjectSearchEnd)) { break }

                                continue

                            }

                        }

                        // Copy the `replacement` one word at a time.

                        for { let o := 0 } 1 {} {

                            mstore(add(result, o), mload(add(replacement, o)))

                            o := add(o, 0x20)

                            if iszero(lt(o, replacementLength)) { break }

                        }

                        result := add(result, replacementLength)

                        subject := add(subject, searchLength)

                        if searchLength {

                            if iszero(lt(subject, subjectSearchEnd)) { break }

                            continue

                        }

                    }

                    mstore(result, t)

                    result := add(result, 1)

                    subject := add(subject, 1)

                    if iszero(lt(subject, subjectSearchEnd)) { break }

                }

            }



            let resultRemainder := result

            result := add(mload(0x40), 0x20)

            let k := add(sub(resultRemainder, result), sub(subjectEnd, subject))

            // Copy the rest of the string one word at a time.

            for {} lt(subject, subjectEnd) {} {

                mstore(resultRemainder, mload(subject))

                resultRemainder := add(resultRemainder, 0x20)

                subject := add(subject, 0x20)

            }

            result := sub(result, 0x20)

            let last := add(add(result, 0x20), k) // Zeroize the slot after the string.

            mstore(last, 0)

            mstore(0x40, add(last, 0x20)) // Allocate the memory.

            mstore(result, k) // Store the length.

        }

    }



    /// @dev Returns the byte index of the first location of `search` in `subject`,

    /// searching from left to right, starting from `from`.

    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.

    function indexOf(string memory subject, string memory search, uint256 from)

        internal

        pure

        returns (uint256 result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            for { let subjectLength := mload(subject) } 1 {} {

                if iszero(mload(search)) {

                    if iszero(gt(from, subjectLength)) {

                        result := from

                        break

                    }

                    result := subjectLength

                    break

                }

                let searchLength := mload(search)

                let subjectStart := add(subject, 0x20)



                result := not(0) // Initialize to `NOT_FOUND`.



                subject := add(subjectStart, from)

                let end := add(sub(add(subjectStart, subjectLength), searchLength), 1)



                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))

                let s := mload(add(search, 0x20))



                if iszero(and(lt(subject, end), lt(from, subjectLength))) { break }



                if iszero(lt(searchLength, 0x20)) {

                    for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {

                        if iszero(shr(m, xor(mload(subject), s))) {

                            if eq(keccak256(subject, searchLength), h) {

                                result := sub(subject, subjectStart)

                                break

                            }

                        }

                        subject := add(subject, 1)

                        if iszero(lt(subject, end)) { break }

                    }

                    break

                }

                for {} 1 {} {

                    if iszero(shr(m, xor(mload(subject), s))) {

                        result := sub(subject, subjectStart)

                        break

                    }

                    subject := add(subject, 1)

                    if iszero(lt(subject, end)) { break }

                }

                break

            }

        }

    }



    /// @dev Returns the byte index of the first location of `search` in `subject`,

    /// searching from left to right.

    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.

    function indexOf(string memory subject, string memory search)

        internal

        pure

        returns (uint256 result)

    {

        result = indexOf(subject, search, 0);

    }



    /// @dev Returns the byte index of the first location of `search` in `subject`,

    /// searching from right to left, starting from `from`.

    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.

    function lastIndexOf(string memory subject, string memory search, uint256 from)

        internal

        pure

        returns (uint256 result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            for {} 1 {} {

                result := not(0) // Initialize to `NOT_FOUND`.

                let searchLength := mload(search)

                if gt(searchLength, mload(subject)) { break }

                let w := result



                let fromMax := sub(mload(subject), searchLength)

                if iszero(gt(fromMax, from)) { from := fromMax }



                let end := add(add(subject, 0x20), w)

                subject := add(add(subject, 0x20), from)

                if iszero(gt(subject, end)) { break }

                // As this function is not too often used,

                // we shall simply use keccak256 for smaller bytecode size.

                for { let h := keccak256(add(search, 0x20), searchLength) } 1 {} {

                    if eq(keccak256(subject, searchLength), h) {

                        result := sub(subject, add(end, 1))

                        break

                    }

                    subject := add(subject, w) // `sub(subject, 1)`.

                    if iszero(gt(subject, end)) { break }

                }

                break

            }

        }

    }



    /// @dev Returns the byte index of the first location of `search` in `subject`,

    /// searching from right to left.

    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `search` is not found.

    function lastIndexOf(string memory subject, string memory search)

        internal

        pure

        returns (uint256 result)

    {

        result = lastIndexOf(subject, search, uint256(int256(-1)));

    }



    /// @dev Returns whether `subject` starts with `search`.

    function startsWith(string memory subject, string memory search)

        internal

        pure

        returns (bool result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let searchLength := mload(search)

            // Just using keccak256 directly is actually cheaper.

            // forgefmt: disable-next-item

            result := and(

                iszero(gt(searchLength, mload(subject))),

                eq(

                    keccak256(add(subject, 0x20), searchLength),

                    keccak256(add(search, 0x20), searchLength)

                )

            )

        }

    }



    /// @dev Returns whether `subject` ends with `search`.

    function endsWith(string memory subject, string memory search)

        internal

        pure

        returns (bool result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let searchLength := mload(search)

            let subjectLength := mload(subject)

            // Whether `search` is not longer than `subject`.

            let withinRange := iszero(gt(searchLength, subjectLength))

            // Just using keccak256 directly is actually cheaper.

            // forgefmt: disable-next-item

            result := and(

                withinRange,

                eq(

                    keccak256(

                        // `subject + 0x20 + max(subjectLength - searchLength, 0)`.

                        add(add(subject, 0x20), mul(withinRange, sub(subjectLength, searchLength))),

                        searchLength

                    ),

                    keccak256(add(search, 0x20), searchLength)

                )

            )

        }

    }



    /// @dev Returns `subject` repeated `times`.

    function repeat(string memory subject, uint256 times)

        internal

        pure

        returns (string memory result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let subjectLength := mload(subject)

            if iszero(or(iszero(times), iszero(subjectLength))) {

                subject := add(subject, 0x20)

                result := mload(0x40)

                let output := add(result, 0x20)

                for {} 1 {} {

                    // Copy the `subject` one word at a time.

                    for { let o := 0 } 1 {} {

                        mstore(add(output, o), mload(add(subject, o)))

                        o := add(o, 0x20)

                        if iszero(lt(o, subjectLength)) { break }

                    }

                    output := add(output, subjectLength)

                    times := sub(times, 1)

                    if iszero(times) { break }

                }

                mstore(output, 0) // Zeroize the slot after the string.

                let resultLength := sub(output, add(result, 0x20))

                mstore(result, resultLength) // Store the length.

                // Allocate the memory.

                mstore(0x40, add(result, add(resultLength, 0x20)))

            }

        }

    }



    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).

    /// `start` and `end` are byte offsets.

    function slice(string memory subject, uint256 start, uint256 end)

        internal

        pure

        returns (string memory result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let subjectLength := mload(subject)

            if iszero(gt(subjectLength, end)) { end := subjectLength }

            if iszero(gt(subjectLength, start)) { start := subjectLength }

            if lt(start, end) {

                result := mload(0x40)

                let resultLength := sub(end, start)

                mstore(result, resultLength)

                subject := add(subject, start)

                let w := not(0x1f)

                // Copy the `subject` one word at a time, backwards.

                for { let o := and(add(resultLength, 0x1f), w) } 1 {} {

                    mstore(add(result, o), mload(add(subject, o)))

                    o := add(o, w) // `sub(o, 0x20)`.

                    if iszero(o) { break }

                }

                // Zeroize the slot after the string.

                mstore(add(add(result, 0x20), resultLength), 0)

                // Allocate memory for the length and the bytes,

                // rounded up to a multiple of 32.

                mstore(0x40, add(result, and(add(resultLength, 0x3f), w)))

            }

        }

    }



    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.

    /// `start` is a byte offset.

    function slice(string memory subject, uint256 start)

        internal

        pure

        returns (string memory result)

    {

        result = slice(subject, start, uint256(int256(-1)));

    }



    /// @dev Returns all the indices of `search` in `subject`.

    /// The indices are byte offsets.

    function indicesOf(string memory subject, string memory search)

        internal

        pure

        returns (uint256[] memory result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let subjectLength := mload(subject)

            let searchLength := mload(search)



            if iszero(gt(searchLength, subjectLength)) {

                subject := add(subject, 0x20)

                search := add(search, 0x20)

                result := add(mload(0x40), 0x20)



                let subjectStart := subject

                let subjectSearchEnd := add(sub(add(subject, subjectLength), searchLength), 1)

                let h := 0

                if iszero(lt(searchLength, 0x20)) { h := keccak256(search, searchLength) }

                let m := shl(3, sub(0x20, and(searchLength, 0x1f)))

                let s := mload(search)

                for {} 1 {} {

                    let t := mload(subject)

                    // Whether the first `searchLength % 32` bytes of

                    // `subject` and `search` matches.

                    if iszero(shr(m, xor(t, s))) {

                        if h {

                            if iszero(eq(keccak256(subject, searchLength), h)) {

                                subject := add(subject, 1)

                                if iszero(lt(subject, subjectSearchEnd)) { break }

                                continue

                            }

                        }

                        // Append to `result`.

                        mstore(result, sub(subject, subjectStart))

                        result := add(result, 0x20)

                        // Advance `subject` by `searchLength`.

                        subject := add(subject, searchLength)

                        if searchLength {

                            if iszero(lt(subject, subjectSearchEnd)) { break }

                            continue

                        }

                    }

                    subject := add(subject, 1)

                    if iszero(lt(subject, subjectSearchEnd)) { break }

                }

                let resultEnd := result

                // Assign `result` to the free memory pointer.

                result := mload(0x40)

                // Store the length of `result`.

                mstore(result, shr(5, sub(resultEnd, add(result, 0x20))))

                // Allocate memory for result.

                // We allocate one more word, so this array can be recycled for {split}.

                mstore(0x40, add(resultEnd, 0x20))

            }

        }

    }



    /// @dev Returns a arrays of strings based on the `delimiter` inside of the `subject` string.

    function split(string memory subject, string memory delimiter)

        internal

        pure

        returns (string[] memory result)

    {

        uint256[] memory indices = indicesOf(subject, delimiter);

        /// @solidity memory-safe-assembly

        assembly {

            let w := not(0x1f)

            let indexPtr := add(indices, 0x20)

            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))

            mstore(add(indicesEnd, w), mload(subject))

            mstore(indices, add(mload(indices), 1))

            let prevIndex := 0

            for {} 1 {} {

                let index := mload(indexPtr)

                mstore(indexPtr, 0x60)

                if iszero(eq(index, prevIndex)) {

                    let element := mload(0x40)

                    let elementLength := sub(index, prevIndex)

                    mstore(element, elementLength)

                    // Copy the `subject` one word at a time, backwards.

                    for { let o := and(add(elementLength, 0x1f), w) } 1 {} {

                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))

                        o := add(o, w) // `sub(o, 0x20)`.

                        if iszero(o) { break }

                    }

                    // Zeroize the slot after the string.

                    mstore(add(add(element, 0x20), elementLength), 0)

                    // Allocate memory for the length and the bytes,

                    // rounded up to a multiple of 32.

                    mstore(0x40, add(element, and(add(elementLength, 0x3f), w)))

                    // Store the `element` into the array.

                    mstore(indexPtr, element)

                }

                prevIndex := add(index, mload(delimiter))

                indexPtr := add(indexPtr, 0x20)

                if iszero(lt(indexPtr, indicesEnd)) { break }

            }

            result := indices

            if iszero(mload(delimiter)) {

                result := add(indices, 0x20)

                mstore(result, sub(mload(indices), 2))

            }

        }

    }



    /// @dev Returns a concatenated string of `a` and `b`.

    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.

    function concat(string memory a, string memory b)

        internal

        pure

        returns (string memory result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let w := not(0x1f)

            result := mload(0x40)

            let aLength := mload(a)

            // Copy `a` one word at a time, backwards.

            for { let o := and(add(aLength, 0x20), w) } 1 {} {

                mstore(add(result, o), mload(add(a, o)))

                o := add(o, w) // `sub(o, 0x20)`.

                if iszero(o) { break }

            }

            let bLength := mload(b)

            let output := add(result, aLength)

            // Copy `b` one word at a time, backwards.

            for { let o := and(add(bLength, 0x20), w) } 1 {} {

                mstore(add(output, o), mload(add(b, o)))

                o := add(o, w) // `sub(o, 0x20)`.

                if iszero(o) { break }

            }

            let totalLength := add(aLength, bLength)

            let last := add(add(result, 0x20), totalLength)

            // Zeroize the slot after the string.

            mstore(last, 0)

            // Stores the length.

            mstore(result, totalLength)

            // Allocate memory for the length and the bytes,

            // rounded up to a multiple of 32.

            mstore(0x40, and(add(last, 0x1f), w))

        }

    }



    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.

    /// WARNING! This function is only compatible with 7-bit ASCII strings.

    function toCase(string memory subject, bool toUpper)

        internal

        pure

        returns (string memory result)

    {

        /// @solidity memory-safe-assembly

        assembly {

            let length := mload(subject)

            if length {

                result := add(mload(0x40), 0x20)

                subject := add(subject, 1)

                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)

                let w := not(0)

                for { let o := length } 1 {} {

                    o := add(o, w)

                    let b := and(0xff, mload(add(subject, o)))

                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))

                    if iszero(o) { break }

                }

                result := mload(0x40)

                mstore(result, length) // Store the length.

                let last := add(add(result, 0x20), length)

                mstore(last, 0) // Zeroize the slot after the string.

                mstore(0x40, add(last, 0x20)) // Allocate the memory.

            }

        }

    }



    /// @dev Returns a lowercased copy of the string.

    /// WARNING! This function is only compatible with 7-bit ASCII strings.

    function lower(string memory subject) internal pure returns (string memory result) {

        result = toCase(subject, false);

    }



    /// @dev Returns an UPPERCASED copy of the string.

    /// WARNING! This function is only compatible with 7-bit ASCII strings.

    function upper(string memory subject) internal pure returns (string memory result) {

        result = toCase(subject, true);

    }



    /// @dev Escapes the string to be used within HTML tags.

    function escapeHTML(string memory s) internal pure returns (string memory result) {

        /// @solidity memory-safe-assembly

        assembly {

            for {

                let end := add(s, mload(s))

                result := add(mload(0x40), 0x20)

                // Store the bytes of the packed offsets and strides into the scratch space.

                // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.

                mstore(0x1f, 0x900094)

                mstore(0x08, 0xc0000000a6ab)

                // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.

                mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))

            } iszero(eq(s, end)) {} {

                s := add(s, 1)

                let c := and(mload(s), 0xff)

                // Not in `["\"","'","&","<",">"]`.

                if iszero(and(shl(c, 1), 0x500000c400000000)) {

                    mstore8(result, c)

                    result := add(result, 1)

                    continue

                }

                let t := shr(248, mload(c))

                mstore(result, mload(and(t, 0x1f)))

                result := add(result, shr(5, t))

            }

            let last := result

            mstore(last, 0) // Zeroize the slot after the string.

            result := mload(0x40)

            mstore(result, sub(last, add(result, 0x20))) // Store the length.

            mstore(0x40, add(last, 0x20)) // Allocate the memory.

        }

    }



    /// @dev Escapes the string to be used within double-quotes in a JSON.

    function escapeJSON(string memory s) internal pure returns (string memory result) {

        /// @solidity memory-safe-assembly

        assembly {

            for {

                let end := add(s, mload(s))

                result := add(mload(0x40), 0x20)

                // Store "\\u0000" in scratch space.

                // Store "0123456789abcdef" in scratch space.

                // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.

                // into the scratch space.

                mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)

                // Bitmask for detecting `["\"","\\"]`.

                let e := or(shl(0x22, 1), shl(0x5c, 1))

            } iszero(eq(s, end)) {} {

                s := add(s, 1)

                let c := and(mload(s), 0xff)

                if iszero(lt(c, 0x20)) {

                    if iszero(and(shl(c, 1), e)) {

                        // Not in `["\"","\\"]`.

                        mstore8(result, c)

                        result := add(result, 1)

                        continue

                    }

                    mstore8(result, 0x5c) // "\\".

                    mstore8(add(result, 1), c)

                    result := add(result, 2)

                    continue

                }

                if iszero(and(shl(c, 1), 0x3700)) {

                    // Not in `["\b","\t","\n","\f","\d"]`.

                    mstore8(0x1d, mload(shr(4, c))) // Hex value.

                    mstore8(0x1e, mload(and(c, 15))) // Hex value.

                    mstore(result, mload(0x19)) // "\\u00XX".

                    result := add(result, 6)

                    continue

                }

                mstore8(result, 0x5c) // "\\".

                mstore8(add(result, 1), mload(add(c, 8)))

                result := add(result, 2)

            }

            let last := result

            mstore(last, 0) // Zeroize the slot after the string.

            result := mload(0x40)

            mstore(result, sub(last, add(result, 0x20))) // Store the length.

            mstore(0x40, add(last, 0x20)) // Allocate the memory.

        }

    }



    /// @dev Returns whether `a` equals `b`.

    function eq(string memory a, string memory b) internal pure returns (bool result) {

        assembly {

            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))

        }

    }



    /// @dev Packs a single string with its length into a single word.

    /// Returns `bytes32(0)` if the length is zero or greater than 31.

    function packOne(string memory a) internal pure returns (bytes32 result) {

        /// @solidity memory-safe-assembly

        assembly {

            // We don't need to zero right pad the string,

            // since this is our own custom non-standard packing scheme.

            result :=

                mul(

                    // Load the length and the bytes.

                    mload(add(a, 0x1f)),

                    // `length != 0 && length < 32`. Abuses underflow.

                    // Assumes that the length is valid and within the block gas limit.

                    lt(sub(mload(a), 1), 0x1f)

                )

        }

    }



    /// @dev Unpacks a string packed using {packOne}.

    /// Returns the empty string if `packed` is `bytes32(0)`.

    /// If `packed` is not an output of {packOne}, the output behaviour is undefined.

    function unpackOne(bytes32 packed) internal pure returns (string memory result) {

        /// @solidity memory-safe-assembly

        assembly {

            // Grab the free memory pointer.

            result := mload(0x40)

            // Allocate 2 words (1 for the length, 1 for the bytes).

            mstore(0x40, add(result, 0x40))

            // Zeroize the length slot.

            mstore(result, 0)

            // Store the length and bytes.

            mstore(add(result, 0x1f), packed)

            // Right pad with zeroes.

            mstore(add(add(result, 0x20), mload(result)), 0)

        }

    }



    /// @dev Packs two strings with their lengths into a single word.

    /// Returns `bytes32(0)` if combined length is zero or greater than 30.

    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {

        /// @solidity memory-safe-assembly

        assembly {

            let aLength := mload(a)

            // We don't need to zero right pad the strings,

            // since this is our own custom non-standard packing scheme.

            result :=

                mul(

                    // Load the length and the bytes of `a` and `b`.

                    or(

                        shl(shl(3, sub(0x1f, aLength)), mload(add(a, aLength))),

                        mload(sub(add(b, 0x1e), aLength))

                    ),

                    // `totalLength != 0 && totalLength < 31`. Abuses underflow.

                    // Assumes that the lengths are valid and within the block gas limit.

                    lt(sub(add(aLength, mload(b)), 1), 0x1e)

                )

        }

    }



    /// @dev Unpacks strings packed using {packTwo}.

    /// Returns the empty strings if `packed` is `bytes32(0)`.

    /// If `packed` is not an output of {packTwo}, the output behaviour is undefined.

    function unpackTwo(bytes32 packed)

        internal

        pure

        returns (string memory resultA, string memory resultB)

    {

        /// @solidity memory-safe-assembly

        assembly {

            // Grab the free memory pointer.

            resultA := mload(0x40)

            resultB := add(resultA, 0x40)

            // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.

            mstore(0x40, add(resultB, 0x40))

            // Zeroize the length slots.

            mstore(resultA, 0)

            mstore(resultB, 0)

            // Store the lengths and bytes.

            mstore(add(resultA, 0x1f), packed)

            mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))

            // Right pad with zeroes.

            mstore(add(add(resultA, 0x20), mload(resultA)), 0)

            mstore(add(add(resultB, 0x20), mload(resultB)), 0)

        }

    }



    /// @dev Directly returns `a` without copying.

    function directReturn(string memory a) internal pure {

        assembly {

            // Assumes that the string does not start from the scratch space.

            let retStart := sub(a, 0x20)

            let retSize := add(mload(a), 0x40)

            // Right pad with zeroes. Just in case the string is produced

            // by a method that doesn't zero right pad.

            mstore(add(retStart, retSize), 0)

            // Store the return offset.

            mstore(retStart, 0x20)

            // End the transaction, returning the string.

            return(retStart, retSize)

        }

    }

}



pragma solidity ^0.8.21;



interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address recipient, uint256 amount) external returns (bool);



    function allowance(address owner, address spender) external view returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



pragma solidity ^0.8.21;





interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);



    function symbol() external view returns (string memory);



    function decimals() external view returns (uint8);

}



pragma solidity ^0.8.21;



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}



pragma solidity ^0.8.21;





abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor() {

        _transferOwnership(_msgSender());

    }



    function owner() public view virtual returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        _;

    }



    function renounceOwnership() public virtual onlyOwner {

        _transferOwnership(address(0));

    }



    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

    }



    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}



pragma solidity ^0.8.21;





contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;



    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

    }



    function name() public view virtual override returns (string memory) {

        return _name;

    }



    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    function decimals() public view virtual override returns (uint8) {

        return 18;

    }



    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);



        uint256 currentAllowance = _allowances[sender][_msgSender()];

        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        unchecked {

            _approve(sender, _msgSender(), currentAllowance - amount);

        }



        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {

            _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        }



        return true;

    }



    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(sender, recipient, amount);



        uint256 senderBalance = _balances[sender];

        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {

            _balances[sender] = senderBalance - amount;

        }

        _balances[recipient] += amount;



        emit Transfer(sender, recipient, amount);



        _afterTokenTransfer(sender, recipient, amount);

    }



    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        _balances[account] += amount;

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }



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



    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}



    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}



pragma solidity ^0.8.21;



contract NumberGame is ERC20, Ownable {

    using SafeMath for uint256;



    error ZeroValue();

    error InvalidNumber();

    error GameNotActive();

    error TransferFailed();

    error DoesntEqualTotal();

    error GameNotConfigured();

    error GameAlreadyStarted();



    IUniswapV2Router02 public immutable uniswapV2Router;

    address public immutable uniswapV2Pair;

    address public constant deadAddress = address(0xdead);



    bool private swapping;

    bool public gameActive;



    address private marketingWallet;

    address private devWallet;



    uint256 public maxTransactionAmount;

    uint256 public swapTokensAtAmount;

    uint256 public maxWallet;



    bool public limitsInEffect = true;

    bool public tradingActive = false;

    bool public swapEnabled = false;



    uint256 private launchedAt;

    uint256 private launchedTime;

    uint256 public deadBlocks;



    uint256 public buyTotalFees;



    uint256 public sellTotalFees;



    uint256 public numberGuessBalance;

    uint256 public currentLevel;

    uint256 public totalLevels;

    uint256 public minGuessHoldings;

    mapping(uint256 => uint256) public payoutPerLevel;



    mapping(address => bool) private _isExcludedFromFees;

    mapping(address => bool) public _isExcludedMaxTransactionAmount;



    mapping(address => bool) public automatedMarketMakerPairs;



    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);



    event ExcludeFromFees(address indexed account, bool isExcluded);



    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);



    event marketingWalletUpdated(address indexed newWallet, address indexed oldWallet);



    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);



    event GameStarted();

    event GameEnded();

    event CorrectGuess(address indexed guesser, uint256 indexed level, uint256 indexed number);



    constructor() ERC20("Number Game", "NUMBER") {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D );



        excludeFromMaxTransaction(address(_uniswapV2Router), true);

        uniswapV2Router = _uniswapV2Router;



        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        excludeFromMaxTransaction(address(uniswapV2Pair), true);

        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);



        uint256 totalSupply = 1_000_000_000 * 1e18;

        // TODO: Manually define numberGuessSupply

        uint256 numberGuessSupply = 100_000_000 * 1e18;

        minGuessHoldings = 1_000_000 * 1e18;



        maxTransactionAmount = 5_000_000 * 1e18;

        maxWallet = 5_000_000 * 1e18;

        swapTokensAtAmount = 150_000 * 1e18; // 0.015% * 20 = 0.3%



        marketingWallet = msg.sender;

        devWallet = msg.sender;



        excludeFromFees(owner(), true);

        excludeFromFees(address(this), true);

        excludeFromFees(address(0xdead), true);



        excludeFromMaxTransaction(owner(), true);

        excludeFromMaxTransaction(address(this), true);

        excludeFromMaxTransaction(address(0xdead), true);



        // Adjusted supply mints to account for numberGuessSupply being stored in contract

        _mint(msg.sender, totalSupply - numberGuessSupply);

        _mint(address(this), numberGuessSupply);

        // Store the tokens allocated to number guess game for proper accounting

        numberGuessBalance = numberGuessSupply;

    }



    receive() external payable {}



    function updateMinimumTokenHoldings(uint256 _newMin) external onlyOwner {

        minGuessHoldings = _newMin * 1e18;

    }



    // Configure number guess game by specifying number of levels and the payout per level

    function configureGuessGame(uint256[] calldata _payouts) external onlyOwner {

        // Prevent reconfiguration if game has already started

        if (gameActive) { revert GameAlreadyStarted(); }

        // Store each level's payout value and tally payouts to prevent exceeding allocation

        uint256 totalPayout;

        for (uint256 i; i < _payouts.length;) {

            if (_payouts[i] == 0) { revert ZeroValue(); }

            payoutPerLevel[i + 1] = _payouts[i];

            unchecked {

                totalPayout += _payouts[i];

                ++i;

            }

        }

        if (totalPayout != numberGuessBalance) { revert DoesntEqualTotal(); }

        // Set totalLevels to _payouts length so mapping doesn't have to be iterable

        totalLevels = _payouts.length;

    }



    // One-way switch to activate the game

    function activateGame() external onlyOwner {

        if (gameActive) { revert GameAlreadyStarted(); }

        if (totalLevels == 0) { revert GameNotConfigured(); }

        gameActive = true;

        currentLevel += 1;

        emit GameStarted();

    }



    // Calculate sender+block-specific hash for any given number

    function hashNum(uint256 _num) public view returns (bytes32) {

        return keccak256(abi.encodePacked(msg.sender, _num));

    }



    // Guess the number for a particular level (starts at 1)

    function guessNumber(uint256 _num) external {

        // Player must hold 1m tokens (0.1%)

        require(balanceOf(msg.sender) >= minGuessHoldings);

        // Confirm game is active

        uint256 level = currentLevel;

        if (level == 0) { revert GameNotActive(); }

        // Calculate address + number hash

        bytes memory numHash = abi.encodePacked(hashNum(_num));

        // Convert bytes32 to string

        string memory numHashString = LibString.toHexStringNoPrefix(numHash);

        // Determine difficulty by calculating repeating "0" prefix based on current level

        string memory difficultyPrefix = LibString.repeat("0", level);

        // Verify number hash starts with the difficulty prefix

        bool confirmed = LibString.startsWith(numHashString, difficultyPrefix);

        if (!confirmed) { revert InvalidNumber(); }

        else {

            uint256 payout = payoutPerLevel[level];

            // Adjust internal accounting

            numberGuessBalance -= payout;

            currentLevel += 1;

            // Check msg.sender's balance beforehand

            uint256 balance = balanceOf(msg.sender);

            // Call pre-override ERC20 _transfer function to avoid tax logic

            ERC20._transfer(address(this), msg.sender, payout);

            // Confirm transfer was successful as _transfer doesn't perform completion checks

            if (balanceOf(msg.sender) - payout != balance) { revert TransferFailed(); }

            emit CorrectGuess(msg.sender, level, _num);

            // If final level win, end game

            if (level == totalLevels) {

                // Setting currentLevel to zero prevents guessNumber from being callable

                currentLevel = 0;

                emit GameEnded();

                // gameActive is not set to false as it would allow for a theoretical rerun with no tokens

            }

        }

    }



    function enableTrading(uint256 _deadBlocks) external onlyOwner {

        deadBlocks = _deadBlocks;

        tradingActive = true;

        swapEnabled = true;

        launchedAt = block.number;

        launchedTime = block.timestamp;

    }



    function removeLimits() external onlyOwner returns (bool) {

        limitsInEffect = false;

        return true;

    }



    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool) {

        require(newAmount >= (totalSupply() * 1) / 100000, "Swap amount cannot be lower than 0.001% total supply.");

        require(newAmount <= (totalSupply() * 5) / 1000, "Swap amount cannot be higher than 0.5% total supply.");

        swapTokensAtAmount = newAmount;

        return true;

    }



    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {

        require(newNum >= ((totalSupply() * 1) / 1000) / 1e18, "Cannot set maxTransactionAmount lower than 0.1%");

        maxTransactionAmount = newNum * (10 ** 18);

    }



    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {

        require(newNum >= ((totalSupply() * 5) / 1000) / 1e18, "Cannot set maxWallet lower than 0.5%");

        maxWallet = newNum * (10 ** 18);

    }



    function whitelistContract(address _whitelist, bool isWL) public onlyOwner {

        _isExcludedMaxTransactionAmount[_whitelist] = isWL;



        _isExcludedFromFees[_whitelist] = isWL;

    }



    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {

        _isExcludedMaxTransactionAmount[updAds] = isEx;

    }



    // only use to disable contract sales if absolutely necessary (emergency use only)

    function updateSwapEnabled(bool enabled) external onlyOwner {

        swapEnabled = enabled;

    }



    function excludeFromFees(address account, bool excluded) public onlyOwner {

        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);

    }



    function manualswap(uint256 amount) external {

        require(_msgSender() == marketingWallet);

        // Corrected require statement to account for number guess game allocation

        require(amount <= (balanceOf(address(this)) - numberGuessBalance) && amount > 0, "Wrong amount");

        swapTokensForEth(amount);

    }



    function manualsend() external {

        bool success;

        (success,) = address(devWallet).call{value: address(this).balance}("");

    }



    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {

        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");



        _setAutomatedMarketMakerPair(pair, value);

    }



    function _setAutomatedMarketMakerPair(address pair, bool value) private {

        automatedMarketMakerPairs[pair] = value;



        emit SetAutomatedMarketMakerPair(pair, value);

    }



    function updateBuyFees(uint256 _marketingFee) external onlyOwner {

        buyTotalFees = _marketingFee;

        require(buyTotalFees <= 5, "Must keep fees at 5% or less");

    }



    function updateSellFees(uint256 _marketingFee) external onlyOwner {

        sellTotalFees = _marketingFee;

        require(sellTotalFees <= 5, "Must keep fees at 5% or less");

    }



    function updateMarketingWallet(address newMarketingWallet) external onlyOwner {

        emit marketingWalletUpdated(newMarketingWallet, marketingWallet);

        marketingWallet = newMarketingWallet;

    }



    function airdrop(address[] calldata addresses, uint256[] calldata amounts) external {

        require(addresses.length > 0 && amounts.length == addresses.length);

        address from = msg.sender;



        for (uint256 i = 0; i < addresses.length; i++) {

            _transfer(from, addresses[i], amounts[i] * (10 ** 18));

        }

    }



    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        if (amount == 0) {

            super._transfer(from, to, 0);

            return;

        }



        if (limitsInEffect) {

            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {

                if ((launchedAt + deadBlocks) >= block.number) {

                    buyTotalFees = 35;

                    sellTotalFees = 35;

                } else if (block.number <= launchedAt + 5) {

                    buyTotalFees = 25;

                    sellTotalFees = 25;

                } else if (block.number <= launchedAt + 10) {

                    buyTotalFees = 10;

                    sellTotalFees = 10;

                } else {

                    buyTotalFees = 3;

                    sellTotalFees = 3;

                }



                if (!tradingActive) {

                    require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");

                }



                //when buy

                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {

                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");

                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");

                }

                //when sell

                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {

                    require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");

                } else if (!_isExcludedMaxTransactionAmount[to]) {

                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");

                }

            }

        }



        // Corrected to account for number guess game allocation

        uint256 contractTokenBalance = balanceOf(address(this)) - numberGuessBalance;



        bool canSwap = contractTokenBalance >= swapTokensAtAmount;



        if (

            canSwap && swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from]

                && !_isExcludedFromFees[to]

        ) {

            swapping = true;



            swapBack();



            swapping = false;

        }



        bool takeFee = !swapping;



        // if any account belongs to _isExcludedFromFee account then remove the fee

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {

            takeFee = false;

        }



        uint256 fees = 0;

        // only take fees on buys/sells, do not take on wallet transfers

        if (takeFee) {

            // on sell

            if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {

                fees = amount.mul(sellTotalFees).div(100);

            }

            // on buy

            else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {

                fees = amount.mul(buyTotalFees).div(100);

            }



            if (fees > 0) {

                super._transfer(from, address(this), fees);

            }



            amount -= fees;

        }



        super._transfer(from, to, amount);

    }



    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth

        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = uniswapV2Router.WETH();



        _approve(address(this), address(uniswapV2Router), tokenAmount);



        // make the swap

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0, // accept any amount of ETH

            path,

            address(this),

            block.timestamp

        );

    }



    function swapBack() private {

        // Corrected to account for number guess game allocation

        uint256 contractBalance = balanceOf(address(this)) - numberGuessBalance;

        bool success;



        if (contractBalance == 0) {

            return;

        }



        if (contractBalance > swapTokensAtAmount * 20) {

            contractBalance = swapTokensAtAmount * 20;

        }



        // Halve the amount of liquidity tokens



        uint256 amountToSwapForETH = contractBalance;



        swapTokensForEth(amountToSwapForETH);



        uint256 ethForDev = (address(this).balance).div(5);

        uint256 ethforMarketing = address(this).balance;



        (success,) = address(devWallet).call{value: ethForDev}("");



        (success,) = address(marketingWallet).call{value: ethforMarketing}("");

    }

}