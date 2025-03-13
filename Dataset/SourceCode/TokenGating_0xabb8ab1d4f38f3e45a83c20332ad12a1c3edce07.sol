// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC721, IERC165} from "../../openzeppelin/token/ERC721/IERC721.sol";
import "../../openzeppelin/token/ERC1155/IERC1155.sol";
import "../../manifold/libraries-solidity/access/AdminControlUpgradeable.sol";
import "../../openzeppelin/utils/introspection/ERC165Checker.sol";
import "../../openzeppelin-upgradeable/access/IAccessControlUpgradeable.sol";
import "../../manifold/royalty-registry/specs/INiftyGateway.sol";
import "../../manifold/royalty-registry/specs/IFoundation.sol";
import {IERC721CreatorCore} from "../../manifold/creator-core/core/IERC721CreatorCore.sol";
import {IERC1155CreatorCore} from "../../manifold/creator-core/core/IERC1155CreatorCore.sol";
import {ReentrancyGuard} from "../../openzeppelin/security/ReentrancyGuard.sol";
import {AdminControl} from "../../manifold/libraries-solidity/access/AdminControl.sol";
import {ECDSA} from "../../openzeppelin/utils/cryptography/ECDSA.sol";

/**
 * @title Token Gating
 * @dev This contract facilitates to gate the collections and gives privilages for the gated token owners to claim the nft from the 
 * required nft collections.
 */
