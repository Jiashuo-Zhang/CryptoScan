/*******************************************************************************************

██████╗  ██████╗  ██████╗ ███╗   ███╗███████╗██████╗  █████╗ ███╗   ██╗ ██████╗ .ART

██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗████╗  ██║██╔════╝ 

██████╔╝██║   ██║██║   ██║██╔████╔██║█████╗  ██████╔╝███████║██╔██╗ ██║██║  ███╗

██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██║██║╚██╗██║██║   ██║

██████╔╝╚██████╔╝╚██████╔╝██║ ╚═╝ ██║███████╗██║  ██║██║  ██║██║ ╚████║╚██████╔╝

╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ PFP•ETH

*******************************************************************************************/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.15 <0.9.0;



/// @title Boomerang Messaging System - ETH edition

/// @author Boomerang.art

/// @notice The Boomerang Messaging System in the blockchain

/// @dev All function calls are currently implemented without side effects

/// @custom:Allright reserved Boomerang art 

/// @custom:Version 1.0.3

/// @custom:Contract 0xF82DC2f52397465fA91BD68Ec7eF23b4d45f4aDE

/// @custom:Audited by ReSecDevTeam "01 Jul, 2023"



import "./IERC721.sol";                      // nft standard

import "./ERC721.sol";                       // nft standard

import "./ERC721URIStorage.sol";  // nft location

import "./ERC721Burnable.sol";    // validating to burn items

import "./ERC2981.sol";                      // royalty lib

import "./ReentrancyGuard.sol";                  // security reason

import "./Ownable.sol";                            // security reason

import "./Counters.sol";                            // itteration

import "./IERC721A.sol";        // communicating by key



