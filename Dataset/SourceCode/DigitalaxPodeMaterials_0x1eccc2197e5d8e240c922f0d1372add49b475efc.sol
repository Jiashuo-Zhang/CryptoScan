/**

 *Submitted for verification at Etherscan.io on 2021-02-15

*/



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



// SPDX-License-Identifier: MIT



pragma solidity ^0.6.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20 {

    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `recipient`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address recipient, uint256 amount) external returns (bool);



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

     * @dev Moves `amount` tokens from `sender` to `recipient` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



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



// File: @openzeppelin/contracts/introspection/IERC165.sol







pragma solidity ^0.6.0;



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



// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol







pragma solidity ^0.6.2;





/**

 * @dev Required interface of an ERC1155 compliant contract, as defined in the

 * https://eips.ethereum.org/EIPS/eip-1155[EIP].

 *

 * _Available since v3.1._

 */

interface IERC1155 is IERC165 {

    /**

     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.

     */

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);



    /**

     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all

     * transfers.

     */

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);



    /**

     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to

     * `approved`.

     */

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);



    /**

     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.

     *

     * If an {URI} event was emitted for `id`, the standard

     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value

     * returned by {IERC1155MetadataURI-uri}.

     */

    event URI(string value, uint256 indexed id);



    /**

     * @dev Returns the amount of tokens of token type `id` owned by `account`.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     */

    function balanceOf(address account, uint256 id) external view returns (uint256);



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.

     *

     * Requirements:

     *

     * - `accounts` and `ids` must have the same length.

     */

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);



    /**

     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,

     *

     * Emits an {ApprovalForAll} event.

     *

     * Requirements:

     *

     * - `operator` cannot be the caller.

     */

    function setApprovalForAll(address operator, bool approved) external;



    /**

     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.

     *

     * See {setApprovalForAll}.

     */

    function isApprovedForAll(address account, address operator) external view returns (bool);



    /**

     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.

     *

     * Emits a {TransferSingle} event.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.

     * - `from` must have a balance of tokens of type `id` of at least `amount`.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the

     * acceptance magic value.

     */

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.

     *

     * Emits a {TransferBatch} event.

     *

     * Requirements:

     *

     * - `ids` and `amounts` must have the same length.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the

     * acceptance magic value.

     */

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}



// File: @openzeppelin/contracts/token/ERC1155/IERC1155MetadataURI.sol







pragma solidity ^0.6.2;





/**

 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined

 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].

 *

 * _Available since v3.1._

 */

interface IERC1155MetadataURI is IERC1155 {

    /**

     * @dev Returns the URI for token type `id`.

     *

     * If the `\{id\}` substring is present in the URI, it must be replaced by

     * clients with the actual token type ID.

     */

    function uri(uint256 id) external view returns (string memory);

}



// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol







pragma solidity ^0.6.0;





/**

 * _Available since v3.1._

 */

interface IERC1155Receiver is IERC165 {



    /**

        @dev Handles the receipt of a single ERC1155 token type. This function is

        called at the end of a `safeTransferFrom` after the balance has been updated.

        To accept the transfer, this must return

        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`

        (i.e. 0xf23a6e61, or its own function selector).

        @param operator The address which initiated the transfer (i.e. msg.sender)

        @param from The address which previously owned the token

        @param id The ID of the token being transferred

        @param value The amount of tokens being transferred

        @param data Additional data with no specified format

        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed

    */

    function onERC1155Received(

        address operator,

        address from,

        uint256 id,

        uint256 value,

        bytes calldata data

    )

        external

        returns(bytes4);



    /**

        @dev Handles the receipt of a multiple ERC1155 token types. This function

        is called at the end of a `safeBatchTransferFrom` after the balances have

        been updated. To accept the transfer(s), this must return

        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`

        (i.e. 0xbc197c81, or its own function selector).

        @param operator The address which initiated the batch transfer (i.e. msg.sender)

        @param from The address which previously owned the token

        @param ids An array containing ids of each token being transferred (order and length must match values array)

        @param values An array containing amounts of each token being transferred (order and length must match ids array)

        @param data Additional data with no specified format

        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed

    */

    function onERC1155BatchReceived(

        address operator,

        address from,

        uint256[] calldata ids,

        uint256[] calldata values,

        bytes calldata data

    )

        external

        returns(bytes4);

}



// File: @openzeppelin/contracts/GSN/Context.sol







pragma solidity ^0.6.0;



/*

 * @dev Provides information about the current execution context, including the

 * sender of the transaction and its data. While these are generally available

 * via msg.sender and msg.data, they should not be accessed in such a direct

 * manner, since when dealing with GSN meta-transactions the account sending and

 * paying for execution may not be the actual sender (as far as an application

 * is concerned).

 *

 * This contract is only required for intermediate, library-like contracts.

 */

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



// File: @openzeppelin/contracts/introspection/ERC165.sol







pragma solidity ^0.6.0;





/**

 * @dev Implementation of the {IERC165} interface.

 *

 * Contracts may inherit from this and call {_registerInterface} to declare

 * their support of an interface.

 */

contract ERC165 is IERC165 {

    /*

     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7

     */

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;



    /**

     * @dev Mapping of interface ids to whether or not it's supported.

     */

    mapping(bytes4 => bool) private _supportedInterfaces;



    constructor () internal {

        // Derived contracts need only register support for their own interfaces,

        // we register support for ERC165 itself here

        _registerInterface(_INTERFACE_ID_ERC165);

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     *

     * Time complexity O(1), guaranteed to always use less than 30 000 gas.

     */

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];

    }



    /**

     * @dev Registers the contract as an implementer of the interface defined by

     * `interfaceId`. Support of the actual ERC165 interface is automatic and

     * registering its interface id is not required.

     *

     * See {IERC165-supportsInterface}.

     *

     * Requirements:

     *

     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).

     */

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");

        _supportedInterfaces[interfaceId] = true;

    }

}



