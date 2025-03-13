// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

/// @title Pixelmon Trainer Adventure Smart Contract
/// @author LiquidX
/// @notice This smart contract is used for storing treasure in Trainer Adventure event on Pixelmon

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./WinnerSelectionManager.sol";
import "./Utils.sol";

/// @notice Thrown when input data length is not as expected
error NotSorted();
/// @notice Thrown when no amount of treasure is available in vault or 'availableTreasure' value is 0
error TreasureNotAvailable();
/// @notice Thrown when pool index is not available
error InvalidPoolIndex();
/// @notice Thrown when treasure vault is not exist in pool or vault
error InvalidVaultIndex();
/// @notice Thrown when pool size exceeding the maximum pool size
error MaximumPoolSizeExceeded();
/// @notice Thrown when treasure is already claimed by the same user in the same week
error ALreadyClaimed();
/// @notice Thrown when address is not part of the winner Merkle Tree
error NotAWinner();

contract PixelmonTrainerAdventure is WinnerSelectionManager, Utils, ReentrancyGuard {
    /// @notice use SafeMath library from OpenZeppelin for unit256 type
    using SafeMath for uint256;

    /// @notice Maximum amount of prize in the pool
    uint256 constant MAXIMUM_POOL_SIZE = 500;

    /// @notice List of available contract type for treasure
    /// @dev Use this to set and validate treasure contract type
    enum ContractType {
        ERC_1155,
        ERC_721
    }

    /// @notice The state of a treasure
    /// @dev Use this to set and validate the state of a treasure
    enum TreasureStatus {
        Invalid,
        AtVault,
        AtPool,
        Claimed,
        Rescued
    }

    /// @notice Enforce rule to add required information of a treasure
    /// @dev This can be used as parameter type when inputting token information in a function
    struct TreasureInput {
        address collectionAddress;
        uint256 tokenId;
        uint256 amount;
    }

    /// @notice A list of information that can be acquired from a treasure
    /// @dev This is used in mapping to keep track the treasure state
    struct Treasure {
        uint256 vaultIndex;
        address collectionAddress;
        uint256 tokenId;
        uint256 contractType;
        uint256 status;
        uint256 claimIndex;
        address receiverWallet;
    }

    /// @notice Current amount of treasure in a pool
    uint256 public treasurePoolSize = 0;
    /// @notice Collection of treasure in pool
    uint256[MAXIMUM_POOL_SIZE + 1] public treasurePool;

    /// @notice Total available treasure in vault
    /// @dev This number is also used as index for mapping the Treasure object
    uint256 public totalTreasure;
    /// @notice Amount of treasure that is available to be claimed
    uint256 public availableTreasure;
    /// @notice Index for claimed treasure
    uint256 public claimIndexCount;

    /// @notice List of treasure in vault
    /// @custom:key Index of the treasure
    /// @custom:value The treasure information
    mapping(uint256 => Treasure) public treasureVault;

    /// @notice Emit when a treasure is claimed
    /// @param weekNumber The week number when the treasure is claimed
    /// @param requestId ID for the claimed index
    /// @param userWallet Address who claimed the treasure
    /// @param collectionAddress Origin of the treasure
    /// @param tokenId Treasure token ID
    /// @param tokenType Treasure contract type (ERC721 or ERC1155)
    /// @param randomNumber Random number used when claiming the treasure, this is used to pick treasure in a pool
    event TreasureTransferred(
        uint256 weekNumber,
        uint256 requestId,
        address userWallet,
        address collectionAddress,
        uint256 tokenId,
        uint256 tokenType,
        uint256 randomNumber
    );

    constructor(
        address _vrfCoordinator,
        uint64 _chainLinkSubscriptionId,
        bytes32 _keyHash
    ) WinnerSelectionManager(_vrfCoordinator, _chainLinkSubscriptionId, _keyHash) {}

    /// @notice Add ERC1155 token as treasure to vault
    /// @dev Only user that has role "Admin" can call this function
    /// @param _treasures Information about the treasure
    function addERC1155TreasuresToVault(TreasureInput[] calldata _treasures) external onlyAdmin(msg.sender) {
        for (uint256 index = 0; index < _treasures.length; index = _uncheckedInc(index)) {
            for (uint256 tokenCount = 0; tokenCount < _treasures[index].amount; tokenCount = _uncheckedInc(tokenCount)) {
                unchecked {
                    totalTreasure++;
                }

                treasureVault[totalTreasure] = Treasure({
                    vaultIndex: totalTreasure,
                    collectionAddress: _treasures[index].collectionAddress,
                    tokenId: _treasures[index].tokenId,
                    receiverWallet: address(0),
                    claimIndex: 0,
                    contractType: uint256(ContractType.ERC_1155),
                    status: uint256(TreasureStatus.AtVault)
                });
            }
            unchecked {
                availableTreasure += _treasures[index].amount;
            }
            IERC1155 erc1155Contract = IERC1155(_treasures[index].collectionAddress);
            erc1155Contract.safeTransferFrom(msg.sender, address(this), _treasures[index].tokenId, _treasures[index].amount, "");
        }
    }

    /// @notice Add ERC721 token as treasure to vault
    /// @dev Only user that has role "Admin" can call this function
    /// @param _treasures Information about the treasure
    function addERC721TreasuresToVault(TreasureInput[] calldata _treasures) external onlyAdmin(msg.sender) {
        for (uint256 index = 0; index < _treasures.length; index = _uncheckedInc(index)) {
            unchecked {
                totalTreasure++;
                availableTreasure++;
            }
            treasureVault[totalTreasure] = Treasure({
                vaultIndex: totalTreasure,
                collectionAddress: _treasures[index].collectionAddress,
                tokenId: _treasures[index].tokenId,
                receiverWallet: address(0),
                claimIndex: 0,
                contractType: uint256(ContractType.ERC_721),
                status: uint256(TreasureStatus.AtVault)
            });
            IERC721 erc721Contract = IERC721(_treasures[index].collectionAddress);
            erc721Contract.transferFrom(msg.sender, address(this), _treasures[index].tokenId);
        }
    }

    /// @notice Transfer available treasure in pool to other address
    /// @param _weekNumber Number of the week
    /// @param _vaultIndex Index of the treasure in the vault
    /// @param _poolIndex Index of the treasure in the pool
    /// @param _transferTo Receiver of the treasure
    function rescueTreasureFromPool(
        uint256 _weekNumber,
        uint256 _vaultIndex,
        uint256 _poolIndex,
        address _transferTo
    ) external nonReentrant noContracts onlyOwner validPoolUpdationPeriod(_weekNumber) {
        if (treasureVault[_vaultIndex].status != uint256(TreasureStatus.AtPool)) {
            revert InvalidVaultIndex();
        }

        if (_poolIndex == 0 || _poolIndex > treasurePoolSize || treasurePool[_poolIndex] != _vaultIndex) {
            revert InvalidPoolIndex();
        }

        availableTreasure--;
        treasureVault[_vaultIndex].status = uint256(TreasureStatus.Rescued);
        removeTreasureFromPool(_poolIndex);

        transferToken(
            treasureVault[_vaultIndex].collectionAddress,
            treasureVault[_vaultIndex].contractType,
            address(this),
            _transferTo,
            treasureVault[_vaultIndex].tokenId,
            1
        );
    }

    /// @notice Transfer available treasure in vault to other address
    /// @param _weekNumber Number of the week
    /// @param _vaultIndex Index of the treasure in the vault
    /// @param _transferTo Receiver of the treasure
    function rescueTreasureFromVault(
        uint256 _weekNumber,
        uint256 _vaultIndex,
        address _transferTo
    ) external nonReentrant noContracts onlyOwner validPoolUpdationPeriod(_weekNumber) {
        if (treasureVault[_vaultIndex].status != uint256(TreasureStatus.AtVault)) {
            revert InvalidVaultIndex();
        }
        availableTreasure--;
        treasureVault[_vaultIndex].status = uint256(TreasureStatus.Rescued);
        treasureVault[_vaultIndex].receiverWallet = _transferTo;
        transferToken(
            treasureVault[_vaultIndex].collectionAddress,
            treasureVault[_vaultIndex].contractType,
            address(this),
            _transferTo,
            treasureVault[_vaultIndex].tokenId,
            1
        );
    }

    /// @notice Transfer token from smart contract to an address
    /// @param _collection Collection address
    /// @param _type Token standard. '0' for ERC1155 and '1' for ERC721
    /// @param _to Address who will receive the token
    /// @param _id token ID
    /// @param _amount Amount of token to transfer
    function emergencyRescue(
        address _collection,
        uint256 _type,
        address _to,
        uint256 _id,
        uint256 _amount
    ) external nonReentrant noContracts onlyOwner {
        transferToken(_collection, _type, address(this), _to, _id, _amount);
    }

    /// @notice Helper function to transfer token
    /// @param _collection Collection address
    /// @param _type Token standard. '0' for ERC1155 and '1' for ERC721
    /// @param _from Address who owns the token
    /// @param _to Address who will receive the token
    /// @param _id token ID
    /// @param _amount Amount of token to transfer
    function transferToken(
        address _collection,
        uint256 _type,
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal {
        if (_type == uint256(ContractType.ERC_1155)) {
            IERC1155 erc1155Contract = IERC1155(_collection);
            erc1155Contract.safeTransferFrom(_from, _to, _id, _amount, "");
        }
        if (_type == uint256(ContractType.ERC_721)) {
            IERC721 erc721Contract = IERC721(_collection);
            erc721Contract.transferFrom(_from, _to, _id);
        }
    }

    /// @notice Claim treasure from the pool. Can only claim 1 treasure per week
    /// @param _weekNumber Number of the week
    /// @param proof Proof to verify Merkle Tree
    function claimTreasure(uint256 _weekNumber, bytes32[] calldata proof) external nonReentrant noContracts {
        if (!(block.timestamp >= weekInfos[_weekNumber].claimStartTimeStamp && block.timestamp <= weekInfos[_weekNumber].endTimeStamp)) {
            revert InvalidClaimingPeriod();
        }
        if (!verify(_weekNumber, proof)) {
            revert NotAWinner();
        }
        if (weekInfos[_weekNumber].claimed[msg.sender]) {
            revert ALreadyClaimed();
        }
        weekInfos[_weekNumber].claimed[msg.sender] = true;

        uint256 randomNumber = getRandomNumber();
        uint256 poolIndex = (randomNumber.mod(treasurePoolSize)) + 1;
        uint256 vaultIndex = treasurePool[poolIndex];
        removeTreasureFromPool(poolIndex);

        unchecked {
            claimIndexCount++;
            availableTreasure--;
        }

        treasureVault[vaultIndex].status = uint256(TreasureStatus.Claimed);
        treasureVault[vaultIndex].receiverWallet = msg.sender;
        treasureVault[vaultIndex].claimIndex = claimIndexCount;

        transferToken(
            treasureVault[vaultIndex].collectionAddress,
            treasureVault[vaultIndex].contractType,
            address(this),
            treasureVault[vaultIndex].receiverWallet,
            treasureVault[vaultIndex].tokenId,
            1
        );

        emit TreasureTransferred(
            _weekNumber,
            claimIndexCount,
            treasureVault[vaultIndex].receiverWallet,
            treasureVault[vaultIndex].collectionAddress,
            treasureVault[vaultIndex].tokenId,
            treasureVault[vaultIndex].contractType,
            randomNumber
        );
    }

    /// @notice Remove treasure from the pool
    /// @param _poolIndex Index of the treasure in the pool
    function removeTreasureFromPool(uint256 _poolIndex) internal {
        treasurePool[_poolIndex] = treasurePool[treasurePoolSize];
        treasurePoolSize--;
    }

    /// @notice Move treasure back to vault
    /// @param _weekNumber Number of the week
    /// @param _poolIndexs Indexs of the treasure in the pool
    function removeTreasureFromPoolExternal(uint256 _weekNumber, uint256[] memory _poolIndexs)
        external
        onlyAdmin(msg.sender)
        validPoolUpdationPeriod(_weekNumber)
    {
        for (uint256 index = 0; index < _poolIndexs.length; index++) {
            if (_poolIndexs[index] == 0 || _poolIndexs[index] > treasurePoolSize) {
                revert InvalidPoolIndex();
            }
            if (index != 0 && _poolIndexs[index] >= _poolIndexs[index - 1]) {
                revert NotSorted();
            }
            treasureVault[treasurePool[_poolIndexs[index]]].status = uint256(TreasureStatus.AtVault);
            removeTreasureFromPool(_poolIndexs[index]);
        }
    }

    /// @notice Move treasure from vault to pool
    /// @param _weekNumber Number of the week
    /// @param _vaultIndexs Indexs of the treasure in the vault
    function addTreasuresToPool(uint256 _weekNumber, uint256[] calldata _vaultIndexs)
        external
        onlyAdmin(msg.sender)
        validPoolUpdationPeriod(_weekNumber)
    {
        if (treasurePoolSize + _vaultIndexs.length > MAXIMUM_POOL_SIZE) {
            revert MaximumPoolSizeExceeded();
        }
        if (_vaultIndexs.length > availableTreasure) {
            revert InvalidVaultIndex();
        }

        for (uint256 index = 0; index < _vaultIndexs.length; index++) {
            if (treasureVault[_vaultIndexs[index]].status == uint256(TreasureStatus.AtVault)) {
                treasurePoolSize++;
                treasurePool[treasurePoolSize] = _vaultIndexs[index];
                treasureVault[_vaultIndexs[index]].status = uint256(TreasureStatus.AtPool);
            } else {
                revert TreasureNotAvailable();
            }
        }
    }

    /// @notice Check whether the interface ID implements interface from IERC1155 or IERC721
    /// @param interfaceID input interface ID
    /// @return 'true' if the interface is either ERC1155 or ERC721
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == type(IERC1155Receiver).interfaceId || interfaceID == type(IERC721Receiver).interfaceId;
    }

    /// @notice Move all treasure in the pool back to vault
    /// @param _weekNumber Number of the week
    function resetTreasurePool(uint256 _weekNumber) external onlyAdmin(msg.sender) validPoolUpdationPeriod(_weekNumber) {
        for (uint256 index = 1; index <= treasurePoolSize; index++) {
            treasureVault[treasurePool[index]].status = uint256(TreasureStatus.AtVault);
        }
        treasurePoolSize = 0;
    }

    /// @notice Get treasure information in the pool
    /// @return  treasurePoolInfos List of treasure information in the pool
    function getTreasurePoolInfo() external view returns (uint256[] memory treasurePoolInfos) {
        uint256[] memory treasureIndexes = new uint256[](treasurePool.length);
        for (uint256 index = 0; index < treasurePool.length; index++) {
            treasureIndexes[index] = treasurePool[index];
        }
        return treasureIndexes;
    }

    /// @notice Get treasure information
    /// @param _collectionAddress Origin of the treasure
    /// @param _tokenIds Treasure token ID
    /// @param _status Treasure state (0: Invalid, 1: In vault, 2: In pool, 3: Claimed, 4: Rescued)
    /// @return treasureInfos of treasure that matches the parameter
    function getTreasureVaultInfo(
        address _collectionAddress,
        uint256[] memory _tokenIds,
        uint256[] memory _status
    ) external view returns (Treasure[] memory treasureInfos) {
        uint256 dataLength = 0;
        Treasure[] memory tmp = new Treasure[](totalTreasure);
        for (uint256 index = 1; index <= totalTreasure; index++) {
            if (
                (treasureVault[index].collectionAddress == _collectionAddress || _collectionAddress == address(0)) &&
                (IsdataExistsInArray(_tokenIds, treasureVault[index].tokenId) || _tokenIds.length == 0) &&
                IsdataExistsInArray(_status, treasureVault[index].status)
            ) {
                tmp[dataLength] = treasureVault[index];
                dataLength++;
            }
        }
        Treasure[] memory treasures = new Treasure[](dataLength);

        for (uint256 index = 0; index < dataLength; index++) {
            Treasure memory treasure = tmp[index];
            treasures[index] = treasure;
        }
        return treasures;
    }

    /// @notice Get treasure information in vault
    /// @param index Index of the treasure in vault
    /// @return treasure Treasure information
    function getTreasureVaultByIndex(uint256 index) external view returns (Treasure memory treasure) {
        treasure = treasureVault[index];
    }
}