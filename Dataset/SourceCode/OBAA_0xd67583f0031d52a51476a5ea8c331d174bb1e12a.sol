//                                           .'`````''''..                       
//                                         ',:"^^``''''......                    
//                                       `!!;:,"^```''.........                  
//                                     'l~>!I;:,"^``'''.......''.                
//                  .......          .,>><>>!I;:,"^```'''..''''''.               
//             .'`^````''''''......'":;li><<>i!I:,,"^^```'''''````               
//          .^:,"^^```'''''......''``^,;!<~~~~<il;;:,""^^^``````^^               
//        'IiI:,"^^````'''.........''`^,;<+_---_~>!l;:,,,"""""""""               
//       !_~iI;:,"^^```'''..........'`^,:<_?][[[[-+<>ilI;;::,,:::`               
//     ._}?+<!I:,,"^^```'''.........''`":!+[{1))11{[]-_+<>i!!iii,                
//     _(1]-~>!I;:,""^^```''''...'''''^":i_})(|\\\|(){}[]]?--?],                 
//    `\|({[-~<iI;:,,""^^````''''''```^,;<?1|/ffjjjff/\/\||||~'                  
//    I\\|)1[?_~i!I;:,,""^^^``````````",l_1/frxxxxxxxxxxxj[,.                    
//    l\//\|1}]-+~>!l;::,,"""^^^^^^^^^":!]|f{~I:::::,"^`.                        
//    ,(\/t/\(){]-_~>ilI;::,,,""""""",,:i?^                                      
//    .)|/fft/\|)}]?_+~>i!I;;:::,,,,,,:I:      OBAA                              
//     ,)\tfjjf/\|){[?-_+~>iii!lII;;IIl;                                         
//      ,)|tfjrjft/\|(1{}[]?_++~~<<<~+I   MILES PEYTON                           
//       ^{|/fjrrrjft/\|()1{{}[[]][[[,                                           
//        .:(/tjrrrrrrjfft//\|||||\i.       2023                                 
//           ^~/fjrrxxxxxxxxrrrr),.                                              
//              '"i?(trxxj/{+;`.                                                 
//                                        
//SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.7;  
  
import "erc721a/contracts/ERC721A.sol";  
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./../DefaultOperatorFilterer.sol";

