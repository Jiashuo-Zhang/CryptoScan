// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NorenNft is ERC721, ERC2981, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    uint256 public maxSupply = 300;
    uint256 public maxPerAddr = 3;
    uint256 public price_wei = 10000000000000000;
    bool public revealed = false;
    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;
    bytes32 private merkleRoot1;
    string internal noren_baseURI;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NorenNft v2", "NORENv2") {
        _setDefaultRoyalty(owner(), 500);
    }
    
    // setter functionss
    function setPrice(uint256 _price_wei) external onlyOwner {
        price_wei = _price_wei;
    }
    function setMPA(uint256 _maxPerAddr) external onlyOwner {
        maxPerAddr = _maxPerAddr;
    }
    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }
    function setRootHash(bytes32 _merkleeRoot1) external onlyOwner {
        merkleRoot1 = _merkleeRoot1;
    }

    //
    function _baseURI() internal view override returns (string memory) {
        return noren_baseURI;
    }

    //
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        if (revealed) {
            return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId))) : "";
        } else {
            return bytes(baseURI).length > 0 ? baseURI : "";
        }
    }

    // for whitelisted1 users
    function whitelistMint1(bytes32[] calldata _proof, uint256 n) public {
        require(allowListMintOpen, "whitelist mint closed");
        require(totalSupply() + n < maxSupply, "not enough supply");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_proof, merkleRoot1, leaf), "not in the whitelist");
        for (uint i = 0; i < n; i++) {
          internalMint(msg.sender);
        }
    }

    // hash check
    function showRootHash1() external onlyOwner view returns (bytes32) {
      return merkleRoot1;
    }

    // wl check by owner
    function wl_check(bytes32[] calldata _proof, address addr) external onlyOwner view returns (string memory) {
        bytes32 leaf = keccak256(abi.encodePacked(addr));
        if (MerkleProof.verify(_proof, merkleRoot1, leaf)) {
          return 'wl1';
        } else {
          return 'none';
        }
    }

    // wl check by user
    function is_on_WL(bytes32[] calldata _proof) external view returns (string memory) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (MerkleProof.verify(_proof, merkleRoot1, leaf)) {
          return 'wl1';
        } else {
          return 'none';
        }
    }

    //
    function adminMint(address to, uint256 n) public onlyOwner {
      require(totalSupply() + n < maxSupply, "not enough supply");
      for (uint i = 0; i < n; i++) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
      }
    }

    //
    function airdrop(address[] calldata wAddresses) public onlyOwner {
      for (uint i = 0; i < wAddresses.length; i++) {
        internalMint(wAddresses[i]);
      }
    }

    //
    function publicMint(uint256 n) public payable {
        require(publicMintOpen, "public mint closed");
        require(totalSupply() + n < maxSupply, "not enough supply");
        require(msg.value == n * price_wei, "not enough funds");
        for (uint i = 0; i < n; i++) {
          internalMint(msg.sender);
        }
    }

    //
    function internalMint(address addr) internal {
        require(balanceOf(addr) < maxPerAddr, "max mint per wallet reached");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(addr, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Modify the mint windows
    function editWindows(bool _publicMintOpen, bool _allowListMintOpen, bool _revealed) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
        revealed = _revealed;
    }

    //
    function editBaseURI(string memory _noren_baseURI) external onlyOwner {
        noren_baseURI = _noren_baseURI;
    }

    //
    function withdraw() external payable onlyOwner {
      (bool success, ) = payable(msg.sender).call{
        value: address(this).balance
      }('');
      require(success);
    }
}