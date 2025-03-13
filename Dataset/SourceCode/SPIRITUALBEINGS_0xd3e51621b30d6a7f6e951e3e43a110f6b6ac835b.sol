// SPDX-License-Identifier: MIT



/**



   ▄████████    ▄███████▄  ▄█     ▄████████  ▄█      ███     ███    █▄     ▄████████  ▄█       

  ███    ███   ███    ███ ███    ███    ███ ███  ▀█████████▄ ███    ███   ███    ███ ███       

  ███    █▀    ███    ███ ███▌   ███    ███ ███▌    ▀███▀▀██ ███    ███   ███    ███ ███       

  ███          ███    ███ ███▌  ▄███▄▄▄▄██▀ ███▌     ███   ▀ ███    ███   ███    ███ ███       

▀███████████ ▀█████████▀  ███▌ ▀▀███▀▀▀▀▀   ███▌     ███     ███    ███ ▀███████████ ███       

         ███   ███        ███  ▀███████████ ███      ███     ███    ███   ███    ███ ███       

   ▄█    ███   ███        ███    ███    ███ ███      ███     ███    ███   ███    ███ ███▌    ▄ 

 ▄████████▀   ▄████▀      █▀     ███    ███ █▀      ▄████▀   ████████▀    ███    █▀  █████▄▄██ 

                                 ███    ███                                          ▀         

          ▀█████████▄     ▄████████  ▄█  ███▄▄▄▄      ▄██████▄     ▄████████                   

            ███    ███   ███    ███ ███  ███▀▀▀██▄   ███    ███   ███    ███                   

            ███    ███   ███    █▀  ███▌ ███   ███   ███    █▀    ███    █▀                    

           ▄███▄▄▄██▀   ▄███▄▄▄     ███▌ ███   ███  ▄███          ███                          

          ▀▀███▀▀▀██▄  ▀▀███▀▀▀     ███▌ ███   ███ ▀▀███ ████▄  ▀███████████                   

            ███    ██▄   ███    █▄  ███  ███   ███   ███    ███          ███                   

            ███    ███   ███    ███ ███  ███   ███   ███    ███    ▄█    ███                   

          ▄█████████▀    ██████████ █▀    ▀█   █▀    ████████▀   ▄████████▀                    

                                                                                        

                Starting April 2023. Visit www.SpiritualBeings.io



Spiritual Beings is a collection of 11,111 digital collectibles on the Ethereum blockchain. It is a visual manifestation of our hope and declaration for our community of holders. Things that feel disjointed and scattered, and even dead, can come together again through the journey of spirituality. Spiritual Beings is a collection that is based on a firm foundation — that we are more the same, than we are different. We are spirit, mind, and body. We are all spiritual beings.



Ownership: 



     Spiritual Beings owns all legal right, title, and interest in and to the Art, and all intellectual property rights therein. The rights that you have in and to the Art are limited to those described in the License below. Spiritual Beings reserves all rights in and to the Art not expressly granted to you in this License.



License: 



     a. General Use. Spiritual Beings grants you a worldwide, non-exclusive, non-transferable, royalty-free license to use, copy, and display the Art for your Purchased digital collectibles, along with any Extensions that you choose to create or use, solely for the following purposes: (i) for your own personal, non-commercial use; (ii) as part of a marketplace that permits the purchase and sale of your digital collectibles.



     b. Commercial Use. Spiritual Beings grants you a limited, worldwide, non-exclusive, non-transferable license to use, copy, and display the Art for your Purchased digital collectibles for the purpose of commercializing your own merchandise that includes, contains, or consists of the Art for your Purchased digital collectibles (“Commercial Use”), provided that such Commercial Use does not result in you earning more than Fifty Thousand Dollars ($50,000 USD) in gross revenue each year.



 */



pragma solidity 0.8.17;



import "@openzeppelin/contracts/access/Ownable.sol";

import "erc721a/contracts/ERC721A.sol";

import "@openzeppelin/contracts/finance/PaymentSplitter.sol"; 

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {DefaultOperatorFilterer} from 'operator-filter-registry/src/DefaultOperatorFilterer.sol';



