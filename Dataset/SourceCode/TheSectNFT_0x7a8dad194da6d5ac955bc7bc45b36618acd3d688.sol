//SPDX-License-Identifier: UNLICENSED



pragma solidity >=0.8.19;



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



library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function tryAdd(

        uint256 a,

        uint256 b

    ) internal pure returns (bool, uint256) {

        unchecked {

            uint256 c = a + b;

            if (c < a) return (false, 0);

            return (true, c);

        }

    }



    /**

     * @dev Returns the substraction of two unsigned integers, with an overflow flag.

     *

     * _Available since v3.4._

     */

    function trySub(

        uint256 a,

        uint256 b

    ) internal pure returns (bool, uint256) {

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

    function tryMul(

        uint256 a,

        uint256 b

    ) internal pure returns (bool, uint256) {

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

    function tryDiv(

        uint256 a,

        uint256 b

    ) internal pure returns (bool, uint256) {

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

    function tryMod(

        uint256 a,

        uint256 b

    ) internal pure returns (bool, uint256) {

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

    function sub(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

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

    function div(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

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

    function mod(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        unchecked {

            require(b > 0, errorMessage);

            return a % b;

        }

    }

}



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

    function toHexString(

        uint256 value,

        uint256 length

    ) internal pure returns (string memory) {

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



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}



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

        _setOwner(_msgSender());

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

        _setOwner(address(0));

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

        _setOwner(newOwner);

    }



    function _setOwner(address newOwner) private {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}



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

    function functionCall(

        address target,

        bytes memory data

    ) internal returns (bytes memory) {

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

    function functionStaticCall(

        address target,

        bytes memory data

    ) internal view returns (bytes memory) {

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

    function functionDelegateCall(

        address target,

        bytes memory data

    ) internal returns (bytes memory) {

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



abstract contract ERC165 is IERC165 {

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(

        bytes4 interfaceId

    ) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}



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

    function transferFrom(address from, address to, uint256 tokenId) external;



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

    function getApproved(

        uint256 tokenId

    ) external view returns (address operator);



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

    function isApprovedForAll(

        address owner,

        address operator

    ) external view returns (bool);



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



interface IERC721Enumerable is IERC721 {

    /**

     * @dev Returns the total amount of tokens stored by the contract.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.

     */

    function tokenOfOwnerByIndex(

        address owner,

        uint256 index

    ) external view returns (uint256 tokenId);



    /**

     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.

     * Use along with {totalSupply} to enumerate all tokens.

     */

    function tokenByIndex(uint256 index) external view returns (uint256);

}



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

    function supportsInterface(

        bytes4 interfaceId

    ) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721-balanceOf}.

     */

    function balanceOf(

        address owner

    ) public view virtual override returns (uint256) {

        require(

            owner != address(0),

            "ERC721: balance query for the zero address"

        );

        return _balances[owner];

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(

        uint256 tokenId

    ) public view virtual override returns (address) {

        address owner = _owners[tokenId];

        require(

            owner != address(0),

            "ERC721: owner query for nonexistent token"

        );

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

    function tokenURI(

        uint256 tokenId

    ) public view virtual override returns (string memory) {

        require(

            _exists(tokenId),

            "ERC721Metadata: URI query for nonexistent token"

        );



        string memory baseURI = _baseURI();

        return

            bytes(baseURI).length > 0

                ? string(abi.encodePacked(baseURI, tokenId.toString()))

                : "";

    }



    /**

     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each

     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty

     * by default, can be overriden in child contracts.

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

            "ERC721: approve caller is not owner nor approved for all"

        );



        _approve(to, tokenId);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(

        uint256 tokenId

    ) public view virtual override returns (address) {

        require(

            _exists(tokenId),

            "ERC721: approved query for nonexistent token"

        );



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(

        address operator,

        bool approved

    ) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");



        _operatorApprovals[_msgSender()][operator] = approved;

        emit ApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC721-isApprovedForAll}.

     */

    function isApprovedForAll(

        address owner,

        address operator

    ) public view virtual override returns (bool) {

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

            "ERC721: transfer caller is not owner nor approved"

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

        bytes memory _data

    ) public virtual override {

        require(

            _isApprovedOrOwner(_msgSender(), tokenId),

            "ERC721: transfer caller is not owner nor approved"

        );

        _safeTransfer(from, to, tokenId, _data);

    }



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * `_data` is additional data, it has no specified format and it is sent in call to `to`.

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

        bytes memory _data

    ) internal virtual {

        _transfer(from, to, tokenId);

        require(

            _checkOnERC721Received(from, to, tokenId, _data),

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

    function _isApprovedOrOwner(

        address spender,

        uint256 tokenId

    ) internal view virtual returns (bool) {

        require(

            _exists(tokenId),

            "ERC721: operator query for nonexistent token"

        );

        address owner = ERC721.ownerOf(tokenId);

        return (spender == owner ||

            getApproved(tokenId) == spender ||

            isApprovedForAll(owner, spender));

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

        bytes memory _data

    ) internal virtual {

        _mint(to, tokenId);

        require(

            _checkOnERC721Received(address(0), to, tokenId, _data),

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

            "ERC721: transfer of token that is not own"

        );

        require(to != address(0), "ERC721: transfer to the zero address");



        _beforeTokenTransfer(from, to, tokenId);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId);



        _balances[from] -= 1;

        _balances[to] += 1;

        _owners[tokenId] = to;



        emit Transfer(from, to, tokenId);

    }



    /**

     * @dev Approve `to` to operate on `tokenId`

     *

     * Emits a {Approval} event.

     */

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;

        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.

     * The call is not executed if the target address is not a contract.

     *

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) private returns (bool) {

        if (to.isContract()) {

            try

                IERC721Receiver(to).onERC721Received(

                    _msgSender(),

                    from,

                    tokenId,

                    _data

                )

            returns (bytes4 retval) {

                return retval == IERC721Receiver.onERC721Received.selector;

            } catch (bytes memory reason) {

                if (reason.length == 0) {

                    revert(

                        "ERC721: transfer to non ERC721Receiver implementer"

                    );

                } else {

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

}



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

    function supportsInterface(

        bytes4 interfaceId

    ) public view virtual override(IERC165, ERC721) returns (bool) {

        return

            interfaceId == type(IERC721Enumerable).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.

     */

    function tokenOfOwnerByIndex(

        address owner,

        uint256 index

    ) public view virtual override returns (uint256) {

        require(

            index < ERC721.balanceOf(owner),

            "ERC721Enumerable: owner index out of bounds"

        );

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

    function tokenByIndex(

        uint256 index

    ) public view virtual override returns (uint256) {

        require(

            index < ERC721Enumerable.totalSupply(),

            "ERC721Enumerable: global index out of bounds"

        );

        return _allTokens[index];

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

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 tokenId

    ) internal virtual override {

        super._beforeTokenTransfer(from, to, tokenId);



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

    function _removeTokenFromOwnerEnumeration(

        address from,

        uint256 tokenId

    ) private {

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



interface IOperatorFilterRegistry {

    /**

     * @notice Returns true if operator is not filtered for a given token, either by address or codeHash. Also returns

     *         true if supplied registrant address is not registered.

     */

    function isOperatorAllowed(

        address registrant,

        address operator

    ) external view returns (bool);



    /**

     * @notice Registers an address with the registry. May be called by address itself or by EIP-173 owner.

     */

    function register(address registrant) external;



    /**

     * @notice Registers an address with the registry and "subscribes" to another address's filtered operators and codeHashes.

     */

    function registerAndSubscribe(

        address registrant,

        address subscription

    ) external;



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

    function subscribe(

        address registrant,

        address registrantToSubscribe

    ) external;



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

    function subscribers(

        address registrant

    ) external returns (address[] memory);



    /**

     * @notice Get the subscriber at a given index in the set of addresses subscribed to a given registrant.

     *         Note that order is not guaranteed as updates are made.

     */

    function subscriberAt(

        address registrant,

        uint256 index

    ) external returns (address);



    /**

     * @notice Copy filtered operators and codeHashes from a different registrantToCopy to addr.

     */

    function copyEntriesOf(

        address registrant,

        address registrantToCopy

    ) external;



    /**

     * @notice Returns true if operator is filtered by a given address or its subscription.

     */

    function isOperatorFiltered(

        address registrant,

        address operator

    ) external returns (bool);



    /**

     * @notice Returns true if the hash of an address's code is filtered by a given address or its subscription.

     */

    function isCodeHashOfFiltered(

        address registrant,

        address operatorWithCode

    ) external returns (bool);



    /**

     * @notice Returns true if a codeHash is filtered by a given address or its subscription.

     */

    function isCodeHashFiltered(

        address registrant,

        bytes32 codeHash

    ) external returns (bool);



    /**

     * @notice Returns a list of filtered operators for a given address or its subscription.

     */

    function filteredOperators(

        address addr

    ) external returns (address[] memory);



    /**

     * @notice Returns the set of filtered codeHashes for a given address or its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashes(

        address addr

    ) external returns (bytes32[] memory);



    /**

     * @notice Returns the filtered operator at the given index of the set of filtered operators for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredOperatorAt(

        address registrant,

        uint256 index

    ) external returns (address);



    /**

     * @notice Returns the filtered codeHash at the given index of the list of filtered codeHashes for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashAt(

        address registrant,

        uint256 index

    ) external returns (bytes32);



    /**

     * @notice Returns true if an address has registered

     */

    function isRegistered(address addr) external returns (bool);



    /**

     * @dev Convenience method to compute the code hash of an arbitrary contract

     */

    function codeHashOf(address addr) external returns (bytes32);

}



address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;

address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;



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



abstract contract DefaultOperatorFilterer is OperatorFilterer {

    /// @dev The constructor that is called when the contract is being deployed.

    constructor() OperatorFilterer(CANONICAL_CORI_SUBSCRIPTION, true) {}

}



contract TheSectNFT is DefaultOperatorFilterer, ERC721Enumerable, Ownable {

    using Strings for uint256;

    using SafeMath for uint256;

    using Counters for Counters.Counter;



    // Constants

    string public baseExtension = ".json";



    uint256 public cost = 0.05 ether;



    // Supply

    uint256 public maxSupply = 10;

    uint256 public lastSupply = 10;



    // Lists

    mapping(uint256 => address) public minters;



    // Params

    bool public paused = false;

    string private _baseTokenURI;

    address private _wallet;



    address public FeeReceiver = 0x486721225Af21d83972553d20E9f52763e611280;



    // Constructor

    constructor() ERC721("The Sect Covenant", "SECTC") {

        _baseTokenURI = "ipfs://bafybeidy2eyghzlxirqidtcfyyarubbtjk3yrcyoywqj7zojnghtmwei5y/";

        _wallet = msg.sender;

    }



    // URI Handling

    function _baseURI() internal view virtual override returns (string memory) {

        return _baseTokenURI;

    }



    // Setters

    function setBaseURI(string memory baseURI) external onlyOwner {

        _baseTokenURI = baseURI;

    }



    function increaseSupply(uint256 _newSupply) public onlyOwner {

        maxSupply = maxSupply.add(_newSupply);

        lastSupply = lastSupply.add(_newSupply);

    }



    function setCost(uint256 _newCost) public onlyOwner {

        cost = _newCost;

    }



    function setBaseExtension(

        string memory _newBaseExtension

    ) public onlyOwner {

        baseExtension = _newBaseExtension;

    }



    function pause(bool _state) public onlyOwner {

        paused = _state;

    }



    function setFeeReceiver(address _newFeeReceiver) public onlyOwner {

        FeeReceiver = _newFeeReceiver;

    }



    function mint(uint256 id) public payable {

        // Checks

        require(!paused, "TheSectNFT: minting has not started yet");

        require(lastSupply >= 1, "TheSectNFT: the collection is sold out");

        require(

            id > 0 && id <= maxSupply,

            "TheSectNFT: invalid token id"

        );

        if (msg.sender != owner()) {

            require(

                msg.value >= cost,

                "TheSectNFT: total cost isn't match"

            );

        }

        // Minting

        _nonRandomMint(msg.sender, id);

        payable(FeeReceiver).transfer(msg.value);

    }



    function _nonRandomMint(address _target, uint256 _index) internal returns (uint256) {

        // Reduce supply

        lastSupply--;

        // Mint

        _safeMint(_target, _index);

        // Save Original minters

        minters[_index] = msg.sender;

        return _index;

    }





    // Get Token List

    function getTokenIds(

        address _owner

    ) public view returns (uint256[] memory) {

        // Count owned Token

        uint256 ownerTokenCount = balanceOf(_owner);

        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        // Get ids of owned Token

        for (uint256 i; i < ownerTokenCount; i++) {

            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);

        }

        return tokenIds;

    }



    // Return compiled Token URI

    function tokenURI(

        uint256 _id

    ) public view virtual override returns (string memory) {

        require(_exists(_id), "TheSectNFT: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();

        return

            bytes(currentBaseURI).length > 0

                ? string(

                    abi.encodePacked(

                        currentBaseURI,

                        _id.toString(),

                        baseExtension

                    )

                )

                : "";

    }



    // Create a random id for minting

    function _getRandom() internal view returns (uint256) {

        return

            uint256(

                keccak256(

                    abi.encodePacked(

                        block.prevrandao,

                        block.timestamp,

                        lastSupply

                    )

                )

            );

    }



    function withdraw() public onlyOwner {

        uint256 balance = address(this).balance;

        payable(msg.sender).transfer(balance);

    }



    function setApprovalForAll(

        address operator,

        bool approved

    ) public override(IERC721, ERC721) onlyAllowedOperatorApproval(operator) {

        super.setApprovalForAll(operator, approved);

    }



    function approve(

        address operator,

        uint256 tokenId

    ) public override(IERC721, ERC721) onlyAllowedOperatorApproval(operator) {

        super.approve(operator, tokenId);

    }



    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override(IERC721, ERC721) onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override(IERC721, ERC721) onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public override(IERC721, ERC721) onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId, data);

    }

}