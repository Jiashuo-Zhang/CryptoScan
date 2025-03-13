// SPDX-License-Identifier: Unlicensed



/*

&&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#%######################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&%%

&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%########################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#############################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#######################################################################################################################%#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%########################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#%###########################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%################################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#%##################################################(###(((((((((((((((((((((((((((##################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##################################################(((((((((((((((((((((((((((((((((((##################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###############################################((((((((((((((((((((((((((((((((((((((((((((#############################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#############################################(((((((((((((((((((((((((((((((((((((((((((((((((##(((#########################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##########################################(((((((((((((((((((((((((((((((((((((((((((((((((((####((#(#######%%##############################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%###########################################(((((((((((((((((((((((((#%##(((((((((((((((((((##%&&&&&&&&&&&&&&&&&################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%###########################################((((((((#(((((((((#%%%&&@&%#(#@@@@@@@&&&&%%&@@@@@@@@@&&&&&&&&&&&&&&@&#################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%######################################(##(((((((((((((#&@@@@@@@@@@@@@@&@&@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@&&&&&@@##################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%#%######################################(#(((((((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&&&&#####################################%#%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################((((((((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@&&&@&&####################################%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################((((((((#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%&&%@@@@&%(######################################%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################(((((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@&&@@@@@@@&&%&@%#&@&@&&(((###################################%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%######################################((((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@@@@@@@@#(##################################%%#%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%#####################################(((((&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%(##################################%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%####################################(((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&%&&&@@@@@@@@@@@@@@@@&&%(///#%#(##################################%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%####################################(((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&%%##((%%&@@@@@@@@@@@@@&(///(%%(((((###############################%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%#####################################(((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&@%%&@@@%((#&@@@@@&%%&&%%#(((((//%(((#################################%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%####################################(((((#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@&%#(##(((((((((((#(((///&((##################################%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%####################################(((((#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#(((############(///***#&(((#################################%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%#####################################(((((&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%/////(((//////*****(&&(#(#################################%%#%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%######################################(((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%(/#@%(###################################%%#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################(#((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#//#@######################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################(#(((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#/,,,,/(&@%######################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################((#(((#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@&%(////#%@@@%(####################################%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%######################################((((##(#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%/(&@@@@@@&#########################################%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%######################################(((((((((##&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%#**(@@@@@@%(####################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#########################################((((((((((((#%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*,**(@@@@@#######################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#########################################((((((((((((((((#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%//%@@@#(#########################################%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%############################################((((((((((((((((#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%#############################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##%##############################################((#((((((##((#(((#%&@@@@@@@@@@@@@@@@@@@@@&(#(###(#######################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#####################################################(((((((((((((((((((####%%&@@@@@@@%##(##(##########################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%########################################################((((((#((((((((#########################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#################################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%##########################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%########################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#################################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###########################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

&&&&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#%%%#################################################################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&

*/



import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "erc721a/contracts/ERC721A.sol";

import "@openzeppelin/contracts/token/common/ERC2981.sol";



pragma solidity >=0.8.17 <0.9.0;



contract DingusBakeryNFT is

    ERC721A,

    Ownable,

    ReentrancyGuard,

    DefaultOperatorFilterer,

    ERC2981

