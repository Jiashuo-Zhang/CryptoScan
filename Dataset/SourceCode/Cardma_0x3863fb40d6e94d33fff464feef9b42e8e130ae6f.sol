/**

 *Submitted for verification at Etherscan.io on 2019-12-18

*/



// File: @openzeppelin/contracts/GSN/Context.sol



pragma solidity ^0.5.0;



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

contract Context {

    // Empty internal constructor, to prevent people from mistakenly deploying

    // an instance of this contract, which should be used via inheritance.

    constructor () internal { }

    // solhint-disable-previous-line no-empty-blocks



    function _msgSender() internal view returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



// File: contracts/Ownable.sol



pragma solidity >0.5.0;





/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be applied to your functions to restrict their use to

 * the owner.

 */

contract Ownable is Context {

    // Initialzation flag

    bool private _initialized;

    

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        address msgSender = _msgSender();

        _owner = msgSender;

        _initialized = true;

        emit OwnershipTransferred(address(0), msgSender);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Returns true if the caller is the current owner.

     */

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;

    }

    

    /**

     * @dev Sets up initial owner for the ownable contract.

     * Can only be called once.

     */

    function setupOwnership() public {

        require(!_initialized, "Ownable: already initialized");

        

        address msgSender = _msgSender();

        emit OwnershipTransferred(address(0), msgSender);

        _owner = msgSender;

        _initialized = true;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



// File: @openzeppelin/contracts/introspection/IERC165.sol



pragma solidity ^0.5.0;



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



// File: @openzeppelin/contracts/token/ERC721/IERC721.sol



pragma solidity ^0.5.0;





/**

 * @dev Required interface of an ERC721 compliant contract.

 */

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    /**

     * @dev Returns the number of NFTs in `owner`'s account.

     */

    function balanceOf(address owner) public view returns (uint256 balance);



    /**

     * @dev Returns the owner of the NFT specified by `tokenId`.

     */

    function ownerOf(uint256 tokenId) public view returns (address owner);



    /**

     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to

     * another (`to`).

     *

     *

     *

     * Requirements:

     * - `from`, `to` cannot be zero.

     * - `tokenId` must be owned by `from`.

     * - If the caller is not `from`, it must be have been allowed to move this

     * NFT by either {approve} or {setApprovalForAll}.

     */

    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    /**

     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to

     * another (`to`).

     *

     * Requirements:

     * - If the caller is not `from`, it must be approved to move this NFT by

     * either {approve} or {setApprovalForAll}.

     */

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);



    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);





    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}



// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol



pragma solidity ^0.5.0;



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

contract IERC721Receiver {

    /**

     * @notice Handle the receipt of an NFT

     * @dev The ERC721 smart contract calls this function on the recipient

     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,

     * otherwise the caller will revert the transaction. The selector to be

     * returned can be obtained as `this.onERC721Received.selector`. This

     * function MAY throw to revert and reject the transfer.

     * Note: the ERC721 contract address is always the message sender.

     * @param operator The address which called `safeTransferFrom` function

     * @param from The address which previously owned the token

     * @param tokenId The NFT identifier which is being transferred

     * @param data Additional data with no specified format

     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

     */

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)

    public returns (bytes4);

}



// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity ^0.5.0;



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

     * - Subtraction cannot overflow.

     *

     * _Available since v2.4.0._

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

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

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

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.5.5;



/**

 * @dev Collection of functions related to the address type

 */

library Address {

    /**

     * @dev Returns true if `account` is a contract.

     *

     * This test is non-exhaustive, and there may be false-negatives: during the

     * execution of a contract's constructor, its address will be reported as

     * not containing a contract.

     *

     * IMPORTANT: It is unsafe to assume that an address for which this

     * function returns false is an externally-owned account (EOA) and not a

     * contract.

     */

    function isContract(address account) internal view returns (bool) {

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts

        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned

        // for accounts without code, i.e. `keccak256('')`

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly

        assembly { codehash := extcodehash(account) }

        return (codehash != 0x0 && codehash != accountHash);

    }



    /**

     * @dev Converts an `address` into `address payable`. Note that this is

     * simply a type cast: the actual underlying value is not changed.

     *

     * _Available since v2.4.0._

     */

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));

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

     *

     * _Available since v2.4.0._

     */

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        // solhint-disable-next-line avoid-call-value

        (bool success, ) = recipient.call.value(amount)("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }

}



