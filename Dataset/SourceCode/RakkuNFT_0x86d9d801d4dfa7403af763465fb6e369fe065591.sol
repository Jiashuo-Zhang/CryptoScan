// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract RakkuNFT is ERC1155, ERC1155Burnable, AccessControl, ERC1155Supply {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string public name = "Rakku Genesis NFT";
    string public symbol = "RPASS";
    string public baseURI = "ipfs://QmVNGDzBmjCic6oXEhaoPkKeCZg5SM3zFcwA4CN2aDjdf4/";

    constructor() ERC1155("ipfs://QmVNGDzBmjCic6oXEhaoPkKeCZg5SM3zFcwA4CN2aDjdf4/{id}.json") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        require(id > 0, "Invalid token Id");
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        require(ids.length > 0, "Empty token Id array");
        for (uint i=0; i<ids.length; i++) {
            require(ids[i] > 0, "Invalid token Id");
        }
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory _uri) public{
        baseURI = _uri;
    }

    function uri(uint256 _tokenId) override view public returns (string memory) {
        return string(
            abi.encodePacked(
                baseURI,
                Strings.toString(_tokenId),".json"
            )
        );
    }

    /**
    * @dev Returns an URI for a given token ID
    */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return uri(_tokenId);
    }
}