// File: @openzeppelin/contracts/math/SafeMath.sol







pragma solidity ^0.6.0;



/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.

 *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 */

library SafeMath {

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

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

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

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     *

     * - Subtraction cannot overflow.

     */

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;



        return c;

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

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts on

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on

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

        require(b > 0, errorMessage);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts when dividing by zero.

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

        return mod(a, b, "SafeMath: modulo by zero");

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts with custom message when dividing by zero.

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

        require(b != 0, errorMessage);

        return a % b;

    }

}



// File: @openzeppelin/contracts/utils/Address.sol







pragma solidity ^0.6.2;



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

     */

    function isContract(address account) internal view returns (bool) {

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

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

        require(address(this).balance >= amount, "Address: insufficient balance");



        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value

        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



    /**

     * @dev Performs a Solidity function call using a low level `call`. A

     * plain`call` is an unsafe replacement for a function call: use this

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

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);

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

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        return _functionCallWithValue(target, data, value, errorMessage);

    }



    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);

        if (success) {

            return returndata;

        } else {

            // Look for revert reason and bubble it up if present

            if (returndata.length > 0) {

                // The easiest way to bubble the revert reason is using memory via assembly



                // solhint-disable-next-line no-inline-assembly

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



// File: contracts/ERC1155/ERC1155.sol



// Contract based from the following:

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aaa5ef81cf75454d1c337dc3de03d12480849ad1/contracts/token/ERC1155/ERC1155.sol







pragma solidity 0.6.12;















/**

 *

 * @dev Implementation of the basic standard multi-token.

 * See https://eips.ethereum.org/EIPS/eip-1155

 * Originally based on code by Enjin: https://github.com/enjin/erc-1155

 *

 * _Available since v3.1._

 *

 * @notice Modifications to uri logic made by BlockRocket.tech

 */

contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;

    using Address for address;



    // Mapping from token ID to account balances

    mapping (uint256 => mapping(address => uint256)) private _balances;



    // Mapping from account to operator approvals

    mapping (address => mapping(address => bool)) private _operatorApprovals;



    // Token ID to its URI

    mapping (uint256 => string) internal tokenUris;



    // Token ID to its total supply

    mapping(uint256 => uint256) public tokenTotalSupply;



    /*

     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e

     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4

     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465

     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a

     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6

     *

     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^

     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26

     */

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;



    /*

     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c

     */

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;



    constructor () public {

        // register the supported interfaces to conform to ERC1155 via ERC165

        _registerInterface(_INTERFACE_ID_ERC1155);



        // register the supported interfaces to conform to ERC1155MetadataURI via ERC165

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);

    }



    /**

     * @dev See {IERC1155MetadataURI-uri}.

     */

    function uri(uint256 tokenId) external view override returns (string memory) {

        return tokenUris[tokenId];

    }



    /**

     * @dev See {IERC1155-balanceOf}.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     */

    function balanceOf(address account, uint256 id) public view override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");

        return _balances[id][account];

    }



    /**

     * @dev See {IERC1155-balanceOfBatch}.

     *

     * Requirements:

     *

     * - `accounts` and `ids` must have the same length.

     */

    function balanceOfBatch(

        address[] memory accounts,

        uint256[] memory ids

    )

    public

    view

    override

    returns (uint256[] memory)

    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");



        uint256[] memory batchBalances = new uint256[](accounts.length);



        for (uint256 i = 0; i < accounts.length; ++i) {

            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");

            batchBalances[i] = _balances[ids[i]][accounts[i]];

        }



        return batchBalances;

    }



    /**

     * @dev See {IERC1155-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) external virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");



        _operatorApprovals[_msgSender()][operator] = approved;

        emit ApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC1155-isApprovedForAll}.

     */

    function isApprovedForAll(address account, address operator) public view override returns (bool) {

        return _operatorApprovals[account][operator];

    }



    /**

     * @dev See {IERC1155-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 id,

        uint256 amount,

        bytes memory data

    )

    external

    virtual

    override

    {

        require(to != address(0), "ERC1155: transfer to the zero address");

        require(

            from == _msgSender() || isApprovedForAll(from, _msgSender()),

            "ERC1155: caller is not owner nor approved"

        );



        address operator = _msgSender();



        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);



        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");

        _balances[id][to] = _balances[id][to].add(amount);



        emit TransferSingle(operator, from, to, id, amount);



        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);

    }



    /**

     * @dev See {IERC1155-safeBatchTransferFrom}.

     */

    function safeBatchTransferFrom(

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    )

    external

    virtual

    override

    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        require(to != address(0), "ERC1155: transfer to the zero address");

        require(

            from == _msgSender() || isApprovedForAll(from, _msgSender()),

            "ERC1155: transfer caller is not owner nor approved"

        );



        address operator = _msgSender();



        _beforeTokenTransfer(operator, from, to, ids, amounts, data);



        for (uint256 i = 0; i < ids.length; ++i) {

            uint256 id = ids[i];

            uint256 amount = amounts[i];



            _balances[id][from] = _balances[id][from].sub(

                amount,

                "ERC1155: insufficient balance for transfer"

            );

            _balances[id][to] = _balances[id][to].add(amount);

        }



        emit TransferBatch(operator, from, to, ids, amounts);



        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);

    }



    /**

     * @dev Sets a new URI for a given token ID

     */

    function _setURI(uint256 tokenId, string memory newuri) internal virtual {

        tokenUris[tokenId] = newuri;

        emit URI(newuri, tokenId);

    }



    /**

     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.

     *

     * Emits a {TransferSingle} event.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the

     * acceptance magic value.

     */

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);



        _balances[id][account] = _balances[id][account].add(amount);

        tokenTotalSupply[id] = tokenTotalSupply[id].add(amount);

        emit TransferSingle(operator, address(0), account, id, amount);



        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);

    }



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.

     *

     * Requirements:

     *

     * - `ids` and `amounts` must have the same length.

     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the

     * acceptance magic value.

     */

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);



        for (uint i = 0; i < ids.length; i++) {

            uint256 id = ids[i];

            uint256 amount = amounts[i];

            _balances[id][to] = amount.add(_balances[id][to]);

            tokenTotalSupply[id] = tokenTotalSupply[id].add(amount);

        }



        emit TransferBatch(operator, address(0), to, ids, amounts);



        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);

    }



    /**

     * @dev Destroys `amount` tokens of token type `id` from `account`

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens of token type `id`.

     */

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");



        _balances[id][account] = _balances[id][account].sub(

            amount,

            "ERC1155: burn amount exceeds balance"

        );



        tokenTotalSupply[id] = tokenTotalSupply[id].sub(amount);



        emit TransferSingle(operator, account, address(0), id, amount);

    }



    /**

     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.

     *

     * Requirements:

     *

     * - `ids` and `amounts` must have the same length.

     */

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");



        address operator = _msgSender();



        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");



        for (uint i = 0; i < ids.length; i++) {

            uint256 id = ids[i];

            uint256 amount = amounts[i];

            _balances[id][account] = _balances[id][account].sub(

                amount,

                "ERC1155: burn amount exceeds balance"

            );



            tokenTotalSupply[id] = tokenTotalSupply[id].sub(amount);

        }



        emit TransferBatch(operator, account, address(0), ids, amounts);

    }



    /**

     * @dev Hook that is called before any token transfer. This includes minting

     * and burning, as well as batched variants.

     *

     * The same hook is called on both single and batched variants. For single

     * transfers, the length of the `id` and `amount` arrays will be 1.

     *

     * Calling conditions (for each `id` and `amount` pair):

     *

     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * of token type `id` will be  transferred to `to`.

     * - When `from` is zero, `amount` tokens of token type `id` will be minted

     * for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`

     * will be burned.

     * - `from` and `to` are never both zero.

     * - `ids` and `amounts` have the same, non-zero length.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    )

    internal virtual

    { }



    function _doSafeTransferAcceptanceCheck(

        address operator,

        address from,

        address to,

        uint256 id,

        uint256 amount,

        bytes memory data

    )

    private

    {

        if (to.isContract()) {

            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {

                if (response != IERC1155Receiver(to).onERC1155Received.selector) {

                    revert("ERC1155: ERC1155Receiver rejected tokens");

                }

            } catch Error(string memory reason) {

                revert(reason);

            } catch {

                revert("ERC1155: transfer to non ERC1155Receiver implementer");

            }

        }

    }



    function _doSafeBatchTransferAcceptanceCheck(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    )

    private

    {

        if (to.isContract()) {

            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {

                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {

                    revert("ERC1155: ERC1155Receiver rejected tokens");

                }

            } catch Error(string memory reason) {

                revert(reason);

            } catch {

                revert("ERC1155: transfer to non ERC1155Receiver implementer");

            }

        }

    }



    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);

        array[0] = element;



        return array;

    }

}



// File: contracts/ERC1155/ERC1155Burnable.sol



//imported from: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aaa5ef81cf75454d1c337dc3de03d12480849ad1/contracts/token/ERC1155/ERC1155Burnable.sol







pragma solidity 0.6.12;





/**

 * @dev Extension of {ERC1155} that allows token holders to destroy both their

 * own tokens and those that they have been approved to use.

 *

 * _Available since v3.1._

 */

