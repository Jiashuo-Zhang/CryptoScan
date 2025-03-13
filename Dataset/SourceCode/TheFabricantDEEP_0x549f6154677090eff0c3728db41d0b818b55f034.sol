// SPDX-License-Identifier: MIT

/*
___________ __    __   _______                                                             
("     _   "/" |  | "\ /"     "|                                                            
 )__/  \\__(:  (__)  :(: ______)                                                            
    \\_ /   \/      \/ \/    |                                                              
    |.  |   //  __  \\ // ___)_                                                             
    \:  |  (:  (  )  :(:      "|                                                            
  ___\__|  _\__|  |__/_\_______)____   __    ______       __     _____  ___ ___________     
 /"     "|/""\    |   _  "\ /"      \ |" \  /" _  "\     /""\   (\"   \|"  ("     _   ")    
(: ______/    \   (. |_)  :|:        |||  |(: ( \___)   /    \  |.\\   \    )__/  \\__/     
 \/    |/' /\  \  |:     \/|_____/   )|:  | \/ \       /' /\  \ |: \.   \\  |  \\_ /        
 // ___//  __'  \ (|  _  \\ //      / |.  | //  \ _   //  __'  \|.  \    \. |  |.  |        
(:  ( /   /  \\  \|: |_)  :|:  __   \ /\  |(:   _) \ /   /  \\  |    \    \ |  \:  |        
 \__/(___/  __\___(_______/|__|__\___(__\_|_\_______(___/    \___\___|\____\)   \__|        
|"      "\ /"     "|/"     "| |   __ "\                                                     
(.  ___  :(: ______(: ______) (. |__) :)                                                    
|: \   ) ||\/    |  \/    |   |:  ____/                                                     
(| (___\ ||// ___)_ // ___)_  (|  /                                                         
|:       :(:      "(:      "|/|__/ \                                                        
(________/ \_______)\_______(_______)     
*/

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "../../../lib/openzeppelin-contracts/contracts/security/Pausable.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol";

import "../../lib/token/ERC721A.sol";
import "../../lib/token/metadata/TFMetadata.sol";

