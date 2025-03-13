// SPDX-License-Identifier: NONE 

pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./IWoofPack.sol";
import "hardhat/console.sol";

contract Sale is Ownable {
    using ECDSA for bytes32;

    uint256 public constant MAX_SUPPLY = 5555;
    uint256 public MINT_PRICE = 0.00 ether;
    uint256 public constant RARITY_PRICE = 5555 ether; // BOOM

    // address where payments will be withdrawn to
    address public K9DAO;
    // signer of messages for claims
    address public signer;
    // list of claims that have been made
    mapping(address => uint256) public claims;
    //list of public claims made
    //each address can have one public mint
    mapping(address=> bool) public publicMints;
    // whether or not claims are enabled
    bool public claimsEnabled = false;

    // reference to WoofPack NFT
    IWoofPack public woofPack;
    // reference to BOOM token
    IERC20 public boom;
    //total number of mints so far
    //starting at 629 because of the 629 mints that were done before the contract was deployed
    uint256 public totalMints = 629;
    // whether or not general mints are enabled
    bool public generalEnabled = false;

    event Mint(
        address recipient,
        uint256 id,
        bool rare
    );

    /****
    @param _signer the address of the signing wallet
    @param _woofPack the address of the NFT contract
    @param _boom the address of BOOM token
    ****/
    constructor(address _signer, address _woofPack, address _boom) {
        signer = _signer;
        K9DAO = msg.sender;
        woofPack = IWoofPack(_woofPack);
        boom = IERC20(_boom);
    }

    //a function that allows the owner to mint NFTs for giveaways
    //this was added in by matt and is not part of the original contract provided
    /***
    @param recipient the address to mint the NFTs to
    @param quantity the number of NFTs to mint
    @param rare whether or not the NFTs should be rare
    ****/
    function ownerMint(address recipient, uint256 quantity, bool rare) external onlyOwner {
        // makes sure that there are general mints available
        require(totalMints + quantity <= MAX_SUPPLY, "General mint sold out");
        // update the number of general mints that have been done
        // mint the NFTs
        _mint(recipient, quantity, rare);
    }

    /****
    allows addresses to claim their free NFT(s)
    @param quantity the number of NFTs to claim for free
    @param rare whether or not the address wants to spend BOOM for additional rarity
    @param signature the signature from the project allowing the claims
    @param maxAllowed the maximum number a user is allowed to claim for straightforward leaf generation
    ****/
    function claimMint(uint256 quantity, bool rare, bytes memory signature, uint256 maxAllowed) external {
        // makes sure that claims are currently enabled
        require(claimsEnabled, "Claims are currently paused");
        //make sure not going ver max supply
        require(totalMints + quantity <= MAX_SUPPLY, "Not enough mints available, try a lower qty.");
        // make sure the address hasn't reached the max claim amount
        require(claims[msg.sender] + quantity <= maxAllowed, "Address cannot mint this many, try a lower qty.");
        // encode the passed in data
        bytes memory message = abi.encode(msg.sender, maxAllowed, "claim");
        bytes32 messageHash = keccak256(message);
        // ensure that the signature is valid
        require(messageHash.toEthSignedMessageHash().recover(signature) == signer, "Invalid signature");        
        // record that the address has made their claim(s)
        claims[msg.sender] += quantity;
        // mint the claimed NFTs
        _mint(msg.sender, quantity, rare);
    }

    /****
    function for direct mints, limit one per address
    @param quantity the number of NFTs to mint
    @param rare whether or not the address wants to spend BOOM for additional rarity
    ****/
    function publicMint(uint256 quantity, bool rare) payable external {
        // makes sure that general minting is currently enabled
        require(generalEnabled, "General mints are currently paused");
        // make sure the qty wont set over max supply
        require(totalMints + quantity <= MAX_SUPPLY, "Not enough mints available, try a lower qty.");
        // guarantee the payment amount is correct
        require(msg.value == quantity * MINT_PRICE, "Invalid payment amount");
        // update the number of general mints that have been done
        require(!publicMints[msg.sender], "address already claimed free mint");
        publicMints[msg.sender] = true;
        // mint the NFTs
        _mint(msg.sender, quantity, rare);
    }

    /****
    general internal function for minting multiple NFTs
    @param recipient the address to send the NFTs to
    @param quantity the number of NFTs to mint
    @param rare whether or not the NFTs are guaranteed rare
    ****/
    function _mint(address recipient, uint256 quantity, bool rare) internal {
        // charge the requisite BOOM, will fail if they don't have enough
        if (rare) _chargeBoom(quantity);
        for (uint256 i = 0; i < quantity; i++) {
            woofPack.mint(recipient, ++totalMints, rare);
            emit Mint(recipient, totalMints, rare);
        }
    }

    /****
    burns BOOM to the DEAD address
    @param quantity the number of tokens having BOOM applied to rarity
    ****/
    function _chargeBoom(uint256 quantity) internal {
        boom.transferFrom(msg.sender, address(0xdead), RARITY_PRICE * quantity);
    }

    /****
    allows owner to update the signer of claims and whitelists
    @param _signer the new signer of valid signatures
    ****/
    function setSigner(address _signer) external onlyOwner{
        signer = _signer;
    }

    /****
    allows owner to withdraw ETH to the DAO
    ****/
    function withdraw() external onlyOwner {
        payable(K9DAO).transfer(address(this).balance);
    }

    /****
    allows owner to update destination of withdrawals
    @param _K9DAO the new address
    ****/
    function setK9DAO(address _K9DAO) external onlyOwner {
        K9DAO = _K9DAO;
    }

    /****
    allows owner to enable/disable claims
    @param _enabled whether or not it's enabled
    ****/
    function setClaimsEnabled(bool _enabled) external onlyOwner {
        claimsEnabled = _enabled;
    }

    /****
    allows owner to enable/disable general mints
    @param _enabled whether or not it's enabled
    ****/
    function setGeneralEnabled(bool _enabled) external onlyOwner {
        generalEnabled = _enabled;
    }

    /****
    allows owner to change price of WL and general mints
    @param _price new price IN WEI (not ETH) of mint
    ****/
    function setMintPrice(uint256 _price) external onlyOwner {
        MINT_PRICE = _price;
    }
}