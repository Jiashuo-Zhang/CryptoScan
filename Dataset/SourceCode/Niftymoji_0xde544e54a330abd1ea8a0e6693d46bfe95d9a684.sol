/**

 *Submitted for verification at Etherscan.io on 2020-02-25

*/



pragma solidity ^0.5.16; /*



___________________________________________________________________

  _      _                                        ______           

  |  |  /          /                                /              

--|-/|-/-----__---/----__----__---_--_----__-------/-------__------

  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     

__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_







███╗   ██╗██╗███████╗████████╗██╗   ██╗    ███╗   ███╗ ██████╗      ██╗██╗

████╗  ██║██║██╔════╝╚══██╔══╝╚██╗ ██╔╝    ████╗ ████║██╔═══██╗     ██║██║

██╔██╗ ██║██║█████╗     ██║    ╚████╔╝     ██╔████╔██║██║   ██║     ██║██║

██║╚██╗██║██║██╔══╝     ██║     ╚██╔╝      ██║╚██╔╝██║██║   ██║██   ██║██║

██║ ╚████║██║██║        ██║      ██║       ██║ ╚═╝ ██║╚██████╔╝╚█████╔╝██║

╚═╝  ╚═══╝╚═╝╚═╝        ╚═╝      ╚═╝       ╚═╝     ╚═╝ ╚═════╝  ╚════╝ ╚═╝

                                                                          



=== 'Niftymoji' NFT Management contract with following features ===

    => ERC721 Compliance

    => ERC165 Compliance

    => SafeMath implementation 

    => Generation of new digital assets

    => Destroyal of digital assets





============= Independant Audit of the code ============

    => Multiple Freelancers Auditors





-------------------------------------------------------------------

 Copyright (c) 2019 onwards  Niftymoji Inc. ( https://niftymoji.com )

-------------------------------------------------------------------

*/ 





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address payable internal _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     * @notice Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address payable newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address payable newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}





// File: contracts/Strings.sol



pragma solidity ^0.5.2;



library Strings {

  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {

    bytes memory _ba = bytes(_a);

    bytes memory _bb = bytes(_b);

    bytes memory _bc = bytes(_c);

    bytes memory _bd = bytes(_d);

    bytes memory _be = bytes(_e);

    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

    bytes memory babcde = bytes(abcde);

    uint k = 0;

    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

    for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

    for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

    for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

    for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];

    return string(babcde);

  }



  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {

    return strConcat(_a, _b, _c, _d, "");

  }



  function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

    return strConcat(_a, _b, _c, "", "");

  }



  function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

    return strConcat(_a, _b, "", "", "");

  }



  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

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



  function fromAddress(address addr) internal pure returns(string memory) {

    bytes20 addrBytes = bytes20(addr);

    bytes16 hexAlphabet = "0123456789abcdef";

    bytes memory result = new bytes(42);

    result[0] = '0';

    result[1] = 'x';

    for (uint i = 0; i < 20; i++) {

      result[i * 2 + 2] = hexAlphabet[uint8(addrBytes[i] >> 4)];

      result[i * 2 + 3] = hexAlphabet[uint8(addrBytes[i] & 0x0f)];

    }

    return string(result);

  }

}



// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



pragma solidity ^0.5.2;



/**

 * @title IERC165

 * @dev https://eips.ethereum.org/EIPS/eip-165

 */

interface IERC165 {

    /**

     * @notice Query if a contract implements an interface

     * @param interfaceId The interface identifier, as specified in ERC-165

     * @dev Interface identification is specified in ERC-165. This function

     * uses less than 30,000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol



pragma solidity ^0.5.2;





/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://eips.ethereum.org/EIPS/eip-721

 */

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);



    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);



    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol



pragma solidity ^0.5.2;



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

