// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Cre8orsERC6551} from "../utils/Cre8orsERC6551.sol";
import {ICre8ors} from "../interfaces/ICre8ors.sol";
import {ICre8ing} from "../interfaces/ICre8ing.sol";
import {IERC721Drop} from "../interfaces/IERC721Drop.sol";
import {ISubscription} from "../subscription/interfaces/ISubscription.sol";
import {Admin} from "../subscription/abstracts/Admin.sol";
import {IERC6551Registry} from "lib/ERC6551/src/interfaces/IERC6551Registry.sol";

contract DNAMinter is Cre8orsERC6551, Admin {
    /// @notice Error event for attempting to mint a DNA Card that has already been minted.
    error DNAMinter_AlreadyMinted();

    /// @notice The address of the collection contract for Cre8ors.
    address public cre8orsNft;

    /// @notice The address of the collection contract for Cre8ors DNA cards.
    address public dnaNft;

    /// @notice Initializes the contract with the address of the Cre8orsNFT contract.
    /// @param _cre8orsNft The address of the Cre8ors contract to be used.
    /// @param _dnaNft The address of the Cre8ors DNA contract to be used.
    /// @param _registry The address of the ERC6551 registry contract to be used.
    /// @param _implementation The address of the ERC6551 implementation contract to be used.
    constructor(
        address _cre8orsNft,
        address _dnaNft,
        address _registry,
        address _implementation
    ) Cre8orsERC6551(_registry, _implementation) {
        cre8orsNft = _cre8orsNft;
        dnaNft = _dnaNft;
    }

    /// @notice Creates a Token Bound Account (TBA) and mints a DNA NFT.
    /// @param _cre8orsTokenId Token ID of the Cre8ors NFT for which DNA will be minted.
    /// @return _mintedDnaTokenId ID of the minted DNA token.
    function createTokenBoundAccountAndMintDNA(
        uint256 _cre8orsTokenId
    )
        public
        onlyFirstMint(_cre8orsTokenId)
        returns (uint256 _mintedDnaTokenId)
    {
        address[] memory airdropList = createTokenBoundAccounts(
            cre8orsNft,
            _cre8orsTokenId,
            1
        );
        _mintedDnaTokenId = ICre8ors(dnaNft).adminMint(airdropList[0], 1);
    }

    /// @notice Modifier to allow minting only if it is the first mint for the given Cre8ors token ID.
    /// @param _cre8orsTokenId Token ID to check for first minting.
    modifier onlyFirstMint(uint256 _cre8orsTokenId) {
        address tba = IERC6551Registry(erc6551Registry).account(
            erc6551AccountImplementation,
            block.chainid,
            cre8orsNft,
            _cre8orsTokenId,
            0
        );
        if (ICre8ors(dnaNft).mintedPerAddress(tba).totalMints > 0) {
            revert DNAMinter_AlreadyMinted();
        }

        _;
    }

    /// @notice Set the Cre8orsNFT contract address.
    /// @dev This function can only be called by an admin, identified by the
    ///     "cre8orsNFT" contract address.
    /// @param _dnaNft The new address of the DNA contract to be set.
    function setDnaNFT(address _dnaNft) public onlyAdmin(dnaNft) {
        dnaNft = _dnaNft;
    }

    /// @notice Set the ERC6551 registry address.
    /// @dev This function can only be called by an admin.
    /// @param _registry Address of the ERC6551 registry to be set.
    function setErc6551Registry(address _registry) public onlyAdmin(dnaNft) {
        erc6551Registry = _registry;
    }

    /// @notice Set the ERC6551 account implementation address.
    /// @dev This function can only be called by an admin.
    /// @param _implementation Address of the ERC6551 account implementation to be set.
    function setErc6551Implementation(
        address _implementation
    ) public onlyAdmin(dnaNft) {
        erc6551AccountImplementation = _implementation;
    }
}