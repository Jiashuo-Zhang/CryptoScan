/**

 *Submitted for verification at Etherscan.io on 2023-06-21

*/



// Sources flattened with hardhat v2.14.1 https://hardhat.org



// File @openzeppelin/contracts/utils/[email protected]



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





// File @openzeppelin/contracts/access/[email protected]





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





// File @openzeppelin/contracts/utils/[email protected]





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





// File @openzeppelin/contracts/utils/escrow/[email protected]





// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)



pragma solidity ^0.8.0;





/**

 * @title Escrow

 * @dev Base escrow contract, holds funds designated for a payee until they

 * withdraw them.

 *

 * Intended usage: This contract (and derived escrow contracts) should be a

 * standalone contract, that only interacts with the contract that instantiated

 * it. That way, it is guaranteed that all Ether will be handled according to

 * the `Escrow` rules, and there is no need to check for payable functions or

 * transfers in the inheritance tree. The contract that uses the escrow as its

 * payment method should be its owner, and provide public methods redirecting

 * to the escrow's deposit and withdraw.

 */

contract Escrow is Ownable {

    using Address for address payable;



    event Deposited(address indexed payee, uint256 weiAmount);

    event Withdrawn(address indexed payee, uint256 weiAmount);



    mapping(address => uint256) private _deposits;



    function depositsOf(address payee) public view returns (uint256) {

        return _deposits[payee];

    }



    /**

     * @dev Stores the sent amount as credit to be withdrawn.

     * @param payee The destination address of the funds.

     *

     * Emits a {Deposited} event.

     */

    function deposit(address payee) public payable virtual onlyOwner {

        uint256 amount = msg.value;

        _deposits[payee] += amount;

        emit Deposited(payee, amount);

    }



    /**

     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the

     * recipient.

     *

     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.

     * Make sure you trust the recipient, or are either following the

     * checks-effects-interactions pattern or using {ReentrancyGuard}.

     *

     * @param payee The address whose funds will be withdrawn and transferred to.

     *

     * Emits a {Withdrawn} event.

     */

    function withdraw(address payable payee) public virtual onlyOwner {

        uint256 payment = _deposits[payee];



        _deposits[payee] = 0;



        payee.sendValue(payment);



        emit Withdrawn(payee, payment);

    }

}





// File @openzeppelin/contracts/security/[email protected]





// OpenZeppelin Contracts (last updated v4.8.0) (security/PullPayment.sol)



pragma solidity ^0.8.0;



/**

 * @dev Simple implementation of a

 * https://consensys.github.io/smart-contract-best-practices/development-recommendations/general/external-calls/#favor-pull-over-push-for-external-calls[pull-payment]

 * strategy, where the paying contract doesn't interact directly with the

 * receiver account, which must withdraw its payments itself.

 *

 * Pull-payments are often considered the best practice when it comes to sending

 * Ether, security-wise. It prevents recipients from blocking execution, and

 * eliminates reentrancy concerns.

 *

 * TIP: If you would like to learn more about reentrancy and alternative ways

 * to protect against it, check out our blog post

 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].

 *

 * To use, derive from the `PullPayment` contract, and use {_asyncTransfer}

 * instead of Solidity's `transfer` function. Payees can query their due

 * payments with {payments}, and retrieve them with {withdrawPayments}.

 */

abstract contract PullPayment {

    Escrow private immutable _escrow;



    constructor() {

        _escrow = new Escrow();

    }



    /**

     * @dev Withdraw accumulated payments, forwarding all gas to the recipient.

     *

     * Note that _any_ account can call this function, not just the `payee`.

     * This means that contracts unaware of the `PullPayment` protocol can still

     * receive funds this way, by having a separate account call

     * {withdrawPayments}.

     *

     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.

     * Make sure you trust the recipient, or are either following the

     * checks-effects-interactions pattern or using {ReentrancyGuard}.

     *

     * @param payee Whose payments will be withdrawn.

     *

     * Causes the `escrow` to emit a {Withdrawn} event.

     */

    function withdrawPayments(address payable payee) public virtual {

        _escrow.withdraw(payee);

    }



    /**

     * @dev Returns the payments owed to an address.

     * @param dest The creditor's address.

     */

    function payments(address dest) public view returns (uint256) {

        return _escrow.depositsOf(dest);

    }



    /**

     * @dev Called by the payer to store the sent amount as credit to be pulled.

     * Funds sent in this way are stored in an intermediate {Escrow} contract, so

     * there is no danger of them being spent before withdrawal.

     *

     * @param dest The destination address of the funds.

     * @param amount The amount to transfer.

     *

     * Causes the `escrow` to emit a {Deposited} event.

     */

    function _asyncTransfer(address dest, uint256 amount) internal virtual {

        _escrow.deposit{value: amount}(dest);

    }

}





