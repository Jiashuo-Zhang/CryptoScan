/**

 *Submitted for verification at Etherscan.io on 2023-08-03

*/



// SPDX-License-Identifier: MIT



// File: @openzeppelin/contracts/utils/Counters.sol





// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)



pragma solidity ^0.8.0;





library Counters {

    struct Counter {

        

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





library SignedMath {

    

    function max(int256 a, int256 b) internal pure returns (int256) {

        return a > b ? a : b;

    }



    

    function min(int256 a, int256 b) internal pure returns (int256) {

        return a < b ? a : b;

    }



    

    function average(int256 a, int256 b) internal pure returns (int256) {

        

        int256 x = (a & b) + ((a ^ b) >> 1);

        return x + (int256(uint256(x) >> 255) & (a ^ b));

    }



    

    function abs(int256 n) internal pure returns (uint256) {

        unchecked {

            

            return uint256(n >= 0 ? n : -n);

        }

    }

}







pragma solidity ^0.8.0;





library Math {

    enum Rounding {

        Down, // Toward negative infinity

        Up, // Toward infinity

        Zero // Toward zero

    }



    

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;

    }



    

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



   

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b) / 2 can overflow.

        return (a & b) + (a ^ b) / 2;

    }



    

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b - 1) / b can overflow on addition, so we distribute.

        return a == 0 ? 0 : (a - 1) / b + 1;

    }



   

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {

        unchecked {

            

            uint256 prod0; // Least significant 256 bits of the product

            uint256 prod1; // Most significant 256 bits of the product

            assembly {

                let mm := mulmod(x, y, not(0))

                prod0 := mul(x, y)

                prod1 := sub(sub(mm, prod0), lt(mm, prod0))

            }



           

            if (prod1 == 0) {

                

                return prod0 / denominator;

            }



           

            require(denominator > prod1, "Math: mulDiv overflow");



            

            uint256 remainder;

            assembly {

                

                remainder := mulmod(x, y, denominator)



               

                prod1 := sub(prod1, gt(remainder, prod0))

                prod0 := sub(prod0, remainder)

            }



            

            uint256 twos = denominator & (~denominator + 1);

            assembly {

               

                denominator := div(denominator, twos)



              

                prod0 := div(prod0, twos)



             

            }



            

            prod0 |= prod1 * twos;



            

            uint256 inverse = (3 * denominator) ^ 2;



           

            inverse *= 2 - denominator * inverse; // inverse mod 2^8

            inverse *= 2 - denominator * inverse; // inverse mod 2^16

            inverse *= 2 - denominator * inverse; // inverse mod 2^32

            inverse *= 2 - denominator * inverse; // inverse mod 2^64

            inverse *= 2 - denominator * inverse; // inverse mod 2^128

            inverse *= 2 - denominator * inverse; // inverse mod 2^256



            

            result = prod0 * inverse;

            return result;

        }

    }



   

    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {

        uint256 result = mulDiv(x, y, denominator);

        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {

            result += 1;

        }

        return result;

    }



    

    function sqrt(uint256 a) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



      

        uint256 result = 1 << (log2(a) >> 1);



       

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



   

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = sqrt(a);

            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);

        }

    }



   

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



    

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log2(value);

            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);

        }

    }



   

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



  

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log10(value);

            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);

        }

    }



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



    

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log256(value);

            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);

        }

    }

}







pragma solidity ^0.8.0;









library Strings {

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



   

    function toString(uint256 value) internal pure returns (string memory) {

        unchecked {

            uint256 length = Math.log10(value) + 1;

            string memory buffer = new string(length);

            uint256 ptr;

           

            assembly {

                ptr := add(buffer, add(32, length))

            }

            while (true) {

                ptr--;

                

                assembly {

                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))

                }

                value /= 10;

                if (value == 0) break;

            }

            return buffer;

        }

    }



   

    function toString(int256 value) internal pure returns (string memory) {

        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));

    }



    

    function toHexString(uint256 value) internal pure returns (string memory) {

        unchecked {

            return toHexString(value, Math.log256(value) + 1);

        }

    }



    

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



    

    function toHexString(address addr) internal pure returns (string memory) {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);

    }



    

    function equal(string memory a, string memory b) internal pure returns (bool) {

        return keccak256(bytes(a)) == keccak256(bytes(b));

    }

}







pragma solidity ^0.8.0;





abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}







pragma solidity ^0.8.0;







abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    

    constructor() {

        _transferOwnership(_msgSender());

    }



  

    modifier onlyOwner() {

        _checkOwner();

        _;

    }



    

    function owner() public view virtual returns (address) {

        return _owner;

    }



    

    function _checkOwner() internal view virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

    }



    function renounceOwnership() public virtual onlyOwner {

        _transferOwnership(address(0));

    }



    

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

    }



    

    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}







pragma solidity ^0.8.1;





library Address {

   

    function isContract(address account) internal view returns (bool) {

        

        return account.code.length > 0;

    }



   

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        (bool success, ) = recipient.call{value: amount}("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



   

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, "Address: low-level call failed");

    }



   

    function functionCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);

    }



    

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }



   

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



    

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");

    }



    

    function functionStaticCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal view returns (bytes memory) {

        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }





    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");

    }





    function functionDelegateCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        (bool success, bytes memory returndata) = target.delegatecall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }





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

        

        if (returndata.length > 0) {

            

            assembly {

                let returndata_size := mload(returndata)

                revert(add(32, returndata), returndata_size)

            }

        } else {

            revert(errorMessage);

        }

    }

}







pragma solidity ^0.8.0;





interface IERC721Receiver {

    

    function onERC721Received(

        address operator,

        address from,

        uint256 tokenId,

        bytes calldata data

    ) external returns (bytes4);

}





pragma solidity ^0.8.0;





interface IERC165 {

    

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity ^0.8.0;







abstract contract ERC165 is IERC165 {

   

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}





pragma solidity ^0.8.0;







interface IERC721 is IERC165 {

  

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);



    

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);



  

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



 

    function balanceOf(address owner) external view returns (uint256 balance);





    function ownerOf(uint256 tokenId) external view returns (address owner);





    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;



    function safeTransferFrom(address from, address to, uint256 tokenId) external;





    function transferFrom(address from, address to, uint256 tokenId) external;



    function approve(address to, uint256 tokenId) external;





    function setApprovalForAll(address operator, bool approved) external;



  

    function getApproved(uint256 tokenId) external view returns (address operator);



 

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}





pragma solidity ^0.8.0;







interface IERC721Metadata is IERC721 {

   

    function name() external view returns (string memory);



   

    function symbol() external view returns (string memory);



  

    function tokenURI(uint256 tokenId) external view returns (string memory);

}





pragma solidity ^0.8.0;



















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



 

    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

    }



  

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }



 

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: address zero is not a valid owner");

        return _balances[owner];

    }





    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _ownerOf(tokenId);

        require(owner != address(0), "ERC721: invalid token ID");

        return owner;

    }



 

    function name() public view virtual override returns (string memory) {

        return _name;

    }



  

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }





    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        _requireMinted(tokenId);



        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";

    }



  

    function _baseURI() internal view virtual returns (string memory) {

        return "";

    }



 

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);

        require(to != owner, "ERC721: approval to current owner");



        require(

            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),

            "ERC721: approve caller is not token owner or approved for all"

        );



        _approve(to, tokenId);

    }



  

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        _requireMinted(tokenId);



        return _tokenApprovals[tokenId];

    }





    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);

    }



 

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];

    }



  

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");



        _transfer(from, to, tokenId);

    }



   

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");

    }



  

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _safeTransfer(from, to, tokenId, data);

    }





    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {

        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");

    }



   

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {

        return _owners[tokenId];

    }



    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _ownerOf(tokenId) != address(0);

    }



    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        address owner = ERC721.ownerOf(tokenId);

        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);

    }





    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");

    }



   

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {

        _mint(to, tokenId);

        require(

            _checkOnERC721Received(address(0), to, tokenId, data),

            "ERC721: transfer to non ERC721Receiver implementer"

        );

    }



  

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");

        require(!_exists(tokenId), "ERC721: token already minted");



        _beforeTokenTransfer(address(0), to, tokenId, 1);



       

        require(!_exists(tokenId), "ERC721: token already minted");



        unchecked {

         

            _balances[to] += 1;

        }



        _owners[tokenId] = to;



        emit Transfer(address(0), to, tokenId);



        _afterTokenTransfer(address(0), to, tokenId, 1);

    }





    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);



        _beforeTokenTransfer(owner, address(0), tokenId, 1);



        

        owner = ERC721.ownerOf(tokenId);



        // Clear approvals

        delete _tokenApprovals[tokenId];



        unchecked {

            

            _balances[owner] -= 1;

        }

        delete _owners[tokenId];



        emit Transfer(owner, address(0), tokenId);



        _afterTokenTransfer(owner, address(0), tokenId, 1);

    }



   

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        require(to != address(0), "ERC721: transfer to the zero address");



        _beforeTokenTransfer(from, to, tokenId, 1);



        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");



      

        delete _tokenApprovals[tokenId];



        unchecked {

          

            _balances[from] -= 1;

            _balances[to] += 1;

        }

        _owners[tokenId] = to;



        emit Transfer(from, to, tokenId);



        _afterTokenTransfer(from, to, tokenId, 1);

    }



   

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;

        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);

    }



   

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {

        require(owner != operator, "ERC721: approve to caller");

        _operatorApprovals[owner][operator] = approved;

        emit ApprovalForAll(owner, operator, approved);

    }



   

    function _requireMinted(uint256 tokenId) internal view virtual {

        require(_exists(tokenId), "ERC721: invalid token ID");

    }



    

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



   

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}



    

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}



   

    function __unsafe_increaseBalance(address account, uint256 amount) internal {

        _balances[account] += amount;

    }

}







