// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import 'operator-filter-registry/src/DefaultOperatorFilterer.sol';

contract CoSinnesloschen is
    ERC721A('CoSinnesloschen', 'CoS'),
    ERC721AQueryable,
    Ownable,
    DefaultOperatorFilterer
{
    using Strings for uint256;

    // Mint Phase
    enum SaleState {
        PAUSED,
        FREE_MINT,
        WHITELIST_MINT,
        PUBLIC_MINT
    }

    // Supply and Max Mint Conditions
    uint256 public constant MAX_SUPPLY = 3141;

    // Removed Constant To Be Available To Change It In The Ongoing Mint
    uint256 public MAX_MINT_PER_WALLET = 5;
    uint256 public MAX_FREE_MINT_PER_WALLET = 2;

    // Merkle Roots
    bytes32 public freeMintRoot;
    bytes32 public wlMintRoot;

    // Mint Price
    uint256 public whitelistPrice = 0.0142 ether;
    uint256 public publicPrice = 0.02131 ether;

    // Strings
    string uriPrefix = '';
    string uriSuffix = '.json';
    string public hiddenURI;

    // Bool
    bool public publicMintCounterEnabled = true;
    bool public revealed;

    SaleState public saleState;

    // Mint Counters
    mapping(address => uint256) public freeMintClaimed;
    mapping(address => uint256) public wlMintClaimed;
    mapping(address => uint256) public publicMintClaimed;

    address public constant ADMIN = 0xc07c66a907DB76F69d755976483A4B2D846eeA6d;

    modifier onlyAdminOrOwner() {
        require(msg.sender == ADMIN || msg.sender == owner(), 'Only Admin or Owner');
        _;
    }

    // Modifiers
    modifier mintCompliance(uint256 amount) {
        require(msg.sender == tx.origin, 'No smart contracts');
        require(totalSupply() + amount <= MAX_SUPPLY, 'Closed');
        _;
    }

    // Public Functions
    function freemint(uint256 amount, bytes32[] calldata proof) external mintCompliance(amount) {
        require(saleState == SaleState.FREE_MINT, 'FREEMINT inactive');
        require(
            freeMintClaimed[msg.sender] + amount <= MAX_FREE_MINT_PER_WALLET,
            'You cant claim more tokens!'
        );
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, freeMintRoot, leaf), 'Invalid proof!');
        freeMintClaimed[msg.sender] += amount;
        _mint(msg.sender, amount);
    }

    function wlMint(
        uint256 amount,
        bytes32[] calldata proof
    ) external payable mintCompliance(amount) {
        require(saleState == SaleState.WHITELIST_MINT, 'WL inactive');
        require(msg.value >= amount * whitelistPrice, 'price not met');
        require(
            wlMintClaimed[msg.sender] + amount <= MAX_MINT_PER_WALLET,
            'You cant claim more tokens!'
        );
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, wlMintRoot, leaf), 'Invalid proof!');
        wlMintClaimed[msg.sender] += amount;
        _mint(msg.sender, amount);
    }

    function publicMint(uint256 amount) external payable mintCompliance(amount) {
        require(saleState == SaleState.PUBLIC_MINT, 'PUBLIC inactive');
        require(msg.value >= amount * publicPrice, 'price not met');
        if (publicMintCounterEnabled) {
            require(
                publicMintClaimed[msg.sender] + amount <= MAX_MINT_PER_WALLET,
                'You cant claim more tokens!'
            );
            publicMintClaimed[msg.sender] += amount;
        }
        _mint(msg.sender, amount);
    }

    function ownerMint(uint256 _amount, address _address) external onlyOwner {
        require(_amount + totalSupply() <= MAX_SUPPLY, 'No more');
        _safeMint(_address, _amount);
    }

    // Setters
    function setPhase(SaleState newState) external onlyOwner {
        saleState = newState;
    }

    function setWhitelistPrice(uint256 newPrice) external onlyOwner {
        whitelistPrice = newPrice;
    }

    function setPublicPrice(uint256 newPrice) external onlyOwner {
        publicPrice = newPrice;
    }

    function setUriPrefix(string memory uri) external onlyOwner {
        uriPrefix = uri;
    }

    function setUriSuffix(string memory uri) external onlyOwner {
        uriPrefix = uri;
    }

    function setHiddenUri(string memory uri) external onlyOwner {
        uriPrefix = uri;
    }

    function setMaxMintPerWallet(uint256 number) external onlyOwner {
        MAX_MINT_PER_WALLET = number;
    }

    function setMaxFreeMintPerWallet(uint256 number) external onlyOwner {
        MAX_FREE_MINT_PER_WALLET = number;
    }

    function setFreeMintRoot(bytes32 root) external onlyOwner {
        freeMintRoot = root;
    }

    function setWlMintRoot(bytes32 root) external onlyOwner {
        wlMintRoot = root;
    }

    // Toggle
    function toggleEnablePublicMintCounter() external onlyOwner {
        publicMintCounterEnabled = !publicMintCounterEnabled;
    }

    function toggleReveal() external onlyOwner {
        revealed = !revealed;
    }

    // Withdraw
    function withdraw() external onlyAdminOrOwner {
        uint256 balance = address(this).balance;
        uint256 adminBalance = (balance * 22) / 100;
        uint256 ownerBalance = balance - adminBalance;

        (bool success, ) = ADMIN.call{value: adminBalance}('');
        require(success, 'Failed to withdraw to ADMIN');

        (success, ) = owner().call{value: ownerBalance}('');
        require(success, 'Failed to withdraw to owner');
    }

    // Overrides
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override(IERC721A, ERC721A) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override(IERC721A, ERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override(IERC721A, ERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return uriPrefix;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override(IERC721A, ERC721A) returns (string memory) {
        require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

        if (!revealed) {
            return hiddenURI;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
                : '';
    }

    // Emergency Functions
    /**
     * This reset or set a specific number on a recipient how many he has minted on freemint and wl
     **/
    function setMaxFreeMintPerWalletClaimed(address recipient, uint256 number) external onlyOwner {
        freeMintClaimed[recipient] = number;
    }

    function setMaxWlPerWalletClaimed(address recipient, uint256 number) external onlyOwner {
        wlMintClaimed[recipient] = number;
    }
}