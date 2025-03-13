// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;



import "./ERC721.sol";

import "./DefaultOperatorFilterer.sol";

import "./Context.sol";

import "./Ownable.sol";



contract NFT is ERC721, Ownable, DefaultOperatorFilterer {

    using Strings for uint256;



    uint public constant MAX_TOKENS = 15000;



    uint256 public whitelistPrice = 22 * 10**15;

    uint256 public rafflePrice = 27 *10**15;

    uint256 public publicPrice = 29 * 10**15;

    uint256 public constant MAX_MINT_PER_TX = 5;





    uint256 public maxMelianID = 4888;

    uint256 public maxSabarianID = 9776;

    uint256 public maxRangarkID = 14664;





    bool public isWhitelist = false;

    bool public isRaffle = false;

    bool public isPublic = false;



    mapping(address => bool) private _iswhitelist;

    mapping(address => bool) private _israffle;



    uint256 public totalSupply;



    string public baseUri;

    string public baseExtension = ".json";



    uint256 private currentCap = 0;



    address private _devWallet = 0xfdD120ed376F9c7CE805a75bdc92b8f4609F1F38;



    address private _sellContract = 0x62BC670611bD4bdd4414334153B93807e1077dbF;



    constructor() ERC721("Valarok", "VALAROK") {

        baseUri = "https://bafybeialnm3yx3dgechabp4b2obucqavfixuiclejbbt6laglhzsn4mrbq.ipfs.nftstorage.link/";

    }

    // Public Functions

    function mint(uint256 _numTokens) external payable {

        uint256 curTotalSupply = totalSupply;

        require(curTotalSupply + _numTokens <= MAX_TOKENS, "Exceeds total supply.");



        if(_msgSender() != owner()){

            require(_numTokens <= MAX_MINT_PER_TX, "You cannot mint that many in one transaction.");

            uint256 price = _checkSellingPhase(_msgSender());

            require(_numTokens * price <= msg.value, "Insufficient funds.");

            require(currentCap - curTotalSupply >= _numTokens, "The amount exceeds maximum availability for the ongoing phase!");

        }



        for(uint256 i = 1; i <= _numTokens; ++i){

            _safeMint(msg.sender, curTotalSupply + i);

        }

        totalSupply += _numTokens;

    }



    function _checkSellingPhase(address _buyer) internal view returns (uint256) {

        uint256 price = 0;

        if(isWhitelist) {

            require(_iswhitelist[_buyer], "Your wallet address is not included into the Whitelist");

            price = whitelistPrice;

        } else if(isRaffle) {

            require(_israffle[_buyer], "Your wallet address is not included into the Raffle");

            price = rafflePrice;

        } else {

            price = publicPrice;

        }

        return price;

    }



    // OnlyOwner Functions



    function setSellingContract (address _address) external onlyOwner {

        _sellContract = _address;

    }



    function updateDevWallet (address _address) external onlyOwner {

        _devWallet = _address;

    }



    function addToWhitelist(address _address) external onlyOwner {

        _iswhitelist[_address] = true;

    }



    function addToRaffle(address _address) external onlyOwner {

        _israffle[_address] = true;

    }



    function enableWhitelist() external onlyOwner {

        isWhitelist = true;

    }



    function enableRaffle() external onlyOwner {

        isWhitelist = false;

        isRaffle = true;

    }



    function enablePublicSale() external onlyOwner{

        isWhitelist = false;

        isRaffle = false;

        isPublic = true;

    }



    function enableMelian() external onlyOwner {

        currentCap = maxMelianID;

    }



    function enableSabarian() external onlyOwner {

        require(totalSupply == maxMelianID, "Non puoi attivarla adesso, finisci di mintare i Melian prima!");

        currentCap = maxSabarianID;

    }



    function enableRangark() external onlyOwner {

        require(totalSupply == maxSabarianID, "Non puoi attivarla adesso, finisci di mintare i Sabarian prima!");

        currentCap = maxRangarkID;

    }



    function setBaseUri(string memory _baseUri) external onlyOwner {

        baseUri = _baseUri;

    }



    function setWhitelistPrice(uint256 _price, uint256 _decimals) external onlyOwner {

        whitelistPrice = _price * 10**_decimals;

    }



    function setRafflePrice(uint256 _price, uint256 _decimals) external onlyOwner {

        rafflePrice = _price * 10**_decimals;

    }



    function setPublicPrice(uint256 _price, uint256 _decimals) external onlyOwner {

        publicPrice = _price * 10**_decimals;

    }



    function withdrawAll() external payable onlyOwner {

        uint256 balance = address(this).balance;

        require(payable(_devWallet).send(balance), "Transfer failed.");

}





	

	function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)

        public

        override

        onlyAllowedOperator

    {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    



    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

 

        string memory currentBaseURI = _baseURI();

        return bytes(currentBaseURI).length > 0

            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))

            : "";

    }

 

    function _baseURI() internal view virtual override returns (string memory) {

        return baseUri;

    }

}