/**

 *Submitted for verification at Etherscan.io on 2023-03-24

*/



// File: contracts/NowPass.sol





pragma solidity ^0.8.0;

    //Context.sol

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



pragma solidity ^0.8.0;

    //Ownable.sol

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

    address private  _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor() {

        _transferOwnership(_msgSender());

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



pragma solidity ^0.8.0;

    //ReentrancyGuard.sol

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



pragma solidity ^0.8.0;

    //IERC20.sol

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



pragma solidity ^0.8.1;

    //Address.sol

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

        require(isContract(target), "Address: call to non-contract");



        (bool success, bytes memory returndata) = target.call{value: value}(data);

        return verifyCallResult(success, returndata, errorMessage);

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



pragma solidity ^0.8.0;

    //SafeERC20.sol

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



    function safeTransfer(

        IERC20 token,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(

        IERC20 token,

        address from,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    /**

     * @dev Deprecated. This function has issues similar to the ones found in

     * {IERC20-approve}, and its usage is discouraged.

     *

     * Whenever possible, use {safeIncreaseAllowance} and

     * {safeDecreaseAllowance} instead.

     */

    function safeApprove(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require(

            (value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        unchecked {

            uint256 oldAllowance = token.allowance(address(this), spender);

            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");

            uint256 newAllowance = oldAllowance - value;

            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

        }

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that

        // the target address contains contract code and also asserts for success in the low-level call.



        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {

            // Return data is optional

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}



pragma solidity ^0.8.0;

    //IERC165.sol

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



pragma solidity ^0.8.0;

    //IERC721.sol

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

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes calldata data

    ) external;

}



pragma solidity ^0.8.0;

    //IERC721Receiver.sol

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

    function onERC721Received(

        address operator,

        address from,

        uint256 tokenId,

        bytes calldata data

    ) external returns (bytes4);

}



pragma solidity ^0.8.0;

    //IERC721Metadata.sol

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



pragma solidity ^0.8.0;

    //IERC721Enumerable.sol

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



pragma solidity ^0.8.0;

    //Strings.sol

/**

 * @dev String operations.

 */

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

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

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



pragma solidity ^0.8.0;

    //Counters.sol

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

pragma solidity ^0.8.0;

    //ERC165.sol

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



pragma solidity ^0.8.0;

    //ECDSA.sol

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



pragma solidity ^0.8.4;







    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error ApproveToCaller();

    error ApprovalToCurrentOwner();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

    //ERC721A.sol

/**

 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including

 * the Metadata extension. Built to optimize for lower gas during batch mints.

 *

 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).

 *

 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.

 *

 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).

 */

    contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;

    using Strings for uint256;



    // Compiler will pack this into a single 256bit word.

    struct TokenOwnership {

        // The address of the owner.

        address addr;

        // Keeps track of the start time of ownership with minimal overhead for tokenomics.

        uint64 startTimestamp;

        // Whether the token has been burned.

        bool burned;

    }



    // Compiler will pack this into a single 256bit word.

    struct AddressData {

        

        // Realistically, 2**64-1 is more than enough.

        uint64 balance;

        // Keeps track of mint count with minimal overhead for tokenomics.

        uint64 numberMinted;

        // Keeps track of burn count with minimal overhead for tokenomics.

        uint64 numberBurned;

        // For miscellaneous variable(s) pertaining to the address

        // (e.g. number of whitelist mint slots used).

        // If there are multiple variables, please pack them into a uint64.

        uint64 aux;

    }



    



    // The tokenId of the next token to be minted.

    uint256 internal _currentIndex;



    // The number of tokens burned.

    uint256 internal _burnCounter;



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Mapping from token ID to ownership details

    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.

    mapping(uint256 => TokenOwnership) internal _ownerships;



    // Mapping owner address to address data

    mapping(address => AddressData) private _addressData;



    // Mapping from token ID to approved address

    mapping(uint256 => address) private _tokenApprovals;



    // Mapping from owner to operator approvals

    mapping(address => mapping(address => bool)) private _operatorApprovals;



  

 

    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

        _currentIndex = _startTokenId();

        

    }

    

    /**

     * To change the starting tokenId, please override this function.

     */

    function _startTokenId() internal view virtual returns (uint256) {

        return 1;

    }



    /**

     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.

     */

    function totalSupply() public view returns (uint256) {

        // Counter underflow is impossible as _burnCounter cannot be incremented

        // more than _currentIndex - _startTokenId() times

        unchecked {

            return _currentIndex - _burnCounter - _startTokenId();

        }

    }



    /**

     * Returns the total amount of tokens minted in the contract.

     */

    function _totalMinted() internal view returns (uint256) {

        // Counter underflow is impossible as _currentIndex does not decrement,

        // and it is initialized to _startTokenId()

        unchecked {

            return _currentIndex - _startTokenId();

        }

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

    function balanceOf(address owner) public view override returns (uint256) {

        

        return uint256(_addressData[owner].balance);

    }



    /**

     * Returns the number of tokens minted by `owner`.

     */

    function _numberMinted(address owner) public view returns (uint256) {

        return uint256(_addressData[owner].numberMinted);

    }



    /**

     * Returns the number of tokens burned by or on behalf of `owner`.

     */

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);

    }



    /**

     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).

     */

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;

    }



    /**

     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).

     * If there are multiple variables, please pack them into a uint64.

     */

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;

    }



    /**

     * Gas spent here starts off proportional to the maximum mint batch size.

     * It gradually moves to O(1) as tokens get transferred around in the collection over time.

     */

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;



        unchecked {

            if (_startTokenId() <= curr && curr < _currentIndex) {

                TokenOwnership memory ownership = _ownerships[curr];

                if (!ownership.burned) {

                    if (ownership.addr != address(0)) {

                        return ownership;

                    }

                    // Invariant:

                    // There will always be an ownership that has an address and is not burned

                    // before an ownership that does not have an address and is not burned.

                    // Hence, curr will not underflow.

                    while (true) {

                        curr--;

                        ownership = _ownerships[curr];

                        if (ownership.addr != address(0)) {

                            return ownership;

                        }

                    }

                }

            }

        }

        revert OwnerQueryForNonexistentToken();

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _ownershipOf(tokenId).addr;

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

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();



        string memory baseURI = _baseURI();

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';

    }



    /**

     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each

     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty

     * by default, can be overriden in child contracts.

     */

    function _baseURI() internal view virtual returns (string memory) {

        return '';

    }



    /**

     * @dev See {IERC721-approve}.

     */

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);

        if (to == owner) revert ApprovalToCurrentOwner();



        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {

            revert ApprovalCallerNotOwnerNorApproved();

        }



        _approve(to, tokenId, owner);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSender()) revert ApproveToCaller();



        _operatorApprovals[_msgSender()][operator] = approved;

        emit ApprovalForAll(_msgSender(), operator, approved);

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

        safeTransferFrom(from, to, tokenId, '');



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

        _transfer(from, to, tokenId);

        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {

            revert TransferToNonERC721ReceiverImplementer();

        }

    }



    /**

     * @dev Returns whether `tokenId` exists.

     *

     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

     *

     * Tokens start existing when they are minted (`_mint`),

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;

    }



    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');

    }



    /**

     * @dev Safely mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _safeMint(

        address to,

        uint256 quantity,

        bytes memory _data

    ) internal {

        _mint(to, quantity, _data, true);

    }



    /**

     * @dev Mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _mint(

        address to,

        uint256 quantity,

        bytes memory _data,

        bool safe

    ) internal {

        

        uint256 startTokenId = _currentIndex;

        

        if (quantity == 0) revert MintZeroQuantity();

          

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

       

        

        // Overflows are incredibly unrealistic.

        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1

        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1

        unchecked {

            _addressData[to].balance += uint64(quantity);

            _addressData[to].numberMinted += uint64(quantity);



            _ownerships[startTokenId].addr = to;

            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);



            uint256 updatedIndex = startTokenId;

            uint256 end = updatedIndex + quantity;



            if (safe && to.isContract()) {

                do {

                    emit Transfer(address(0), to, updatedIndex);

                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {

                        revert TransferToNonERC721ReceiverImplementer();

                    }

                } while (updatedIndex != end);

                // Reentrancy protection

                if (_currentIndex != startTokenId) revert();

            } else {

                do {

                    emit Transfer(address(0), to, updatedIndex++);

                } while (updatedIndex != end);

            }

            _currentIndex = updatedIndex;

        }

        _afterTokenTransfers(address(0), to, startTokenId, quantity);

    }



    /**

     * @dev Transfers `tokenId` from `from` to `to`.

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

    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);



        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();



        bool isApprovedOrOwner = (_msgSender() == from ||

            isApprovedForAll(from, _msgSender()) ||

            getApproved(tokenId) == _msgSender());



        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        if (to == address(0)) revert TransferToZeroAddress();



        _beforeTokenTransfers(from, to, tokenId, 1);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId, from);



        // Underflow of the sender's balance is impossible because we check for

        // ownership above and the recipient's balance can't realistically overflow.

        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.

        unchecked {

            _addressData[from].balance -= 1;

            _addressData[to].balance += 1;



            TokenOwnership storage currSlot = _ownerships[tokenId];

            currSlot.addr = to;

            currSlot.startTimestamp = uint64(block.timestamp);



            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.

            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.

            uint256 nextTokenId = tokenId + 1;

            TokenOwnership storage nextSlot = _ownerships[nextTokenId];

            if (nextSlot.addr == address(0)) {

                // This will suffice for checking _exists(nextTokenId),

                // as a burned slot cannot contain the zero address.

                if (nextTokenId != _currentIndex) {

                    nextSlot.addr = from;

                    nextSlot.startTimestamp = prevOwnership.startTimestamp;

                }

            }

        }

         emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId, 1);

    }



    /**

     * @dev This is equivalent to _burn(tokenId, false)

     */

    function _burn(uint256 tokenId) internal virtual {

        _burn(tokenId, false);

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

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);



        address from = prevOwnership.addr;



        if (approvalCheck) {

            bool isApprovedOrOwner = (_msgSender() == from ||

                isApprovedForAll(from, _msgSender()) ||

                getApproved(tokenId) == _msgSender());



            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        }



        _beforeTokenTransfers(from, address(0), tokenId, 1);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId, from);



        // Underflow of the sender's balance is impossible because we check for

        // ownership above and the recipient's balance can't realistically overflow.

        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.

        unchecked {

            AddressData storage addressData = _addressData[from];

            addressData.balance -= 1;

            addressData.numberBurned += 1;



            // Keep track of who burned the token, and the timestamp of burning.

            TokenOwnership storage currSlot = _ownerships[tokenId];

            currSlot.addr = from;

            currSlot.startTimestamp = uint64(block.timestamp);

            currSlot.burned = true;



            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.

            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.

            uint256 nextTokenId = tokenId + 1;

            TokenOwnership storage nextSlot = _ownerships[nextTokenId];

            if (nextSlot.addr == address(0)) {

                // This will suffice for checking _exists(nextTokenId),

                // as a burned slot cannot contain the zero address.

                if (nextTokenId != _currentIndex) {

                    nextSlot.addr = from;

                    nextSlot.startTimestamp = prevOwnership.startTimestamp;

                }

            }

        }



        emit Transfer(from, address(0), tokenId);

        _afterTokenTransfers(from, address(0), tokenId, 1);



        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.

        unchecked {

            _burnCounter++;

        }

    }



    /**

     * @dev Approve `to` to operate on `tokenId`

     *

     * Emits a {Approval} event.

     */

    function _approve(

        address to,

        uint256 tokenId,

        address owner

    ) private {

        _tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.

     *

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkContractOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) private returns (bool) {

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {

            return retval == IERC721Receiver(to).onERC721Received.selector;

        } catch (bytes memory reason) {

            if (reason.length == 0) {

                revert TransferToNonERC721ReceiverImplementer();

            } else {

                assembly {

                    revert(add(32, reason), mload(reason))

                }

            }

        }

    }



    /**

     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.

     * And also called before burning one token.

     *

     * startTokenId - the first token id to be transferred

     * quantity - the amount to be transferred

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be

     * transferred to `to`.

     * - When `from` is zero, `tokenId` will be minted for `to`.

     * - When `to` is zero, `tokenId` will be burned by `from`.

     * - `from` and `to` are never both zero.

     */

    function _beforeTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual {

       

       //require(from == address(0) || to == address(0), "Not allowed to transfer token");

            

    }



    /**

     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes

     * minting.

     * And also called after one token has been burned.

     *

     * startTokenId - the first token id to be transferred

     * quantity - the amount to be transferred

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been

     * transferred to `to`.

     * - When `from` is zero, `tokenId` has been minted for `to`.

     * - When `to` is zero, `tokenId` has been burned by `from`.

     * - `from` and `to` are never both zero.

     */

    function _afterTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual {}

}



