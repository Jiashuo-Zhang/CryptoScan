// SPDX-License-Identifier: MIT

/*
                          _______
                         /|_____|\
                        | |     | |
                 ______ | |     | |
                /|____|\| \_____/ | ______
               | |    | |         |/|____|\
               | |    | |   _____ | |    | |
               | \____/ | -----   | |    | |
               |        | ------- | \____/ |
               |  ----  |         |        |
               |        |         |   ---  |
               |        |         | ------ |
               |        |         |        |
               |        |  _____  |        | _____
               |  ----- | ------- |        |/|---|\
               | ----  -| ----    |        | |   | |
               |  ----- |  ------ |  ___   | `---' |
               |   --   |   ---   |------  | ----- |
               |        |         |  ----- |       |
               |        |         |        |       |
    ______     |        |         |        |       |
   /.---. `.   |        |         |        |  ___  |
   \\----\  \  |        |         |        | ----- |
    \\    \  \ |        |         |        |   --  |
     \\___/   || .  .  / \   . .   \       |       |
      \       ||   . .      . . .      .   |        \
      |       |/    .        . .      . .   \       |
      |_.- .' /                 .      .     \      |
      |_.-'   |                               `.    |
      |       |                                   . |
      |       |                                  .  |
      |       |                                   . |
      |       |                                     |
      |       |                                     |
      |       |                                     |
      |       '                                     |
      |   |                                         |
       \   \                                        /
        \                                          |
         \                                         |
          \                                        |
           \                                      /
            \                                     |
             \                _                   |
              `.    _.-  '                       /
                \                                |
                 |                              /
                 |                              |
                 |                            \ |
                 |  `- ._   _                .  |
                 |                        . . . |
                 |                         . .  |
                 |                              |
                 |                              |
                 |                              |
                 |                              |
                 |                              |
                 |                              |
*/

pragma solidity ^0.6.6;

import "ERC721A.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";

contract ETHANDS is Ownable, ERC721A, ReentrancyGuard {
    uint256 public maxSupply = 1111;
    uint256 public maxMintPerTx = 10;
    uint256 public price = 0.11 * 10 ** 18;
    bytes32 public whitelistMerkleRoot =
        0x82d1dc70b21fec07976e83c5438b265b9c07df024038126f91b906eec77aeee4;
    bool public publicPaused = true;
    bool public revealed = false;
    string public baseURI;
    string public hiddenMetadataUri =
        "ipfs://QmYsuPkGb77MvvqZ5KsWu3Bhf4cEhRuc4memyqcZY8Pu7x";

    constructor() public ERC721A("ETHANDS", "ETHANDS", 1111, 1111) {}

    function mint(uint256 amount) external payable {
        uint256 ts = totalSupply();
        require(publicPaused == false, "Mint not open for public");
        require(ts + amount <= maxSupply, "Purchase would exceed max tokens");
        require(
            amount <= maxMintPerTx,
            "Amount should not exceed max mint number"
        );

        require(msg.value >= price * amount, "Please send the exact amount.");

        _safeMint(msg.sender, amount);
    }

    function openPublicMint(bool paused) external onlyOwner {
        publicPaused = paused;
    }

    function setWhitelistMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        whitelistMerkleRoot = _merkleRoot;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function whitelistStop(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxPerTx(uint256 _maxMintPerTx) external onlyOwner {
        maxMintPerTx = _maxMintPerTx;
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function whitelistMint(
        uint256 amount,
        bytes32[] calldata _merkleProof
    ) public payable {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        uint256 ts = totalSupply();
        require(ts + amount <= maxSupply, "Purchase would exceed max tokens");

        require(
            MerkleProof.verify(_merkleProof, whitelistMerkleRoot, leaf),
            "Invalid proof!"
        );

        {
            _safeMint(msg.sender, amount);
        }
    }

    function setHiddenMetadataUri(
        string memory _hiddenMetadataUri
    ) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, _tokenId.toString()))
                : "";
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}