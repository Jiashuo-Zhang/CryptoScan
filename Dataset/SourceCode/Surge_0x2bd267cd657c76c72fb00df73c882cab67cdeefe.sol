/**

 *Submitted for verification at Etherscan.io on 2023-04-17

*/



// SPDX-License-Identifier: MIT



pragma solidity 0.8.19;



/**

 * @dev These functions deal with verification of Merkle Tree proofs.

 *

 * The proofs can be generated using the JavaScript library

 * https://github.com/miguelmota/merkletreejs[merkletreejs].

 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.

 *

 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.

 *

 * WARNING: You should avoid using leaf values that are 64 bytes long prior to

 * hashing, or use a hash function other than keccak256 for hashing leaves.

 * This is because the concatenation of a sorted pair of internal nodes in

 * the merkle tree could be reinterpreted as a leaf value.

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

    function processProof(bytes32[] memory proof, bytes32 leaf)

        internal

        pure

        returns (bytes32)

    {

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

    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf)

        internal

        pure

        returns (bytes32)

    {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {

            computedHash = _hashPair(computedHash, proof[i]);

        }

        return computedHash;

    }



    /**

     * @dev Returns true if the `leaves` can be proved to be a part of a Merkle tree defined by

     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.

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

     * @dev Returns the root of a tree reconstructed from `leaves` and the sibling nodes in `proof`,

     * consuming from one or the other at each step according to the instructions given by

     * `proofFlags`.

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

        require(

            leavesLen + proof.length - 1 == totalHashes,

            "MerkleProof: invalid multiproof"

        );



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

            bytes32 a = leafPos < leavesLen

                ? leaves[leafPos++]

                : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]

                : proof[proofPos++];

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

     * @dev Calldata version of {processMultiProof}

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

        require(

            leavesLen + proof.length - 1 == totalHashes,

            "MerkleProof: invalid multiproof"

        );



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

            bytes32 a = leafPos < leavesLen

                ? leaves[leafPos++]

                : hashes[hashPos++];

            bytes32 b = proofFlags[i]

                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]

                : proof[proofPos++];

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



    function _efficientHash(bytes32 a, bytes32 b)

        private

        pure

        returns (bytes32 value)

    {

        /// @solidity memory-safe-assembly

        assembly {

            mstore(0x00, a)

            mstore(0x20, b)

            value := keccak256(0x00, 0x40)

        }

    }

}



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



/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



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

    function toHexString(uint256 value, uint256 length)

        internal

        pure

        returns (string memory)

    {

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



    /**

     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.

     */

    function toHexString(address addr) internal pure returns (string memory) {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);

    }

}



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

        require(

            address(this).balance >= amount,

            "Address: insufficient balance"

        );



        (bool success, ) = recipient.call{value: amount}("");

        require(

            success,

            "Address: unable to send value, recipient may have reverted"

        );

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

    function functionCall(address target, bytes memory data)

        internal

        returns (bytes memory)

    {

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

        return

            functionCallWithValue(

                target,

                data,

                value,

                "Address: low-level call with value failed"

            );

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

        require(

            address(this).balance >= value,

            "Address: insufficient balance for call"

        );

        require(isContract(target), "Address: call to non-contract");



        (bool success, bytes memory returndata) = target.call{value: value}(

            data

        );

        return verifyCallResult(success, returndata, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but performing a static call.

     *

     * _Available since v3.3._

     */

    function functionStaticCall(address target, bytes memory data)

        internal

        view

        returns (bytes memory)

    {

        return

            functionStaticCall(

                target,

                data,

                "Address: low-level static call failed"

            );

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

    function functionDelegateCall(address target, bytes memory data)

        internal

        returns (bytes memory)

    {

        return

            functionDelegateCall(

                target,

                data,

                "Address: low-level delegate call failed"

            );

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

}



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

    function supportsInterface(bytes4 interfaceId)

        public

        view

        virtual

        override

        returns (bool)

    {

        return interfaceId == type(IERC165).interfaceId;

    }

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

    function supportsInterface(bytes4 interfaceId)

        public

        view

        virtual

        override(IERC165, ERC165)

        returns (bool)

    {

        return

            interfaceId == type(IERC2981).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @inheritdoc IERC2981

     */

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)

        public

        view

        virtual

        override

        returns (address, uint256)

    {

        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];



        if (royalty.receiver == address(0)) {

            royalty = _defaultRoyaltyInfo;

        }



        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) /

            _feeDenominator();



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

    function _setDefaultRoyalty(address receiver, uint96 feeNumerator)

        internal

        virtual

    {

        require(

            feeNumerator <= _feeDenominator(),

            "ERC2981: royalty fee will exceed salePrice"

        );

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

        require(

            feeNumerator <= _feeDenominator(),

            "ERC2981: royalty fee will exceed salePrice"

        );

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



/**

 * @dev Required interface of an ERC721 compliant contract.

 */

interface IERC721 is IERC165 {

    /**

     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.

     */

    event Transfer(

        address indexed from,

        address indexed to,

        uint256 indexed tokenId

    );



    /**

     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.

     */

    event Approval(

        address indexed owner,

        address indexed approved,

        uint256 indexed tokenId

    );



    /**

     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.

     */

    event ApprovalForAll(

        address indexed owner,

        address indexed operator,

        bool approved

    );



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

    function getApproved(uint256 tokenId)

        external

        view

        returns (address operator);



    /**

     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

     *

     * See {setApprovalForAll}

     */

    function isApprovedForAll(address owner, address operator)

        external

        view

        returns (bool);

}



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



address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;

address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;



interface IOperatorFilterRegistry {

    /**

     * @notice Returns true if operator is not filtered for a given token, either by address or codeHash. Also returns

     *         true if supplied registrant address is not registered.

     */

    function isOperatorAllowed(address registrant, address operator)

        external

        view

        returns (bool);



    /**

     * @notice Registers an address with the registry. May be called by address itself or by EIP-173 owner.

     */

    function register(address registrant) external;



    /**

     * @notice Registers an address with the registry and "subscribes" to another address's filtered operators and codeHashes.

     */

    function registerAndSubscribe(address registrant, address subscription)

        external;



    /**

     * @notice Registers an address with the registry and copies the filtered operators and codeHashes from another

     *         address without subscribing.

     */

    function registerAndCopyEntries(

        address registrant,

        address registrantToCopy

    ) external;



    /**

     * @notice Unregisters an address with the registry and removes its subscription. May be called by address itself or by EIP-173 owner.

     *         Note that this does not remove any filtered addresses or codeHashes.

     *         Also note that any subscriptions to this registrant will still be active and follow the existing filtered addresses and codehashes.

     */

    function unregister(address addr) external;



    /**

     * @notice Update an operator address for a registered address - when filtered is true, the operator is filtered.

     */

    function updateOperator(

        address registrant,

        address operator,

        bool filtered

    ) external;



    /**

     * @notice Update multiple operators for a registered address - when filtered is true, the operators will be filtered. Reverts on duplicates.

     */

    function updateOperators(

        address registrant,

        address[] calldata operators,

        bool filtered

    ) external;



    /**

     * @notice Update a codeHash for a registered address - when filtered is true, the codeHash is filtered.

     */

    function updateCodeHash(

        address registrant,

        bytes32 codehash,

        bool filtered

    ) external;



    /**

     * @notice Update multiple codeHashes for a registered address - when filtered is true, the codeHashes will be filtered. Reverts on duplicates.

     */

    function updateCodeHashes(

        address registrant,

        bytes32[] calldata codeHashes,

        bool filtered

    ) external;



    /**

     * @notice Subscribe an address to another registrant's filtered operators and codeHashes. Will remove previous

     *         subscription if present.

     *         Note that accounts with subscriptions may go on to subscribe to other accounts - in this case,

     *         subscriptions will not be forwarded. Instead the former subscription's existing entries will still be

     *         used.

     */

    function subscribe(address registrant, address registrantToSubscribe)

        external;



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

    function subscribers(address registrant)

        external

        returns (address[] memory);



    /**

     * @notice Get the subscriber at a given index in the set of addresses subscribed to a given registrant.

     *         Note that order is not guaranteed as updates are made.

     */

    function subscriberAt(address registrant, uint256 index)

        external

        returns (address);



    /**

     * @notice Copy filtered operators and codeHashes from a different registrantToCopy to addr.

     */

    function copyEntriesOf(address registrant, address registrantToCopy)

        external;



    /**

     * @notice Returns true if operator is filtered by a given address or its subscription.

     */

    function isOperatorFiltered(address registrant, address operator)

        external

        returns (bool);



    /**

     * @notice Returns true if the hash of an address's code is filtered by a given address or its subscription.

     */

    function isCodeHashOfFiltered(address registrant, address operatorWithCode)

        external

        returns (bool);



    /**

     * @notice Returns true if a codeHash is filtered by a given address or its subscription.

     */

    function isCodeHashFiltered(address registrant, bytes32 codeHash)

        external

        returns (bool);



    /**

     * @notice Returns a list of filtered operators for a given address or its subscription.

     */

    function filteredOperators(address addr)

        external

        returns (address[] memory);



    /**

     * @notice Returns the set of filtered codeHashes for a given address or its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashes(address addr)

        external

        returns (bytes32[] memory);



    /**

     * @notice Returns the filtered operator at the given index of the set of filtered operators for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredOperatorAt(address registrant, uint256 index)

        external

        returns (address);



    /**

     * @notice Returns the filtered codeHash at the given index of the list of filtered codeHashes for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashAt(address registrant, uint256 index)

        external

        returns (bytes32);



    /**

     * @notice Returns true if an address has registered

     */

    function isRegistered(address addr) external returns (bool);



    /**

     * @dev Convenience method to compute the code hash of an arbitrary contract

     */

    function codeHashOf(address addr) external returns (bytes32);

}



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

                OPERATOR_FILTER_REGISTRY.registerAndSubscribe(

                    address(this),

                    subscriptionOrRegistrantToCopy

                );

            } else {

                if (subscriptionOrRegistrantToCopy != address(0)) {

                    OPERATOR_FILTER_REGISTRY.registerAndCopyEntries(

                        address(this),

                        subscriptionOrRegistrantToCopy

                    );

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

            if (

                !OPERATOR_FILTER_REGISTRY.isOperatorAllowed(

                    address(this),

                    operator

                )

            ) {

                revert OperatorNotAllowed(operator);

            }

        }

    }

}



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

    function supportsInterface(bytes4 interfaceId)

        public

        view

        virtual

        override(ERC165, IERC165)

        returns (bool)

    {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721-balanceOf}.

     */

    function balanceOf(address owner)

        public

        view

        virtual

        override

        returns (uint256)

    {

        require(

            owner != address(0),

            "ERC721: address zero is not a valid owner"

        );

        return _balances[owner];

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId)

        public

        view

        virtual

        override

        returns (address)

    {

        address owner = _owners[tokenId];

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

    function tokenURI(uint256 tokenId)

        public

        view

        virtual

        override

        returns (string memory)

    {

        _requireMinted(tokenId);



        string memory baseURI = _baseURI();

        return

            bytes(baseURI).length > 0

                ? string(abi.encodePacked(baseURI, tokenId.toString()))

                : "";

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

            "ERC721: approve caller is not token owner nor approved for all"

        );



        _approve(to, tokenId);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(uint256 tokenId)

        public

        view

        virtual

        override

        returns (address)

    {

        _requireMinted(tokenId);



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved)

        public

        virtual

        override

    {

        _setApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC721-isApprovedForAll}.

     */

    function isApprovedForAll(address owner, address operator)

        public

        view

        virtual

        override

        returns (bool)

    {

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

        require(

            _isApprovedOrOwner(_msgSender(), tokenId),

            "ERC721: caller is not token owner nor approved"

        );



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

        require(

            _isApprovedOrOwner(_msgSender(), tokenId),

            "ERC721: caller is not token owner nor approved"

        );

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

        require(

            _checkOnERC721Received(from, to, tokenId, data),

            "ERC721: transfer to non ERC721Receiver implementer"

        );

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

        return _owners[tokenId] != address(0);

    }



    /**

     * @dev Returns whether `spender` is allowed to manage `tokenId`.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId)

        internal

        view

        virtual

        returns (bool)

    {

        address owner = ERC721.ownerOf(tokenId);

        return (spender == owner ||

            isApprovedForAll(owner, spender) ||

            getApproved(tokenId) == spender);

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



        _beforeTokenTransfer(address(0), to, tokenId);



        _balances[to] += 1;

        _owners[tokenId] = to;



        emit Transfer(address(0), to, tokenId);



        _afterTokenTransfer(address(0), to, tokenId);

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

        address owner = ERC721.ownerOf(tokenId);



        _beforeTokenTransfer(owner, address(0), tokenId);



        // Clear approvals

        _approve(address(0), tokenId);



        _balances[owner] -= 1;

        delete _owners[tokenId];



        emit Transfer(owner, address(0), tokenId);



        _afterTokenTransfer(owner, address(0), tokenId);

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

        require(

            ERC721.ownerOf(tokenId) == from,

            "ERC721: transfer from incorrect owner"

        );

        require(to != address(0), "ERC721: transfer to the zero address");



        _beforeTokenTransfer(from, to, tokenId);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId);



        _balances[from] -= 1;

        _balances[to] += 1;

        _owners[tokenId] = to;



        emit Transfer(from, to, tokenId);



        _afterTokenTransfer(from, to, tokenId);

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

            try

                IERC721Receiver(to).onERC721Received(

                    _msgSender(),

                    from,

                    tokenId,

                    data

                )

            returns (bytes4 retval) {

                return retval == IERC721Receiver.onERC721Received.selector;

            } catch (bytes memory reason) {

                if (reason.length == 0) {

                    revert(

                        "ERC721: transfer to non ERC721Receiver implementer"

                    );

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

     * @dev Hook that is called before any token transfer. This includes minting

     * and burning.

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be

     * transferred to `to`.

     * - When `from` is zero, `tokenId` will be minted for `to`.

     * - When `to` is zero, ``from``'s `tokenId` will be burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 tokenId

    ) internal virtual {}



    /**

     * @dev Hook that is called after any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _afterTokenTransfer(

        address from,

        address to,

        uint256 tokenId

    ) internal virtual {}

}



/**

 * @dev Contract module which allows children to implement an emergency stop

 * mechanism that can be triggered by an authorized account.

 *

 * This module is used through inheritance. It will make available the

 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to

 * the functions of your contract. Note that they will not be pausable by

 * simply including this module, only once the modifiers are put in place.

 */

abstract contract Pausable is Context {

    /**

     * @dev Emitted when the pause is triggered by `account`.

     */

    event Paused(address account);



    /**

     * @dev Emitted when the pause is lifted by `account`.

     */

    event Unpaused(address account);



    bool private _paused;



    /**

     * @dev Initializes the contract in unpaused state.

     */

    constructor() {

        _paused = false;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     *

     * Requirements:

     *

     * - The contract must not be paused.

     */

    modifier whenNotPaused() {

        _requireNotPaused();

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     *

     * Requirements:

     *

     * - The contract must be paused.

     */

    modifier whenPaused() {

        _requirePaused();

        _;

    }



    /**

     * @dev Returns true if the contract is paused, and false otherwise.

     */

    function paused() public view virtual returns (bool) {

        return _paused;

    }



    /**

     * @dev Throws if the contract is paused.

     */

    function _requireNotPaused() internal view virtual {

        require(!paused(), "Pausable: paused");

    }



    /**

     * @dev Throws if the contract is not paused.

     */

    function _requirePaused() internal view virtual {

        require(paused(), "Pausable: not paused");

    }



    /**

     * @dev Triggers stopped state.

     *

     * Requirements:

     *

     * - The contract must not be paused.

     */

    function _pause() internal virtual whenNotPaused {

        _paused = true;

        emit Paused(_msgSender());

    }



    /**

     * @dev Returns to normal state.

     *

     * Requirements:

     *

     * - The contract must be paused.

     */

    function _unpause() internal virtual whenPaused {

        _paused = false;

        emit Unpaused(_msgSender());

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

abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );



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

        require(

            newOwner != address(0),

            "Ownable: new owner is the zero address"

        );

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



/*

          ______         __    __        _______          ______         ________ 

         /      \       |  \  |  \      |       \        /      \       |        \

        |  $$$$$$\      | $$  | $$      | $$$$$$$\      |  $$$$$$\      | $$$$$$$$

        | $$___\$$      | $$  | $$      | $$__| $$      | $$ __\$$      | $$__    

         \$$    \       | $$  | $$      | $$    $$      | $$|    \      | $$  \   

         _\$$$$$$\      | $$  | $$      | $$$$$$$\      | $$ \$$$$      | $$$$$   

        |  \__| $$      | $$__/ $$      | $$  | $$      | $$__| $$      | $$_____ 

         \$$    $$       \$$    $$      | $$  | $$       \$$    $$      | $$     \

          \$$$$$$         \$$$$$$        \$$   \$$        \$$$$$$        \$$$$$$$$                                                    

                                                                

*/



/**

 * @title Surge (https://surgenft.xyz/)

 * @author Exodia Studio (https://exodia.studio/)

 */

contract Surge is

    ERC721,

    Pausable,

    Ownable,

    ReentrancyGuard,

    DefaultOperatorFilterer,

    ERC2981

{

    // ------------------------------------------------------------------------------------------------------- //

    // ---------------------------------------------- INITIALIZATION ----------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    constructor() ERC721("Surge", "SGE") {

        _pause();

        unchecked {

            for (uint256 i; i < 20; ) {

                _mint(msg.sender, tokenIdCounter);

                ++i;

                ++tokenIdCounter;

            }

        }

    }



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------ LIBRARIES -------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    using Strings for uint256;



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------ MODIFIERS -------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    modifier checkRequirements(uint256 amount) {

        uint256 cost = price * amount;



        require(msg.value == cost, "Incorrect value!");

        require(amount <= maxPerTx, "Exceeds max per tx!");

        require(tokenIdCounter + amount <= MAX_SUPPLY, "Exceeds max supply!");

        _;

    }



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------ VARIABLES -------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    /* ------------------------------------------------ CONSTANTS -------------------------------------------- */



    uint256 private constant MAX_SUPPLY = 2500;



    /* ------------------------------------------------ UPDATABLE -------------------------------------------- */



    bool private metadataLock;

    bool private publicMintPhase;

    uint256 private maxPerTx = 2;

    uint256 private tokenIdCounter;

    uint256 private maxPerWallet = 2;

    uint256 private price = 0.019 ether;

    string private uri =

        "ipfs://bafybeiciguidsf2iklibchqn4beptqxbtovi7ss3uvgk4daaadum3ccw3q/";

    bytes32 private merkleRoot =

        0x35f076cc6a8aac4109a7f23f6b973878f81476c48e92c2ae19088c18cf1fe0b1;



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------ MAPPINGS --------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    mapping(address => uint256) private _publicMinted;

    mapping(address => uint256) private _banditsMinted;



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------- EVENTS ---------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    event Reveal(string indexed uri);

    event SetPrice(uint256 indexed value);

    event SetMaxPerTx(uint256 indexed value);

    event SetMaxPerWallet(uint256 indexed value);

    event SetMerkleRoot(bytes32 indexed merkleRoot);

    event SetPublicMintPhase(bool indexed check);



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------- GETTERS --------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    function totalSupply() public view returns (uint256) {

        return tokenIdCounter;

    }



    function getPrice() public view returns (uint256) {

        return price;

    }



    function getMaxPerTx() public view returns (uint256) {

        return maxPerTx;

    }



    function getMaxPerWallet() public view returns (uint256) {

        return maxPerWallet;

    }



    function checkPublicMintPhase() public view returns (bool) {

        return publicMintPhase;

    }



    function getPublicMintedByWallet(address wallet)

        public

        view

        returns (uint256)

    {

        return _publicMinted[wallet];

    }



    function getBanditsMintedByWallet(address wallet)

        public

        view

        returns (uint256)

    {

        return _banditsMinted[wallet];

    }



    function isWhitelisted(address wallet, bytes32[] calldata merkleProof)

        public

        view

        returns (bool)

    {

        bytes32 leaf = keccak256(abi.encodePacked(wallet));

        return MerkleProof.verify(merkleProof, merkleRoot, leaf);

    }



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------- SETTERS --------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    /* ----------------------------------------------- CENTRALIZED ------------------------------------------- */



    function pause() external onlyOwner {

        _pause();

    }



    function unpause() external onlyOwner {

        _unpause();

    }



    function withdraw() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);

    }



    function switchMintPhase() external onlyOwner {

        publicMintPhase = !publicMintPhase;

        emit SetPublicMintPhase(publicMintPhase);

    }



    function reveal(string memory _uri) external onlyOwner {

        require(!metadataLock, "Already revealed!");

        metadataLock = true;

        uri = _uri;

        emit Reveal(_uri);

    }



    function setPrice(uint256 _price) external onlyOwner {

        price = _price;

        emit SetPrice(_price);

    }



    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        maxPerTx = _maxPerTx;

        emit SetMaxPerTx(_maxPerTx);

    }



    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {

        merkleRoot = _merkleRoot;

        emit SetMerkleRoot(_merkleRoot);

    }



    function setMaxPerWallet(uint256 _maxPerWallet) external onlyOwner {

        maxPerWallet = _maxPerWallet;

        emit SetMaxPerWallet(_maxPerWallet);

    }



    function setDefaultRoyalty(address receiver, uint96 feeNumerator)

        external

        onlyOwner

    {

        _setDefaultRoyalty(receiver, feeNumerator);

    }



    /* -------------------------------------------------- PUBLIC --------------------------------------------- */



    function publicMint(uint256 amount)

        external

        payable

        nonReentrant

        checkRequirements(amount)

    {

        require(publicMintPhase, "Public sale finished!");

        require(

            _publicMinted[msg.sender] + amount <= maxPerWallet,

            "Exceeds max per wallet!"

        );

        unchecked {

            _publicMinted[msg.sender] += amount;



            for (uint256 i; i < amount; ) {

                _mint(msg.sender, tokenIdCounter);

                ++tokenIdCounter;

                ++i;

            }

        }

    }



    function banditMint(uint256 amount, bytes32[] calldata merkleProof)

        external

        payable

        nonReentrant

        checkRequirements(amount)

    {

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        require(!publicMintPhase, "Whitelist sale finished!");

        require(

            MerkleProof.verify(merkleProof, merkleRoot, leaf),

            "NOT_WHITELISTED!"

        );



        require(

            _banditsMinted[msg.sender] + amount <= maxPerWallet,

            "Exceeds max per wallet!"

        );

        unchecked {

            _banditsMinted[msg.sender] += amount;



            for (uint256 i; i < amount; ) {

                _mint(msg.sender, tokenIdCounter);

                ++tokenIdCounter;

                ++i;

            }

        }

    }



    // ------------------------------------------------------------------------------------------------------- //

    // ------------------------------------------------ OVERRIDES -------------------------------------------- //

    // ------------------------------------------------------------------------------------------------------- //



    function _baseURI() internal view override returns (string memory) {

        return uri;

    }



    function tokenURI(uint256 tokenId)

        public

        view

        virtual

        override

        returns (string memory)

    {

        _requireMinted(tokenId);

        string memory baseURI = _baseURI();

        return

            bytes(baseURI).length > 0

                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))

                : "";

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.

     */

    function setApprovalForAll(address operator, bool approved)

        public

        override

        onlyAllowedOperatorApproval(operator)

    {

        super.setApprovalForAll(operator, approved);

    }



    /**

     * @dev See {IERC721-approve}.

     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.

     */

    function approve(address operator, uint256 tokenId)

        public

        override

        onlyAllowedOperatorApproval(operator)

    {

        super.approve(operator, tokenId);

    }



    /**

     * @dev See {IERC721-transferFrom}.

     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.

     */

    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     *      In this example the added modifier ensures that the operator is allowed by the OperatorFilterRegistry.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId)

        public

        view

        virtual

        override(ERC721, ERC2981)

        returns (bool)

    {

        return super.supportsInterface(interfaceId);

    }

}