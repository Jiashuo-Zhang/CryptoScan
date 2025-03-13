// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "erc721a/contracts/IERC721A.sol";

import {DefaultOperatorFilterer} from "./opensea/DefaultOperatorFilterer.sol";
import {IInfanityERC721} from "./interface/IInfanityERC721.sol";
import {IInfanity} from "./interface/IInfanity.sol";

contract Infanity is ERC1155, ERC2981, IInfanity, DefaultOperatorFilterer, AccessControl  {
    using ERC165Checker for address;
    using Counters for Counters.Counter;
    Counters.Counter private _nextItemId;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Brand {
        uint256[] itemIds;
        bool enabled;
        bool exist;
    }

    struct InfanityItem {
        uint256 brandId;
        address tokenGated;
        uint256 tokenGatedId;
        CollectionType collectionType;
        uint256 mintPriceInWei;
        uint256 cap;
        uint256 minted;
        uint256 maxMintPerAddress;
        uint256 maxMintPerTx;
        bool enabled;
        bool exist;
        bool enabledTokenGated;
    }

    event BrandCreated(uint256 brandId, bool enabled, bool exist);

    event InfanityCreated(
        uint256 brandId,
        uint256 itemId,
        uint256 mintPriceInWei,
        uint256 cap,
        bool enabled,
        bool exist
    );

    event Minted(
        uint256 indexed brandId,
        uint256 indexed itemId,
        CollectionType collectionType,
        uint256 quantity,
        uint256 indexed dateMinted
    );

    IInfanityERC721 public infanityNFT;

    // withdrawal variables
    address[] public wallets;
    uint256[] public walletsShares;
    uint256 public totalShares;

    // brandId => Brand
    mapping(uint256 => Brand) private brands;
    // collectionId => StormTrooperItem
    mapping(uint256 => InfanityItem) private infanities;
    // track collectionId => brandId
    mapping(uint256 => uint256) brandItemTracker;

    // get all brandIds
    uint256[] private brandIds;
    // get all collectionIds
    uint256[] private collectionIds;

    // track address minted token per collection
    // address => collectionId => minted quantity
    mapping(address => mapping(uint256 => uint256)) public mintedPerCollections;
    

    modifier onlyHasRole(bytes32 _role) {
        require(hasRole(_role, _msgSender()), "Caller does not have role");
        _;
    }

    modifier onlyExistingItem(uint256 _id) {
        if (!infanities[_id].exist) {
            revert NonExistingItem();
        }
        _;
    }

    modifier onlyExistingBrand(uint256 _brandId) {
        if (!brands[_brandId].exist) {
            revert NonExistingBrand();
        }
        _;
    }

    constructor(
        string memory metadataURI
    )
        ERC1155(metadataURI)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _nextItemId.increment();
    }

    function mint(
        uint256 _itemId, 
        uint256 _quantity, 
        CollectionType collectionType
    )
        external 
        override 
        payable 
    {
        InfanityItem memory item = infanities[_itemId];
        require(item.mintPriceInWei * _quantity == msg.value, "Eth not enough");
        // check if token gated enabled
        if (item.enabledTokenGated) {
            // get the balance of users
            uint256 tokenGatedBalance = getTokenGatedBalance(msg.sender, item.tokenGated, item.tokenGatedId);
            if (mintedPerCollections[msg.sender][_itemId] + _quantity > tokenGatedBalance) {
                revert MintQuantityExceedsLimit();
            }
        } 

        if (mintedPerCollections[msg.sender][_itemId] + _quantity > item.maxMintPerAddress) {
            revert MintQuantityExceedsLimit();
        }

        mintedPerCollections[msg.sender][_itemId] += _quantity;      
        _mintByCollectionType(msg.sender, _itemId, _quantity, collectionType);
    }

    function mint(
        address _to, 
        uint256 _itemId, 
        uint256 _quantity , 
        CollectionType collectionType
    ) 
        external 
        override 
        onlyHasRole(MINTER_ROLE) 
    {
        _mintByCollectionType(_to, _itemId, _quantity, collectionType);
    }

    function _mintByCollectionType(
        address _to, 
        uint256 _itemId, 
        uint256 _quantity, 
        CollectionType collectionType
    ) 
        internal 
        onlyExistingItem(_itemId)
    {
        if (_to == address(0)) {
            revert MintToZeroAddress();
        }

        if (_quantity == 0) {
            revert UintZeroValue();
        }

        uint256 brandId = brandItemTracker[_itemId];
        if (!brands[brandId].enabled) {
            revert MintDisableBrand();
        }

        InfanityItem memory item = infanities[_itemId];
        if (!item.enabled) {
            revert MintDisableItem();
        }

        if (item.collectionType != collectionType) {
            revert MintInvalidCollectionType();
        }

        if (_quantity> item.maxMintPerTx) {
            revert MintQuantityExceedsLimitPerTx();
        }

        if (item.minted + _quantity > item.cap) {
            revert MintQuantityExceedsLimit();
        }

        infanities[_itemId].minted = item.minted + _quantity;

        emit Minted({
            brandId: brandId,
            itemId: _itemId,
            collectionType: collectionType,
            quantity: _quantity,
            dateMinted: block.timestamp
        });

        if (collectionType == CollectionType.Limited) {
            infanityNFT.mint(_to, _itemId, _quantity);
        } else {
            _mint(_to, _itemId, _quantity, "");
        }
    }

    function getBrandInfo(uint256 brandId) external view onlyExistingBrand(brandId) returns (Brand memory) {
        return brands[brandId];
    }

    function getCollectionInfo(
        uint256 itemId
    ) 
        external 
        view 
        onlyExistingItem(itemId) 
        returns (InfanityItem memory) 
    {
        return infanities[itemId];
    }

    function getBrandsIds() external view returns (uint256[] memory) {
        return brandIds;
    }

    function getCollectionIds() external view returns (uint256[] memory) {
        return collectionIds;
    }

    function regularType() external pure returns (CollectionType) {
        return CollectionType.Regular;
    }

    function limitedType() external pure returns (CollectionType) {
        return CollectionType.Limited;
    }

    // === Admin === //

    /// @dev Enable brand
    /// @param brandId The brand to Enable
    function enableBrand(uint256 brandId) 
        external 
        onlyExistingBrand(brandId) 
        onlyHasRole(ADMIN_ROLE) 
    {
        require(!brands[brandId].enabled, "Already enabled");
        brands[brandId].enabled = true;
    }

    /// @dev Disable brand
    /// @notice Disabling brand will disable all collection under this category
    /// @param brandId The brandId to disable
    function disableBrand(uint256 brandId) 
        external 
        onlyExistingBrand(brandId) 
        onlyHasRole(ADMIN_ROLE) 
    {
        require(brands[brandId].enabled, "Already disabled");
        brands[brandId].enabled = false;
    }

    function enableCollection(uint256 _id) 
        external 
        onlyExistingItem(_id) 
        onlyHasRole(ADMIN_ROLE) 
    {
        require(!infanities[_id].enabled, "Collection already enabled");
        infanities[_id].enabled = true;
    }

    function disableCollection(uint256 _id) 
        external 
        onlyExistingItem(_id)  
        onlyHasRole(ADMIN_ROLE) 
    {
        require(infanities[_id].enabled, "Collection already disabled");
        infanities[_id].enabled = false;
    }

    function updateInfanityNFT(address _nft) external onlyHasRole(ADMIN_ROLE) {
        infanityNFT = IInfanityERC721(_nft);
    }

    function createBrand(uint256 brandId, bool enabled) external onlyHasRole(ADMIN_ROLE) {
        if (brands[brandId].exist) {
            revert CreateExistingBrand();
        }

        brands[brandId] = Brand({
            itemIds: new uint256[](0),
            enabled: true,
            exist: true
        });

        brandIds.push(brandId);

        emit BrandCreated({brandId: brandId, enabled: enabled, exist: true});
    }

    function createCollection(
        uint256 brandId,
        address tokenGated, 
        uint256 tokenGatedId,
        uint256 mintPriceInWei, 
        uint256 cap, 
        uint256 maxMintPerAddress,
        uint256 maxMintPerTx,
        bool enabled,
        bool enabledTokenGated
    )   
        external 
        onlyHasRole(ADMIN_ROLE) 
    {
        _create(
            brandId, 
            tokenGated,
            tokenGatedId,
            mintPriceInWei, 
            cap, 
            maxMintPerAddress,
            maxMintPerTx,
            enabled, 
            enabledTokenGated,
            CollectionType.Regular
        );
    }

    function createLimited(
        uint256 brandId, 
        address tokenGatedAddrs,
        uint256 tokenGatedId,
        uint256 mintPriceInWei, 
        uint256 cap, 
        uint256 maxMintPerAddress,
        uint256 maxMintPerTx,
        bool enabled,
        bool enabledTokenGated
    ) 
        external 
        onlyHasRole(ADMIN_ROLE) 
    {
        _create(
            brandId, 
            tokenGatedAddrs,
            tokenGatedId,
            mintPriceInWei, 
            cap, 
            maxMintPerAddress,
            maxMintPerTx,
            enabled, 
            enabledTokenGated,
            CollectionType.Limited
        );
    }

    function _create(
        uint256 brandId, 
        address tokenGatedAddrs,
        // this is the collectionId if the token Gated Address is 1155
        // if its 721 it will be ignored
        uint256 tokenGatedId,
        uint256 mintPriceInWei, 
        uint256 cap,
        uint256 maxMintPerAddrs,
        uint256 maxMintPerTx,
        bool enabled, 
        bool enabledTokenGated,
        CollectionType collectionType
    ) 
        onlyExistingBrand(brandId) 
        private 
    {
        if (cap == 0 || mintPriceInWei == 0) {
            revert UintZeroValue();
        }

        if (enabledTokenGated) {
            if (tokenGatedAddrs == address(0)) revert SetToZeroAddress();
        }

        uint256 itemId = nextItemId();
        _nextItemId.increment();

        brandItemTracker[itemId] = brandId;

        infanities[itemId] = InfanityItem(
            brandId, 
            tokenGatedAddrs,
            tokenGatedId,
            collectionType,
            mintPriceInWei,
            cap,
            0,
            maxMintPerAddrs,
            maxMintPerTx,
            enabled,
            true,
            enabledTokenGated
        );

        emit InfanityCreated({
            brandId: brandId,
            itemId: itemId,
            mintPriceInWei: mintPriceInWei,
            cap: cap,
            enabled: enabled,
            exist: true
        });

        collectionIds.push(itemId);
    }

    function updateInfanityData(
        uint256 _id,
        uint256 _mintPriceInWei,
        uint256 _cap,
        uint256 _maxMintPerAddress,
        uint256 _maxMintPerTx

    ) 
        external
        onlyHasRole(ADMIN_ROLE) 
        onlyExistingItem(_id) 
    {
        if (infanities[_id].minted >= _cap) {
            revert UpdateLessThanCap();
        }

        infanities[_id].mintPriceInWei = _mintPriceInWei;
        infanities[_id].cap = _cap;
        infanities[_id].maxMintPerAddress = _maxMintPerAddress;
        infanities[_id].maxMintPerTx = _maxMintPerTx;
    }

    function updateTokenGatedInfo(
        uint256 _id, 
        address _token,
        uint256 _tokenGatedId, 
        bool _enabled
    )
        external
        onlyHasRole(ADMIN_ROLE) 
        onlyExistingItem(_id) 
    {
        if (_enabled) {
            if (_token == address(0)) revert SetToZeroAddress();
        }

        infanities[_id].tokenGated = _token;
        infanities[_id].tokenGatedId = _tokenGatedId;
        infanities[_id].enabledTokenGated = _enabled;
    }

    function updateItemsMintPrice(
        uint256 _id, 
        uint256 _mintPriceInWei
    ) 
        external 
        onlyHasRole(ADMIN_ROLE) 
        onlyExistingItem(_id) 
    {
        infanities[_id].mintPriceInWei = _mintPriceInWei;
    }

    function updateItemCap(
        uint256 _id, 
        uint256 cap
    ) 
        external 
        onlyHasRole(ADMIN_ROLE) 
        onlyExistingItem(_id) 
    {
        if (infanities[_id].minted >= cap) {
            revert UpdateLessThanCap();
        }

        infanities[_id].cap = cap;
    }

    function setURI(string memory _baseUri) external onlyHasRole(ADMIN_ROLE) {
        _setURI(_baseUri);
    }

    /// @dev Get next tokenId
    function nextItemId() public view returns (uint256) {
        return _nextItemId.current();
    }

    function getTokenGatedBalance(address caller, address tokenAddrs, uint256 tokenId) public view returns (uint256) {
        if (tokenAddrs.supportsInterface(type(IERC1155).interfaceId)) {
            return IERC1155(tokenAddrs).balanceOf(caller, tokenId);
        } else if (tokenAddrs.supportsInterface(type(IERC721).interfaceId)) {
            return IERC721(tokenAddrs).balanceOf(caller);
        } else {
            return IERC721A(tokenAddrs).balanceOf(caller);
        } 
    }

     // === Royalty === //

    /// @dev Set the royalty for all collection
    /// @param _feeNumerator The fee for collection
    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator)
        public
        onlyHasRole(ADMIN_ROLE)
    {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    /// @dev Set royalty fee for specific token
    /// @param _tokenId The tokenId where to add the royalty
    /// @param _receiver The royalty receiver
    /// @param _feeNumerator the fee for specific tokenId
    function setTokenRoyalty(
        uint256 _tokenId,
        address _receiver,
        uint96 _feeNumerator
    ) public onlyHasRole(ADMIN_ROLE) {
        _setTokenRoyalty(_tokenId, _receiver, _feeNumerator);
    }

    /// @dev Allow owner to delete the default royalty for all collection
    function deleteDefaultRoyalty() external onlyHasRole(ADMIN_ROLE) {
        _deleteDefaultRoyalty();
    }

    /// @dev Reset specific royalty
    /// @param tokenId The token id where to reset the royalty
    function resetTokenRoyalty(uint256 tokenId)
        external
        onlyHasRole(ADMIN_ROLE)
    {
        _resetTokenRoyalty(tokenId);
    }

    // === Withdrawal ===

    /// @dev Set wallets shares
    /// @param _wallets The wallets
    /// @param _walletsShares The wallets shares
    function setWithdrawalInfo(
        address[] memory _wallets,
        uint256[] memory _walletsShares
    ) public onlyHasRole(ADMIN_ROLE) {
        require(_wallets.length == _walletsShares.length, "not equal");
        wallets = _wallets;
        walletsShares = _walletsShares;

        totalShares = 0;
        for (uint256 i = 0; i < _walletsShares.length; i++) {
            totalShares += _walletsShares[i];
        }
    }

    /// @dev Withdraw contract native token balance
    function withdraw() external onlyHasRole(ADMIN_ROLE) {
        require(address(this).balance > 0, "no eth to withdraw");
        uint256 totalReceived = address(this).balance;
        for (uint256 i = 0; i < walletsShares.length; i++) {
            uint256 payment = (totalReceived * walletsShares[i]) / totalShares;
            Address.sendValue(payable(wallets[i]), payment);
        }
    }

    // === SupportInterface === //

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC2981, AccessControl)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(AccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // == royalty for opensea
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    receive() external payable {}

}