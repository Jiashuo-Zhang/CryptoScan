// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721, ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract Graffiti is ERC721URIStorage, Ownable {
    using Strings for uint256;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    /**
     * @notice Constructor
     */
    constructor()
        ERC721("NMB Ethereum Argentina 23 Graffitis", "NMB23")
    {}

    /**
     * @notice "Mint" graffiti token to a given address using its tokenUri.
     */
    function paint(address to, string memory tokenUri) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < 23, 'Ran out of paint');
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenUri);
    }

    /**
     * @notice Remove graffiti token from wallet by burning it.
     */
    function remove(uint256 tokenId) external {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only the owner can remove graffiti"
        );
        _burn(tokenId);
    }

    /**
     * @notice Get contract-level information, formatted as a dataURI containing a
     *      JSON object with the contract name, author, description, and
     *      collection image.
     */
    function contractURI() external pure returns (string memory) {
        return
            string.concat(
                "data:application/json;utf8,",
                "{",
                '"name": "NMB Ethereum Argentina 23 Graffitis",',
                '"author": "just-buidl-it",',
                '"description":',
                unicode'"Para celebrar eth arg 2023 y la creación de la colección nfts “23 días sin lavarme” Las moscas ensuciaron 23 billeteras participantes de la conferencia. NMB <> 238",',
                '"image": "ipfs://bafkreigchobeba3jwjwayofoasrk7iirsloryqbjtunrrwuecfh4dfozc4",',
                '"external_link": "https://opensea.io/es/collection/moskas-238"'
                "}"
            );
    }

    /**
     * @notice Prevent the transfer of token because graffiti can only be removed.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal pure override {
        require(
            from == address(0) || to == address(0),
            "Graffiti is non-transferrable"
        );
    }
}