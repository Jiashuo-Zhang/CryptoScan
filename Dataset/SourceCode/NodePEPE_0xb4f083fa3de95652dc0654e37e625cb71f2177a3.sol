//  _  _  _____  ____  ____  ____  ____  ____  ____
// ( \( )(  _  )(  _ \( ___)(  _ \( ___)(  _ \( ___)
//  )  (  )(_)(  )(_) ))__)  )___/ )__)  )___/ )__)
// (_)\_)(_____)(____/(____)(__)  (____)(__)  (____)
// nodepepe.xyz
// x: @nodePEPE_
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract NodePEPE is ERC2981, ERC721A, DefaultOperatorFilterer, Ownable {
    using Strings for uint256;

    event Mint(uint256 amount);

    uint64 public maxSupply = 6666;
    uint64 public maxPerTx = 23;
    uint64 public freePerWallet = 3;
    bool public isSaleActive;

    uint256 publicPrice = 0.0025 ether;

    mapping(address => uint256) public minted;
    string private baseURI;
    string public contractURI;

    constructor(
        string memory _baseURI,
        string memory _contractURI
    ) ERC721A("NodePEPE", "NPEP") Ownable(msg.sender) {
        baseURI = _baseURI;
        contractURI = _contractURI;
        _setDefaultRoyalty(msg.sender, 500);
    }

    function mint(uint256 quantity) external payable {
        require(isSaleActive, "Mint has not started yet");
        require(tx.origin == _msgSender(), "No contracts");
        require(totalSupply() + quantity <= maxSupply, "Max supply exceeded");
        require(quantity <= maxPerTx, "Per transaction limit exceeded");
        uint256 requiredSum = quantity * publicPrice;
        if (minted[msg.sender] < freePerWallet) {
            uint discount = freePerWallet - minted[msg.sender];
            quantity <= discount ? requiredSum = 0 : requiredSum =
                (quantity - discount) *
                publicPrice;
        }
        require(msg.value >= requiredSum, "Incorrect ETH amount");

        minted[msg.sender] += quantity;
        _mint(msg.sender, quantity);
        emit Mint(quantity);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function setContractURI(string memory uri) external onlyOwner {
        contractURI = uri;
    }

    function setRoyalty(address receiver, uint96 fee) external onlyOwner {
        _setDefaultRoyalty(receiver, fee);
    }

    function setMaxPerTx(uint64 limit) external onlyOwner {
        maxPerTx = limit;
    }

    function setFreePerWallet(uint64 limit) external onlyOwner {
        freePerWallet = limit;
    }

    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function pepedrop(uint256 quantity, address receiver) external onlyOwner {
        require(totalSupply() + quantity <= maxSupply, "Max supply exceeded");
        _safeMint(receiver, quantity);
    }

    function releaseFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to release");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "withdraw failed");
    }

    function cutSupply(uint64 newSupply) external onlyOwner {
        require(
            newSupply < maxSupply,
            "New max supply should be lower than current max supply"
        );
        require(
            newSupply >= totalSupply(),
            "New max suppy should be higher than current number of minted tokens"
        );
        maxSupply = newSupply;
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
    ) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}