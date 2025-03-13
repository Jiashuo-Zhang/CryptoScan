// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC721A, ERC721A} from "erc721a/contracts/ERC721A.sol";
import {ERC721AQueryable} from "erc721a/contracts/extensions/ERC721AQueryable.sol";
import {ERC721ABurnable} from "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "closedsea/src/OperatorFilterer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AIGrifters is 
    ERC721AQueryable,
    ERC721ABurnable, 
    OperatorFilterer, 
    Ownable, 
    ERC2981 {

    string  private _baseTokenURI;
    uint256 public constant MAX_SUPPLY = 666;
    bool    public operatorFilteringEnabled;
    bool    public publicMintActive;
    bytes32 public merkleRoot;
    uint256 public walletMintLimit = 3;
    uint256 public transactionLimit = 1;
    uint256 public allowListPhase = 0;
    mapping(address => uint256) public mintTracker;

    constructor() ERC721A("AI Grifters", "GRIFT") {
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;
        _setDefaultRoyalty(0x70DE3D7ca8A1b2D69be60234bc634B6a7fE1b9Ff, 690);
    }

    function mint(uint256 quantity) public {
        require(publicMintActive, "Mint not active");
        require(quantity <= transactionLimit, "Over transaction limit");
        mintTracker[msg.sender] += quantity;
        require(mintTracker[msg.sender] <= walletMintLimit, "This wallet has reached its minting limit.");
        _mintTokens(msg.sender, quantity);
    }

    function allowListMint(uint256 quantity, uint256 phase, bytes32[] calldata proof) public {
        require(MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(msg.sender, quantity, phase))), "Invalid proof");
        require(phase <= allowListPhase, "You are not eligible to mint yet.");
        uint256 mintAmount = quantity - mintTracker[msg.sender];
        require(mintAmount > 0, "You cannot mint anymore tokens with this wallet");
        mintTracker[msg.sender] += mintAmount;
        _mintTokens(msg.sender, mintAmount);
    }

    function _mintTokens(address account, uint quantity) internal {
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Exceeds Supply");
        _mint(account, quantity);
    }

    function airdrop(address addr, uint256 quantity) public onlyOwner {
        _mintTokens(addr, quantity);
    }
    
    function setMerkleRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function setWalletMintLimit(uint256 limit) external onlyOwner {
        walletMintLimit = limit;
    }

    function setPublicMintActive(bool active) external onlyOwner {
        publicMintActive = active;
    }

    function setTransactionLimit(uint256 limit) external onlyOwner {
        transactionLimit = limit;
    }

    function setAllowListPhase(uint256 phase) external onlyOwner {
        allowListPhase = phase;
    }

   

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function tokenURI(uint256 _tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(_tokenId), "Token does not exist.");
        return string(
            abi.encodePacked(
                _baseTokenURI,
                Strings.toString(_tokenId),
                ".json"
            )
        );
    }

     function setApprovalForAll(address operator, bool approved)
        public
        override(IERC721A, ERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        payable
        override(IERC721A, ERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    /**
     * @dev Both safeTransferFrom functions in ERC721A call this function
     * so we don't need to override them.
     */
    function transferFrom(address from, address to, uint256 tokenId)
        public
        payable
        override(IERC721A, ERC721A)
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC721A, ERC721A, ERC2981)
        returns (bool)
    {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function _isPriorityOperator(address operator) internal pure override returns (bool) {
        // OpenSea Seaport Conduit:
        // https://etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        // https://goerli.etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        return operator == address(0x1E0049783F008A0085193E00003D00cd54003c71);
    }
}