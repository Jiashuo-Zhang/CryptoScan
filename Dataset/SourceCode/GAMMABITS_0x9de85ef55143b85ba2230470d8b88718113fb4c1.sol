// SPDX-License-Identifier: MIT

/*

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&##BGPPPYJJYY?JY55PPPPGGB#&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#BBGPP55J???77!777!!!77???JYYY55PPPGB&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@&BPP55YYJ?77!~^^:::::::^^:^^::::^^^~!7??JJJY5GB&@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@&BPYJJ?7!!~~^^^::^~~~~~!777??7??7!!~~~^:::::^^^~7YYY5GB&@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@&#G5YJ?7~~^::::^~~7?JYYYYYYY55555Y5YYYJJJ?777!~~^::^^~!?JY5PB&@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@#G5YY?7~^::^^~!777?J5PP55PP55PPPPPP55555555YYYJ????7!~^:::^!?JJYG#@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@&BP5YJ7~::::^~7?JJYYY55PPGGGPPPPPPPPPPPPPPPPP55555YYYYYJ??7!^:::^~?JJ5G&@@@@@@@@@@@@@@
@@@@@@@@@@@@&G5YYJ!^::^~!7?JJ???J55P5PPPPPPPPPPPPPGGPPPPPPPP5PP5555YYJ????7!~^^^^~7JJYG&@@@@@@@@@@@@
@@@@@@@@@@@#P5Y?!^::^!7?77?7~::^?Y5555PP5PPPPPPPPPGGPPPPPPPPPP55555J7^:^~!????7!^^^:~?JYB@@@@@@@@@@@
@@@@@@@@@#P5YJ!^::~!?JJ?7~^:::::^7YY55PP5PPPPPPPPPGGPPPPPPPPP555YYJ!::::::^!7??J?!:..:!JJP#@@@@@@@@@
@@@@@@@@B55J7^::^!?777!~:::.:::::^7JYY555555PPPPPPPPPPPPPP5555YYJ?~.::::::::^~7?J?7~:.:~7YYP@@@@@@@@
@@@@@@&P55J~:.:!?J?7!^:..:::::^::::~?JYY55555PPPPPPPPPPPPP55YYYJ7^:.::::::::..:~7??7!^::^!??5&@@@@@@
@@@@@&PYY?^..^7JJ?7^:::.::::::::::::^7JYYY55555PPPP5PPPPP555YJJ!^::::::::::::::.:~7??7!^::~JY5&@@@@@
@@@@#PYJ7^::~7???~:..::::::::::::::..^7?JYYY55555555PPP5555YJJ!:.::::::::..:::::::^7?77~^^:~JY5#@@@@
@@@&5YJ!:::~7??7~::::::::::::::.::..:::!??JYY5555555555555YJ?!:::::::::::..:::::::.:!??!~:::^7J5#@@@
@@&5YJ7:::~????~^::::..::::::::.....::::~7?JYYYY555YYYY5YJJ7~:::::::::.:::::::...::.:!??7~:::^7?5&@@
@@PYY?~::^7?J?^:::::...:....::.:.::::::..^7JJYYYYYYYYYJJJ?7^..::::::::..:::.:::....:::!??7!^::~?JP@@
@#YYJ!^:^7??J7^::::^:::.::::::.:.:::.::...^!??JJYJJJJJ??7!:::^^::..:::.....::::::..::::!??7~::^7J?B@
@5JJ7:::~7??7^::::::::::::::^:...:::::.:::.:~7????JJJJ?7~..::::....:::::....::::.::::::^7?77~:^~??Y@
#YJ?~::^7???^..:::::::::::::::.:.::::..::..:~7??77????7!^:....:......:::.....:::::::::::~??7!::^7JJ#
5?J?^::^~7?7^::.::::::::::::....::::..::.:~!7!!~^^^^^~!!7!^:.........::....:....::::::::^7J?!^^^!JYG
5JJ7:::~~!7~:.:::::::::::::::...:...::::^!!!~:.........^!!!~:::::...::::....:::::.....:::!??7~::^?J5
YJ?~::^!777:..:::.::::::::....:..::..:.:~!!~::...:....:::~!!^..::....::::::.::...:::^:::.~?7!!:::7JY
5J7!::^7?J?~~~~^^^^^^^^^^^^^^^^^^^^^^^^^!!!:..........::.^!7!^^^^^^^^^^^^^^^^^^^^^^^^^^~~!777^..:!?J
YJ?!:::!7YYY5YYYJJJJJJJJ??????7777??777???7^::::....::..:~!777??JJ?????????????JJJ???JJJJ???7~:::!?J
Y??!:::~!JY55555555555YYJJJJJJ??JJJ???????77~::......:::~77?????JJYYJJJJJJJJJJYYYYYYYYYYYY?77~:::7?Y
GJ?7:::~7JY55555PPPPPP555YYYYJJJJJJJJJJ???777!^::::::^~77???JJJJJJJYYYYYYYY5YYY5555YYY5YYJ7!!~:.^?JP
#5YJ^::^7JYY5PPPPPPPPP55555Y5YYYJJJJJJJJ???7777!!!!!7777????JJJYYYYYYY5Y5555555PP5555555YJ?7~:::!JJ#
@PYJ7:::!?Y5PPPPPGGPPPP55555555YYJYYJJJJJ?77^:^^~~~^^^^^~7???JJYYYY555555555P5555P5555555Y?7^.:^?J5@
@BJJ?~::^?JY5GGPPPPPPPPPPP5PP55YYJJJJJ???7!::::::....::::^!????JJYYYY5555555P55555555555YY?!:::!JY#@
@@GYY?^::~7?J5PP5PPPPPPGPPPPPP5YYYYJJJ??7~:.:::::.....::..^!7??JJJYYYY555555555PPP555555J?7^^^^?JG@@
@@&PYJ!:.:~?JY5PPPGPP5PPPP555P5YYYYJJ??7~:::..::::...:::...:~7??J?JYYY5555PPP555PP5555YY?7^:.:7J5&@@
@@@&5YJ!::^!7?Y55PPPP55555555P5YYYYJ??7^:::::.:::..:.:::....:~7???YYYY555555P555PP5555YJ7~:::7J5&@@@
@@@@#5YJ!:::!J?J5555PP5PP5555P5YYYJJ?!^::::::..:::::.:..::::..~7??JYYYY5555555555P555Y?!~^::7J5#@@@@
@@@@@&PYY7::^!7?JY55555PPPP55P5YYYJ?!:.::.....::::::::::::^::.:~7?JYYYY555555555555Y?!~^:^^7J5#@@@@@
@@@@@@&P5Y7^^:^!?Y55YY555P55555YYJ?!::::::::::::::..:::::::^::::^7?JJYYYY5555P5555Y?!^:::!JYP&@@@@@@
@@@@@@@@B5Y?~:..~7JJYYYY55555YYYJ?!::::^^^^:^:::::::::.....::..:::!JJYYY5555555YJJ?!^::^7Y5G@@@@@@@@
@@@@@@@@@&GYJ!^::^!7?YY5Y5555YYY?~::::::::::::::::::.::..:::::::.::!JJY55PP555J?!~^:::!J5P#@@@@@@@@@
@@@@@@@@@@@B5JJ!^:::~7?JYY5YYYJ?^:::::::::::::::::::::::::::::^:::::~?YY5P55YJ7!^:::~7YPB@@@@@@@@@@@
@@@@@@@@@@@@&B5J?!^..:^~7JJJJJ?~::.:::::::::::::::::::::::^:..:::.:::!JJJJJ??!^:::~?Y5B@@@@@@@@@@@@@
@@@@@@@@@@@@@@&B5YJ7~:::^~!77??77!~^^:::::::...::::::::.:::::::^^^~!??J?7!~^:::^7?J5B&@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@#PJJJ?!^::^^~!77777777!~~~^^^:::^^^::^^^^~!!777777777!^::.:^~7YPG#@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@&BPP5J7~^::::^~~!!7??77????77??????????777?7!!!~^:::.:~7?Y5P#&@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@&#GYY?7!!~:::::^^~~!!!!!!77?7777777!!!~^::::::^~!?JYPG#&@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&#BP5YJ?77!~~^^:::^^:::::^::::^^::::^^~~!7?JY5PB&@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#BGG55YYJ????77!!~~~~~~!!7777?JJYY5PG#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&#BGGGPP5P555555555PPGGB##&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


*/

pragma solidity ^0.8.0;

import "ERC721A.sol";
import "DefaultOperatorFilterer.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";
import "Strings.sol";

contract GAMMABITS is
    Ownable,
    ERC721A,
    ReentrancyGuard,
    DefaultOperatorFilterer
{
    uint256 public price = 0.111 * 10 ** 18;
    uint256 public maxSupply = 2222;
    uint256 public maxMintPerTx = 10;
    bytes32 public whitelistMerkleRoot =
        0x8d2617f47712918c1a97962dec3948347d8d4651836560622ffd7778afb3153d;
    bool public publicPaused = true;
    bool public revealed = false;
    string public baseURI;
    string public hiddenMetadataUri =
        "ipfs://QmPWc5eLCuxgbMtBH29iDVArU3EvzHoQNB4pjVG5xd3s3A";

    constructor() ERC721A("GAMMA BITS", "GAMMA") {}

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

    function claim(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
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
                ? string(
                    abi.encodePacked(currentBaseURI, Strings.toString(_tokenId))
                )
                : "";
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // OVERRIDDEN PUBLIC WRITE CONTRACT FUNCTIONS: OpenSea's Royalty Filterer Implementation. //

    function approve(
        address operator,
        uint256 tokenId
    ) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
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

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }
}