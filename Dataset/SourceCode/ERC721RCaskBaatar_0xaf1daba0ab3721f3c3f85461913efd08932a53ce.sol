// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721RCaskBaatar  is ERC721A, Ownable {
    uint256 private constant maxMintSupply = 299;
    
    uint256 private constant stakingPrice = 0.15 ether;
    uint256 private constant salePrice = 0.3 ether;
    uint256 private constant discountPrice = 0.3*0.8 ether;
    uint256 private constant pubsalePrice = 0.33 ether;

    uint256 private constant saleSupply = 269;
    uint256 private constant discountSupply = 10;
    uint256 private constant freeSupply = 20;

    uint256 private constant maxSaleMintAmount = 3;
    uint256 private constant maxDiscountMintAmount = 1;
    uint256 private constant maxFreeMintAmount = 1;

    uint256 private constant MINT_TYPE_SALE = 1;
    uint256 private constant MINT_TYPE_DISCOUNT = 2;
    uint256 private constant MINT_TYPE_FREE = 3;
    uint256 private constant MINT_TYPE_PUBSALE = 4;

    bytes32 private saleMerkleRoot;
    bytes32 private discountMerkleRoot;
    bytes32 private freeMerkleRoot;

    uint256 public totalStaking = 0;

    uint256 private saleCount = 0;
    uint256 private discountCount = 0;
    uint256 private freeCount = 0;

    mapping(uint256 => bool) public stakingExchanged; 
    mapping(uint256 => bool) public stakingRefunded;

    bool public refundEnabled;
    bool public exchangeEnabled;

    mapping(address => uint256) private saleMintedCount;
    mapping(address => uint256) private discountMintedCount;
    mapping(address => uint256) private freeMintedCount;

    // 2023-02-22 11:50:00
    uint256 public whitelistStartTime = 1677037800;
    // 2023-02-26 23:59:00
    uint256 public whitelistEndTime = 1677427140;
    // 2023-02-27 12:00:00
    uint256 public pubsaleStartTime = 1677470400;
    // 2023-03-01 12:00:00
    uint256 public pubsaleEndTime = 1677643200;

    bool public timeDisabled;

    string private baseURI = "https://nft.caskbaatar.com/metadata/";

    event Mint(address indexed sender, uint256 tokenId, uint256 mintType, uint256 quantity, bytes32[] proof);
    event Refund(address indexed sender, uint256[] tokenIds);
    event Exchange(address indexed sender, uint256[] tokenIds);
    event Withdraw(address indexed sender, uint256 amount);
    event SetMerkleRoot(address indexed sender, bytes32 saleRoot, bytes32 discountRoot, bytes32 freeRoot);

    constructor() ERC721A("ERC721RCaskBaatar", "ERC721RCB") {
    }

    function mint(uint256 mintType, uint256 quantity, bytes32[] calldata proof)
        external
        payable
    {
        require(mintType == MINT_TYPE_SALE || mintType == MINT_TYPE_DISCOUNT || mintType == MINT_TYPE_FREE || mintType == MINT_TYPE_PUBSALE, "Invalid mint type");
        address sender = msg.sender;
        uint256 time = block.timestamp;

        uint256 mintPrice = 0;

        if(mintType == MINT_TYPE_PUBSALE) {
            require(timeDisabled || (time >= pubsaleStartTime && time < pubsaleEndTime), "Invalid time");            
            mintPrice = pubsalePrice;
        } else {

            require(timeDisabled || (time >= whitelistStartTime && time < whitelistEndTime), "Invalid time");            
            bytes32 merkleRoot = 0x0;

            if(mintType == MINT_TYPE_SALE) {
                mintPrice = salePrice;
                merkleRoot = saleMerkleRoot;
                saleCount += quantity;
                require(saleCount <= saleSupply, "Max sale supply");
                saleMintedCount[sender] += quantity;
                require(saleMintedCount[sender] <= maxSaleMintAmount, "Max sale mint");
            } else
            if(mintType == MINT_TYPE_DISCOUNT) {
                mintPrice = discountPrice;
                merkleRoot = discountMerkleRoot;
                discountCount += quantity;
                require(discountCount <= discountSupply, "Max discount supply");
                discountMintedCount[sender] += quantity;
                require(discountMintedCount[sender] <= maxDiscountMintAmount, "Max discount mint");
            } else
            if(mintType == MINT_TYPE_FREE) {
                merkleRoot = freeMerkleRoot;
                freeCount += quantity;
                require(freeCount <= freeSupply, "Max free supply");
                freeMintedCount[sender] += quantity;
                require(freeMintedCount[sender] <= maxFreeMintAmount, "Max free mint");
            } 

            require(_isAllowlisted(sender, proof, merkleRoot), "Not on allow list");
        }

        require(msg.value == quantity * mintPrice, "Value");
        require(_totalMinted() + quantity <= maxMintSupply, "Max mint supply");

        totalStaking += (quantity * stakingPrice);

        _safeMint(sender, quantity);
        emit Mint(sender, _currentIndex-quantity, mintType, quantity, proof);
    }

    function refund(uint256[] calldata tokenIds) external {
        require(refundEnabled, "Refund disabled");
        address sender = msg.sender;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(sender == ownerOf(tokenId), "Not token owner");
            require(!stakingRefunded[tokenId], "Already refunded");
            require(!stakingExchanged[tokenId], "Already exchanged");
            stakingRefunded[tokenId] = true;
            transferFrom(sender, owner(), tokenId);
        }

        uint256 amount = tokenIds.length * stakingPrice;
        totalStaking -= amount;
        Address.sendValue(payable(sender), amount);
        emit Refund(sender, tokenIds);
    }

    function exchange(uint256[] calldata tokenIds) external {
        require(exchangeEnabled, "Exchange disabled");
        address sender = msg.sender;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(sender == ownerOf(tokenId), "Not token owner");
            require(!stakingRefunded[tokenId], "Already refunded");
            require(!stakingExchanged[tokenId], "Already exchanged");
            stakingExchanged[tokenId] = true;
            transferFrom(sender, owner(), tokenId);
        }

        uint256 amount = tokenIds.length * stakingPrice;
        totalStaking -= amount;
        //Address.sendValue(payable(owner()), amount);
        emit Exchange(sender, tokenIds);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance >= totalStaking, "Not enough money");
        Address.sendValue(payable(owner()), balance - totalStaking);
        emit Withdraw(msg.sender, balance - totalStaking);
    }

    function toggleRefund() external onlyOwner {
        refundEnabled = !refundEnabled;
    }

    function toggleExchange() external onlyOwner {
        exchangeEnabled = !exchangeEnabled;
    }

    function toggleTime() external onlyOwner {
        timeDisabled = !timeDisabled;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
        if(0 == bytes(baseURI).length) {
            require(false, "Need setBaseURI");
        } else {
            return super.tokenURI(tokenId);
        }
    }

    function setMerkleRoot(bytes32 saleRoot, bytes32 discountRoot, bytes32 freeRoot) external onlyOwner {
        saleMerkleRoot = saleRoot;
        discountMerkleRoot = discountRoot;
        freeMerkleRoot = freeRoot;
        emit SetMerkleRoot(msg.sender, saleRoot, discountRoot, freeRoot);
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function _leaf(address _account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _isAllowlisted(
        address _account,
        bytes32[] calldata _proof,
        bytes32 _root
    ) internal pure returns (bool) {
        return MerkleProof.verify(_proof, _root, _leaf(_account));
    }

    function setStartEndTime(uint256 whitelistStart, uint256 whitelistEnd, uint256 pubsaleStart, uint256 pubsaleEnd) external onlyOwner {
        whitelistStartTime = whitelistStart;
        whitelistEndTime = whitelistEnd;
        pubsaleStartTime = pubsaleStart;
        pubsaleEndTime = pubsaleEnd;
    }
}