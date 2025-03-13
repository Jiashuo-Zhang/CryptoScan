// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ERC721A.sol";
import "./Ownable.sol";

contract Crayons is ERC721A, Ownable {
    using Strings for uint256;
    uint256 public maxSupply = 3333;
    uint256 public cost = 0.003 ether;
    uint256 public maxPerWallet = 5;
    uint256 public maxFreePerWallet = 0;
    uint256 public maxMintAmountPerTx = 5;
    string public baseURI;
    bool public paused = true;
    
    constructor() ERC721A("Crayons", "CRAYONS") {}

    modifier mintCompliance(uint256 quantity) {
        require(quantity > 0 && quantity <= maxMintAmountPerTx, "Maximum of 5 crayons per transaction!");
        require(_numberMinted(msg.sender) + quantity <= maxPerWallet, "Maximum amount of crayons minted!");
        require(totalSupply() + quantity < maxSupply + 1, "There's no more crayons left!");
        _;
    }

    modifier mintPriceCompliance(uint256 quantity) {
        uint256 realCost = 0;
        if (_numberMinted(msg.sender) < maxFreePerWallet) {
            uint256 freeMintsLeft = maxFreePerWallet - _numberMinted(msg.sender);
            realCost = cost * freeMintsLeft;
        }
        require(msg.value >= cost * quantity - realCost, "Please send the exact amount.");
        _;
    }

    function publicMint(uint256 quantity) external payable mintCompliance(quantity) mintPriceCompliance(quantity) {
        require(!paused, "Crayons aren't ready... yet!");
        _safeMint(msg.sender, quantity);
    }

    function ownerMint(uint256 quantity)
        public
        payable
        mintCompliance(quantity)
        onlyOwner
    {
        _safeMint(_msgSender(), quantity);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
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
            "URI token does not exist!"
        );
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function setMaxFreePerWallet(uint256 _amount) external onlyOwner {
        maxFreePerWallet = _amount;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Ooops!");
    }
}