pragma solidity ^0.8.0;

    //StorageSlot.sol

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



pragma solidity ^0.8.8;





    type ShortString is bytes32;

    //ShortStrings.sol

/**

 * @dev This library provides functions to convert short memory strings

 * into a `ShortString` type that can be used as an immutable variable.

 * Strings of arbitrary length can be optimized if they are short enough by

 * the addition of a storage variable used as fallback.

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

    error StringTooLong(string str);



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

        uint256 len = length(sstr);

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

    function length(ShortString sstr) internal pure returns (uint256) {

        return uint256(ShortString.unwrap(sstr)) & 0xFF;

    }



    /**

     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.

     */

    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {

        if (bytes(value).length < 32) {

            return toShortString(value);

        } else {

            StorageSlot.getStringSlot(store).value = value;

            return ShortString.wrap(0);

        }

    }



    /**

     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.

     */

    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {

        if (length(value) > 0) {

            return toString(value);

        } else {

            return store;

        }

    }

}



pragma solidity ^0.8.0;

    //IERC5267.sol

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



pragma solidity ^0.8.8;

    //EIP712.sol

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



    ShortString private immutable _name;

    ShortString private immutable _version;

    string private _nameFallback;

    string private _versionFallback;



    bytes32 private immutable _hashedName;

    bytes32 private immutable _hashedVersion;



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





