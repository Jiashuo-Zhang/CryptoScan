/*__  __      _        _   _______          _                                       _____              

 |  \/  |    | |      | | |__   __|        | |         /\                          |  __ \             

 | \  / | ___| |_ __ _| |    | | ___   ___ | |___     /  \   ___ ___ ___  ___ ___  | |__) |_ _ ___ ___ 

 | |\/| |/ _ \ __/ _` | |    | |/ _ \ / _ \| / __|   / /\ \ / __/ __/ _ \/ __/ __| |  ___/ _` / __/ __|

 | |  | |  __/ || (_| | |    | | (_) | (_) | \__ \  / ____ \ (_| (_|  __/\__ \__ \ | |  | (_| \__ \__ \

 |_|  |_|\___|\__\__,_|_|    |_|\___/ \___/|_|___/ /_/    \_\___\___\___||___/___/ |_|   \__,_|___/___/

                                                                                                        */

// SPDX-License-Identifier: MIT



pragma solidity >=0.8.9 <0.9.0;



import 'erc721a/contracts/ERC721A.sol';

import '@openzeppelin/contracts/access/Ownable.sol';

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

import '@openzeppelin/contracts/utils/Strings.sol';

import 'operator-filter-registry/src/DefaultOperatorFilterer.sol';



contract MetalToolsAccessPass is ERC721A, Ownable, ReentrancyGuard, DefaultOperatorFilterer {

    using Strings for uint256;



    string public baseURI = "ipfs://bafybeibowothvelpjflot4k2ndlpot6h4a3zuag47h3zxbnirevpun22gy/";

    string public baseExtension = ".json";

    uint256 public cost = 0.5 ether;

    uint256 public maxSupply = 230;

	uint256 public maxPublicSupply = 200;

	uint256 public maxTeamSupply = 30;

	uint256 public teamMintedCount = 0;

	uint256 public totalMintedCount = 0;

    uint256 public maxMintAmount = 3;



    mapping(address => uint256) public addressMintedBalance;



    uint256 public currentState = 0;

  

    constructor() ERC721A("Metal Tools Access Pass", "MTOOLS") {}



    function mint(uint256 _mintAmount) public payable {

        require(_mintAmount > 0, "need to mint at least 1 NFT");

        require(totalMintedCount + _mintAmount <= maxPublicSupply, "max NFT limit exceeded");

		require(_mintAmount <= maxSupply, "maxSupply limit exceeded");

        if (msg.sender != owner()) {

            require(currentState > 0, "the contract is paused");

            if (currentState == 1) {

                uint256 ownerMintedCount = addressMintedBalance[msg.sender];

                require(_mintAmount <= maxMintAmount,"max mint amount per session exceeded");

                require(ownerMintedCount + _mintAmount <= maxMintAmount,"max NFT per address exceeded");

                require(msg.value >= cost * _mintAmount, "insufficient funds");

            }

        }



        _safeMint(msg.sender, _mintAmount);

		totalMintedCount += _mintAmount;

        if (currentState == 1) {

            addressMintedBalance[msg.sender] += _mintAmount;

        }

    }

	

    function TeamMint(uint256 _mintAmount, address _receiver) public onlyOwner {

	    require(_mintAmount > 0, "need to mint at least 1 NFT");

        require(teamMintedCount + _mintAmount <= maxTeamSupply, "max team NFT limit exceeded");

		require(_mintAmount <= maxSupply, "maxSupply limit exceeded");

        teamMintedCount += _mintAmount;

        _safeMint(_receiver, _mintAmount);

    }



    function mintableAmountForUser(address _user) public view returns (uint256) {

        if (currentState == 1) {

            return maxMintAmount - addressMintedBalance[_user];

        }

        return 0;

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return baseURI;

    }

	

    function _startTokenId() internal view virtual override returns (uint256) {

        return 1;

    }

	

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require( _exists(tokenId), "ERC721Metadata: URI query for nonexistent token" );

        string memory currentBaseURI = _baseURI();

        return

            bytes(currentBaseURI).length > 0

                ? string( abi.encodePacked( currentBaseURI, tokenId.toString(), baseExtension ) ) : "";

    }



    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {

        maxMintAmount = _newmaxMintAmount;

    }

	

	function setmaxTeamSupply(uint256 _newmaxTeamSupply) public onlyOwner {

        maxTeamSupply = _newmaxTeamSupply;

    }

	

	function setmaxSupply(uint256 _newmaxSupply) public onlyOwner {

        maxSupply = _newmaxSupply;

    }



    function setBaseURI(string memory _newBaseURI) public onlyOwner {

        baseURI = _newBaseURI;

    }



    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {

        baseExtension = _newBaseExtension;

    }



    function setCost(uint256 _price) public onlyOwner {

        cost = _price;

    }



    function pause() public onlyOwner {

        currentState = 0;

    }



    function SetPublic() public onlyOwner {

        currentState = 1;

    }



    function withdraw() public onlyOwner nonReentrant {

        (bool os, ) = payable(owner()).call{value: address(this).balance}('');

        require(os);

    }



    /////////////////////////////

    // OPENSEA FILTER REGISTRY 

    /////////////////////////////



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



}