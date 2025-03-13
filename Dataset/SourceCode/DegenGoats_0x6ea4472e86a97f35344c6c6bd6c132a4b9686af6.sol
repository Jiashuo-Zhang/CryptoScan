// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "erc721a/contracts/ERC721A.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract DegenGoats is ERC721A, DefaultOperatorFilterer, Ownable, ReentrancyGuard {
    using Strings for uint256;

    bool public isWlActive = false;
    bool public isPublicActive = false;

    uint256 public wlPrice = 0.005 ether;
    uint256 public publicPrice = 0.009 ether;

    string private unrevealedUri;
    string private baseURI;
    bool public isRevealed = false;

    mapping(address => uint256) public wlClaimedList;
    uint256 public wlClaimedCount = 0;
    mapping(address => uint256) public publicClaimedList;
    uint256 public publicClaimedCount = 0;

    bytes32 public wlMerkleRoot;

    uint256 public constant WHITELIST_LIMIT_PER_WALLET = 3;
    uint256 public constant PUBLIC_LIMIT_PER_WALLET = 3;
    uint256 public MAX_SUPPLY = 5454;

    uint256 public WL_SUPPLY = 3000;
    uint256 public PUBLIC_SUPPLY = 2154;
    uint256 public constant OG_SUPPLY = 300;


    constructor(
        string memory _unrevealedUri
    ) ERC721A("DegenGoats", "DGG") {
        unrevealedUri = _unrevealedUri;
    }

    function whiteListMint(uint256 _quantity, bytes32[] calldata _merkleProof)
    external
    payable
    nonReentrant
    {
        require(isWlActive, "Whitelist Stage isn't enabled!");
        require(_quantity > 0, "Quantity must be more zero!");
        require(_quantity <= WHITELIST_LIMIT_PER_WALLET, "Quantity must be less max!");

        require(
            wlClaimedList[msg.sender] + _quantity <= WHITELIST_LIMIT_PER_WALLET,
            "You already minted max in Whitelist Stage!"
        );
        require(
            wlClaimedCount + _quantity <= WL_SUPPLY,
            "Already minted all tokens in Whitelist Stage!"
        );
        bytes32 sender = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, wlMerkleRoot, sender),
            "Invalid merkle proof!"
        );
        if (wlClaimedList[msg.sender] == 0) {
            require(msg.value == wlPrice * (_quantity - 1), "Invalid funds provided!");
        } else {
            require(msg.value == wlPrice * _quantity, "Invalid funds provided!");
        }

        _safeMint(msg.sender, _quantity);
        wlClaimedList[msg.sender] += _quantity;
        wlClaimedCount += _quantity;
    }

    function publicMint(uint256 _quantity) external payable nonReentrant {
        require(isPublicActive, "Public Stage isn't enabled!");
        require(_quantity > 0, "Quantity must be more zero!");
        require(_quantity <= PUBLIC_LIMIT_PER_WALLET, "Quantity must be less max!");
        require(msg.value == publicPrice * _quantity, "Invalid funds provided!");
        require(
            publicClaimedCount + _quantity <= PUBLIC_SUPPLY,
            "Already minted all tokens in Public Stage!"
        );
        require(
            publicClaimedList[msg.sender] + _quantity <=
            PUBLIC_LIMIT_PER_WALLET,
            "Already minted max in Public Stage!"
        );
        _safeMint(msg.sender, _quantity);
        publicClaimedList[msg.sender] += _quantity;
        publicClaimedCount += _quantity;
    }

    function cutMaxSupply(uint256 _value) external onlyOwner {
        MAX_SUPPLY = _value;
    }

    function cutWlSupply(uint256 _value) external onlyOwner {
        WL_SUPPLY = _value;
    }

    function cutPublicSupply(uint256 _value) external onlyOwner {
        PUBLIC_SUPPLY = _value;
    }

    function airdropOg(address[] calldata recipients)
    external
    onlyOwner
    {
        require(totalSupply() + recipients.length <= MAX_SUPPLY, "Exceed max supply!");
        for (uint256 i = 0; i < recipients.length;) {
            _mint(recipients[i], 1);
            unchecked {
                ++i;
            }
        }
    }

    function setIsWlActive(bool _value) external onlyOwner {
        isWlActive = _value;
    }

    function setIsPublicActive(bool _value) external onlyOwner {
        isPublicActive = _value;
    }

    function setWlPrice(uint256 _wlPrice) external onlyOwner {
        wlPrice = _wlPrice;
    }

    function setPublicPrice(uint256 _publicPrice) external onlyOwner {
        publicPrice = _publicPrice;
    }

    function setWlRoot(bytes32 _wlRoot) external onlyOwner {
        wlMerkleRoot = _wlRoot;
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function setUnrevealedUri(string memory _uri) external onlyOwner {
        unrevealedUri = _uri;
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success,) = payable(owner()).call{value : address(this).balance}(
            ""
        );
        require(success, "Withdraw failed!");
    }

    function reveal() external onlyOwner {
        isRevealed = true;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        if (isRevealed) {
            return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json"));
        }
        return unrevealedUri;
    }

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }
    function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
    public
    payable
    override
    onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}