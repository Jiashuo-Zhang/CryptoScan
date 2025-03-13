//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract LyraLifetimePass is Ownable, ERC721A {
    enum SaleState {
        CLOSED, // people can't reserve nor claim
        WL_RESERVE, // wl people can reserve their NFT but can't claim
        RESERVE, // all people can reserve their NFT but can't claim
        END // sale is over, all people can claim their NFT but they can't reserve
    }

    enum ClaimState {
        NONE, // didnt claim yet
        RESERVED, // reserved the nft whether it was through wlReserve() or reserve()
        CLAIMED // claimed the NFT. no longer able to claim or reserve
    }

    // Constants
    uint256 public constant MAX_SUPPLY = 111;
    uint256 public constant PRICE = 0.75 ether;

    // State
    mapping (address => ClaimState) public userClaims;
    uint256 public reserveCount;
    SaleState public saleState;
    string private baseURI;
    bytes32 public merkleRoot;  

    constructor() ERC721A("Lyra Lifetime Pass", "LYRA") {}

    /* Public facing functions */

    // reserve allows the caller to purchase their claim as long as they are whitelisted
    function wlReserve(bytes32[] calldata proof) external payable {
        require(msg.sender == tx.origin, "Nope");
        require(saleState == SaleState.WL_RESERVE, "WL reserve is closed");
        require(msg.value == PRICE, "Wrong price");
        require(reserveCount + 1 <= MAX_SUPPLY, "Sold out");
        require(userClaims[msg.sender] == ClaimState.NONE, "Already reserved/claimed");

        // verify if user is whitelisted
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Not on whitelist");

        userClaims[msg.sender] = ClaimState.RESERVED;
        unchecked {
            ++reserveCount;
        }
    }

    // reserve allows the caller to purchase their claim
    function reserve() external payable {
        require(msg.sender == tx.origin, "Nope");
        require(saleState == SaleState.RESERVE, "Reserve is closed");
        require(msg.value == PRICE, "Wrong price");
        require(reserveCount + 1 <= MAX_SUPPLY, "Sold out");
        require(userClaims[msg.sender] == ClaimState.NONE, "Already reserved/claimed");

        userClaims[msg.sender] = ClaimState.RESERVED;
        unchecked {
            ++reserveCount;
        }
    }

    // claim allows the caller to mint their nft
    function claim() external payable {
        require(msg.sender == tx.origin, "Nope");
        require(saleState == SaleState.END, "Claim is closed");
        require(userClaims[msg.sender] == ClaimState.RESERVED, "No claim available/already claimed");
        require(_totalMinted() + 1 <= MAX_SUPPLY, "Sold out");

        userClaims[msg.sender] = ClaimState.CLAIMED;
        _mint(msg.sender, 1);
    }

    /* Owner functions */

    function setState(SaleState state) external onlyOwner {
        saleState = state;
    }

    function setBaseURI(string memory url) external onlyOwner {
        baseURI = url;
    }

    function setMerkleRoot(bytes32 root) external onlyOwner {
        merkleRoot = root;
    }

    function withdraw(address to) external payable onlyOwner {
        uint balance = address(this).balance;
        payable(to).transfer(balance);
    }

    function ownerMint(uint256 qty) external payable onlyOwner {
        require(_totalMinted() + qty <= MAX_SUPPLY, "Sold out");

        _mint(msg.sender, qty);
    }

    /* Override functions */

    function _baseURI() override internal view virtual returns (string memory) {
        return baseURI;
    }
}