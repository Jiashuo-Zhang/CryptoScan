// SPDX-License-Identifier: MIT
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AlleyMentals is ERC721A, Ownable, ReentrancyGuard {
    uint256 public TOTAL_SUPPLY = 8888;
    uint256 public FREE_MINTS_AVAILABLE = 1000;
    uint256 public MAX_FREE_PER_WALLET = 1;
    mapping(address => uint256) public FREE_MINTS_PER_WALLET;
    mapping(address => uint256) public CLAIMS_PER_WALLET;
    bool public SALE_STARTED = false;
    uint256 public MINT_PRICE = 0.0069 ether;
    address private VAULT_ADDRESS = address(0);
    bytes32 private MERKLE_ROOT = 0x0;
    string public baseURI;

    constructor() ERC721A("AlleyMentals", "MNTL") {}

    function mint(uint256 _amount) external payable nonReentrant {
        require(SALE_STARTED, "Sale not open");
        require(_amount > 0, "Amount must be greater than 0");
        require(totalSupply() + _amount <= TOTAL_SUPPLY, "Exceeds total supply");

        uint256 freeAmount = FREE_MINTS_AVAILABLE > 0 && FREE_MINTS_PER_WALLET[_msgSender()] < MAX_FREE_PER_WALLET
            ? MAX_FREE_PER_WALLET - FREE_MINTS_PER_WALLET[_msgSender()]
            : 0;

        if (freeAmount > 0) {
            freeAmount = freeAmount > _amount ? _amount : freeAmount;
            uint256 paidAmount = _amount <= freeAmount ? 0 : _amount - freeAmount;
            require(paidAmount * MINT_PRICE <= msg.value, "Not enough ETH paid");
            FREE_MINTS_AVAILABLE = FREE_MINTS_AVAILABLE - freeAmount;
            FREE_MINTS_PER_WALLET[_msgSender()] = FREE_MINTS_PER_WALLET[_msgSender()] + freeAmount;
        }

        _safeMint(_msgSender(), _amount);
    }

    function privateMint(address _receiver, uint256 _amount) external onlyOwner {
        require(totalSupply() + _amount <= TOTAL_SUPPLY);
        _safeMint(_receiver, _amount);
    }

    function claim(bytes32[] memory _proof) external nonReentrant {
        require(MerkleProof.verify(_proof, MERKLE_ROOT, keccak256(abi.encodePacked(_msgSender()))), "Wrong claim proof");
        require(CLAIMS_PER_WALLET[_msgSender()] < 1, "Already claimed");
        require(totalSupply() + 1 <= TOTAL_SUPPLY, "Exceeds total supply");

        CLAIMS_PER_WALLET[_msgSender()] = 1;

        _safeMint(_msgSender(), 1);
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        MINT_PRICE = _price;
    }

    function setFreeMintsAvailable(uint256 _amount) external onlyOwner {
        FREE_MINTS_AVAILABLE = _amount;
    }

    function setTotalSupply(uint256 _amount) external onlyOwner {
        TOTAL_SUPPLY = _amount;
    }

    function setMaxFreePerWallet(uint256 _amount) external onlyOwner {
        MAX_FREE_PER_WALLET = _amount;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setMerkleRoot(bytes32 _value) external onlyOwner {
        MERKLE_ROOT = _value;
    }

    function setVault(address _address) external onlyOwner {
        VAULT_ADDRESS = _address;
    }

    function withdrawToVault() external onlyOwner {
        require(VAULT_ADDRESS != address(0));
        payable(VAULT_ADDRESS).transfer(address(this).balance);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function toggleSaleStarted() external onlyOwner {
        SALE_STARTED = !SALE_STARTED;
    }
}