contract TokenGating is ReentrancyGuard, AdminControl {
    using ECDSA for bytes32;
    
    /// @notice The Gating data at collection level
    /// @param perTokenLimit the limit per token
    /// @param perCollectionLimit the limit per collection
    struct CollectionGatingData {
        uint256 perTokenLimit;
        uint256 perCollectionLimit;
    }

    /// @notice The signing data by admin
    /// @param expirationTime the expiration time for the signature
    /// @param nonce the unique nonce for the signature
    /// @param signature the signature data given by signer
    /// @param signer the address of the signer
    struct Approval {
        uint32 expirationTime;
        string nonce;
        bytes signature;
        address signer;
    }

    // admin approval requirement
    bool public adminApprovalRequired; 
    
    // sets Collection gating data with respect to collection
    mapping(address => CollectionGatingData) private collectionLimitations;

    // sets token limit with respect to tokenID of collection concerned
    mapping(address => mapping(uint256 => uint256)) private tokenLimitations;

    // sets perToken limit with respect to tokenID of collection concerned
    mapping(address => mapping(uint256 => uint256)) private perTokenLimitation;

    // signature validation
    mapping(bytes => bool) public signatureUsed;
    
    // sets interface ERC721 Id
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;

    // sets interface ERC1155 Id
    bytes4 private constant ERC1155_INTERFACE_ID = 0xd9b67a26;
    
    /// @notice the type of gating
    enum GatingType {
        collection,
        token
    }
   
     
    /// @notice emits an event when gated minting
    /// @param gatedCollection the collection address which is gated
    /// @param tokenId the token id
    /// @param mintedWallet the minter wallet address
    /// @param mintingContract the contract address of minting process
    /// @param tokenIdMinted the minted token ids
    event gatedMinting(
        address indexed gatedCollection,
        uint256 indexed tokenId,
        address mintedWallet,
        address mintingContract,
        uint256[] tokenIdMinted
    );
    
    /// @notice emits an event when gated transfer
    /// @param gatedCollection the collection address which is gated
    /// @param tokenId the token id
    /// @param transferWallet the wallet address of Nft transferred
    /// @param transferContract the contract address of transfer process
    /// @param transferTokenId the token id which is transferred
    /// @param transferOwner the Owner address where the nft transfers from
    event gatedTransfer(
        address indexed gatedCollection,
        uint256 indexed tokenId,
        address transferWallet,
        address transferContract,
        uint256 transferTokenId,
        address transferOwner
    );
    
    /// @notice emits an event when acquiring gated info
    /// @param gatedCollection the collection address which is gated
    /// @param gatedTokenId the token id which is gated
    /// @param acquiredAddress the address of acquiring entity
    /// @param gatingType the contract address of transfer process
    event gatingAcquired(
        address gatedCollection,
        uint256 gatedTokenId,
        address acquiredAddress,
        string gatingType
    );
    
    /// @notice emits an event when token is gated
    /// @param gatedCollection the collection address which is gated
    /// @param tokenId the token id 
    /// @param limit the gating limit 
    event tokenGated(address gatedCollection, uint256 tokenId, uint256 limit);
    
    /// @notice emits an event when Collection is gated
    /// @param gatedCollection the collection address which is gated
    /// @param perCollectionLimit the gating limit at collection level
    /// @param petTokenLimit the gating limit at token level
    event collectionGated(
        address gatedCollection,
        uint256 perCollectionLimit,
        uint256 petTokenLimit
    );
    
   /**
     * @notice constructor
     * @param _adminApprovalRequired the set/reset the admin approval
     */
    constructor(bool _adminApprovalRequired) {

        adminApprovalRequired = _adminApprovalRequired;
    }
    
    /**
     * @notice setTokenGating, sets gating data at token level
     * @param collectionAddress the address of nft collection
     * @param tokenId the id of token
     * @param limit the gating limit of token id
     */
    function setTokenGating(
        address collectionAddress,
        uint256 tokenId,
        uint256 limit
    ) public nonReentrant {
        require(
            isAdmin(msg.sender) ,
            "sender should be a Admin"
        );

        tokenLimitations[collectionAddress][tokenId] = limit;

        emit tokenGated(collectionAddress, tokenId, limit);
    }
    
    /**
     * @notice setCollectionGating, sets gating data at collection level
     * @param collectionAddress the address of nft collection
     * @param perTokenLimit the gating limit of per token
     * @param perCollectionLimit the gating limit of collection
     */
    function setCollectionGating(
        address collectionAddress,
        uint256 perTokenLimit,
        uint256 perCollectionLimit
    ) public nonReentrant {
        require(
            isAdmin(msg.sender),
            "sender should be a Admin "
        );
        collectionLimitations[collectionAddress] = CollectionGatingData(
            perTokenLimit,
            perCollectionLimit
        );

        emit collectionGated(
            collectionAddress,
            perCollectionLimit,
            perTokenLimit
        );
    }
   
    /**
     * @notice acquireGating, updates gating data while acquiring the gated related info
     * @param collectionAddress the address of nft collection
     * @param tokenId the Token id
     * @param walletAddress the user wallet address who acquiring the info.
     */
    function acquireGating(
        address collectionAddress,
        uint256 tokenId,
        address walletAddress
    ) public nonReentrant returns (bool) {
        require(
            walletAddress == tx.origin ||
                walletAddress == msg.sender ||
                isAdmin(msg.sender),
            "msg.sender should be wallet address or the admin"
        );
        require(
            ownerOf(collectionAddress, tokenId, walletAddress),
            "allows only whitelisted collections tokens wallet"
        );
        string memory gatingType;
        if (
            collectionLimitations[collectionAddress].perTokenLimit != 0 &&
            collectionLimitations[collectionAddress].perCollectionLimit > 0 &&
            perTokenLimitation[collectionAddress][tokenId] <
            collectionLimitations[collectionAddress].perTokenLimit
        ) {
            collectionLimitations[collectionAddress].perCollectionLimit -= 1;
            perTokenLimitation[collectionAddress][tokenId] += 1;
            gatingType = "CollectionLevel";
        }
        if (
            tokenLimitations[collectionAddress][tokenId] > 0 &&
            bytes(gatingType).length == 0
        ) {
            tokenLimitations[collectionAddress][tokenId] -= 1;
            gatingType = "TokenLevel";
        }
        if (bytes(gatingType).length == 0) {
            revert("the token in the collection does not have any limitation");
        }

        emit gatingAcquired(collectionAddress, tokenId, msg.sender, gatingType);
        return true;
    }
    
    /**
     * @notice mint, mintng the nft 
     * @param gatedCollection the address of gated nft collection
     * @param gatedTokenId the id of the gated token
     * @param walletAddress the user wallet address 
     * @param mintCollectionAddress the collection address of minting process
     * @param tokenIdExt1155 the token id
     * @param approval the approval status
     */
    function mint(
        address gatedCollection,
        uint256 gatedTokenId,
        address walletAddress,
        address mintCollectionAddress,
        uint256 tokenIdExt1155,
        Approval calldata approval
    ) public {
            if (adminApprovalRequired ) {
            require(
                isAdmin(approval.signer),
                "only owner or admin can sign for discount"
            );
            require(
                !signatureUsed[approval.signature],
                "signature already applied"
            );
            require(
                _verifySignature(
                    walletAddress,
                    approval.expirationTime,
                    approval.signer,
                    approval.nonce,
                    approval.signature
                ),
                "invalid approval signature"
            );
            signatureUsed[approval.signature] = true;

        }
        acquireGating(gatedCollection, gatedTokenId, walletAddress);
        uint256[] memory mintedTokenId = new uint256[](1);
        if (
            IERC165(mintCollectionAddress).supportsInterface(
                ERC721_INTERFACE_ID
            )
        ) {
            // Minting the ERC721 in a batch
            mintedTokenId[0] = IERC721CreatorCore(mintCollectionAddress)
                .mintExtension(walletAddress);
        } else if (
            IERC165(mintCollectionAddress).supportsInterface(
                ERC1155_INTERFACE_ID
            )
        ) {
            address[] memory to = new address[](1);
            uint256[] memory amounts = new uint256[](1);
            string[] memory uris = new string[](1);
            to[0] = walletAddress;
            amounts[0] = 1;
            if (
                IERC1155CreatorCore(mintCollectionAddress).totalSupply(
                    tokenIdExt1155
                ) == 0
            ) {
                // Minting ERC1155  of already existing tokens
                mintedTokenId = IERC1155CreatorCore(mintCollectionAddress)
                    .mintExtensionNew(to, amounts, uris);
            } else if (
                IERC1155CreatorCore(mintCollectionAddress).totalSupply(
                    tokenIdExt1155
                ) > 0
            ) {
                uint256[] memory tokenIdNew = new uint256[](1);
                tokenIdNew[0] = tokenIdExt1155;
                // Minting new ERC1155 tokens
                IERC1155CreatorCore(mintCollectionAddress)
                    .mintExtensionExisting(to, tokenIdNew, amounts);
            }
        }
        emit gatedMinting(
            gatedCollection,
            gatedTokenId,
            walletAddress,
            mintCollectionAddress,
            mintedTokenId
        );
    }
    
    /**
     * @notice transfer, transfer the nft 
     * @param gatedCollection the address of gated nft collection
     * @param gatedTokenId the id of the gated token
     * @param walletAddress the user wallet address 
     * @param transferCollection the collection address of transfer process
     * @param transferTokenId the token id
     * @param transferOwner the owner address
     * @param approval the approval status
     */
    function transfer(
        address gatedCollection,
        uint256 gatedTokenId,
        address walletAddress,
        address transferCollection,
        uint256 transferTokenId,
        address transferOwner,
        Approval calldata approval
    ) public {

            if (adminApprovalRequired ) {
            require(
                isAdmin(approval.signer),
                "only owner or admin can sign for discount"
            );
            require(
                !signatureUsed[approval.signature],
                "signature already applied"
            );
            require(
                _verifySignature(
                    walletAddress,
                    approval.expirationTime,
                    approval.signer,
                    approval.nonce,
                    approval.signature
                ),
                "invalid approval signature"
            );
            signatureUsed[approval.signature] = true;

        }
        acquireGating(gatedCollection, gatedTokenId, walletAddress);

        if (
            IERC165(transferCollection).supportsInterface(ERC721_INTERFACE_ID)
        ) {
            // Transferring the ERC721
            IERC721(transferCollection).safeTransferFrom(
                transferOwner,
                walletAddress,
                transferTokenId
            );
        } else if (
            IERC165(transferCollection).supportsInterface(ERC1155_INTERFACE_ID)
        ) {
            // Transferring the ERC1155
            IERC1155(transferCollection).safeTransferFrom(
                transferOwner,
                walletAddress,
                transferTokenId,
                1,
                "0x"
            );
        }
        emit gatedTransfer(
            gatedCollection,
            gatedTokenId,
            walletAddress,
            transferCollection,
            transferTokenId,
            transferOwner
        );
    }
    
    /**
     * @notice cancelTokenGating, cancels gating data at token level
     * @param collectionAddress the address of nft collection
     * @param tokenId the id of token
     * @param limit the gating limit of token id
     */
    function cancelTokenGating(
        address collectionAddress,
        uint256 tokenId,
        uint256 limit
    ) public nonReentrant {
        require(
            isAdmin(msg.sender),
            "sender should be a Admin "
        );

        delete tokenLimitations[collectionAddress][tokenId];

        emit tokenGated(collectionAddress, tokenId, limit);
    }
    
    /**
     * @notice cancelCollectionGating, cancels gating data at collection level
     * @param collectionAddress the address of nft collection
     * @param perTokenLimit the gating limit of per token
     * @param perCollectionLimit the gating limit of collection
     */
    function cancelCollectionGating(
        address collectionAddress,
        uint256 perTokenLimit,
        uint256 perCollectionLimit
    ) public nonReentrant {
        require(
            isAdmin(msg.sender) ,
            "sender should be a Admin "
        );
        delete collectionLimitations[collectionAddress];

        emit collectionGated(
            collectionAddress,
            perCollectionLimit,
            perTokenLimit
        );
    }
    
    /**
     * @notice getTokenLimitation, gets gating limit of token
     * @param gatedCollection the address of nft collection
     * @param gatedTokenId the id of gated token id
     */
    function getTokenLimitation(
        address gatedCollection,
        uint256 gatedTokenId
    ) public view returns (uint256) {
        return tokenLimitations[gatedCollection][gatedTokenId];
    }
    
    /**
     * @notice getCollectionLimitation, gets gating limit of collection
     * @param gatedCollection the address of nft collection
     */
    function getCollectionLimitation(
        address gatedCollection
    ) public view returns (uint256 perCollectionLimit, uint256 perTokenLimit) {
        perCollectionLimit = collectionLimitations[gatedCollection]
            .perCollectionLimit;
        perTokenLimit = collectionLimitations[gatedCollection].perTokenLimit;
    }
    
    /**
     * @notice getCollectionTokenLimit, gets gating limit gated collection of given token id
     * @param gatedCollection the address of nft collection
     * @param gatedTokenId the id of gated token id
     * @param walletAddress the address that owns the nft
     */
    function getCollectionTokenLimit(
        address gatedCollection,
        uint256 gatedTokenId,
        address walletAddress
    ) public view returns (uint256 perTokenLimitRemining) {
        if(ownerOf(gatedCollection,gatedTokenId, walletAddress)) {
        perTokenLimitRemining =
            collectionLimitations[gatedCollection].perTokenLimit -
            perTokenLimitation[gatedCollection][gatedTokenId];
        } else {
            perTokenLimitRemining = 0;
        }

    }
    
    /**
     * @notice Verifes the signature
     * @param buyer the buyer address
     * @param expirationTime the exprire time stamp of signature
     * @param _signer the signer address
     * @param nonce the nonce used for sign generation
     * @param _signature the signature 
     */
    function _verifySignature(
        address buyer,
        uint32 expirationTime,
        address _signer,
        string calldata nonce,
        bytes calldata _signature
    ) internal view returns (bool) {
        require(
            expirationTime >= block.timestamp,
            "admin signature is already expired"
        );
        return
            keccak256(
                abi.encodePacked(
                    buyer,
                    expirationTime,
                    nonce,
                    "GATING",
                    block.chainid
                )
            ).toEthSignedMessageHash().recover(_signature) == _signer;
    }

    /**
     * @notice ownerOf, gets owner address
     * @param collectionAddress the address of collection contract
     * @param tokenId the id of token
     * @param sender the sender address
     */
    function ownerOf(
        address collectionAddress,
        uint256 tokenId,
        address sender
    ) internal view returns (bool isOwner) {
        if (IERC165(collectionAddress).supportsInterface(ERC721_INTERFACE_ID)) {
            IERC721 erc721 = IERC721(collectionAddress);
            return erc721.ownerOf(tokenId) == sender;
        }
        if (
            IERC165(collectionAddress).supportsInterface(ERC1155_INTERFACE_ID)
        ) {
            IERC1155 erc1155 = IERC1155(collectionAddress);
            return erc1155.balanceOf(sender, tokenId) > 0;
        }
    }
    
    /**
     * @notice updateAdminApproval, updates the admin approval
     * @param _adminApprovalRequired the boolean value of _adminApprovalRequired
     */
    function updateAdminApproval(bool _adminApprovalRequired) external adminRequired {
        adminApprovalRequired = _adminApprovalRequired;
    }
}