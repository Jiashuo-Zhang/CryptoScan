pragma solidity ^0.5.0;



interface IERC165 {

    /**

     * @notice Query if a contract implements an interface

     * @param interfaceId The interface identifier, as specified in ERC-165

     * @dev Interface identification is specified in ERC-165. This function

     * uses less than 30,000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**

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



contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;

    using Address for address;



    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;



    // Mapping from token ID to owner

    mapping (uint256 => address) private _tokenOwner;



    // Mapping from token ID to approved address

    mapping (uint256 => address) private _tokenApprovals;



    // Mapping from owner to number of owned token

    mapping (address => uint256) private _ownedTokensCount;



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

        return _ownedTokensCount[owner];

    }



    /**

     * @dev Gets the owner of the specified token ID

     * @param tokenId uint256 ID of the token to query the owner of

     * @return owner address currently marked as the owner of the given token ID

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

     * Requires the msg sender to be the owner, approved, or operator

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

     *

     * Requires the msg sender to be the owner, approved, or operator

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

     * Requires the msg sender to be the owner, approved, or operator

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

     * @return whether the token exists

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

     *    is an operator of the owner, or is the owner of the token

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

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));

        require(!_exists(tokenId));



        _tokenOwner[tokenId] = to;

        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);



        emit Transfer(address(0), to, tokenId);

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



        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);

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



        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);

        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);



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

     * @return whether the call correctly returned the expected magic value

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



contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);



    function tokenByIndex(uint256 index) public view returns (uint256);

}



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

    /**

     * 0x780e9d63 ===

     *     bytes4(keccak256('totalSupply()')) ^

     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

     *     bytes4(keccak256('tokenByIndex(uint256)'))

     */



    /**

     * @dev Constructor function

     */

    constructor () public {

        // register the supported interface to conform to ERC721 via ERC165

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

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;

    }



    /**

     * @dev Gets the token ID at a given index of all the tokens in this contract

     * Reverts if the index is greater or equal to the total number of tokens

     * @param index uint256 representing the index to be accessed of the tokens list

     * @return uint256 token ID at the given index of the tokens list

     */

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply());

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

     * @dev Internal function to mint a new token

     * Reverts if the given token ID already exists

     * @param to address the beneficiary that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);



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



        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occcupied by

        // lasTokenId, or just over the end of the array if the token was the last one).

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



contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}



contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Optional mapping for token URIs

    mapping(uint256 => string) private _tokenURIs;



    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**

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



    function _tokenURI(uint256 tokenId) internal view returns (string memory) {

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



contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {

        // solhint-disable-previous-line no-empty-blocks

    }

}



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

     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

     */

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)

    public returns (bytes4);

}



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





/**************************************************************************

VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch

***************************************************************************/

/**************************************************************************

VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch

***************************************************************************/

/**************************************************************************

VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch

***************************************************************************/

/**************************************************************************

VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch

***************************************************************************/

/**************************************************************************

VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch VonAesch

***************************************************************************/