abstract contract ERC1155Burnable is ERC1155 {

    function burn(address account, uint256 id, uint256 amount) public virtual {

        require(

            account == _msgSender() || isApprovedForAll(account, _msgSender()),

            "ERC1155: caller is not owner nor approved"

        );



        _burn(account, id, amount);

    }



    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public virtual {

        require(

            account == _msgSender() || isApprovedForAll(account, _msgSender()),

            "ERC1155: caller is not owner nor approved"

        );



        _burnBatch(account, ids, amounts);

    }

}



// File: @openzeppelin/contracts/utils/EnumerableSet.sol







pragma solidity ^0.6.0;



/**

 * @dev Library for managing

 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive

 * types.

 *

 * Sets have the following properties:

 *

 * - Elements are added, removed, and checked for existence in constant time

 * (O(1)).

 * - Elements are enumerated in O(n). No guarantees are made on the ordering.

 *

 * ```

 * contract Example {

 *     // Add the library methods

 *     using EnumerableSet for EnumerableSet.AddressSet;

 *

 *     // Declare a set state variable

 *     EnumerableSet.AddressSet private mySet;

 * }

 * ```

 *

 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`

 * (`UintSet`) are supported.

 */

library EnumerableSet {

    // To implement this library for multiple types with as little code

    // repetition as possible, we write it in terms of a generic Set type with

    // bytes32 values.

    // The Set implementation uses private functions, and user-facing

    // implementations (such as AddressSet) are just wrappers around the

    // underlying Set.

    // This means that we can only create new EnumerableSets for types that fit

    // in bytes32.



    struct Set {

        // Storage of set values

        bytes32[] _values;



        // Position of the value in the `values` array, plus 1 because index 0

        // means a value is not in the set.

        mapping (bytes32 => uint256) _indexes;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {

            set._values.push(value);

            // The value is stored at length-1, but we add 1 to all indexes

            // and use 0 as a sentinel value

            set._indexes[value] = set._values.length;

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        // We read and store the value's index to prevent multiple reads from the same storage slot

        uint256 valueIndex = set._indexes[value];



        if (valueIndex != 0) { // Equivalent to contains(set, value)

            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in

            // the array, and then remove the last element (sometimes called as 'swap and pop').

            // This modifies the order of the array, as noted in {at}.



            uint256 toDeleteIndex = valueIndex - 1;

            uint256 lastIndex = set._values.length - 1;



            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs

            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.



            bytes32 lastvalue = set._values[lastIndex];



            // Move the last value to the index where the value to delete is

            set._values[toDeleteIndex] = lastvalue;

            // Update the index for the moved value

            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based



            // Delete the slot where the moved value was stored

            set._values.pop();



            // Delete the index for the deleted slot

            delete set._indexes[value];



            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;

    }



   /**

    * @dev Returns the value stored at position `index` in the set. O(1).

    *

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");

        return set._values[index];

    }



    // AddressSet



    struct AddressSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



   /**

    * @dev Returns the value stored at position `index` in the set. O(1).

    *

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));

    }





    // UintSet



    struct UintSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



   /**

    * @dev Returns the value stored at position `index` in the set. O(1).

    *

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));

    }

}



// File: @openzeppelin/contracts/access/AccessControl.sol







pragma solidity ^0.6.0;









/**

 * @dev Contract module that allows children to implement role-based access

 * control mechanisms.

 *

 * Roles are referred to by their `bytes32` identifier. These should be exposed

 * in the external API and be unique. The best way to achieve this is by

 * using `public constant` hash digests:

 *

 * ```

 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");

 * ```

 *

 * Roles can be used to represent a set of permissions. To restrict access to a

 * function call, use {hasRole}:

 *

 * ```

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

 * accounts that have been granted it.

 */

abstract contract AccessControl is Context {

    using EnumerableSet for EnumerableSet.AddressSet;

    using Address for address;



    struct RoleData {

        EnumerableSet.AddressSet members;

        bytes32 adminRole;

    }



    mapping (bytes32 => RoleData) private _roles;



    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;



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

     * bearer except when using {_setupRole}.

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

    function hasRole(bytes32 role, address account) public view returns (bool) {

        return _roles[role].members.contains(account);

    }



    /**

     * @dev Returns the number of accounts that have `role`. Can be used

     * together with {getRoleMember} to enumerate all bearers of a role.

     */

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {

        return _roles[role].members.length();

    }



    /**

     * @dev Returns one of the accounts that have `role`. `index` must be a

     * value between 0 and {getRoleMemberCount}, non-inclusive.

     *

     * Role bearers are not sorted in any particular way, and their ordering may

     * change at any point.

     *

     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure

     * you perform all queries on the same block. See the following

     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]

     * for more information.

     */

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {

        return _roles[role].members.at(index);

    }



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {

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

     */

    function grantRole(bytes32 role, address account) public virtual {

        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");



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

     */

    function revokeRole(bytes32 role, address account) public virtual {

        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");



        _revokeRole(role, account);

    }



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

    function renounceRole(bytes32 role, address account) public virtual {

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

     * [WARNING]

     * ====

     * This function should only be called from the constructor when setting

     * up the initial roles for the system.

     *

     * Using this function in any other way is effectively circumventing the admin

     * system imposed by {AccessControl}.

     * ====

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

        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);

        _roles[role].adminRole = adminRole;

    }



    function _grantRole(bytes32 role, address account) private {

        if (_roles[role].members.add(account)) {

            emit RoleGranted(role, account, _msgSender());

        }

    }



    function _revokeRole(bytes32 role, address account) private {

        if (_roles[role].members.remove(account)) {

            emit RoleRevoked(role, account, _msgSender());

        }

    }

}



// File: contracts/DigitalaxAccessControls.sol







pragma solidity 0.6.12;





/**

 * @notice Access Controls contract for the Digitalax Platform

 * @author BlockRocket.tech

 */

contract DigitalaxAccessControls is AccessControl {

    /// @notice Role definitions

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");

    bytes32 public constant VERIFIED_MINTER_ROLE = keccak256("VERIFIED_MINTER_ROLE");



    /// @notice Events for adding and removing various roles

    event AdminRoleGranted(

        address indexed beneficiary,

        address indexed caller

    );



    event AdminRoleRemoved(

        address indexed beneficiary,

        address indexed caller

    );



    event MinterRoleGranted(

        address indexed beneficiary,

        address indexed caller

    );



    event MinterRoleRemoved(

        address indexed beneficiary,

        address indexed caller

    );



    event SmartContractRoleGranted(

        address indexed beneficiary,

        address indexed caller

    );



    event SmartContractRoleRemoved(

        address indexed beneficiary,

        address indexed caller

    );



    event VerifiedMinterRoleGranted(

        address indexed beneficiary,

        address indexed caller

    );



    event VerifiedMinterRoleRemoved(

        address indexed beneficiary,

        address indexed caller

    );



    /**

     * @notice The deployer is automatically given the admin role which will allow them to then grant roles to other addresses

     */

    constructor() public {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    }



    /////////////

    // Lookups //

    /////////////



    /**

     * @notice Used to check whether an address has the admin role

     * @param _address EOA or contract being checked

     * @return bool True if the account has the role or false if it does not

     */

    function hasAdminRole(address _address) external view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, _address);

    }



    /**

     * @notice Used to check whether an address has the minter role

     * @param _address EOA or contract being checked

     * @return bool True if the account has the role or false if it does not

     */

    function hasMinterRole(address _address) external view returns (bool) {

        return hasRole(MINTER_ROLE, _address);

    }



    /**

     * @notice Used to check whether an address has the verified minter role

     * @param _address EOA or contract being checked

     * @return bool True if the account has the role or false if it does not

     */

    function hasVerifiedMinterRole(address _address)

        external

        view

        returns (bool)

    {

        return hasRole(VERIFIED_MINTER_ROLE, _address);

    }



    /**

     * @notice Used to check whether an address has the smart contract role

     * @param _address EOA or contract being checked

     * @return bool True if the account has the role or false if it does not

     */

    function hasSmartContractRole(address _address) external view returns (bool) {

        return hasRole(SMART_CONTRACT_ROLE, _address);

    }



    ///////////////

    // Modifiers //

    ///////////////



    /**

     * @notice Grants the admin role to an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract receiving the new role

     */

    function addAdminRole(address _address) external {

        grantRole(DEFAULT_ADMIN_ROLE, _address);

        emit AdminRoleGranted(_address, _msgSender());

    }



    /**

     * @notice Removes the admin role from an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract affected

     */

    function removeAdminRole(address _address) external {

        revokeRole(DEFAULT_ADMIN_ROLE, _address);

        emit AdminRoleRemoved(_address, _msgSender());

    }



    /**

     * @notice Grants the minter role to an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract receiving the new role

     */

    function addMinterRole(address _address) external {

        grantRole(MINTER_ROLE, _address);

        emit MinterRoleGranted(_address, _msgSender());

    }



    /**

     * @notice Removes the minter role from an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract affected

     */

    function removeMinterRole(address _address) external {

        revokeRole(MINTER_ROLE, _address);

        emit MinterRoleRemoved(_address, _msgSender());

    }



    /**

     * @notice Grants the verified minter role to an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract receiving the new role

     */

    function addVerifiedMinterRole(address _address) external {

        grantRole(VERIFIED_MINTER_ROLE, _address);

        emit VerifiedMinterRoleGranted(_address, _msgSender());

    }



    /**

     * @notice Removes the verified minter role from an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract affected

     */

    function removeVerifiedMinterRole(address _address) external {

        revokeRole(VERIFIED_MINTER_ROLE, _address);

        emit VerifiedMinterRoleRemoved(_address, _msgSender());

    }



    /**

     * @notice Grants the smart contract role to an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract receiving the new role

     */

    function addSmartContractRole(address _address) external {

        grantRole(SMART_CONTRACT_ROLE, _address);

        emit SmartContractRoleGranted(_address, _msgSender());

    }



    /**

     * @notice Removes the smart contract role from an address

     * @dev The sender must have the admin role

     * @param _address EOA or contract affected

     */

    function removeSmartContractRole(address _address) external {

        revokeRole(SMART_CONTRACT_ROLE, _address);

        emit SmartContractRoleRemoved(_address, _msgSender());

    }

}



// File: @openzeppelin/contracts/token/ERC721/IERC721.sol







pragma solidity ^0.6.2;





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

    function safeTransferFrom(address from, address to, uint256 tokenId) external;



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

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



// File: @openzeppelin/contracts/token/ERC721/IERC721Metadata.sol







pragma solidity ^0.6.2;





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



// File: @openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol







pragma solidity ^0.6.2;





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

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);



    /**

     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.

     * Use along with {totalSupply} to enumerate all tokens.

     */

    function tokenByIndex(uint256 index) external view returns (uint256);

}



// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol







pragma solidity ^0.6.0;



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

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)

    external returns (bytes4);

}



// File: @openzeppelin/contracts/utils/EnumerableMap.sol







pragma solidity ^0.6.0;



/**

 * @dev Library for managing an enumerable variant of Solidity's

 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]

 * type.

 *

 * Maps have the following properties:

 *

 * - Entries are added, removed, and checked for existence in constant time

 * (O(1)).

 * - Entries are enumerated in O(n). No guarantees are made on the ordering.

 *

 * ```

 * contract Example {

 *     // Add the library methods

 *     using EnumerableMap for EnumerableMap.UintToAddressMap;

 *

 *     // Declare a set state variable

 *     EnumerableMap.UintToAddressMap private myMap;

 * }

 * ```

 *

 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are

 * supported.

 */

library EnumerableMap {

    // To implement this library for multiple types with as little code

    // repetition as possible, we write it in terms of a generic Map type with

    // bytes32 keys and values.

    // The Map implementation uses private functions, and user-facing

    // implementations (such as Uint256ToAddressMap) are just wrappers around

    // the underlying Map.

    // This means that we can only create new EnumerableMaps for types that fit

    // in bytes32.



    struct MapEntry {

        bytes32 _key;

        bytes32 _value;

    }



    struct Map {

        // Storage of map keys and values

        MapEntry[] _entries;



        // Position of the entry defined by a key in the `entries` array, plus 1

        // because index 0 means a key is not in the map.

        mapping (bytes32 => uint256) _indexes;

    }



    /**

     * @dev Adds a key-value pair to a map, or updates the value for an existing

     * key. O(1).

     *

     * Returns true if the key was added to the map, that is if it was not

     * already present.

     */

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        // We read and store the key's index to prevent multiple reads from the same storage slot

        uint256 keyIndex = map._indexes[key];



        if (keyIndex == 0) { // Equivalent to !contains(map, key)

            map._entries.push(MapEntry({ _key: key, _value: value }));

            // The entry is stored at length-1, but we add 1 to all indexes

            // and use 0 as a sentinel value

            map._indexes[key] = map._entries.length;

            return true;

        } else {

            map._entries[keyIndex - 1]._value = value;

            return false;

        }

    }



    /**

     * @dev Removes a key-value pair from a map. O(1).

     *

     * Returns true if the key was removed from the map, that is if it was present.

     */

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        // We read and store the key's index to prevent multiple reads from the same storage slot

        uint256 keyIndex = map._indexes[key];



        if (keyIndex != 0) { // Equivalent to contains(map, key)

            // To delete a key-value pair from the _entries array in O(1), we swap the entry to delete with the last one

            // in the array, and then remove the last entry (sometimes called as 'swap and pop').

            // This modifies the order of the array, as noted in {at}.



            uint256 toDeleteIndex = keyIndex - 1;

            uint256 lastIndex = map._entries.length - 1;



            // When the entry to delete is the last one, the swap operation is unnecessary. However, since this occurs

            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.



            MapEntry storage lastEntry = map._entries[lastIndex];



            // Move the last entry to the index where the entry to delete is

            map._entries[toDeleteIndex] = lastEntry;

            // Update the index for the moved entry

            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based



            // Delete the slot where the moved entry was stored

            map._entries.pop();



            // Delete the index for the deleted slot

            delete map._indexes[key];



            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Returns true if the key is in the map. O(1).

     */

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;

    }



    /**

     * @dev Returns the number of key-value pairs in the map. O(1).

     */

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;

    }



   /**

    * @dev Returns the key-value pair stored at position `index` in the map. O(1).

    *

    * Note that there are no guarantees on the ordering of entries inside the

    * array, and it may change when more entries are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");



        MapEntry storage entry = map._entries[index];

        return (entry._key, entry._value);

    }



    /**

     * @dev Returns the value associated with `key`.  O(1).

     *

     * Requirements:

     *

     * - `key` must be in the map.

     */

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");

    }



    /**

     * @dev Same as {_get}, with a custom error message when `key` is not in the map.

     */

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];

        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)

        return map._entries[keyIndex - 1]._value; // All indexes are 1-based

    }



    // UintToAddressMap



    struct UintToAddressMap {

        Map _inner;

    }



    /**

     * @dev Adds a key-value pair to a map, or updates the value for an existing

     * key. O(1).

     *

     * Returns true if the key was added to the map, that is if it was not

     * already present.

     */

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the key was removed from the map, that is if it was present.

     */

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));

    }



    /**

     * @dev Returns true if the key is in the map. O(1).

     */

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));

    }



    /**

     * @dev Returns the number of elements in the map. O(1).

     */

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);

    }



   /**

    * @dev Returns the element stored at position `index` in the set. O(1).

    * Note that there are no guarantees on the ordering of values inside the

    * array, and it may change when more values are added or removed.

    *

    * Requirements:

    *

    * - `index` must be strictly less than {length}.

    */

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);

        return (uint256(key), address(uint256(value)));

    }



    /**

     * @dev Returns the value associated with `key`.  O(1).

     *

     * Requirements:

     *

     * - `key` must be in the map.

     */

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));

    }



    /**

     * @dev Same as {get}, with a custom error message when `key` is not in the map.

     */

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));

    }

}