contract IERC721Receiver {

    /**

     * @notice Handle the receipt of an NFT

     * @dev The ERC721 smart contract calls this function on the recipient

     * after a `safeTransfer`. This function MUST return the function selector,

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



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

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

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



// File: openzeppelin-solidity/contracts/utils/Address.sol



pragma solidity ^0.5.2;



/**

 * Utility library of inline functions on addresses

 */

library Address {

    /**

     * Returns whether the target address is a contract

     * @dev This function will return false if invoked during the constructor of a contract,

     * as the code is not actually created until after the constructor finishes.

     * @param account address of the account to check

     * @return whether the target address is a contract

     */

    function isContract(address account) internal view returns (bool) {

        uint256 size;

        // XXX Currently there is no better way to check if there is a contract in an address

        // than to check the size of the code at that address.

        // See https://ethereum.stackexchange.com/a/14016/36603

        // for more details about how this works.

        // TODO Check this again before the Serenity release, because all addresses will be

        // contracts then.

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

    }

}



// File: openzeppelin-solidity/contracts/drafts/Counters.sol



pragma solidity ^0.5.2;





/**

 * @title Counters

 * @author Matt Condon (@shrugs)

 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number

 * of elements in a mapping, issuing ERC721 ids, or counting request ids

 *

 * Include with `using Counters for Counters.Counter;`

 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath

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



// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



pragma solidity ^0.5.2;





/**

 * @title ERC165

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /*

     * 0x01ffc9a7 ===

     *     bytes4(keccak256('supportsInterface(bytes4)'))

     */



    /**

     * @dev a mapping of interface id to whether or not it's supported

     */

    mapping(bytes4 => bool) private _supportedInterfaces;



    /**

     * @dev A contract implementing SupportsInterfaceWithLookup

     * implement ERC165 itself

     */

    constructor () internal {

        _registerInterface(_INTERFACE_ID_ERC165);

    }



    /**

     * @dev implement supportsInterface(bytes4) using a lookup table

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];

    }



    /**

     * @dev internal method for registering an interface

     */

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);

        _supportedInterfaces[interfaceId] = true;

    }

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol



pragma solidity ^0.5.2;









interface OldNiftymoji{

    function powerNLucks(uint256 tokenID) external returns(uint256, uint256);

}









/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://eips.ethereum.org/EIPS/eip-721

 */

contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;

    using Address for address;

    using Counters for Counters.Counter;

    

        struct powerNLuck

    {

        uint256 power;

        uint256 luck;        

    }

    

    uint256 public totalSupply;

    

    //uint256 is tokenNo and powerNLuck is associated details in uint256

    mapping (uint256 => powerNLuck) public powerNLucks;



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



    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*

     * 0x80ac58cd ===

     *     bytes4(keccak256('balanceOf(address)')) ^

     *     bytes4(keccak256('ownerOf(uint256)')) ^

     *     bytes4(keccak256('approve(address,uint256)')) ^

     *     bytes4(keccak256('getApproved(uint256)')) ^

     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^

     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^

     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))

     */



    constructor () public {

        // register the supported interfaces to conform to ERC721 via ERC165

        _registerInterface(_INTERFACE_ID_ERC721);

    }



    /**

     * @dev Gets the balance of the specified address

     * @param owner address to query the balance of

     * @return uint256 representing the amount owned by the passed address

     */

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));

        return _ownedTokensCount[owner].current();

    }



    /**

     * @dev Gets the owner of the specified token ID

     * @param tokenId uint256 ID of the token to query the owner of

     * @return address currently marked as the owner of the given token ID

     */

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];

        require(owner != address(0));

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

        require(to != owner);

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



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

        require(_exists(tokenId));

        return _tokenApprovals[tokenId];

    }



    /**

     * @dev Sets or unsets the approval of a given operator

     * An operator is allowed to transfer all tokens of the sender on their behalf

     * @param to operator address to set the approval

     * @param approved representing the status of the approval to be set

     */

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);

        _operatorApprovals[msg.sender][to] = approved;

        emit ApprovalForAll(msg.sender, to, approved);

    }



    /**

     * @dev Tells whether an operator is approved by a given owner

     * @param owner owner address which you want to query the approval of

     * @param operator operator address which you want to query the approval of

     * @return bool whether the given operator is approved by the given owner

     */

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev Transfers the ownership of a given token ID to another address

     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible

     * Requires the msg.sender to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));



        _transferFrom(from, to, tokenId);

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

     */

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");

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

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, _data));

    }



    /**

     * @dev Returns whether the specified token exists

     * @param tokenId uint256 ID of the token to query the existence of

     * @return bool whether the token exists

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];

        return owner != address(0);

    }



    /**

     * @dev Returns whether the given spender can transfer a given token ID

     * @param spender address of the spender to query

     * @param tokenId uint256 ID of the token to be transferred

     * @return bool whether the msg.sender is approved for the given token ID,

     * is an operator of the owner, or is the owner of the token

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);

        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

    }



    /**

     * @dev Internal function to mint a new token

     * Reverts if the given token ID already exists

     * @param to The address that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _mint(address to, uint256 tokenId, uint256 _userSeed) internal {

        require(to != address(0));

        require(!_exists(tokenId));

        require(totalSupply <= 3187, 'Excedend Max Token Supply');



        _tokenOwner[tokenId] = to;

        _ownedTokensCount[to].increment();

        totalSupply++;

        

        //generating random numbers for luck and power based on previous blockhash and user seed

        //this method of entropy is not very secure, but kept it as consent of client

        uint256 _luck = uint256(keccak256(abi.encodePacked(blockhash( block.number -1), _userSeed))) % 100; //0-99

        uint256 _power = uint256(keccak256(abi.encodePacked(blockhash( block.number -10), now, _userSeed))) % 100; //0-99

        //assigning lucky no and power to tokenId        

        powerNLucks[tokenId].luck = _luck+1;    //this will cause it will never be zero.

        powerNLucks[tokenId].power = _power+1;  //this will cause it will never be zero.



        emit Transfer(address(0), to, tokenId);

    }

    

    function _mintSyncedTokens(uint256 tokenID, address user) internal {

        

        _tokenOwner[tokenID] = user;

        _ownedTokensCount[user].increment();

        totalSupply++;

        

        //generating random numbers for luck and power based on previous blockhash and user seed

        //this method of entropy is not very secure, but kept it as consent of client

        (uint256 _power, uint256 _luck) = OldNiftymoji(0x40b16A1b6bEA856745FeDf7E0946494B895611a2).powerNLucks(tokenID);  //mainnet

        //(uint256 _power, uint256 _luck) = OldNiftymoji(0x03f701FB8EA5441A9Bf98B65461e795931B55298).powerNLucks(tokenID);    //testnet

        

        //assigning lucky no and power to tokenId        

        powerNLucks[tokenID].luck = _luck;    //this will cause it will never be zero.

        powerNLucks[tokenID].power = _power;  //this will cause it will never be zero.



        emit Transfer(address(0), user, tokenID);

    }

    

    



    /**

     * @dev Internal function to burn a specific token

     * Reverts if the token does not exist

     * Deprecated, use _burn(uint256) instead.

     * @param owner owner of the token to burn

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);



        _clearApproval(tokenId);



        _ownedTokensCount[owner].decrement();

        _tokenOwner[tokenId] = address(0);



        emit Transfer(owner, address(0), tokenId);

    }



    /**

     * @dev Internal function to burn a specific token

     * Reverts if the token does not exist

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);

    }



    /**

     * @dev Internal function to transfer ownership of a given token ID to another address.

     * As opposed to transferFrom, this imposes no restrictions on msg.sender.

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);

        require(to != address(0));



        _clearApproval(tokenId);



        _ownedTokensCount[from].decrement();

        _ownedTokensCount[to].increment();



        _tokenOwner[tokenId] = to;



        emit Transfer(from, to, tokenId);

    }



    /**

     * @dev Internal function to invoke `onERC721Received` on a target address

     * The call is not executed if the target address is not a contract

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



        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);

        return (retval == _ERC721_RECEIVED);

    }



    /**

     * @dev Private function to clear current approval of a given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {

            _tokenApprovals[tokenId] = address(0);

        }

    }

    

    

    

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Enumerable.sol



pragma solidity ^0.5.2;





/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

contract IERC721Enumerable is IERC721 {

    //function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);



    function tokenByIndex(uint256 index) public view returns (uint256);

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol



pragma solidity ^0.5.2;









/**

 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    // Mapping from owner to list of owned token IDs

    mapping(address => uint256[]) private _ownedTokens;



    // Mapping from token ID to index of the owner tokens list

    mapping(uint256 => uint256) private _ownedTokensIndex;



    // Array with all token ids, used for enumeration

    uint256[] private _allTokens;



    // Mapping from token id to position in the allTokens array

    mapping(uint256 => uint256) private _allTokensIndex;



    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /*

     * 0x780e9d63 ===

     *     bytes4(keccak256('totalSupply()')) ^

     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

     *     bytes4(keccak256('tokenByIndex(uint256)'))

     */



    /**

     * @dev Constructor function

     */

    constructor () public {

        // register the supported interface to conform to ERC721Enumerable via ERC165

        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);

    }



    /**

     * @dev Gets the token ID at a given index of the tokens list of the requested owner

     * @param owner address owning the tokens list to be accessed

     * @param index uint256 representing the index to be accessed of the requested tokens list

     * @return uint256 token ID at the given index of the tokens list owned by the requested address

     */

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner));

        return _ownedTokens[owner][index];

    }



    /**

     * @dev Gets the total amount of tokens stored by the contract

     * @return uint256 representing the total amount of tokens

     */

    function totalSupplyEnum() public view returns (uint256) {

        return _allTokens.length;

    }



    /**

     * @dev Gets the token ID at a given index of all the tokens in this contract

     * Reverts if the index is greater or equal to the total number of tokens

     * @param index uint256 representing the index to be accessed of the tokens list

     * @return uint256 token ID at the given index of the tokens list

     */

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupplyEnum());

        return _allTokens[index];

    }



    



    /**

     * @dev Gets the list of token IDs of the requested owner

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

     * @dev Internal function to mint a new token

     * Reverts if the given token ID already exists

     * @param to address the beneficiary that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId,0);



        _addTokenToOwnerEnumeration(to, tokenId);



        _addTokenToAllTokensEnumeration(tokenId);

    }



    /**

     * @dev Internal function to burn a specific token

     * Reverts if the token does not exist

     * Deprecated, use _burn(uint256) instead

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

     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that

     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for

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



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol



pragma solidity ^0.5.2;





/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol



pragma solidity ^0.5.2;









contract ERC721Metadata is ERC165, IERC721Metadata, ERC721 {

    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Optional mapping for token URIs

    mapping(uint256 => string) private _tokenURIs;



    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*

     * 0x5b5e139f ===

     *     bytes4(keccak256('name()')) ^

     *     bytes4(keccak256('symbol()')) ^

     *     bytes4(keccak256('tokenURI(uint256)'))

     */



    /**

     * @dev Constructor function

     */

    constructor (string memory name, string memory symbol) public {

        _name = name;

        _symbol = symbol;



        // register the supported interfaces to conform to ERC721 via ERC165

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);

    }



    /**

     * @dev Gets the token name

     * @return string representing the token name

     */

    function name() external view returns (string memory) {

        return _name;

    }



    /**

     * @dev Gets the token symbol

     * @return string representing the token symbol

     */

    function symbol() external view returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns an URI for a given token ID

     * Throws if the token ID does not exist. May return an empty string.

     * @param tokenId uint256 ID of the token to query

     */

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));

        return _tokenURIs[tokenId];

    }



    /**

     * @dev Internal function to set the token URI for a given token

     * Reverts if the token ID does not exist

     * @param tokenId uint256 ID of the token to set its URI

     * @param uri string URI to assign

     */

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId));

        _tokenURIs[tokenId] = uri;

    }



    /**

     * @dev Internal function to burn a specific token

     * Reverts if the token does not exist

     * Deprecated, use _burn(uint256) instead

     * @param owner owner of the token to burn

     * @param tokenId uint256 ID of the token being burned by the msg.sender

     */

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);



        // Clear metadata (if any)

        if (bytes(_tokenURIs[tokenId]).length != 0) {

            delete _tokenURIs[tokenId];

        }

    }

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol



pragma solidity ^0.5.2;









/**

 * @title Full ERC721 Token

 * This implementation includes all the required and some optional functionality of the ERC721 standard

 * Moreover, it includes approve all functionality using operator terminology

 * @dev see https://eips.ethereum.org/EIPS/eip-721

 */

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {

        // solhint-disable-previous-line no-empty-blocks

    }

}





// File: contracts/TradeableERC721Token.sol



pragma solidity ^0.5.2;









contract OwnableDelegateProxy { }







contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;

}



/**

 * @title TradeableERC721Token

 * TradeableERC721Token - ERC721 contract that whitelists a trading address, and has minting functionality.

 */

contract TradeableERC721Token is ERC721Full, Ownable {

  using Strings for string;

  

  uint256 public tokenPrice=5 * (10**16) ;  //price of token to buy

  address proxyRegistryAddress;

  uint256 private _currentTokenId = 0;

  

  



  constructor(string memory _name, string memory _symbol) ERC721Full(_name, _symbol) public {

  }



  /**

    * @dev Mints a token to an address with a tokenURI.

    * @param _to address of the future owner of the token

    */

  function mintTo(address _to) public onlyOwner {

    uint256 newTokenId = _getNextTokenId();

    _mint(_to, newTokenId,0);

    _incrementTokenId();

  }





  function setTokenPrice(uint256 _tokenPrice) public onlyOwner returns(bool)

  {

      tokenPrice = _tokenPrice;

      return true;

  }

  



  function buyToken(uint256 _userSeed) public payable returns(bool)

  {

    uint256 paidAmount = msg.value;

    require(paidAmount == tokenPrice, "Invalid amount paid");

    uint256 newTokenId = _getNextTokenId();

    _mint(msg.sender, newTokenId,_userSeed);

    _incrementTokenId(); 

    _owner.transfer(paidAmount);

     return true;

  }

  

  function batchMintToken(address[] memory _buyer) public onlyOwner returns(bool)

  {

      uint256 buyerLength = _buyer.length;

      require(buyerLength <= 100, "please try less then 101");

      for(uint256 i=0;i<buyerLength;i++)

      {

        uint256 newTokenId = _getNextTokenId();

        _mint(_buyer[i], newTokenId,0);

        _incrementTokenId();           

      }

      return true;

  }

  



  /**

    * @dev calculates the next token ID based on value of _currentTokenId 

    * @return uint256 for the next token ID

    */

  function _getNextTokenId() private view returns (uint256) {

    return _currentTokenId.add(1);

  }



  /**

    * @dev increments the value of _currentTokenId 

    */

  function _incrementTokenId() private  {

    _currentTokenId++;

  }



  function baseTokenURI() public view returns (string memory) {

    return "";

  }



  function tokenURI(uint256 _tokenId) external view returns (string memory) {

    return Strings.strConcat(baseTokenURI(),Strings.uint2str(_tokenId)

    );

  }



  /**

   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.

   */

  function isApprovedForAll(

    address owner,

    address operator

  )

    public

    view

    returns (bool)

  {

    // Whitelist OpenSea proxy contract for easy trading.

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

    if (address(proxyRegistry.proxies(owner)) == operator) {

        return true;

    }



    return super.isApprovedForAll(owner, operator);

  }

  

  function changeProxyURL(address newProxyAddress) public onlyOwner returns(bool){

      proxyRegistryAddress = newProxyAddress;

      return true;

  }

  

  

  function syncFromOldContract(uint256[] memory tokens, address[] memory users) public onlyOwner returns(bool) {

      uint256 arrayLength = tokens.length;

        require(arrayLength <= 150, 'Too many tokens IDs');

        

        //processing each entries

        for(uint8 i=0; i< arrayLength; i++ ){

            if(!_exists(tokens[i])){

                _mintSyncedTokens(tokens[i], users[i]);

                _incrementTokenId(); 

            }

        }

        return true;

    }

  

}