pragma solidity ^0.8.4;

/*

MMMMMMMWKKWMMMMMMMMMMMMMMMMMMWOkNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMM0ll0WMMMMMMMMMMMMMMW0l:OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMWO,.cONMMMMMMMMMMW0c.,OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMM0; .;kNMMMMMMWOc. ,0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMK:   ,dXMMWO:.  ;0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMXc    'ox:.   :KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMMXl          cXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMMMNo.      .lXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMMMMWk;.  .;kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMMMMMMN0kk0NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

MMMMMMMMMMMMMMMMMMMMMMWX0kxxxkO0XWMMMMMMMMMMMMMMMMMMWNKOOkdddxk0XNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWWWWWWWWWWWWWWWMMWWWWWWWWWWWWWM

NOxoc::::::::::::oXW0o:..      ..;o0WMMMMMMMMMMMWXkl;':xOOx;   ..',lxKWWKkxdc:;;;;;;;;;;;;cxXWKxo:;;;;;;;;;;;;;ox0NKkxdc;;;;;:oxkK

WNXKl.           .oddxOkc.         .cKWMMMMMMMNOc.   ,0MMMMNl        .:kXNNXx.            ,0WMWNKc             oNWMWWWXo.   'xXWWW

MMMMK,            ;OWMMMNc           ,0MMMMMWO;.     oWMMMMMK,          ;kNMWx.           .kMMMMM0'            ;XMMMMMMX:  :KMMMMM

MMMMK,            dWMMMMWd            lNMMMXl.       dWMMMMMWd.          .cKMXc            :XMMMMWo            .dWMMMMMWl ;KMMMMMM

MMMMK,           .xMMMMMWd            ;KMM0;         lWMMMMMM0'            ,0WO.           .xMMMMMK,            ;KMMMMMNc,OMMMMMMM

MMMMK;           .xMMMMMWd            ,KMK;          :XMMMMMMX:             ;KNl            ;XMMMMX:            .dWMMMM0cxWMMMMMMM

MMMMK;           .xMMMMMWd            ,KWo           ,KMMMMMMWl              lN0'           .dWMMWk:'            ,KMMMWdoXMMMMMMMM

MMMMK;           .xMMMMMWd            ,K0'           .kMMMMMMMx.             '0Wd.           ,KMMXoxk.            oWMMOlOMMMMMMMMM

MMMMK;           .xMMMMMWd            ,Kk.           .dWMMMMMMO'             .kMK;           .dWWxoXNl            ,0MNodNMMMMMMMMM

MMMMK;           .xMMMMMWd            ,Kx.            cNMMMMMMX;             .kMWx.           ,0KokWM0'            oNkl0MMMMMMMMMM

MMMMK;           .xMMMMMWd            ,KO.            ;KMMMMMMNl             '0MMX:            lddNMMWo            'xlxWMMMMMMMMMM

MMMMK;           .xMMMMMWd            ,KX:            .OMMMMMMWd.            lNMMMO.           .;OMMMMK;            .lXMMMMMMMMMMM

MMMMK;           .xMMMMMWd            ,KWO.            dWMMMMMMk.           :KMMMMNl            lNMMMMWx.           .kMMMMMMMMMMMM

MMMMK;           .xMMMMMWd            ,KMWk'           :XMMMMMM0'          cKMMMMMM0'          'OMMMMMMX:           lNMMMMMMMMMMMM

MMMMK;           .xMMMMMWd            ,KMMMK:.         .OMMMMMMK,        .dNMMMMMMMWo.         oWMMMMMMMO.         '0MMMMMMMMMMMMM

MMMMK,           .xMMMMMWd            ,KMMMMNk;.        cNMMMMMK,      .lKWMMMMMMMMMK;        ,0MMMMMMMMNl        .dWMMMMMMMMMMMMM

MWWNx.           .dWMMMMXc            .kWMMMMMNOl'      .xWMMMMk.    'l0WMMMMMMMMMMMWx.      .oWMMMMMMMMM0'       ;XMMMMMMMMMMMMMM

Kxxo;'''''''''''''cxONXko;'''''''''''',cxkONMMMMMNOo:'.  .lOK0x;.';lkNMMMMMMMMMMMMMMMXc......:KMMMMMMMMMMWd......'kMMMMMMMMMMMMMMM

WNNNNNNNNNNNNNNNNNNNNWWWNNNNNWNNNNNNNNNNNNWMMMMMMMMMWNKOxddxkOk0XNWMMMMMMMMMMMMMMMMMMMNKKKKKKXWMMMMMMMMMMMWKKKKKKXWMMMMMMMMMMMMMMM

MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

0oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooood0

                                                                                                                                 

                    .'''''...                    .'''.                      .',,'.                   ..,,,'.                     

                   .xNNNNNNNKOl.                'ONNNK:                  .:kXNXXNXOl.              'd0NNXXXKx,                   

                   .kMMKo::dXMWd.              .kWWNWM0,                 :XMWx;':xOk:             .kMMKc',oOOo.                  

                   .kMM0;..cKMMx.             .oNMO:xWWk.                ;KMWXkdooc,.             .xWMNOxdoo:.                   

                   .kMMWXXXNWNk,              cXMWx;oXMWd.                'lxO0XNWWXl.             .:dk0KXWMNk'                  

                   .kMMKocc:;'               ;KMMWNNNWMMNl               ;odl,..cKMMO.            .loo:..,xWMNc                  

                   .kMMO.                   'OMWk;,,,;xWMK;              ,kNWXOOKWW0:             .lKWN0OOXWXd.                  

                    ,cl;                    .cl:.     .:lc,                ':loolc,.                .;clool:.                    

                                                                                                                                                                                                                                                               



*/



    contract NowPass is ERC721A, EIP712, Ownable {

    using Counters for Counters.Counter;

    using Strings for uint;



    Counters.Counter private bindCounter;

    

    string private constant SIGNING_DOMAIN = "NOWPASS";

    string private constant SIGNATURE_VERSION = "1";



    uint256 public publicCost = 0.25 ether;

    uint public maxSupply = 2750;

    uint256 public bindRate;

    uint public maxBound = 0;



    mapping(uint256 => bool) public binds;

    mapping(bytes => bool) public sigs;

  

    string public boundURI;

    string public NR = "ipfs://HIDDEN_METADATA/";

    bool public presaleOnly = true;

    bool public revealed = false;

    bool public paused = true;

    uint public phase = 0;

    address public validator;



    event DevMinted(address indexed to, uint256 quantity, uint256 indexed tokenId);

    event PresaleMinted(address indexed to, uint256 quantity, uint256 indexed tokenId);

    event PublicMinted(address indexed to, uint256 quantity, uint256 indexed tokenId);

    event Revoke(address indexed to, uint256 indexed tokenId);

    event Bind(address indexed from, uint256 indexed tokenId);



    constructor() ERC721A("NOWPASSV2", "NOW") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)

    {

        validator = owner();

    }

    

