// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;



import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "operator-filter-registry/src/DefaultOperatorFilterer.sol";



contract PABCNewEra is

    ERC721,

    Pausable,

    Ownable,

    ERC721Burnable,

    DefaultOperatorFilterer,

    ReentrancyGuard

{

    using Strings for uint256;

    address public vault;

    uint256 public constant BLUE_OFFSET = 100000;

    uint256 public constant GREEN_OFFSET = 200000;

    uint256 public constant PINK_OFFSET = 300000;

    uint256 public constant RED_OFFSET = 400000;

    uint256 public constant GOLD_OFFSET = 500000;

    string public uriPrefix = "";

    string public uriSuffix = ".json";

    IERC721 public oldPABC;

    bool public mintPaused = false;

    uint256 public maxMintAmountPerTx = 20;



    constructor(

        address _oldPABC,

        address _vault

    ) ERC721("Party Ape Billionaire Club New Era", "PABC") {

        oldPABC = IERC721(_oldPABC);

        vault = _vault;

    }



    modifier mintCompliance(uint256 _mintAmount) {

        require(!mintPaused, "The mint is paused!");

        require(

            _mintAmount > 0 && _mintAmount <= maxMintAmountPerTx,

            "Invalid mint amount!"

        );

        _;

    }



    function pause() public onlyOwner {

        _pause();

    }



    function unpause() public onlyOwner {

        _unpause();

    }



    function transferApesToVault(uint256[] calldata ids) private {

        require(

            oldPABC.isApprovedForAll(msg.sender, address(this)),

            "Must set approval for the old PABC collection"

        );



        for (uint256 i = 0; i < ids.length; i++) {

            oldPABC.safeTransferFrom(msg.sender, vault, ids[i]);

        }

    }



    function safeMint(address to, uint256 tokenId) public onlyOwner {

        _safeMint(to, tokenId);

    }



    function mintFor(address to, uint256[] calldata ids) public onlyOwner {

        for (uint256 i = 0; i < ids.length; i++) {

            require(

                !_exists(ids[i]) &&

                    !_exists(ids[i] + BLUE_OFFSET) &&

                    !_exists(ids[i] + GREEN_OFFSET) &&

                    !_exists(ids[i] + PINK_OFFSET) &&

                    !_exists(ids[i] + RED_OFFSET) &&

                    !_exists(ids[i] + GOLD_OFFSET),

                "Token already exists or has been morphed"

            );

            _safeMint(to, ids[i]);

        }

    }



    function standardMint(

        uint256[] calldata ids

    ) external mintCompliance(ids.length) {

        for (uint256 i = 0; i < ids.length; i++) {

            require(

                oldPABC.ownerOf(ids[i]) == msg.sender,

                "Not owner of the NFT"

            );

            require(

                !_exists(ids[i]) &&

                    !_exists(ids[i] + BLUE_OFFSET) &&

                    !_exists(ids[i] + GREEN_OFFSET) &&

                    !_exists(ids[i] + PINK_OFFSET) &&

                    !_exists(ids[i] + RED_OFFSET) &&

                    !_exists(ids[i] + GOLD_OFFSET),

                "Token already exists or has been morphed"

            );

        }



        transferApesToVault(ids);



        for (uint256 i = 0; i < ids.length; i++) {

            _safeMint(msg.sender, ids[i]);

        }

    }



    function neonMint(

        uint256[] calldata ids,

        uint8 colorNumber

    ) external payable mintCompliance(ids.length) {

        require(msg.value >= 0.003 ether * ids.length, "Insufficient payment");



        uint256 colorOffset;

        if (colorNumber == 1) colorOffset = BLUE_OFFSET;

        else if (colorNumber == 2) colorOffset = GREEN_OFFSET;

        else if (colorNumber == 3) colorOffset = PINK_OFFSET;

        else if (colorNumber == 4) colorOffset = RED_OFFSET;

        else revert("Invalid color!");



        for (uint256 i = 0; i < ids.length; i++) {

            require(

                oldPABC.ownerOf(ids[i]) == msg.sender,

                "Not owner of the NFT"

            );

            require(

                !_exists(ids[i]) &&

                    !_exists(ids[i] + BLUE_OFFSET) &&

                    !_exists(ids[i] + GREEN_OFFSET) &&

                    !_exists(ids[i] + PINK_OFFSET) &&

                    !_exists(ids[i] + RED_OFFSET) &&

                    !_exists(ids[i] + GOLD_OFFSET),

                "Token already exists or has been morphed"

            );

        }



        transferApesToVault(ids);



        for (uint256 i = 0; i < ids.length; i++) {

            _safeMint(msg.sender, ids[i] + colorOffset);

        }

    }



    function goldMint(

        uint256[] calldata ids

    ) external payable mintCompliance(ids.length) {

        require(msg.value >= 0.006 ether * ids.length, "Insufficient payment");



        for (uint256 i = 0; i < ids.length; i++) {

            require(

                oldPABC.ownerOf(ids[i]) == msg.sender,

                "Not owner of the NFT"

            );

            require(

                !_exists(ids[i]) &&

                    !_exists(ids[i] + BLUE_OFFSET) &&

                    !_exists(ids[i] + GREEN_OFFSET) &&

                    !_exists(ids[i] + PINK_OFFSET) &&

                    !_exists(ids[i] + RED_OFFSET) &&

                    !_exists(ids[i] + GOLD_OFFSET),

                "Token already exists or has been morphed"

            );

        }



        transferApesToVault(ids);



        for (uint256 i = 0; i < ids.length; i++) {

            _safeMint(msg.sender, ids[i] + GOLD_OFFSET);

        }

    }



    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 tokenId,

        uint256 batchSize

    ) internal override whenNotPaused {

        super._beforeTokenTransfer(from, to, tokenId, batchSize);

    }



    function tokenURI(

        uint256 _tokenId

    ) public view virtual override returns (string memory) {

        require(

            _exists(_tokenId),

            "ERC721Metadata: URI query for nonexistent token"

        );



        string memory currentBaseURI = _baseURI();

        return

            bytes(currentBaseURI).length > 0

                ? string(

                    abi.encodePacked(

                        currentBaseURI,

                        _tokenId.toString(),

                        uriSuffix

                    )

                )

                : "";

    }



    function setMaxMintAmountPerTx(

        uint256 _maxMintAmountPerTx

    ) external onlyOwner {

        maxMintAmountPerTx = _maxMintAmountPerTx;

    }



    function setMintPaused(bool _state) external onlyOwner {

        mintPaused = _state;

    }



    function setUriPrefix(string memory _uriPrefix) public onlyOwner {

        uriPrefix = _uriPrefix;

    }



    function setUriSuffix(string memory _uriSuffix) public onlyOwner {

        uriSuffix = _uriSuffix;

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return uriPrefix;

    }



    function setApprovalForAll(

        address operator,

        bool approved

    ) public override onlyAllowedOperatorApproval(operator) {

        super.setApprovalForAll(operator, approved);

    }



    function approve(

        address operator,

        uint256 tokenId

    ) public override onlyAllowedOperatorApproval(operator) {

        super.approve(operator, tokenId);

    }



    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    function withdraw() external onlyOwner nonReentrant {

        (bool success, ) = payable(msg.sender).call{

            value: address(this).balance

        }("");

        require(success, "Failed to send Ether");

    }

}