// File: contracts/OpenSeaAsset.sol



pragma solidity ^0.5.2;







/**

 * @title OpenSea Asset

 * OpenSea Asset - A contract for easily creating custom assets on OpenSea. 

 */

contract Niftymoji is TradeableERC721Token {

  string private _baseTokenURI;

  uint256 public changePowerPrice = 20000000000000000; //0.02 ETH

  uint256 public changeLuckPrice =  20000000000000000; //0.02 ETH



  constructor(

    string memory _name,

    string memory _symbol,

    string memory baseURI

  ) TradeableERC721Token(_name, _symbol) public {

    _baseTokenURI = baseURI;

  }



  function openSeaVersion() public pure returns (string memory) {

    return "1.2.0";

  }



  function baseTokenURI() public view returns (string memory) {

    return _baseTokenURI;

  }



  function setBaseTokenURI(string memory uri) public onlyOwner {

    _baseTokenURI = uri;

  }

  

  function changePowerLuckPrice(uint256 powerPrice, uint256 luckPrice) public onlyOwner returns(bool){

      changePowerPrice = powerPrice;

      changeLuckPrice  = luckPrice;

      return true;

  }

  

  /**

   * Status: 0 = only power, 1 = only luck, 2 = both power and luck

   */

  function changePowerLuck(uint256 tokenID, uint8 status) public payable returns(bool){

      require(msg.sender == ownerOf(tokenID), 'This token is not owned by caller');

      if(status == 0){

          require(msg.value == changePowerPrice, 'Invalid ETH amount');

            //generating random numbers for luck and power based on previous blockhash and timestamp

            //this method of entropy is not very secure, but kept it as consent of client

            uint256 _power = uint256(keccak256(abi.encodePacked(blockhash( block.number -10), now))) % 100; //0-99 

            powerNLucks[tokenID].power = _power+1;  //this will cause it will never be zero.

      }

      else if(status == 1){

          require(msg.value == changeLuckPrice, 'Invalid ETH amount');

            uint256 _luck = uint256(keccak256(abi.encodePacked(blockhash( block.number -1)))) % 100;        //0-99

            powerNLucks[tokenID].luck = _luck+1;    //this will cause it will never be zero.

      }

      else if(status == 2){

          require(msg.value == (changePowerPrice + changeLuckPrice), 'Invalid ETH amount');

            uint256 _luck = uint256(keccak256(abi.encodePacked(blockhash( block.number -1)))) % 100;        //0-99

            uint256 _power = uint256(keccak256(abi.encodePacked(blockhash( block.number -10), now))) % 100; //0-99 

            //assigning lucky no and power to tokenId        

            powerNLucks[tokenID].luck = _luck+1;    //this will cause it will never be zero.

            powerNLucks[tokenID].power = _power+1;  //this will cause it will never be zero.

      }

      

        _owner.transfer(msg.value);

        return true;

      

  }

  

  

  

  

  

}