// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/// Openzeppelin imports

/// Local includes
import './BaseERC721Burnable.sol';
import './BaseERC721Mintable.sol';
import './BaseERC721Pausable.sol';
import '../Blacklist.sol';


contract BERC721TokenBMP is BaseERC721Pausable, BaseERC721Mintable, BaseERC721Burnable, Blacklist {


    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        bool updatable_,
        bool transferable_,
        uint256 cap_)
            BaseERC721Mintable(name_, symbol_, baseURI_, updatable_, transferable_, cap_)
            BaseERC721Burnable()
            BaseERC721Pausable() {

    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, BaseERC721) {

        BaseERC721._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, BaseERC721)
        returns (string memory) {

        return BaseERC721.tokenURI(tokenId);
    }

    function _baseURI() internal view virtual override(BaseERC721, ERC721) returns (string memory) {
        return BaseERC721._baseURI();
    }

    function supportsInterface(bytes4 interfaceId)
        public view virtual override(BaseERC721, BaseERC721Pausable, ERC721, Blacklist) returns (bool) {

        return BaseERC721.supportsInterface(interfaceId)
                || BaseERC721Pausable.supportsInterface(interfaceId)
                || Blacklist.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override(ERC721, BaseERC721, ERC721Pausable) {

        require(! isInBlacklist(_msgSender()), 'operator blacklisted');
        ERC721Pausable._beforeTokenTransfer(from, to, amount);
        BaseERC721._beforeTokenTransfer(from, to, amount);
    }

    // Gets type of token
    function getType() pure public virtual returns (
                bool burnable,
                bool mintable,
                bool pausable) {

        burnable = true;
        mintable = true;
        pausable = true;
    }
}