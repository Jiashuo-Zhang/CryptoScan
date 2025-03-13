// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./default_operator_contracts/DefaultOperatorFilterer.sol";
import "./Tag.sol";
import "./BBTag.sol";

/// @title Boring Brew
/// @author Atlas C.O.R.P.
contract BoringBrew is
    AccessControlEnumerable,
    ERC1155URIStorage,
    ERC1155Burnable,
    DefaultOperatorFilterer,
    Ownable
{
    bytes32 public constant MINTING_ROLE = keccak256("MINTING_ROLE");
    string public name = "Boring Brew";

    constructor(string memory _baseURI) ERC1155(_baseURI) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTING_ROLE, msg.sender);
    }

    /// @param _to address being minted to
    /// @param _ids collection ids as an array
    /// @param _amounts amounts of each collection id as an array
    function mintMultiple(
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts
    ) public onlyRole(MINTING_ROLE) {
        _mintBatch(_to, _ids, _amounts, "");
    }

    /// @param _to is the address being minted to
    /// @param _id is the desired id of the caller
    /// @param _amount is how many the caller is minting
    function mintSingle(
        address _to,
        uint256 _id,
        uint256 _amount
    ) public onlyRole(MINTING_ROLE) {
        _mint(_to, _id, _amount, "");
    }

    /// @param _tokenId is the collection ID
    /// @param _tokenURI is the new metadata URI
    function setURI(
        uint256 _tokenId,
        string memory _tokenURI
    ) external onlyOwner {
        _setURI(_tokenId, _tokenURI);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @notice to change the IPFS URI link
    /// @param _baseURI the new link
    function setBaseURI(string calldata _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }

    function uri(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(tokenId);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }
}