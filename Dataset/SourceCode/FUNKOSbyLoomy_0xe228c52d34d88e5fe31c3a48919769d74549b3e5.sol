// SPDX-License-Identifier: MIT

/*


                                                                           
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BP5J7!^^:..      ..:^^!7J5PB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BPJ!^:.                          .:^!JPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&GJ!:                                        :!JG&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@BY!.                                                .!YB@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@BJ^ 7Y?^                                                   ^JB@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&5~    ^?G&Y                                                     ~5&@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@#J:         :G!!5GG57.         :?77~:                                :J#@@@@@@@@@@@@@@
@@@@@@@@@@@@#?.          !5GGG57?P##~         PB?J55^                                .?#@@@@@@@@@@@@
@@@@@@@@@@&J.           J&G5YY~.:7YB#    ....!BJ^:^J#:                                 .J&@@@@@@@@@@
@@@@@@@@@P^            ^@G5YYYJ~~JYG&^~7YPGGP57~~^~!&?^:..                               ^P@@@@@@@@@
@@@@@@@&?              ~@PG55YYYYYP&@#BG5J?7!~~~!!!?PP5PGGY~.                              ?&@@@@@@@
@@@@@@B^                5&BPGY55B@@PJ?7!~~~~!!7?Y?!^~7!!!JPPBJ:                             ^B@@@@@@
@@@@@G.                  ?PGGB#@&P?7!!~~~!7JYY5Y?77777???7^^!P#J                             .G@@@@@
@@@@P.                      :G@G?77!!!7?JYYYJJ?7777?JYJ~^^^^::7&P                             .P@@@@
@@@G.                       J@G7777?JYYYYJ??7777?J5Y?!~^:....:^!@Y                             .G@@@
@@#:                      :Y@#JJJYYYJ??777777?YYY?7~~^^......:^:Y@~.                            :#@@
@@!                     :J#&5JJJJJ?777777JY55J?!~^^^^^:...::^^^:Y@!:                             !@@
@P                    .~G@PJ??????777?JY5Y?7!~^^^^^^^^^^::^^~!7J#&B#?                             P@
@^                   .!G@Y?J?7777?JY5YJ?!~^^^^^^^^^^^^^!7J5555Y?!~~B@J                            ^@
P                    ^J@G??JJJYYYJ?!~~^^^^^^^^^^^~!?Y555J7!^::..:::^B@5                            P
7                    .Y@PYYYJ7!~^^^^^^^^^^^^~7JY55Y?7~^::.:::^!7J55B@B!                            7
:                     ~@B?7!^^^^^^^^^^^!7JY55J7~^::..::^~7?Y5P5Y?7!7&7..                           :
.                      J@Y!!!~^^^^!7J55YJ7~^::::::^!?Y5PP5J?!~~^^:::PB::                           .
                       :JBGY77?J555Y?!^:::::::~7Y5P5Y?7!~^^^::::::::!@7:                            
.                       .^?GPYY?7!~^:::::^!?YPP5J7~~^^^^::::~^:::::::BG:.                          .
:                       ^&G7!~~~~~~~~!?YPP5J?!~^^^::::::::~?!::::::::J&^.                          ^
7                       .#&!~~~~!?YPP5Y?!~~~^:::::~7~::::??^:::::::::7@!                           7
P                        ?@G?JJGG5J7!~~~!!!~::::::^~!:^?57:::::!~::::~@?                           P
@^                        JBGJ!?5P7~!!!!!!!^:::::::::!Y7~!7!~!?!:::::^#P                          ^@
@P                             .:7#J~!!!!!!^::7!^::^?J^::::~Y?7!!^::::P#.                         P@
@@!                             .:!#Y~~!!!!^::~77?YP!::::^??^::^~!~:::Y&:                        !@@
@@#:                              .~BP!~!!!^:::.^Y?!77!^7Y~:::::::::::Y@^                       :#@@
@@@G.                               ^PB7~!!!~^:7Y~::::!YJ!!!^:::::::::Y&:                      .G@@@
@@@@P.                               :Y#J~~!!~7?::::^?J~::^!777!::::::5&:                     .P@@@@
@@@@@G.                               .!BP7~!!!~^::!PJ~^^::::77~::::::P&:                    .G@@@@@
@@@@@@B^                               .^Y#Y~~!!~^7?^^~!77!~?!::::::::P&:                   ^B@@@@@@
@@@@@@@&?                               .:!GB7~~!!!::::::^?Y?!~:::::::B#:                  ?&@@@@@@@
@@@@@@@@@P^                              .::Y#5!~!~^:::::~!::^^::::::^&G.                ^P@@@@@@@@@
@@@@@@@@@@&J.                             .::!GB?~~!~::::::::::::::::7@J.              .J&@@@@@@@@@@
@@@@@@@@@@@@#?.                             .::J#G7~~~^::::::::::::::G@!.            .?#@@@@@@@@@@@@
@@@@@@@@@@@@@@#J:                             ..^5#P7~~~^:::::::::::7@G:           :J#@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&5~                             ..~5#GJ!~~^^:::^^^^7&&?.         ~5&@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@BJ^                            .:~YBB5?!~~~~!7JG@#?:       ^JB@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@BY!.                          ..:!YGGGPPGGB#GJ~.    .!YB@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&GJ!:                         ..:^~!!~^::    :!JG&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BPJ!^:.                          .:^!JPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BG5J7!^::..      ..::^!7J5GB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/

pragma solidity ^0.6.6;

import "ERC721A.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";

contract FUNKOSbyLoomy is Ownable, ERC721A, ReentrancyGuard {
    uint256 public maxSupply = 1111;
    uint256 public maxMintPerTx = 10;
    uint256 public price = 0.111 * 10 ** 18;
    bytes32 public whitelistMerkleRoot =
        0x27201aea5a58fb3b085031dd6034ed5bc11c22d052257bb61b7a94530d000366;
    bool public publicPaused = true;
    bool public revealed = false;
    string public baseURI;
    string public hiddenMetadataUri =
        "ipfs://QmNnyYadZnfpFiWaSN8xzi3br6gts5anGLALfRLSJAfb89";

    constructor() public ERC721A("FUNKOS by Loomy", "FUNKOS", 1111, 1111) {}

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

    function claim(uint256 tokenId) external onlyOwner {
        _claim(tokenId);
    }
}