// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/[email protected]/utils/cryptography/MerkleProof.sol";
import "https://github.com/ProjectOpenSea/operator-filter-registry/blob/main/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract THNFTees is
    ERC721A,
    Ownable,
    ReentrancyGuard,
    DefaultOperatorFilterer
{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 6000;
    uint256 public constant MAX_PUBLIC_MINTS_WALLET = 1;
    uint256 private TEAM_SUPPLY = 30;
    string public constant NAME = "THNFTees: Dorks";
    string public constant SYMBOL = "DORKS";
    string private baseURI;
    string public notRevealedURI;
    bool public revealed = false;
    bool private TEAM_MINTED = false;

    enum Stages {
        Deployed,
        Whitelist,
        Public,
        SoldOut
    }

    Stages public stages;

    mapping(address => uint256) public PublicMintClaimed;
    mapping(address => bool) public WhitelistMintClaimed;
    mapping(uint256 => bytes32) private Roots;

    constructor(string memory _notRevealedURI) ERC721A(NAME, SYMBOL) {
        notRevealedURI = _notRevealedURI;
        stages = Stages.Deployed;
        _safeMint(msg.sender, 1);
    }

    function WhitelistMint(uint256 amount, bytes32[] calldata _proof)
        external
        payable
        nonReentrant
    {
        require(stages == Stages.Whitelist, "Whitelist not started yet.");
        require(
            WhitelistMintClaimed[msg.sender] == false,
            "You can't mint more with wallet"
        );
        require(Roots[amount] != bytes32(0), "Not exist root.");
        require(
            isWhiteListed(
                _proof,
                Roots[amount],
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Not part of Whitelist"
        );

        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply exceeded");
        _safeMint(msg.sender, amount);
        WhitelistMintClaimed[msg.sender] = true;
    }

    function PublicMint(uint256 amount) external payable nonReentrant {
        require(stages == Stages.Public, "Public has not started yet.");
        require(amount > 0, "Require amount > 0");
        require(
            PublicMintClaimed[msg.sender] + amount <= MAX_PUBLIC_MINTS_WALLET,
            "Can't mint more NFTs with this wallet."
        );
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply exceeded");
        _safeMint(msg.sender, amount);
        PublicMintClaimed[msg.sender] += amount;
    }

    function addRoots(uint256[] memory _number, bytes32[] memory _root)
        external
        onlyOwner
    {
        require(
            _number.length == _root.length,
            "Not same length roots and number of them"
        );
        for (uint256 i = 0; i < _root.length; i++) {
            Roots[_number[i]] = _root[i];
        }
    }

    function isWhiteListed(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) public view virtual returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function setDeployedStage() external onlyOwner {
        stages = Stages.Deployed;
    }

    function setWhitelistMint() external onlyOwner {
        stages = Stages.Whitelist;
    }

    function setPublicMint() external onlyOwner {
        stages = Stages.Public;
    }

    function setSoldOutManually() external onlyOwner {
        stages = Stages.SoldOut;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseUri(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function reveal() external onlyOwner {
        revealed = true;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (!revealed) {
            return notRevealedURI;
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function teamMint() external onlyOwner {
        require(
            totalSupply() + TEAM_SUPPLY <= MAX_SUPPLY,
            "Max supply exceeded!"
        );
        require(TEAM_MINTED == false, "Team already minted.");
        _safeMint(msg.sender, TEAM_SUPPLY);
        TEAM_MINTED = true;
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}