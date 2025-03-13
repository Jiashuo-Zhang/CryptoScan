// SPDX-License-Identifier: MIT

/***
 *    ▒██   ██▒ ██▓     ██▓▓█████  ███▄    █   ██████ 
 *    ▒▒ █ █ ▒░▓██▒    ▓██▒▓█   ▀  ██ ▀█   █ ▒██    ▒ 
 *    ░░  █   ░▒██░    ▒██▒▒███   ▓██  ▀█ ██▒░ ▓██▄   
 *     ░ █ █ ▒ ▒██░    ░██░▒▓█  ▄ ▓██▒  ▐▌██▒  ▒   ██▒
 *    ▒██▒ ▒██▒░██████▒░██░░▒████▒▒██░   ▓██░▒██████▒▒
 *    ▒▒ ░ ░▓ ░░ ▒░▓  ░░▓  ░░ ▒░ ░░ ▒░   ▒ ▒ ▒ ▒▓▒ ▒ ░
 *    ░░   ░▒ ░░ ░ ▒  ░ ▒ ░ ░ ░  ░░ ░░   ░ ▒░░ ░▒  ░ ░
 *     ░    ░    ░ ░    ▒ ░   ░      ░   ░ ░ ░  ░  ░  
 *     ░    ░      ░  ░ ░     ░  ░         ░       ░  
 *                                                    
 */

pragma solidity 0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "erc721a/contracts/extensions/IERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";


contract Xliens is ERC721A, ERC721AQueryable, DefaultOperatorFilterer, Ownable {

    string public baseURI = "ipfs://bafybeihlwdak2fnrcge5vfcrezh3tiaojzxrujpnk4znfmazqcu45fmj6i/"; //pre-reveal, updated for reveal
    uint256 public price = 0.0088 ether;
    uint256 public maxSupply = 8888;
    uint256 public maxPerTransaction = 10;
    uint256 public maxPerWallet = 10;
    uint256 public freeMint = 1;

    bool public saleActive;
    
    mapping(address => uint256) private redeemedTokens;
    
    constructor () ERC721A("Xliens", "XLIEN") {
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

    function mint(uint256 amount) public payable {
            require(saleActive);
            require(_numberMinted(msg.sender) + amount <= maxPerWallet);
            require(amount <= maxPerTransaction);
            if (amount == 1) {
                if (redeemedTokens[msg.sender] < freeMint) {
                    require(totalSupply() + amount <= maxSupply);
                    _safeMint(msg.sender, 1);
                    redeemedTokens[msg.sender] + 1;
                }
                else {
                    require(msg.value >= price, "Insufficient funds");
                    require(totalSupply() + amount <= maxSupply);
                    _safeMint(msg.sender, 1);
                    redeemedTokens[msg.sender] + 1;
                }
            }
            else {
                uint256 totalPrice = price * amount;
                require(msg.value >= totalPrice, "Insufficient funds");
                require(totalSupply() + amount <= maxSupply);
                _safeMint(msg.sender, amount);
                redeemedTokens[msg.sender] += amount;
            }
    }


    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function cutSupply(uint256 newSupply) public onlyOwner {
        maxSupply = newSupply;
    }

    function setmaxPerTransaction(uint256 newmaxPerTransaction) public onlyOwner {
        maxPerTransaction = newmaxPerTransaction;
    }

    function setmaxPerWallet(uint256 newmaxPerWallet) public onlyOwner {
        maxPerWallet = newmaxPerWallet;
    }

    function setfreeMint(uint256 newfreeMint) public onlyOwner {
        freeMint = newfreeMint;
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function devMint(uint256 quantity) external onlyOwner {
        require(totalSupply() + quantity <= maxSupply);
        _safeMint(msg.sender, quantity);
    }

    function treasuryMint(uint256 quantity) public onlyOwner {
        require(totalSupply() + quantity <= maxSupply);
        require(quantity > 0, "Invalid mint amount");
        require(
            totalSupply() + quantity <= maxSupply,
            "Maximum supply exceeded"
        );
        _safeMint(msg.sender, quantity);
    }

    function setApprovalForAll(address operator, bool approved) public override (ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {
    super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override (ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override (ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override (ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }
}