// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; 
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

import "./common/meta-transactions/ContentMixin.sol";
import "./common/meta-transactions/NativeMetaTransaction.sol";


// Proxy

contract OwnableDelegateProxy {}
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}


//
// SKY FRONTIER OARAI ICON NFT
//

contract SkyFrontier_Oarai_ICON_NFT is Context, ERC721Enumerable, ContextMixin, NativeMetaTransaction, Ownable, Pausable, DefaultOperatorFilterer {

    using Counters for Counters.Counter;

    address private _proxyRegistryAddress;
    string private _baseURIString;


    uint256 public constant CHARS_TOTAL_SUPPLY = 10_000;

    uint constant C_System = 0;
    uint constant C_Leyla  = 1;
    uint constant C_Sakura = 2;
    uint constant C_Other  = 3;

    Counters.Counter[4] private _currentTokenId;
    string[4] private _tokenType = [ "System", "Leyla", "Sakura", "Other" ];


    // ERC721
    constructor(
        string memory name,
        string memory symbol,
	address proxyRegistryAddress,
	string memory baseURI
    ) ERC721(name, symbol) {
	_proxyRegistryAddress = proxyRegistryAddress;
	_baseURIString = baseURI;
	_initializeEIP712(name);

	_currentTokenId[C_System].reset();
	_currentTokenId[C_Leyla ].reset();
	_currentTokenId[C_Sakura].reset();
	_currentTokenId[C_Other ].reset();
    }

    function decimals() public pure returns ( uint8 ) { return 0; }

    function totalSupply() public view virtual override returns (uint256) {
	uint256 tokens = _currentTokenId[C_System].current() + _currentTokenId[C_Leyla].current() + _currentTokenId[C_Sakura].current() + _currentTokenId[C_Other].current();
        return tokens;
    }


    // Mint

    function mint(address to, uint ctype) public virtual onlyOwner returns( uint256 ) {
//	require( !paused() );

	require( (ctype==C_System||ctype==C_Leyla||ctype==C_Sakura||ctype==C_Other), "mint: Type mismatch" );
	require( (_currentTokenId[ctype].current()<CHARS_TOTAL_SUPPLY), "mint: Token supply exceeded" );

	_currentTokenId[ctype].increment();
        uint256 newItemId = ctype*10000 + _currentTokenId[ctype].current();

	require(!_exists(newItemId), "ERC721: token already minted");

        super._safeMint(to, newItemId);

	return newItemId;
    }

    function mintSystem(address to) public virtual onlyOwner returns( uint256 ) { return mint( to, C_System ); }
    function mintLeyla (address to) public virtual onlyOwner returns( uint256 ) { return mint( to, C_Leyla  ); }
    function mintSakura(address to) public virtual onlyOwner returns( uint256 ) { return mint( to, C_Sakura ); }
    function mintOther (address to) public virtual onlyOwner returns( uint256 ) { return mint( to, C_Other  ); }

    function bulkMint(address to, uint ctype, uint256 amount) public virtual onlyOwner returns( uint256 ) {
	uint256 lastItemId = 0;

        for(uint256 i=1; i<=amount; i++){
          lastItemId = mint(to, ctype);
        }

	return lastItemId;
    }


    // URI

    function setBaseTokenURI( string memory newBaseTokenURI ) public virtual onlyOwner returns (string memory) {
	string memory oldBaseTokeURI = _baseURIString;
	_baseURIString = newBaseTokenURI;
	return oldBaseTokeURI;
    }

    function baseTokenURI() public view virtual returns (string memory) {
        return string(abi.encodePacked( _baseURIString ));
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
	uint ctype = tokenId / CHARS_TOTAL_SUPPLY;
	uint token = tokenId % CHARS_TOTAL_SUPPLY;
        return string(abi.encodePacked( baseTokenURI(), _tokenType[ctype], "/metadata/", Strings.toString(token) ));
    }

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked( baseTokenURI(), "ContractMetadata" ));
    }


    // pause

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }


    // Transfer

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
	uint256 batchsize
    ) internal whenNotPaused virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchsize);

        if (from != address(0)) {
            require( _isApprovedOrOwner(_msgSender(), tokenId), "Only the owner of NFT can transfer or burn it" );
        }

	require( ( batchsize == 1 ), "ERC721Enumerable: Consecutive transfers not supported" );
        require( !paused(), "ERC721Pausable: token transfer while paused");
    }


    // Burn

    function burn(uint256 tokenId) public {
        super._burn(tokenId);
    }


    // OpenSea

    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override(ERC721, IERC721) returns (bool isOperator) {
        // Whitelist OpenSea proxy contract for easy trading.

	// Ethereum (Mainnet/rinkeby)
        ProxyRegistry proxyRegistry = ProxyRegistry(_proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

/*
	// No Proxy: Polygon / Ethereum (goerli)
        if (address(_proxyRegistryAddress) == operator) {
            return true;
        }
*/
        
        return super.isApprovedForAll(owner, operator);
    }

    function setApprovalForAll(address operator, bool approved) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }


    function _msgSender() internal override view returns (address sender)
    {
        return ContextMixin.msgSender();
    }

}  // End of Contract

//
// EOF
//