/**

 *  The Consumer Contract Wallet

 *  Copyright (C) 2018 The Contract Wallet Company Limited

 *

 *  This program is free software: you can redistribute it and/or modify

 *  it under the terms of the GNU General Public License as published by

 *  the Free Software Foundation, either version 3 of the License, or

 *  (at your option) any later version.



 *  This program is distributed in the hope that it will be useful,

 *  but WITHOUT ANY WARRANTY; without even the implied warranty of

 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

 *  GNU General Public License for more details.



 *  You should have received a copy of the GNU General Public License

 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.

 */



pragma solidity ^0.4.25;



/// @title The Controller interface provides access to an external list of controllers.

interface IController {

    function isController(address) external view returns (bool);

}



/// @title Controller stores a list of controller addresses that can be used for authentication in other contracts.

contract Controller is IController {

    event AddedController(address _sender, address _controller);

    event RemovedController(address _sender, address _controller);



    mapping (address => bool) private _isController;

    uint private _controllerCount;



    /// @dev Constructor initializes the list of controllers with the provided address.

    /// @param _account address to add to the list of controllers.

    constructor(address _account) public {

        _addController(_account);

    }



    /// @dev Checks if message sender is a controller.

    modifier onlyController() {

        require(isController(msg.sender), "sender is not a controller");

        _;

    }



    /// @dev Add a new controller to the list of controllers.

    /// @param _account address to add to the list of controllers.

    function addController(address _account) external onlyController {

        _addController(_account);

    }



    /// @dev Remove a controller from the list of controllers.

    /// @param _account address to remove from the list of controllers.

    function removeController(address _account) external onlyController {

        _removeController(_account);

    }



    /// @return true if the provided account is a controller.

    function isController(address _account) public view returns (bool) {

        return _isController[_account];

    }



    /// @return the current number of controllers.

    function controllerCount() public view returns (uint) {

        return _controllerCount;

    }



    /// @dev Internal-only function that adds a new controller.

    function _addController(address _account) internal {

        require(!_isController[_account], "provided account is already a controller");

        _isController[_account] = true;

        _controllerCount++;

        emit AddedController(msg.sender, _account);

    }



    /// @dev Internal-only function that removes an existing controller.

    function _removeController(address _account) internal {

        require(_isController[_account], "provided account is not a controller");

        require(_controllerCount > 1, "cannot remove the last controller");

        _isController[_account] = false;

        _controllerCount--;

        emit RemovedController(msg.sender, _account);

    }

}



/**

 * BSD 2-Clause License

 *

 * Copyright (c) 2018, True Names Limited

 * All rights reserved.

 *

 * Redistribution and use in source and binary forms, with or without

 * modification, are permitted provided that the following conditions are met:

 *

 * * Redistributions of source code must retain the above copyright notice, this

 *   list of conditions and the following disclaimer.

 *

 * * Redistributions in binary form must reproduce the above copyright notice,

 *   this list of conditions and the following disclaimer in the documentation

 *   and/or other materials provided with the distribution.

 *

 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"

 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE

 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE

 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE

 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL

 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR

 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER

 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,

 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE

 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/



interface ENS {



    // Logged when the owner of a node assigns a new owner to a subnode.

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);



    // Logged when the owner of a node transfers ownership to a new account.

    event Transfer(bytes32 indexed node, address owner);



    // Logged when the resolver for a node changes.

    event NewResolver(bytes32 indexed node, address resolver);



    // Logged when the TTL of a node changes

    event NewTTL(bytes32 indexed node, uint64 ttl);





    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public;

    function setResolver(bytes32 node, address resolver) public;

    function setOwner(bytes32 node, address owner) public;

    function setTTL(bytes32 node, uint64 ttl) public;

    function owner(bytes32 node) public view returns (address);

    function resolver(bytes32 node) public view returns (address);

    function ttl(bytes32 node) public view returns (uint64);



}



/// @title Resolver returns the controller contract address.

interface IResolver {

    function addr(bytes32) external view returns (address);

}



/// @title Controllable implements access control functionality based on a controller set in ENS.

contract Controllable {

    /// @dev _ENS points to the ENS registry smart contract.

    ENS private _ENS;

    /// @dev Is the registered ENS name of the controller contract.

    bytes32 private _node;



    /// @dev Constructor initializes the controller contract object.

    /// @param _ens is the address of the ENS.

    /// @param _controllerName is the ENS name of the Controller.

    constructor(address _ens, bytes32 _controllerName) internal {

      _ENS = ENS(_ens);

      _node = _controllerName;

    }



    /// @dev Checks if message sender is the controller.

    modifier onlyController() {

        require(_isController(msg.sender), "sender is not a controller");

        _;

    }



    /// @return true if the provided account is the controller.

    function _isController(address _account) internal view returns (bool) {

        return IController(IResolver(_ENS.resolver(_node)).addr(_node)).isController(_account);

    }

}



/// @title Date provides date parsing functionality.

contract Date {



    bytes32 constant private JANUARY = keccak256("Jan");

    bytes32 constant private FEBRUARY = keccak256("Feb");

    bytes32 constant private MARCH = keccak256("Mar");

    bytes32 constant private APRIL = keccak256("Apr");

    bytes32 constant private MAY = keccak256("May");

    bytes32 constant private JUNE = keccak256("Jun");

    bytes32 constant private JULY = keccak256("Jul");

    bytes32 constant private AUGUST = keccak256("Aug");

    bytes32 constant private SEPTEMBER = keccak256("Sep");

    bytes32 constant private OCTOBER = keccak256("Oct");

    bytes32 constant private NOVEMBER = keccak256("Nov");

    bytes32 constant private DECEMBER = keccak256("Dec");



    /// @return the number of the month based on its name.

    /// @param _month the first three letters of a month's name e.g. "Jan".

    function _monthToNumber(string _month) internal pure returns (uint8) {

        bytes32 month = keccak256(abi.encodePacked(_month));

        if (month == JANUARY) {

            return 1;

        } else if (month == FEBRUARY) {

            return 2;

        } else if (month == MARCH) {

            return 3;

        } else if (month == APRIL) {

            return 4;

        } else if (month == MAY) {

            return 5;

        } else if (month == JUNE) {

            return 6;

        } else if (month == JULY) {

            return 7;

        } else if (month == AUGUST) {

            return 8;

        } else if (month == SEPTEMBER) {

            return 9;

        } else if (month == OCTOBER) {

            return 10;

        } else if (month == NOVEMBER) {

            return 11;

        } else if (month == DECEMBER) {

            return 12;

        } else {

            revert("not a valid month");

        }

    }

}



/*

 * Copyright 2016 Nick Johnson

 *

 * Licensed under the Apache License, Version 2.0 (the "License");

 * you may not use this file except in compliance with the License.

 * You may obtain a copy of the License at

 *

 *     http://www.apache.org/licenses/LICENSE-2.0

 *

 * Unless required by applicable law or agreed to in writing, software

 * distributed under the License is distributed on an "AS IS" BASIS,

 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

 * See the License for the specific language governing permissions and

 * limitations under the License.

 */



/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <arachnid@notdot.net>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */



