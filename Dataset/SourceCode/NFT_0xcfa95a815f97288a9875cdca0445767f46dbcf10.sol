// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "erc721a/contracts/ERC721A.sol";

import {DefaultOperatorFilterer} from "./ofr/DefaultOperatorFilterer.sol";



contract NFT is ERC721A, Ownable, DefaultOperatorFilterer  {

    string public constant uriSuffix = '.json';

    string private baseUri = "ipfs://bafybeieeoixmpt4dfyeirpuornnvitoqww2im5aov5sjsav4mhdgjfsdte/";

    uint256 public immutable max_supply = 777;

    bool public publicSaleEnabled = true;

    uint256 public publicSalePrice = 0.0077 ether;

    uint256 public amountMintPerAccount = 15;

    

    event MintSuccessful(address user);



    constructor() ERC721A("Mystery", "?") {

        airdrop(msg.sender, 1);

    }

    

    function _startTokenId() internal view override returns (uint256) {

        return 1;

    }



    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {

        require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');



        string memory currentBaseURI = _baseURI();

        return bytes(currentBaseURI).length > 0

            ? string(abi.encodePacked(currentBaseURI, Strings.toString(_tokenId), uriSuffix))

            : '';

    }



    function mint(uint256 quantity) external payable {

        require(publicSaleEnabled, 'Minting is not enabled');

        require(totalSupply() + quantity <= max_supply, 'Cannot mint more than max supply');

        require(msg.value >= publicSalePrice * quantity, "Not enough ETH sent; check price!");

        require(balanceOf(msg.sender) + quantity <= amountMintPerAccount, 'Each address may only mint x NFTs!');



        _mint(msg.sender, quantity);

        

        emit MintSuccessful(msg.sender);

    }



    function _baseURI() internal view override returns (string memory) {

        return baseUri;

    }



    function setPublicSaleEnabled(bool _state) public onlyOwner {

        publicSaleEnabled = _state;

    }



    function setAmountMintPerAccount(uint _amountMintPerAccount) public onlyOwner {

        amountMintPerAccount = _amountMintPerAccount;

    }



    function setPublicSalePrice(uint _price) public onlyOwner {

        publicSalePrice = _price;

    }



    function setBaseURI(string memory _URI) external onlyOwner {

        baseUri = _URI;

    }



    function withdraw() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);

    }



    function withdrawAll() external onlyOwner {

        require(payable(msg.sender).send(address(this).balance));

    }



    function airdrop(address _user, uint256 _quantity) public onlyOwner {

        require(totalSupply() + _quantity <= max_supply, "Can't mint more than total supply");

        _mint(_user, _quantity);

    }



    function transferFrom(address from, address to, uint256 tokenId) public override payable onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId) public override payable onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)

        public

        override

        payable

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId, data);

    }

}