{

    using Strings for uint256;





    bytes32 public merkleRoot;

    string internal uri;

    string public uriExtension = ".json";

    string public hiddenMetadataUri;

    uint256 public wlprice = 0.0069 ether;

    uint256 public supplyLimit = 6969;

    uint256 public wlmaxMintAmountPerTx = 3;

    uint256 public wlmaxLimitPerWallet = 3;

    bool public whitelistSale = false;

    bool public revealed = false;

    mapping(address => uint256) public wlMintCount;

    uint96 internal royaltyFraction = 500; 

    address internal royaltiesReciever =

        0xE237B09711A390BF1295bA4dab0d2e1958b11920;

    uint256 public publicmaxMintAmountPerTx = 3;

    uint256 public publicprice = 0.0096 ether;

    uint256 public publicmaxLimitPerWallet = 3;

    bool public publicSale = false;

    mapping(address => uint256) public publicMintCount;





    constructor(string memory _uri) ERC721A("DingusBakeryNFT", "DNGSBKRYNFT") {

        seturi(_uri);

        setRoyaltyInfo(royaltiesReciever, royaltyFraction);

    }



    function WhitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)

        public

        payable

        nonReentrant

    {

        // Verify wl requirements

        require(whitelistSale, "The loaf sale is paused!");

        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));

        require(

            MerkleProof.verify(_merkleProof, merkleRoot, leaf),

            "Invalid proof!"

        );



        // Normal requirements

        require(

            _mintAmount > 0 && _mintAmount <= wlmaxMintAmountPerTx,

            "Invalid mint amount!"

        );

        require(

            totalSupply() + _mintAmount <= supplyLimit,

            "Max Dingus exceeded!"

        );

        require(

            wlMintCount[msg.sender] + _mintAmount <= wlmaxLimitPerWallet,

            "Max mint per Loafwallet exceeded!"

        );

        require(msg.value >= wlprice * _mintAmount, "Insufficient funds!");



        // Mint

        _safeMint(_msgSender(), _mintAmount);



        // Mapping update

        wlMintCount[msg.sender] += _mintAmount;

    }



    function PublicMint(uint256 _mintAmount) public payable nonReentrant {

        // Normal requirements

        require(publicSale, "The PublicSale is paused!");

        require(

            _mintAmount > 0 && _mintAmount <= publicmaxMintAmountPerTx,

            "Invalid mint amount!"

        );

        require(

            totalSupply() + _mintAmount <= supplyLimit,

            "Max Dingus exceeded!"

        );

        require(

            publicMintCount[msg.sender] + _mintAmount <=

                publicmaxLimitPerWallet,

            "Max mint per wallet exceeded!"

        );

        require(msg.value >= publicprice * _mintAmount, "Insufficient funds!");



        // Mint

        _safeMint(_msgSender(), _mintAmount);



        // Mapping update

        publicMintCount[msg.sender] += _mintAmount;

    }



    function TeamMint(uint256 _mintAmount, address _receiver) public onlyOwner {

        require(

            totalSupply() + _mintAmount <= supplyLimit,

            "Max supply exceeded!"

        );

        _safeMint(_receiver, _mintAmount);

    }



    function MassAirdrop(address[] calldata receivers) external onlyOwner {

        for (uint256 i; i < receivers.length; ++i) {

            require(totalSupply() + 1 <= supplyLimit, "Max supply exceeded!");

            _mint(receivers[i], 1);

        }

    }





    function setRevealed(bool _state) public onlyOwner {

        revealed = _state;

    }



    function seturi(string memory _uri) public onlyOwner {

        uri = _uri;

    }



    function seturiExtension(string memory _uriExtension) public onlyOwner {

        uriExtension = _uriExtension;

    }



    function setHiddenMetadataUri(string memory _hiddenMetadataUri)

        public

        onlyOwner

    {

        hiddenMetadataUri = _hiddenMetadataUri;

    }



    function setwlSale() public onlyOwner {

        whitelistSale = !whitelistSale;

    }



    function setpublicSale() public onlyOwner {

        publicSale = !publicSale;

    }



    function setwlMerkleRootHash(bytes32 _merkleRoot) public onlyOwner {

        merkleRoot = _merkleRoot;

    }



    function setwlmaxMintAmountPerTx(uint256 _wlmaxMintAmountPerTx)

        public

        onlyOwner

    {

        wlmaxMintAmountPerTx = _wlmaxMintAmountPerTx;

    }



    function setpublicmaxMintAmountPerTx(uint256 _publicmaxMintAmountPerTx)

        public

        onlyOwner

    {

        publicmaxMintAmountPerTx = _publicmaxMintAmountPerTx;

    }



    function setwlmaxLimitPerWallet(uint256 _wlmaxLimitPerWallet)

        public

        onlyOwner

    {

        wlmaxLimitPerWallet = _wlmaxLimitPerWallet;

    }



    function setpublicmaxLimitPerWallet(uint256 _publicmaxLimitPerWallet)

        public

        onlyOwner

    {

        publicmaxLimitPerWallet = _publicmaxLimitPerWallet;

    }



    function setwlPrice(uint256 _wlprice) public onlyOwner {

        wlprice = _wlprice;

    }



    function setpublicPrice(uint256 _publicprice) public onlyOwner {

        publicprice = _publicprice;

    }



    function setsupplyLimit(uint256 _supplyLimit) public onlyOwner {

        supplyLimit = _supplyLimit;

    }



    function setRoyaltyTokens(

        uint256 _tokenId,

        address _receiver,

        uint96 _royaltyFeesInBips

    ) public onlyOwner {

        _setTokenRoyalty(_tokenId, _receiver, _royaltyFeesInBips);

    }



    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips)

        public

        onlyOwner

    {

        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);

    }





    function withdraw() public onlyOwner nonReentrant {

        //owner withdraw

        (bool os, ) = payable(owner()).call{value: address(this).balance}("");

        require(os);

    }





    function tokensOfOwner(address owner)

        external

        view

        returns (uint256[] memory)

    {

        unchecked {

            uint256[] memory a = new uint256[](balanceOf(owner));

            uint256 end = _nextTokenId();

            uint256 tokenIdsIdx;

            address currOwnershipAddr;

            for (uint256 i; i < end; i++) {

                TokenOwnership memory ownership = _ownershipAt(i);

                if (ownership.burned) {

                    continue;

                }

                if (ownership.addr != address(0)) {

                    currOwnershipAddr = ownership.addr;

                }

                if (currOwnershipAddr == owner) {

                    a[tokenIdsIdx++] = i;

                }

            }

            return a;

        }

    }



    function _startTokenId() internal view virtual override returns (uint256) {

        return 1;

    }



    function tokenURI(uint256 _tokenId)

        public

        view

        virtual

        override

        returns (string memory)

    {

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

                    abi.encodePacked(

                        currentBaseURI,

                        _tokenId.toString(),

                        uriExtension

                    )

                )

                : "";

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return uri;

    }



    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public payable override onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

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



    function setApprovalForAll(address operator, bool approved)

        public

        override

        onlyAllowedOperatorApproval(operator)

    {

        super.setApprovalForAll(operator, approved);

    }



    function approve(address operator, uint256 tokenId)

        public

        payable

        override

        onlyAllowedOperatorApproval(operator)

    {

        super.approve(operator, tokenId);

    }



    function supportsInterface(bytes4 interfaceId)

        public

        view

        virtual

        override(ERC721A, ERC2981)

        returns (bool)

    {

        return

            ERC721A.supportsInterface(interfaceId) ||

            ERC2981.supportsInterface(interfaceId);

    }





}