//****Minting Functions*****



    //@dev Presale ECDSA verified that signature and typed message resolves to Owner or a set Validator's wallet

    

        function presaleMint(uint qty, uint nonce, address addr, bytes memory signature) external payable 

        {

            uint tm = totalSupply();

            uint _cost = publicCost;



            require(paused==false, "Paused");

            require(check(qty, nonce, addr, signature) == validator, "Not verified");

            require(addr == msg.sender, "Destination address and sender dont match");

            require(sigs[signature] == false, "This signature has already been used");

            require(_numberMinted(msg.sender) + qty < 3, "Exceeds limit"); 

            require(tm + qty < 2751, "SOLD OUT!");

            require(msg.value + 1 > qty * _cost, "Not Enough ETH sent");

                               

        sigs[signature] = true;                                          

        _mint(addr, qty,"", false);



        emit PresaleMinted(addr, qty, tm + qty);

        }



    //@dev used for ECDSA signature verification



        function check(uint256 qty, uint256 nonce, address addr, bytes memory signature) public view returns (address) 

        {

            return _verify(qty, nonce, addr, signature);

        }



        function _verify(uint256 qty, uint256 nonce, address addr, bytes memory signature) internal view returns (address) 

        {

            bytes32 digest = _hash(qty, nonce, addr);

            return ECDSA.recover(digest, signature);

        }



        function _hash(uint256 qty, uint256 nonce, address addr) internal view returns (bytes32) 

        {

            return _hashTypedDataV4(keccak256(abi.encode(

                keccak256("Web3Struct(uint256 qty,uint256 nonce,address addr)"),

                qty,

                nonce,

                addr

        )));

        }



    //@dev Public mint with no ECDSA verfication



        function publicMint(uint qty) external payable 

        {

            uint tm = totalSupply();

            uint _cost = publicCost;



            require(_numberMinted(msg.sender) + qty < 4, "Exceeds limit"); 

            require(paused==false,"Paused");

            require(presaleOnly==false,"Presale Only");       

            require(msg.sender == tx.origin, "no bots");       

            require(tm + qty < 2751, "SOLD OUT!");

            require(msg.value + 1 > qty * _cost, "Not Enough ETH sent");



        _mint(msg.sender, qty,"", false);



        emit PublicMinted(msg.sender, qty, tm + qty);        

     

        }



    //@dev Developer Mints to Owner wallet    

    

        function devMint(uint qty) public onlyOwner 

        {

            uint tm = totalSupply();

            require(tm + qty < 2751, "SOLD OUT!");  

            

        _mint(msg.sender, qty,"", false);

            

        emit DevMinted(msg.sender, qty, tm + qty);



        }



    //@dev Bulk Mint to users wallets *CAUTION* NO CHECKS



        function bulkDrop(address[] memory users) external onlyOwner 

        {



            for (uint256 i; i < users.length; i++) 

            {

            uint tm = totalSupply();

            require(tm + 1 < 2751, "SOLD OUT!"); 



        _mint(users[i], 1, '', true);



        emit DevMinted(users[i], 1, tm + 1);             

            }

        }