// File @openzeppelin/contracts/utils/introspection/[email protected]





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





// File @openzeppelin/contracts/token/ERC721/[email protected]





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)



pragma solidity ^0.8.0;



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

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;



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

    function safeTransferFrom(address from, address to, uint256 tokenId) external;



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

     * @dev Approve or remove `operator` as an operator for the caller.

     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.

     *

     * Requirements:

     *

     * - The `operator` cannot be the caller.

     *

     * Emits an {ApprovalForAll} event.

     */

    function setApprovalForAll(address operator, bool approved) external;



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





// File @openzeppelin/contracts/token/ERC721/extensions/[email protected]





// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)



pragma solidity ^0.8.0;



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





// File @openzeppelin/contracts/token/ERC721/[email protected]





// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)



pragma solidity ^0.8.0;



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





// File @openzeppelin/contracts/utils/introspection/[email protected]





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





// File @openzeppelin/contracts/utils/math/[email protected]





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





// File @openzeppelin/contracts/utils/math/[email protected]





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





// File @openzeppelin/contracts/utils/[email protected]





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





// File @openzeppelin/contracts/token/ERC721/[email protected]





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)



pragma solidity ^0.8.0;















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

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");



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

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {

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

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {

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

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {

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

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

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

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {

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

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}



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

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}



    /**

     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.

     *

     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant

     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such

     * that `ownerOf(tokenId)` is `a`.

     */

    // solhint-disable-next-line func-name-mixedcase

    function __unsafe_increaseBalance(address account, uint256 amount) internal {

        _balances[account] += amount;

    }

}





// File @openzeppelin/contracts/token/ERC20/[email protected]





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





// File @openzeppelin/contracts/utils/[email protected]





// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)



pragma solidity ^0.8.0;



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





// File @openzeppelin/contracts/utils/math/[email protected]





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





// File contracts/common/meta-transactions/ContentMixin.sol







pragma solidity ^0.8.0;



abstract contract ContextMixin {

    function msgSender()

        internal

        view

        returns (address payable sender)

    {

        if (msg.sender == address(this)) {

            bytes memory array = msg.data;

            uint256 index = msg.data.length;

            assembly {

                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.

                sender := and(

                    mload(add(array, index)),

                    0xffffffffffffffffffffffffffffffffffffffff

                )

            }

        } else {

            sender = payable(msg.sender);

        }

        return sender;

    }

}





// File contracts/common/meta-transactions/Initializable.sol







pragma solidity ^0.8.0;



contract Initializable {

    bool inited = false;



    modifier initializer() {

        require(!inited, "already inited");

        _;

        inited = true;

    }

}





// File contracts/common/meta-transactions/EIP712Base.sol







pragma solidity ^0.8.0;



contract EIP712Base is Initializable {

    struct EIP712Domain {

        string name;

        string version;

        address verifyingContract;

        bytes32 salt;

    }



    string constant public ERC712_VERSION = "1";



    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(

        bytes(

            "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"

        )

    );

    bytes32 internal domainSeperator;



    // supposed to be called once while initializing.

    // one of the contracts that inherits this contract follows proxy pattern

    // so it is not possible to do this in a constructor

    function _initializeEIP712(

        string memory name

    )

        internal

        initializer

    {

        _setDomainSeperator(name);

    }



    function _setDomainSeperator(string memory name) internal {

        domainSeperator = keccak256(

            abi.encode(

                EIP712_DOMAIN_TYPEHASH,

                keccak256(bytes(name)),

                keccak256(bytes(ERC712_VERSION)),

                address(this),

                bytes32(getChainId())

            )

        );

    }



    function getDomainSeperator() public view returns (bytes32) {

        return domainSeperator;

    }



    function getChainId() public view returns (uint256) {

        uint256 id;

        assembly {

            id := chainid()

        }

        return id;

    }



    /**

     * Accept message hash and returns hash message in EIP712 compatible form

     * So that it can be used to recover signer from signature signed using EIP712 formatted data

     * https://eips.ethereum.org/EIPS/eip-712

     * "\\x19" makes the encoding deterministic

     * "\\x01" is the version byte to make it compatible to EIP-191

     */

    function toTypedMessageHash(bytes32 messageHash)

        internal

        view

        returns (bytes32)

    {

        return

            keccak256(

                abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)

            );

    }

}