// dermerlo 



pragma solidity >=0.7.0 <0.9.0;









contract Elements5MLgen01 is ERC721, Ownable {

  using Strings for uint256;

  using Counters for Counters.Counter;



  Counters.Counter private supply;



  string public uriPrefix = "";

  string public uriSuffix = ".json";

  string public hiddenMetadataUri;

  

  uint256 public maxSupply = 118;

  uint256 public maxMintAmountPerTx = 1;



  bool public paused = true;

  bool public revealed = false;



  constructor() ERC721("Elements of 5ML gen.01", "5ML1") {

    setHiddenMetadataUri("ipfs://QmTEg7VFmdhbCTb1FTfesvwACauiWsAb2yD7TefTDRgtiB/hidden.json");

  }



  modifier mintCompliance(uint256 _mintAmount) {

    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");

    require(supply.current() + _mintAmount <= maxSupply, "Max supply exceeded!");

    _;

  }



  function totalSupply() public view returns (uint256) {

    return supply.current();

  }



  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {

    require(!paused, "The contract is paused!");

    require(balanceOf(msg.sender) == 0, "Max Mint per wallet reached");



    _mintLoop(msg.sender, _mintAmount);

  }

  

  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {

    _mintLoop(_receiver, _mintAmount);

  }



  function walletOfOwner(address _owner)

    public

    view

    returns (uint256[] memory)

  {

    uint256 ownerTokenCount = balanceOf(_owner);

    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);

    uint256 currentTokenId = 1;

    uint256 ownedTokenIndex = 0;



    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {

      address currentTokenOwner = ownerOf(currentTokenId);



      if (currentTokenOwner == _owner) {

        ownedTokenIds[ownedTokenIndex] = currentTokenId;



        ownedTokenIndex++;

      }



      currentTokenId++;

    }



    return ownedTokenIds;

  }



  function tokenURI(uint256 _tokenId)

    public

    view

    virtual

    override

    returns (string memory)

  {

    require(

      _exists(_tokenId),

      "ERC721Metadata: URI query for nonexistent token"

    );



    if (revealed == false) {

      return hiddenMetadataUri;

    }



    string memory currentBaseURI = _baseURI();

    return bytes(currentBaseURI).length > 0

        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))

        : "";

  }



  function setRevealed(bool _state) public onlyOwner {

    revealed = _state;

  }



  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {

    maxMintAmountPerTx = _maxMintAmountPerTx;

  }



  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {

    hiddenMetadataUri = _hiddenMetadataUri;

  }



  function setUriPrefix(string memory _uriPrefix) public onlyOwner {

    uriPrefix = _uriPrefix;

  }



  function setUriSuffix(string memory _uriSuffix) public onlyOwner {

    uriSuffix = _uriSuffix;

  }



  function setPaused(bool _state) public onlyOwner {

    paused = _state;

  }



  function withdraw() public onlyOwner {

    (bool os, ) = payable(owner()).call{value: address(this).balance}("");

    require(os);

    

  }



  function _mintLoop(address _receiver, uint256 _mintAmount) internal {

    for (uint256 i = 0; i < _mintAmount; i++) {

      supply.increment();

      _safeMint(_receiver, supply.current());

    }

  }



  function _baseURI() internal view virtual override returns (string memory) {

    return uriPrefix;

  }

}