// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "erc721a/contracts/extensions/IERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

interface Libee {
    function generateURI(uint256 tokenId, uint256 randomNumber) view external returns (string memory);
}

contract OcOpepen is ERC721A, ERC721AQueryable, Ownable {

    uint256 public price = 0.015 ether; //change
    uint256 public maxSupply = 798;
    uint256 public maxPerTransaction = 2;
    
    uint256 public maxPerWallet = 2;

    mapping (uint256 => uint256) private _tokenIdToRandomNumber;

    bool public saleActive;

    address libee_addr;

    uint256 currentSupply;

    Libee libee;

    mapping (uint256 => bool) private _frozenMetadata;

    
    constructor () ERC721A("OcOpepen", "OcO") {
    }

    function _setAddr(address _libee_addr) public onlyOwner  {  
        libee_addr = _libee_addr;
        // libee = Libee(_libee_addr);
    }

    function freezeMetadata(uint256 tokenId) public onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _frozenMetadata[tokenId] = true;
    }

    function freezeMetadataMultiple(uint256[] calldata tokenIds) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(_exists(tokenId), "Token does not exist");
            _frozenMetadata[tokenId] = true;
        }
    }

    function isMetadataFrozen(uint256 tokenId) public view returns (bool) {
        return _frozenMetadata[tokenId];
    }


    function _getNum(uint256 tokenId) public view returns (uint256)  {
            require(_exists(tokenId), "oye, not minted yet");
            return _tokenIdToRandomNumber[tokenId];
    }

    function _setNum(uint256 tokenId, uint256 _newRandomNumber) public onlyOwner  {  
        _tokenIdToRandomNumber[tokenId] = _newRandomNumber;
    }

    function tokenURI(uint256 tokenId) public view virtual override (ERC721A, IERC721A) returns (string memory) {
            require(_exists(tokenId), "oye, not minted yet");
            uint256 randomNumber = _tokenIdToRandomNumber[tokenId]; 
            string memory tokenURI_new = Libee(libee_addr).generateURI(tokenId, randomNumber);
            return tokenURI_new;
    }

    function mint(uint256 amount) public payable {
        require(saleActive);
        require(amount <= maxPerTransaction);
        require(totalSupply() + amount <= maxSupply);
        require(_numberMinted(msg.sender) + amount <= maxPerWallet);
        require(msg.value >= price * amount);
        currentSupply = totalSupply();
            for (uint256 i = 1; i <= amount ; i++)
            {
                uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, totalSupply() + i))) % 10000000000;
                _tokenIdToRandomNumber[currentSupply + i] = randomNumber;
            }
            _safeMint(msg.sender, amount);
        
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function startSale() external onlyOwner {
        require(saleActive == false);
        saleActive = true;
    }

    function stopSale() external onlyOwner {
        require(saleActive == true);
        saleActive = false;
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function setmaxPerTransaction(uint256 _maxPerTransaction) external onlyOwner
    {
        maxPerTransaction = _maxPerTransaction;
    }

    function setmaxPerWallet(uint256 _maxPerWallet) external onlyOwner
    {
        maxPerWallet = _maxPerWallet;
    }

    function setmaxSupply(uint256 _maxSupply) external onlyOwner
    {
        require(_maxSupply <= maxSupply); //no increase
        maxSupply = _maxSupply;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }


    function devMint(uint256 quantity) external onlyOwner {
        require(totalSupply() + quantity <= maxSupply);
        currentSupply = totalSupply();
        for (uint256 i = 1; i <= quantity ; i++)
            {
                uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, totalSupply() + i))) % 10000000000;
                _tokenIdToRandomNumber[currentSupply + i] = randomNumber;
            }
        _safeMint(msg.sender, quantity);
    }

    function treasuryMint(uint256 quantity) public onlyOwner {
        require(totalSupply() + quantity <= maxSupply);
        require(quantity > 0, "Invalid mint amount");
        require(
            totalSupply() + quantity <= maxSupply,
            "Maximum supply exceeded"
        );
        currentSupply = totalSupply();
        for (uint256 i = 1; i <= quantity ; i++)
            {
                uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, totalSupply() + i))) % 10000000000;
                _tokenIdToRandomNumber[currentSupply + i] = randomNumber;
            }
        _safeMint(msg.sender, quantity);
    }

    function airdropTokens(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Invalid input: recipients and amounts length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];
            currentSupply = totalSupply();
            for (uint256 j = 1; j <= amount ; j++)
            {
                uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, totalSupply() + j))) % 10000000000;
                _tokenIdToRandomNumber[currentSupply + j] = randomNumber;
            }
            _safeMint(recipient, amount);
        }
    }
    
}