contract BoomerangNFT is ERC721, ERC721URIStorage, ERC721Burnable, ERC2981, Ownable, ReentrancyGuard {



    // ******************************************

    // Dataset

    // ******************************************

    using Counters for Counters.Counter;



    Counters.Counter private _tokenIdCounter;

    uint256 private price = 0.03 ether;         // 30000000000000000 wei, no cost for users, only newcomers pay for mint

    uint96  private __fee = 500;                // royalty fee

    

    address private creator;                    // income from royalty

    IERC721A BoomerangGenesis;                  // used for key to use this smartcontract



     

    string private _iconUrl; 



    // ******************************************

    // Yelling

    // ******************************************

    event RoyaltyFee(uint96 fee, uint256 time); 



    // ******************************************

    // Modifiers

    // ******************************************

    modifier isUser() {                         // this is for ETH network, the key owners valid for free mint

        require(_isUser(msg.sender) == true, "Only user");

        _;

    }



    // ******************************************

    // Init

    // ******************************************

    constructor(address _ticket, string memory _name, string memory _symbol, string memory iconUrl_) ERC721(_name, _symbol) {

        creator = msg.sender;

        _setDefaultRoyalty(creator, __fee);

        setTicket(_ticket);

        _iconUrl = iconUrl_;

    }



    function setIconUrl(string memory iconUrl_) public onlyOwner {      // set token icon

        _iconUrl = iconUrl_;

    }



    function iconUrl() public view returns (string memory) {            // get token icon

        return _iconUrl;

    }



    receive() external payable {}



    // ******************************************

    // The following functions are overrides required by Solidity.

    // ******************************************

    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) {

        super._burn(_tokenId);

        _resetTokenRoyalty(_tokenId);       // --> reset royalty for burned item

    }



    function tokenURI(uint256 _tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {

        return super.tokenURI(_tokenId);

    }



    // ******************************************

    // Communication

    // ******************************************

    function supportsInterface(bytes4 interfaceId) 

    public view virtual override(ERC721, ERC2981, ERC721URIStorage) returns (bool) {

        return interfaceId == type(IERC721).interfaceId ||

        interfaceId == type(IERC721A).interfaceId ||

        interfaceId == type(ERC2981).interfaceId || 

        super.supportsInterface(interfaceId);

    }



    // ******************************************

    // Royalty

    // ******************************************

    function changeRoyalityFee(uint96 newFee) public onlyOwner returns (uint96) {

        __fee = newFee;

        _setDefaultRoyalty(creator, newFee);

        emit RoyaltyFee(__fee, block.timestamp);

        return __fee;

    }



    function transferOwnership(address newOwner) public virtual override onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

        creator = newOwner;

    }



    function changeCreator(address _newCreator) public onlyOwner {

        require(_newCreator != address(0), "Only real address");

        creator = _newCreator;

        _setDefaultRoyalty(_newCreator, __fee);

    }



    // ******************************************

    // Claim

    // ******************************************

    // pfp only on eth - msg+pfp on polygon

    // ==========================================

    function pfpMint(string memory _uri) public isUser returns (uint256 _tokenId) {

        uint256 _id = _tokenIdCounter.current();

        _tokenId = _pfpMint(_uri);

        require(_tokenId > _id, "Mint did not happen");

    }



    function pfpMintClient(string memory _uri) public payable returns (uint256 _tokenId) {

        require(msg.value >= price, "Check the price");

        uint256 _id = _tokenIdCounter.current();

        _tokenId = _pfpMint(_uri);

        require(_tokenId > _id, "Mint did not happen");

        require(_withdraw(price), "Cost is not benefit");

    }



    // ==========================================

    function msgMintBulk(address[] memory _to, string memory _uri) public isUser returns (uint256 _tokenId, address _sender) {

        uint _len = _to.length;

        for(uint i = 0; i <= _len; ++i){

            uint256 _id = _tokenIdCounter.current();

            (_tokenId, _sender) = _msgMint(_to[i], _uri);

            require(_tokenId > _id, "Mint did not happen");

        }

    }



    function msgMintBulkClient(address[] memory _to, string memory _uri) public payable returns (uint256 _tokenId, address _sender) {

        uint _len = _to.length;

        uint _prices = price * _len;

        require(msg.value >= _prices, "Check the price");

        for(uint i = 0; i <= _len; ++i){

            uint256 _id = _tokenIdCounter.current();

            (_tokenId, _sender) = _msgMint(_to[i], _uri);

            require(_tokenId > _id, "Mint did not happen");

        }

        require(_withdraw(_prices), "Cost is not benefit");

    }



    function msgMint(address _to, string memory _uri) public isUser returns (uint256 _tokenId, address _sender) {

        uint256 _id = _tokenIdCounter.current();

        (_tokenId, _sender) = _msgMint(_to, _uri);

        require(_tokenId > _id, "Mint did not happen");

    }



    function msgMintClient(address _to, string memory _uri) public payable returns (uint256 _tokenId, address _sender) {

        require(msg.value >= price, "Check the price");

        uint256 _id = _tokenIdCounter.current();

        (_tokenId, _sender) = _msgMint(_to, _uri);

        require(_tokenId > _id, "Mint did not happen");

        require(_withdraw(price), "Cost is not benefit");

    }

    // ==========================================



    // mint logics

    function _pfpMint(string memory _uri) internal returns (uint256 _tokenId) {

        uint256 _id = _tokenIdCounter.current();

        _tokenIdCounter.increment();

        _setMinter(msg.sender, _id, _uri);

        _tokenId = _tokenIdCounter.current();

    }

    

    // _when = x hours {[14400 = 4H], [28800 = 8H], [43200 = 12H], [86400 = 24H]}

    function _msgMint(address _to, string memory _uri) internal returns (uint256 _tokenId, address _sender) {

        require(_to != msg.sender, "Use PFP for your-self");

        uint256 _id = _tokenIdCounter.current();

        _tokenIdCounter.increment();

        _setMinterTo(_to, _id, _uri);

        _sender = msg.sender;

        _tokenId = _tokenIdCounter.current();

    }



    function _setMinter(address _to, uint256 _id, string memory _uri) private {

        _safeMint(_to, _id); 

        _setTokenURI(_id, _uri);

    }



    function _setMinterTo(address _to, uint256 _id, string memory _uri) private {

        _safeMint(msg.sender, _id); 

        _setTokenURI(_id, _uri);

        approve(address(this), _id);

        setApprovalForAll(address(this), true);

        safeTransferFrom(msg.sender, _to, _id);

        /*

        // the separated logic in below

        approve(address(this), _id);

        setApprovalForAll(address(this), true);

        safeTransferFrom(msg.sender, _to, _id);

        

        // third-party, use js

            const contract = new ethers.Contract(

                '0x1234567890abcdef',

                'ERC721',

                provider

            );



            await contract.transferFrom(

                '0x1234567890abcdef',

                '0xdeadbeefdeadbeef',

                1

            );

        */

    }



    // ******************************************

    // Finance

    // ******************************************

    function getPrice() public view returns (uint256) {

        return price;

    }

    

    function setPrice(uint256 _price) public onlyOwner returns (uint256) {

        price = _price;

        return price;

    }



    function _withdraw(uint256 _val) private nonReentrant returns (bool) {

        (bool success, ) = payable(owner()).call{value: _val}("");

        /*

        // what to do:

        require(success);

        return success;

        */

        if (!success) {

            return false;

        } else {

            return true;

        }

    }



    // ******************************************

    // Ticket check

    // ******************************************

    function setTicket(address _boomerangGenesis) public onlyOwner {    // for ETH network only

        BoomerangGenesis = IERC721A(_boomerangGenesis);

    }



    function getTicket() public view returns (address) {                // for ETH network only

        // return address(IERC721A(BoomerangGenesis));                  // this is valid like following

        return address(BoomerangGenesis);

    }



    function _isUser(address _user) public view returns (bool) {        // for ETH network only

        return BoomerangGenesis.balanceOf(_user) > 0;

    }

}