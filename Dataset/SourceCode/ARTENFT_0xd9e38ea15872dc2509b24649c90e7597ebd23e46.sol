//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract ARTENFT is ERC721URIStorage, Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public mintPrice;

    event Burn(address indexed _from, uint256 _tokenId);

    constructor() ERC721("ARTENFT", "AN") {}

    function mintToken(
        string memory tokenURI,
        uint256 price,
        address account,
        bool cbt
    ) public payable whenNotPaused returns (uint256) {
        mintPrice = price;

        require(msg.sender.balance > mintPrice, "Not enough ethers");
        require(msg.value == mintPrice, "Must be equal to the mintPrice");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        if (cbt) {
            _requireMinted(newItemId);
            transferToken(account, newItemId);
        }
        
        return newItemId;
    }

    function transferToken(address _to, uint256 _tokenId)
        public
        onlyOwner
        whenNotPaused
        returns (bool)
    {
        require(_exists(_tokenId), "Token does not exist");
        require(msg.sender == ownerOf(_tokenId), "Not the owner of this token");

        safeTransferFrom(msg.sender, _to, _tokenId);

        return true;
    }

    function withdraw() external payable onlyOwner {
        uint256 contractBalance = address(this).balance;

        require(contractBalance > 0, "Insufficient balance");
        payable(owner()).transfer(contractBalance);
    }

    function getCurrentTokenId() external view returns (uint256) {
        return _tokenIds.current();
    }

    function verifyHash(
        bytes32 _hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external pure returns (address signer) {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        );

        return ecrecover(messageDigest, v, r, s);
    }

    function setPaused(bool status) public onlyOwner {
        require(msg.sender == owner(), "You are not the owner");
        status ? _pause() : _unpause();
    }

    function burnToken(uint256 tokenId) external onlyOwner {
        require(msg.sender == owner(), "You are not the owner");

        _burn(tokenId);
        emit Burn(msg.sender, tokenId);
    }

    function checkExistTokenId(uint256 tokenId) external view returns (bool) {
        bool isExist = _exists(tokenId);
        return isExist;
    }

}