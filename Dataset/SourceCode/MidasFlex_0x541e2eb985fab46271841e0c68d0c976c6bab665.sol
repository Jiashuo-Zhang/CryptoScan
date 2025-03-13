// SPDX-License-Identifier: MIT

/*

                                                                                                  
                                                   dddddddd                                       
MMMMMMMM               MMMMMMMM  iiii              d::::::d                                       
M:::::::M             M:::::::M i::::i             d::::::d                                       
M::::::::M           M::::::::M  iiii              d::::::d                                       
M:::::::::M         M:::::::::M                    d:::::d                                        
M::::::::::M       M::::::::::Miiiiiii     ddddddddd:::::d   aaaaaaaaaaaaa      ssssssssss        
M:::::::::::M     M:::::::::::Mi:::::i   dd::::::::::::::d   a::::::::::::a   ss::::::::::s       
M:::::::M::::M   M::::M:::::::M i::::i  d::::::::::::::::d   aaaaaaaaa:::::ass:::::::::::::s      
M::::::M M::::M M::::M M::::::M i::::i d:::::::ddddd:::::d            a::::as::::::ssss:::::s     
M::::::M  M::::M::::M  M::::::M i::::i d::::::d    d:::::d     aaaaaaa:::::a s:::::s  ssssss      
M::::::M   M:::::::M   M::::::M i::::i d:::::d     d:::::d   aa::::::::::::a   s::::::s           
M::::::M    M:::::M    M::::::M i::::i d:::::d     d:::::d  a::::aaaa::::::a      s::::::s        
M::::::M     MMMMM     M::::::M i::::i d:::::d     d:::::d a::::a    a:::::assssss   s:::::s      
M::::::M               M::::::Mi::::::id::::::ddddd::::::dda::::a    a:::::as:::::ssss::::::s     
M::::::M               M::::::Mi::::::i d:::::::::::::::::da:::::aaaa::::::as::::::::::::::s      
M::::::M               M::::::Mi::::::i  d:::::::::ddd::::d a::::::::::aa:::as:::::::::::ss       
MMMMMMMM               MMMMMMMMiiiiiiii   ddddddddd   ddddd  aaaaaaaaaa  aaaa sssssssssss         
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
FFFFFFFFFFFFFFFFFFFFFFlllllll                                                                     
F::::::::::::::::::::Fl:::::l                                                                     
F::::::::::::::::::::Fl:::::l                                                                     
FF::::::FFFFFFFFF::::Fl:::::l                                                                     
  F:::::F       FFFFFF l::::l     eeeeeeeeeeee  xxxxxxx      xxxxxxx                              
  F:::::F              l::::l   ee::::::::::::ee x:::::x    x:::::x                               
  F::::::FFFFFFFFFF    l::::l  e::::::eeeee:::::eex:::::x  x:::::x                                
  F:::::::::::::::F    l::::l e::::::e     e:::::e x:::::xx:::::x                                 
  F:::::::::::::::F    l::::l e:::::::eeeee::::::e  x::::::::::x                                  
  F::::::FFFFFFFFFF    l::::l e:::::::::::::::::e    x::::::::x                                   
  F:::::F              l::::l e::::::eeeeeeeeeee     x::::::::x                                   
  F:::::F              l::::l e:::::::e             x::::::::::x                                  
FF:::::::FF           l::::::le::::::::e           x:::::xx:::::x                                 
F::::::::FF           l::::::l e::::::::eeeeeeee  x:::::x  x:::::x                                
F::::::::FF           l::::::l  ee:::::::::::::e x:::::x    x:::::x                               
FFFFFFFFFFF           llllllll    eeeeeeeeeeeeeexxxxxxx      xxxxxxx                              
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                  
                                                                                                 

*/

pragma solidity ^0.8.0;

import "ERC721A.sol";
import "DefaultOperatorFilterer.sol";
import "Ownable.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";
import "Strings.sol";

contract MidasFlex is
    Ownable,
    ERC721A,
    ReentrancyGuard,
    DefaultOperatorFilterer
{
    uint256 public price = 0.111 * 10 ** 18;
    uint256 public maxSupply = 1111;
    uint256 public maxMintPerTx = 5;
    bytes32 public whitelistMerkleRoot =
        0x82ff7763d44a1ae30e5e08058e4104119a2b26310bde4d38717f2e5de83b6130;
    bool public publicPaused = true;
    bool public revealed = false;
    string public baseURI;
    string public hiddenMetadataUri =
        "ipfs://QmUPdLVpf7HzxECvwd5mUrbSjp6UDyQJZkqa4MUBxcMrjV";

    constructor() ERC721A("Midas Flex", "FLEX") {}

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

    function whitelist(
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