/**

 *Submitted for verification at Etherscan.io on 2020-11-14

*/



pragma solidity ^0.5.16;



/**

  * @title ArtDeco Finance

  *

  * @notice Reward for ArtNFT staking , A-1-type role for initial user

  * 

  */



interface NFTFactory{

    function getMeta( uint256 resId ) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, address);

    function getFactory( uint256 nftId ) external view returns (address);

}





interface IAnftToken{

    function mint(address to, uint256 tokenId) external returns (bool) ;

    function burn(uint256 tokenId) external;

    function safeMint(address to, uint256 tokenId, bytes calldata _data) external returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function totalSupply() external returns (uint256);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}



interface IPlayerLink {

    function settleReward( address from,uint256 amount ) external returns (uint256);

    function bindRefer( address from,string calldata  affCode )  external returns (bool);

    function hasRefer(address from) external returns(bool);



}



library Math {

    /**

     * @dev Returns the largest of two numbers.

     */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;

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

        // (a + b) / 2 can overflow, so we distribute

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

    }

}



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

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        address msgSender = _msgSender();

        _owner = msgSender;

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



/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);



    function tokenByIndex(uint256 index) public view returns (uint256);

}





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

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts

        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned

        // for accounts without code, i.e. `keccak256('')`

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly

        assembly { codehash := extcodehash(account) }

        return (codehash != accountHash && codehash != 0x0);

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

        // The {SafeMath} overflow check can be skipped here, see the comment at the top

        counter._value += 1;

    }



    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);

    }

}





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

     * This is an internal detail of the `ERC721` contract and its use is deprecated.

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

        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(

            IERC721Receiver(to).onERC721Received.selector,

            _msgSender(),

            from,

            tokenId,

            _data

        ));

        if (!success) {

            if (returndata.length > 0) {

                // solhint-disable-next-line no-inline-assembly

                assembly {

                    let returndata_size := mload(returndata)

                    revert(add(32, returndata), returndata_size)

                }

            } else {

                revert("ERC721: transfer to non ERC721Receiver implementer");

            }

        } else {

            bytes4 retval = abi.decode(returndata, (bytes4));

            return (retval == _ERC721_RECEIVED);

        }

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





/**

 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {

    // Mapping from owner to list of owned token IDs

    mapping(address => uint256[]) private _ownedTokens;



    // Mapping from token ID to index of the owner tokens list

    mapping(uint256 => uint256) private _ownedTokensIndex;



    // Array with all token ids, used for enumeration

    uint256[] private _allTokens;



    // Mapping from token id to position in the allTokens array

    mapping(uint256 => uint256) private _allTokensIndex;



    /*

     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd

     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59

     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7

     *

     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63

     */

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;



    /**

     * @dev Constructor function.

     */

    constructor () public {

        // register the supported interface to conform to ERC721Enumerable via ERC165

        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);

    }



    /**

     * @dev Gets the token ID at a given index of the tokens list of the requested owner.

     * @param owner address owning the tokens list to be accessed

     * @param index uint256 representing the index to be accessed of the requested tokens list

     * @return uint256 token ID at the given index of the tokens list owned by the requested address

     */

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");

        return _ownedTokens[owner][index];

    }



    /**

     * @dev Gets the total amount of tokens stored by the contract.

     * @return uint256 representing the total amount of tokens

     */

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;

    }



    /**

     * @dev Gets the token ID at a given index of all the tokens in this contract

     * Reverts if the index is greater or equal to the total number of tokens.

     * @param index uint256 representing the index to be accessed of the tokens list

     * @return uint256 token ID at the given index of the tokens list

     */

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");

        return _allTokens[index];

    }



    /**

     * @dev Internal function to transfer ownership of a given token ID to another address.

     * As opposed to transferFrom, this imposes no restrictions on msg.sender.

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);



        _removeTokenFromOwnerEnumeration(from, tokenId);



        _addTokenToOwnerEnumeration(to, tokenId);

    }



    /**

     * @dev Internal function to mint a new token.

     * Reverts if the given token ID already exists.

     * @param to address the beneficiary that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);



        _addTokenToOwnerEnumeration(to, tokenId);



        _addTokenToAllTokensEnumeration(tokenId);

    }



    /**

     * @dev Internal function to burn a specific token.

     * Reverts if the token does not exist.

     * Deprecated, use {ERC721-_burn} instead.

     * @param owner owner of the token to burn

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);



        _removeTokenFromOwnerEnumeration(owner, tokenId);

        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund

        _ownedTokensIndex[tokenId] = 0;



        _removeTokenFromAllTokensEnumeration(tokenId);

    }



    /**

     * @dev Gets the list of token IDs of the requested owner.

     * @param owner address owning the tokens

     * @return uint256[] List of token IDs owned by the requested address

     */

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];

    }



    /**

     * @dev Private function to add a token to this extension's ownership-tracking data structures.

     * @param to address representing the new owner of the given token ID

     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

     */

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;

        _ownedTokens[to].push(tokenId);

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

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and

        // then delete the last slot (swap and pop).



        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);

        uint256 tokenIndex = _ownedTokensIndex[tokenId];



        // When the token to delete is the last token, the swap operation is unnecessary

        if (tokenIndex != lastTokenIndex) {

            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];



            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        }



        // This also deletes the contents at the last position of the array

        _ownedTokens[from].length--;



        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by

        // lastTokenId, or just over the end of the array if the token was the last one).

    }



    /**

     * @dev Private function to remove a token from this extension's token tracking data structures.

     * This has O(1) time complexity, but alters the order of the _allTokens array.

     * @param tokenId uint256 ID of the token to be removed from the tokens list

     */

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and

        // then delete the last slot (swap and pop).



        uint256 lastTokenIndex = _allTokens.length.sub(1);

        uint256 tokenIndex = _allTokensIndex[tokenId];



        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so

        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding

        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)

        uint256 lastTokenId = _allTokens[lastTokenIndex];



        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index



        // This also deletes the contents at the last position of the array

        _allTokens.length--;

        _allTokensIndex[tokenId] = 0;

    }

}