contract OBAA is ERC721A, DefaultOperatorFilterer, ERC2981, Ownable, ReentrancyGuard {  
    address public pieContractAddress = 0xfb5aceff3117ac013a387D383fD1643D573bd5b4;
    
    address public split;

    string public baseURI;

    bool public baseURILocked = false;

    uint96 private royaltyBps = 1000;

    uint256 public whitelistPrice = 0.035 ether;
    uint256 public publicPrice = 0.04 ether;

    uint256 public pieDiscountPct = 10;

    uint256 public maxSupply = 512;
    uint256 public remainingSeeds = maxSupply;

    uint256[] private seeds;

    bytes32 public whitelistMerkleRoot;

    mapping(address => bool) public gifters;

    uint256[] public obaaSeeds;
    uint256[] public birthdays;

    mapping (uint256 => uint256) public quantityToDiscountPct;
    mapping (uint256 => bool) public quantityHasDiscount;

    bool public mintPaused = true;
    bool public whitelistOnly = true;

    modifier onlyGifter() {
        require(gifters[_msgSender()] || owner() == _msgSender(), "Not a gifter");
        _;
    }

    constructor() ERC721A("OBAA", "OBAA") {
        for (uint256 i = 0; i < maxSupply; i++) {
            seeds.push(i);
        }

        setQuantityDiscount(2, 2);
        setQuantityDiscount(4, 4);
        setQuantityDiscount(8, 8);
        setQuantityDiscount(16, 16);
    }

    function setQuantityDiscount(uint256 _quantity, uint256 _discountPct) public onlyOwner {
        quantityToDiscountPct[_quantity] = _discountPct;
        quantityHasDiscount[_quantity] = true;
    }

    function removeQuantityDiscount(uint256 _quantity) public onlyOwner {
        quantityToDiscountPct[_quantity] = 0;
        quantityHasDiscount[_quantity] = false;
    }

    function updatePieContractAddress(address _address) public onlyOwner {
        pieContractAddress = _address;
    }

    function updatePieDiscountPct(uint256 _discountPct) public onlyOwner {
        pieDiscountPct = _discountPct;
    }

    function updatePublicPrice(uint256 _price) public onlyOwner {
        publicPrice = _price;
    }

    function updateWhitelistPrice(uint256 _price) public onlyOwner {
        whitelistPrice = _price;
    }

    function checkPieHolder(address user) public view returns (bool) {
        IERC721 pieContract = IERC721(pieContractAddress);
        bool hasPie = pieContract.balanceOf(user) > 0;
        return hasPie;
    }

    function getAllSeeds() public view returns (uint256[] memory) {
        return obaaSeeds;
    }

    function getAllBirthdays() public view returns (uint256[] memory) {
        return birthdays;
    }

    function setGifter(address gifter, bool isGifter) public onlyOwner {
        gifters[gifter] = isGifter;
    }

    function updateMerkleRoot(bytes32 _whitelistMerkleRoot) public onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

    function updateMintPaused(bool _mintPaused) public onlyOwner {
        mintPaused = _mintPaused;
    }

    function updateWhitelistOnly(bool _whitelistOnly) public onlyOwner {
        whitelistOnly = _whitelistOnly;
    }

    function generateSeed(uint256 tokenID, address minter) internal returns (uint256) {
        require(remainingSeeds > 0, "All seeds have been generated");

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(tokenID, minter, blockhash(block.number - 1)))) % remainingSeeds;

        uint256 temp = seeds[randomIndex];
        seeds[randomIndex] = seeds[remainingSeeds - 1];
        seeds[remainingSeeds - 1] = temp;

        remainingSeeds -= 1;

        return seeds[remainingSeeds];
    }

    function checkPrice(bool whitelisted, uint256 quantity, address user) public view returns (uint256) {
        uint256 basePrice = whitelisted ? whitelistPrice : publicPrice;

        bool hasPie = checkPieHolder(user);

        uint256 total = basePrice * quantity;

        uint256 discountPct = 0;

        if(hasPie) {
            discountPct += pieDiscountPct;
        }

        if(quantityHasDiscount[quantity]) {
            discountPct += quantityToDiscountPct[quantity];
        }

        uint256 discountAmt = (total * discountPct) / 100;

        total -= discountAmt;

        return total;
    }

    function mintWhitelisted(uint256 quantity, bytes32[] calldata merkleProof) public payable nonReentrant {
        require(!mintPaused, "minting paused");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, whitelistMerkleRoot, leaf), "invalid proof");

        uint256 totalPrice = checkPrice(true, quantity, msg.sender);

        require(msg.value == totalPrice, "did not send correct amount of eth");
        require(totalSupply() + quantity <= maxSupply, "not enough supply");

        uint256 minTokenID = totalSupply();
        uint256 maxTokenID = minTokenID + quantity - 1;

        _safeMint(msg.sender, quantity);

        for(uint256 i = minTokenID; i <= maxTokenID; i++) {
            birthdays.push(block.timestamp);
            obaaSeeds.push(generateSeed(i, msg.sender));
        }
    }

    function mintPublic(uint256 quantity) public payable nonReentrant {
        require(!mintPaused, "minting paused");
        require(!whitelistOnly, "whitelist only");
        require(totalSupply() + quantity <= maxSupply, "max supply reached");

        uint256 totalPrice = checkPrice(false, quantity, msg.sender);

        require(msg.value == totalPrice, "not enough eth sent");

        uint256 minTokenID = totalSupply();
        uint256 maxTokenID = minTokenID + quantity - 1;

        _safeMint(msg.sender, quantity);

        for(uint256 i = minTokenID; i <= maxTokenID; i++) {
            birthdays.push(block.timestamp);
            obaaSeeds.push(generateSeed(i, msg.sender));
        }
    }

    function gift(address[] memory recipients) public onlyGifter {
        require(recipients.length > 0, "no recipients");
        require(totalSupply() + recipients.length <= maxSupply, "max supply reached");

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 thisTokenID = totalSupply();

            _safeMint(recipients[i], 1);

            birthdays.push(block.timestamp);
            obaaSeeds.push(generateSeed(thisTokenID, msg.sender));
        }
    }

    function updateRoyalty(uint96 _royaltyBps) public onlyOwner {
        require(split!=address(0), "split address not set, please set split address before updating royalty");
        royaltyBps = _royaltyBps;
        _setDefaultRoyalty(split, royaltyBps);
    }

    function updateBaseURI(string calldata givenBaseURI) public onlyOwner {
        require(!baseURILocked, "base uri locked");
       
        baseURI = givenBaseURI;
    }

    function lockBaseURI() public onlyOwner {
        baseURILocked = true;
    }

    function tokenURI(uint256 tokenID) public view override returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        require(tokenID < maxSupply - remainingSeeds, "seed not allocated");

        return string(abi.encodePacked(baseURI, Strings.toString(obaaSeeds[tokenID])));
    }
 
    function setSplitAddress(address _address) public onlyOwner {
        split = _address;
        _setDefaultRoyalty(split, royaltyBps);
    }

    function withdraw() public onlyOwner {
        require(split != address(0), "split address not set");

        (bool success, ) = split.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // Opensea Operator filter registry
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        payable
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(
    bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return 
            ERC721A.supportsInterface(interfaceId) || 
            ERC2981.supportsInterface(interfaceId);
    }
}