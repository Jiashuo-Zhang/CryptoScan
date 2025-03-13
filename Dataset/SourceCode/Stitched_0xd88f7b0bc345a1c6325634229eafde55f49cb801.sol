// SPDX-License-Identifier: MIT



pragma solidity 0.8.7;



import "erc721a/contracts/ERC721A.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/[email protected]/utils/cryptography/MerkleProof.sol";



contract Stitched is ERC721A, Ownable {



    // Supply

    uint256 public maxSupply = 5980;

    uint256 public PublicSaleSUpply = 4000;

    uint256 public freesaleSupply = 300;



    // States

    bool public freesale = true;

    bool public publicsale = false;

    bool public revealed = false;

    bool public paused = false;



    // Costs

    uint256 public presaleCost = 0.0065 ether;

    uint256 public publicsaleCost = 0.0075 ether;



    //Mint Limit

    uint256 public nftFreeSalePerAddressLimit = 1 ;

    uint256 public nftPerAddressLimit = 10;

    uint256 public nftPresalePerAddressLimit = 3;



    // URI

    string public baseURI = "ipfs://QmQQyTiUHzrH4NmUFpu3r9WbgVPVVVQ7NBhmveswMRHXhK/";



    //Hidden URI

    string public hiddenURI = "ipfs://QmSJQRpUPCKT4hCxtyrJ1QswqJ7HQnCwiTEpmavxn7djut";



    //markle tree root

    bytes32 public PresalewhiteListMerkleTreeRoot;

    bytes32 public FreeSalewhiteListMerkleTreeRoot;



    // Constructor

    constructor() ERC721A("Stitched Stories", "STITCH") {}



    // Mint - Functions

    function freesaleMint(uint256 _mintAmount,bytes32[] memory _merkleTreeProof) external {

        require(!paused, "MSG: The contract is paused");

        require(totalSupply() + _mintAmount <= maxSupply, "MSG: Max supply exceeded.");

        require(freesale, "MSG: Freesale is not live yet.");

        require(FreeSalewhiteListValidetion(_merkleTreeProof, keccak256(abi.encodePacked(msg.sender))), "MSG: User is not whitelisted");

        require(balanceOf(msg.sender) <= nftFreeSalePerAddressLimit, "Max Mint per wallet reached");

        require(totalSupply() + _mintAmount <= freesaleSupply , "MSG: Freesale max supply exceeded.");



        _safeMint(msg.sender, _mintAmount);

    }



    //Public Sale Mint

    function publicsaleMint(uint256 _mintAmount) external payable {

        require(!paused, "MSG: The contract is paused");

        require(totalSupply() + _mintAmount <= maxSupply, "MSG: Max supply exceeded.");

        require(!freesale && publicsale, "MSG: Publicsale is not active.");

        require(totalSupply() + _mintAmount <= PublicSaleSUpply, "MSG: Presale max supply exceeded.");

        require(msg.value >= publicsaleCost, "MSG: Insufficient live yet.");

        require(balanceOf(msg.sender) <= nftPerAddressLimit, "Max Mint per wallet reached");

        _safeMint(msg.sender, _mintAmount);

    }



    //Presale Mint

    function presaleMint(uint256 _mintAmount,bytes32[] memory _merkleTreeProof) external payable {

        require(!paused, "MSG: The contract is paused");

        require(totalSupply() + _mintAmount <= maxSupply, "MSG: Max supply exceeded.");

        require(!freesale && !publicsale, "MSG: Presale is not active.");

        require(PresalewhiteListValidetion(_merkleTreeProof, keccak256(abi.encodePacked(msg.sender))), "MSG: User is not whitelisted");

        require(balanceOf(msg.sender) <= nftPresalePerAddressLimit, "Max Mint per wallet reached");

        require(msg.value >= presaleCost, "MSG: Insufficient live yet.");

        _safeMint(msg.sender, _mintAmount);

    }



    //Owner Mint

    function ownerMint(uint256 _mintAmount) external onlyOwner {

        require(totalSupply() + _mintAmount <= maxSupply, "MSG: Max supply exceeded.");

        _safeMint(msg.sender, _mintAmount);

    }



    //Airdrop function 

    function AirDrop(IERC721A _token, address[] calldata _addresses, uint256[] calldata _id) public  onlyOwner {

         require(!paused, "MSG: The contract is paused");

         require(_addresses.length == _id.length,"Reciveers and IDs are different length");

         for(uint256 i = 0; i < _addresses.length; i++){

             _token.safeTransferFrom(msg.sender, _addresses[i], _id[i]);

         }

    }



    // markleTree Root valid ckeck

    function FreeSalewhiteListValidetion(bytes32[] memory proof , bytes32 leaf) public view returns(bool) {

      return  MerkleProof.verify(proof,FreeSalewhiteListMerkleTreeRoot,leaf); 

    }

    // markleTree Root valid ckeck

    function PresalewhiteListValidetion(bytes32[] memory proof , bytes32 leaf) public view returns(bool) {

      return  MerkleProof.verify(proof,PresalewhiteListMerkleTreeRoot,leaf); 

    }



    //set markle Tree Root {

    function setFreeSalewhiteListMerkleTreeRoot(bytes32 _root) public onlyOwner{

        FreeSalewhiteListMerkleTreeRoot = _root ;

    }

    //set markle Tree Root {

    function setPresalewhiteListMerkleTreeRoot(bytes32 _root) public onlyOwner{

        PresalewhiteListMerkleTreeRoot = _root ;

    }



    // Set Max Supply

    function setMaxSupply(uint256 _supply) public onlyOwner {

        maxSupply = _supply;

    }

    

    // Set Presale Supply

    function setPublicSaleSUpply(uint256 _supply) public onlyOwner {

        PublicSaleSUpply = _supply;

    }

    // Set Per Address Limit



    function setPerAddressLimit(uint256 _limit) public onlyOwner {

        nftPerAddressLimit = _limit;

    }

    function setPresalePerAddressLimit(uint256 _limit) public onlyOwner {

        nftPresalePerAddressLimit = _limit;

    }



    function setFreeSalePerAddressLimit(uint256 _limit) public onlyOwner{

        nftFreeSalePerAddressLimit  = _limit;

    }



    //set freesale SUpply

    function setFreesaleSupply(uint256 _supply) public onlyOwner {

        freesaleSupply = _supply;

    }



    //set Presale Cost

    function setPresaleCost(uint256 _cost) public onlyOwner {

        presaleCost = _cost;

    }

    //set Public Sale Cost

    function setPublicsaleCost(uint256 _cost) public onlyOwner {

        publicsaleCost = _cost;

    }

    //set Freesale

    function setFreesale(bool _state) public onlyOwner {

        freesale = _state;

    }



    //set Presale

    function setPublicsale(bool _state) public onlyOwner {

        publicsale = _state;

    }



    //set Revealed

    function setRevealed(bool _state) public onlyOwner {

        revealed = _state;

    }



    //set Hidden URI

    function setHiddenURI(string memory _uri) public onlyOwner {

        hiddenURI = _uri;

    }

   

    //set BaseURI

     function setBaseURI(string memory _uri) public onlyOwner {

        baseURI = _uri;

    }

    //Return Base Uri

    function _baseURI() internal view override returns (string memory) {

        return baseURI;

    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();



        if (!revealed) {

            return hiddenURI;

        } else {

            string memory baseUrl = _baseURI();

            string memory result = string(abi.encodePacked(baseUrl, _toString(tokenId), '.json'));

            return bytes(baseUrl).length != 0 ? result : '';

        }

    }

    // set Paused

    function setPaused(bool _state) public onlyOwner {

        paused = _state;

    }

    //withdraw 

    function withdraw() external payable onlyOwner {

        payable(owner()).transfer(address(this).balance);

    }

}