/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see {ERC20Detailed}.

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

    function mint(address account, uint amount) external;

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





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using SafeMath for uint256;

    using Address for address;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        // solhint-disable-next-line max-line-length

        require((value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves.



        // A Solidity high level call has three parts:

        //  1. The target address is checked to verify it contains contract code

        //  2. The call itself is made, and success asserted

        //  3. The return value is decoded, which in turn checks the size of the returned data.

        // solhint-disable-next-line max-line-length

        require(address(token).isContract(), "SafeERC20: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = address(token).call(data);

        require(success, "SafeERC20: low-level call failed");



        if (returndata.length > 0) { // Return data is optional

            // solhint-disable-next-line max-line-length

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}





contract Governance {



    address public _governance;



    constructor() public {

        _governance = tx.origin;

    }



    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);



    modifier onlyGovernance {

        require(msg.sender == _governance, "not governance");

        _;

    }



    function setGovernance(address governance)  public  onlyGovernance

    {

        require(governance != address(0), "new governance the zero address");

        emit GovernanceTransferred(_governance, governance);

        _governance = governance;

    }





}



contract NFTRewardA is Governance {

    using SafeERC20 for IERC20;

    using SafeMath for uint256;



    IERC20 public _artd = IERC20(0xA23F8462d90dbc60a06B9226206bFACdEAD2A26F);

    IAnftToken public _anftToken = IAnftToken(0x99a7e1188CE9a0b7514d084878DFb8A405D8529F);

    address public _anftFactory = 0xC1046b1e2941248da9926d57719eEcb61C676719;

    address public _playerLink = address(0x4eD7A3721F203Cf108b4279061B36CC20b14E57A);



    address public _teamWallet = 0x3b2b4f84cFE480289df651bE153c147fa417Fb8A;

    address public _rewardPool = 0x4D732FA01032b41eE0fA152398B22Bfab6689DCb;



    uint256 public constant DURATION = 30 days;

    uint256 public _initReward = 500 * 1e18;

    uint256 public _startTime =  now + 3650 days;

    uint256 public _periodFinish = 0;

    uint256 public _rewardRate = 0;

    uint256 public _lastUpdateTime;

    uint256 public _rewardPerWeightStored;



    uint256 public _teamRewardRate = 500;

    uint256 public _poolRewardRate = 1000;

    uint256 public _baseRate = 10000;

    uint256 public _punishTime = 5 days;

  

    mapping(address => uint256) public _userRewardPerWeightPaid;

    mapping(address => uint256) public _userrewards;

    mapping(uint256 => uint256) public _idRewardPerWeightPaid;

    mapping(uint256 => uint256) public _idrewards;

    mapping(address => uint256) public _lastStakedTime;



    bool public _hasStart = false;

    bool public _hasRewardStart = false;

    uint256 public _fixRateBase = 100000;

    

    uint256 public _totalWeight;

    mapping(address => uint256) public _weightBalances;

    mapping(address => uint256) public _artdBalances;

    mapping(address => uint256[]) public _playerAnft;

    mapping(uint256 => uint256) public _anftMapIndex;

    

    uint256 private _totalPower;

    mapping(address => uint256) private _powerBalances;



    struct User {

        address owner;

        uint256 nftId;

        uint index;

    }

    mapping (uint256 => User) private users;

    uint256[] private usersRecords;



    event ReadyStake(uint256 timestamp);

    event RewardReserved(uint256 reward);

    event StakedANft(address indexed user, uint256 anftId);

    event WithdrawnANft(address indexed user, uint256 anftId);

    event RewardPaid(address indexed user, uint256 reward);

    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);

    event NewJoinId(uint256 indexed anftId, uint index, address owner);



    modifier checkHalve() {

        if (block.timestamp >= _periodFinish) {

            _initReward = _initReward.mul(50).div(100);



            _artd.mint(address(this), _initReward);



            _rewardRate = _initReward.div(DURATION);

            _periodFinish = block.timestamp.add(DURATION);

            emit RewardReserved(_initReward);

        }

        _;

    }

    

    modifier checkStart() {

        require(block.timestamp > _startTime, "not start");

        _;

    }



    modifier updateReward(address account) {

        _rewardPerWeightStored = rewardPerWeight();

        _lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {

            _userrewards[account] = earned(account);

            _userRewardPerWeightPaid[account] = _rewardPerWeightStored;

        }

        _;

    }

    

    modifier updateIdReward(uint256 anftId) {

        _rewardPerWeightStored = rewardPerWeight();

        _lastUpdateTime = lastTimeRewardApplicable();

        if (anftId != 0) {

            _idrewards[anftId] = earnedId(anftId);

            _idRewardPerWeightPaid[anftId] = _rewardPerWeightStored;

        }

        _;

    }  



    function addUserId(uint256 _nftid) private returns(bool success)

    {

        users[_nftid].nftId = _nftid;

        users[_nftid].owner = msg.sender;

        users[_nftid].index = usersRecords.push(_nftid) -1;

        emit NewJoinId( _nftid, users[_nftid].index, users[_nftid].owner );

        return true;

    }



    function quitUser(uint256 _nftid) private returns(uint index)

    {

        uint toDelete = users[_nftid].index;

        uint256 lastIndex = usersRecords[usersRecords.length-1];

        usersRecords[toDelete] = lastIndex;

        users[lastIndex].index = toDelete; 

        usersRecords.length--;

        return toDelete;   

    }    

    

    function getStaker(uint256 _nftid) public view returns( address )

    {

        return users[_nftid].owner;

    }   



    function UserRecord(uint256 number) public view returns( uint256 )

    {

        return usersRecords[number];

    }   



    function stakeInfo(uint256 number) public view returns( uint256, address, uint256, uint256 )

    {

        uint256 nftid = usersRecords[number];

        address staker = users[nftid].owner;

        uint256 weight = getNftWeight(nftid);

        uint256 earnedbyid = earnedId(nftid);

        return (nftid, staker, weight, earnedbyid);

    }   



    function stakeCount() public view returns( uint )

    {

        return usersRecords.length;

    }  



    function setNftFactoy(address anftfactory) external onlyGovernance{

        _anftFactory = anftfactory;

    }

    

    /* Fee collection for any other token */

    function seize(IERC20 token, uint256 amount) external onlyGovernance{

        require(token != _artd, "reward");

        token.safeTransfer(_governance, amount);

    }

    

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, _periodFinish);

    }



    function rewardPerWeight() public view returns (uint256) {

       

        if( _hasRewardStart == false){

            return _rewardPerWeightStored;

        }

          

        if (totalWeight() == 0) {

            return _rewardPerWeightStored;

        }

        return

            _rewardPerWeightStored.add(

                lastTimeRewardApplicable()

                    .sub(_lastUpdateTime)

                    .mul(_rewardRate)

                    .mul(1e18)

                    .div(totalWeight())

            );

    }



    function earned(address account) public view returns (uint256) {

        return

            getWeight(account)

                .mul(rewardPerWeight().sub(_userRewardPerWeightPaid[account]))

                .div(1e18)

                .add(_userrewards[account]);

    }



    function earnedId(uint256 anftId) public view returns (uint256) {

        return

            getNftWeight(anftId)

                .mul(rewardPerWeight().sub(_idRewardPerWeightPaid[anftId]))

                .div(1e18)

                .add(_idrewards[anftId]);

    }

    

    function getNftWeight( uint256 anftId ) public view returns ( uint256 )

    {

        uint256 era;

        uint256 grade;

        uint256 promote;

        uint256 artdAmount;

        uint256 apwrAmount;

        uint256 skill;

        address factory;



        NFTFactory _nftfactory =  NFTFactory(_anftFactory);

        (era, grade, promote, artdAmount, apwrAmount, skill, factory) = _nftfactory.getMeta(anftId);



        require(artdAmount > 0,"No ARTD amount error");

        uint256 weight = 0;

        require(era > 0, "era zero error");

           

        uint256 artd =  artdAmount.div(1e18);

        uint256 apwr =  apwrAmount.div(1e16);

        uint lv1 = 0;

        uint lv2 = 0;

        uint lv3 = 0;

        if( artd >= 1)

            lv1 = 1;

        if( apwr >= 3)

            lv2 = 1;

        if( skill >= 1)

            lv3 = 1;

            

        weight = lv1 + lv2 + lv3;

            

        return weight;

    }



    function getWeight(address account) public view returns (uint256) {

        return _weightBalances[account];

    }



    function totalWeight() public view returns (uint256) {

        return _totalWeight;

    }

    

    

    function stakeAnft(uint256 anftId, string memory affCode)

        public

        updateReward(msg.sender)

        checkHalve

        checkStart

    {

        uint256[] storage anftIds = _playerAnft[msg.sender];

        if (anftIds.length == 0) {

            anftIds.push(0);    

            _anftMapIndex[0] = 0;

        }

        anftIds.push(anftId);

        _anftMapIndex[anftId] = anftIds.length - 1;

        

        if( _idRewardPerWeightPaid[anftId] == 0 )

        {

            _idRewardPerWeightPaid[anftId] = rewardPerWeight();

            _idrewards[anftId] = 0;

        }



        address owner = NFTownerOf(anftId);

        require(msg.sender == owner);

        

        uint256 stakeweight = 0;



        require(anftId > 0, "Cannot stake zero ID");

        stakeweight = getNftWeight(anftId);



        _totalWeight = _totalWeight.add(stakeweight);

        _weightBalances[msg.sender] = _weightBalances[msg.sender].add(stakeweight);



        _anftToken.safeTransferFrom(msg.sender, address(this), anftId);



        if (!IPlayerLink(_playerLink).hasRefer(msg.sender)) {

            IPlayerLink(_playerLink).bindRefer(msg.sender, affCode);

        }

        

        addUserId(anftId);

        _lastStakedTime[msg.sender] = now;

        emit StakedANft(msg.sender, anftId);        

   

    }

    

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {

        if(_hasStart == false) {

            return 0;

        }



        emit NFTReceived(operator, from, tokenId, data);

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    }



    function withdrawAnft(uint256 anftId)

        public

        updateReward(msg.sender)

        updateIdReward(anftId)

        checkHalve

        checkStart

    {

        require(anftId > 0, "the anftId error");

        

        uint256[] memory anftIds = _playerAnft[msg.sender];

        uint256 anftIndex = _anftMapIndex[anftId];

        

        require(anftIds[anftIndex] == anftId, "not AnftId owner");



        uint256 anftArrayLength = anftIds.length-1;

        uint256 tailId = anftIds[anftArrayLength];



        _playerAnft[msg.sender][anftIndex] = tailId;

        _playerAnft[msg.sender][anftArrayLength] = 0;

        _playerAnft[msg.sender].length--;

        _anftMapIndex[tailId] = anftIndex;

        _anftMapIndex[anftId] = 0;



        uint256 weight = 0;



        weight = getNftWeight(anftId);



        if( weight > _totalWeight )

        {

            _totalWeight = 0;

        }

        else

        {

            _totalWeight = _totalWeight.sub(weight);

        }

        

        if( weight > _powerBalances[msg.sender])

        {

            _weightBalances[msg.sender] = 0;

        }

        else

        {

            _weightBalances[msg.sender] = _weightBalances[msg.sender].sub(weight);

        }

        

        _anftToken.safeTransferFrom(address(this), msg.sender, anftId);

        quitUser(anftId);

        

        emit WithdrawnANft(msg.sender, anftId);

    }        



    function withdrawall()

        public

        checkStart

    {

        uint256[] memory anftId = _playerAnft[msg.sender];

        for (uint8 index = 1; index < anftId.length; index++) {

            if (anftId[index] > 0) {

                withdrawAnft(anftId[index]);

            }

        }

    }



    function getPlayerIds( address account ) public view returns( uint256[] memory anftId )

    {

        anftId = _playerAnft[account];

    }



    function exit() external {

        withdrawall();

        getReward();

    }



    function getReward() public 

      updateReward(msg.sender) 

      checkHalve 

      checkStart 

    {

        uint256 reward = earned(msg.sender);

        if (reward > 0) {

            _userrewards[msg.sender] = 0;



            uint256 fee = IPlayerLink(_playerLink).settleReward(msg.sender, reward);

            if(fee > 0){

                _artd.safeTransfer(_playerLink, fee);

            }

            

            uint256 teamReward = reward.mul(_teamRewardRate).div(_baseRate);

            if(teamReward>0){

                _artd.safeTransfer(_teamWallet, teamReward);

            }

            uint256 leftReward = reward.sub(fee).sub(teamReward);

            uint256 poolReward = 0;



            if(now  < (_lastStakedTime[msg.sender] + _punishTime) ){

                poolReward = leftReward.mul(_poolRewardRate).div(_baseRate);

            }

            if(poolReward>0){

                _artd.safeTransfer(_rewardPool, poolReward);

                leftReward = leftReward.sub(poolReward);

            }



            if(leftReward>0){

                _artd.safeTransfer(msg.sender, leftReward );

            }

    

            uint256[] memory anftId = _playerAnft[msg.sender];

            uint256 nftid = 0;

            

            for (uint8 index = 1; index < anftId.length; index++) {

                if (anftId[index] > 0) 

                {

                    nftid = anftId[index];

                    _idrewards[nftid] = 0;

                    _idRewardPerWeightPaid[nftid] = 0;

                }

            }

        

            emit RewardPaid(msg.sender, leftReward);

        }

 

    }



    function readyNFTStake( )

        external

        onlyGovernance

    {

        require(_hasStart == false, "has started");

        _hasStart = true;



         _startTime = now;

         

        emit ReadyStake(now);

    }



    // set Timestamp to start NFTReward

    function startNFTReward(uint256 startTime)

        external

        onlyGovernance

        updateReward(address(0))

        updateIdReward(0)

    {

        require(_hasStart == true, "To start NFTStake firstly");

        _hasRewardStart = true;

        

        _startTime = startTime;



        _rewardRate = _initReward.div(DURATION); 

        _artd.mint(address(this), _initReward);



        _lastUpdateTime = _startTime;

        _periodFinish = _startTime.add(DURATION);



        emit RewardReserved(_initReward);

    }





    // Extend reward for increase players

    function reserveMintAmount(uint256 reward)

        external

        onlyGovernance

        updateReward(address(0))

        updateIdReward(0)

    {

        _artd.mint(address(this), reward);

        if (block.timestamp >= _periodFinish) {

            _rewardRate = reward.div(DURATION);

        } else {

            uint256 remaining = _periodFinish.sub(block.timestamp);

            uint256 leftover = remaining.mul(_rewardRate);

            _rewardRate = reward.add(leftover).div(DURATION);

        }

        _lastUpdateTime = block.timestamp;

        _periodFinish = block.timestamp.add(DURATION);

        emit RewardReserved(reward);

    }



    function setTeamRewardRate( uint256 teamRewardRate ) public onlyGovernance {

        _teamRewardRate = teamRewardRate;

    }



    function setPoolRewardRate( uint256  poolRewardRate ) public onlyGovernance{

        _poolRewardRate = poolRewardRate;

    }



    function setWithDrawPunishTime( uint256  punishTime ) public onlyGovernance{

        _punishTime = punishTime;

    }



    /**

     * @dev Gets the owner of the NFT ID

     * @param nftId uint256 ID of the token to query the owner of

     * @return owner address currently marked as the owner of the given NFT ID

     */

    function NFTownerOf(uint256 nftId) public view returns (address) {

        IAnftToken _anftx =  IAnftToken(_anftToken);

        address owner = _anftx.ownerOf(nftId);

        require(owner != address(0));

        return owner;

    }

    

}