// File contracts/common/meta-transactions/NativeMetaTransaction.sol







pragma solidity ^0.8.0;





contract NativeMetaTransaction is EIP712Base {

    using SafeMath for uint256;

    bytes32 private constant META_TRANSACTION_TYPEHASH = keccak256(

        bytes(

            "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"

        )

    );

    event MetaTransactionExecuted(

        address userAddress,

        address payable relayerAddress,

        bytes functionSignature

    );

    mapping(address => uint256) nonces;



    /*

     * Meta transaction structure.

     * No point of including value field here as if user is doing value transfer then he has the funds to pay for gas

     * He should call the desired function directly in that case.

     */

    struct MetaTransaction {

        uint256 nonce;

        address from;

        bytes functionSignature;

    }



    function executeMetaTransaction(

        address userAddress,

        bytes memory functionSignature,

        bytes32 sigR,

        bytes32 sigS,

        uint8 sigV

    ) public payable returns (bytes memory) {

        MetaTransaction memory metaTx = MetaTransaction({

            nonce: nonces[userAddress],

            from: userAddress,

            functionSignature: functionSignature

        });



        require(

            verify(userAddress, metaTx, sigR, sigS, sigV),

            "Signer and signature do not match"

        );



        // increase nonce for user (to avoid re-use)

        nonces[userAddress] = nonces[userAddress].add(1);



        emit MetaTransactionExecuted(

            userAddress,

            payable(msg.sender),

            functionSignature

        );



        // Append userAddress and relayer address at the end to extract it from calling context

        (bool success, bytes memory returnData) = address(this).call(

            abi.encodePacked(functionSignature, userAddress)

        );

        require(success, "Function call not successful");



        return returnData;

    }



    function hashMetaTransaction(MetaTransaction memory metaTx)

        internal

        pure

        returns (bytes32)

    {

        return

            keccak256(

                abi.encode(

                    META_TRANSACTION_TYPEHASH,

                    metaTx.nonce,

                    metaTx.from,

                    keccak256(metaTx.functionSignature)

                )

            );

    }



    function getNonce(address user) public view returns (uint256 nonce) {

        nonce = nonces[user];

    }



    function verify(

        address signer,

        MetaTransaction memory metaTx,

        bytes32 sigR,

        bytes32 sigS,

        uint8 sigV

    ) internal view returns (bool) {

        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");

        return

            signer ==

            ecrecover(

                toTypedMessageHash(hashMetaTransaction(metaTx)),

                sigV,

                sigR,

                sigS

            );

    }

}





// File contracts/ERC721ChaosCoinClub.sol







pragma solidity ^0.8.0;

















contract OwnableDelegateProxy {}



/**

 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users

 */

contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;

}



/**

 * @title ERC721ChaosCoinClub

 * ERC721ChaosCoinClub - ERC721 contract that can whitelists 2 trading proxy addresses, can approve other contract addresses, 

 * has minting functionality to mint with both Eth and a configurable ERC20, has an allow list for a certain number of discounted mints,

 * has multi-mint functionality with discount 

 */

