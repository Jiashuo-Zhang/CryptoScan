// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./libraries/ERC721A.sol";
import "./libraries/Strings.sol";
import "./libraries/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ERR01R is ERC721A, Ownable {
    using Strings for uint256;

    string private baseURI;

    bytes32 public merkleRoot =
        0x3a04999e6b6fd4875957beac806c6bfe6504826d358881d38c31195259808df3;

    uint256 public price = 0.009 ether;

    uint256 public maxPerTx = 1;

    uint256 public maxSupply = 999;

    bool public mintEnabled = false;

    bool public whitelistSaleEnabled = false;

    mapping(address => bool) public claimed;

    constructor() ERC721A("ERR01R", "ERR01R") {
        setBaseURI("ipfs://QmT4Vt7PQAbGYXXZTm7MjahzxzWEkBbsjGwsfjvY7kwZHJ/");
    }

    function setMerkleRoot(bytes32 _newRoot) public onlyOwner {
        merkleRoot = _newRoot;
    }

    function mint(bytes32[] calldata _merkleProof) external payable {
        require(msg.value >= price, "Please send the exact amount");
        require(totalSupply() + 1 <= maxSupply, "No more");
        require(mintEnabled, "Minting is not live yet");

        if(whitelistSaleEnabled) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(
                MerkleProof.verify(_merkleProof, merkleRoot, leaf),
                "Invalid Merkle Proof"
            );
            require(!claimed[msg.sender], "Already claimed");
            claimed[msg.sender] = true;
            _safeMint(msg.sender, 1);
        } else {
            _safeMint(msg.sender, 1);
        }
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
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function flipSale() external onlyOwner {
        mintEnabled = !mintEnabled;
    }

    function startWhitelistSale() external onlyOwner {
        whitelistSaleEnabled = !whitelistSaleEnabled;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");
    }
}