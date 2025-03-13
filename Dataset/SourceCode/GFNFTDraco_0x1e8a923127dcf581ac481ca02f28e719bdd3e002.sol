// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



import "ERC721A.sol";

import "Ownable.sol";

import "MerkleProof.sol";



contract GFNFTDraco is ERC721A, Ownable {

    using Strings for uint256;



    string public baseURI;



    bool public public_mint_status = true;

    bool public wl_mint_status = true;    

    bool public paused = false;



    uint256 MAX_SUPPLY = 2000;



    string public notRevealedUri;

    

    bool public revealed = false;



    uint256 public whitelistCost = 0.01 ether;

    uint256 public publicSaleCost = 0.1 ether;

    uint256 public max_per_wallet = 2000;



    uint256 public total_PS_count;

    uint256 public total_wl_count;



    uint256 public total_PS_limit = 2000;

    uint256 public total_wl_limit = 2000;

    

    bytes32 public whitelistSigner;



    constructor(string memory _initBaseURI, string memory _initNotRevealedUri) ERC721A("GFNFT Draco", "GFNFT") {

    

    setBaseURI(_initBaseURI);

    setNotRevealedURI(_initNotRevealedUri);   

    mint(1); 

    }



    function airdrop(address[] calldata receiver, uint256[] calldata quantity) public payable onlyOwner {

  

        require(receiver.length == quantity.length, "Airdrop data does not match");



        for(uint256 x = 0; x < receiver.length; x++){

        _safeMint(receiver[x], quantity[x]);

        }

    }



    function mint(uint256 quantity) public payable  {

        require(totalSupply() + quantity <= MAX_SUPPLY,"No More NFTs to Mint");



        if (msg.sender != owner()) {



            require(!paused, "The contract is paused");

            require(public_mint_status, "Public mint status is off");



            require(balanceOf(msg.sender) + quantity <= max_per_wallet, "Per Wallet Limit Reached");



                require(total_PS_count + quantity <= total_PS_limit, "Public Sale Limit Reached");  

                require(msg.value >= (publicSaleCost * quantity), "Not Enough ETH Sent");  

                total_PS_count = total_PS_count + quantity;

           

        }



        _safeMint(msg.sender, quantity);

        

        }

   

    // whitelist minting 



   function whitelistMint(bytes32[] calldata  _proof, uint256 quantity) payable public{



   require(totalSupply() + quantity <= MAX_SUPPLY, "Not enough tokens left");

   require(wl_mint_status, "whitelist mint is off");

   require(balanceOf(msg.sender) + quantity <= max_per_wallet,"Per wallet limit reached");

   require(total_wl_count + quantity <= total_wl_limit, "Whitelist Limit Reached");



   require(msg.value >= whitelistCost * quantity, "insufficient funds");



   bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

   require(MerkleProof.verify(_proof,leaf,whitelistSigner),"Invalid Proof");

   total_wl_count = total_wl_count + quantity; 

   _safeMint(msg.sender, quantity);

  

  }





    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();



        if(revealed == false) {

        return notRevealedUri;

        }

      

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : '';

    }







    function _baseURI() internal view override returns (string memory) {

        return baseURI;

    }





    //only owner      

    

    function toggleReveal() public onlyOwner {

        

        if(revealed==false){

            revealed = true;

        }else{

            revealed = false;

        }

    }   



    function toggle_paused() public onlyOwner {

        

        if(paused==false){

            paused = true;

        }else{

            paused = false;

        }

    } 

        

    function toggle_public_mint_status() public onlyOwner {

        

        if(public_mint_status==false){

            public_mint_status = true;

        }else{

            public_mint_status = false;

        }

    }  



    function toggle_wl_mint_status() public onlyOwner {

        

        if(wl_mint_status==false){

            wl_mint_status = true;

        }else{

            wl_mint_status = false;

        }

    } 



    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {

        notRevealedUri = _notRevealedURI;

    }

  

    function setWhitelistSigner(bytes32 newWhitelistSigner) external onlyOwner {

        whitelistSigner = newWhitelistSigner;

    }

   

    function withdraw() public payable onlyOwner {

  

    (bool main, ) = payable(owner()).call{value: address(this).balance}("");

    require(main);

    }



    function setWhitelistCost(uint256 _whitelistCost) public onlyOwner {

        whitelistCost = _whitelistCost;

    }

    

    function setPublicSaleCost(uint256 _publicSaleCost) public onlyOwner {

        publicSaleCost = _publicSaleCost;

    }



    function set_total_PS_limit(uint256 _total_PS_limit) public onlyOwner {

        total_PS_limit = _total_PS_limit;

    }



    function set_total_wl_limit(uint256 _total_wl_limit) public onlyOwner {

        total_wl_limit = _total_wl_limit;

    }



    function setMax_per_wallet(uint256 _max_per_wallet) public onlyOwner {

        max_per_wallet = _max_per_wallet;

    }



    function setMAX_SUPPLY(uint256 _MAX_SUPPLY) public onlyOwner {

        MAX_SUPPLY = _MAX_SUPPLY;

    }



    function setBaseURI(string memory _newBaseURI) public onlyOwner {

        baseURI = _newBaseURI;

   }

       

}