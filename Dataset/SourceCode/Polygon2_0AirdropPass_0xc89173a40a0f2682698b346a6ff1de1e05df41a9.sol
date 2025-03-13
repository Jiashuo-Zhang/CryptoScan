// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "@openzeppelin/contracts/utils/Strings.sol";



contract Polygon2_0AirdropPass is ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply {



    string public name = "Polygon 2.0 Matic Airdrop";

    string public symbol = "https://maticdrops.com";

 

    constructor()

        ERC1155("https://ipfs.io/ipfs/QmWrh5iWPBcdbr5pmfARdEiKMuhZxAeDtq9ygwUCKKG2aK/{id}.json")

    {}



    function uri(uint256 _tokenid) override public pure returns (string memory) {

        return string(

            abi.encodePacked(

                "https://ipfs.io/ipfs/QmWrh5iWPBcdbr5pmfARdEiKMuhZxAeDtq9ygwUCKKG2aK/",

                Strings.toString(_tokenid),".json"

            )

        );

    }



    function contractURI() public pure returns(string memory) {

        return "https://ipfs.io/ipfs/QmWrh5iWPBcdbr5pmfARdEiKMuhZxAeDtq9ygwUCKKG2aK/collection.json";

    }



    function setURI(string memory newuri) public onlyOwner {

        _setURI(newuri);

    }



    function pause() public onlyOwner {

        _pause();

    }



    function unpause() public onlyOwner {

        _unpause();

    }



    function mint(address account, uint256 id, uint256 amount)

        public

        onlyOwner

    {

        _mint(account, id, amount, "");

    }



    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts)

        public

        onlyOwner

    {

        _mintBatch(to, ids, amounts, "");

    }



    function airdropToken(uint256 tokenId, address[] calldata recipients) external onlyOwner {

        for (uint i = 0; i < recipients.length; i++) {

            _safeTransferFrom(msg.sender, recipients[i], tokenId, 1, "");

        }

    }



    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)

        internal

        whenNotPaused

        override(ERC1155, ERC1155Supply)

    {

        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(msg.sender == owner() || to == address(0), "Token cannot be transfered. Can only be Burned");

    }

}