// File: @openzeppelin/contracts/drafts/Counters.sol



pragma solidity ^0.5.0;





/**

 * @title Counters

 * @author Matt Condon (@shrugs)

 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number

 * of elements in a mapping, issuing ERC721 ids, or counting request ids.

 *

 * Include with `using Counters for Counters.Counter;`

 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}

 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never

 * directly accessed.

 */

library Counters {

    using SafeMath for uint256;



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

        counter._value += 1;

    }



    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);

    }

}



// File: @openzeppelin/contracts/introspection/ERC165.sol



pragma solidity ^0.5.0;





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

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

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

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");

        _supportedInterfaces[interfaceId] = true;

    }

}



// File: @openzeppelin/contracts/token/ERC721/ERC721.sol



pragma solidity ^0.5.0;

















/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://eips.ethereum.org/EIPS/eip-721

 */

contract ERC721 is Context, ERC165, IERC721 {

    using SafeMath for uint256;

    using Address for address;

    using Counters for Counters.Counter;



    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;



    // Mapping from token ID to owner

    mapping (uint256 => address) private _tokenOwner;



    // Mapping from token ID to approved address

    mapping (uint256 => address) private _tokenApprovals;



    // Mapping from owner to number of owned token

    mapping (address => Counters.Counter) private _ownedTokensCount;



    // Mapping from owner to operator approvals

    mapping (address => mapping (address => bool)) private _operatorApprovals;



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

     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd

     */

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;



    constructor () public {

        // register the supported interfaces to conform to ERC721 via ERC165

        _registerInterface(_INTERFACE_ID_ERC721);

    }



    /**

     * @dev Gets the balance of the specified address.

     * @param owner address to query the balance of

     * @return uint256 representing the amount owned by the passed address

     */

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");



        return _ownedTokensCount[owner].current();

    }



    /**

     * @dev Gets the owner of the specified token ID.

     * @param tokenId uint256 ID of the token to query the owner of

     * @return address currently marked as the owner of the given token ID

     */

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];

        require(owner != address(0), "ERC721: owner query for nonexistent token");



        return owner;

    }



    /**

     * @dev Approves another address to transfer the given token ID

     * The zero address indicates there is no approved address.

     * There can only be one approved address per token at a given time.

     * Can only be called by the token owner or an approved operator.

     * @param to address to be approved for the given token ID

     * @param tokenId uint256 ID of the token to be approved

     */

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);

        require(to != owner, "ERC721: approval to current owner");



        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),

            "ERC721: approve caller is not owner nor approved for all"

        );



        _tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);

    }



    /**

     * @dev Gets the approved address for a token ID, or zero if no address set

     * Reverts if the token ID does not exist.

     * @param tokenId uint256 ID of the token to query the approval of

     * @return address currently approved for the given token ID

     */

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev Sets or unsets the approval of a given operator

     * An operator is allowed to transfer all tokens of the sender on their behalf.

     * @param to operator address to set the approval

     * @param approved representing the status of the approval to be set

     */

    function setApprovalForAll(address to, bool approved) public {

        require(to != _msgSender(), "ERC721: approve to caller");



        _operatorApprovals[_msgSender()][to] = approved;

        emit ApprovalForAll(_msgSender(), to, approved);

    }



    /**

     * @dev Tells whether an operator is approved by a given owner.

     * @param owner owner address which you want to query the approval of

     * @param operator operator address which you want to query the approval of

     * @return bool whether the given operator is approved by the given owner

     */

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev Transfers the ownership of a given token ID to another address.

     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.

     * Requires the msg.sender to be the owner, approved, or operator.

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function transferFrom(address from, address to, uint256 tokenId) public {

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");



        _transferFrom(from, to, tokenId);

    }



    /**

     * @dev Safely transfers the ownership of a given token ID to another address

     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     * Requires the msg.sender to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");

    }



    /**

     * @dev Safely transfers the ownership of a given token ID to another address

     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     * Requires the _msgSender() to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes data to send along with a safe transfer check

     */

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _safeTransferFrom(from, to, tokenId, _data);

    }



    /**

     * @dev Safely transfers the ownership of a given token ID to another address

     * If the target address is a contract, it must implement `onERC721Received`,

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     * Requires the msg.sender to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes data to send along with a safe transfer check

     */

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transferFrom(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");

    }



    /**

     * @dev Returns whether the specified token exists.

     * @param tokenId uint256 ID of the token to query the existence of

     * @return bool whether the token exists

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];

        return owner != address(0);

    }



    /**

     * @dev Returns whether the given spender can transfer a given token ID.

     * @param spender address of the spender to query

     * @param tokenId uint256 ID of the token to be transferred

     * @return bool whether the msg.sender is approved for the given token ID,

     * is an operator of the owner, or is the owner of the token

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");

        address owner = ownerOf(tokenId);

        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

    }



    /**

     * @dev Internal function to safely mint a new token.

     * Reverts if the given token ID already exists.

     * If the target address is a contract, it must implement `onERC721Received`,

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     * @param to The address that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");

    }



    /**

     * @dev Internal function to safely mint a new token.

     * Reverts if the given token ID already exists.

     * If the target address is a contract, it must implement `onERC721Received`,

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     * @param to The address that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     * @param _data bytes data to send along with a safe transfer check

     */

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);

        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");

    }



    /**

     * @dev Internal function to mint a new token.

     * Reverts if the given token ID already exists.

     * @param to The address that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");

        require(!_exists(tokenId), "ERC721: token already minted");



        _tokenOwner[tokenId] = to;

        _ownedTokensCount[to].increment();



        emit Transfer(address(0), to, tokenId);

    }



    /**

     * @dev Internal function to burn a specific token.

     * Reverts if the token does not exist.

     * Deprecated, use {_burn} instead.

     * @param owner owner of the token to burn

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");



        _clearApproval(tokenId);



        _ownedTokensCount[owner].decrement();

        _tokenOwner[tokenId] = address(0);



        emit Transfer(owner, address(0), tokenId);

    }



    /**

     * @dev Internal function to burn a specific token.

     * Reverts if the token does not exist.

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);

    }



    /**

     * @dev Internal function to transfer ownership of a given token ID to another address.

     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");

        require(to != address(0), "ERC721: transfer to the zero address");



        _clearApproval(tokenId);



        _ownedTokensCount[from].decrement();

        _ownedTokensCount[to].increment();



        _tokenOwner[tokenId] = to;



        emit Transfer(from, to, tokenId);

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.

     * The call is not executed if the target address is not a contract.

     *

     * This function is deprecated.

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)

        internal returns (bool)

    {

        if (!to.isContract()) {

            return true;

        }



        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);

        return (retval == _ERC721_RECEIVED);

    }



    /**

     * @dev Private function to clear current approval of a given token ID.

     * @param tokenId uint256 ID of the token to be transferred

     */

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {

            _tokenApprovals[tokenId] = address(0);

        }

    }

}