//****Binding Functions*****



    // Function to BIND the token to the users wallet permanently. Philosophical opposite of BURN. BINDING allows for off-chain incentives through the lens of customer loyalty.

        function bind(uint256 tokenId, bool bindVal) public payable 

        {

            require(maxBound > 0, "Binding not available yet");

            require(ownerOf(tokenId) == msg.sender, "Only owner of the token can bind it");

            require(bindVal == true, "Bind value must be true");

            require(bindCounter.current() < maxBound, "No more tokens can currently be bound");

            require(msg.value >= bindRate, "Not enough ether sent to bind");

            

        bindCounter.increment();

        binds[tokenId] = bindVal;

        emit Bind(msg.sender,tokenId);

        }



    // Function to BURN the token.

        function burn(uint256 tokenId) external 

        {

            require(ownerOf(tokenId) == msg.sender, "Only owner of the token can burn it");



            if (binds[tokenId] == true) 

            {

                binds[tokenId] = false;

                bindCounter.decrement();

            }



            _burn(tokenId);

        }





    // Function to ensure is a token is not BOUND before transfer

        function _beforeTokenTransfers(address from, address to, uint256 tokenId, uint quantity) internal virtual override(ERC721A)

        {

            if (binds[tokenId] == true) 

            {

                require(from == address(0) || to == address(0), "Not allowed to transfer token");            

            }

        }



        function _burn(uint256 tokenId) internal override(ERC721A) 

        {

            super._burn(tokenId);

        }

   

    // Function to return the total number of BOUND tokens

        function totalBound() public view returns (uint256) 

        {

            return bindCounter.current();

        } 



