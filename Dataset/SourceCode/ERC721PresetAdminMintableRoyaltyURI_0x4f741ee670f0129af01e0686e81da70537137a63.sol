// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../extensions/ERC721AdminMintableRoyalty.sol";

contract ERC721PresetAdminMintableRoyaltyURI is ERC721AdminMintableRoyalty {
    string internal _baseTokenURI;

    event SetBaseURI(string baseURI_);
    event Burn(uint256 tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        uint96 feeInBeeps,
        string memory baseURI_
    ) ERC721AdminMintableRoyalty(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(SIGNER_ERC721_ROLE, _msgSender());
        _setRoleAdmin(SIGNER_ERC721_ROLE, SIGNER_ERC721_ROLE);
        _setDefaultRoyalty(_msgSender(), feeInBeeps);
        _baseTokenURI = baseURI_;
    }

    /// @dev Set the base URI
    /// @param baseURI_ Base path to metadata

    function setBaseURI(string memory baseURI_) public onlySigner {
        _baseTokenURI = baseURI_;
        emit SetBaseURI(baseURI_);
    }

    /// @dev Get current base uri

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /// @dev Return the token URI. Included baseUri concatenated with tokenUri
    /// @param tokenId Id of ERC721 token

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721AdminMintableRoyalty)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner not approved"
        );
        _burn(tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721AdminMintableRoyalty)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721AdminMintableRoyalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}