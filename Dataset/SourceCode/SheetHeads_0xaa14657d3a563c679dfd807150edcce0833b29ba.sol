// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { IERC4906 } from "@openzeppelin/interfaces/IERC4906.sol";
import { Ownable } from "@openzeppelin/access/Ownable.sol";

/**
 *
 *     _____ _               _     _   _                _
 *    /  ___| |             | |   | | | |              | |
 *    \ `--.| |__   ___  ___| |_  | |_| | ___  __ _  __| |___
 *     `--. \ '_ \ / _ \/ _ \ __| |  _  |/ _ \/ _` |/ _` / __|
 *    /\__/ / | | |  __/  __/ |_  | | | |  __/ (_| | (_| \__ \
 *    \____/|_| |_|\___|\___|\__| \_| |_/\___|\__,_|\__,_|___/
 *
 *
 */

/// @title SheetHeads
contract SheetHeads is ERC721, IERC4906, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                       ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the number of SHEETs to mint is zero or overflows the collection size.
    error SheetHeads__InvalidMintAmount();

    /*//////////////////////////////////////////////////////////////////////////
                                      STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The total number of SHEETs in existence.
    uint256 public totalSupply;

    /// @dev The base URI of the collection.
    string private _baseURIVar;

    /// @notice The size of the collection.
    uint256 public immutable COLLECTION_SIZE;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param collectionSize_ The size of the collection.
    constructor(uint256 collectionSize_) ERC721("Sheet Heads", "SHEET") {
        COLLECTION_SIZE = collectionSize_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    // @dev See {IERC165-supportsInterface}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        // @dev see https://eips.ethereum.org/EIPS/eip-4906
        return interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                               NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Mint SHEETs.
    ///
    /// @param mintAmount The number of SHEETs to mint.
    function batchMint(address recipient, uint256 mintAmount) external onlyOwner {
        uint256 mTotalSupply = totalSupply;
        if (mTotalSupply + mintAmount > COLLECTION_SIZE || mintAmount == 0) {
            revert SheetHeads__InvalidMintAmount();
        }
        for (uint256 i = mTotalSupply; i < mTotalSupply + mintAmount;) {
            _mint(recipient, i);
            unchecked {
                ++i;
            }
        }
        unchecked {
            totalSupply += mintAmount;
        }
    }

    /// @notice Set base URI.
    ///
    /// @param newBaseURI The new base URI.
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseURIVar = newBaseURI;
        // @dev see {IERC4906}
        emit BatchMetadataUpdate(0, type(uint256).max);
    }

    /// @dev See {IERC721Metadata-tokenURI}.
    function _baseURI() internal view override returns (string memory) {
        return _baseURIVar;
    }
}