//****Metadata Functions****



        string private _baseTokenURI;



        function _baseURI() internal view virtual override returns (string memory) 

        {

            return _baseTokenURI;

        }



        function exists(uint256 tokenId) public view returns (bool) 

        {

            return _exists(tokenId);

        }



    // Function to set the tokenURI based on whether the collection has been revealed and if it is bound

        function tokenURI(uint tokenId) public view virtual override(ERC721A) returns (string memory) 

        {

            if (revealed == false) 

            {

                return NR;

            }



            else if (binds[tokenId] == true){

    

                    return bytes(boundURI).length > 0

            ? string(abi.encodePacked(boundURI, tokenId.toString(), ".json"))

            : "";

            }



            string memory currentBaseURI = _baseURI();

            return bytes(currentBaseURI).length > 0

            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json"))

            : "";

        }

        

//****Owner Only Functions****







    //@dev Function to set the URI for bound tokens in the collection

        function setBoundURI(string memory _boundURI) public onlyOwner 

        {

            boundURI = _boundURI;

        } 



    //@dev Function to set the price for Binding

        function setBindRate(uint256 _rate) public onlyOwner 

        {

            bindRate = _rate;

        }         



    //@dev Set the phase of the mint

        function setPhase(uint _phase) public onlyOwner 

        {

            phase = _phase;

        }   



    //@dev Set an approved validator for the Minting website

        function setValidator(address _validator) public onlyOwner 

        {

            require(_validator != address(0), "Validator cannot be address 0");

            validator = _validator;

        }

    

    //@dev Set the state of presale period

        function setPresaleOnly(bool _state) external onlyOwner 

        {

            if (presaleOnly == false) 

            {

                require(_state == false, "Cannot go back to presale");

            }

            

            presaleOnly = _state;//set to false for main mint

        }



    //@dev Pause the mint

        function pause(bool _state) public onlyOwner() 

        {

            paused = _state;

        }

    

    //@dev withdraws all remaining funds from the smart contract

        function withdraw() public payable onlyOwner 

        {

            (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");

            require(success);

        }



        function revoke(uint256 tokenId) external onlyOwner 

        {

            require(ownerOf(tokenId) == msg.sender, "Only owner of the token can burn it");



            if (binds[tokenId] == true) 

            {

                binds[tokenId] = false;

                bindCounter.decrement();

            }



            _burn(tokenId);

        }



    //@dev Sets the base URI of the collection

        function setBaseURI(string memory baseURI) external onlyOwner 

        {

            _baseTokenURI = baseURI;

        }



    //@dev Sets the state of whether the collection metadata is revealed

        function setRevealed(bool _state) public onlyOwner 

        {

            require(revealed == false, "Cannot be unrevealed");

            revealed = _state;

        }



    //@dev Sets the Not Revealed URI for the collection

        function setNR(string memory _nr) public onlyOwner() 

        {

            NR = _nr;

        }



    //@dev Sets the total number of tokens that can be currently BOUND

        function setMaxBound(uint256 _maxBound) public onlyOwner 

        {

            require(_maxBound > maxBound, "Maximum soulbounds must be greater than previously.");

            maxBound = _maxBound;

        }



    // Returns the owned tokens of a specific address

        function tokensOfOwner(address owner) external view returns (uint256[] memory) {

            unchecked {

                uint256 tokenIdsIdx;

                address currOwnershipAddr;

                uint256 tokenIdsLength = balanceOf(owner);

                uint256[] memory tokenIds = new uint256[](tokenIdsLength);

                TokenOwnership memory ownership;

                for (uint256 i = _startTokenId(); tokenIdsIdx != tokenIdsLength; ++i) {

                    ownership = _ownershipOf(i);

                    if (ownership.burned) {

                        continue;

                    }

                    if (ownership.addr != address(0)) {

                        currOwnershipAddr = ownership.addr;

                    }

                    if (currOwnershipAddr == owner) {

                        tokenIds[tokenIdsIdx++] = i;

                    }

                }

                return tokenIds;

            }

        }        

}