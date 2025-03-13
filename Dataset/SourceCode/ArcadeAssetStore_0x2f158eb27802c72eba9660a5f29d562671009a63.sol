//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "openzeppelin/token/ERC1155/utils/ERC1155Holder.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/cryptography/MerkleProof.sol";
import "./ArcadeAsset.sol";
import "./IAssetInfo.sol";

error InvalidArrayLength(uint256 len1, uint256 len2);
error FailedToSend();
error InsufficientMintPrice(uint256 value, uint256 totalPrice);
error MintLimitExceeded(uint256 amount, uint256 mintLimit);
error TokenNotClaimable(uint256 tokenID);
error AlreadyClaimed(uint256 tokenID);
error InvalidSaleState(uint256 tokenID);

contract ArcadeAssetStore is ERC1155Holder, Ownable, IAssetInfo {
    ArcadeAsset public arcadeAsset;
    mapping(uint256 => AssetInfo) public tokenIDToAssetInfo;
    mapping(uint256 => SaleState) public tokenIDToSaleState;

    // BatchKey => AssetID => Address => Amount
    string public batchKey;
    mapping(string => mapping(uint256 => mapping(address => uint256))) public claimed;
    mapping(uint256 => mapping(address => uint256)) public publicMinted;

    bytes32 public merkleRoot;

    constructor(address _assetAddress) {
        arcadeAsset = ArcadeAsset(_assetAddress);
    }

    function setAssetAddress(address _assetAddress) public onlyOwner {
        arcadeAsset = ArcadeAsset(_assetAddress);
    }

    function setWhitelistMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setBatchKey(string memory _batchKey) public onlyOwner {
        batchKey = _batchKey;
    }

    function addAssetInfo(uint256[] calldata tokenIDs, AssetInfo[] calldata assetInfoList) public override onlyOwner {
        if (tokenIDs.length != assetInfoList.length) {
            revert InvalidArrayLength(tokenIDs.length, assetInfoList.length);
        }
        for (uint256 i = 0; i < assetInfoList.length; i++) {
            tokenIDToAssetInfo[tokenIDs[i]] = assetInfoList[i];
        }
    }

    function setSaleState(uint256[] calldata tokenIDs, SaleState[] calldata saleStates) public override onlyOwner {
        if (tokenIDs.length != saleStates.length) {
            revert InvalidArrayLength(tokenIDs.length, saleStates.length);
        }
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            tokenIDToSaleState[tokenIDs[i]] = saleStates[i];
        }
    }

    function claim(uint256[] calldata tokenIDs, uint256[] calldata amounts, bytes32[] calldata merkleProof) public {
        if (tokenIDs.length != amounts.length) {
            revert InvalidArrayLength(tokenIDs.length, amounts.length);
        }
        bytes32 node = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, tokenIDs, amounts))));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid proof");

        for (uint256 i = 0; i < tokenIDs.length; i++) {
            if (tokenIDToSaleState[tokenIDs[i]] != SaleState.Claimable) {
                revert TokenNotClaimable(tokenIDs[i]);
            }
            if (amounts[i] > 0) {
                if (claimed[batchKey][tokenIDs[i]][_msgSender()] != 0) {
                    revert AlreadyClaimed(tokenIDs[i]);
                }
                claimed[batchKey][tokenIDs[i]][_msgSender()] = amounts[i];
                arcadeAsset.mint(_msgSender(), tokenIDs[i], amounts[i]);
            }
        }
    }

    function publicSale(uint256 tokenID, uint256 amount) public payable {
        if (tokenIDToSaleState[tokenID] != SaleState.PublicSale) {
            revert InvalidSaleState(tokenID);
        }
        AssetInfo memory assetInfo = tokenIDToAssetInfo[tokenID];

        if (amount + publicMinted[tokenID][_msgSender()] > assetInfo.mintLimit) {
            revert MintLimitExceeded(amount + publicMinted[tokenID][_msgSender()], assetInfo.mintLimit);
        }
        if (msg.value < assetInfo.mintPrice * amount) {
            revert InsufficientMintPrice(msg.value, assetInfo.mintPrice * amount);
        }
        publicMinted[tokenID][_msgSender()] += amount;
        arcadeAsset.mint(_msgSender(), tokenID, amount);
    }

    function mint(address account, uint256 id, uint256 amount) public onlyOwner {
        arcadeAsset.mint(account, id, amount);
    }

    function safeTransferFrom(address to, uint256 id, uint256 amount) public onlyOwner {
        arcadeAsset.safeTransferFrom(address(this), to, id, amount, "");
    }

    function safeBatchTransferFrom(address to, uint256[] memory ids, uint256[] memory amounts) public onlyOwner {
        arcadeAsset.safeBatchTransferFrom(address(this), to, ids, amounts, "");
    }

    function withdraw(address payable _to) public onlyOwner {
        // Call returns a boolean value indicating success or failure.
        (bool sent, ) = _to.call{value: address(this).balance}("");
        if (sent == false) {
            revert FailedToSend();
        }
    }
}