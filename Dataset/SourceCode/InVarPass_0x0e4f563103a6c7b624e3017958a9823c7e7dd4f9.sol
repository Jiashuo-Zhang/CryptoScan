// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721Enumerable, ERC721} from "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Counters} from "openzeppelin-contracts/utils/Counters.sol";
import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {IPass} from "./IPass.sol";
import {IPassConstants} from "./IPassConstants.sol";

import {CantBeEvil, LicenseVersion} from "a16z-contracts/licenses/CantBeEvil.sol";

contract InVarPass is
    ERC721Enumerable,
    IPass,
    IPassConstants,
    Ownable,
    ReentrancyGuard,
    CantBeEvil
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    uint256 private _premiumTokenIds;

    Stage public currentStage;
    bool public isPremiumMint;

    Trees public trees;

    mapping(address => MintRecord) public mintRecords;

    string private _baseuri;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _premium,
        string memory _uri
    ) ERC721(_name, _symbol) CantBeEvil(LicenseVersion.PERSONAL_NO_HATE) {
        if (_premium < MAX_SUPPLY) revert WrongPremiumTokenIds();
        currentStage = Stage.Free;
        _premiumTokenIds = _premium;
        _baseuri = _uri;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, CantBeEvil)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     *  =================== Owner Operation ===================
     */

    function setSaleStage(Stage _stage) external onlyOwner {
        if (uint8(_stage) > uint8(Stage.Public)) revert InvalidStage();
        currentStage = _stage;
        emit UpdateSaleStage(currentStage);
    }

    function setPremiumMint(bool _isPremium) external onlyOwner {
        isPremiumMint = _isPremium;
        emit UpdatePremiumMint(isPremiumMint);
    }

    function setMerkleRoot(bytes32 _root, bytes32 _name) external onlyOwner {
        if (_name == FREE_MINT) {
            trees.freemintMerkleRoot = _root;
        }
        if (_name == WHITELIST) {
            trees.whitelistMerkleRoot = _root;
        }
        if (_name == TOKEN) {
            trees.tokenMerkleRoot = _root;
        }
        emit UpdateMerkleRoot(_name, _root);
    }

    function setBaseUri(string memory _uri) external onlyOwner {
        _baseuri = _uri;
        emit UpdateBaseUri(_uri);
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = payable(MULTISIG).call{value: address(this).balance}("");
        if (!success) revert EthersTransferErr();
    }

    /**
     * =================== Mint ===================
     */

    function freeMint(bytes32[] calldata _proof) external {
        bytes32 root = trees.freemintMerkleRoot;
        if (root == 0 || currentStage != Stage.Free) revert MintNotStart();
        // merkle proof
        // double-hashed value to meet oz/merkle-tree hashLeaf func
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender)))
        );
        if (!MerkleProof.verifyCalldata(_proof, root, leaf)) revert InvalidProof();
        if (mintRecords[msg.sender].freemintClaimed) revert AlreadyClaimed();
        // free mint
        uint256 tokenId = _generateTokenId();
        mintRecords[msg.sender].freemintClaimed = true;
        _safeMint(msg.sender, tokenId);

        emit Mint(msg.sender, Stage.Free, tokenId);
    }

    function whitelistMint(bytes32[] calldata _proof)
        external
        payable
        nonReentrant
    {
        bytes32 root = trees.whitelistMerkleRoot;
        if (root == 0 || currentStage != Stage.Whitelist) revert MintNotStart();
        // merkle proof
        // double-hashed value to meet oz/merkle-tree hashLeaf func
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender)))
        );
        if (!MerkleProof.verifyCalldata(_proof, root, leaf)) revert InvalidProof();
        if (mintRecords[msg.sender].whitelistClaimed) revert AlreadyClaimed();
        // whitelist mint
        uint256 tokenId = _generateTokenId();
        mintRecords[msg.sender].whitelistClaimed = true;
        _safeMint(msg.sender, tokenId);
        _refundIfOver(WHITELIST_PRICE);

        emit Mint(msg.sender, Stage.Whitelist, tokenId);
    }

    function publicMint(uint256 _quantity) external payable nonReentrant {
        if (currentStage != Stage.Public) revert MintNotStart();
        if (PUBLIC_MINT_QTY < mintRecords[msg.sender].publicMinted + _quantity) revert MintExceedsLimit();

        mintRecords[msg.sender].publicMinted += uint8(_quantity);

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = _generateTokenId();
            _safeMint(msg.sender, tokenId);
            emit Mint(msg.sender, Stage.Public, tokenId);
        }

        _refundIfOver(PUBLICSALE_PRICE * _quantity);
    }

    function premiumMint(
        bytes32[][] calldata _proofs,
        uint256[] calldata _tokens
    ) external {
        if (!isPremiumMint) revert MintNotStart();
        if (_proofs.length != _tokens.length) revert LengthMismatch();

        if (
            !(verifyToken(_proofs[0], _tokens[0], EARTH, msg.sender) &&
                verifyToken(_proofs[1], _tokens[1], OCEAN, msg.sender))
        ) revert InvalidProof();

        _burn(_tokens[0]);
        _burn(_tokens[1]);

        uint256 tokenId = _getPremiumTokenId();
        _safeMint(msg.sender, tokenId);

        emit Mint(msg.sender, Stage.Premium, tokenId);
    }

    function _refundIfOver(uint256 _price) private {
        if (msg.value < _price) revert InsufficientEthers();
        if (msg.value > _price) {
            unchecked {
                (bool success, ) = payable(msg.sender).call{value: msg.value - _price}("");
                if (!success) revert EthersTransferErr();
            }
        }
    }

    function currentTokenId() public view returns (uint256) {
        return _tokenIds.current();
    }

    function _generateTokenId() private returns (uint256) {
        _tokenIds.increment();
        uint256 tokenId = currentTokenId();
        if (tokenId >= MAX_SUPPLY) revert MintExceedsLimit();
        return tokenId;
    }

    function _getPremiumTokenId() private returns (uint256) {
        return ++_premiumTokenIds;
    }

    // for other services to verify the owner of token and the pass type
    function verifyToken(
        bytes32[] calldata _proof,
        uint256 _tokenId,
        bytes memory _type,
        address _owner
    ) public view returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(_tokenId, _type)))
        );
        return (MerkleProof.verifyCalldata(
            _proof,
            trees.tokenMerkleRoot,
            leaf
        ) && ownerOf(_tokenId) == _owner);
    }

    // override
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseuri;
    }
}