// File: @openzeppelin/contracts/utils/Strings.sol







pragma solidity ^0.6.0;



/**

 * @dev String operations.

 */

library Strings {

    /**

     * @dev Converts a `uint256` to its ASCII `string` representation.

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

        uint256 index = digits - 1;

        temp = value;

        while (temp != 0) {

            buffer[index--] = byte(uint8(48 + temp % 10));

            temp /= 10;

        }

        return string(buffer);

    }

}



// File: contracts/ERC721/ERC721WithSameTokenURIForAllTokens.sol







pragma solidity 0.6.12;

























/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://eips.ethereum.org/EIPS/eip-721

 * @dev This is a modified OZ ERC721 base contract with one change where all tokens have the same token URI

 */

contract ERC721WithSameTokenURIForAllTokens is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;

    using Address for address;

    using EnumerableSet for EnumerableSet.UintSet;

    using EnumerableMap for EnumerableMap.UintToAddressMap;

    using Strings for uint256;



    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;



    // Mapping from holder address to their (enumerable) set of owned tokens

    mapping (address => EnumerableSet.UintSet) private _holderTokens;



    // Enumerable mapping from token ids to their owners

    EnumerableMap.UintToAddressMap private _tokenOwners;



    // Mapping from token ID to approved address

    mapping (uint256 => address) private _tokenApprovals;



    // Mapping from owner to operator approvals

    mapping (address => mapping (address => bool)) private _operatorApprovals;



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Single token URI for all tokens

    string public tokenURI_;



    /*

     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231

     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e

     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3

     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc

     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465

     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5

     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde

     *

     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^

     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd

     */

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;



    /*

     *     bytes4(keccak256('name()')) == 0x06fdde03

     *     bytes4(keccak256('symbol()')) == 0x95d89b41

     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd

     *

     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f

     */

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;



    /*

     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd

     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59

     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7

     *

     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63

     */

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;



    /**

     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.

     */

    constructor (string memory name, string memory symbol) public {

        _name = name;

        _symbol = symbol;



        // register the supported interfaces to conform to ERC721 via ERC165

        _registerInterface(_INTERFACE_ID_ERC721);

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);

        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);

    }



    /**

     * @dev See {IERC721-balanceOf}.

     */

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");



        return _holderTokens[owner].length();

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");

    }



    /**

     * @dev See {IERC721Metadata-name}.

     */

    function name() public view override returns (string memory) {

        return _name;

    }



    /**

     * @dev See {IERC721Metadata-symbol}.

     */

    function symbol() public view override returns (string memory) {

        return _symbol;

    }



    /**

     * @dev See {IERC721Metadata-tokenURI}.

     */

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");



        return tokenURI_;

    }



    /**

     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.

     */

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);

    }



    /**

     * @dev See {IERC721Enumerable-totalSupply}.

     */

    function totalSupply() public view override returns (uint256) {

        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds

        return _tokenOwners.length();

    }



    /**

     * @dev See {IERC721Enumerable-tokenByIndex}.

     */

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);

        return tokenId;

    }



    /**

     * @dev See {IERC721-approve}.

     */

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);

        require(to != owner, "ERC721: approval to current owner");



        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),

            "ERC721: approve caller is not owner nor approved for all"

        );



        _approve(to, tokenId);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");



        _operatorApprovals[_msgSender()][operator] = approved;

        emit ApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC721-isApprovedForAll}.

     */

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev See {IERC721-transferFrom}.

     */

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");



        _transfer(from, to, tokenId);

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");

    }



    /**

     * @dev Returns whether `tokenId` exists.

     *

     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

     *

     * Tokens start existing when they are minted (`_mint`),

     * and stop existing when they are burned (`_burn`).

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);

    }



    /**

     * @dev Returns whether `spender` is allowed to manage `tokenId`.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");

        address owner = ownerOf(tokenId);

        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

    }



    /**

     * @dev Safely mints `tokenId` and transfers it to `to`.

     *

     * Requirements:

     d*

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

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);

        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");

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



        _holderTokens[to].add(tokenId);



        _tokenOwners.set(tokenId, to);



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

        address owner = ownerOf(tokenId);



        _beforeTokenTransfer(owner, address(0), tokenId);



        // Clear approvals

        _approve(address(0), tokenId);



        _holderTokens[owner].remove(tokenId);



        _tokenOwners.remove(tokenId);



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

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");

        require(to != address(0), "ERC721: transfer to the zero address");



        _beforeTokenTransfer(from, to, tokenId);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId);



        _holderTokens[from].remove(tokenId);

        _holderTokens[to].add(tokenId);



        _tokenOwners.set(tokenId, to);



        emit Transfer(from, to, tokenId);

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

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)

    private returns (bool)

    {

        if (!to.isContract()) {

            return true;

        }

        bytes memory returndata = to.functionCall(abi.encodeWithSelector(

                IERC721Receiver(to).onERC721Received.selector,

                _msgSender(),

                from,

                tokenId,

                _data

            ), "ERC721: transfer to non ERC721Receiver implementer");

        bytes4 retval = abi.decode(returndata, (bytes4));

        return (retval == _ERC721_RECEIVED);

    }



    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;

        emit Approval(ownerOf(tokenId), to, tokenId);

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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}



// File: contracts/DigitalaxPodeNFT.sol







pragma solidity 0.6.12;







/**

 * @title Digitalax Pode NFT

 * @dev To facilitate the pode sale for the Digitialax platform

 */

