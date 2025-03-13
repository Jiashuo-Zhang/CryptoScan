// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Forge is Ownable, Pausable, ERC721, IERC1155Receiver {
    using Strings for uint256;

    address private immutable _bricktorigins;
    address private constant _dead = 0x000000000000000000000000000000000000dEaD;
    string private baseURI;
    uint256 private _index;
    uint256 constant private RANGE = 5;

    function bricktorigins() external view returns (address) {
        return _bricktorigins;
    }

    constructor(address bricktorigins_, string memory baseURI_) ERC721("BricktOrigins Monuments", "BMNT") {
        require(bricktorigins_ != address(0), "Invalid address");

        _bricktorigins = bricktorigins_;
        baseURI = baseURI_;
        _index = 1;
    }

    function burn(uint256 tokenId) external whenNotPaused () {
        require(ownerOf(tokenId) == _msgSender(), "burn: You don't own this NFT");

        _burn(tokenId);
        emit Burned(_msgSender(), tokenId);
    }

    function mint() external whenNotPaused() {
        require(_hasNFTs(_msgSender()), "mint: You don't have all the NFTs");

        for (uint i = 1; i <= RANGE; i++) {
            // Note magic number 1 is the amount of NFTs to transfer
            IERC1155(_bricktorigins).safeTransferFrom(_msgSender(), _dead, i, 1, "");
        }

        _safeMint(_msgSender(), _index);
        emit Minted(_msgSender(), _index);

        _index++;
    }

    function hasNFTs(address account) external view returns (bool) {
        return _hasNFTs(account);
    }

    function _hasNFTs(address account) private view returns (bool) {
        for (uint i = 1; i <= RANGE; i++) {
            if (IERC1155(_bricktorigins).balanceOf(account, i) < 1) {
                return false;
            }
        }

        return true;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    event Burned(address indexed owner, uint256 id);
    event Minted(address indexed owner, uint256 id);
}