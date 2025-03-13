// SPDX-License-Identifier: MIT

/*

    Version 1 of the HyperCycle License contract.

*/



pragma solidity 0.8.19;



import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IHyperCycleLicense.sol";



/*

@title HyperCycle License ERC721, splitting contract.

@author Barry Rowe, David Liendo

@notice This is the smart contract for minting and splitting of HyperCycle Licenses.

        These licenses have a unique LicenseID number, ranging from 

        8796629893120 to 8796629897215 inclusive (4096 in total). The contract ensures 

        that only licenses in this range can be minted, while licenses can be split by

        by the owner, creating two child licenses at the cost of destroying the

        parent license. Merging two neighboring licenses, the inverse of the split

        operation, is also possible, but limited to only tokens that were previously

        split by the contract.



        These ids are organized into a binary tree structure, with each node being 

        assigned an integer (the licenseID). For each parent node, the child node

        on the left has the parent's number times 2, while the right is this number

        plus one (going down on the left in the tree corresponds to appending a 0 

        to the binary representation of the licenseId, and going down on the right

        to appending a 1).



        The numbering system for licenses is based on their location in the binary

        tree, with 8796629893120 being 10000000000000100000000000000000000000000000

        in binary. The c_HyPC numbers in the related swap contract by contrast,

        exist on the left side of the tree so as to no overlap the license numbers.

        As a final note, spliting is limited to the 64th level inside the tree,

        which would correspond to 19 splits from a root license, however, the bottom

        10 splits are reserved for a future implementation of the license contract,

        which will involve a future reputation system and will be integrated into

        a separate contract (that one would deposit the tokens of this contract

        into in order to further split). Tokens at the bottom level in the tree  

        are in the range of 4503874505277440 to 4503874507374591 inclusive, with

        each root token corresponding to 512 tokens at that level.

*/



/* General Errors (modifiers) */

///@dev Error for when trying to do a token operation when you're not the owner.

error MustBeTokenOwner();

///@dev Error for when trying to do a token operation when the token is not yet created.

error MustBeValidToken();



/* Minting Errors */

///@dev Error for when trying to mint beyond the minting limit

error MintingTooManyTokens();



/* Splitting Errors */

///@dev Error for when trying to split a token beyond height 10.

error HeightMustBeHigherThanTen();



/* Merge Errors */

///@dev Error for when trying to merge tokens on the odd side.

error MustBeEvenToken();

///@dev Error for when trying to merge root licenses.

error CantMergeRootLicenses();



/* getBurnData Errors */

///@dev Error for when trying to get the burn data of a non-burnt token

error TokenMustBeBurnt();





contract HyperCycleLicense is

    ERC721Enumerable,

    Ownable, ReentrancyGuard, IHyperCycleLicense

