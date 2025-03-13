/* SPDX-License-Identifier: MIT */



//         */*

//                         ./###/.           ./##/

//         ..,.            .(####*.          ,(##(

//         *###*.          ,######*.        ./###(.

//          /###/.        .*#######/.       /####(.

//          ,(###(*       ./###(####*      *(####(.

//           /#####/      ,(###.,(###*    .(#####(,

//           ,(#####(.    *###/  ,(###/   ,*(#####,

//            *######/.  ,(###,   ./##############,

//            ./#############/     ./###########/.

//             ,/(###########(*.   *##############*

//              ./##############(/(####(,,..*/(###/

//         ,(###/*.    *########(*      *####/

//              .*####/.      ./###(*.        .*(/*

//               .(##(.



pragma solidity ^0.8.17;



//import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "./OperatorFilterer.sol";



contract Web3MakersBegins is Ownable, ERC721Enumerable, OperatorFilterer {



    using Strings for uint256;



    /// @dev Enum about SaleState Mint

    enum SaleState {

        NO,

        ALLOW_SALE,

        PUBLIC_SALE

    }



    /// @dev State Mint

    SaleState public state;



    // @param Is the final metadata accessible ?

    bool public revealed;



    // @param Key use for the whitelist processing

    bytes32 public merkleRoot;



    // @param baseTokenURI  Base url for token.

    string private baseTokenURI;



    // @param  Number of items in the collection

    uint256 public immutable collectionSize;



    // @param Number of items in the gift supply

    uint256 public immutable giftSupply;



    // @param Min eth balabce to mint

    uint256 public immutable minEThBalance;



    // @param  get the address  who has minted

    mapping(address => bool) public  hasMinted;





    constructor(

        string memory _baseUri,

        uint256 _collectionSize,

        uint256 _giftSupply,

        uint256 _minEthBalance

    )  ERC721("Web3Makers Begins", "W3MBegins")

    OperatorFilterer(address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6), true)

    {

        baseTokenURI = _baseUri;

        collectionSize = _collectionSize;

        giftSupply = _giftSupply;

        minEThBalance = _minEthBalance;

    }



    modifier callerIsUser() {

        require(tx.origin == msg.sender, "NO_BOT");

        _;

    }





    function startAllowSale(bytes32 _merkelRoot) external onlyOwner {

        state = SaleState.ALLOW_SALE;

        merkleRoot = _merkelRoot;

    }





    function startPublicSale() external onlyOwner {

        state = SaleState.PUBLIC_SALE;

    }



    function reveal(string calldata _revealedTokenURI) external onlyOwner {

        setBaseURI(_revealedTokenURI);

        revealed = true;

    }



    function setBaseURI(string  memory _uri) public onlyOwner {

        baseTokenURI = _uri;

    }



    function _baseURI() internal override view virtual returns (string memory) {

        string memory uri = baseTokenURI;

        return uri;

    }



    function baseURI() external view virtual returns (string memory) {

        return _baseURI();

    }



    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        _requireMinted(tokenId);

        string memory mBaseURI = _baseURI();

        if (!revealed) {

            return mBaseURI;

        }

        return bytes(mBaseURI).length > 0 ? string(abi.encodePacked(mBaseURI, tokenId.toString())) : "";

    }





    function exists(uint256 tokenId) external view returns (bool) {

        return _exists(tokenId);

    }



    // @param quantity  number of requested token

    // @param recipient  owner of the minted NFT

    function giftMint(uint256 quantity, address recipient) external onlyOwner callerIsUser {

        uint256 supply = totalSupply();

        require(supply + quantity <= giftSupply, "GIFT_SUPPLY_EXCEEDED");

        for (uint256 i; i < quantity; i++) {

            _safeMint(recipient, supply + i);

        }

    }



    function allowMint(bytes32[] memory proof) external callerIsUser {

        uint256 supply = totalSupply();

        require(state == SaleState.ALLOW_SALE, "NOT_ALLOW_SALE");

        bytes32 leaf = keccak256(abi.encode(msg.sender));

        require(MerkleProof.verify(proof, merkleRoot, leaf), "NOT_ALLOWED");

        require(hasMinted[msg.sender] == false, "ALREADY_CLAIMED");

        require(supply < collectionSize, "SOLD_OUT");

        hasMinted[msg.sender] = true;

        _safeMint(msg.sender, supply);

    }



    function publicMint() external callerIsUser

    {

        uint256 supply = totalSupply();

        require(state == SaleState.PUBLIC_SALE, "PUBLICSALE_NOT_STARTED");

        require(msg.sender.balance >= minEThBalance, "MIN_ETH_BALANCE");

        require(hasMinted[msg.sender] == false, "MAX_MINT_PER_WALLET_EXCEEDED");

        require(supply < collectionSize, "SOLD_OUT");

        hasMinted[msg.sender] = true;

        _safeMint(msg.sender, supply);

    }



    function getOwnedTokens(address _wallet) external view returns (uint256[] memory) {

        uint256 range = balanceOf(_wallet);

        uint256[] memory tokenIds = new uint256[](range);

        for (uint256 i; i < range; i++) {

            tokenIds[i] = tokenOfOwnerByIndex(_wallet, i);

        }

        return tokenIds;

    }

}