library strings {

    struct slice {

        uint _len;

        uint _ptr;

    }



    function memcpy(uint dest, uint src, uint len) private pure {

        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }

    }



    /*

     * @dev Returns a slice containing the entire string.

     * @param self The string to make a slice from.

     * @return A newly allocated slice containing the entire string.

     */

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;

        assembly {

            ptr := add(self, 0x20)

        }

        return slice(bytes(self).length, ptr);

    }



    /*

     * @dev Returns the length of a null-terminated bytes32 string.

     * @param self The value to find the length of.

     * @return The length of the string, from 0 to 32.

     */

    function len(bytes32 self) internal pure returns (uint) {

        uint ret;

        if (self == 0)

            return 0;

        if (self & 0xffffffffffffffffffffffffffffffff == 0) {

            ret += 16;

            self = bytes32(uint(self) / 0x100000000000000000000000000000000);

        }

        if (self & 0xffffffffffffffff == 0) {

            ret += 8;

            self = bytes32(uint(self) / 0x10000000000000000);

        }

        if (self & 0xffffffff == 0) {

            ret += 4;

            self = bytes32(uint(self) / 0x100000000);

        }

        if (self & 0xffff == 0) {

            ret += 2;

            self = bytes32(uint(self) / 0x10000);

        }

        if (self & 0xff == 0) {

            ret += 1;

        }

        return 32 - ret;

    }



    /*

     * @dev Returns a slice containing the entire bytes32, interpreted as a

     *      null-terminated utf-8 string.

     * @param self The bytes32 value to convert to a slice.

     * @return A new slice containing the value of the input argument up to the

     *         first null.

     */

    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {

        // Allocate space for `self` in memory, copy it there, and point ret at it

        assembly {

            let ptr := mload(0x40)

            mstore(0x40, add(ptr, 0x20))

            mstore(ptr, self)

            mstore(add(ret, 0x20), ptr)

        }

        ret._len = len(self);

    }



    /*

     * @dev Returns a new slice containing the same data as the current slice.

     * @param self The slice to copy.

     * @return A new slice containing the same data as `self`.

     */

    function copy(slice memory self) internal pure returns (slice memory) {

        return slice(self._len, self._ptr);

    }



    /*

     * @dev Copies a slice to a new string.

     * @param self The slice to copy.

     * @return A newly allocated string containing the slice's text.

     */

    function toString(slice memory self) internal pure returns (string memory) {

        string memory ret = new string(self._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        memcpy(retptr, self._ptr, self._len);

        return ret;

    }



    /*

     * @dev Returns the length in runes of the slice. Note that this operation

     *      takes time proportional to the length of the slice; avoid using it

     *      in loops, and call `slice.empty()` if you only need to know whether

     *      the slice is empty or not.

     * @param self The slice to operate on.

     * @return The length of the slice in runes.

     */

    function len(slice memory self) internal pure returns (uint l) {

        // Starting at ptr-31 means the LSB will be the byte we care about

        uint ptr = self._ptr - 31;

        uint end = ptr + self._len;

        for (l = 0; ptr < end; l++) {

            uint8 b;

            assembly { b := and(mload(ptr), 0xFF) }

            if (b < 0x80) {

                ptr += 1;

            } else if(b < 0xE0) {

                ptr += 2;

            } else if(b < 0xF0) {

                ptr += 3;

            } else if(b < 0xF8) {

                ptr += 4;

            } else if(b < 0xFC) {

                ptr += 5;

            } else {

                ptr += 6;

            }

        }

    }



    /*

     * @dev Returns true if the slice is empty (has a length of 0).

     * @param self The slice to operate on.

     * @return True if the slice is empty, False otherwise.

     */

    function empty(slice memory self) internal pure returns (bool) {

        return self._len == 0;

    }



    /*

     * @dev Returns a positive number if `other` comes lexicographically after

     *      `self`, a negative number if it comes before, or zero if the

     *      contents of the two slices are equal. Comparison is done per-rune,

     *      on unicode codepoints.

     * @param self The first slice to compare.

     * @param other The second slice to compare.

     * @return The result of the comparison.

     */

    function compare(slice memory self, slice memory other) internal pure returns (int) {

        uint shortest = self._len;

        if (other._len < self._len)

            shortest = other._len;



        uint selfptr = self._ptr;

        uint otherptr = other._ptr;

        for (uint idx = 0; idx < shortest; idx += 32) {

            uint a;

            uint b;

            assembly {

                a := mload(selfptr)

                b := mload(otherptr)

            }

            if (a != b) {

                // Mask out irrelevant bytes and check again

                uint256 mask = uint256(-1); // 0xffff...

                if(shortest < 32) {

                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);

                }

                uint256 diff = (a & mask) - (b & mask);

                if (diff != 0)

                    return int(diff);

            }

            selfptr += 32;

            otherptr += 32;

        }

        return int(self._len) - int(other._len);

    }



    /*

     * @dev Returns true if the two slices contain the same text.

     * @param self The first slice to compare.

     * @param self The second slice to compare.

     * @return True if the slices are equal, false otherwise.

     */

    function equals(slice memory self, slice memory other) internal pure returns (bool) {

        return compare(self, other) == 0;

    }



    /*

     * @dev Extracts the first rune in the slice into `rune`, advancing the

     *      slice to point to the next rune and returning `self`.

     * @param self The slice to operate on.

     * @param rune The slice that will contain the first rune.

     * @return `rune`.

     */

    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {

        rune._ptr = self._ptr;



        if (self._len == 0) {

            rune._len = 0;

            return rune;

        }



        uint l;

        uint b;

        // Load the first byte of the rune into the LSBs of b

        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }

        if (b < 0x80) {

            l = 1;

        } else if(b < 0xE0) {

            l = 2;

        } else if(b < 0xF0) {

            l = 3;

        } else {

            l = 4;

        }



        // Check for truncated codepoints

        if (l > self._len) {

            rune._len = self._len;

            self._ptr += self._len;

            self._len = 0;

            return rune;

        }



        self._ptr += l;

        self._len -= l;

        rune._len = l;

        return rune;

    }



    /*

     * @dev Returns the first rune in the slice, advancing the slice to point

     *      to the next rune.

     * @param self The slice to operate on.

     * @return A slice containing only the first rune from `self`.

     */

    function nextRune(slice memory self) internal pure returns (slice memory ret) {

        nextRune(self, ret);

    }



    /*

     * @dev Returns the number of the first codepoint in the slice.

     * @param self The slice to operate on.

     * @return The number of the first codepoint in the slice.

     */

    function ord(slice memory self) internal pure returns (uint ret) {

        if (self._len == 0) {

            return 0;

        }



        uint word;

        uint length;

        uint divisor = 2 ** 248;



        // Load the rune into the MSBs of b

        assembly { word:= mload(mload(add(self, 32))) }

        uint b = word / divisor;

        if (b < 0x80) {

            ret = b;

            length = 1;

        } else if(b < 0xE0) {

            ret = b & 0x1F;

            length = 2;

        } else if(b < 0xF0) {

            ret = b & 0x0F;

            length = 3;

        } else {

            ret = b & 0x07;

            length = 4;

        }



        // Check for truncated codepoints

        if (length > self._len) {

            return 0;

        }



        for (uint i = 1; i < length; i++) {

            divisor = divisor / 256;

            b = (word / divisor) & 0xFF;

            if (b & 0xC0 != 0x80) {

                // Invalid UTF-8 sequence

                return 0;

            }

            ret = (ret * 64) | (b & 0x3F);

        }



        return ret;

    }



    /*

     * @dev Returns the keccak-256 hash of the slice.

     * @param self The slice to hash.

     * @return The hash of the slice.

     */

    function keccak(slice memory self) internal pure returns (bytes32 ret) {

        assembly {

            ret := keccak256(mload(add(self, 32)), mload(self))

        }

    }



    /*

     * @dev Returns true if `self` starts with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        if (self._ptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let length := mload(needle)

            let selfptr := mload(add(self, 0x20))

            let needleptr := mload(add(needle, 0x20))

            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

        }

        return equal;

    }



    /*

     * @dev If `self` starts with `needle`, `needle` is removed from the

     *      beginning of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {

            return self;

        }



        bool equal = true;

        if (self._ptr != needle._ptr) {

            assembly {

                let length := mload(needle)

                let selfptr := mload(add(self, 0x20))

                let needleptr := mload(add(needle, 0x20))

                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

            }

        }



        if (equal) {

            self._len -= needle._len;

            self._ptr += needle._len;

        }



        return self;

    }



    /*

     * @dev Returns true if the slice ends with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        uint selfptr = self._ptr + self._len - needle._len;



        if (selfptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let length := mload(needle)

            let needleptr := mload(add(needle, 0x20))

            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

        }



        return equal;

    }



    /*

     * @dev If `self` ends with `needle`, `needle` is removed from the

     *      end of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {

            return self;

        }



        uint selfptr = self._ptr + self._len - needle._len;

        bool equal = true;

        if (selfptr != needle._ptr) {

            assembly {

                let length := mload(needle)

                let needleptr := mload(add(needle, 0x20))

                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))

            }

        }



        if (equal) {

            self._len -= needle._len;

        }



        return self;

    }



    // Returns the memory address of the first byte of the first occurrence of

    // `needle` in `self`, or the first byte after `self` if not found.

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr = selfptr;

        uint idx;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));



                bytes32 needledata;

                assembly { needledata := and(mload(needleptr), mask) }



                uint end = selfptr + selflen - needlelen;

                bytes32 ptrdata;

                assembly { ptrdata := and(mload(ptr), mask) }



                while (ptrdata != needledata) {

                    if (ptr >= end)

                        return selfptr + selflen;

                    ptr++;

                    assembly { ptrdata := and(mload(ptr), mask) }

                }

                return ptr;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := keccak256(needleptr, needlelen) }



                for (idx = 0; idx <= selflen - needlelen; idx++) {

                    bytes32 testHash;

                    assembly { testHash := keccak256(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr;

                    ptr += 1;

                }

            }

        }

        return selfptr + selflen;

    }



    // Returns the memory address of the first byte after the last occurrence of

    // `needle` in `self`, or the address of `self` if not found.

    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));



                bytes32 needledata;

                assembly { needledata := and(mload(needleptr), mask) }



                ptr = selfptr + selflen - needlelen;

                bytes32 ptrdata;

                assembly { ptrdata := and(mload(ptr), mask) }



                while (ptrdata != needledata) {

                    if (ptr <= selfptr)

                        return selfptr;

                    ptr--;

                    assembly { ptrdata := and(mload(ptr), mask) }

                }

                return ptr + needlelen;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := keccak256(needleptr, needlelen) }

                ptr = selfptr + (selflen - needlelen);

                while (ptr >= selfptr) {

                    bytes32 testHash;

                    assembly { testHash := keccak256(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr + needlelen;

                    ptr -= 1;

                }

            }

        }

        return selfptr;

    }



    /*

     * @dev Modifies `self` to contain everything from the first occurrence of

     *      `needle` to the end of the slice. `self` is set to the empty slice

     *      if `needle` is not found.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len -= ptr - self._ptr;

        self._ptr = ptr;

        return self;

    }



    /*

     * @dev Modifies `self` to contain the part of the string from the start of

     *      `self` to the end of the first occurrence of `needle`. If `needle`

     *      is not found, `self` is set to the empty slice.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len = ptr - self._ptr;

        return self;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and `token` to everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = self._ptr;

        token._len = ptr - self._ptr;

        if (ptr == self._ptr + self._len) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

            self._ptr = ptr + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and returning everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` up to the first occurrence of `delim`.

     */

    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        split(self, needle, token);

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and `token` to everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = ptr;

        token._len = self._len - (ptr - self._ptr);

        if (ptr == self._ptr) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and returning everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` after the last occurrence of `delim`.

     */

    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        rsplit(self, needle, token);

    }



    /*

     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return The number of occurrences of `needle` found in `self`.

     */

    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;

        while (ptr <= self._ptr + self._len) {

            cnt++;

            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;

        }

    }



    /*

     * @dev Returns True if `self` contains `needle`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return True if `needle` is found in `self`, false otherwise.

     */

    function contains(slice memory self, slice memory needle) internal pure returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;

    }



    /*

     * @dev Returns a newly allocated string containing the concatenation of

     *      `self` and `other`.

     * @param self The first slice to concatenate.

     * @param other The second slice to concatenate.

     * @return The concatenation of the two strings.

     */

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);

        memcpy(retptr + self._len, other._ptr, other._len);

        return ret;

    }



    /*

     * @dev Joins an array of slices, using `self` as a delimiter, returning a

     *      newly allocated string.

     * @param self The delimiter to use.

     * @param parts A list of slices to join.

     * @return A newly allocated string containing all the slices in `parts`,

     *         joined with `self`.

     */

    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {

        if (parts.length == 0)

            return "";



        uint length = self._len * (parts.length - 1);

        for(uint i = 0; i < parts.length; i++)

            length += parts[i]._len;



        string memory ret = new string(length);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        for(i = 0; i < parts.length; i++) {

            memcpy(retptr, parts[i]._ptr, parts[i]._len);

            retptr += parts[i]._len;

            if (i < parts.length - 1) {

                memcpy(retptr, self._ptr, self._len);

                retptr += self._len;

            }

        }



        return ret;

    }

}



// <ORACLIZE_API>

// Release targetted at solc 0.4.25 to silence compiler warning/error messages, compatible down to 0.4.22

/*

Copyright (c) 2015-2016 Oraclize SRL

Copyright (c) 2016 Oraclize LTD







Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:







The above copyright notice and this permission notice shall be included in

all copies or substantial portions of the Software.







THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

THE SOFTWARE.

*/



// This api is currently targeted at 0.4.22 to 0.4.25 (stable builds), please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);

}



contract OraclizeAddrResolverI {

    function getAddress() public returns (address _addr);

}



/*

Begin solidity-cborutils



https://github.com/smartcontractkit/solidity-cborutils



MIT License



Copyright (c) 2018 SmartContract ChainLink, Ltd.



Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in all

copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

SOFTWARE.

 */



library Buffer {

    struct buffer {

        bytes buf;

        uint capacity;

    }



    function init(buffer memory buf, uint _capacity) internal pure {

        uint capacity = _capacity;

        if(capacity % 32 != 0) capacity += 32 - (capacity % 32);

        // Allocate space for the buffer data

        buf.capacity = capacity;

        assembly {

            let ptr := mload(0x40)

            mstore(buf, ptr)

            mstore(ptr, 0)

            mstore(0x40, add(ptr, capacity))

        }

    }



    function resize(buffer memory buf, uint capacity) private pure {

        bytes memory oldbuf = buf.buf;

        init(buf, capacity);

        append(buf, oldbuf);

    }



    function max(uint a, uint b) private pure returns(uint) {

        if(a > b) {

            return a;

        }

        return b;

    }



    /**

     * @dev Appends a byte array to the end of the buffer. Resizes if doing so

     *      would exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, bytes data) internal pure returns(buffer memory) {

        if(data.length + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, data.length) * 2);

        }



        uint dest;

        uint src;

        uint len = data.length;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Start address = buffer address + buffer length + sizeof(buffer length)

            dest := add(add(bufptr, buflen), 32)

            // Update buffer length

            mstore(bufptr, add(buflen, mload(data)))

            src := add(data, 32)

        }



        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }



        return buf;

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, uint8 data) internal pure {

        if(buf.buf.length + 1 > buf.capacity) {

            resize(buf, buf.capacity * 2);

        }



        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length)

            let dest := add(add(bufptr, buflen), 32)

            mstore8(dest, data)

            // Update buffer length

            mstore(bufptr, add(buflen, 1))

        }

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {

        if(len + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, len) * 2);

        }



        uint mask = 256 ** len - 1;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length) + len

            let dest := add(add(bufptr, buflen), len)

            mstore(dest, or(and(mload(dest), not(mask)), data))

            // Update buffer length

            mstore(bufptr, add(buflen, len))

        }

        return buf;

    }

}



library CBOR {

    using Buffer for Buffer.buffer;



    uint8 private constant MAJOR_TYPE_INT = 0;

    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;

    uint8 private constant MAJOR_TYPE_BYTES = 2;

    uint8 private constant MAJOR_TYPE_STRING = 3;

    uint8 private constant MAJOR_TYPE_ARRAY = 4;

    uint8 private constant MAJOR_TYPE_MAP = 5;

    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;



    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {

        if(value <= 23) {

            buf.append(uint8((major << 5) | value));

        } else if(value <= 0xFF) {

            buf.append(uint8((major << 5) | 24));

            buf.appendInt(value, 1);

        } else if(value <= 0xFFFF) {

            buf.append(uint8((major << 5) | 25));

            buf.appendInt(value, 2);

        } else if(value <= 0xFFFFFFFF) {

            buf.append(uint8((major << 5) | 26));

            buf.appendInt(value, 4);

        } else if(value <= 0xFFFFFFFFFFFFFFFF) {

            buf.append(uint8((major << 5) | 27));

            buf.appendInt(value, 8);

        }

    }



    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {

        buf.append(uint8((major << 5) | 31));

    }



    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {

        encodeType(buf, MAJOR_TYPE_INT, value);

    }



    function encodeInt(Buffer.buffer memory buf, int value) internal pure {

        if(value >= 0) {

            encodeType(buf, MAJOR_TYPE_INT, uint(value));

        } else {

            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));

        }

    }



    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {

        encodeType(buf, MAJOR_TYPE_BYTES, value.length);

        buf.append(value);

    }



    function encodeString(Buffer.buffer memory buf, string value) internal pure {

        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);

        buf.append(bytes(value));

    }



    function startArray(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);

    }



    function startMap(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);

    }



    function endSequence(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);

    }

}



/*

End solidity-cborutils

 */



contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Android = 0x40;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_consensys = 161;



    OraclizeAddrResolverI OAR;



    OraclizeI oraclize;

    modifier oraclizeAPI {

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))

            oraclize_setNetwork(networkID_auto);



        if(address(oraclize) != OAR.getAddress())

            oraclize = OraclizeI(OAR.getAddress());



        _;

    }

    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

      return oraclize_setNetwork();

      networkID; // silence the warning and remain backwards compatible

    }

    function oraclize_setNetwork() internal returns(bool){

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 myid, string result) public {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) public {

      return;

      // Following should never be reached with a preceding return, however

      // this is just a placeholder function, ideally meant to be defined in

      // child contract when proofs are used

      myid; result; proof; // Silence compiler warnings

      oraclize = OraclizeI(0); // Additional compiler silence about making function pure/view. 

    }



    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource);

    }



    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource, gaslimit);

    }



    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(0, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(timestamp, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(0, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_cbAddress() oraclizeAPI internal returns (address){

        return oraclize.cbAddress();

    }

    function oraclize_setProof(byte proofP) oraclizeAPI internal {

        return oraclize.setProofType(proofP);

    }

    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) view internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal pure returns (address){

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i=2; i<2+2*20; i+=2){

            iaddr *= 256;

            b1 = uint160(tmp[i]);

            b2 = uint160(tmp[i+1]);

            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;

            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;

            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;

            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;

            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;

            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;

            iaddr += (b1*16+b2);

        }

        return address(iaddr);

    }



    function strCompare(string _a, string _b) internal pure returns (int) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) minLength = b.length;

        for (uint i = 0; i < minLength; i ++)

            if (a[i] < b[i])

                return -1;

            else if (a[i] > b[i])

                return 1;

        if (a.length < b.length)

            return -1;

        else if (a.length > b.length)

            return 1;

        else

            return 0;

    }



    function indexOf(string _haystack, string _needle) internal pure returns (int) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if(h.length < 1 || n.length < 1 || (n.length > h.length))

            return -1;

        else if(h.length > (2**128 -1))

            return -1;

        else

        {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i ++)

            {

                if (h[i] == n[0])

                {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])

                    {

                        subindex++;

                    }

                    if(subindex == n.length)

                        return int(i);

                }

            }

            return -1;

        }

    }



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);

    }



    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal pure returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal pure returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i=0; i<bresult.length; i++){

            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                if (decimals){

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(bresult[i]) - 48;

            } else if (bresult[i] == 46) decimals = true;

        }

        if (_b > 0) mint *= 10**_b;

        return mint;

    }



    function uint2str(uint i) internal pure returns (string){

        if (i == 0) return "0";

        uint j = i;

        uint len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }



    using CBOR for Buffer.buffer;

    function stra2cbor(string[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeString(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function ba2cbor(bytes[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeBytes(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string) {

        return oraclize_network_name;

    }



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        require((_nbytes > 0) && (_nbytes <= 32));

        // Convert from seconds to ledger timer ticks

        _delay *= 10;

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            // the following variables can be relaxed

            // check relaxed random contract under ethereum-examples repo

            // for an idea on how to override and replace comit hash vars

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes memory delay = new bytes(32);

        assembly {

            mstore(add(delay, 0x20), _delay)

        }



        bytes memory delay_bytes8 = new bytes(8);

        copyBytes(delay, 24, 8, delay_bytes8, 0);



        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];

        bytes32 queryId = oraclize_query("random", args, _customGasLimit);



        bytes memory delay_bytes8_left = new bytes(8);



        assembly {

            let x := mload(add(delay_bytes8, 0x20))

            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))



        }



        oraclize_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));

        return queryId;

    }



    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {

        oraclize_randomDS_args[queryId] = commitment;

    }



    mapping(bytes32=>bytes32) oraclize_randomDS_args;

    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;



    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){

        bool sigok;

        address signer;



        bytes32 sigr;

        bytes32 sigs;



        bytes memory sigr_ = new bytes(32);

        uint offset = 4+(uint(dersig[3]) - 0x20);

        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);



        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }





        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);

        if (address(keccak256(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(keccak256(pubkey)) == signer);

        }

    }



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {

        bool sigok;



        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);

        copyBytes(proof, sig2offset, sig2.length, sig2, 0);



        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);



        bytes memory tosign2 = new bytes(1+65+32);

        tosign2[0] = byte(1); //role

        copyBytes(proof, sig2offset-65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);



        if (sigok == false) return false;





        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";



        bytes memory tosign3 = new bytes(1+65);

        tosign3[0] = 0xFE;

        copyBytes(proof, 3, 65, tosign3, 1);



        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);

        copyBytes(proof, 3+65, sig3.length, sig3, 0);



        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);



        return sigok;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);



        _;

    }



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;



        return 0;

    }



    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){

        bool match_ = true;



        require(prefix.length == n_random_bytes);



        for (uint256 i=0; i< n_random_bytes; i++) {

            if (content[i] != prefix[i]) match_ = false;

        }



        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){



        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(context_name, queryId)))))) return false;



        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);



        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;



        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);



        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);



        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;





        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;



        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }



        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {

        uint minLength = length + toOffset;



        // Buffer too small

        require(to.length >= minLength); // Should be a better way?



        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint i = 32 + fromOffset;

        uint j = 32 + toOffset;



        while (i < (32 + fromOffset + length)) {

            assembly {

                let tmp := mload(add(from, i))

                mstore(add(to, j), tmp)

            }

            i += 32;

            j += 32;

        }



        return to;

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    // Duplicate Solidity's ecrecover, but catching the CALL return value

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {

        // We do our own memory management here. Solidity uses memory offset

        // 0x40 to store the current end of memory. We write past it (as

        // writes are memory extensions), but don't update the offset so

        // Solidity will reuse it. The memory used here is only needed for

        // this context.



        // FIXME: inline assembly can't access return values

        bool ret;

        address addr;



        assembly {

            let size := mload(0x40)

            mstore(size, hash)

            mstore(add(size, 32), v)

            mstore(add(size, 64), r)

            mstore(add(size, 96), s)



            // NOTE: we can reuse the request memory because we deal with

            //       the return code

            ret := call(3000, 1, 0, size, 128, size, 32)

            addr := mload(size)

        }



        return (ret, addr);

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        if (sig.length != 65)

          return (false, 0);



        // The signature format is a compact form of:

        //   {bytes32 r}{bytes32 s}{uint8 v}

        // Compact means, uint8 is not padded to 32 bytes.

        assembly {

            r := mload(add(sig, 32))

            s := mload(add(sig, 64))



            // Here we are loading the last 32 bytes. We exploit the fact that

            // 'mload' will pad with zeroes if we overread.

            // There is no 'mload8' to do this, but that would be nicer.

            v := byte(0, mload(add(sig, 96)))



            // Alternative solution:

            // 'byte' is not working due to the Solidity parser, so lets

            // use the second best option, 'and'

            // v := and(mload(add(sig, 65)), 255)

        }



        // albeit non-transactional signatures are not specified by the YP, one would expect it

        // to match the YP range of [27, 28]

        //

        // geth uses [0, 1] and some clients have followed. This might change, see:

        //  https://github.com/ethereum/go-ethereum/issues/2053

        if (v < 27)

          v += 27;



        if (v != 27 && v != 28)

            return (false, 0);



        return safer_ecrecover(hash, v, r, s);

    }



    function safeMemoryCleaner() internal pure {

        assembly {

            let fmem := mload(0x40)

            codecopy(fmem, codesize, sub(msize, fmem))

        }

    }



}

// </ORACLIZE_API>



/// @title JSON provides JSON parsing functionality.

contract JSON is usingOraclize{

    using strings for *;



    bytes32 constant private prefixHash = keccak256("{\"ETH\":");



    /// @dev Extracts JSON rate value from the response object.

    /// @param _json body of the JSON response from the CryptoCompare API.

    function parseRate(string _json) public pure returns (string) {



        uint json_len = abi.encodePacked(_json).length;

        //{"ETH":}.length = 8, assuming a (maximum of) 18 digit prevision

        require(json_len > 8 && json_len <= 28, "misformatted input");



        bytes memory jsonPrefix = new bytes(7);

        copyBytes(abi.encodePacked(_json), 0, 7, jsonPrefix, 0);

        require(keccak256(jsonPrefix) == prefixHash, "prefix mismatch");



        strings.slice memory body = _json.toSlice();

        body.split(":".toSlice()); //we are sure that ':' is included in the string, body now contains the rate+'}'

        json_len = body._len;

        body.until("}".toSlice());

        require(body._len == json_len-1,"not json format"); //ensure that the json is properly terminated with a '}'

        return body.toString();



    }

}



/**

 * The MIT License (MIT)

 * 

 * Copyright (c) 2016 Smart Contract Solutions, Inc.

 * 

 * Permission is hereby granted, free of charge, to any person obtaining

 * a copy of this software and associated documentation files (the

 * "Software"), to deal in the Software without restriction, including

 * without limitation the rights to use, copy, modify, merge, publish,

 * distribute, sublicense, and/or sell copies of the Software, and to

 * permit persons to whom the Software is furnished to do so, subject to

 * the following conditions:

 * 

 * The above copyright notice and this permission notice shall be included

 * in all copies or substantial portions of the Software.

 * 

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS

 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF

 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY

 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,

 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE

 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



/// @title ParseIntScientific provides floating point in scientific notation (e.g. e-5) parsing functionality.

contract ParseIntScientific {



    using SafeMath for uint256;



    byte constant private PLUS_ASCII = byte(43); //decimal value of '+'

    byte constant private DASH_ASCII = byte(45); //decimal value of '-'

    byte constant private DOT_ASCII = byte(46); //decimal value of '.'

    byte constant private ZERO_ASCII = byte(48); //decimal value of '0'

    byte constant private NINE_ASCII = byte(57); //decimal value of '9'

    byte constant private E_ASCII = byte(69); //decimal value of 'E'

    byte constant private e_ASCII = byte(101); //decimal value of 'e'



    /// @dev ParseIntScientific delegates the call to _parseIntScientific(string, uint) with the 2nd argument being 0.

    function _parseIntScientific(string _inString) internal pure returns (uint) {

        return _parseIntScientific(_inString, 0);

    }



    /// @dev ParseIntScientificWei parses a rate expressed in ETH and returns its wei denomination

    function _parseIntScientificWei(string _inString) internal pure returns (uint) {

        return _parseIntScientific(_inString, 18);

    }



    /// @dev ParseIntScientific parses a JSON standard - floating point number.

    /// @param _inString is input string.

    /// @param _magnitudeMult multiplies the number with 10^_magnitudeMult.

    function _parseIntScientific(string _inString, uint _magnitudeMult) internal pure returns (uint) {



        bytes memory inBytes = bytes(_inString);

        uint mint = 0; // the final uint returned

        uint mintDec = 0; // the uint following the decimal point

        uint mintExp = 0; // the exponent

        uint decMinted = 0; // how many decimals were 'minted'.

        uint expIndex = 0; // the position in the byte array that 'e' was found (if found)

        bool integral = false; // indicates the existence of the integral part, it should always exist (even if 0) e.g. 'e+1'  or '.1' is not valid

        bool decimals = false; // indicates a decimal number, set to true if '.' is found

        bool exp = false; // indicates if the number being parsed has an exponential representation

        bool minus = false; // indicated if the exponent is negative

        bool plus = false; // indicated if the exponent is positive



        for (uint i = 0; i < inBytes.length; i++) {

            if ((inBytes[i] >= ZERO_ASCII) && (inBytes[i] <= NINE_ASCII) && (!exp)) {

                // 'e' not encountered yet, minting integer part or decimals

                if (decimals) {

                    // '.' encountered

                    //use safeMath in case there is an overflow

                    mintDec = mintDec.mul(10);

                    mintDec = mintDec.add(uint(inBytes[i]) - uint(ZERO_ASCII));

                    decMinted++; //keep track of the #decimals

                } else {

                    // integral part (before '.')

                    integral = true;

                    //use safeMath in case there is an overflow

                    mint = mint.mul(10);

                    mint = mint.add(uint(inBytes[i]) - uint(ZERO_ASCII));

                }

            } else if ((inBytes[i] >= ZERO_ASCII) && (inBytes[i] <= NINE_ASCII) && (exp)) {

                //exponential notation (e-/+) has been detected, mint the exponent

                mintExp = mintExp.mul(10);

                mintExp = mintExp.add(uint(inBytes[i]) - uint(ZERO_ASCII));

            } else if (inBytes[i] == DOT_ASCII) {

                //an integral part before should always exist before '.'

                require(integral, "missing integral part");

                // an extra decimal point makes the format invalid

                require(!decimals, "duplicate decimal point");

                //the decimal point should always be before the exponent

                require(!exp, "decimal after exponent");

                decimals = true;

            } else if (inBytes[i] == DASH_ASCII) {

                // an extra '-' should be considered an invalid character

                require(!minus, "duplicate -");

                require(!plus, "extra sign");

                require(expIndex + 1 == i, "- sign not immediately after e");

                minus = true;

            } else if (inBytes[i] == PLUS_ASCII) {

                // an extra '+' should be considered an invalid character

                require(!plus, "duplicate +");

                require(!minus, "extra sign");

                require(expIndex + 1 == i, "+ sign not immediately after e");

                plus = true;

            } else if ((inBytes[i] == E_ASCII) || (inBytes[i] == e_ASCII)) {

                //an integral part before should always exist before 'e'

                require(integral, "missing integral part");

                // an extra 'e' or 'E' should be considered an invalid character

                require(!exp, "duplicate exponent symbol");

                exp = true;

                expIndex = i;

            } else {

                revert("invalid digit");

            }

        }



        if (minus || plus) {

            // end of string e[x|-] without specifying the exponent

            require(i > expIndex + 2);

        } else if (exp) {

            // end of string (e) without specifying the exponent

            require(i > expIndex + 1);

        }



        if (minus) {

            // e^(-x)

            if (mintExp >= _magnitudeMult) {

                // the (negative) exponent is bigger than the given parameter for "shifting left".

                // use integer division to reduce the precision.

                require(mintExp - _magnitudeMult < 78, "exponent > 77"); //

                mint /= 10 ** (mintExp - _magnitudeMult);

                return mint;



            } else {

                // the (negative) exponent is smaller than the given parameter for "shifting left".

                //no need for underflow check

                _magnitudeMult = _magnitudeMult - mintExp;

            }

        } else {

            // e^(+x), positive exponent or no exponent

            // just shift left as many times as indicated by the exponent and the shift parameter

            _magnitudeMult = _magnitudeMult.add(mintExp);

          }



          if (_magnitudeMult >= decMinted) {

              // the decimals are fewer or equal than the shifts: use all of them

              // shift number and add the decimals at the end

              // include decimals if present in the original input

              require(decMinted < 78, "more than 77 decimal digits parsed"); //

              mint = mint.mul(10 ** (decMinted));

              mint = mint.add(mintDec);

              //// add zeros at the end if the decimals were fewer than #_magnitudeMult

              require(_magnitudeMult - decMinted < 78, "exponent > 77"); //

              mint = mint.mul(10 ** (_magnitudeMult - decMinted));

          } else {

              // the decimals are more than the #_magnitudeMult shifts

              // use only the ones needed, discard the rest

              decMinted -= _magnitudeMult;

              require(decMinted < 78, "more than 77 decimal digits parsed"); //

              mintDec /= 10 ** (decMinted);

              // shift number and add the decimals at the end

              require(_magnitudeMult < 78, "more than 77 decimal digits parsed"); //

              mint = mint.mul(10 ** (_magnitudeMult));

              mint = mint.add(mintDec);

          }



        return mint;

    }

}



/**

 * This method was modified from the GPLv3 solidity code found in this repository

 * https://github.com/vcealicu/melonport-price-feed/blob/master/pricefeed/PriceFeed.sol

 */



/// @title Base64 provides base 64 decoding functionality.

contract Base64 {

    bytes constant BASE64_DECODE_CHAR = hex"000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e003e003f3435363738393a3b3c3d00000000000000000102030405060708090a0b0c0d0e0f10111213141516171819000000003f001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f30313233";



    /// @return decoded array of bytes.

    /// @param _encoded base 64 encoded array of bytes.

    function _base64decode(bytes _encoded) internal pure returns (bytes) {

        byte v1;

        byte v2;

        byte v3;

        byte v4;

        uint length = _encoded.length;

        bytes memory result = new bytes(length);

        uint index;



        // base64 encoded strings can't be length 0 and they must be divisble by 4

        require(length > 0  && length % 4 == 0, "invalid base64 encoding");



          if (keccak256(abi.encodePacked(_encoded[length - 2])) == keccak256("=")) {

              length -= 2;

          } else if (keccak256(abi.encodePacked(_encoded[length - 1])) == keccak256("=")) {

              length -= 1;

          }

          uint count = length >> 2 << 2;

          for (uint i = 0; i < count;) {

              v1 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              v2 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              v3 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              v4 = BASE64_DECODE_CHAR[uint(_encoded[i++])];



              result[index++] = (v1 << 2 | v2 >> 4) & 255;

              result[index++] = (v2 << 4 | v3 >> 2) & 255;

              result[index++] = (v3 << 6 | v4) & 255;

          }

          if (length - count == 2) {

              v1 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              v2 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              result[index++] = (v1 << 2 | v2 >> 4) & 255;

          } else if (length - count == 3) {

              v1 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              v2 = BASE64_DECODE_CHAR[uint(_encoded[i++])];

              v3 = BASE64_DECODE_CHAR[uint(_encoded[i++])];



              result[index++] = (v1 << 2 | v2 >> 4) & 255;

              result[index++] = (v2 << 4 | v3 >> 2) & 255;

          }



        // Set to correct length.

        assembly {

            mstore(result, index)

        }



        return result;

    }

}





/// @title Oracle converts ERC20 token amounts into equivalent ether amounts based on cryptocurrency exchange rates.

interface IOracle {

    function convert(address, uint) external view returns (bool, uint);

}





/// @title Oracle provides asset exchange rates and conversion functionality.

contract Oracle is usingOraclize, Base64, Date, JSON, Controllable, ParseIntScientific, IOracle {

    using strings for *;

    using SafeMath for uint256;





    /*******************/

    /*     Events     */

    /*****************/



    event AddedToken(address _sender, address _token, string _symbol, uint _magnitude);

    event RemovedToken(address _sender, address _token);

    event UpdatedTokenRate(address _sender, address _token, uint _rate);



    event SetGasPrice(address _sender, uint _gasPrice);

    event Converted(address _sender, address _token, uint _amount, uint _ether);



    event RequestedUpdate(string _symbol);

    event FailedUpdateRequest(string _reason);



    event VerifiedProof(bytes _publicKey, string _result);



    event SetCryptoComparePublicKey(address _sender, bytes _publicKey);



    /**********************/

    /*     Constants     */

    /********************/



    uint constant private PROOF_LEN = 165;

    uint constant private ECDSA_SIG_LEN = 65;

    uint constant private ENCODING_BYTES = 2;

    uint constant private HEADERS_LEN = PROOF_LEN - 2 * ENCODING_BYTES - ECDSA_SIG_LEN; // 2 bytes encoding headers length + 2 for signature.

    uint constant private DIGEST_BASE64_LEN = 44; //base64 encoding of the SHA256 hash (32-bytes) of the result: fixed length.

    uint constant private DIGEST_OFFSET = HEADERS_LEN - DIGEST_BASE64_LEN; // the starting position of the result hash in the headers string.



    uint constant private MAX_BYTE_SIZE = 256; //for calculating length encoding



    struct Token {

        string symbol;    // Token symbol

        uint magnitude;   // 10^decimals

        uint rate;        // Token exchange rate in wei

        uint lastUpdate;  // Time of the last rate update

        bool exists;      // Flags if the struct is empty or not

    }



    mapping(address => Token) public tokens;

    address[] private _tokenAddresses;



    bytes public APIPublicKey;

    mapping(bytes32 => address) private _queryToToken;



    /// @dev Construct the oracle with multiple controllers, address resolver and custom gas price.

    /// @dev _resolver is the oraclize address resolver contract address.

    /// @param _ens is the address of the ENS.

    /// @param _controllerName is the ENS name of the Controller.

    constructor(address _resolver, address _ens, bytes32 _controllerName) Controllable(_ens, _controllerName) public {

        APIPublicKey = hex"a0f4f688350018ad1b9785991c0bde5f704b005dc79972b114dbed4a615a983710bfc647ebe5a320daa28771dce6a2d104f5efa2e4a85ba3760b76d46f8571ca";

        OAR = OraclizeAddrResolverI(_resolver);

        oraclize_setCustomGasPrice(10000000000);

        oraclize_setProof(proofType_Native);

    }



    /// @dev Updates the Crypto Compare public API key.

    function updateAPIPublicKey(bytes _publicKey) external onlyController {

        APIPublicKey = _publicKey;

        emit SetCryptoComparePublicKey(msg.sender, _publicKey);

    }



    /// @dev Sets the gas price used by oraclize query.

    function setCustomGasPrice(uint _gasPrice) external onlyController {

        oraclize_setCustomGasPrice(_gasPrice);

        emit SetGasPrice(msg.sender, _gasPrice);

    }



    /// @dev Convert ERC20 token amount to the corresponding ether amount (used by the wallet contract).

    /// @param _token ERC20 token contract address.

    /// @param _amount amount of token in base units.

    function convert(address _token, uint _amount) external view returns (bool, uint) {

        // Store the token in memory to save map entry lookup gas.

        Token storage token = tokens[_token];

        // If the token exists require that its rate is not zero

        if (token.exists) {

            require(token.rate != 0, "token rate is 0");

            // Safely convert the token amount to ether based on the exchange rate.

            // return the value and a 'true' implying that the token is protected

            return (true, _amount.mul(token.rate).div(token.magnitude));

        }

        // this returns a 'false' to imply that a card is not protected 

        return (false, 0);

        

    }



    /// @dev Add ERC20 tokens to the list of supported tokens.

    /// @param _tokens ERC20 token contract addresses.

    /// @param _symbols ERC20 token names.

    /// @param _magnitude 10 to the power of number of decimal places used by each ERC20 token.

    /// @param _updateDate date for the token updates. This will be compared to when oracle updates are received.

    function addTokens(address[] _tokens, bytes32[] _symbols, uint[] _magnitude, uint _updateDate) external onlyController {

        // Require that all parameters have the same length.

        require(_tokens.length == _symbols.length && _tokens.length == _magnitude.length, "parameter lengths do not match");

        // Add each token to the list of supported tokens.

        for (uint i = 0; i < _tokens.length; i++) {

            // Require that the token doesn't already exist.

            address token = _tokens[i];

            require(!tokens[token].exists, "token already exists");

            // Store the intermediate values.

            string memory symbol = _symbols[i].toSliceB32().toString();

            uint magnitude = _magnitude[i];

            // Add the token to the token list.

            tokens[token] = Token({

                symbol : symbol,

                magnitude : magnitude,

                rate : 0,

                exists : true,

                lastUpdate: _updateDate

            });

            // Add the token address to the address list.

            _tokenAddresses.push(token);

            // Emit token addition event.

            emit AddedToken(msg.sender, token, symbol, magnitude);

        }

    }



    /// @dev Remove ERC20 tokens from the list of supported tokens.

    /// @param _tokens ERC20 token contract addresses.

    function removeTokens(address[] _tokens) external onlyController {

        // Delete each token object from the list of supported tokens based on the addresses provided.

        for (uint i = 0; i < _tokens.length; i++) {

            //token must exist, reverts on duplicates as well

            require(tokens[_tokens[i]].exists, "token does not exist");

            // Store the token address.

            address token = _tokens[i];

            // Delete the token object.

            delete tokens[token];

            // Remove the token address from the address list.

            for (uint j = 0; j < _tokenAddresses.length.sub(1); j++) {

                if (_tokenAddresses[j] == token) {

                    _tokenAddresses[j] = _tokenAddresses[_tokenAddresses.length.sub(1)];

                    break;

                }

            }

            _tokenAddresses.length--;

            // Emit token removal event.

            emit RemovedToken(msg.sender, token);

        }

    }



    /// @dev Update ERC20 token exchange rate manually.

    /// @param _token ERC20 token contract address.

    /// @param _rate ERC20 token exchange rate in wei.

    /// @param _updateDate date for the token updates. This will be compared to when oracle updates are received.

    function updateTokenRate(address _token, uint _rate, uint _updateDate) external onlyController {

        // Require that the token exists.

        require(tokens[_token].exists, "token does not exist");

        // Update the token's rate.

        tokens[_token].rate = _rate;

        // Update the token's last update timestamp.

        tokens[_token].lastUpdate = _updateDate;

        // Emit the rate update event.

        emit UpdatedTokenRate(msg.sender, _token, _rate);

    }



    /// @dev Update ERC20 token exchange rates for all supported tokens.

    //// @param _gasLimit the gas limit is passed, this is used for the Oraclize callback

    function updateTokenRates(uint _gasLimit) external payable onlyController {

        _updateTokenRates(_gasLimit);

    }



    //// @dev Withdraw ether from the smart contract to the specified account.

    function withdraw(address _to, uint _amount) external onlyController {

        _to.transfer(_amount);

    }



    //// @dev Handle Oraclize query callback and verifiy the provided origin proof.

    //// @param _queryID Oraclize query ID.

    //// @param _result query result in JSON format.

    //// @param _proof origin proof from crypto compare.

    // solium-disable-next-line mixedcase

    function __callback(bytes32 _queryID, string _result, bytes _proof) public {

        // Require that the caller is the Oraclize contract.

        require(msg.sender == oraclize_cbAddress(), "sender is not oraclize");

        // Use the query ID to find the matching token address.

        address _token = _queryToToken[_queryID];

        require(_token != address(0), "queryID matches to address 0");

        // Get the corresponding token object.

        Token storage token = tokens[_token];



        bool valid;

        uint timestamp;

        (valid, timestamp) = _verifyProof(_result, _proof, APIPublicKey, token.lastUpdate);



        // Require that the proof is valid.

        if (valid) {

            // Parse the JSON result to get the rate in wei.

            token.rate = _parseIntScientificWei(parseRate(_result));

            // Set the update time of the token rate.

            token.lastUpdate = timestamp;

            // Remove query from the list.

            delete _queryToToken[_queryID];

            // Emit the rate update event.

            emit UpdatedTokenRate(msg.sender, _token, token.rate);

        }

    }



    /// @dev Re-usable helper function that performs the Oraclize Query.

    //// @param _gasLimit the gas limit is passed, this is used for the Oraclize callback

    function _updateTokenRates(uint _gasLimit) private {

        // Check if there are any existing tokens.

        if (_tokenAddresses.length == 0) {

            // Emit a query failure event.

            emit FailedUpdateRequest("no tokens");

        // Check if the contract has enough Ether to pay for the query.

        } else if (oraclize_getPrice("URL") * _tokenAddresses.length > address(this).balance) {

            // Emit a query failure event.

            emit FailedUpdateRequest("insufficient balance");

        } else {

            // Set up the cryptocompare API query strings.

            strings.slice memory apiPrefix = "https://min-api.cryptocompare.com/data/price?fsym=".toSlice();

            strings.slice memory apiSuffix = "&tsyms=ETH&sign=true".toSlice();



            // Create a new oraclize query for each supported token.

            for (uint i = 0; i < _tokenAddresses.length; i++) {

                // Store the token symbol used in the query.

                strings.slice memory symbol = tokens[_tokenAddresses[i]].symbol.toSlice();

                // Create a new oraclize query from the component strings.

                bytes32 queryID = oraclize_query("URL", apiPrefix.concat(symbol).toSlice().concat(apiSuffix), _gasLimit);

                // Store the query ID together with the associated token address.

                _queryToToken[queryID] = _tokenAddresses[i];

                // Emit the query success event.

                emit RequestedUpdate(symbol.toString());

            }

        }

    }



    /// @dev Verify the origin proof returned by the cryptocompare API.

    /// @param _result query result in JSON format.

    /// @param _proof origin proof from cryptocompare.

    /// @param _publicKey cryptocompare public key.

    /// @param _lastUpdate timestamp of the last time the requested token was updated.

    function _verifyProof(string _result, bytes _proof, bytes _publicKey, uint _lastUpdate) private returns (bool, uint) {



        //expecting fixed length proofs

        if (_proof.length != PROOF_LEN)

          revert("invalid proof length");



        //proof should be 65 bytes long: R (32 bytes) + S (32 bytes) + v (1 byte)

        if (uint(_proof[1]) != ECDSA_SIG_LEN)

          revert("invalid signature length");



        bytes memory signature = new bytes(ECDSA_SIG_LEN);



        signature = copyBytes(_proof, 2, ECDSA_SIG_LEN, signature, 0);



        // Extract the headers, big endian encoding of headers length

        if (uint(_proof[ENCODING_BYTES + ECDSA_SIG_LEN]) * MAX_BYTE_SIZE + uint(_proof[ENCODING_BYTES + ECDSA_SIG_LEN + 1]) != HEADERS_LEN)

          revert("invalid headers length");



        bytes memory headers = new bytes(HEADERS_LEN);

        headers = copyBytes(_proof, 2*ENCODING_BYTES + ECDSA_SIG_LEN, HEADERS_LEN, headers, 0);



        // Check if the signature is valid and if the signer address is matching.

        if (!_verifySignature(headers, signature, _publicKey)) {

            revert("invalid signature");

        }



        // Check if the date is valid.

        bytes memory dateHeader = new bytes(20);

        //keep only the relevant string(e.g. "16 Nov 2018 16:22:18")

        dateHeader = copyBytes(headers, 11, 20, dateHeader, 0);



        bool dateValid;

        uint timestamp;

        (dateValid, timestamp) = _verifyDate(string(dateHeader), _lastUpdate);



        // Check whether the date returned is valid or not

        if (!dateValid)

            revert("invalid date");



        // Check if the signed digest hash matches the result hash.

        bytes memory digest = new bytes(DIGEST_BASE64_LEN);

        digest = copyBytes(headers, DIGEST_OFFSET, DIGEST_BASE64_LEN, digest, 0);



        if (keccak256(abi.encodePacked(sha256(abi.encodePacked(_result)))) != keccak256(_base64decode(digest)))

          revert("result hash not matching");



        emit VerifiedProof(_publicKey, _result);

        return (true, timestamp);

    }



    /// @dev Verify the HTTP headers and the signature

    /// @param _headers HTTP headers provided by the cryptocompare api

    /// @param _signature signature provided by the cryptocompare api

    /// @param _publicKey cryptocompare public key.

    function _verifySignature(bytes _headers, bytes _signature, bytes _publicKey) private returns (bool) {

        address signer;

        bool signatureOK;



        // Checks if the signature is valid by hashing the headers

        (signatureOK, signer) = ecrecovery(sha256(_headers), _signature);

        return signatureOK && signer == address(keccak256(_publicKey));

    }



    /// @dev Verify the signed HTTP date header.

    /// @param _dateHeader extracted date string e.g. Wed, 12 Sep 2018 15:18:14 GMT.

    /// @param _lastUpdate timestamp of the last time the requested token was updated.

    function _verifyDate(string _dateHeader, uint _lastUpdate) private pure returns (bool, uint) {



        //called by verifyProof(), _dateHeader is always a string of length = 20

        assert(abi.encodePacked(_dateHeader).length == 20);



        //Split the date string and get individual date components.

        strings.slice memory date = _dateHeader.toSlice();

        strings.slice memory timeDelimiter = ":".toSlice();

        strings.slice memory dateDelimiter = " ".toSlice();



        uint day = _parseIntScientific(date.split(dateDelimiter).toString());

        require(day > 0 && day < 32, "day error");



        uint month = _monthToNumber(date.split(dateDelimiter).toString());

        require(month > 0 && month < 13, "month error");



        uint year = _parseIntScientific(date.split(dateDelimiter).toString());

        require(year > 2017 && year < 3000, "year error");



        uint hour = _parseIntScientific(date.split(timeDelimiter).toString());

        require(hour < 25, "hour error");



        uint minute = _parseIntScientific(date.split(timeDelimiter).toString());

        require(minute < 60, "minute error");



        uint second = _parseIntScientific(date.split(timeDelimiter).toString());

        require(second < 60, "second error");



        uint timestamp = year * (10 ** 10) + month * (10 ** 8) + day * (10 ** 6) + hour * (10 ** 4) + minute * (10 ** 2) + second;



        return (timestamp > _lastUpdate, timestamp);

    }

}



/// @title Ownable has an owner address and provides basic authorization control functions.

/// This contract is modified version of the MIT OpenZepplin Ownable contract 

/// This contract doesn't allow for multiple changeOwner operations

/// https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol

contract Ownable {

    event TransferredOwnership(address _from, address _to);



    address private _owner;

    bool private _isTransferable;



    /// @dev Constructor sets the original owner of the contract and whether or not it is one time transferable.

    constructor(address _account, bool _transferable) internal {

        _owner = _account;

        _isTransferable = _transferable;

        emit TransferredOwnership(address(0), _account);

    }



    /// @dev Reverts if called by any account other than the owner.

    modifier onlyOwner() {

        require(_isOwner(), "sender is not an owner");

        _;

    }



    /// @dev Allows the current owner to transfer control of the contract to a new address.

    /// @param _account address to transfer ownership to.

    function transferOwnership(address _account) external onlyOwner {

        // Require that the ownership is transferable.

        require(_isTransferable, "ownership is not transferable");

        // Require that the new owner is not the zero address.

        require(_account != address(0), "owner cannot be set to zero address");

        // Set the transferable flag to false.

        _isTransferable = false;

        // Emit the ownership transfer event.

        emit TransferredOwnership(_owner, _account);

        // Set the owner to the provided address.

        _owner = _account;

    }



    /// @dev Allows the current owner to relinquish control of the contract.

    /// @notice Renouncing to ownership will leave the contract without an owner and unusable.

    /// It will not be possible to call the functions with the `onlyOwner` modifier anymore.

    function renounceOwnership() public onlyOwner {

        // Require that the ownership is transferable.

        require(_isTransferable, "ownership is not transferable");

        emit TransferredOwnership(_owner, address(0));

        // note that this could be terminal

        _owner = address(0);

    }



    /// @return the address of the owner.

    function owner() public view returns (address) {

        return _owner;

    }



    /// @return true if the ownership is transferable.

    function isTransferable() public view returns (bool) {

        return _isTransferable;

    }



    /// @return true if sender is the owner of the contract.

    function _isOwner() internal view returns (bool) {

        return msg.sender == _owner;

    }

}



/**

 * BSD 2-Clause License

 * 

 * Copyright (c) 2018, True Names Limited

 * All rights reserved.

 * 

 * Redistribution and use in source and binary forms, with or without

 * modification, are permitted provided that the following conditions are met:

 * 

 * * Redistributions of source code must retain the above copyright notice, this

 *   list of conditions and the following disclaimer.

 * 

 * * Redistributions in binary form must reproduce the above copyright notice,

 *   this list of conditions and the following disclaimer in the documentation

 *   and/or other materials provided with the distribution.

 * 

 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"

 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE

 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE

 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE

 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL

 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR

 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER

 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,

 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE

 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/



/**

 * A simple resolver anyone can use; only allows the owner of a node to set its

 * address.

 */

contract PublicResolver {



    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;

    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;

    bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;

    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;

    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;

    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;

    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;

    bytes4 constant MULTIHASH_INTERFACE_ID = 0xe89401a1;



    event AddrChanged(bytes32 indexed node, address a);

    event ContentChanged(bytes32 indexed node, bytes32 hash);

    event NameChanged(bytes32 indexed node, string name);

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    event TextChanged(bytes32 indexed node, string indexedKey, string key);

    event MultihashChanged(bytes32 indexed node, bytes hash);



    struct PublicKey {

        bytes32 x;

        bytes32 y;

    }



    struct Record {

        address addr;

        bytes32 content;

        string name;

        PublicKey pubkey;

        mapping(string=>string) text;

        mapping(uint256=>bytes) abis;

        bytes multihash;

    }



    ENS ens;



    mapping (bytes32 => Record) records;



    modifier only_owner(bytes32 node) {

        require(ens.owner(node) == msg.sender);

        _;

    }



    /**

     * Constructor.

     * @param ensAddr The ENS registrar contract.

     */

    constructor(ENS ensAddr) public {

        ens = ensAddr;

    }



    /**

     * Sets the address associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param addr The address to set.

     */

    function setAddr(bytes32 node, address addr) public only_owner(node) {

        records[node].addr = addr;

        emit AddrChanged(node, addr);

    }



    /**

     * Sets the content hash associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The node to update.

     * @param hash The content hash to set

     */

    function setContent(bytes32 node, bytes32 hash) public only_owner(node) {

        records[node].content = hash;

        emit ContentChanged(node, hash);

    }



    /**

     * Sets the multihash associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param hash The multihash to set

     */

    function setMultihash(bytes32 node, bytes hash) public only_owner(node) {

        records[node].multihash = hash;

        emit MultihashChanged(node, hash);

    }

    

    /**

     * Sets the name associated with an ENS node, for reverse records.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param name The name to set.

     */

    function setName(bytes32 node, string name) public only_owner(node) {

        records[node].name = name;

        emit NameChanged(node, name);

    }



    /**

     * Sets the ABI associated with an ENS node.

     * Nodes may have one ABI of each content type. To remove an ABI, set it to

     * the empty string.

     * @param node The node to update.

     * @param contentType The content type of the ABI

     * @param data The ABI data.

     */

    function setABI(bytes32 node, uint256 contentType, bytes data) public only_owner(node) {

        // Content types must be powers of 2

        require(((contentType - 1) & contentType) == 0);

        

        records[node].abis[contentType] = data;

        emit ABIChanged(node, contentType);

    }

    

    /**

     * Sets the SECP256k1 public key associated with an ENS node.

     * @param node The ENS node to query

     * @param x the X coordinate of the curve point for the public key.

     * @param y the Y coordinate of the curve point for the public key.

     */

    function setPubkey(bytes32 node, bytes32 x, bytes32 y) public only_owner(node) {

        records[node].pubkey = PublicKey(x, y);

        emit PubkeyChanged(node, x, y);

    }



    /**

     * Sets the text data associated with an ENS node and key.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param key The key to set.

     * @param value The text data value to set.

     */

    function setText(bytes32 node, string key, string value) public only_owner(node) {

        records[node].text[key] = value;

        emit TextChanged(node, key, key);

    }



    /**

     * Returns the text data associated with an ENS node and key.

     * @param node The ENS node to query.

     * @param key The text data key to query.

     * @return The associated text data.

     */

    function text(bytes32 node, string key) public view returns (string) {

        return records[node].text[key];

    }



    /**

     * Returns the SECP256k1 public key associated with an ENS node.

     * Defined in EIP 619.

     * @param node The ENS node to query

     * @return x, y the X and Y coordinates of the curve point for the public key.

     */

    function pubkey(bytes32 node) public view returns (bytes32 x, bytes32 y) {

        return (records[node].pubkey.x, records[node].pubkey.y);

    }



    /**

     * Returns the ABI associated with an ENS node.

     * Defined in EIP205.

     * @param node The ENS node to query

     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.

     * @return contentType The content type of the return value

     * @return data The ABI data

     */

    function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes data) {

        Record storage record = records[node];

        for (contentType = 1; contentType <= contentTypes; contentType <<= 1) {

            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {

                data = record.abis[contentType];

                return;

            }

        }

        contentType = 0;

    }



    /**

     * Returns the name associated with an ENS node, for reverse records.

     * Defined in EIP181.

     * @param node The ENS node to query.

     * @return The associated name.

     */

    function name(bytes32 node) public view returns (string) {

        return records[node].name;

    }



    /**

     * Returns the content hash associated with an ENS node.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The ENS node to query.

     * @return The associated content hash.

     */

    function content(bytes32 node) public view returns (bytes32) {

        return records[node].content;

    }



    /**

     * Returns the multihash associated with an ENS node.

     * @param node The ENS node to query.

     * @return The associated multihash.

     */

    function multihash(bytes32 node) public view returns (bytes) {

        return records[node].multihash;

    }



    /**

     * Returns the address associated with an ENS node.

     * @param node The ENS node to query.

     * @return The associated address.

     */

    function addr(bytes32 node) public view returns (address) {

        return records[node].addr;

    }



    /**

     * Returns true if the resolver implements the interface specified by the provided hash.

     * @param interfaceID The ID of the interface to check for.

     * @return True if the contract implements the requested interface.

     */

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {

        return interfaceID == ADDR_INTERFACE_ID ||

        interfaceID == CONTENT_INTERFACE_ID ||

        interfaceID == NAME_INTERFACE_ID ||

        interfaceID == ABI_INTERFACE_ID ||

        interfaceID == PUBKEY_INTERFACE_ID ||

        interfaceID == TEXT_INTERFACE_ID ||

        interfaceID == MULTIHASH_INTERFACE_ID ||

        interfaceID == INTERFACE_META_ID;

    }

}



/// @title ERC20 interface is a subset of the ERC20 specification.

interface ERC20 {

    function transfer(address, uint) external returns (bool);

    function balanceOf(address) external view returns (uint);

}





/// @title ERC165 interface specifies a standard way of querying if a contract implements an interface.

interface ERC165 {

    function supportsInterface(bytes4) external view returns (bool);

}





/// @title Whitelist provides payee-whitelist functionality.

contract Whitelist is Controllable, Ownable {

    event AddedToWhitelist(address _sender, address[] _addresses);

    event SubmittedWhitelistAddition(address[] _addresses, bytes32 _hash);

    event CancelledWhitelistAddition(address _sender, bytes32 _hash);



    event RemovedFromWhitelist(address _sender, address[] _addresses);

    event SubmittedWhitelistRemoval(address[] _addresses, bytes32 _hash);

    event CancelledWhitelistRemoval(address _sender, bytes32 _hash);



    mapping(address => bool) public isWhitelisted;

    address[] private _pendingWhitelistAddition;

    address[] private _pendingWhitelistRemoval;

    bool public submittedWhitelistAddition;

    bool public submittedWhitelistRemoval;

    bool public initializedWhitelist;



    /// @dev Check if the provided addresses contain the owner or the zero-address address.

    modifier hasNoOwnerOrZeroAddress(address[] _addresses) {

        for (uint i = 0; i < _addresses.length; i++) {

            require(_addresses[i] != owner(), "provided whitelist contains the owner address");

            require(_addresses[i] != address(0), "provided whitelist contains the zero address");

        }

        _;

    }



    /// @dev Check that neither addition nor removal operations have already been submitted.

    modifier noActiveSubmission() {

        require(!submittedWhitelistAddition && !submittedWhitelistRemoval, "whitelist operation has already been submitted");

        _;

    }



    /// @dev Getter for pending addition array.

    function pendingWhitelistAddition() external view returns(address[]) {

        return _pendingWhitelistAddition;

    }



    /// @dev Getter for pending removal array.

    function pendingWhitelistRemoval() external view returns(address[]) {

        return _pendingWhitelistRemoval;

    }



    /// @dev Getter for pending addition/removal array hash.

    function pendingWhitelistHash(address[] _pendingWhitelist) public pure returns(bytes32) {

        return keccak256(abi.encodePacked(_pendingWhitelist));

    }



    /// @dev Add initial addresses to the whitelist.

    /// @param _addresses are the Ethereum addresses to be whitelisted.

    function initializeWhitelist(address[] _addresses) external onlyOwner hasNoOwnerOrZeroAddress(_addresses) {

        // Require that the whitelist has not been initialized.

        require(!initializedWhitelist, "whitelist has already been initialized");

        // Add each of the provided addresses to the whitelist.

        for (uint i = 0; i < _addresses.length; i++) {

            isWhitelisted[_addresses[i]] = true;

        }

        initializedWhitelist = true;

        // Emit the addition event.

        emit AddedToWhitelist(msg.sender, _addresses);

    }



    /// @dev Add addresses to the whitelist.

    /// @param _addresses are the Ethereum addresses to be whitelisted.

    function submitWhitelistAddition(address[] _addresses) external onlyOwner noActiveSubmission hasNoOwnerOrZeroAddress(_addresses)  {

        // Require that the whitelist has been initialized.

        require(initializedWhitelist, "whitelist has not been initialized");

        // Set the provided addresses to the pending addition addresses.

        _pendingWhitelistAddition = _addresses;

        // Flag the operation as submitted.

        submittedWhitelistAddition = true;

        // Emit the submission event.

        emit SubmittedWhitelistAddition(_addresses, pendingWhitelistHash(_pendingWhitelistAddition));

    }



    /// @dev Confirm pending whitelist addition.

    function confirmWhitelistAddition(bytes32 _hash) external onlyController {

        // Require that the whitelist addition has been submitted.

        require(submittedWhitelistAddition, "whitelist addition has not been submitted");



        // Require that confirmation hash and the hash of the pending whitelist addition match

        require(_hash == pendingWhitelistHash(_pendingWhitelistAddition), "hash of the pending whitelist addition do not match");



        // Whitelist pending addresses.

        for (uint i = 0; i < _pendingWhitelistAddition.length; i++) {

            isWhitelisted[_pendingWhitelistAddition[i]] = true;

        }

        // Emit the addition event.

        emit AddedToWhitelist(msg.sender, _pendingWhitelistAddition);

        // Reset pending addresses.

        delete _pendingWhitelistAddition;

        // Reset the submission flag.

        submittedWhitelistAddition = false;

    }



    /// @dev Cancel pending whitelist addition.

    function cancelWhitelistAddition(bytes32 _hash) external onlyController {

        // Require that confirmation hash and the hash of the pending whitelist addition match

        require(_hash == pendingWhitelistHash(_pendingWhitelistAddition), "hash of the pending whitelist addition does not match");

        // Reset pending addresses.

        delete _pendingWhitelistAddition;

        // Reset the submitted operation flag.

        submittedWhitelistAddition = false;

        // Emit the cancellation event.

        emit CancelledWhitelistAddition(msg.sender, _hash);

    }



    /// @dev Remove addresses from the whitelist.

    /// @param _addresses are the Ethereum addresses to be removed.

    function submitWhitelistRemoval(address[] _addresses) external onlyOwner noActiveSubmission {

        // Add the provided addresses to the pending addition list.

        _pendingWhitelistRemoval = _addresses;

        // Flag the operation as submitted.

        submittedWhitelistRemoval = true;

        // Emit the submission event.

        emit SubmittedWhitelistRemoval(_addresses, pendingWhitelistHash(_pendingWhitelistRemoval));

    }



    /// @dev Confirm pending removal of whitelisted addresses.

    function confirmWhitelistRemoval(bytes32 _hash) external onlyController {

        // Require that the pending whitelist is not empty and the operation has been submitted.

        require(submittedWhitelistRemoval, "whitelist removal has not been submitted");

        require(_pendingWhitelistRemoval.length > 0, "pending whitelist removal is empty");

        // Require that confirmation hash and the hash of the pending whitelist removal match

        require(_hash == pendingWhitelistHash(_pendingWhitelistRemoval), "hash of the pending whitelist removal does not match the confirmed hash");

        // Remove pending addresses.

        for (uint i = 0; i < _pendingWhitelistRemoval.length; i++) {

            isWhitelisted[_pendingWhitelistRemoval[i]] = false;

        }

        // Emit the removal event.

        emit RemovedFromWhitelist(msg.sender, _pendingWhitelistRemoval);

        // Reset pending addresses.

        delete _pendingWhitelistRemoval;

        // Reset the submission flag.

        submittedWhitelistRemoval = false;

    }



    /// @dev Cancel pending removal of whitelisted addresses.

    function cancelWhitelistRemoval(bytes32 _hash) external onlyController {

        // Require that confirmation hash and the hash of the pending whitelist removal match

        require(_hash == pendingWhitelistHash(_pendingWhitelistRemoval), "hash of the pending whitelist removal does not match");

        // Reset pending addresses.

        delete _pendingWhitelistRemoval;

        // Reset the submitted operation flag.

        submittedWhitelistRemoval = false;

        // Emit the cancellation event.

        emit CancelledWhitelistRemoval(msg.sender, _hash);

    }

}





//// @title SpendLimit provides daily spend limit functionality.

contract SpendLimit is Controllable, Ownable {

    event SetSpendLimit(address _sender, uint _amount);

    event SubmittedSpendLimitChange(uint _amount);

    event CancelledSpendLimitChange(address _sender, uint _amount);



    using SafeMath for uint256;



    uint public spendLimit;

    uint private _spendLimitDay;

    uint private _spendAvailable;



    uint public pendingSpendLimit;

    bool public submittedSpendLimit;

    bool public initializedSpendLimit;



    /// @dev Constructor initializes the daily spend limit in wei.

    constructor(uint _spendLimit) internal {

        spendLimit = _spendLimit;

        _spendLimitDay = now;

        _spendAvailable = spendLimit;

    }



    /// @dev Returns the available daily balance - accounts for daily limit reset.

    /// @return amount of ether in wei.

    function spendAvailable() public view returns (uint) {

        if (now > _spendLimitDay + 24 hours) {

            return spendLimit;

        } else {

            return _spendAvailable;

        }

    }



    /// @dev Initialize a daily spend (aka transfer) limit for non-whitelisted addresses.

    /// @param _amount is the daily limit amount in wei.

    function initializeSpendLimit(uint _amount) external onlyOwner {

        // Require that the spend limit has not been initialized.

        require(!initializedSpendLimit, "spend limit has already been initialized");

        // Modify spend limit based on the provided value.

        _modifySpendLimit(_amount);

        // Flag the operation as initialized.

        initializedSpendLimit = true;

        // Emit the set limit event.

        emit SetSpendLimit(msg.sender, _amount);

    }



    /// @dev Set a daily transfer limit for non-whitelisted addresses.

    /// @param _amount is the daily limit amount in wei.

    function submitSpendLimit(uint _amount) external onlyOwner {

        // Require that the spend limit has been initialized.

        require(initializedSpendLimit, "spend limit has not been initialized");

        // Require that the operation has been submitted.

        require(!submittedSpendLimit, "spend limit has already been submitted");

        // Assign the provided amount to pending daily limit change.

        pendingSpendLimit = _amount;

        // Flag the operation as submitted.

        submittedSpendLimit = true;

        // Emit the submission event.

        emit SubmittedSpendLimitChange(_amount);

    }



    /// @dev Confirm pending set daily limit operation.

    function confirmSpendLimit(uint _amount) external onlyController {

        // Require that the operation has been submitted.

        require(submittedSpendLimit, "spend limit has not been submitted");

        // Require that pending and confirmed spend limit are the same

        require(pendingSpendLimit == _amount, "confirmed and submitted spend limits dont match");

        // Modify spend limit based on the pending value.

        _modifySpendLimit(pendingSpendLimit);

        // Emit the set limit event.

        emit SetSpendLimit(msg.sender, pendingSpendLimit);

        // Reset the submission flag.

        submittedSpendLimit = false;

        // Reset pending daily limit.

        pendingSpendLimit = 0;

    }



    /// @dev Cancel pending set daily limit operation.

    function cancelSpendLimit(uint _amount) external onlyController {

        // Require that pending and confirmed spend limit are the same

        require(pendingSpendLimit == _amount, "pending and cancelled spend limits dont match");

        // Reset pending daily limit.

        pendingSpendLimit = 0;

        // Reset the submitted operation flag.

        submittedSpendLimit = false;

        // Emit the cancellation event.

        emit CancelledSpendLimitChange(msg.sender, _amount);

    }



    // @dev Setter method for the available daily spend limit.

    function _setSpendAvailable(uint _amount) internal {

        _spendAvailable = _amount;

    }



    /// @dev Update available spend limit based on the daily reset.

    function _updateSpendAvailable() internal {

        if (now > _spendLimitDay.add(24 hours)) {

            // Advance the current day by how many days have passed.

            uint extraDays = now.sub(_spendLimitDay).div(24 hours);

            _spendLimitDay = _spendLimitDay.add(extraDays.mul(24 hours));

            // Set the available limit to the current spend limit.

            _spendAvailable = spendLimit;

        }

    }



    /// @dev Modify the spend limit and spend available based on the provided value.

    /// @dev _amount is the daily limit amount in wei.

    function _modifySpendLimit(uint _amount) private {

        // Account for the spend limit daily reset.

        _updateSpendAvailable();

        // Set the daily limit to the provided amount.

        spendLimit = _amount;

        // Lower the available limit if it's higher than the new daily limit.

        if (_spendAvailable > spendLimit) {

            _spendAvailable = spendLimit;

        }

    }

}





//// @title Asset store with extra security features.

contract Vault is Whitelist, SpendLimit, ERC165 {

    event Received(address _from, uint _amount);

    event Transferred(address _to, address _asset, uint _amount);



    using SafeMath for uint256;



    /// @dev Supported ERC165 interface ID.

    bytes4 private constant _ERC165_INTERFACE_ID = 0x01ffc9a7; // solium-disable-line uppercase



    /// @dev ENS points to the ENS registry smart contract.

    ENS private _ENS;

    /// @dev Is the registered ENS name of the oracle contract.

    bytes32 private _node;



    /// @dev Constructor initializes the vault with an owner address and spend limit. It also sets up the oracle and controller contracts.

    /// @param _owner is the owner account of the wallet contract.

    /// @param _transferable indicates whether the contract ownership can be transferred.

    /// @param _ens is the ENS public registry contract address.

    /// @param _oracleName is the ENS name of the Oracle.

    /// @param _controllerName is the ENS name of the controller.

    /// @param _spendLimit is the initial spend limit.

    constructor(address _owner, bool _transferable, address _ens, bytes32 _oracleName, bytes32 _controllerName, uint _spendLimit) SpendLimit(_spendLimit) Ownable(_owner, _transferable) Controllable(_ens, _controllerName) public {

        _ENS = ENS(_ens);

        _node = _oracleName;

    }



    /// @dev Checks if the value is not zero.

    modifier isNotZero(uint _value) {

        require(_value != 0, "provided value cannot be zero");

        _;

    }



    /// @dev Ether can be deposited from any source, so this contract must be payable by anyone.

    function() public payable {

        //TODO question: Why is this check here, is it necessary or are we building into a corner?

        require(msg.data.length == 0);

        emit Received(msg.sender, msg.value);

    }



    /// @dev Returns the amount of an asset owned by the contract.

    /// @param _asset address of an ERC20 token or 0x0 for ether.

    /// @return balance associated with the wallet address in wei.

    function balance(address _asset) external view returns (uint) {

        if (_asset != address(0)) {

            return ERC20(_asset).balanceOf(this);

        } else {

            return address(this).balance;

        }

    }



    /// @dev Transfers the specified asset to the recipient's address.

    /// @param _to is the recipient's address.

    /// @param _asset is the address of an ERC20 token or 0x0 for ether.

    /// @param _amount is the amount of tokens to be transferred in base units.

    function transfer(address _to, address _asset, uint _amount) external onlyOwner isNotZero(_amount) {

        // Checks if the _to address is not the zero-address

        require(_to != address(0), "_to address cannot be set to 0x0");



        // If address is not whitelisted, take daily limit into account.

        if (!isWhitelisted[_to]) {

            // Update the available spend limit.

            _updateSpendAvailable();

            // Convert token amount to ether value.

            uint etherValue;

            bool tokenExists;

            if (_asset != address(0)) {

                (tokenExists, etherValue) = IOracle(PublicResolver(_ENS.resolver(_node)).addr(_node)).convert(_asset, _amount);

            } else {

                etherValue = _amount;

            }



            // If token is supported by our oracle or is ether

            // Check against the daily spent limit and update accordingly

            if (tokenExists || _asset == address(0)) {

                // Require that the value is under remaining limit.

                require(etherValue <= spendAvailable(), "transfer amount exceeds available spend limit");

                // Update the available limit.

                _setSpendAvailable(spendAvailable().sub(etherValue));

            }

        }

        // Transfer token or ether based on the provided address.

        if (_asset != address(0)) {

            require(ERC20(_asset).transfer(_to, _amount), "ERC20 token transfer was unsuccessful");

        } else {

            _to.transfer(_amount);

        }

        // Emit the transfer event.

        emit Transferred(_to, _asset, _amount);

    }



    /// @dev Checks for interface support based on ERC165.

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {

        return interfaceID == _ERC165_INTERFACE_ID;

    }

}





//// @title Asset wallet with extra security features and gas top up management.

contract Wallet is Vault {

    event SetTopUpLimit(address _sender, uint _amount);

    event SubmittedTopUpLimitChange(uint _amount);

    event CancelledTopUpLimitChange(address _sender, uint _amount);



    event ToppedUpGas(address _sender, address _owner, uint _amount);



    using SafeMath for uint256;



    uint constant private MINIMUM_TOPUP_LIMIT = 1 finney; // solium-disable-line uppercase

    uint constant private MAXIMUM_TOPUP_LIMIT = 500 finney; // solium-disable-line uppercase



    uint public topUpLimit;

    uint private _topUpLimitDay;

    uint private _topUpAvailable;



    uint public pendingTopUpLimit;

    bool public submittedTopUpLimit;

    bool public initializedTopUpLimit;



    /// @dev Constructor initializes the wallet top up limit and the vault contract.

    /// @param _owner is the owner account of the wallet contract.

    /// @param _transferable indicates whether the contract ownership can be transferred.

    /// @param _ens is the address of the ENS.

    /// @param _oracleName is the ENS name of the Oracle.

    /// @param _controllerName is the ENS name of the Controller.

    /// @param _spendLimit is the initial spend limit.

    constructor(address _owner, bool _transferable, address _ens, bytes32 _oracleName, bytes32 _controllerName, uint _spendLimit) Vault(_owner, _transferable, _ens, _oracleName, _controllerName, _spendLimit) public {

        _topUpLimitDay = now;

        topUpLimit = MAXIMUM_TOPUP_LIMIT;

        _topUpAvailable = topUpLimit;

    }



    /// @dev Returns the available daily gas top up balance - accounts for daily limit reset.

    /// @return amount of gas in wei.

    function topUpAvailable() external view returns (uint) {

        if (now > _topUpLimitDay + 24 hours) {

            return topUpLimit;

        } else {

            return _topUpAvailable;

        }

    }



    /// @dev Initialize a daily gas top up limit.

    /// @param _amount is the gas top up amount in wei.

    function initializeTopUpLimit(uint _amount) external onlyOwner {

        // Require that the top up limit has not been initialized.

        require(!initializedTopUpLimit, "top up limit has already been initialized");

        // Require that the limit amount is within the acceptable range.

        require(MINIMUM_TOPUP_LIMIT <= _amount && _amount <= MAXIMUM_TOPUP_LIMIT, "top up amount is outside of the min/max range");

        // Modify spend limit based on the provided value.

        _modifyTopUpLimit(_amount);

        // Flag operation as initialized.

        initializedTopUpLimit = true;

        // Emit the set limit event.

        emit SetTopUpLimit(msg.sender, _amount);

    }



    /// @dev Set a daily top up top up limit.

    /// @param _amount is the daily top up limit amount in wei.

    function submitTopUpLimit(uint _amount) external onlyOwner {

        // Require that the top up limit has been initialized.

        require(initializedTopUpLimit, "top up limit has not been initialized");

        // Require that the operation has not been submitted.

        require(!submittedTopUpLimit, "top up limit has already been submitted");

        // Require that the limit amount is within the acceptable range.

        require(MINIMUM_TOPUP_LIMIT <= _amount && _amount <= MAXIMUM_TOPUP_LIMIT, "top up amount is outside of the min/max range");

        // Assign the provided amount to pending daily limit change.

        pendingTopUpLimit = _amount;

        // Flag the operation as submitted.

        submittedTopUpLimit = true;

        // Emit the submission event.

        emit SubmittedTopUpLimitChange(_amount);

    }



    /// @dev Confirm pending set top up limit operation.

    function confirmTopUpLimit(uint _amount) external onlyController {

        // Require that the operation has been submitted.

        require(submittedTopUpLimit, "top up limit has not been submitted");

        // Assert that the pending top up limit amount is within the acceptable range.

        require(MINIMUM_TOPUP_LIMIT <= pendingTopUpLimit && pendingTopUpLimit <= MAXIMUM_TOPUP_LIMIT, "top up amount is outside the min/max range");

        // Assert that confirmed and pending topup limit are the same.

        require(_amount == pendingTopUpLimit, "confirmed and pending topup limit are not same");

        // Modify top up limit based on the pending value.

        _modifyTopUpLimit(pendingTopUpLimit);

        // Emit the set limit event.

        emit SetTopUpLimit(msg.sender, pendingTopUpLimit);

        // Reset pending daily limit.

        pendingTopUpLimit = 0;

        // Reset the submission flag.

        submittedTopUpLimit = false;

    }



    /// @dev Cancel pending set top up limit operation.

    function cancelTopUpLimit(uint _amount) external onlyController {

        // Require that pending and confirmed spend limit are the same

        require(pendingTopUpLimit == _amount, "pending and cancelled top up limits dont match");

        // Reset pending daily limit.

        pendingTopUpLimit = 0;

        // Reset the submitted operation flag.

        submittedTopUpLimit = false;

        // Emit the cancellation event.

        emit CancelledTopUpLimitChange(msg.sender, _amount);

    }



    /// @dev Refill owner's gas balance.

    /// @dev Revert if the transaction amount is too large

    /// @param _amount is the amount of ether to transfer to the owner account in wei.

    function topUpGas(uint _amount) external isNotZero(_amount) {

        // Require that the sender is either the owner or a controller.

        require(_isOwner() || _isController(msg.sender), "sender is neither an owner nor a controller");

        // Account for the top up limit daily reset.

        _updateTopUpAvailable();

        // Make sure the available top up amount is not zero.

        require(_topUpAvailable != 0, "available top up limit cannot be zero");

        // Fail if there isn't enough in the daily top up limit to perform topUp

        require(_amount <= _topUpAvailable, "available top up limit less than amount passed in");

        // Reduce the top up amount from available balance and transfer corresponding

        // ether to the owner's account.

        _topUpAvailable = _topUpAvailable.sub(_amount);

        owner().transfer(_amount);

        // Emit the gas top up event.

        emit ToppedUpGas(tx.origin, owner(), _amount);

    }



    /// @dev Modify the top up limit and top up available based on the provided value.

    /// @dev _amount is the daily limit amount in wei.

    function _modifyTopUpLimit(uint _amount) private {

        // Account for the top up limit daily reset.

        _updateTopUpAvailable();

        // Set the daily limit to the provided amount.

        topUpLimit = _amount;

        // Lower the available limit if it's higher than the new daily limit.

        if (_topUpAvailable > topUpLimit) {

            _topUpAvailable = topUpLimit;

        }

    }



    /// @dev Update available top up limit based on the daily reset.

    function _updateTopUpAvailable() private {

        if (now > _topUpLimitDay.add(24 hours)) {

            // Advance the current day by how many days have passed.

            uint extraDays = now.sub(_topUpLimitDay).div(24 hours);

            _topUpLimitDay = _topUpLimitDay.add(extraDays.mul(24 hours));

            // Set the available limit to the current top up limit.

            _topUpAvailable = topUpLimit;

        }

    }

}