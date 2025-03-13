//      __          _        ___             _
//   /\ \ \___   __| | ___  / __\ ___  _ __ | | _____
//  /  \/ / _ \ / _` |/ _ \/__\/// _ \| '_ \| |/ / __|
// / /\  / (_) | (_| |  __/ \/  \ (_) | | | |   <\__ \
// \_\ \/ \___/ \__,_|\___\_____/\___/|_| |_|_|\_\___/
// Copypaste 2002 <-> All rights are lefts
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NodeBonks is ERC2981, ERC721A, Ownable {
    using Strings for uint256;

    event Mint(uint256 amount);

    uint256 public price = 0.002 ether;
    uint64 public freePerWallet = 2;
    uint64 public maxSupply = 10000;
    uint64 public maxPerTx = 52;
    bool public isSaleActive;

    mapping(address => uint256) public minted;
    string private baseURI;
    string public contractURI;

    constructor(
        string memory _baseURI,
        string memory _contractURI
    ) ERC721A("NodeBonks", "NBNK") Ownable(msg.sender) {
        baseURI = _baseURI;
        contractURI = _contractURI;
        _setDefaultRoyalty(msg.sender, 500);
    }

    function mint(uint256 quantity) external payable {
        require(isSaleActive, "Mint has not started yet");
        require(tx.origin == _msgSender(), "Bots not allowed");
        require(totalSupply() + quantity <= maxSupply, "Max supply exceeded");
        require(quantity <= maxPerTx, "Per transaction limit exceeded");
        uint256 requiredSum = quantity * price;
        if (minted[msg.sender] < freePerWallet) {
            uint discount = freePerWallet - minted[msg.sender];
            quantity <= discount ? requiredSum = 0 : requiredSum =
                (quantity - discount) *
                price;
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
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

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function setContractURI(string memory uri) external onlyOwner {
        contractURI = uri;
    }

    function setFreePerWallet(uint64 limit) external onlyOwner {
        freePerWallet = limit;
    }

    function setMaxPerTx(uint64 limit) external onlyOwner {
        maxPerTx = limit;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function airdrop(uint256 quantity, address receiver) external onlyOwner {
        require(totalSupply() + quantity <= maxSupply, "Max supply exceeded");
        _safeMint(receiver, quantity);
    }

    function release() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to release");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Release failed");
    }
}