// File: @openzeppelin/contracts/token/ERC721/IERC721Metadata.sol



pragma solidity ^0.5.0;





/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}



// File: contracts/ERC721WithMessage.sol



pragma solidity >0.5.0;













contract ERC721WithMessage is Context, ERC165, ERC721, IERC721Metadata, Ownable {

    struct Message {

      string content;

      bool encrypted;

    }



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Token URI

    string private _tokenURI;



    // Optional mapping for token messages

    mapping(uint256 => Message) private _tokenMessages;



    /*

     *     bytes4(keccak256('name()')) == 0x06fdde03

     *     bytes4(keccak256('symbol()')) == 0x95d89b41

     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd

     *

     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f

     */

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;



    /**

     * @dev Initializor function

     */

    function initialize(string memory name, string memory symbol, string memory tokenURI) public onlyOwner {

        _name = name;

        _symbol = symbol;

        _tokenURI = tokenURI;



        // register the supported interfaces to conform to ERC721 via ERC165

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);

    }



    /**

     * @dev Gets the token name.

     * @return string representing the token name

     */

    function name() external view returns (string memory) {

        return _name;

    }



    /**

     * @dev Gets the token symbol.

     * @return string representing the token symbol

     */

    function symbol() external view returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the URI for a given token ID. May return an empty string.

     * @return token metadata URI

     */

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        return _tokenURI;

    }

    

    /**

     * @dev Returns the message for a given token ID.

     * @return token message

     */

    function tokenMessage(uint256 tokenId) external view returns (string memory, bool) {

        Message storage message = _tokenMessages[tokenId];

        return (message.content, message.encrypted);

    }

    

    /**

     * @dev Function to mint tokens.

     * @param to The address that will receive the minted tokens.

     * @param tokenId The token id to mint.

     * @param message The private message of the minted token.

     * @return A boolean that indicates if the operation was successful.

     */

    function mintWithMessage(address to, uint256 tokenId, string memory message, bool encrypted) public onlyOwner returns (bool) {

        _mint(to, tokenId);

        _tokenMessages[tokenId] = Message(message, encrypted);

        return true;

    }

}