contract DigitalaxPodeNFT is ERC721WithSameTokenURIForAllTokens("DigitalaxPode", "PODE") {

    using SafeMath for uint256;



    // @notice event emitted upon construction of this contract, used to bootstrap external indexers

    event DigitalaxPodeNFTContractDeployed();



    // @notice event emitted when a contributor buys a Pode NFT

    event PodePurchased(

        address indexed buyer,

        uint256 indexed tokenId,

        uint256 contribution

    );



    // @notice event emitted when a contributors amount is increased

    event ContributionIncreased(

        address indexed buyer,

        uint256 contribution

    );



    // @notice all funds will be sent to this address pon purchase of a Pode NFT

    address payable public fundsMultisig;



    // @notice start date for them the Pode sale is open to the public, before this data no purchases can be made

    uint256 public podeStartTimestamp;



    // @notice end date for them the Pode sale is closed, no more purchased can be made after this point

    uint256 public podeEndTimestamp;



    // @notice set after end time has been changed once, prevents further changes to end timestamp

    bool public podeEndTimestampLocked;



    // @notice set the transfer lock time, so no noe can move Pode NFT

    uint256 public podeLockTimestamp;



    // @notice the minimum amount a buyer can contribute in a single go

    uint256 public constant minimumContributionAmount = 1 ether;



    // @notice accumulative => contribution total

    mapping(address => uint256) public contribution;



    // @notice global accumulative contribution amount

    uint256 public totalContributions;



    // @notice max number of paid contributions to the pode sale

    uint256 public constant maxPodeContributionTokens = 500;



    constructor(

        address payable _fundsMultisig,

        uint256 _podeStartTimestamp,

        uint256 _podeEndTimestamp,

        uint256 _podeLockTimestamp,

        string memory _tokenURI

    ) public {

        fundsMultisig = _fundsMultisig;

        podeStartTimestamp = _podeStartTimestamp;

        podeEndTimestamp = _podeEndTimestamp;

        podeLockTimestamp = _podeLockTimestamp;

        tokenURI_ = _tokenURI;

        emit DigitalaxPodeNFTContractDeployed();

    }



    /**

     * @dev Facilitating the initial purchase of a Pode NFT

     * @dev Cannot contribute less than minimumContributionAmount

     * @dev Reverts if already owns an pode token

     * @dev Buyer receives a NFT on success

     * @dev All funds move to fundsMultisig

     */

    function buy() public payable {

        require(contribution[_msgSender()] == 0, "DigitalaxPodeNFT.buy: You already own a pode NFT");

        require(

            _getNow() >= podeStartTimestamp && _getNow() <= podeEndTimestamp,

            "DigitalaxPodeNFT.buy: No pode are available outside of the pode window"

        );



        uint256 _contributionAmount = msg.value;

        require(

            _contributionAmount >= minimumContributionAmount,

            "DigitalaxPodeNFT.buy: Contribution does not meet minimum requirement"

        );



        require(remainingPodeTokens() > 0, "DigitalaxPodeNFT.buy: Total number of pode token holders reached");



        contribution[_msgSender()] = _contributionAmount;

        totalContributions = totalContributions.add(_contributionAmount);



        (bool fundsTransferSuccess,) = fundsMultisig.call{value : _contributionAmount}("");

        require(fundsTransferSuccess, "DigitalaxPodeNFT.buy: Unable to send contribution to funds multisig");



        uint256 tokenId = totalSupply().add(1);

        _safeMint(_msgSender(), tokenId);



        emit PodePurchased(_msgSender(), tokenId, _contributionAmount);

    }



    /**

    * @dev Returns total remaining number of tokens available in the Pode sale

    */

    function remainingPodeTokens() public view returns (uint256) {

        return _getMaxPodeContributionTokens() - totalSupply();

    }



    // Internal



    function _getNow() internal virtual view returns (uint256) {

        return block.timestamp;

    }



    function _getMaxPodeContributionTokens() internal virtual view returns (uint256) {

        return maxPodeContributionTokens;

    }



    /**

     * @dev Before token transfer hook to enforce that no token can be moved to another address until the pode sale has ended

     */

    function _beforeTokenTransfer(address from, address, uint256) internal override {

        if (from != address(0) && _getNow() <= podeLockTimestamp) {

            revert("DigitalaxPodeNFT._beforeTokenTransfer: Transfers are currently locked at this time");

        }

    }

}



