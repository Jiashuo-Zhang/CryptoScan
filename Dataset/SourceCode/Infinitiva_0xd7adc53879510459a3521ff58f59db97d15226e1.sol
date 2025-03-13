// SPDX-License-Identifier: MIT

/*
####################################################################################################
##B??????????????????????????????????????????????????????????????????????????????????????????????B##
##G::^^^^^^^^^^::^^^^^^^^^^::^^^^:::::::::::::^^^^::::::^^^^:::^^^^^^^^:^:::^:^^^^::^^^:::^^^^^^^G##
##G^^^^^^^^^^^^^~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^~^^^^^^^^^^^^^^^^~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^::^^^^^^^^^^^^^~^~~~^^^^^^^^^^^^~~^^^^^:^^^^^:::^^~~!~~^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^:::.:::^^^:^^^^~~~~^^^^^^^^~~^^^^^^^~~^^^^^^^^::::....:::^!7777!~^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^~~~^~!!~~^^^~^^^.:^^~~^^^^^^^^^~^~~^^^^~^^::~!!7?JJJJJJJYJJJ?77??7!^^^^^^^^^^^^G##
##G^^^^^^^^^~!77?YYJJJ???777?J55?!^^^^~!!!~~^^^^^^^^:.:^^~!7?Y5P5PP5YYYY555PPPGPJ7?JJ?!^^^^^^^^^^G##
##G^^^^^^^!7?YJ7YJ??JJJ?J555Y?J5PGG5J??7!!!~~~~^^^:::^~7?Y5PP5YJJY5YJJ5GGGGPP5YPBBPJ77?7^^^^^^^^^G##
##G^^^^^^??5PJJPBPYPBBBB##BBGPP5YYJJY5PPYYY?!~!~:::^~7?77?JYJY55J7777J5GB#####BGPPGP5!~??^^^^^^^^G##
##G^^^~^JYPGYP#BP5G&&&#BGYYY5YJJJJ5P5YYPB##B5Y?~^:^~77~!JY555J7!7Y5555P5P5YJYGGP5YJ5JGY!??^^^^^^^G##
##G~^^^7P5PPG#GPGG##PPP55YY5PY?JJ7!!!JYY55PB&BPY5J77!7YJJYYJ!!?Y55YYYYYY55YJ?JPGG5?55?BY7?!^^^^^^G##
##G^~^^YPJ55BGPGBPGPP5Y55YJJJYYYYYJ?JJJ?!!7!?G&#GGP5Y5J7JJ~~!7?Y5Y?7!~~~!?555YYP55JP#G5YY7?^^^^^^G##
##G^^^^P5!Y5#PYB#GGGP55Y^^^^~~!7JYYJJJ5P5J7~^:~5BBPJ7JPPY7:!JYY?!~~~~~~~~^?5YJ?5PJ?5@BGJB?J~^^^^~G##
##G^~~^557Y5&GPBGPP5G5YY7^^~~~~~~~!7J5YYYPPPJ~::~5#BJ!7Y5Y??J?!~~~~~~~~~~!JJJ??J5J75@BBYBY?~~^^^^G##
##G^^^^?5YJY#P5BGPPGGBP55J7!~~~~!!?Y5J77P55PPPY7^~JP#BPJ7!J??JJ?777777777?777777??5&&#GJG57^~^^^^G##
##G^^^^~YJJ?5GP5G#BPPGPGG5Y55YYY555YJJY5YY5JJY5YJJYJYB&#P!~!7?JJ?7!77!!!!!~~!7JPG#@&##YJYJ~^^^^^^G##
##G^~^^^7YJJYPBB55GBGPGGPPPPPGP555Y5PP5Y5555P555Y??Y55B#&#P??????77?JYYJY55PPPB&@@&BBP5PY!^^^^^^~G##
##G^^^^^^!JYJ5GGGGPPPG55PGGGGGGGGGBBGGGGGGGP555PG5??YYPBB#&&BPJ??J5GGGPPB&@@@@&&##GPYYGJ~^^^^^^^^G##
##G^^^^^^^~?YYYYYPPP5YY5Y5PPPPGGGGBBGGBBBGGPPJ~^7PG5J???5GPG#&&&#BBBGPB#&&###GP5YJ7~7Y7^^^^^^^^^^G##
##G^^^^^^^^^!JYY5Y?JPPGP55P5PGGPGBBBGP555YJ?!~!!~~7YPGP555Y55PPB#&&&&&##BYJYYJ7!~!7?7~^^^^^^^^^^^G##
##G^^^^:^^^^:^~?Y5YJYYY5YYYY5555PPP55YJJ?JJ??7!~~~^^~!?5PGGBGP55PP5PG5YYYYY??7!??7!^^^^^^^^^^^^:^G##
##G:::::::::::::^~?Y5PPPGP5PPP555555555P5Y?!^^^^^^^^^^^^^~7?JY55555YYJJJJYYJ?7!~^^^^^^^^^^:::::::G##
##G:::::::::::::::::^~7?JY5PPPPPPP5YY?7!~^^^^^^^^^^^^^^^^^^^^^^^~~~~~~~~~~^^^^^^^^^^^^^^^::::::::G##
##G::::::::::::::::::::::^^^~~~~~^^^^^^^^^~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^::::::G##
##G:::::::^^^^^^^^^^^^^^^^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^~~~~~~!!!!!!!!!!!!!!!!!!!777!7!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~G##
##G^^^^^^~~^~~~~~~!!!7777777?????????????????????????????????????????????????77777777777777!!!~~~G##
##G^^^^^^^^^^~~~~~~~!!!!7777777???????????JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ?J???????????77777!!!~~~~G##
##G^^^^^^^^^^^^^~~~~~~~~~!!!!!!!7777777???????????JJJJJJJJJJJJJJJJJJJJJJJJJ???????7777!!!!~~~~~~~G##
##G^^^^^^^^^^^^^^^^^^^^~~~~~~~~~~~~~~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~~~~~^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^~^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^G##
##G!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!G##
####################################################################################################

*/

pragma solidity ^0.6.6;

import "ERC721A.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";

contract Infinitiva is Ownable, ERC721A, ReentrancyGuard {
    uint256 public maxSupply = 888;
    uint256 public maxMintPerTx = 10;
    uint256 public price = 0.088 * 10 ** 18;
    bytes32 public whitelistMerkleRoot =
        0xfd3671ea765b3846ec1a574526ccb7950fefcccec0c878d74420bb6de82c1f8f;
    bool public publicPaused = true;
    bool public revealed = false;
    string public baseURI;
    string public hiddenMetadataUri =
        "ipfs://QmXaNptATNK8GDWfuQYFimqHpFtc7HnEWswpkXfaoTcood";

    constructor() public ERC721A("Infinitiva", "INFINITIVA", 888, 888) {}

    function mlnt(
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