abstract contract ERC721ChaosCoinClub is ERC721, ContextMixin, NativeMetaTransaction,  PullPayment, Ownable {

    using SafeMath for uint256;

    using Counters for Counters.Counter;



    /**

     * We rely on the OZ Counter util to keep track of the next available ID.

     * We track the nextTokenId instead of the currentTokenId to save users on gas costs. 

     */ 

    Counters.Counter internal _nextTokenId;

    address proxyRegistryAddress;

    address proxyRegistryAddress2;

    bool private _isMarketplace1Approved = true;

    bool private _isMarketplace2Approved = true;

    mapping(address=>bool) proxyAddressApproval;





    uint256 public mintingFee;

    uint256 public discountFee;

    uint256 public maxSupply;

    uint256 public maxMintSize;

    uint256 public maxMintBonusRounds;

    uint256 public maxMintDiscount;



    uint256 public mintingChaosFee;

    uint256 public nftsPerTier;



    mapping(address => uint256) public allowList;



    IERC20 public tokenAddress;

    bool mintingWithChaos = true;

    bool internal chaosLock;



modifier chaosGuard() {

     require(!chaosLock);

     chaosLock = true;

      _;

      chaosLock= false;

  }



  modifier callerIsUser() {

    require(tx.origin == msg.sender, "The caller is another contract");

    _;

  }



    constructor(

        string memory _name,

        string memory _symbol,

        address _proxyRegistryAddress,

        address _proxyRegistryAddress2,

        uint256 _mintingFee,

        uint256 _discountFee,

        uint256 _maxSupply,

        uint256 _maxMintSize,

        uint256 _maxMintBonusRounds,

        uint256 _maxMintDiscount,

        uint256 _nftsPerTier,

        uint256 _mintingChaosFee



    ) ERC721(_name, _symbol) {

        proxyRegistryAddress = _proxyRegistryAddress;

        proxyRegistryAddress2 = _proxyRegistryAddress2;

        mintingFee = _mintingFee;

        discountFee = _discountFee;

        maxSupply = _maxSupply;

        maxMintSize = _maxMintSize;

        maxMintBonusRounds = _maxMintBonusRounds;

        maxMintDiscount = _maxMintDiscount;

        nftsPerTier = _nftsPerTier;

        mintingChaosFee = _mintingChaosFee;

        

        // nextTokenId is initialized to 1, since starting at 0 leads to higher gas cost for the first minter

        _nextTokenId.increment();

        _initializeEIP712(_name);

    }





function chaosUnlock() external onlyOwner chaosGuard {

        chaosLock = false;

    }



    function checkChaosLock() public view returns (bool) {

      return chaosLock;

    }







    function mintTo(address _to, uint256 _count) public onlyOwner callerIsUser {

        require(totalSupply() + _count < maxSupply+1, "Maximum supply reached. Attempted to mint too many NFTs.");

        require(_count > 0 && _count < maxMintSize + 1, "Exceeds maximum tokens you can mint in a single transaction");        

        for(uint256 i = 0; i < _count; i++){

            uint256 currentTokenId = _nextTokenId.current();

            _nextTokenId.increment();

            //_safeMint(_to, currentTokenId);

            _mint(_to, currentTokenId);

        }

    }



    function mint(uint256 _count) external payable callerIsUser {

        require(totalSupply() + _count < maxSupply + 1, "Cannot Mint that many NFTs. Maximum supply reached");

        require(_count > 0 && _count < maxMintSize + 1, "Exceeds maximum tokens you can mint in a single transaction");



        if (allowList[msg.sender] > 0 && allowList[msg.sender] +1 > _count) {            

            require(msg.value >= discountFee * _count && msg.value < mintingFee * _count, "Incorrect payment amount.");

            allowList[msg.sender] -= _count;

            

            for(uint256 i = 0; i < _count; i++){

                uint256 currentTokenId = _nextTokenId.current();

                _nextTokenId.increment();

                _mint(msg.sender, currentTokenId);

            }



        } else {

            //require(msg.value >= mintingFee, "Insufficient funds to mint");

            //engage discount Bonus Rounds as maxMintSize is approached

            //uint discountedCount = _count;

            //uint discountPercent = 0;

            //uint256 discountRounds = 0;

            uint256 finalPrice = _count * (mintingFee * (1 + (totalSupply() / nftsPerTier)));



            if (_count > maxMintSize - maxMintBonusRounds)

            {

                //discountRounds = (_count - (maxMintSize - maxMintBonusRounds));

                //finalPrice = (finalPrice * (100-(discountRounds*maxMintDiscount)/maxMintBonusRounds))/100;

                finalPrice = (finalPrice * (100-((_count - (maxMintSize - maxMintBonusRounds))*maxMintDiscount)/maxMintBonusRounds))/100;

            }

            

            //require(msg.value >= discountedCount * (mintingFee * (1 + (totalSupply() / nftsPerTier))), "Ether value sent is not correct");

            require(msg.value >= finalPrice, "Ether value sent is not correct");

            

            for(uint256 i = 0; i < _count; i++){

                uint256 currentTokenId = _nextTokenId.current();

                _nextTokenId.increment();

                _mint(msg.sender, currentTokenId);

            }

        }

    }







    function mintWithChaos(uint256 _count) public chaosGuard callerIsUser {

        require(mintingWithChaos == true, "Minting with ERC20 token is Not Enabled.");

        require( _count > 0, "mintWithChaos _count must be greater than Zero");

        require(totalSupply()+ _count < maxSupply+1, "Maximum supply reached");

        //require(mintingChaosFee > 0, "Minting with ERC20 token is Not Enabled. mintingChaosFee must be greater than zero.");

        uint256 finalPrice = _count * (mintingChaosFee * (1 + (totalSupply() / nftsPerTier)));

        

        if (_count > maxMintSize - maxMintBonusRounds)

        {

            //discountRounds = (_count - (maxMintSize - maxMintBonusRounds));

            //finalPrice = (finalPrice * (100-(discountRounds*maxMintDiscount)/maxMintBonusRounds))/100;

            finalPrice = (finalPrice * (100-((_count - (maxMintSize - maxMintBonusRounds))*maxMintDiscount)/maxMintBonusRounds))/100;

        }



        tokenAddress.transferFrom(msg.sender, address(this), finalPrice);

   

       for(uint256 i = 0; i < _count; i++){

        

        uint256 currentTokenId = _nextTokenId.current();

        _nextTokenId.increment();

        _safeMint(msg.sender, currentTokenId);

        //_mint(msg.sender, currentTokenId);

       }

    }

    















    function setDiscountFee(uint256 _newFee) external onlyOwner {

        discountFee = _newFee;

    }



    function setMintingFee(uint256 _newFee) external onlyOwner {

        mintingFee = _newFee;

    }





    function checkMintPrice() public view returns (uint256) {

      return mintingFee * (1 + (totalSupply() / nftsPerTier));

    }





    function setChaosCoinAddress(address _newAddress) external onlyOwner {

        tokenAddress = IERC20(_newAddress);

    }



    function setMintingChaosFee(uint256 _newFee) external onlyOwner {

        mintingChaosFee = _newFee;

    }

    function setMintingWithChaos(bool _newState) external onlyOwner {

        mintingWithChaos = _newState;

    }



    function checkMintPriceChaos() public view returns (uint256) {

      return mintingChaosFee * (1 + (totalSupply() / nftsPerTier));

    }



    /**

        @dev Returns the total tokens minted so far.

        1 is always subtracted from the Counter since it tracks the next available tokenId.

     */

    function totalSupply() public view returns (uint256) {

        return _nextTokenId.current() - 1;

    }









    //changed from pure to view

    function baseTokenURI() virtual public view returns (string memory);



    //changed from pure to view

    function tokenURI(uint256 _tokenId) override public view returns (string memory) {

        return string(abi.encodePacked(baseTokenURI(), Strings.toString(_tokenId)));

    }



    function setMarketplace1(address _proxyRegistryAddress) external onlyOwner {

        proxyRegistryAddress = _proxyRegistryAddress;

    }



    function setMarketplace2(address _proxyRegistryAddress2) external onlyOwner {

        proxyRegistryAddress2 = _proxyRegistryAddress2;

    }



    function setMarketplace1Approved(bool isMarketplaceApproved) external onlyOwner {

        _isMarketplace1Approved = isMarketplaceApproved;

    }



    function setMarketplace2Approved(bool isMarketplaceApproved) external onlyOwner {

        _isMarketplace2Approved = isMarketplaceApproved;

    }

	

    function setProxyApprovalState(address proxyAddress, bool newState) public onlyOwner {

	proxyAddressApproval[proxyAddress] = newState;

    }



    /**

     * Override isApprovedForAll to whitelist user's proxy accounts to enable gas-less listings.

     */

    function isApprovedForAll(address owner, address operator)

        override

	    public

        view

        returns (bool)

    {

        // Whitelist 2 proxy contracts for easy trading.

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

        ProxyRegistry proxyRegistry2 = ProxyRegistry(proxyRegistryAddress2);

        if ((_isMarketplace1Approved && (address(proxyRegistry.proxies(owner)) == operator )

		|| (_isMarketplace2Approved && address(proxyRegistry2.proxies(owner)) == operator ))

		|| proxyAddressApproval[operator]) {

            return true;

        }



        return super.isApprovedForAll(owner, operator);

    }

	

	

    /**

     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.

     */

    function _msgSender()

        internal

        override

        view

        returns (address sender)

    {

        return ContextMixin.msgSender();

    }











    function addToAllowList(address _address, uint256 _numDiscountMints) public onlyOwner {

        allowList[_address] = _numDiscountMints;

    }



    function addManyToAllowList(address[] memory _addresses, uint256[] memory _numDiscountMints) external onlyOwner {

        require(_addresses.length == _numDiscountMints.length, "Arrays _addresses and _numDiscountMints must be the same length");



        for (uint256 i = 0; i < _addresses.length; i++) {

            allowList[_addresses[i]] = _numDiscountMints[i];

        }

    }



    function removeFromAllowList(address[] memory _addresses) external onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            delete allowList[_addresses[i]];

        }

    }



    function allowListAmount(address xyz) public view returns (uint256) {

      if (allowList[xyz] > 0) return allowList[xyz]; 

      else return 0;

    }







    function withdrawPayments(address payable payee) public override onlyOwner callerIsUser chaosGuard {

        super.withdrawPayments(payee);

    }



    function withdrawToken() public onlyOwner chaosGuard callerIsUser {

        tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));

    }