// Grounding:

error Grounding721A__CurrentlyGrounding();

error Grounding721A__NotApprovedOrOwner();

error Grounding721A__GroundingClosed();

error Grounding721A__NotGrounded();



contract SPIRITUALBEINGS is Ownable, ERC721A, PaymentSplitter, DefaultOperatorFilterer {



    uint public maxSupply  = 11111;           // Hard-coded in setMaxSupply() also.

    uint public mintPrice  = 0.4818 ether;    // Price ~equiv. to $1000USD

    uint public promoPrice = 0.3613 ether;    // Price ~equiv. to $750USD

    bool public presaleIsLive = false;

    string public provenanceHash;

    uint public randomOffset;

    uint public reservedNFTs;

    bool public saleIsLive = false;

    uint public transactionLimit = 10;       // ETH-mint limit

    uint public transactionLimitCC = 5;      // CC-purchase limit

    uint public walletLimit = 200;           

    string private contractURIval;

    string private metadataURI;

    bool private mintLock;

    bool private provenanceLock = false;

    uint id = totalSupply();



    // Merkle tree:

    bytes32 public merkleRoot;

    mapping(address => bool) public allowlistClaimed;



    struct Account {

        uint nftsReserved;

        uint mintedNFTs;

        uint isAdmin;

    }

    mapping(address => Account) public accounts;



    struct AffiliateAccount {

    	uint affiliateFee;

    	uint affiliateUnpaidSales;

    	uint affiliateTotalSales;

    	uint affiliateAmountPaid;

        address affiliateReceiver;

        bool affiliateIsActive;

    }

    mapping(string => AffiliateAccount) public affiliateAccounts;



    // *********************************

        // Grounding:



        // tokenId to grounding start time (0 = not grounding)

        mapping(uint256 => uint256) private s_groundingStarted;



        // Cumulative per-token grounding, excluding the current period

        mapping(uint256 => uint256) private s_groundingTotal;



        // MUST only be modified by safeTransferWhileGrounding(); if set 

        // to 2 then the _beforeTokenTransfer() block while grounding is disabled.

        uint256 private s_groundingTransfer = 1;



        // Whether grounding is currently allowed.

        // If false, grounding is blocked but ungrounding is always allowed.

        bool public s_groundingOpen = false;



        // Emitted when a SpiritualBeing begins grounding.

        event Grounded(uint256 indexed tokenId);



        // Emitted when a SpiritualBeing stops grounding; 

        // either through normal means or by expulsion.

        event Ungrounded(uint256 indexed tokenId);



        // Emitted when a SpiritualBeing is expelled from grounding.

        event Expelled(uint256 indexed tokenId);

    // *********************************



    event Mint(address indexed sender, uint totalSupply);

    event PermanentURI(string _value, uint256 indexed _id);

    event Burn(address indexed sender, uint indexed _id);



    address[] private _distro;

    uint[] private _distro_shares;



    string[] private affiliateDistro;



    // Merkle tree (add bytes32 _merkleRoot)

    constructor(address[] memory distro, uint[] memory distro_shares, address[] memory teamclaim, bytes32 _merkleRoot)

        ERC721A("Spiritual Beings", "SB")

        PaymentSplitter(distro, distro_shares)

    {

        metadataURI = "ipfs://QmVPLq3wPzs1K429DLJy8iJuSdRWoVDiTb4TA8JFi7fNGb/"; 



        accounts[msg.sender] = Account( 0, 0, 0 );



        // Set Team NFTs & Initial Admin Levels:

        accounts[teamclaim[0]] = Account(552, 0, 1 ); // Team Use NFTs

        accounts[teamclaim[1]] = Account( 28, 0, 1 ); // tbd

        accounts[teamclaim[2]] = Account( 28, 0, 1 ); // tbd

        accounts[teamclaim[3]] = Account( 28, 0, 1 ); // tbd

        accounts[teamclaim[4]] = Account( 27, 0, 1 ); // tbd



        reservedNFTs = 663;  



        _distro = distro;

        _distro_shares = distro_shares;



        // Merkle tree:

        merkleRoot = _merkleRoot;



    }



    // (^_^) Modifiers (^_^) 



    modifier minAdmin1() {

        require(accounts[msg.sender].isAdmin > 0 , "Error: Level 1(+) admin clearance required.");

        _;

    }



    modifier minAdmin2() {

        require(accounts[msg.sender].isAdmin > 1, "Error: Level 2(+) admin clearance required.");

        _;

    }



    modifier minAdmin3() {

        require(accounts[msg.sender].isAdmin > 2, "Error: Level 3(+) admin clearance required.");

        _;

    }



    modifier noReentrant() {

        require(!mintLock, "Error: No re-entrancy.");

        mintLock = true;

        _;

        mintLock = false;

    } 



    // Grounding: Require msg.sender own or is approved for the token.    

    modifier onlyApprovedOrOwner(uint256 tokenId) {

        if (

            !(_ownershipOf(tokenId).addr == msg.sender ||

            getApproved(tokenId) == msg.sender)

        ) {

            revert Grounding721A__NotApprovedOrOwner();

        }

        _;

    }



    // (^_^) Overrides (^_^) 



    // ERC721A: Start token IDs at 1 instead of 0

    function _startTokenId() internal view virtual override returns (uint256) {

        return 1;

    }    

    

    // For OS Operator Filter Registry

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {

        super.setApprovalForAll(operator, approved);

    }



    // For OS Operator Filter Registry

    function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {

        super.approve(operator, tokenId);

    }



    // ERC721A: Xfer functions for OS Operator Filter Registry

    function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    // ERC721A: Xfer functions for OS Operator Filter Registry

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    // ERC721A: Xfer functions for OS Operator Filter Registry

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable override onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    // OZ Payment Splitter, make release() restricted to minAdmin3

    function release(address payable account) public override minAdmin3 {

        super.release(account);

    }



    // OZ Payment Splitter, make release() restricted to minAdmin3

    function release(IERC20 token, address account) public override minAdmin3 {

        super.release(token, account);

    }



    // (^_^) Basic Mint (^_^) 

    // (For anyone desiring to easily mint from the contract.)

    function contractMint(uint _amount) external payable noReentrant {



        require(saleIsLive, "Error: Sale is not active. Via contractMint().");

        require(totalSupply() + _amount <= (maxSupply - reservedNFTs), "Error: Purchase would exceed max supply. Via contractMint().");

        require((_amount + accounts[msg.sender].mintedNFTs) <= walletLimit, "Error: You would exceed the wallet limit. Via contractMint().");

        require(!isContract(msg.sender), "Error: Contracts cannot mint. Via contractMint().");

        require(msg.value >= (mintPrice * _amount), "Error: Not enough ether sent. Via contractMint().");

	    accounts[msg.sender].mintedNFTs += _amount;

        _safeMint(msg.sender, _amount);

        emit Mint(msg.sender, totalSupply());



    }



    // (^_^) Setters (^_^) 



    function adminLevelRaise(address _addr) external onlyOwner { 

        accounts[_addr].isAdmin ++; 

    }



    function adminLevelLower(address _addr) external onlyOwner { 

        accounts[_addr].isAdmin --; 

    }



    function provenanceHashLock() external onlyOwner {

        provenanceLock = true;

    }

    

    function provenanceSet(string memory _provenanceHash) external onlyOwner {

        require(provenanceLock == false);

        provenanceHash = _provenanceHash;

    }  



    function reservesDecrease(uint _decreaseReservedBy, address _addr) external onlyOwner {

        require(reservedNFTs - _decreaseReservedBy >= 0, "Error: This would make reserved less than 0.");

        require(accounts[_addr].nftsReserved - _decreaseReservedBy >= 0, "Error: User does not have this many reserved NFTs.");

        reservedNFTs -= _decreaseReservedBy;

        accounts[_addr].nftsReserved -= _decreaseReservedBy;

    }



    function reservesIncrease(uint _increaseReservedBy, address _addr) external onlyOwner {

        require(reservedNFTs + totalSupply() + _increaseReservedBy <= maxSupply, "Error: This would exceed the max supply.");

        reservedNFTs += _increaseReservedBy;

        accounts[_addr].nftsReserved += _increaseReservedBy;

        if ( accounts[_addr].isAdmin == 0 ) { accounts[_addr].isAdmin ++; }

    }



    function salePresaleActivate() external minAdmin3 {

        presaleIsLive = true;

    }



    function salePresaleDeactivate() external minAdmin3 {

        presaleIsLive = false;

    } 



    function salePublicActivate() external minAdmin3 {

        saleIsLive = true;

    }



    function salePublicDeactivate() external minAdmin3 {

        saleIsLive = false;

    } 



    function setBaseURI(string memory _newURI) external minAdmin3 {

        metadataURI = _newURI;

    }



    function setContractURI(string memory _newURI) external onlyOwner {

        contractURIval = _newURI;

    }



    // Grounding:    

    function setGroundingOpen(bool isOpen) external minAdmin2 {

        s_groundingOpen = isOpen;

    }



    // We allow max supply to be reset, but it can never exceed the original max.

    function setMaxSupply(uint _maxSupply) external onlyOwner {

        require(_maxSupply <= 11111, 'Error: New max supply cannot exceed original max.');        

        maxSupply = _maxSupply;

    }



    function setMintPrice(uint _newPrice) external onlyOwner {

        mintPrice = _newPrice;

    }



    function setPromoPrice(uint _newPrice) external onlyOwner {

        promoPrice = _newPrice;

    }



    function setRandomValue(address account, uint lowValue, uint highValue) external onlyOwner returns (uint) {

    	require(randomOffset==0, "Error: Random offset has already been set.");

    	require(highValue > lowValue, "Error: Low value must be lower than High value.");

    	uint mod_operator = highValue + 1 - lowValue;

        uint random_id = lowValue + uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.gaslimit, account)))% mod_operator;

        randomOffset = random_id;

        return random_id;

    }    



    function setTransactionLimit(uint _newTxLimit) external onlyOwner {

        transactionLimit = _newTxLimit;

    }



    function setTransactionLimitCC(uint _newTxLimitCC) external onlyOwner {

        transactionLimitCC = _newTxLimitCC;

    }



    function setWalletLimit(uint _newLimit) external onlyOwner {

        walletLimit = _newLimit;

    }



    // (^_^) Getters (^_^)



    // -- For OpenSea

    function contractURI() public view returns (string memory) {

        return contractURIval;

    }



    // -- For Metadata

    function _baseURI() internal view virtual override returns (string memory) {

        return metadataURI;

    }  



    // -- For Grounding

    function getGroundingPeriod(uint256 tokenId) external view returns (bool grounding, uint256 current, uint256 total) {

        uint256 start = s_groundingStarted[tokenId];

        if (start != 0) {

            grounding = true;

            current = block.timestamp - start;

        }

        total = current + s_groundingTotal[tokenId];

    }

    



    // (^_^) Main NFT Drop Mgmt. Functions (^_^) 



    function airDropNFT(address[] memory _addr) external minAdmin3 {



        require(totalSupply() + _addr.length <= (maxSupply - reservedNFTs), "Error: You would exceed the airdrop limit.");



        for (uint i = 0; i < _addr.length; i++) {

             _safeMint(_addr[i], 1);

             emit Mint(msg.sender, totalSupply());

        }



    }



    function claimReserved(uint _amount) external minAdmin1 {



        require(_amount > 0, "Error: Need to have reserved supply.");

        require(accounts[msg.sender].nftsReserved >= _amount, "Error: You are trying to claim more NFTs than you have reserved.");

        require(totalSupply() + _amount <= maxSupply, "Error: You would exceed the max supply limit.");



        accounts[msg.sender].nftsReserved -= _amount;

        reservedNFTs -= _amount;



        _safeMint(msg.sender, _amount);

        emit Mint(msg.sender, totalSupply());

        

    }



    function mint(uint _amount, bool isAffiliate, string memory affiliateRef) external payable noReentrant {



        require(saleIsLive, "Error: Sale is not active.");

        require(totalSupply() + _amount <= (maxSupply - reservedNFTs), "Error: Purchase would exceed max supply.");

        require((_amount + accounts[msg.sender].mintedNFTs) <= walletLimit, "Error: You would exceed the wallet limit.");

        require(_amount <= transactionLimit, "Error: You would exceed the transaction limit.");

        require(!isContract(msg.sender), "Error: Contracts cannot mint.");



        if(isAffiliate) {



            require(msg.value >= (promoPrice * _amount), "Error: Not enough ether sent.");

        	bool isActive = affiliateAccounts[affiliateRef].affiliateIsActive;

        	require(isActive, "Error: Affiliate account invalid or disabled.");

       		affiliateAccounts[affiliateRef].affiliateUnpaidSales += _amount;

       		affiliateAccounts[affiliateRef].affiliateTotalSales += _amount;



        } else {



            require(msg.value >= (mintPrice * _amount), "Error: Not enough ether sent.");



        }



	    accounts[msg.sender].mintedNFTs += _amount;

        _safeMint(msg.sender, _amount);

        emit Mint(msg.sender, totalSupply());



    }



    // Standalone function for CC processors to call, if needed.

    function ccGetPrice(string memory affiliateRef) public view returns (uint) {

       bool isActive = affiliateAccounts[affiliateRef].affiliateIsActive;

       if (isActive) { return promoPrice; } else { return mintPrice; }

    }



    // For CC companies (and/or I guess anyone dying to circumvent wallet limits).

    function ccMint(uint _amount, address _recipient, bool isAffiliate, string memory affiliateRef) external payable noReentrant {



        require(saleIsLive, "ccMint Error: Sale is not active.");

        require(totalSupply() + _amount <= (maxSupply - reservedNFTs), "ccMint Error: Purchase would exceed max supply.");

        require(_amount <= transactionLimitCC, "ccMint Error: You would exceed the transaction limit.");



        if(isAffiliate) {



            require(msg.value >= (promoPrice * _amount), "ccMint Error: Not enough ether sent.");

        	bool isActive = affiliateAccounts[affiliateRef].affiliateIsActive;

        	require(isActive, "ccMint Error: Affiliate account invalid or disabled.");

       		affiliateAccounts[affiliateRef].affiliateUnpaidSales += _amount;

       		affiliateAccounts[affiliateRef].affiliateTotalSales += _amount;



        } else {



            require(msg.value >= (mintPrice * _amount), "ccMint Error: Not enough ether sent.");



        }



	    accounts[msg.sender].mintedNFTs += _amount;

        _safeMint(_recipient, _amount);

        emit Mint(msg.sender, totalSupply());



    }



    function burn(uint _id) external returns (bool, uint) {



        require(msg.sender == ownerOf(_id) || msg.sender == getApproved(_id) || isApprovedForAll(ownerOf(_id), msg.sender), "Error: You must own this token to burn it.");

        _burn(_id);

        emit Burn(msg.sender, _id);

        return (true, _id);



    }



    /** 

     * Payout Function 1 --> Distribute Shares to Affiliates *and* Payees (DSAP)

     * In addition to including this, we also modified the PaymentSplitter

     * release() function to make it minAdmin3 (to ensure that affiliate funds 

     * will always be paid out prior to defined shares).

     */

    function distributeSharesAffilsAndPayees() external minAdmin3 noReentrant {



        // A. Payout affiliates:

        for (uint i = 0; i < affiliateDistro.length; i++) {



            // The ref name -- eg. jim, etc.

		    string memory affiliateRef = affiliateDistro[i];



            // The wallet addr to be paid for this affiliate:

		    address DSAP_receiver_wallet = affiliateAccounts[affiliateRef].affiliateReceiver;



            // The fee due per sale for this affiliate:

		    uint DSAP_fee = affiliateAccounts[affiliateRef].affiliateFee;



            // The # of mints they are credited with:

		    uint DSAP_mintedNFTs = affiliateAccounts[affiliateRef].affiliateUnpaidSales;



            // Payout calc:

            uint DSAP_payout = DSAP_fee * DSAP_mintedNFTs;

            if ( DSAP_payout == 0 ) { continue; }

 

            // Require that the contract balance is enough to send out ETH:

		    require(address(this).balance >= DSAP_payout, "Error: Insufficient balance");



            // Send payout to the affiliate:

	       	(bool sent, bytes memory data) = payable(DSAP_receiver_wallet).call{value: DSAP_payout}("");

		    require(sent, "Error: Failed to send ETH to receiver");	



            // Update total amt earned for this person:

		    affiliateAccounts[affiliateRef].affiliateAmountPaid += DSAP_payout;



            // Set their affiliateUnpaidSales back to 0:

		    affiliateAccounts[affiliateRef].affiliateUnpaidSales = 0;



        }



        // B. Then pay defined shareholders:

        for (uint i = 0; i < _distro.length; i++) {

            release(payable(_distro[i]));

        }



    }    



    /**

     * Payout Function 2 --> Standard distribute per OZ payment splitter

     * (present as a backup distrubute mechanism only).

     */

    function distributeSharesPayeesOnly() external onlyOwner {



        for (uint i = 0; i < _distro.length; i++) {

            release(payable(_distro[i]));

        }



    }



    function isContract(address account) internal view returns (bool) {  

        uint256 size;

        assembly {

            size := extcodesize(account)

        }

        return size > 0;

    }    





    // (^_^) GenNFTs Affiliate Program functions (^_^) 

    // New functionality created by GenerativeNFTs.io to aid in influencer trust and transparency.



    function genNftsAffiliateAdd(address _addr, string memory affiliateRef, uint fee) external onlyOwner { 



        // REMINDER: Submit fee in WEI!

        require(fee > 0, "Error: Fee must be > 0 (and s/b in WEI).");



        // FORMAT: lowercase alpha-numeric; will enforce in validateAffiliateName().

        require(validateAffiliateName(affiliateRef), "Error: Affiliate Reference code used doesn't pass validations.");



        // ORDER: fee, minted NFTs, ttl minted, ttl amt earned, wallet, active:

        affiliateAccounts[affiliateRef] = AffiliateAccount(fee, 0, 0, 0, _addr, true);

        affiliateDistro.push(affiliateRef);



    }



    function genNftsAffiliateDisable(string memory affiliateRef) external onlyOwner {

       	require(affiliateAccounts[affiliateRef].affiliateFee > 0 , "Error: Affiliate reference likely wrong.");

        affiliateAccounts[affiliateRef].affiliateIsActive = false;

    }



    function genNftsAffiliateEnable(string memory affiliateRef) external onlyOwner { 

       	require(affiliateAccounts[affiliateRef].affiliateFee > 0 , "Error: Affiliate reference likely wrong.");

        affiliateAccounts[affiliateRef].affiliateIsActive = true;

    }



    function genNftsLookupAffilRef(address _addr) public view returns (string memory) { 



        for (uint i = 0; i < affiliateDistro.length; i++) {

   		    string memory affiliateRef = affiliateDistro[i];

            address thisWallet = affiliateAccounts[affiliateRef].affiliateReceiver;

            if ( thisWallet==_addr ) { return affiliateRef; }

        }



    }



    function validateAffiliateName(string memory str) public pure returns (bool){



        bytes memory b = bytes(str);

        if ( b.length < 3  ) return false;

        if ( b.length > 15 ) return false;  // Can't be > 15 chars

        if ( b[0] == 0x20  ) return false;  // No leading space

        if ( b[b.length - 1] == 0x20 ) return false; // No trailing space



        bytes1 lastChar = b[0];



        for( uint i; i < b.length; i++ ){



            bytes1 char = b[i];



            if (char == 0x20) return false; // Can't contain spaces



            //   We want all lowercase alpha-numeric here.

            //   But to include UC as well, add:

            //   !(char >= 0x41 && char <= 0x5A) && // A-Z

            if ( !(char >= 0x30 && char <= 0x39) && // 9-0

                 !(char >= 0x61 && char <= 0x7A)    // a-z 

               ) return false;



            lastChar = char;

        }



        return true;

    }  



    // (^_^) Merkle tree functions (^_^) 



    function allowlistMint(bytes32[] calldata _merkleProof, uint _amount) external payable noReentrant {

        require(presaleIsLive, "Error: Allowlist Sale is not active.");

        require(totalSupply() + _amount <= (maxSupply - reservedNFTs), "Error: Purchase would exceed max supply.");

        require((_amount + accounts[msg.sender].mintedNFTs) <= walletLimit, "Error: You would exceed the wallet limit.");

        require(_amount <= transactionLimit, "Error: You would exceed the transaction limit.");

        require(!isContract(msg.sender), "Error: Contracts cannot mint.");

        require(msg.value >= (mintPrice * _amount), "Error: Not enough ether sent.");

        require(!allowlistClaimed[msg.sender], "Error: You have already claimed all of your NFTs.");



        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Error: You are not allowlisted.");



        if ( ( _amount + accounts[msg.sender].mintedNFTs ) == walletLimit ) {

            allowlistClaimed[msg.sender] = true;

        }



	    accounts[msg.sender].mintedNFTs += _amount;

        _safeMint(msg.sender, _amount);

        emit Mint(msg.sender, totalSupply());



    } 



    function allowlistNewMerkleRoot(bytes32 _merkleRoot) external onlyOwner {

        merkleRoot = _merkleRoot;

    } 



    // Grounding: 

    // Transfer a token between addresses while the Spiritual

    // Being is grounding, thus not resetting the grouding period.

    function safeTransferWhileGrounding(

        address from,

        address to,

        uint256 tokenId

    ) external onlyApprovedOrOwner(tokenId) {

        s_groundingTransfer = 2;

        safeTransferFrom(from, to, tokenId);

        s_groundingTransfer = 1;

    }  



    // Block transfers while grounding:

    function _beforeTokenTransfers(

        address,

        address,

        uint256 startTokenId,

        uint256 quantity

    ) internal view override {

        uint256 tokenId = startTokenId;

        for (uint256 end = tokenId + quantity; tokenId < end; tokenId++) {

        if (!(s_groundingStarted[tokenId] == 0 || s_groundingTransfer == 2)) {

            revert Grounding721A__CurrentlyGrounding();

        }

        }

    }



    // Changes the SpiritualBeing's grounding status:

    function toggleGrounding(uint256 tokenId)

        internal

        onlyApprovedOrOwner(tokenId)

    {

        uint256 start = s_groundingStarted[tokenId];

        if (start == 0) {

            if (!s_groundingOpen) {

                revert Grounding721A__GroundingClosed();

            }

            s_groundingStarted[tokenId] = block.timestamp;

            emit Grounded(tokenId);

        } else {

            s_groundingTotal[tokenId] += block.timestamp - start;

            s_groundingStarted[tokenId] = 0;

            emit Ungrounded(tokenId);

        }

    }    



    // Changes the grounding status of one or more SpiritualBeing(s):

    function toggleGrounding(uint256[] calldata tokenIds) external {

        for (uint256 i = 0; i < tokenIds.length; i++) {

            toggleGrounding(tokenIds[i]);

        }

    }



    // Admin ability to expel a SpirtualBeing from grounding. As most sales listings use off-chain signatures, it's impossible to detect someone who has grounded and then deliberately undercuts the floor price in the knowledge that the sale can't proceed. This function allows for monitoring of such practices and expulsion if abuse is detected, allowing the undercutting SpiritualBeing to be sold on the open market. Since OpenSea uses isApprovedForAll() in its pre-listing checks, we can't block by that means because grounding would then be all-or-nothing for all of a particular owner's SpiritualBeings:

    function expelFromGrounding(uint256 tokenId) external minAdmin2 {

        if (s_groundingStarted[tokenId] == 0) {

            revert Grounding721A__NotGrounded();

        }

        s_groundingTotal[tokenId] += block.timestamp - s_groundingStarted[tokenId];

        s_groundingStarted[tokenId] = 0;

        emit Ungrounded(tokenId);

        emit Expelled(tokenId);

    }





    // (^_^) THE END, FRENS! (^_^)

    // Grounding functionality coded by Paul Rennick :-)

    // LFG!  [email protected]

    // .--- .. -- .--.-. --. . -. . .-. .- - .. ...- . -. ..-. - ... .-.-.- .. ---



}