{

    enum Status {NOT_MINTED, MINTED, SPLIT, BURNED}



    struct LicenseNFT {

        Status status;

        uint8 height;

        string burnData;

    }



    mapping(uint256 => LicenseNFT) public tokenData;



    uint256 public constant START_ROOT_TOKEN = 8796629893120;

    uint256 public constant END_ROOT_TOKEN_LIMIT = 8796629893120+4096;

    uint256 public currentRootToken = START_ROOT_TOKEN;

    uint256 public totalTokens;



    //Events

    /// @dev   The event for when a new token is minted.

    /// @param owner: the address that this token was minted to.

    /// @param licenseId: the specified licenseID for this token.

    event Mint(

        address indexed owner,

        uint256 indexed licenseId

    );



    /// @dev   The event when a token is split.

    /// @param owner: The address that split this token.

    /// @param licenseId: The licenseId of the token that was split.

    /// @param newLicenseId1: The licenseId of the token created on the left

    /// @param newLicenseId2: The licenseId of the token created on the right

    event Split(

        address owner,

        uint256 indexed licenseId,

        uint256 newLicenseId1,

        uint256 newLicenseId2

    );



    /// @dev   The event when a token is merged (unsplit).

    /// @param owner: The address that merged this token.

    /// @param parentLicenseId: The licenseId of the token parent that was merged.

    /// @param childLicenseId1: The licenseId of the child token on the left

    /// @param childLicenseId2: The licenseId of the child token on the right

    event Merge(

        address owner,

        uint256 indexed parentLicenseId,

        uint256 childLicenseId1,

        uint256 childLicenseId2

    );



    /// @dev   The event when a token is burnt.

    /// @param owner: The address that burned this token.

    /// @param licenseId: The licenseId of the token that was burnt.

    /// @param burnData: The burn metadata used for this burn.

    event Burn(

        address owner,

        uint256 indexed licenseId,

        string indexed burnData

    );



    // Modifiers

    /// @dev   Checks that the tokenId is owned by the sender of the transaction.

    /// @param licenseId: The tokenId inside this contract to check ownership.

    modifier isOwner(uint256 licenseId) {

        if (ownerOf(licenseId) != msg.sender) {

            revert MustBeTokenOwner();

        }

        _;

    }



    /// @dev   Checks that the given tokenId was previously minted (burned or not).

    /// @param licenseId: The tokenId to check is valid (previously created).

    ///                   This token could have been previously burnt or split.

    modifier isValid(uint256 licenseId) {

        if (tokenData[licenseId].status == Status.NOT_MINTED) {

            revert MustBeValidToken();

        }

        _;

    }



    // Functions

    /// @dev   Initializes the contract with the given name and symbol according

    ///        to the ERC721 standard.

    constructor () ERC721("HyPC License", "HyPCL") {

    }



    /// @dev   Creates a new root token inside this contract, with a specified licenseID.

    /// @param numTokens: The number of tokens to mint for this call.

    function mint(uint256 numTokens) external onlyOwner {

        if (currentRootToken + numTokens > END_ROOT_TOKEN_LIMIT) {

            revert MintingTooManyTokens();

        }

        for (uint256 i=0; i<numTokens; i++) {

            uint256 licenseId = currentRootToken+i;

            tokenData[licenseId] = LicenseNFT(Status.MINTED, 19, "");

            _mint(msg.sender, licenseId);

            emit Mint(msg.sender, licenseId);

        }

        totalTokens+=numTokens;

        currentRootToken+=numTokens;

 

    }

   

    /// @dev   Splits a given token into two new tokens, with corresponding licenseID's.

    /// @param licenseId: The tokenId to be split into two new tokens.

    function split(uint256 licenseId) external nonReentrant isOwner(licenseId) {

        LicenseNFT memory licenseData = tokenData[licenseId];

        if (licenseData.height <= 10) {

            revert HeightMustBeHigherThanTen();

        }



        uint256 licenseId1 = licenseId*2;

        uint256 licenseId2 = licenseId1+1;



        tokenData[licenseId1] = LicenseNFT(Status.MINTED, licenseData.height-1, "");

        tokenData[licenseId2] = LicenseNFT(Status.MINTED, licenseData.height-1, "");

        tokenData[licenseId].status = Status.SPLIT;

        _burn(licenseId);

        _safeMint(msg.sender, licenseId1); 

        _safeMint(msg.sender, licenseId2); 

        totalTokens+=1;

        emit Split(msg.sender, licenseId, licenseId1, licenseId2);

    }



    /// @dev   Burns a given tokenId with a specified burn string.

    /// @param licenseId: The tokenId to burn inside this contract.

    /// @param burnString: The metadata string assigned to this burn.

    function burn(uint256 licenseId, string memory burnString) external isOwner(licenseId) {

        tokenData[licenseId].burnData = burnString;

        tokenData[licenseId].status = Status.BURNED;

        totalTokens-=1;

        emit Burn(msg.sender, licenseId, burnString);

        _burn(licenseId);

    }



    /// @dev   Merges together two child licenses into a parent license.

    /// @param licenseId: The left-child license that will be merged to create the parent license.

    function merge(uint256 licenseId) external nonReentrant isOwner(licenseId) isOwner(licenseId+1) {

        if (licenseId%2 != 0) {

            revert MustBeEvenToken();

        } else if (licenseId/2 < START_ROOT_TOKEN) {

            revert CantMergeRootLicenses();

        }

        assert(tokenData[licenseId/2].status == Status.SPLIT);



        tokenData[licenseId].status = Status.NOT_MINTED;

        tokenData[licenseId+1].status = Status.NOT_MINTED;



        totalTokens-=1;

        _safeMint(msg.sender, licenseId/2);

        _burn(licenseId);

        _burn(licenseId+1);



        emit Merge(msg.sender, licenseId/2, licenseId, licenseId+1);

    }



    //Getters

    /// @dev   Returns the burn data from the given tokenId.

    /// @param licenseId: The tokenId that was previously burnt.    

    function getBurnData(uint256 licenseId) external view returns (string memory) {

        if (tokenData[licenseId].status != Status.BURNED) {

            revert TokenMustBeBurnt();

        }

        return tokenData[licenseId].burnData;

    }



    /// @dev   Returns the license height of the given tokenId.

    /// @param licenseId: The tokenId to get the license height of.

    function getLicenseHeight(uint256 licenseId) external isValid(licenseId) view returns (uint8) {

        return tokenData[licenseId].height;

    }



    /// @dev   Returns the license status of the given tokenId.

    /// @param licenseId: The tokenId to get the status of.

    function getLicenseStatus(uint256 licenseId) external view returns (uint256) {

        return uint256(tokenData[licenseId].status);

    }

}