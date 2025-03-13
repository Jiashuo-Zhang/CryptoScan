// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen 6529 - Minter Contract
 *  @date: 20-December-2023
 *  @version: 1.10
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./INextGenCore.sol";
import "./IDelegationManagementContract.sol";
import "./MerkleProof.sol";
import "./INextGenAdmins.sol";
import "./IERC721.sol";

contract NextGenMinterContract {

    // total funds collected during minting per collection
    mapping (uint256 => uint256) public collectionTotalAmount;

    // timestamp of last mint for used in sales model 3
    mapping (uint256 => uint) public lastMintDate;

    // tokens airdropped per collection
    mapping (uint256 => uint256) public excludeTokensCounter;

    // burn or swap address during burnOrSwap functionality
    mapping (bytes32 => address) public burnOrSwapAddress;

    // token ids set during burnOrSwap functionality
    mapping (bytes32 => uint256[2]) private burnOrSwapIds;

    // burnToMint initialization --> burn a token on a NextGen collection and mint a token on a new NextGen collection
    mapping (uint256 => mapping (uint256 => bool)) public burnToMintCollections;

    // burnOrSwap initialization --> burn a token on an external ERC721 collection and mint a token on a NextGen collection
    mapping (bytes32 => mapping (uint256 => bool)) public burnExternalToMintCollections;

    // checks if minting costs for a collectionwere set
    mapping (uint256 => bool) private setMintingCosts;

    // struct that holds minting costs and phases
    struct collectionPhasesDataStructure {
        uint allowlistStartTime;
        uint allowlistEndTime;
        uint publicStartTime;
        uint publicEndTime;
        bytes32 merkleRoot;
        uint256 collectionMintCost;
        uint256 collectionEndMintCost;
        uint256 timePeriod;
        uint256 rate;
        uint8 salesOption;
        address delAddress;
    }

    // mapping of collectionPhasesData struct
    mapping (uint256 => collectionPhasesDataStructure) private collectionPhases;

    // struct that holds primary royalties
    struct royaltiesPrimarySplits {
        uint256 artistPercentage;
        uint256 teamPercentage;
    }

    // mapping of royaltiesPrimarySplits struct
    mapping (uint256 => royaltiesPrimarySplits) private collectionRoyaltiesPrimarySplits;

    // struct that holds addresses and percentages for primary splits
    struct collectionPrimaryAddresses {
        address primaryAdd1;
        address primaryAdd2;
        address primaryAdd3;
        uint256 add1Percentage;
        uint256 add2Percentage;
        uint256 add3Percentage;
        bool setStatus;
        bool approvedStatus;
    }

    // mapping of collectionPrimaryAndSecondaryAddresses struct
    mapping (uint256 => collectionPrimaryAddresses) private collectionArtistPrimaryAddresses;

    // struct that holds secondary royalties
    struct royaltiesSecondarySplits {
        uint256 artistPercentage;
        uint256 teamPercentage;
    }

    // mapping of royaltiesSecondarySplits struct

    mapping (uint256 => royaltiesSecondarySplits) private collectionRoyaltiesSecondarySplits;

    // struct that holds addresses and percentages for secondary splits
    struct collectionSecondaryAddresses {
        address secondaryAdd1;
        address secondaryAdd2;
        address secondaryAdd3;
        uint256 add1Percentage;
        uint256 add2Percentage;
        uint256 add3Percentage;
        bool setStatus;
        bool approvedStatus;
    }

    // mapping of collectionSecondaryAddresses struct
    mapping (uint256 => collectionSecondaryAddresses) private collectionArtistSecondaryAddresses;

    // mapping that holds the auction end time when a token is sent to auction
    mapping (uint256 => uint) private mintToAuctionData;

    // mapping that holds the auction status when a token is sent to auction
    mapping (uint256 => bool) private mintToAuctionStatus;

    //external contracts declaration
    INextGenCore public gencore;
    IDelegationManagementContract public dmc;
    INextGenAdmins private adminsContract;

    // events
    event Withdraw(address indexed _add, bool status, uint256 indexed funds);

    // constructor
    constructor (address _gencore, address _del, address _adminsContract) {
        gencore = INextGenCore(_gencore);
        dmc = IDelegationManagementContract(_del);
        adminsContract = INextGenAdmins(_adminsContract);
    }

    // certain functions can only be called by an admin or the artist

    modifier ArtistOrAdminRequired(uint256 _collectionID, bytes4 _selector) {
      require(msg.sender == gencore.retrieveArtistAddress(_collectionID) || adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true, "Not allowed");
      _;
    }

    // certain functions can only be called by a global or function admin

    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    // certain functions can only be called by a collection, global or function admin

    modifier CollectionAdminRequired(uint256 _collectionID, bytes4 _selector) {
      require(adminsContract.retrieveCollectionAdmin(msg.sender,_collectionID) == true || adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true, "Not allowed");
      _;
    }

    // function to add a collection's minting costs

    function setCollectionCosts(uint256 _collectionID, uint256 _collectionMintCost, uint256 _collectionEndMintCost, uint256 _rate, uint256 _timePeriod, uint8 _salesOption, address _delAddress) public CollectionAdminRequired(_collectionID, this.setCollectionCosts.selector) {
        require(gencore.retrievewereDataAdded(_collectionID) == true, "Add data");
        collectionPhases[_collectionID].collectionMintCost = _collectionMintCost;
        collectionPhases[_collectionID].collectionEndMintCost = _collectionEndMintCost;
        collectionPhases[_collectionID].rate = _rate;
        collectionPhases[_collectionID].timePeriod = _timePeriod;
        collectionPhases[_collectionID].salesOption = _salesOption;
        collectionPhases[_collectionID].delAddress = _delAddress;
        setMintingCosts[_collectionID] = true;
    }

    // function to add a collection's minting phases and merkleroot

    function setCollectionPhases(uint256 _collectionID, uint _allowlistStartTime, uint _allowlistEndTime, uint _publicStartTime, uint _publicEndTime, bytes32 _merkleRoot) public CollectionAdminRequired(_collectionID, this.setCollectionPhases.selector) {
        require(setMintingCosts[_collectionID] == true, "Set Costs");
        collectionPhases[_collectionID].allowlistStartTime = _allowlistStartTime;
        collectionPhases[_collectionID].allowlistEndTime = _allowlistEndTime;
        collectionPhases[_collectionID].merkleRoot = _merkleRoot;
        collectionPhases[_collectionID].publicStartTime = _publicStartTime;
        collectionPhases[_collectionID].publicEndTime = _publicEndTime;
    }

    // airdrop function
    
    function airDropTokens(address[] memory _recipients, string[] memory _tokenData, uint256[] memory _saltfun_o, uint256 _collectionID, uint256[] memory _numberOfTokens) public FunctionAdminRequired(this.airDropTokens.selector) {
        require(gencore.retrievewereDataAdded(_collectionID) == true, "Add data");
        uint256 collectionTokenMintIndex;
        for (uint256 y=0; y< _recipients.length; y++) {
            collectionTokenMintIndex = gencore.viewTokensIndexMin(_collectionID) + gencore.viewCirSupply(_collectionID) + _numberOfTokens[y] - 1;
            require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(_collectionID), "No supply");
            for(uint256 i = 0; i < _numberOfTokens[y]; i++) {
                uint256 mintIndex = gencore.viewTokensIndexMin(_collectionID) + gencore.viewCirSupply(_collectionID);
                gencore.airDropTokens(mintIndex, _recipients[y], _tokenData[y], _saltfun_o[y], _collectionID);
            }
        }
    }

    // mint function for allowlist or public minting

    function mint(uint256 _collectionID, uint256 _numberOfTokens, uint256 _maxAllowance, string memory _tokenData, address _mintTo, bytes32[] calldata merkleProof, address _delegator, uint256 _saltfun_o) public payable {
        require(setMintingCosts[_collectionID] == true && _numberOfTokens > 0, "err");
        uint256 col = _collectionID;
        address mintingAddress;
        uint256 phase;
        string memory tokData = _tokenData;
        if (block.timestamp >= collectionPhases[col].allowlistStartTime && block.timestamp < collectionPhases[col].allowlistEndTime) {
            phase = 1;
            bytes32 node;
            if (_delegator != 0x0000000000000000000000000000000000000000) {
                bool isAllowedToMint;
                isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 2);
                if (isAllowedToMint == false) {
                isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(_delegator, collectionPhases[col].delAddress, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(_delegator, collectionPhases[col].delAddress, msg.sender, 2);    
                }
                require(isAllowedToMint == true, "No delegation");
                node = keccak256(bytes.concat(keccak256((abi.encodePacked(_delegator, _maxAllowance, tokData)))));
                require(_maxAllowance >= gencore.retrieveTokensMintedALPerAddress(col, _delegator) + _numberOfTokens, "AL limit");
                mintingAddress = _delegator;
            } else {
                node = keccak256(bytes.concat(keccak256((abi.encodePacked(msg.sender, _maxAllowance, tokData)))));
                require(_maxAllowance >= gencore.retrieveTokensMintedALPerAddress(col, msg.sender) + _numberOfTokens, "AL limit");
                mintingAddress = msg.sender;
            }
            require(MerkleProof.verifyCalldata(merkleProof, collectionPhases[col].merkleRoot, node), 'invalid proof');
        } else if (block.timestamp >= collectionPhases[col].publicStartTime && block.timestamp <= collectionPhases[col].publicEndTime) {
            phase = 2;
            require(_numberOfTokens <= gencore.viewMaxAllowance(col), "Change no of tokens");
            require(gencore.retrieveTokensMintedPublicPerAddress(col, msg.sender) + _numberOfTokens <= gencore.viewMaxAllowance(col), "Max");
            mintingAddress = msg.sender;
            tokData = '"public"';
        } else {
            revert("No minting");
        }
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = gencore.viewTokensIndexMin(col) + gencore.viewCirSupply(col) + _numberOfTokens - 1;
        require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(col), "No supply");
        require(msg.value >= (getPrice(col) * _numberOfTokens), "Wrong ETH");
        // refund excess
        {
            uint256 excess = calculateExcess(msg.value, getPrice(col) * _numberOfTokens);
            collectionTotalAmount[col] = collectionTotalAmount[col] + msg.value - excess;
        }
        // check mechanism for sale option 3
        if (collectionPhases[col].salesOption == 3) {
            uint timeOfLastMint;
            if (lastMintDate[col] == 0) {
                // for only public minting set the allowliststarttime as publicstarttime
                timeOfLastMint = collectionPhases[col].allowlistStartTime - collectionPhases[col].timePeriod;
            } else {
                timeOfLastMint =  lastMintDate[col];
            }
            // calculate periods and check if a period has passed in order to allow minting
            uint tDiff = (block.timestamp - timeOfLastMint) / collectionPhases[col].timePeriod;
            // users are able to mint after a period passes
            // unminted tokens from previous periods are transferred for minting into new periods
            // 1 mint at a time period
            require(tDiff>=1 && _numberOfTokens == 1, "1 mint/period");
            // exclude tokens ex. airdrop tokens so they do not affect lastMintDate
            lastMintDate[col] = collectionPhases[col].allowlistStartTime + (collectionPhases[col].timePeriod * (gencore.viewCirSupply(col) - excludeTokensCounter[col]));
        }
        // mint tokens
        for(uint256 i = 0; i < _numberOfTokens; i++) {
            uint256 mintIndex = gencore.viewTokensIndexMin(col) + gencore.viewCirSupply(col);
            gencore.mint(mintIndex, mintingAddress, _mintTo, tokData, _saltfun_o, col, phase);
        }
    }

    // burn to mint function (does not require contract approval)

    function burnToMint(uint256 _burnCollectionID, uint256 _tokenId, uint256 _mintCollectionID, uint256 _saltfun_o) public payable {
        require(setMintingCosts[_mintCollectionID] == true && burnToMintCollections[_burnCollectionID][_mintCollectionID] == true, "init err");
        require(block.timestamp >= collectionPhases[_mintCollectionID].publicStartTime && block.timestamp <= collectionPhases[_mintCollectionID].publicEndTime,"No minting");
        require ((_tokenId >= gencore.viewTokensIndexMin(_burnCollectionID)) && (_tokenId <= gencore.viewTokensIndexMax(_burnCollectionID)), "col/token id error");
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = gencore.viewTokensIndexMin(_mintCollectionID) + gencore.viewCirSupply(_mintCollectionID);
        require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(_mintCollectionID), "No supply");
        require(msg.value >= getPrice(_mintCollectionID), "Wrong ETH");
        // refund excess
        {
            uint256 excess = calculateExcess(msg.value, getPrice(_mintCollectionID));
            collectionTotalAmount[_mintCollectionID] = collectionTotalAmount[_mintCollectionID] + msg.value - excess;
        }
        uint256 mintIndex = gencore.viewTokensIndexMin(_mintCollectionID) + gencore.viewCirSupply(_mintCollectionID);
        // burn and mint token
        address burner = msg.sender;
        gencore.burnToMint(mintIndex, _burnCollectionID, _tokenId, _mintCollectionID, _saltfun_o, burner);
    }

    // mint and auction
    
    function mintAndAuction(address _recipient, string memory _tokenData, uint256 _saltfun_o, uint256 _collectionID, uint _auctionEndTime) public FunctionAdminRequired(this.mintAndAuction.selector) {
        require(gencore.retrievewereDataAdded(_collectionID) == true, "Add data");
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = gencore.viewTokensIndexMin(_collectionID) + gencore.viewCirSupply(_collectionID);
        require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(_collectionID), "No supply");
        uint256 mintIndex = gencore.viewTokensIndexMin(_collectionID) + gencore.viewCirSupply(_collectionID);
        uint timeOfLastMint;
        // 1 token per period can be minted and send to auction
        // time period can be set for any sales model
        if (lastMintDate[_collectionID] == 0) {
        // for public sale set the allowliststarttime the same time as publicstarttime
            timeOfLastMint = collectionPhases[_collectionID].allowlistStartTime - collectionPhases[_collectionID].timePeriod;
        } else {
            timeOfLastMint =  lastMintDate[_collectionID];
        }
        // calculate periods and check if a period has passed in order to allow minting
        uint tDiff = (block.timestamp - timeOfLastMint) / collectionPhases[_collectionID].timePeriod;
        // admins are able to mint after a period passes
        require(tDiff>=1, "1 mint/period");
        lastMintDate[_collectionID] = collectionPhases[_collectionID].allowlistStartTime + (collectionPhases[_collectionID].timePeriod * ((gencore.viewCirSupply(_collectionID) - excludeTokensCounter[_collectionID])));
        require(_auctionEndTime >= block.timestamp + 600); // 10mins min auction
        mintToAuctionData[mintIndex] = _auctionEndTime;
        mintToAuctionStatus[mintIndex] = true;
        // token is airdropped to the _recipient address
        gencore.airDropTokens(mintIndex, _recipient, _tokenData, _saltfun_o, _collectionID);
    }

    // function to exclude a specific no of tokens during sales model 3 or reset lastMintDate

    function excludeTokensOrResetLD(uint256 _option, uint256 _collectionID, uint256 _excludeCounter) public FunctionAdminRequired(this.excludeTokensOrResetLD.selector) { 
        if (_option == 1) {
            excludeTokensCounter[_collectionID] = _excludeCounter;
        } else {
            lastMintDate[_collectionID] = 0;
        }  
    }

    // function to refund any excess amount

    function calculateExcess(uint256 _value, uint256 _price) internal returns(uint256) {
        uint256 excess;
        excess = _value - _price;
        (bool success1, ) = payable(msg.sender).call{value: excess}("");
        require(success1, "ETH failed");
        return(excess);
    }

    // function to initialize burn to mint for NextGen collections

    function initializeBurn(uint256 _burnCollectionID, uint256 _mintCollectionID, bool _status) public FunctionAdminRequired(this.initializeBurn.selector) { 
        require((gencore.retrievewereDataAdded(_burnCollectionID) == true) && (gencore.retrievewereDataAdded(_mintCollectionID) == true), "No data");
        burnToMintCollections[_burnCollectionID][_mintCollectionID] = _status;
    }

    // function to initialize external burn or swap to mint

    function initializeExternalBurnOrSwap(address _erc721Collection, uint256 _burnCollectionID, uint256 _mintCollectionID, uint256 _tokmin, uint256 _tokmax, address _burnOrSwapAddress, bool _status) public FunctionAdminRequired(this.initializeExternalBurnOrSwap.selector) { 
        bytes32 externalCol = keccak256(abi.encodePacked(_erc721Collection,_burnCollectionID));
        require((gencore.retrievewereDataAdded(_mintCollectionID) == true), "No data");
        burnExternalToMintCollections[externalCol][_mintCollectionID] = _status;
        burnOrSwapAddress[externalCol] = _burnOrSwapAddress;
        burnOrSwapIds[externalCol][0] = _tokmin;
        burnOrSwapIds[externalCol][1] = _tokmax;
    }

    // burn or swap to mint (requires contract approval)

    function burnOrSwapExternalToMint(address _erc721Collection, uint256 _burnCollectionID, uint256 _tokenId, uint256 _mintCollectionID, string memory _tokenData, bytes32[] calldata merkleProof, uint256 _saltfun_o) public payable {
        bytes32 externalCol = keccak256(abi.encodePacked(_erc721Collection,_burnCollectionID));
        require(setMintingCosts[_mintCollectionID] == true && burnExternalToMintCollections[externalCol][_mintCollectionID] == true, "init err");
        address ownerOfToken = IERC721(_erc721Collection).ownerOf(_tokenId);
        if (msg.sender != ownerOfToken) {
            bool isAllowedToMint;
            isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(ownerOfToken, 0x8888888888888888888888888888888888888888, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(ownerOfToken, 0x8888888888888888888888888888888888888888, msg.sender, 2);
            if (isAllowedToMint == false) {
            isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(ownerOfToken, _erc721Collection, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(ownerOfToken, _erc721Collection, msg.sender, 2);    
            }
            require(isAllowedToMint == true, "No delegation");
        }
        require(_tokenId >= burnOrSwapIds[externalCol][0] && _tokenId <= burnOrSwapIds[externalCol][1], "Token id does not match");
        IERC721(_erc721Collection).safeTransferFrom(ownerOfToken, burnOrSwapAddress[externalCol], _tokenId);
        uint256 col = _mintCollectionID;
        address mintingAddress;
        uint256 phase;
        string memory tokData = _tokenData;
        if (block.timestamp >= collectionPhases[col].allowlistStartTime && block.timestamp < collectionPhases[col].allowlistEndTime) {
            phase = 1;
            bytes32 node;
            node = keccak256(bytes.concat(keccak256((abi.encodePacked(_tokenId, tokData)))));
            mintingAddress = ownerOfToken;
            require(MerkleProof.verifyCalldata(merkleProof, collectionPhases[col].merkleRoot, node), 'invalid proof');            
        } else if (block.timestamp >= collectionPhases[col].publicStartTime && block.timestamp <= collectionPhases[col].publicEndTime) {
            phase = 2;
            mintingAddress = ownerOfToken;
            tokData = '"public"';
        } else {
            revert("No minting");
        }
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = gencore.viewTokensIndexMin(col) + gencore.viewCirSupply(col);
        require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(col), "No supply");
        require(msg.value >= getPrice(col), "Wrong ETH");
        // refund excess
        {
            uint256 excess = calculateExcess(msg.value, getPrice(col));
            collectionTotalAmount[col] = collectionTotalAmount[col] + msg.value - excess;
        }
        uint256 mintIndex = gencore.viewTokensIndexMin(col) + gencore.viewCirSupply(col);
        gencore.mint(mintIndex, mintingAddress, ownerOfToken, tokData, _saltfun_o, col, phase);
    }

    // function to set primary splits

    function setPrimaryAndSecondarySplits(uint256 _collectionID, uint256 _artistPrSplit, uint256 _teamPrSplit, uint256 _artistSecSplit, uint256 _teamSecSplit) public FunctionAdminRequired(this.setPrimaryAndSecondarySplits.selector) {
        require(_artistPrSplit + _teamPrSplit == 100, "splits need to be 100%");
        require(_artistSecSplit + _teamSecSplit == 100, "splits need to be 100%");
        collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage = _artistPrSplit;
        collectionRoyaltiesPrimarySplits[_collectionID].teamPercentage = _teamPrSplit;
        collectionRoyaltiesSecondarySplits[_collectionID].artistPercentage = _artistSecSplit;
        collectionRoyaltiesSecondarySplits[_collectionID].teamPercentage = _teamSecSplit;
    }

    // function to propose primary addresses and percentages for each address

    function proposePrimaryAddressesAndPercentages(uint256 _collectionID, address _primaryAdd1, address _primaryAdd2, address _primaryAdd3, uint256 _add1Percentage, uint256 _add2Percentage, uint256 _add3Percentage) public ArtistOrAdminRequired(_collectionID, this.proposePrimaryAddressesAndPercentages.selector) {
        require (collectionArtistPrimaryAddresses[_collectionID].approvedStatus == false, "Already approved");
        require (_add1Percentage + _add2Percentage + _add3Percentage == collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage, "Check %");
        collectionArtistPrimaryAddresses[_collectionID].primaryAdd1 = _primaryAdd1;
        collectionArtistPrimaryAddresses[_collectionID].primaryAdd2 = _primaryAdd2;
        collectionArtistPrimaryAddresses[_collectionID].primaryAdd3 = _primaryAdd3;
        collectionArtistPrimaryAddresses[_collectionID].add1Percentage = _add1Percentage;
        collectionArtistPrimaryAddresses[_collectionID].add2Percentage = _add2Percentage;
        collectionArtistPrimaryAddresses[_collectionID].add3Percentage = _add3Percentage;
        collectionArtistPrimaryAddresses[_collectionID].setStatus = true;
        collectionArtistPrimaryAddresses[_collectionID].approvedStatus = false;
    }

    // function to propose secondary addresses and percentages for each address

    function proposeSecondaryAddressesAndPercentages(uint256 _collectionID, address _secondaryAdd1, address _secondaryAdd2, address _secondaryAdd3, uint256 _add1Percentage, uint256 _add2Percentage, uint256 _add3Percentage) public ArtistOrAdminRequired(_collectionID, this.proposeSecondaryAddressesAndPercentages.selector) {
        require (collectionArtistSecondaryAddresses[_collectionID].approvedStatus == false, "Already approved");
        require (_add1Percentage + _add2Percentage + _add3Percentage == collectionRoyaltiesSecondarySplits[_collectionID].artistPercentage, "Check %");
        collectionArtistSecondaryAddresses[_collectionID].secondaryAdd1 = _secondaryAdd1;
        collectionArtistSecondaryAddresses[_collectionID].secondaryAdd2 = _secondaryAdd2;
        collectionArtistSecondaryAddresses[_collectionID].secondaryAdd3 = _secondaryAdd3;
        collectionArtistSecondaryAddresses[_collectionID].add1Percentage = _add1Percentage;
        collectionArtistSecondaryAddresses[_collectionID].add2Percentage = _add2Percentage;
        collectionArtistSecondaryAddresses[_collectionID].add3Percentage = _add3Percentage;
        collectionArtistSecondaryAddresses[_collectionID].setStatus = true;
        collectionArtistSecondaryAddresses[_collectionID].approvedStatus = false;
    }

    // function to accept primary addresses and percentages

    function acceptAddressesAndPercentages(uint256 _collectionID, bool _statusPrimary, bool _statusSecondary) public FunctionAdminRequired(this.acceptAddressesAndPercentages.selector) {
        require(collectionArtistPrimaryAddresses[_collectionID].setStatus == true && collectionArtistSecondaryAddresses[_collectionID].setStatus == true, "Propose Addresses");
        collectionArtistPrimaryAddresses[_collectionID].approvedStatus = _statusPrimary;
        collectionArtistSecondaryAddresses[_collectionID].approvedStatus = _statusSecondary;
        if (_statusPrimary == false) {
            collectionArtistPrimaryAddresses[_collectionID].setStatus = false;
        } else if (_statusSecondary == false) {
            collectionArtistSecondaryAddresses[_collectionID].setStatus = false;
        }
    }

    // function to transfer funds to the artist and team

    function payArtist(uint256 _collectionID, address _team1, address _team2, uint256 _teamperc1, uint256 _teamperc2) public FunctionAdminRequired(this.payArtist.selector) {
        require(collectionArtistPrimaryAddresses[_collectionID].approvedStatus == true, "Accept Royalties");
        require(collectionTotalAmount[_collectionID] > 0, "Collection Balance must be grater than 0");
        require(collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage + _teamperc1 + _teamperc2 == 100, "Change percentages");
        uint256 royalties = collectionTotalAmount[_collectionID];
        collectionTotalAmount[_collectionID] = 0;
        address tm1 = _team1;
        address tm2 = _team2;
        uint256 colId = _collectionID;
        uint256 artistRoyalties1;
        uint256 artistRoyalties2;
        uint256 artistRoyalties3;
        uint256 teamRoyalties1;
        uint256 teamRoyalties2;
        artistRoyalties1 = royalties * collectionArtistPrimaryAddresses[colId].add1Percentage / 100;
        artistRoyalties2 = royalties * collectionArtistPrimaryAddresses[colId].add2Percentage / 100;
        artistRoyalties3 = royalties * collectionArtistPrimaryAddresses[colId].add3Percentage / 100;
        teamRoyalties1 = royalties * _teamperc1 / 100;
        teamRoyalties2 = royalties * _teamperc2 / 100;
        (bool success1, ) = payable(collectionArtistPrimaryAddresses[colId].primaryAdd1).call{value: artistRoyalties1}("");
        (bool success2, ) = payable(collectionArtistPrimaryAddresses[colId].primaryAdd2).call{value: artistRoyalties2}("");
        (bool success3, ) = payable(collectionArtistPrimaryAddresses[colId].primaryAdd3).call{value: artistRoyalties3}("");
        (bool success4, ) = payable(tm1).call{value: teamRoyalties1}("");
        (bool success5, ) = payable(tm2).call{value: teamRoyalties2}("");
        require(success1, "ETH failed");
        require(success2, "ETH failed");
        require(success3, "ETH failed");
        require(success4, "ETH failed");
        require(success5, "ETH failed");
    }

    // function to update core contract

    function updateCoreContract(address _gencore) public FunctionAdminRequired(this.updateCoreContract.selector) { 
        gencore = INextGenCore(_gencore);
    }

    // function to update admin contract

    function updateAdminContract(address _newadminsContract) public FunctionAdminRequired(this.updateAdminContract.selector) {
        require(INextGenAdmins(_newadminsContract).isAdminContract() == true, "Contract is not Admin");
        adminsContract = INextGenAdmins(_newadminsContract);
    }

    // function to withdraw any balance from the smart contract

    function emergencyWithdraw() public FunctionAdminRequired(this.emergencyWithdraw.selector) {
        uint balance = address(this).balance;
        address admin = adminsContract.owner();
        (bool success, ) = payable(admin).call{value: balance}("");
        require(success, "ETH failed");
        emit Withdraw(msg.sender, success, balance);
    }

    // function to retrieve primary splits between artist and team

    function retrievePrimarySplits(uint256 _collectionID) public view returns(uint256, uint256){
        return (collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage, collectionRoyaltiesPrimarySplits[_collectionID].teamPercentage);
    }

    // function to retrieve primary addresses and percentages

    function retrievePrimaryAddressesAndPercentages(uint256 _collectionID) public view returns(address, address, address, uint256, uint256, uint256, bool){
        return (collectionArtistPrimaryAddresses[_collectionID].primaryAdd1, collectionArtistPrimaryAddresses[_collectionID].primaryAdd2, collectionArtistPrimaryAddresses[_collectionID].primaryAdd3, collectionArtistPrimaryAddresses[_collectionID].add1Percentage, collectionArtistPrimaryAddresses[_collectionID].add2Percentage, collectionArtistPrimaryAddresses[_collectionID].add3Percentage, collectionArtistPrimaryAddresses[_collectionID].approvedStatus);
    }

    // function to retrieve secondary splits between artist and team

    function retrieveSecondarySplits(uint256 _collectionID) public view returns(uint256, uint256){
        return (collectionRoyaltiesSecondarySplits[_collectionID].artistPercentage, collectionRoyaltiesSecondarySplits[_collectionID].teamPercentage);
    }

    // function to retrieve secondary addresses and percentages

    function retrieveSecondaryAddressesAndPercentages(uint256 _collectionID) public view returns(address, address, address, uint256, uint256, uint256, bool){
        return (collectionArtistSecondaryAddresses[_collectionID].secondaryAdd1, collectionArtistSecondaryAddresses[_collectionID].secondaryAdd2, collectionArtistSecondaryAddresses[_collectionID].secondaryAdd3, collectionArtistSecondaryAddresses[_collectionID].add1Percentage, collectionArtistSecondaryAddresses[_collectionID].add2Percentage, collectionArtistSecondaryAddresses[_collectionID].add3Percentage, collectionArtistSecondaryAddresses[_collectionID].approvedStatus);
    }

    // function to retrieve the phases and merkle root of a collection

    function retrieveCollectionPhases(uint256 _collectionID) public view returns(uint, uint, bytes32, uint, uint){
        return (collectionPhases[_collectionID].allowlistStartTime, collectionPhases[_collectionID].allowlistEndTime, collectionPhases[_collectionID].merkleRoot, collectionPhases[_collectionID].publicStartTime, collectionPhases[_collectionID].publicEndTime);
    }

    // function to retrieve the minting details of a collection

    function retrieveCollectionMintingDetails(uint256 _collectionID) public view returns(uint256, uint256, uint256, uint256, uint8, address){
        return (collectionPhases[_collectionID].collectionMintCost, collectionPhases[_collectionID].collectionEndMintCost, collectionPhases[_collectionID].rate, collectionPhases[_collectionID].timePeriod, collectionPhases[_collectionID].salesOption, collectionPhases[_collectionID].delAddress);
    }

    // retrieve minter contract status

    function isMinterContract() external view returns (bool) {
        return true;
    }

    // retrieve minting end time

    function getEndTime(uint256 _collectionID) external view returns (uint) {
        return collectionPhases[_collectionID].publicEndTime;
    }

    // retrieve auction end time

    function getAuctionEndTime(uint256 _tokenId) external view returns (uint) {
        return mintToAuctionData[_tokenId];
    }

    // retrieve auction status

    function getAuctionStatus(uint256 _tokenId) external view  returns (bool) {
        return mintToAuctionStatus[_tokenId];
    }

    // retrieve the minting price of collection

    function getPrice(uint256 _collectionId) public view returns (uint256) {
        uint tDiff;
        if (collectionPhases[_collectionId].salesOption == 3) {
            // periodic sale model
            // if rate > 0 minting price increases by rate (percentage) during each mint
            if (collectionPhases[_collectionId].rate > 0) {
                return collectionPhases[_collectionId].collectionMintCost + ((collectionPhases[_collectionId].collectionMintCost * collectionPhases[_collectionId].rate / 100) * (gencore.viewCirSupply(_collectionId) - excludeTokensCounter[_collectionId]));
            } else {
                return collectionPhases[_collectionId].collectionMintCost;
            }
        } else if (collectionPhases[_collectionId].salesOption == 2 && block.timestamp >= collectionPhases[_collectionId].allowlistStartTime && block.timestamp <= collectionPhases[_collectionId].publicEndTime){
            // decreases during a time period
            // if only public minting set allowlistStartTime = publicStartTime
            // if rate = 0 exponential descending model, otherwise, linear descending model
            // if rate is set the linear decrase each period per rate
            tDiff = (block.timestamp - collectionPhases[_collectionId].allowlistStartTime) / collectionPhases[_collectionId].timePeriod;
            uint256 price;
            uint256 decreaserate;
            if (collectionPhases[_collectionId].rate == 0) {
                price = collectionPhases[_collectionId].collectionMintCost / (tDiff + 1);
                decreaserate = ((price - (collectionPhases[_collectionId].collectionMintCost / (tDiff + 2))) / collectionPhases[_collectionId].timePeriod) * ((block.timestamp - (tDiff * collectionPhases[_collectionId].timePeriod) - collectionPhases[_collectionId].allowlistStartTime));
            } else {
                if (((collectionPhases[_collectionId].collectionMintCost - collectionPhases[_collectionId].collectionEndMintCost) / (collectionPhases[_collectionId].rate)) >= tDiff) {
                    price = collectionPhases[_collectionId].collectionMintCost - (tDiff * collectionPhases[_collectionId].rate);
                } else {
                    price = collectionPhases[_collectionId].collectionEndMintCost;
                }
            }
            if (price - decreaserate > collectionPhases[_collectionId].collectionEndMintCost) {
                return price - decreaserate; 
            } else {
                return collectionPhases[_collectionId].collectionEndMintCost;
            }
        } else {
            // fixed price model
            return collectionPhases[_collectionId].collectionMintCost;
        }
    }

}