/// @title TheFabricantDEEP
/// @author The Fabricant ([email protected], [email protected])
/// @notice The Fabricant's DEEP NFT collection
contract TheFabricantDEEP is Ownable, Pausable, ERC721A, ERC2981, ReentrancyGuard, TFMetadata {
    using Strings for uint32;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when the access list is updated
    /// @param addresses Array of addresses to update
    /// @param allowed Array of booleans indicating if the address is allowed to mint
    event AccessListUpdated(address[] addresses, bool[] allowed);

    /// @notice Event emitted when the base URI is updated
    /// @param baseURI New base URI
    event BaseURIUpdated(string baseURI);

    /// @notice Event emitted when the default royalty receiver and fee are updated
    /// @param receiver Address to receive royalties
    /// @param feeNumerator Numerator of the royalty fee
    event DefaultRoyaltyUpdated(address receiver, uint96 feeNumerator);

    /// @notice Event emitted when the sale is opened or closed
    /// @param isOpen Boolean indicating if the sale is open or closed
    event SaleIsOpenUpdated(bool isOpen);

    /// @notice Event emitted when the dev minting phase is opened or closed
    /// @param isOpen Boolean indicating if the dev minting phase is open or closed
    event DevMintIsOpenUpdated(bool isOpen);

    /// @notice Event emitted when a payment is withdrawn
    /// @param receiver Address to receive mint royalties
    /// @param amount Amount withdrawn
    event PaymentWithdrawn(address receiver, uint256 amount);

    /// @notice Event emitted when the price of a variant is updated
    /// @param variantId Variant ID of the variant to set the price for
    /// @param price Price to set for the variant
    event VariantPriceUpdated(uint32 indexed variantId, uint256 price);

    /// @notice Event emitted when an NFT is minted
    /// @param tokenId Token ID of the NFT minted
    /// @param variantId Variant ID of the NFT minted
    /// @param receiver Address that received the NFT
    event NftMinted(uint256 indexed tokenId, uint32 indexed variantId, address indexed receiver);

    /*//////////////////////////////////////////////////////////////
                            DATA STRUCTURES
    //////////////////////////////////////////////////////////////*/

    /// @notice Used by contract to keep track of sale
    struct SaleConfig {
        bool isOpen; // Minting is open/closed
        bool devMintIsOpen; // Dev minting is open/closed
        uint16 maxBatchSize; // Max number of tokens that can be minted in a single transaction
    }

    /// @notice Used to get Sale data off-chain
    struct SaleData {
        bool isOpen; // Minting is open/closed
        uint16 maxBatchSize; // max number of nfts that can be minted in a single batch
        uint32 totalSupply; // total number sold
        uint32[] allowedVariants; // Array of variant IDs that are allowed to be minted
        uint16[] unitsSold; // Number sold of each variant
        uint256[] variantPrices; // Prices of each variant
    }

    /// @notice Used by contract to get variant data
    struct VariantData {
        bool isSet; // Indicates if variantData is set for this position in the _variantData mapping
        uint32 variantId; // id of the variant
        uint16 unitsSold; // number of nfts minted for this variant
        uint256 price; // price of the variant in wei
        string variantName; // name of the variant
        string description; // desc of the variant
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Configuration settings for the sale
    SaleConfig public saleConfig;

    /// @notice Used internally to track settings for each variant and check if a variant can be minted
    /// @dev Maps variant IDs to their respective VariantData
    mapping(uint32 => VariantData) internal _variantData;

    /// @notice Used internally to construct metadata for tokens
    /// @dev Maps token IDs to their corresponding variant IDs
    mapping(uint32 => uint32) internal _tokenIdToVariantId;

    /// @notice Access list for addresses allowed to mint in dev minting phase
    /// @dev Used exclusively for dev minting, mapping an address to a bool indicating allowed access
    mapping(address => bool) public accessList;

    /// @notice Address designated to receive minting royalties
    /// @dev Public address that is set to receive royalties from minting
    address public mintRoyaltyReceiver;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor for TheFabricantDEEP
    /// @param _baseURIString Base URI for token metadata
    /// @param _royaltyBasisPoints Royalty basis points for minting
    constructor(string memory _baseURIString, uint96 _royaltyBasisPoints) ERC721A("TheFabricantDEEP", "TFDEEP") {
        // Set VariantData
        // Variant 1
        VariantData memory v1 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 1,
            unitsSold: 0,
            variantName: "UNKNOWN",
            description: "Style unknown, creativity redefined."
        });
        _variantData[1] = v1;

        // Variant 2
        VariantData memory v2 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 2,
            unitsSold: 0,
            variantName: "DATABASE",
            description: "New models emerge from the primordial dataset."
        });
        _variantData[2] = v2;
        // Variant 3
        VariantData memory v3 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 3,
            unitsSold: 0,
            variantName: "FAST",
            description: "Time to accelerate."
        });
        _variantData[3] = v3;
        // Variant 4
        VariantData memory v4 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 4,
            unitsSold: 0,
            variantName: "HYBRID",
            description: "Hybrid intelligence, crossbreed creation."
        });
        _variantData[4] = v4;
        // Variant 5
        VariantData memory v5 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 5,
            unitsSold: 0,
            variantName: "LEARN",
            description: "Deep learn, deep curiosity."
        });
        _variantData[5] = v5;
        // Variant 6
        VariantData memory v6 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 6,
            unitsSold: 0,
            variantName: "COPYCOPYCOPY",
            description: "A copy of a copy of copy creates something new."
        });
        _variantData[6] = v6;
        // Variant 7
        VariantData memory v7 = VariantData({
            isSet: true,
            price: 0.001 ether,
            variantId: 7,
            unitsSold: 0,
            variantName: "MACHINE",
            description: "Parallel processes infinitely expanding."
        });
        _variantData[7] = v7;
        // Set SaleConfig
        SaleConfig memory saleConf = SaleConfig({isOpen: false, devMintIsOpen: false, maxBatchSize: 5});
        saleConfig = saleConf;
        // Set marketplace royalty
        _setDefaultRoyalty(0xf5f916a3E4C449Ac8Ae39fDAEF7ac3D169faa87A, uint96(_royaltyBasisPoints));
        // Set mint royalty receiver
        mintRoyaltyReceiver = 0x21F52C84A6f9D858b7B93dB0D88e592196b1c384;
        // Set collection name and baseURI
        _setCollectionName("TheFabricantDEEP");
        setBaseURI(_baseURIString);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Internal function that returns the baseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /*//////////////////////////////////////////////////////////////
                EXTERNAL/PUBLIC STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice External function to mint tokens
    /// @param _to Address to mint tokens to
    /// @param _quantity Number of tokens to mint
    /// @param _variantId Variant ID of the token to mint
    /// @dev Users can only mint if the sale is open, the batchSize (quantity) is less than 5 but not 0, and the variantId is between 1 and 7. They must also send the correct payment amount.
    function mint(address _to, uint256 _quantity, uint32 _variantId) external payable nonReentrant whenNotPaused {
        SaleConfig memory saleC = saleConfig;
        VariantData storage variant = _variantData[_variantId];

        require(_to != address(0), "DEEP::mint:Cannot mint to 0 address");
        require(saleC.isOpen, "DEEP::mint:Mint closed");
        require(_quantity <= saleC.maxBatchSize && _quantity != 0, "DEEP::mint:Unsupported quantity");
        require(variant.isSet, "DEEP::mint:Variant ID not set");
        require(msg.value >= _quantity * variant.price, ("DEEP::mint:Ether value sent is incorrect"));

        // totalSupply gives the next tokenId
        uint32 index = uint32(totalSupply());
        // Set variantId for tokenId
        for (uint32 i = index; i < (_quantity + index); i++) {
            _tokenIdToVariantId[i] = _variantId;

            emit NftMinted(i, _variantId, _to);
        }
        // Increment the number of units sold of the variant in storage
        variant.unitsSold += uint16(_quantity);

        _safeMint(_to, _quantity);
    }

    /// @notice External function to mint tokens using the access list. Only address on the access list can mint
    /// @param _to Address to mint tokens to
    /// @param _quantity Number of tokens to mint
    /// @param _variantId Variant ID of the token to mint
    /// @dev Users can only mint if the dev mint sale is open, the batchSize (quantity) is less than 5 but not 0, and the variantId is between 1 and 7. Used for treasury minting, so there is no associated payment fee.
    function accessListMint(address _to, uint256 _quantity, uint32 _variantId)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(accessList[msg.sender], "DEEP::accessListMint:Sender not on access list");

        SaleConfig memory saleC = saleConfig;
        VariantData storage variant = _variantData[_variantId];

        require(_to != address(0), "DEEP::accessListMint:Cannot mint to 0 address");
        require(saleC.devMintIsOpen, "DEEP::accessListMint:Dev mint closed");
        require(_quantity <= saleC.maxBatchSize && _quantity != 0, "DEEP::accessListMint:Unsupported quantity");
        require(variant.isSet, "DEEP::accessListMint:Variant ID not set");

        // totalSupply gives the next tokenId
        uint32 index = uint32(totalSupply());
        // Set variantId for tokenId
        for (uint32 i = index; i < (_quantity + index); i++) {
            _tokenIdToVariantId[i] = _variantId;

            emit NftMinted(i, _variantId, _to);
        }
        // Increment the number of units sold of the variant in storage
        variant.unitsSold += uint16(_quantity);

        _safeMint(_to, _quantity);
    }

    /// @notice External function to set the default royalty receiver and fee
    /// @param _receiver Address to receive royalties
    /// @param _feeNumerator Numerator of the royalty fee
    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) external onlyOwner whenNotPaused {
        _setDefaultRoyalty(_receiver, _feeNumerator);

        emit DefaultRoyaltyUpdated(_receiver, _feeNumerator);
    }

    /// @notice External function to set the mint royalty receiver
    /// @param _receiver Address to receive royalties
    function setMintRoyaltyReceiver(address _receiver) external onlyOwner whenNotPaused {
        require(_receiver != address(0), "DEEP::setMintRoyaltyReceiver:Receiver cannot be 0 address");
        mintRoyaltyReceiver = _receiver;
    }

    /// @notice External function to set the sale to open or closed
    /// @param _isOpen Boolean indicating if the sale is open or closed
    function setIsOpen(bool _isOpen) external onlyOwner whenNotPaused {
        saleConfig.isOpen = _isOpen;

        emit SaleIsOpenUpdated(_isOpen);
    }

    /// @notice External function to set the dev minting to open or closed
    /// @param _isOpen Boolean indicating if the dev minting is open or closed
    function setDevMintIsOpen(bool _isOpen) external onlyOwner whenNotPaused {
        saleConfig.devMintIsOpen = _isOpen;

        emit DevMintIsOpenUpdated(_isOpen);
    }

    /// @notice External function to set the price of a single variant
    /// @param _variantId Variant ID of the variant to set the price for
    /// @param _price Price to set for the variant
    function setVariantPrice(uint32 _variantId, uint256 _price) external onlyOwner whenNotPaused {
        require(_variantData[_variantId].isSet, "DEEP::setVariantPrice:Variant ID not set");
        _variantData[_variantId].price = _price;

        emit VariantPriceUpdated(_variantId, _price);
    }

    /// @notice External function to update the access list
    /// @param _addresses Array of addresses to update
    /// @param _allowed Array of booleans indicating if the address is allowed to mint
    /// @dev Access list for dev/treasury minting should be small to keep gas costs low when calling. 5 addresses or less is ideal
    function updateAccessList(address[] memory _addresses, bool[] memory _allowed) external onlyOwner whenNotPaused {
        require(_addresses.length == _allowed.length, "DEEP::updateAccessList:Array lengths do not match");
        for (uint256 i = 0; i < _addresses.length; i++) {
            accessList[_addresses[i]] = _allowed[i];
        }

        emit AccessListUpdated(_addresses, _allowed);
    }

    /// @notice External function to update the base URI
    /// @param _uri New base URI
    function setBaseURI(string memory _uri) public onlyOwner whenNotPaused {
        _baseTokenURI = _uri;

        emit BaseURIUpdated(_uri);
    }

    /// @notice External function to pause the contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice External function to unpause the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice External function to withdraw payments
    function withdrawPayment() external onlyOwner nonReentrant whenNotPaused {
        uint contractBalance = address(this).balance;
        (bool success,) = mintRoyaltyReceiver.call{value: address(this).balance}("");
        require(success, "DEEP::withdrawPayment:Transfer failed.");

        emit PaymentWithdrawn(mintRoyaltyReceiver, contractBalance);
    }

    /*//////////////////////////////////////////////////////////////
                    EXTERNAL/PUBLIC VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice External function to get the base URI
    function baseURI() external view returns (string memory) {
        return _baseURI();
    }

    /// @notice External function to get the current saleData
    /// @dev Returns a SaleData struct
    /// @dev Number of variants is 7
    function saleData() external view returns (SaleData memory) {
        // Calculate variantData mapping length
        // i = 1: variantIds always start from 1
        // .isSet indicates if variantData is set for that variantId. Break if it isn't.
        uint32 variantDataLength;
        for (uint8 i = 1; i < type(uint8).max; i++) {
            if (_variantData[i].isSet) {
                variantDataLength++;
            } else {
                break;
            }
        }

        SaleData memory _saleData;

        _saleData.isOpen = saleConfig.isOpen;
        _saleData.maxBatchSize = maxBatchSize();

        _saleData.totalSupply = uint32(totalSupply());

        // Set array lengths for _saleData
        _saleData.allowedVariants = new uint32[](variantDataLength);
        _saleData.variantPrices = new uint256[](variantDataLength);
        _saleData.unitsSold = new uint16[](variantDataLength);

        for (uint8 i = 0; i < variantDataLength; i++) {
            // variantData starts at index 1 as the variantId matches the key in the mapping
            uint8 variantKey = i + 1;
            VariantData memory variant = _variantData[variantKey];

            if (!variant.isSet) break;

            _saleData.allowedVariants[i] = variant.variantId;
            _saleData.variantPrices[i] = variant.price;
            _saleData.unitsSold[i] = variant.unitsSold;
        }

        return _saleData;
    }

    /// @notice External function to get the tokenURI for a given variantId
    /// @param _tokenId Token ID to get the uri for
    /// @dev returns a JSON string
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "DEEP::tokeURI:ERC721Metadata:URI query for nonexistent token");

        uint32 variantId = _tokenIdToVariantId[uint32(_tokenId)];
        require(_variantData[variantId].isSet, "DEEP::tokenURI: Variant ID not set");
        string memory variantName = _variantData[variantId].variantName;
        string memory variantDescription = _variantData[variantId].description;

        return _createMetadataString(uint32(_tokenId).toString(), variantId.toString(), variantName, variantDescription);
    }

    /// @notice External function to get the number of tokens minted for a given address
    /// @param _owner Address to get the number of tokens minted for
    function numberMinted(address _owner) public view returns (uint256) {
        return _numberMinted(_owner);
    }

    /// @notice External function to get the maxBatchSize
    function maxBatchSize() public view returns (uint16) {
        return saleConfig.maxBatchSize;
    }

    /// @notice External function to get the variantId for a given tokenId
    /// @param _tokenId Token ID to get the variantId for
    function tokenIdToVariantId(uint32 _tokenId) public view returns (uint32) {
        require(_exists(_tokenId), "DEEP::tokenIdToVariantId:ERC721Metadata:URI query for nonexistent token");
        uint32 variantId = _tokenIdToVariantId[_tokenId];
        require(variantId != 0, "DEEP::tokenIdToVariantId:No variantId set for tokenId");
        return variantId;
    }

    /// @notice External function to get the variantData for a given variantId
    /// @param _variantId Variant ID to get the variantData for
    function variantData(uint32 _variantId) public view returns (VariantData memory) {
        require(_variantData[_variantId].isSet, "DEEP::variantData:Variant ID not set");
        return _variantData[_variantId];
    }

    /// @notice External function to indicate which interfaces are supported
    /// @param interfaceId Interface ID to check if supported
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }
}