contract VonAeschERC721 is ERC721Full {



    uint256 public liveTokenId;





    mapping(bytes32 => uint256) private PatternToken;

    mapping(uint256 => bytes32) private TokenPattern;

    mapping(uint256 => string) private _tokenMSGs;



    string public info = "Von Aesch Offcial Token https://von-aesch.com";



    string public baseTokenURI = "https://von-aesch.com/tokenURI.php?colors=";

    string public basefallbackTokenURI = "https://cloudflare-ipfs.com/ipfs/Qmes4xg8qpfrpBnfCgcm1i9235gSszMS7pDTStWRAFNmYv#colors=";



    address private constant emergency_admin = 0x59ab67D9BA5a748591bB79Ce223606A8C2892E6d;

    address private constant first_admin = 0x9a203e2E251849a26566EBF94043D74FEeb0011c;

    address private admin = 0x9a203e2E251849a26566EBF94043D74FEeb0011c;





    constructor()

        ERC721Full("VonAeschPattern", "VA")

        public

    {}



    /**************************************************************************

    * modifiers

    ***************************************************************************/



    modifier onlyAdmin {

        require(msg.sender == admin);

        _;

    }



    modifier onlyEAdmin {

        require(msg.sender == emergency_admin);

        _;

    }





    /* function currentId (bytes32 patternid) public view

    returns(bool)

    {

      if(Pattern[patternid].owner == address(0)){

        return false;

      }else{

        return true;

      }

    } */



    /**************************************************************************

    * Overrides

    ***************************************************************************/



    function strConcat(string memory a, string memory b) internal pure returns (string memory) {

        return string(abi.encodePacked(a, b));

    }



    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));

        return strConcat(

            baseTokenURI,

            _tokenURI(tokenId)

        );

    }



    function fallbackTokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));

        return strConcat(

            basefallbackTokenURI,

            _tokenURI(tokenId)

        );

    }



    /* function tokenURI22(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));

        return strConcat(

            baseTokenURI,

            _tokenURI(tokenId)

        );

    } */



    function tokenMessage(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId));

        return _tokenMSGs[tokenId];

    }





    /**************************************************************************

    * functionS

    ***************************************************************************/





    function patternIdToTokenId(bytes32 patternid) public view returns(uint256){

      return PatternToken[patternid];

    }



    function tokenIdToPatternId(uint256 tokenId) public view returns(bytes32){

      return TokenPattern[tokenId];

    }





    function _setTokenMSG(uint256 tokenId, string memory _msg) internal {

        require(_exists(tokenId));

        _tokenMSGs[tokenId] = _msg;

    }



    function setMessage(uint256 tokenId, string memory _msg) public {

      address owner = ownerOf(tokenId);

      require(msg.sender == owner);

      _setTokenMSG(tokenId,_msg);

    }





    function checkPatternExistance (bytes32 patternid) public view

    returns(bool)

    {

    //get tokenid from PATTERNID

    uint256 t_tokenId = PatternToken[patternid];

      return _exists(t_tokenId);

    }



    function exists(uint256 tokenId) public view returns(bool){

      return _exists(tokenId);

    }



    function nextTokenId() internal returns(uint256) {

      liveTokenId = liveTokenId + 1;

      return liveTokenId;

    }



    function createPattern(bytes32 patternid, string memory dataMixed, address newowner, string memory message)

        onlyAdmin

        public

        returns(string memory)

    {



      //CONVERT DATA to UPPERCASE

      string memory data = toUpper(dataMixed);



      //hash the color data

      bytes32 colordatahash = keccak256(abi.encodePacked(data));



      //check if _exists. continue if it doesnt.

      require(PatternToken[colordatahash] == 0);



      //generate new tokenId

      uint256 newTokenId = nextTokenId();



      //assign token id to pattern mapping

      PatternToken[colordatahash] = newTokenId;

      //and vice versa

      TokenPattern[newTokenId] = colordatahash;



      //mint new token

      _mint(newowner, newTokenId);

      _setTokenURI(newTokenId, data);

      _setTokenMSG(newTokenId, message);



      return "ok";





    }

    function transferPattern(bytes32 patternid,address newowner,string memory message, uint8 v, bytes32 r, bytes32 s)

      public

      returns(string memory)

    {

        //anyone can transfer a token BUT needs to supply a new address signed by the old owner



        //get tokenid from PATTERNID

        uint256 t_tokenId = PatternToken[patternid];



        //get old owner

        address t_oldowner = ownerOf(t_tokenId);

        require(t_oldowner != address(0));



        //generate the hash for the new address

        bytes32 h = prefixedHash2(newowner);



        //check if eveything adds up.

        require(ecrecover(h, v, r, s) == t_oldowner);



        _transferFrom(t_oldowner, newowner, t_tokenId);

        _setTokenMSG(t_tokenId, message);



        return "ok";



    }



    function changeMessage(bytes32 patternid,string memory message, uint8 v, bytes32 r, bytes32 s)

      public

      returns(string memory)

    {

      //anyone can change the message of a token BUT needs to supply a new message signed by the owner



      //get tokenid from PATTERNID

      uint256 t_tokenId = PatternToken[patternid];



      //get owner

      address t_owner = ownerOf(t_tokenId);

      require(t_owner != address(0));



      //generate the hash for the new message

      bytes32 h = prefixedHash(message);



      //check if eveything adds up.

      require(ecrecover(h, v, r, s) == t_owner);



      _setTokenMSG(t_tokenId, message);



      return "ok";



    }



    function verifyOwner(bytes32 patternid, address owner, uint8 v, bytes32 r, bytes32 s)

      public

      view

      returns(bool)

    {

      //get tokenid from PATTERNID

      uint256 t_tokenId = PatternToken[patternid];



      //get owner

      address t_owner = ownerOf(t_tokenId);

      require(t_owner != address(0));



      //generate the hash for the new message

      bytes32 h = prefixedHash2(owner);



      //check if eveything adds up.

      address owner2 = ecrecover(h, v, r, s);



      //check if owner actually owns item in question

      if(t_owner == owner2 && owner == owner2){

        return true;

      }else{

        return false;

      }

    }



    function prefixedHash(string memory message)

      private

      pure

      returns (bytes32)

    {

        bytes32 h = keccak256(abi.encodePacked(message));

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", h));

    }



    function prefixedHash2(address message)

      private

      pure

      returns (bytes32)

    {

        bytes32 h = keccak256(abi.encodePacked(message));

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", h));

    }





    /* okokokokokoikokokokokokok */



    function userHasPattern(address account)

      public

      view

      returns(bool)

    {

      if(balanceOf(account) >=1 )

      {

        return true;

      }else{

        return false;

      }

    }



    function emergency(address newa)

      public

      onlyEAdmin

    {

      require(newa != address(0));

      admin = newa;

    }



    function changeInfo(string memory newstring)

      public

      onlyAdmin

    {

      info = newstring;

    }



    function changeBaseTokenURI(string memory newstring)

      public

      onlyAdmin

    {

      baseTokenURI = newstring;

    }



    function changeFallbackTokenURI(string memory newstring)

      public

      onlyAdmin

    {

      basefallbackTokenURI = newstring;

    }





    function toUpper(string memory str)

      pure

      private

      returns (string memory)

    {

      bytes memory bStr = bytes(str);

      bytes memory bLower = new bytes(bStr.length);

      for (uint i = 0; i < bStr.length; i++) {

        // lowercase character...

        if ((uint8(bStr[i]) >= 65+32) && (uint8(bStr[i]) <= 90+32)) {

          // So we remove 32 to make it uppercase

          bLower[i] = bytes1(uint8(bStr[i]) - 32);

        } else {

          bLower[i] = bStr[i];

        }

      }

      return string(bLower);

    }











}