// File: contracts/DigitalaxPodeMaterials.sol







pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;











/**

 * @title Digitalax PODEM NFT 

 */

contract DigitalaxPodeMaterials is ERC1155Burnable {



    // @notice event emitted on contract creation

    event DigitalaxPodeMaterialsDeployed();



    // @notice a single child has been created

    event TokenUriAdded(

        uint256 indexed tokenId

    );



    string public name;

    string public symbol;



    // @notice current token ID pointer

    uint256 public tokenIdPointer;



    /// @dev Limit of tokens per address

    uint256 public maxLimit = 1;



    /// @dev List of metadata

    string[] public metadataList;



    // @notice enforcing access controls

    DigitalaxAccessControls public accessControls;

    DigitalaxPodeNFT public podeNft;



    constructor(

        string memory _name,

        string memory _symbol,

        DigitalaxAccessControls _accessControls,

        DigitalaxPodeNFT _podeNft

    ) public {

        name = _name;

        symbol = _symbol;

        accessControls = _accessControls;

        podeNft = _podeNft;

        emit DigitalaxPodeMaterialsDeployed();

    }



    ///////////////////////////

    // Creating new nft //

    ///////////////////////////



    /**

     @notice Creates a single child ERC1155 token

     @dev Only callable with smart contact role

     @return id the generated child Token ID

     */

    function addTokenUri(string calldata _uri) external returns (uint256 id) {

        require(

            accessControls.hasSmartContractRole(_msgSender()) || accessControls.hasAdminRole(_msgSender()),

            "DigitalaxPodeMaterials.createChild: Sender must be smart contract or admin"

        );



        require(bytes(_uri).length > 0, "DigitalaxPodeMaterials.createChild: URI is a blank string");



        id = tokenIdPointer;

        _setURI(id, _uri);

        tokenIdPointer = tokenIdPointer.add(1);



        emit TokenUriAdded(id);

    }





    //////////////////////////////////

    // Minting of existing children //

    //////////////////////////////////



    /**

      @notice Mints a single child ERC1155 tokens, increasing its supply by the _amount specified. msg.data along with the

      parent contract as the recipient can be used to map the created children to a given parent token

      @dev Only callable with smart contact role

     */

    function mint(address _beneficiary) external {

        require(totalBalanceOf(_msgSender()) < maxLimit, "DigitalaxPodeMaterials.mint: Sender already minted");

        require(podeNft.balanceOf(_msgSender()) > 0, "DigitalaxPodeMaterials.mint: Sender must have PODE NFT");



        uint256 _randomIndex = _rand();

        _mint(_beneficiary, _randomIndex, 1, abi.encodePacked(""));

    }



    /**

     @notice Method for setting max limit

     @dev Only admin

     @param _maxLimit New max limit

     */

    function setMaxLimit(uint256 _maxLimit) external {

        require(

            accessControls.hasAdminRole(_msgSender()),

            "DigitalaxPodeMaterials.addTokenURI: Sender must be an authorised contract or admin"

        );

        maxLimit = _maxLimit;

    }



    function updateAccessControls(DigitalaxAccessControls _accessControls) external {

        require(

            accessControls.hasAdminRole(_msgSender()),

            "DigitalaxPodeMaterials.updateAccessControls: Sender must be admin"

        );



        require(

            address(_accessControls) != address(0),

            "DigitalaxPodeMaterials.updateAccessControls: New access controls cannot be ZERO address"

        );



        accessControls = _accessControls;

    }



    /**

     @notice Method for getting balance of account

     @param account Account address

     */

    function totalBalanceOf(address account) public view returns (uint256) {

        require(account != address(0), "DigitalaxPodeMaterials: balance query for the zero address");



        uint256 totalBalance = 0;

        for (uint256 i = 0; i < tokenIdPointer; i ++) {

            totalBalance = totalBalance.add(balanceOf(account, i));

        }



        return totalBalance;

    }



    /**

     @notice Method for getting tokenId by index

     @param account Account address

     @param index Index

     */

    function tokenOfOwnerByIndex(address account, uint256 index) public view returns (uint256) {

        uint256 tokenId;

        uint256 holdingIndex;

        for (uint256 i = 0; i < tokenIdPointer; i ++) {

            if (balanceOf(account, i) > 0) {

                if (holdingIndex == index) {

                    tokenId = i;

                }

                holdingIndex = holdingIndex.add(1);

            }

        }



        if (holdingIndex <= index) {

            revert("Index out of holding tokens.");

        }

        return tokenId;

    }



    /**

     @notice Generate unpredictable random number

     */

    function _rand() private view returns (uint256) {

        uint256 seed = uint256(keccak256(abi.encodePacked(

            block.timestamp + block.difficulty +

            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +

            block.gaslimit + 

            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +

            block.number

        )));



        return seed.sub(seed.div(tokenIdPointer).mul(tokenIdPointer));

    }



    /**

    * @notice Reclaims ERC20 Compatible tokens for entire balance

    * @dev Only access controls admin

    * @param _tokenContract The address of the token contract

    */

    function reclaimERC20(address _tokenContract) external {

        require(

            accessControls.hasAdminRole(_msgSender()),

            "DigitalaxMarketplace.reclaimERC20: Sender must be admin"

        );

        require(_tokenContract != address(0), "Invalid address");

        IERC20 token = IERC20(_tokenContract);

        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(msg.sender, balance), "Transfer failed");

    }



    /**

     * @notice Reclaims ETH, drains all ETH sitting on the smart contract

     * @dev The instant buy feature means technically, ETH should never sit on contract.

     * @dev Only access controls admin can access

     */

    function reclaimETH() external {

        require(

            accessControls.hasAdminRole(_msgSender()),

            "DigitalaxMarketplace.reclaimETH: Sender must be admin"

        );

        msg.sender.transfer(address(this).balance);

    }

}