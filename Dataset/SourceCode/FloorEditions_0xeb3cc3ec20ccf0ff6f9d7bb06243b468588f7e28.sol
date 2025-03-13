// SPDX-License-Identifier: UNLICENSED

// ███╗   ███╗ █████╗ ██████╗ ███████╗   ██╗    ██╗██╗████████╗██╗  ██╗   ███╗   ███╗ █████╗ ███████╗ ██████╗ ███╗   ██╗
// ████╗ ████║██╔══██╗██╔══██╗██╔════╝   ██║    ██║██║╚══██╔══╝██║  ██║   ████╗ ████║██╔══██╗██╔════╝██╔═══██╗████╗  ██║
// ██╔████╔██║███████║██║  ██║█████╗     ██║ █╗ ██║██║   ██║   ███████║   ██╔████╔██║███████║███████╗██║   ██║██╔██╗ ██║
// ██║╚██╔╝██║██╔══██║██║  ██║██╔══╝     ██║███╗██║██║   ██║   ██╔══██║   ██║╚██╔╝██║██╔══██║╚════██║██║   ██║██║╚██╗██║
// ██║ ╚═╝ ██║██║  ██║██████╔╝███████╗   ╚███╔███╔╝██║   ██║   ██║  ██║   ██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝██║ ╚████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚══╝╚══╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝

pragma solidity ^0.8.17;

import "./mason/utils/Administrable.sol";
import "./mason/utils/Ownable.sol";
import "./mason/utils/ECDSA.sol";
import "erc721a/contracts/ERC721A.sol";
import {Base64} from "./Base64.sol";
import {Utils} from "./Utils.sol";

error ContractLocked();
error ExceedsMaxPerWallet();
error InvalidSignature();
error WhitelistNotEnabled();
error AlreadyMintedMoreThanMaxSupply();
error ExceedsMaxSupply();
error URIQueryForNonexistentToken();

contract FloorEditions is ERC721A, Ownable, Administrable {
    using ECDSA for bytes32;

    mapping(uint256 => uint256) tokenArt;
    mapping(uint256 => uint256) numberMinted;
    mapping(uint256 => uint256) maxSupply;
    mapping(address => mapping(uint256 => uint256)) editionsMinted;

    address signingKey = address(0);

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant MINTER_TYPEHASH =
        keccak256("Minter(address wallet,uint256 count)");

    uint256 public MAX_PER_WALLET = 1;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _customBaseURI
    ) ERC721A(_tokenName, _tokenSymbol) {
        customBaseURI = _customBaseURI;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("DiscountToken")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    // ------ AIRDROPS ----------------------------------------------------------

    function airdrop(
        uint64 _quantity,
        address _recipient,
        uint256 _edition
    ) external onlyOperatorsAndOwner {
        if (numberMinted[_edition] + _quantity > maxSupply[_edition])
            revert ExceedsMaxSupply();

        uint256 nextTokenId = _nextTokenId();

        _mint(_recipient, _quantity);

        for (uint256 i; i < _quantity; ) {
            tokenArt[nextTokenId + i] = _edition;

            unchecked {
                ++i;
            }
        }

        editionsMinted[msg.sender][_edition] += _quantity;
        numberMinted[_edition] += _quantity;
    }

    // ------ MINTS ----------------------------------------------------------

    function mint(
        uint256 _edition,
        bytes calldata _signature
    )
        external
        payable
        requiresWhitelist(_signature, _edition)
        requireActiveWhitelist
    {
        uint256 newNumberMinted = numberMinted[_edition] + 1;
        if (newNumberMinted > maxSupply[_edition]) revert ExceedsMaxSupply();

        uint256 newEditionsMinted = editionsMinted[msg.sender][_edition] + 1;
        if (newEditionsMinted > MAX_PER_WALLET) revert ExceedsMaxPerWallet();

        uint256 tokenId = _nextTokenId();
        _mint(msg.sender, 1);

        tokenArt[tokenId] = _edition;
        numberMinted[_edition] = newNumberMinted;
        editionsMinted[msg.sender][_edition] = newEditionsMinted;
    }

    // ----- ALLOWLIST ---------------------------------------------------------

    function checkWhitelist(
        uint256 _edition,
        bytes calldata _signature
    ) external view requiresWhitelist(_signature, _edition) returns (bool) {
        return true;
    }

    function allowedMintCount(
        address _minter,
        uint256 _edition
    ) external view returns (uint256) {
        return MAX_PER_WALLET - editionsMinted[_minter][_edition];
    }

    function maxSupplyForEdition(
        uint256 _edition
    ) external view returns (uint256) {
        return maxSupply[_edition];
    }

    function remainingSupplyForEdition(
        uint256 _edition
    ) external view returns (uint256) {
        return maxSupply[_edition] - numberMinted[_edition];
    }

    // ------ ADMIN -------------------------------------------------------------

    function setMaxSupplyForEdition(
        uint256 _edition,
        uint256 _maxSupply
    ) external onlyOperatorsAndOwner {
        if (numberMinted[_edition] > _maxSupply)
            revert AlreadyMintedMoreThanMaxSupply();

        maxSupply[_edition] = _maxSupply;
    }

    function setMaxPerWallet(
        uint64 _maxPerWallet
    ) external onlyOperatorsAndOwner {
        MAX_PER_WALLET = _maxPerWallet;
    }

    function setSigningAddress(
        address newSigningKey
    ) public onlyOperatorsAndOwner {
        signingKey = newSigningKey;
    }

    // ------ MODIFIERS ---------------------------------------------------------

    modifier requiresWhitelist(bytes calldata signature, uint256 value) {
        if (signingKey == address(0)) revert WhitelistNotEnabled();

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(MINTER_TYPEHASH, msg.sender, value))
            )
        );

        address recoveredAddress = digest.recover(signature);
        if (recoveredAddress != signingKey) revert InvalidSignature();
        _;
    }

    // ------ TOKEN METADATA ----------------------------------------------------

    string private customBaseURI;

    function baseTokenURI() public view returns (string memory) {
        return customBaseURI;
    }

    function setBaseURI(
        string calldata _customBaseURI
    ) external onlyOperatorsAndOwner {
        customBaseURI = _customBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return customBaseURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return
            string(abi.encodePacked(_baseURI(), _toString(tokenArt[tokenId])));
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, AccessControlEnumerable) returns (bool) {
        return
            ERC721A.supportsInterface(interfaceId) ||
            AccessControlEnumerable.supportsInterface(interfaceId);
    }
}