/*

    function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {

        return super.supportsInterface(interfaceId);

    }

    

   

    function supportsInterface(bytes4 interfaceId) public view override (ERC165, ERC721) returns (bool) {

        return

            interfaceId == type(IERC165).interfaceId ||

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }

*/



}





// File contracts/ChaosCube.sol







pragma solidity ^0.8.0;



/**

 * @title Chaos Cube

 * Chaos Cube - a contract for non-fungible tokens

 */

contract ChaosCube is ERC721ChaosCoinClub {



    string public _contractURI = "https://nftstorage.link/ipfs/bafybeifugmip2h5do55basyzgieftmsgnju246gfqctdiugvwn5jkc45am/chaoscube";

    string public _baseTokenURI = "ipfs://bafybeia6fyq7sglwc7swdawmm5ikjtyx5s3jqwcynotqqa4wjwenolvhyu/";



    constructor(

    // mainnet

    // 0xa5409ec958C83C3f309868babACA7c86DCB077c1, 0x000000000000Ad05Ccc4F10045630fb830B95127



)

    ERC721ChaosCoinClub("Chaos Cube", "CHAOSCUBE", 0xa5409ec958C83C3f309868babACA7c86DCB077c1, 0x000000000000Ad05Ccc4F10045630fb830B95127, 

25000000000000000, 5000000000000000, 1000, 10, 4, 20, 100, 25 * 10 ** 18){}



    

    function baseTokenURI() public override view returns (string memory) {

        return _baseTokenURI;

    }



    function setBaseTokenURI(string calldata newBaseTokenURI) public onlyOwner {

        _baseTokenURI = newBaseTokenURI;

    }

    



    function setContractURI(string calldata newContractURI) public onlyOwner {

        _contractURI = newContractURI;

    }





    function contractURI() public view returns (string memory) {

        return _contractURI;

    }







}