// File: contracts/Cardma.sol



pragma solidity >0.5.0;

pragma experimental ABIEncoderV2;







contract Cardma is Ownable {

    /*

     * ----- Type Definitions -----

     */

    struct Card {

        address cardAddress;

        string name;

        string author;

        string description;

        string imageURI;

        uint256 price;   // Price for the card

        uint256 count;   // Current issued card count

        uint256 limit;   // Maximum number of cards to issue, limit = 0 means unlimited.

    }

    

    struct SentCard {

        address senderAddress;

        address keyAddress;

        uint256 cardIndex;

        uint256 tokenId;

        uint256 giftAmount;

        uint256 timestamp;

        bool claimed;

    }



    struct ReadableCard {

        address keyAddress;

        string imageURI;

        string message;

        bool encrypted;

        uint256 giftAmount;

        uint256 timestamp;

        bool claimed;

    }



    /*

     * ----- Contract Variables -----

     */

    Card[] private _cards;

    mapping(address => SentCard) private _sentCards;

    mapping(address => address[]) private _sentCardsFromUser;

    mapping(address => address[]) private _receivedCardsForUser;



    address private _cardFactoryAddress;

    uint256 private _revenue;

    

    /*

     * ----- Internal Methods -----

     */

    function createCardContract()

        internal

        returns (address result)

    {

        bytes20 factoryAddress = bytes20(_cardFactoryAddress);



        // solhint-disable-next-line security/no-inline-assembly

        assembly {

            let clone := mload(0x40)

            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

            mstore(add(clone, 0x14), factoryAddress)

            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            result := create(0, clone, 0x37)

        }

    }

    

    function uint2str(uint256 _i)

        internal

        pure

        returns (string memory)

    {

        if (_i == 0) {

            return "0";

        }

        uint j = _i;

        uint len;

        while (j != 0) {

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (_i != 0) {

            bstr[k--] = byte(uint8(48 + _i % 10));

            _i /= 10;

        }

        return string(bstr);

    }



    // check signature before claiming card

    modifier checkSignature(

        address keyAddress,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) {

        require(

            _sentCards[keyAddress].senderAddress == _msgSender() ||

                keyAddress == ecrecover(getPersonalChallenge(), v, r, s),

            "Cardma: invalid signature"

        );

        _;

    }



    // check that index falls withing todo list range

    modifier checkIndex(uint256 cardIndex) {

        require(cardIndex < _cards.length, "Cardma: card index out of range");

        _;

    }

    

    /*

     * ----- Owner Methods -----

     */

    function setupCardFactory(address cardFactoryAddress)

        public

        onlyOwner

    {

        _cardFactoryAddress = cardFactoryAddress;

    }

     

    function addCard(

        string memory name,

        string memory author,

        string memory description,

        string memory imageURI,

        string memory tokenURI,

        uint256 price,

        uint256 limit

    )

        public

        onlyOwner

    {

        require(_cardFactoryAddress != address(0), "Cardma: card factory not set");

        

        uint256 cardIndex = _cards.length;

        address cardAddress = createCardContract();

        ERC721WithMessage cardContract = ERC721WithMessage(cardAddress);

        cardContract.setupOwnership();

        cardContract.initialize(

            name,

            string((abi.encodePacked("CM-", uint2str(cardIndex)))),

            tokenURI

        );

        _cards.push(Card(

            cardAddress,

            name,

            author,

            description,

            imageURI,

            price,

            0,

            limit

        ));

    }

    

    function updateCardPrice(

        uint256 cardIndex,

        uint256 price

    )

        public

        onlyOwner

        checkIndex(cardIndex)

    {

        _cards[cardIndex].price = price;

    }



    function claimAllRevenue()

        public

        onlyOwner

    {

        _msgSender().transfer(_revenue);

        _revenue = 0;

    }



    function getRevenue()

        public

        view

        returns (uint256 revenue)

    {

        return _revenue;

    }

    

    /*

     * ----- Public Methods -----

     */

    // Default payable function

    function()

        external

        payable

    {

    }



    function getPersonalChallenge()

        public

        view

        returns (bytes32 challenge)

    {

        return keccak256(abi.encodePacked(

            "portto - make blockchain simple",

            _msgSender()

        ));

    }



    function getCard(uint256 cardIndex)

        public

        view

        checkIndex(cardIndex)

        returns (Card memory card)

    {

        return _cards[cardIndex];

    }

    

    function getCards()

        public

        view

        returns (Card[] memory cards)

    {

        return _cards;

    }

    

    function sendCard(

        address keyAddress,

        uint256 cardIndex,

        string memory message,

        bool encrypted

    )

        public

        payable

        checkIndex(cardIndex)

    {

        Card storage card = _cards[cardIndex];



        // Check card keyAddress

        require(_sentCards[keyAddress].keyAddress == address(0), "Cardma: same keyAddress exists");



        // Check card availability

        require(card.limit == 0 || card.count < card.limit, "Cardma: desired card has been sold out");



        // Check and charge card price

        require(msg.value >= card.price, "Cardma: cannot afford the card");

        _revenue += card.price;



        uint256 tokenId = card.count;

        // Mint ERC721 token

        ERC721WithMessage(card.cardAddress).mintWithMessage(

            address(this), // hold token until claimed

            tokenId,

            message,

            encrypted

        );



        // Keep token and ETH

        address senderAddress = _msgSender();

        SentCard memory sentCard = SentCard(

            senderAddress,

            keyAddress,

            cardIndex,

            tokenId,

            msg.value - card.price,

            block.timestamp,

            false

        );



        // Update contract storage

        _sentCards[keyAddress] = sentCard;

        _sentCardsFromUser[senderAddress].push(keyAddress);

        card.count += 1;

    }



    function readCard(address keyAddress)

        public

        view

        returns (ReadableCard memory card)

    {

        SentCard storage sentCard = _sentCards[keyAddress];

        Card storage card = _cards[sentCard.cardIndex];



        (string memory message, bool encrypted) = ERC721WithMessage(card.cardAddress).tokenMessage(sentCard.tokenId);



        return ReadableCard(

            keyAddress,

            card.imageURI,

            message,

            encrypted,

            sentCard.giftAmount,

            sentCard.timestamp,

            sentCard.claimed

        );

    }



    function claimCard(

        address keyAddress,

        uint8 v,

        bytes32 r,

        bytes32 s

    )

        public

        checkSignature(keyAddress, v, r, s)

    {

        address payable msgSender = _msgSender();

        SentCard storage sentCard = _sentCards[keyAddress];

        Card storage card = _cards[sentCard.cardIndex];



        // Check card unclaimed

        require(!sentCard.claimed, "Cardma: card already claimed");



        // Transfer ERC721 token

        ERC721WithMessage(card.cardAddress)

            .safeTransferFrom(

                address(this),

                msgSender,

                sentCard.tokenId

            );



        // Transfer ETH

        msgSender.transfer(sentCard.giftAmount);

        _receivedCardsForUser[msgSender].push(keyAddress);

        sentCard.claimed = true;

    }



    function getMySentCards()

        public

        view

        returns (ReadableCard[] memory sentCards)

    {

        address[] storage sentCardsFromUser = _sentCardsFromUser[_msgSender()];

        ReadableCard[] memory sentCards = new ReadableCard[](sentCardsFromUser.length);



        for(uint i = 0; i < sentCardsFromUser.length; i++) {

            sentCards[i] = readCard(sentCardsFromUser[i]);

        }



        return sentCards;

    }



    function getMyReceivedCards()

        public

        view

        returns (ReadableCard[] memory receivedCards)

    {

        address[] storage receivedCardsForUser = _receivedCardsForUser[_msgSender()];

        ReadableCard[] memory receivedCards = new ReadableCard[](receivedCardsForUser.length);



        for(uint i = 0; i < receivedCardsForUser.length; i++) {

            receivedCards[i] = readCard(receivedCardsForUser[i]);

        }



        return receivedCards;

    }

}