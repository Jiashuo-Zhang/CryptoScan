// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.20;

import "@ERC721A/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@closedsea/OperatorFilterer.sol";

// Errors
error InvalidSaleState();
error InvalidSignature();
error AllowlistExceeded();
error WalletLimitExceeded();
error InvalidNewSupplyHigh();
error InvalidNewSupplyLow();
error SupplyExceeded();
error WithdrawFailed();
error URIQueryForNonexistentToken();
error CallerIsContract();

contract AICatgirl is OperatorFilterer, Ownable, ERC2981, ERC721A {
    using ECDSA for bytes32;

    enum SaleStates {
        CLOSED,
        ALLOWLIST,
        PUBLIC
    }

    uint256 public constant PUBLIC_MINTS_PER_WALLET = 2;
    uint256 public maxSupply = 1000;
    address public mintSigner;
    SaleStates public saleState;
    bool public operatorFilteringEnabled;
    string private _baseTokenURI = 'https://api.aicatgirl.wtf/metadata/';

    constructor(address _signer, address _royaltyReceiver)
        ERC721A("AI Catgirl", "AICatgirl")
    {
        mintSigner = _signer;
        
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;

        _setDefaultRoyalty(_royaltyReceiver, 600);
    }

    modifier callerIsUser() {
        if (tx.origin != msg.sender) revert CallerIsContract();
        _;
    }

    function setSaleState(SaleStates _saleState) external onlyOwner {
        saleState = _saleState;
    }

    function AllowlistMint(address to, uint8 qty, uint8 mintLimit, bytes calldata signature) external {
        if (saleState != SaleStates.ALLOWLIST) revert InvalidSaleState();
        if (_totalMinted() + qty > maxSupply) revert SupplyExceeded();

        // Validate signature
        bytes32 hashVal = keccak256(abi.encodePacked(msg.sender, mintLimit));
        bytes32 signedHash = hashVal.toEthSignedMessageHash();
        if (signedHash.recover(signature) != mintSigner) revert InvalidSignature();

        // Validate that user still has allowlist spots
        uint64 alMintCount = _getAux(msg.sender) + qty;
        if (alMintCount > mintLimit) revert AllowlistExceeded();

        _setAux(msg.sender, alMintCount);

        _mint(to, qty);
    }

    function publicMint(uint8 qty) external callerIsUser {
        if (saleState != SaleStates.PUBLIC) revert InvalidSaleState();
        if (_totalMinted() + qty > maxSupply) revert SupplyExceeded();

        // Determine number of public mints by substracting AL mints from total mints
        if (_numberMinted(msg.sender) - _getAux(msg.sender) + qty > PUBLIC_MINTS_PER_WALLET) {
            revert WalletLimitExceeded();
        }

        _mint(msg.sender, qty);
    }

    function ownerMint(address to, uint256 qty) external onlyOwner {
        if (_totalMinted() + qty > maxSupply) revert SupplyExceeded();
        _mint(to, qty);
    }

    function allowlistMintCount(address user) external view returns (uint64) {
        return _getAux(user);
    }

    function totalMintCount(address user) external view returns (uint256) {
        return _numberMinted(user);
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        if (_maxSupply >= maxSupply) revert InvalidNewSupplyHigh();
        if (_maxSupply < totalSupply()) revert InvalidNewSupplyLow();
        maxSupply = _maxSupply;
    }

    function setMintSigner(address _signer) external onlyOwner {
        mintSigner = _signer;
    }

    function testSignature(address to, uint8 mintLimit, bytes calldata signature) public view returns (bool) {
        // Validate signature
        bytes32 hashVal = keccak256(abi.encodePacked(to, mintLimit));
        bytes32 signedHash = hashVal.toEthSignedMessageHash();

        return (signedHash.recover(signature) == mintSigner);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : "";
    }
    
    function withdrawFunds() external onlyOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        if (!sent) {
            revert WithdrawFailed();
        }
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override(ERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        payable
        override(ERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId)
        public
        payable
        override(ERC721A)
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function setDefaultRoyalty(
        address payable receiver,
        uint96 numerator
    ) external onlyOwner {
        _setDefaultRoyalty(receiver, numerator);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, ERC2981) returns (bool) {
        return
            ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }
}