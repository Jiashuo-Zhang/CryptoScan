// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract MightyGorillas is ERC721A, DefaultOperatorFilterer, Ownable {
    //  Contracts
    ERC20Burnable public jungleToken;

    // Jungle Bank
    address public jungleBank;

    //  Accounts
    address private constant creator0Address =
        0x73e3187ebF63C9E8a1539772678272781BC2838f;
    address private constant creator1Address =
        0x68615b557073262FA0ab9eD41533a5c4Dd81e2BE;
    address private constant creator2Address =
        0x0C36922266e6cE0f92a357E20399F295c2b9ff10;
    address private constant creator3Address =
        0x73001491D58400F6c29fd9E6D6FfF8A46dB86eE7;
    address private constant creator4Address =
        0xBF9fE3aE379FF32a4aC2fB1196D271c557f42513;

    // Minting Variables
    uint256 public maxSupply = 8888;
    uint256 public reserveSupply = 1500;
    uint256 public publicMintPrice = 0.03 ether;
    uint256 public privateMintPrice = 0.02 ether;
    uint256 public mintJungleCoinPrice = 1000 ether;
    uint256 public maxPurchase = 5;

    // Metadata lock
    bool public locked;

    // Sale Status
    bool public presaleActive;
    bool public publicSaleActive;
    bool public jungleSaleActive;

    // Merkle Roots
    bytes32 private allowlistRoot;
    bytes32 private claimableRoot;
    bytes32 private jungleRoot;

    mapping(address => bool) public hasClaimed;
    mapping(address => uint256) public mintCounts;
    mapping(address => uint256) public jungleMintCounts;

    // Metadata
    string _baseTokenURI;

    // Events
    event PublicSaleActivation(bool isActive);
    event PresaleActivation(bool isActive);
    event JungleSaleActivation(bool isActive);

    // Contract
    constructor(
        address jungleTokenAddress,
        address jungleBankAddress
    ) ERC721A("The Mighty Gorillas", "TMG") {
        jungleToken = ERC20Burnable(jungleTokenAddress);
        jungleBank = jungleBankAddress;
    }

    // Merkle Proofs
    function setAllowlistRoot(bytes32 _root) external onlyOwner {
        allowlistRoot = _root;
    }

    function setClaimableRoot(bytes32 _root) external onlyOwner {
        claimableRoot = _root;
    }

    function setJungleRoot(bytes32 _root) external onlyOwner {
        jungleRoot = _root;
    }

    function setReserveSupply(uint256 _reserveSupply) external onlyOwner {
        reserveSupply = _reserveSupply;
    }

    // Minting
    function ownerMint(address _to, uint256 _count) external onlyOwner {
        require(
            totalSupply() + _count <= (maxSupply - reserveSupply),
            "exceeds max supply"
        );

        _safeMint(_to, _count);
    }

    function presaleMint(
        uint256 _count,
        bytes32[] calldata _proof
    ) external payable {
        require(presaleActive, "Presale must be active");
        require(
            isInTree(msg.sender, _proof, allowlistRoot),
            "not whitelisted for presale"
        );
        require(
            mintCounts[msg.sender] + _count <= maxPurchase,
            "exceeds the account's quota"
        );
        require(
            totalSupply() + _count <= (maxSupply - reserveSupply),
            "exceeds max supply"
        );
        require(
            privateMintPrice * _count <= msg.value,
            "Ether value sent is not correct"
        );

        mintCounts[msg.sender] = mintCounts[msg.sender] + _count;
        require(
            mintCounts[msg.sender] <= maxPurchase,
            "exceeds the account's quota"
        );

        _safeMint(msg.sender, _count);
    }

    function mint(uint256 _count) external payable {
        require(publicSaleActive, "Sale must be active");
        require(_count <= maxPurchase, "exceeds maximum purchase amount");
        require(
            mintCounts[msg.sender] + _count <= maxPurchase,
            "exceeds the account's quota"
        );

        require(
            totalSupply() + _count <= (maxSupply - reserveSupply),
            "exceeds max supply"
        );
        require(
            publicMintPrice * _count <= msg.value,
            "Ether value sent is not correct"
        );

        mintCounts[msg.sender] = mintCounts[msg.sender] + _count;
        require(
            mintCounts[msg.sender] <= maxPurchase,
            "exceeds the account's quota"
        );

        _safeMint(msg.sender, _count);
    }

    /**
     * @dev Mints a token with Jungle Coin
     * @param _count The number of NFTs to mint
     * @param _maxClaim The maximum number of NFTs that can be claimed. This must match what is in the Merkle Tree
     * @param _proof The Merkle proof
     */
    function mintWithJungle(
        uint256 _count,
        uint256 _maxClaim,
        bytes32[] calldata _proof
    ) external payable {
        require(jungleSaleActive, "Sale must be active");
        require(canClaim(msg.sender, _maxClaim, _proof, jungleRoot), "proof");
        require(
            totalSupply() + _count <= (maxSupply - reserveSupply),
            "exceeds max supply"
        );

        jungleMintCounts[msg.sender] = jungleMintCounts[msg.sender] + _count;
        require(
            jungleMintCounts[msg.sender] <= _maxClaim,
            "exceeds the account's quota"
        );

        jungleToken.transferFrom(
            _msgSender(),
            jungleBank,
            _count * mintJungleCoinPrice
        );

        _safeMint(msg.sender, _count);
    }

    /**
     * @dev Claims a token with Jungle Coin
     * @param _count The number of NFTs to claim
     * @param _proof The Merkle proof
     */
    function claim(uint _count, bytes32[] calldata _proof) external {
        require(totalSupply() + _count <= maxSupply, "exceeds max supply");
        require(!hasClaimed[msg.sender], "claimed");
        require(canClaim(msg.sender, _count, _proof, claimableRoot), "proof");
        hasClaimed[msg.sender] = true;
        _safeMint(msg.sender, _count);
    }

    // Configurations
    function lockMetadata() external onlyOwner {
        locked = true;
    }

    function togglePresaleStatus() external onlyOwner {
        presaleActive = !presaleActive;
        emit PresaleActivation(presaleActive);
    }

    function toggleSaleStatus() external onlyOwner {
        publicSaleActive = !publicSaleActive;
        emit PublicSaleActivation(publicSaleActive);
    }

    function toggleJungleSaleStatus() external onlyOwner {
        jungleSaleActive = !jungleSaleActive;
        emit JungleSaleActivation(jungleSaleActive);
    }

    function setPrivateMintPrice(uint256 _mintPrice) external onlyOwner {
        privateMintPrice = _mintPrice;
    }

    function setPublicMintPrice(uint256 _mintPrice) external onlyOwner {
        publicMintPrice = _mintPrice;
    }

    function setMintJungleCoinPrice(
        uint256 _mintJungleCoinPrice
    ) external onlyOwner {
        mintJungleCoinPrice = _mintJungleCoinPrice;
    }

    function setMaxPurchase(uint256 _maxPurchase) external onlyOwner {
        maxPurchase = _maxPurchase;
    }

    function setJungleBank(address _jungleBank) external onlyOwner {
        jungleBank = _jungleBank;
    }

    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Balance can't be zero");

        uint256 creator1Dividend = (balance / 100) * 18;
        uint256 creator2Dividend = (balance / 100) * 2;
        uint256 creator3Dividend = (balance / 100) * 3;
        uint256 creator4Dividend = (balance / 100) * 4;

        payable(creator1Address).transfer(creator1Dividend);
        payable(creator2Address).transfer(creator2Dividend);
        payable(creator3Address).transfer(creator3Dividend);
        payable(creator4Address).transfer(creator4Dividend);
        payable(creator0Address).transfer(address(this).balance);
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply();
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        require(!locked, "Contract metadata methods are locked");
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _leaf(address _account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _leaf(
        address _account,
        uint _amount
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _amount));
    }

    function isInTree(
        address _account,
        bytes32[] calldata _proof,
        bytes32 _root
    ) internal pure returns (bool) {
        return MerkleProof.verify(_proof, _root, _leaf(_account));
    }

    function canClaim(
        address _account,
        uint _amount,
        bytes32[] calldata _proof,
        bytes32 _root
    ) internal pure returns (bool) {
        return MerkleProof.verify(_proof, _root, _leaf(_account, _amount));
    }

    // =============
    // for DefaultOperatorFilterer
    // =============
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
}