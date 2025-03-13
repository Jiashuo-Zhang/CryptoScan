// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BitcoinPepe is
    ERC721,
    ERC721Enumerable,
    ERC721Royalty,
    ReentrancyGuard,
    Ownable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => MintRound) public mintRound;

    mapping(uint256 => uint256) public tokenUnlockTimestamp; // tokenID => unlockTimestamp
    mapping(address => uint256) public mintedCount; // address => mintedCountCount

    address public mintFeeReceiver;
    string public baseURI;

    uint256 public maxSupply;
    uint256 public maxMintPerAddress;
    uint256 public activeRoundIndex;
    uint256 public mintRoundCount;

    bool public mintActive;

    struct BaseMintRound {
        string name;
        bytes32 merkleRoot;
    }

    struct MintRound {
        string name;
        mapping(uint256 => MintPrice) mintPrice;
        uint256 mintPriceCount;
        bytes32 merkleRoot;
    }

    struct MintPrice {
        uint256 price;
        uint256 lockDuration;
    }

    function canMint(
        uint256 quantity,
        bytes32[] memory merkleProof
    ) public view {
        require(mintActive, "MINT_INACTIVE");
        require(totalSupply() <= maxSupply, "REACHED_MAX_SUPPLY");
        require(quantity > 0, "QUANTITY_LESS_THAN_ONE");
        require(
            totalSupply() + quantity <= maxSupply,
            "QUANTITY_EXCEEDED_MAX_SUPPLY"
        );
        require(
            mintedCount[msg.sender] + quantity <= maxMintPerAddress,
            "REACHED_MINT_CAP"
        );
        require(
            mintRound[activeRoundIndex].merkleRoot == bytes32(0) ||
                MerkleProof.verify(
                    merkleProof,
                    mintRound[activeRoundIndex].merkleRoot,
                    keccak256(abi.encodePacked(msg.sender))
                ),
            "INVALID_MERKLE_PROOF"
        );
    }

    constructor(
        uint256 _maxSupply,
        address _mintFeeReceiver,
        uint256 _maxMintPerAddress,
        string memory baseURI_
    ) ERC721("BitcoinPepe", "BTCPEP") {
        maxSupply = _maxSupply;
        mintFeeReceiver = _mintFeeReceiver;
        maxMintPerAddress = _maxMintPerAddress;
        baseURI = baseURI_;
    }

    // Minting

    function mint(
        uint256 quantity,
        uint256 mintPriceIndex,
        bytes32[] calldata merkleProof
    ) external payable nonReentrant {
        canMint(quantity, merkleProof);

        MintPrice memory mintPrice = mintRound[activeRoundIndex].mintPrice[
            mintPriceIndex
        ];

        require(
            mintRound[activeRoundIndex].mintPriceCount > 0,
            "INVALID_ROUND"
        );
        require(
            mintPrice.price != 0 || mintPrice.lockDuration != 0,
            "INVALID_PRICE"
        );
        uint256 fee = mintPrice.price * quantity;

        if (fee > 0) {
            _transferInETH(fee);
            _transferOutETH(mintFeeReceiver, fee);
        }

        for (uint256 i = 0; i < quantity; i++) {
            safeMint(msg.sender, mintPrice.lockDuration);
        }

        mintedCount[msg.sender] += quantity;
    }

    // Configurators

    function setMintFeeReceiver(address _mintFeeReceiver) external onlyOwner {
        mintFeeReceiver = _mintFeeReceiver;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function setMintRound(
        BaseMintRound[] memory baseMintRound,
        MintPrice[][] memory mintPrice
    ) external onlyOwner {
        require(
            baseMintRound.length == mintPrice.length,
            "INVALID_INPUT_LENGTH"
        );
        for (uint256 i = 0; i < mintRoundCount; i++) {
            delete mintRound[i];
        }

        for (uint256 i = 0; i < baseMintRound.length; i++) {
            mintRound[i].name = baseMintRound[i].name;
            mintRound[i].mintPriceCount = mintPrice[i].length;
            mintRound[i].merkleRoot = baseMintRound[i].merkleRoot;

            for (uint256 j = 0; j < mintPrice[i].length; j++) {
                mintRound[i].mintPrice[j] = mintPrice[i][j];
            }
        }

        mintRoundCount = baseMintRound.length;
    }

    function setMaxMintPerAddress(
        uint256 _maxMintPerAddress
    ) external onlyOwner {
        maxMintPerAddress = _maxMintPerAddress;
    }

    function setActiveRoundIndex(uint256 _activeRoundIndex) external onlyOwner {
        activeRoundIndex = _activeRoundIndex;
    }

    function setMintActive(bool _mintActive) external onlyOwner {
        mintActive = _mintActive;
    }

    function setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function resetTokenRoyalty(uint256 tokenId) external onlyOwner {
        _resetTokenRoyalty(tokenId);
    }

    // Helpers

    function getMintRoundPrice(
        uint256 mintRoundIndex
    ) external view returns (MintPrice[] memory) {
        MintPrice[] memory mintPrice = new MintPrice[](
            mintRound[mintRoundIndex].mintPriceCount
        );
        for (uint256 i = 0; i < mintRound[mintRoundIndex].mintPriceCount; i++) {
            mintPrice[i] = mintRound[mintRoundIndex].mintPrice[i];
        }
        return mintPrice;
    }

    function _transferInETH(uint256 amount) internal {
        require(msg.value >= amount, "INSUFFICIENT_ETH_RECEIVED");
    }

    function _transferOutETH(address receiver, uint256 amount) internal {
        require(amount > 0, "INVALID_AMOUNT");
        require(address(this).balance >= amount, "INSUFFICIENT_ETH_BALANCE");

        Address.sendValue(payable(receiver), amount);
    }

    function safeMint(address to, uint256 lockDuration) internal {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        tokenUnlockTimestamp[tokenId] = block.timestamp + lockDuration;
    }

    // Overrides

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        require(
            !_exists(tokenId) ||
                tokenUnlockTimestamp[tokenId] <= block.timestamp,
            "TOKEN_TRANSFER_LOCKED"
        );
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}