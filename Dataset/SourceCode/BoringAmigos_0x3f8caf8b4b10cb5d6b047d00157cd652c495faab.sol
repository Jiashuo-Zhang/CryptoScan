// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import {OperatorFilterer} from "./library/OperatorFilterer.sol";

contract BoringAmigos is ERC721, OperatorFilterer, Ownable, ERC2981, ReentrancyGuard {
    using Strings for uint256;

    error FailedRandomAttempt();
    event UintPropertyChange(string param, uint256 value);

    enum Stage {
        Init,
        Holder,
        Public
    }

    struct Holder {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    Stage public stage;
    bool public operatorFilteringEnabled;
    string public tokenURIPrefix;
    string public uriPrefix;
    string public uriSuffix;
    uint256 private nonce = 0;
    uint256 public price = 0.001 ether;
    uint256 public maxSupply = 20000;
    uint256 public normalFreeMint = 3;
    uint256 public maxMintAmountPerTx = 20;
    uint256 public mintedSupply = 0;
    uint256 public maxRandomAttempts = 20000;
    address private immutable _adminSigner;
    mapping(uint256 => bool) public mintedTokenIds;
    mapping(uint256 => bool) public noTokenIds;
    mapping(address => uint256) public holderMinted;
    mapping(address => uint256) public _mintedFreeAmount;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uriPrefix,
        uint96 feeBasis,
        uint256[] memory tokenIds,
        address adminSigner
    ) ERC721(_name, _symbol) {
        _adminSigner = adminSigner;
        uriPrefix = _uriPrefix;
        uriSuffix = ".json";
        stage = Stage.Holder;
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;
        _setDefaultRoyalty(_msgSender(), feeBasis);
        setNoTokenIds(tokenIds);
    }

    modifier mintCompliance(uint256 quantity) {
        require(
            quantity > 0 && quantity <= maxMintAmountPerTx,
            "Invalid mint amount!"
        );
        require(mintedSupply + quantity <= maxSupply, "Max supply exceeded!");
        _;
    }

    function totalSupply() public view virtual returns (uint256) {
        return mintedSupply;
    }

    function claim(
        address owner_,
        uint256[] calldata idxsToClaim,
        uint256[] calldata idsOfOwner,
        Holder memory holder
    ) external {
        require(stage == Stage.Holder, "Not in the holder mint stage!");
        bytes32 digest = keccak256(abi.encode(idsOfOwner, owner_));
        require(_isVerifiedHolder(digest, holder), "Invalid holder");

        for (uint256 i; i < idxsToClaim.length; i++) {
            uint256 tokenId = idsOfOwner[idxsToClaim[i]];
            if (!mintedTokenIds[tokenId]) {
                _mint(owner_, tokenId);
                mintedTokenIds[tokenId] = true;
                holderMinted[owner_]++;
                mintedSupply++;
            }
        }
    }

    function mint(uint256 quantity) public payable mintCompliance(quantity) {
        require(stage == Stage.Public, "Not in the public mint stage!");

        uint256 leftFree = normalFreeMint - _mintedFreeAmount[msg.sender];
        uint256 paid = quantity > leftFree ? quantity - leftFree : 0;
        uint256 free = quantity > leftFree ? leftFree : quantity;

        require(msg.value >= paid * price, "Insufficient funds!");
        _mintedFreeAmount[msg.sender] += free;

        _randomMint(msg.sender, quantity);
    }

    function setNoTokenIds(uint256[] memory tokenIds) public onlyOwner {
        for (uint256 i; i < tokenIds.length; ++i) {
            mintedTokenIds[tokenIds[i]] = true;
            noTokenIds[tokenIds[i]] = true;
            mintedSupply++;
        }
    }

    function setStage(Stage _stage) public onlyOwner {
        stage = _stage;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function _isVerifiedHolder(
        bytes32 digest,
        Holder memory holder
    ) internal view returns (bool) {
        address signer = ecrecover(digest, holder.v, holder.r, holder.s);
        require(signer != address(0), "ECDSA: invalid signature");
        return signer == _adminSigner;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            tokenId >= 0 && tokenId < maxSupply && !noTokenIds[tokenId],
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenId.toString(), uriSuffix)
                )
                : "";
    }

    function setMaxMintAmountPerTx(
        uint256 _maxMintAmountPerTx
    ) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC2981, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() public onlyOwner nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function _isPriorityOperator(
        address operator
    ) internal pure override returns (bool) {
        return operator == address(0x1E0049783F008A0085193E00003D00cd54003c71);
    }

    function setMaxRandomAttempts(uint256 value) external onlyOwner {
        maxRandomAttempts = value;
        emit UintPropertyChange("maxRandomAttempts", value);
    }

    function _randomMint(address to, uint256 quantity) private {
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _getRandomTokenId();
            _mint(to, tokenId);
            mintedTokenIds[tokenId] = true;
            mintedSupply++;
        }
    }

    function _getRandomTokenId() private returns (uint256) {
        uint256 random = uint256(
            keccak256(abi.encodePacked(nonce, msg.sender, block.timestamp))
        ) % maxSupply;
        nonce++;
        uint256 tokenId = random;
        uint256 attempts = 1;
        while (mintedTokenIds[tokenId]) {
            random =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            random,
                            nonce,
                            msg.sender,
                            block.timestamp
                        )
                    )
                ) %
                maxSupply;
            nonce++;
            tokenId = random;
            attempts++;
            if (attempts > maxRandomAttempts) {
                revert FailedRandomAttempt();
            }
        }
        return tokenId;
    }
}