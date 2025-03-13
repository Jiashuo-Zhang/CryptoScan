// SPDX-License-Identifier: BUSL 1.0
// Metadrop Contracts (v0.0.1)

/**
 *
 * @title DropFactory.sol - Core contract for metadrop NFT drop creation.
 *
 * @author metadrop https://metadrop.com/
 *
 * @notice This contract performs the following roles:
 * - Storage of drop data that has been submitted to metadrop for approval.
 *   This information is held in hash format, and compared with sent data
 *   to create the drop.
 * - Drop creation. This factory will create the required NFT contracts for
 *   an approved drop using the approved confirmation.
 * - Platform Utilities. This contract holds core platform data accessed by other
 *   on-chain elements of the metadrop ecosystem. For example, VRF functionality.
 *
 */

pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "../NFT/INFTByMetadrop.sol";
import "../PrimaryVesting/IPrimaryVestingByMetadrop.sol";
import "../PrimarySaleModules/IPrimarySaleModule.sol";
import "../RoyaltyPaymentSplitter/IRoyaltyPaymentSplitterByMetadrop.sol";
import "./IDropFactory.sol";
import "../Global/AuthorityModel.sol";

/**
 *
 * @dev Inheritance details:
 *      IDropFactory            Interface definition for the metadrop drop factory
 *      Ownable                 OZ ownable implementation - provided for backwards compatibility
 *                              with any infra that assumes a project owner.
 *      AccessControl           OZ access control implementation - used for authority control
 *      VRFConsumerBaseV2       This contract will call chainlink VRF on behalf of deployed NFT
 *                              contracts, relaying the returned result to the NFT contract
 *
 */

contract DropFactory is
  IDropFactory,
  Ownable,
  AuthorityModel,
  VRFConsumerBaseV2
{
  using Address for address;
  using Clones for address payable;
  using SafeERC20 for IERC20;

  uint16 public constant MAX_REQUEST_CONFIRMATIONS = 200;
  uint32 public constant MAX_NUM_WORDS = 500;

  // The number of days that must have passed before the details for a drop held on chain can be deleted.
  uint32 public dropExpiryInDays;

  // Pause should not be allowed indefinitely
  uint8 public pauseCutOffInDays;

  // This is the address that will be set as the owner on all new contract clones. Note that on the constructor
  // of this contract this address is setup as the first address with the platform admin role.
  address public initialInstanceOwner;

  // Address for all platform fee payments
  address private platformTreasury;

  // Metadrop trusted oracle address
  address public metadropOracleAddress;

  // Primary sale metadrop basis Points
  uint256 private defaultMetadropPrimaryShareBasisPoints;

  // Royalty metadrop percentage
  uint256 private defaultMetadropRoyaltyBasisPoints;

  // Fee for drop submission (default is zero)
  uint256 public dropFeeETH;

  // The oracle signed message validity period:
  uint80 public messageValidityInSeconds = 600;

  // Chainlink config
  VRFCoordinatorV2Interface public immutable vrfCoordinatorInterface;
  uint64 public vrfSubscriptionId;
  bytes32 public vrfKeyHash;
  uint32 public vrfCallbackGasLimit;
  uint16 public vrfRequestConfirmations;
  uint32 public vrfNumWords;

  // Array of templates:
  // Note that this means that templates can be updated as the metadrop NFT evolves.
  // Using a new one will mean that all drops from that point forward will use the new contract template.
  // All deployed NFT contracts are NOT upgradeable and will continue to use the contract as deployed
  // At the time of drop.

  Template[] public contractTemplates;

  // Map the dropId to the Drop object
  //   struct DropApproval {
  //   DropStatus status;
  //   uint32 lastChangedDate;
  //   address dropOwnerAddress;
  //   bytes32 configHash;
  // }
  mapping(string => DropApproval) private dropDetailsByDropId;

  // Map to store any primary fee overrides on a drop by drop basis
  //   struct NumericOverride {
  //   bool isSet;
  //   uint248 overrideValue;
  // }
  mapping(string => NumericOverride) private primaryFeeOverrideByDrop;

  // Map to store any vesting period overrides on a drop by drop basis
  //   struct NumericOverride {
  //   bool isSet;
  //   uint248 overrideValue;
  // }

  mapping(string => NumericOverride) private metadropRoyaltyOverrideByDrop;

  // Map to store deployed NFT addresses:
  mapping(address => bool) public deployedNFTContracts;

  // Map to store VRF request IDs:
  mapping(uint256 => address) public addressForVRFRequestId;

  /** ====================================================================================================================
   *                                                    CONSTRUCTOR
   * =====================================================================================================================

  /** ____________________________________________________________________________________________________________________
   *                                                                                                        -->CONSTRUCTOR
   * @dev constructor           The constructor is not called when the contract is cloned. In this
   *                            constructor we just setup default values and set the template contract to initialised.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param initialInstanceOwnerAndPlatformAdmin_           The contract address of the VRF coordinator
   * ---------------------------------------------------------------------------------------------------------------------
   * @param reviewAdmin_                                    The address for the review admin. Review admins can approve 
   *                                                        drops.
   * ---------------------------------------------------------------------------------------------------------------------
   * @param platformTreasury_                               The address of the platform treasury. This will be used on 
   *                                                        primary vesting for the platform share of funds and on the 
   *                                                        royalty payment splitter for the platform share.
   * ---------------------------------------------------------------------------------------------------------------------
   * @param defaultMetadropPrimaryShareBasisPoints_         This is the default metadrop share of primary sales proceeds
   * ---------------------------------------------------------------------------------------------------------------------
   * @param defaultMetadropRoyaltyBasisPoints_              The default royalty share in basis points for the platform
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfCoordinator_                                 The address of the VRF coordinator
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfKeyHash_             The VRF key hash to determine the gas channel to use for VRF calls (i.e. the max gas 
   *                                you are willing to supply on the VRF call)
   *                                - Mainnet 200 gwei: 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef
   *                                - Goerli 150 gwei 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfSubscriptionId_      The subscription ID that chainlink tokens are consumed from for VRF calls
   * ---------------------------------------------------------------------------------------------------------------------
   * @param metadropOracleAddress_  The address of the metadrop oracle signer
   * ---------------------------------------------------------------------------------------------------------------------   
   * _____________________________________________________________________________________________________________________
   */
  constructor(
    address initialInstanceOwnerAndPlatformAdmin_,
    address reviewAdmin_,
    address platformTreasury_,
    uint256 defaultMetadropPrimaryShareBasisPoints_,
    uint256 defaultMetadropRoyaltyBasisPoints_,
    address vrfCoordinator_,
    bytes32 vrfKeyHash_,
    uint64 vrfSubscriptionId_,
    address metadropOracleAddress_
  ) VRFConsumerBaseV2(vrfCoordinator_) {
    // The initial instance owner is set as the Ownable owner on all cloned contracts:
    if (initialInstanceOwnerAndPlatformAdmin_ == address(0)) {
      revert InitialInstanceOwnerCannotBeAddressZero();
    }
    initialInstanceOwner = initialInstanceOwnerAndPlatformAdmin_;

    // DEFAULT_ADMIN_ROLE can grant and revoke all other roles. This address MUST be secured:
    _grantRole(DEFAULT_ADMIN_ROLE, initialInstanceOwnerAndPlatformAdmin_);

    // PLATFORM_ADMIN is used for elevated access functionality:
    _grantRole(PLATFORM_ADMIN, initialInstanceOwnerAndPlatformAdmin_);

    // PLATFORM_ADMIN can also review drops:
    _grantRole(REVIEW_ADMIN, initialInstanceOwnerAndPlatformAdmin_);

    // REVIEW_ADMIN can approve drops but nothing else:
    if (reviewAdmin_ == address(0)) {
      revert ReviewAdminCannotBeAddressZero();
    }
    _grantRole(REVIEW_ADMIN, reviewAdmin_);

    // Set platform treasury:
    if (platformTreasury_ == address(0)) {
      revert PlatformTreasuryCannotBeAddressZero();
    }
    platformTreasury = platformTreasury_;

    // Set the default platform primary fee percentage:
    defaultMetadropPrimaryShareBasisPoints = defaultMetadropPrimaryShareBasisPoints_;

    // Set the default platform royalty fee percentage:
    defaultMetadropRoyaltyBasisPoints = defaultMetadropRoyaltyBasisPoints_;

    // Set default VRF details
    if (vrfCoordinator_ == address(0)) {
      revert VRFCoordinatorCannotBeAddressZero();
    }
    vrfCoordinatorInterface = VRFCoordinatorV2Interface(vrfCoordinator_);
    vrfKeyHash = vrfKeyHash_;
    vrfSubscriptionId = vrfSubscriptionId_;
    vrfCallbackGasLimit = 150000;
    vrfRequestConfirmations = 3;
    vrfNumWords = 1;

    pauseCutOffInDays = 90;

    if (metadropOracleAddress_ == address(0)) {
      revert MetadropOracleCannotBeAddressZero();
    }
    metadropOracleAddress = metadropOracleAddress_;
  }

  /** ====================================================================================================================
   *                                                      GETTERS
   * =====================================================================================================================
   */

  /** ____________________________________________________________________________________________________________________
   *                                                                                                             -->GETTER
   * @dev (function) getPlatformTreasury  return the treasury address (provided as explicit method rather than public var)
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @return platformTreasury_  Treasury address
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getPlatformTreasury()
    external
    view
    returns (address platformTreasury_)
  {
    return (platformTreasury);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                             -->GETTER
   * @dev (function) getDropDetails   Getter for the drop details held on chain
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_  The drop ID being queries
   * ---------------------------------------------------------------------------------------------------------------------
   * @return dropDetails_  The drop details struct for the provided drop Id.
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getDropDetails(
    string memory dropId_
  ) external view returns (DropApproval memory dropDetails_) {
    return (dropDetailsByDropId[dropId_]);
  }

  /** ====================================================================================================================
   *                                                 PRIVILEGED ACCESS
   * =====================================================================================================================
   */

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) getDefaultMetadropPrimaryShareBasisPoints   Getter for the default platform primary fee basis points
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @return defaultMetadropPrimaryShareBasisPoints_   The metadrop primary share in basis points
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getDefaultMetadropPrimaryShareBasisPoints()
    external
    view
    onlyPlatformAdmin
    returns (uint256 defaultMetadropPrimaryShareBasisPoints_)
  {
    return (defaultMetadropPrimaryShareBasisPoints);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) getMetadropRoyaltyBasisPoints   Getter for the metadrop royalty share in basis points
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @return metadropRoyaltyBasisPoints_   The metadrop royalty share in basis points
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getMetadropRoyaltyBasisPoints()
    external
    view
    onlyPlatformAdmin
    returns (uint256 metadropRoyaltyBasisPoints_)
  {
    return (defaultMetadropRoyaltyBasisPoints);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) getPrimaryFeeOverrideByDrop    Getter for any drop specific primary fee override
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_                      The drop Id being queried
   * ---------------------------------------------------------------------------------------------------------------------
   * @return isSet_                      If this override is set
   * ---------------------------------------------------------------------------------------------------------------------
   * @return primaryFeeOverrideByDrop_   The primary fee override for the drop (if any)
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getPrimaryFeeOverrideByDrop(
    string memory dropId_
  )
    external
    view
    onlyPlatformAdmin
    returns (bool isSet_, uint256 primaryFeeOverrideByDrop_)
  {
    return (
      primaryFeeOverrideByDrop[dropId_].isSet,
      primaryFeeOverrideByDrop[dropId_].overrideValue
    );
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) getMetadropRoyaltyOverrideByDrop    Getter for any drop specific royalty basis points override
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_                               The drop Id being queried
   * ---------------------------------------------------------------------------------------------------------------------
   * @return isSet_                               If this override is set
   * ---------------------------------------------------------------------------------------------------------------------
   * @return metadropRoyaltyOverrideByDrop_       Royalty basis points override for the drop (if any)
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getMetadropRoyaltyOverrideByDrop(
    string memory dropId_
  )
    external
    view
    onlyPlatformAdmin
    returns (bool isSet_, uint256 metadropRoyaltyOverrideByDrop_)
  {
    return (
      metadropRoyaltyOverrideByDrop[dropId_].isSet,
      metadropRoyaltyOverrideByDrop[dropId_].overrideValue
    );
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                           -->PAUSABLE
   * @dev (function) getPauseCutOffInDays    Getter for the default pause cutoff period
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @return pauseCutOffInDays_    Default pause cutoff in days
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function getPauseCutOffInDays()
    external
    view
    onlyPlatformAdmin
    returns (uint8 pauseCutOffInDays_)
  {
    return (pauseCutOffInDays);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) setVRFSubscriptionId    Set the chainlink subscription id..
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfSubscriptionId_    The VRF subscription that this contract will consume chainlink from.

   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setVRFSubscriptionId(
    uint64 vrfSubscriptionId_
  ) public onlyPlatformAdmin {
    vrfSubscriptionId = vrfSubscriptionId_;
    emit vrfSubscriptionIdSet(vrfSubscriptionId_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) setVRFKeyHash   Set the chainlink keyhash (gas lane).
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfKeyHash_  The desired VRF keyhash
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setVRFKeyHash(bytes32 vrfKeyHash_) external onlyPlatformAdmin {
    vrfKeyHash = vrfKeyHash_;
    emit vrfKeyHashSet(vrfKeyHash_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) setVRFCallbackGasLimit  Set the chainlink callback gas limit
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfCallbackGasLimit_  Callback gas limit
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setVRFCallbackGasLimit(
    uint32 vrfCallbackGasLimit_
  ) external onlyPlatformAdmin {
    vrfCallbackGasLimit = vrfCallbackGasLimit_;
    emit vrfCallbackGasLimitSet(vrfCallbackGasLimit_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) setVRFRequestConfirmations  Set the chainlink number of confirmations required
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfRequestConfirmations_  Required number of confirmations
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setVRFRequestConfirmations(
    uint16 vrfRequestConfirmations_
  ) external onlyPlatformAdmin {
    if (vrfRequestConfirmations_ > MAX_REQUEST_CONFIRMATIONS) {
      revert ValueExceedsMaximum();
    }
    vrfRequestConfirmations = vrfRequestConfirmations_;
    emit vrfRequestConfirmationsSet(vrfRequestConfirmations_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) setVRFNumWords  Set the chainlink number of words required
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vrfNumWords_  Required number of confirmations
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setVRFNumWords(uint32 vrfNumWords_) external onlyPlatformAdmin {
    if (vrfNumWords_ > MAX_NUM_WORDS) {
      revert ValueExceedsMaximum();
    }
    vrfNumWords = vrfNumWords_;
    emit vrfNumWordsSet(vrfNumWords_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                             -->ORACLE
   * @dev (function) setMetadropOracleAddress  Set the metadrop trusted oracle address
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param metadropOracleAddress_   Trusted metadrop oracle address
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setMetadropOracleAddress(
    address metadropOracleAddress_
  ) external onlyPlatformAdmin {
    if (metadropOracleAddress_ == address(0)) {
      revert MetadropOracleCannotBeAddressZero();
    }
    metadropOracleAddress = metadropOracleAddress_;
    emit metadropOracleAddressSet(metadropOracleAddress_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                             -->ORACLE
   * @dev (function) setMessageValidityInSeconds  Set the validity period of signed messages
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param messageValidityInSeconds_   Validity period in seconds for messages signed by the trusted oracle
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setMessageValidityInSeconds(
    uint80 messageValidityInSeconds_
  ) external onlyPlatformAdmin {
    messageValidityInSeconds = messageValidityInSeconds_;
    emit messageValidityInSecondsSet(messageValidityInSeconds_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                           -->PAUSABLE
   * @dev (function) setpauseCutOffInDays    Set the number of days from the start date that a contract can be paused for
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param pauseCutOffInDays_    Default pause cutoff in days
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setpauseCutOffInDays(
    uint8 pauseCutOffInDays_
  ) external onlyPlatformAdmin {
    pauseCutOffInDays = pauseCutOffInDays_;

    emit pauseCutOffInDaysSet(pauseCutOffInDays_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setDropFeeETH    Set drop fee (if any)
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param fee_    New drop fee
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setDropFeeETH(uint256 fee_) external onlyPlatformAdmin {
    uint256 oldDropFee = dropFeeETH;
    dropFeeETH = fee_;
    emit SubmissionFeeETHUpdated(oldDropFee, fee_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setPlatformTreasury    Set the platform treasury address
   *
   * Set the address that platform fees will be paid to / can be withdrawn to.
   * Note that this is restricted to the highest authority level, the default
   * admin. Platform admins can trigger a withdrawal to the treasury, but only
   * the default admin can set or alter the treasury address. It is recommended
   * that the default admin is highly secured and restrited e.g. a multi-sig.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param platformTreasury_    New treasury address
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setPlatformTreasury(
    address platformTreasury_
  ) external onlyPlatformAdmin {
    if (platformTreasury_ == address(0)) {
      revert PlatformTreasuryCannotBeAddressZero();
    }
    platformTreasury = platformTreasury_;

    emit PlatformTreasurySet(platformTreasury_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setinitialInstanceOwner    Set the owner on all created instances
   *
   * The 'initial instance owner' is the address that will be set as the Owner
   * on all cloned instances of contracts created in this factory. Note that we the
   * contract instances are clones we do not call a constructor when an instance
   * is created, rather we set the owner on the call to initialise.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param initialInstanceOwner_    New owner address
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setinitialInstanceOwner(
    address initialInstanceOwner_
  ) external onlyPlatformAdmin {
    if (initialInstanceOwner_ == address(0)) {
      revert InitialInstanceOwnerCannotBeAddressZero();
    }
    initialInstanceOwner = initialInstanceOwner_;

    emit InitialInstanceOwnerSet(initialInstanceOwner_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setDefaultMetadropPrimaryShareBasisPoints    Setter for the metadrop primary basis points fee
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param defaultMetadropPrimaryShareBasisPoints_    New default meradrop primary share
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setDefaultMetadropPrimaryShareBasisPoints(
    uint32 defaultMetadropPrimaryShareBasisPoints_
  ) external onlyPlatformAdmin {
    defaultMetadropPrimaryShareBasisPoints = defaultMetadropPrimaryShareBasisPoints_;

    emit DefaultMetadropPrimaryShareBasisPointsSet(
      defaultMetadropPrimaryShareBasisPoints_
    );
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setMetadropRoyaltyBasisPoints   Setter for the metadrop royalty percentate in
   *                                                basis points i.e. 100 = 1%
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param defaultMetadropRoyaltyBasisPoints_      New default royalty basis points
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setMetadropRoyaltyBasisPoints(
    uint32 defaultMetadropRoyaltyBasisPoints_
  ) external onlyPlatformAdmin {
    defaultMetadropRoyaltyBasisPoints = defaultMetadropRoyaltyBasisPoints_;

    emit DefaultMetadropRoyaltyBasisPointsSet(
      defaultMetadropRoyaltyBasisPoints_
    );
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setMetadropRoyaltyOverrideByDrop   Setter to override royalty basis points
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_                  The drop for the override
   * ---------------------------------------------------------------------------------------------------------------------
   * @param royaltyBasisPoints_      Royalty basis points verride
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setMetadropRoyaltyOverrideByDrop(
    string memory dropId_,
    uint256 royaltyBasisPoints_
  ) external onlyPlatformAdmin {
    metadropRoyaltyOverrideByDrop[dropId_].isSet = true;
    metadropRoyaltyOverrideByDrop[dropId_].overrideValue = uint248(
      royaltyBasisPoints_
    );

    emit RoyaltyBasisPointsOverrideByDropSet(dropId_, royaltyBasisPoints_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) setPrimaryFeeOverrideByDrop   Setter for the metadrop primary percentage fee, in basis points
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_           The drop for the override
   * ---------------------------------------------------------------------------------------------------------------------
   * @param basisPoints_      The basis points override
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setPrimaryFeeOverrideByDrop(
    string memory dropId_,
    uint256 basisPoints_
  ) external onlyPlatformAdmin {
    primaryFeeOverrideByDrop[dropId_].isSet = true;
    primaryFeeOverrideByDrop[dropId_].overrideValue = uint248(basisPoints_);

    emit PrimaryFeeOverrideByDropSet(dropId_, basisPoints_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) setDropExpiryInDays   Setter for the number of days that must pass since a drop was last changed
   *                                       before it can be removed from storage
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropExpiryInDays_              The number of days that must pass for a submitted drop to be considered expired
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function setDropExpiryInDays(
    uint32 dropExpiryInDays_
  ) external onlyPlatformAdmin {
    dropExpiryInDays = dropExpiryInDays_;

    emit DropExpiryInDaysSet(dropExpiryInDays_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                     -->ACCESS CONTROL
   * @dev (function) grantPlatformAdmin  Allows the super user Default Admin to add an address to the platform admin group
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param newPlatformAdmin_              The address of the new platform admin
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function grantPlatformAdmin(
    address newPlatformAdmin_
  ) external onlyDefaultAdmin {
    if (newPlatformAdmin_ == address(0)) {
      revert PlatformAdminCannotBeAddressZero();
    }

    grantRole(PLATFORM_ADMIN, newPlatformAdmin_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                     -->ACCESS CONTROL
   * @dev (function) grantReviewAdmin  Allows the super user Default Admin to add an address to the review admin group.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param newReviewAdmin_              The address of the new review admin
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function grantReviewAdmin(address newReviewAdmin_) external onlyDefaultAdmin {
    if (newReviewAdmin_ == address(0)) {
      revert ReviewAdminCannotBeAddressZero();
    }
    grantRole(REVIEW_ADMIN, newReviewAdmin_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                     -->ACCESS CONTROL
   * @dev (function) revokePlatformAdmin  Allows the super user Default Admin to revoke from the platform admin group
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param oldPlatformAdmin_              The address of the old platform admin
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function revokePlatformAdmin(
    address oldPlatformAdmin_
  ) external onlyDefaultAdmin {
    revokeRole(PLATFORM_ADMIN, oldPlatformAdmin_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                     -->ACCESS CONTROL
   * @dev (function) revokeReviewAdmin  Allows the super user Default Admin to revoke an address to the review admin group
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param oldReviewAdmin_              The address of the old review admin
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function revokeReviewAdmin(
    address oldReviewAdmin_
  ) external onlyDefaultAdmin {
    revokeRole(REVIEW_ADMIN, oldReviewAdmin_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                     -->ACCESS CONTROL
   * @dev (function) transferDefaultAdmin  Allows the super user Default Admin to transfer this right to another address
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param newDefaultAdmin_              The address of the new default admin
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function transferDefaultAdmin(
    address newDefaultAdmin_
  ) external onlyDefaultAdmin {
    grantRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin_);
    revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) withdrawETH   A withdraw function to allow ETH to be withdrawn to the treasury
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param amount_  The amount to withdraw
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function withdrawETH(uint256 amount_) external onlyPlatformAdmin {
    (bool success, ) = platformTreasury.call{value: amount_}("");
    require(success, "Transfer failed");
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                            -->FINANCE
   * @dev (function) withdrawERC20   A withdraw function to allow ERC20s to be withdrawn to the treasury
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param token_   The contract address of the token being withdrawn
   * ---------------------------------------------------------------------------------------------------------------------
   * @param amount_  The amount to withdraw
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function withdrawERC20(
    IERC20 token_,
    uint256 amount_
  ) external onlyPlatformAdmin {
    token_.safeTransfer(platformTreasury, amount_);
  }

  /** ====================================================================================================================
   *                                                    VRF SERVER
   * =====================================================================================================================
   */

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) requestVRFRandomness  Get the metadata start position for use on reveal of the calling collection
   * _____________________________________________________________________________________________________________________
   */
  function requestVRFRandomness() external {
    // Can only be called by a deployed collection:
    if (deployedNFTContracts[msg.sender] = true) {
      addressForVRFRequestId[
        vrfCoordinatorInterface.requestRandomWords(
          vrfKeyHash,
          vrfSubscriptionId,
          vrfRequestConfirmations,
          vrfCallbackGasLimit,
          vrfNumWords
        )
      ] = msg.sender;
    } else {
      revert MetadropOnly();
    }
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                                -->VRF
   * @dev (function) fulfillRandomWords  Callback from the chainlinkv2 oracle with randomness. We then forward
   * this to the requesting NFT
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param requestId_      The Id of this request (this contract will submit a single request)
   * ---------------------------------------------------------------------------------------------------------------------
   * @param randomWords_   The random words returned from chainlink
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function fulfillRandomWords(
    uint256 requestId_,
    uint256[] memory randomWords_
  ) internal override {
    INFTByMetadrop(addressForVRFRequestId[requestId_]).fulfillRandomWords(
      requestId_,
      randomWords_
    );
  }

  /** ====================================================================================================================
   *                                                    TEMPLATES
   * =====================================================================================================================
   */

  /** ____________________________________________________________________________________________________________________
   *                                                                                                          -->TEMPLATES
   * @dev (function) addTemplate  Add a contract to the template library
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param contractAddress_              The address of the deployed contract that will be a template
   * ---------------------------------------------------------------------------------------------------------------------
   * @param templateDescription_          The description of the template
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function addTemplate(
    address payable contractAddress_,
    string memory templateDescription_
  ) public onlyPlatformAdmin {
    if (address(contractAddress_) == address(0)) {
      revert TemplateCannotBeAddressZero();
    }

    uint256 nextTemplateNumber = contractTemplates.length;
    contractTemplates.push(
      Template(
        TemplateStatus.live,
        uint16(nextTemplateNumber),
        uint32(block.timestamp),
        contractAddress_,
        templateDescription_
      )
    );

    emit TemplateAdded(
      TemplateStatus.live,
      nextTemplateNumber,
      block.timestamp,
      contractAddress_,
      templateDescription_
    );
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                          -->TEMPLATES
   * @dev (function) terminateTemplate  Mark a template as terminated
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param templateNumber_              The number of the template to be marked as terminated
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function terminateTemplate(
    uint16 templateNumber_
  ) external onlyPlatformAdmin {
    contractTemplates[templateNumber_].status = TemplateStatus.terminated;

    emit TemplateTerminated(templateNumber_);
  }

  /** ====================================================================================================================
   *                                                    DROP CREATION
   * =====================================================================================================================
   */

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) removeExpiredDropDetails  A review admin user can remove details for a drop that has expired.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_              The drop Id for which details are to be removed
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function removeExpiredDropDetails(
    string memory dropId_
  ) external onlyReviewAdmin {
    // Drop ID must exist:
    require(
      dropDetailsByDropId[dropId_].lastChangedDate != 0,
      "Drop Review: drop ID does not exist"
    );

    // Last changed date must be the expiry period in the past (or greater)
    require(
      dropDetailsByDropId[dropId_].lastChangedDate <
        (block.timestamp - (dropExpiryInDays * 1 days)),
      "Drop Review: drop ID does not exist"
    );

    delete dropDetailsByDropId[dropId_];

    emit DropDetailsDeleted(dropId_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) approveDrop  A review admin user can approve the drop.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_              The drop Id being approved
   * ---------------------------------------------------------------------------------------------------------------------
   * @param projectOwner_        Address of the project owner
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropConfigHash_      The config hash for this drop
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function approveDrop(
    string memory dropId_,
    address projectOwner_,
    bytes32 dropConfigHash_
  ) external onlyReviewAdmin {
    if (projectOwner_ == address(0)) {
      revert ProjectOwnerCannotBeAddressZero();
    }
    dropDetailsByDropId[dropId_] = DropApproval(
      DropStatus.approved,
      uint32(block.timestamp),
      projectOwner_,
      dropConfigHash_
    );

    emit DropApproved(dropId_, projectOwner_, dropConfigHash_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) createDrop     Create a drop using the stored and approved configuration if called by the address
   *                                that the user has designated as project admin
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_                        The drop Id being approved
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vestingModule_                 Struct containing the relevant config for the vesting module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param nftModule_                     Struct containing the relevant config for the NFT module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param primarySaleModulesConfig_      Array of structs containing the config details for all primary sale modules
   *                                       associated with this drop (can be 1 to n)
   * ---------------------------------------------------------------------------------------------------------------------
   * @param royaltyPaymentSplitterModule_  Struct containing the relevant config for the royalty splitter module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param salesPageHash_                 A hash of sale page data
   * ---------------------------------------------------------------------------------------------------------------------
   * @param customNftAddress_              If this drop uses a custom NFT this will hold that contract's address
   * ---------------------------------------------------------------------------------------------------------------------
   * @param collectionURIs_                An array of collection URIs (pre-reveal, ipfs and arweave)
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function createDrop(
    string memory dropId_,
    VestingModuleConfig memory vestingModule_,
    NFTModuleConfig memory nftModule_,
    PrimarySaleModuleConfig[] memory primarySaleModulesConfig_,
    RoyaltySplitterModuleConfig memory royaltyPaymentSplitterModule_,
    bytes32 salesPageHash_,
    address customNftAddress_,
    string[3] memory collectionURIs_
  ) external payable {
    // Check the fee:
    require(msg.value == dropFeeETH, "Incorrect ETH payment");

    // Get the details from storage:
    DropApproval memory currentDrop = dropDetailsByDropId[dropId_];

    // We can only proceed if this drop is set to 'approved'
    require(
      currentDrop.status == DropStatus.approved,
      "Drop creation: must be approved"
    );

    // We can only proceed if this is being called by the project owner:
    require(
      currentDrop.dropOwnerAddress == msg.sender,
      "Drop creation: must be submitted by project owner"
    );

    dropDetailsByDropId[dropId_].status = DropStatus.deployed;

    // We can only proceed if the hash of the passed configuration matches that stored
    // on chain from the project approval
    require(
      configHashMatches(
        dropId_,
        vestingModule_,
        nftModule_,
        primarySaleModulesConfig_,
        royaltyPaymentSplitterModule_,
        salesPageHash_,
        customNftAddress_
      ),
      "Drop creation: passed config does not match approved"
    );

    // ---------------------------------------------
    //
    // VESTING
    //
    // ---------------------------------------------

    // Create the vesting contract clone instance:
    address newVestingInstance = _createVestingContract(
      vestingModule_,
      dropId_
    );

    // ---------------------------------------------
    //
    // ROYALTY
    //
    // ---------------------------------------------

    // Create the royalty payment splitter contract clone instance:
    (
      address newRoyaltyPaymentSplitterInstance,
      uint96 royaltyFromSalesInBasisPoints
    ) = _createRoyaltyPaymentSplitterContract(
        royaltyPaymentSplitterModule_,
        dropId_
      );

    // ---------------------------------------------
    //
    // PRIMARY SALE MODULES
    //
    // ---------------------------------------------
    //

    // Array to hold addresses of created primary sale modules:
    PrimarySaleModuleInstance[]
      memory primarySaleModuleInstances = new PrimarySaleModuleInstance[](
        primarySaleModulesConfig_.length
      );

    // Iterate over the received primary sale modules, instansiate and initialise:
    for (uint256 i = 0; i < primarySaleModulesConfig_.length; i++) {
      primarySaleModuleInstances[i].instanceAddress = payable(
        contractTemplates[primarySaleModulesConfig_[i].templateId]
          .templateAddress
      ).clone();

      primarySaleModuleInstances[i].instanceDescription = contractTemplates[
        primarySaleModulesConfig_[i].templateId
      ].templateDescription;

      // Initialise storage data:
      IPrimarySaleModule(primarySaleModuleInstances[i].instanceAddress)
        .initialisePrimarySaleModule(
          initialInstanceOwner,
          msg.sender, // project owner
          newVestingInstance,
          primarySaleModulesConfig_[i].configData,
          pauseCutOffInDays,
          metadropOracleAddress,
          messageValidityInSeconds
        );
    }

    // ---------------------------------------------
    //
    // NFT
    //
    // ---------------------------------------------
    //

    // Create the NFT clone instance:
    address newNFTInstance = _createNFTContract(
      msg.sender,
      primarySaleModuleInstances,
      nftModule_,
      newRoyaltyPaymentSplitterInstance,
      royaltyFromSalesInBasisPoints,
      customNftAddress_,
      collectionURIs_
    );

    // Iterate over the primary sale modules, and add the NFT address
    for (uint256 i = 0; i < primarySaleModuleInstances.length; i++) {
      IPrimarySaleModule(primarySaleModuleInstances[i].instanceAddress)
        .setNFTAddress(newNFTInstance);
    }

    emit DropDeployed(
      dropId_,
      newNFTInstance,
      newVestingInstance,
      primarySaleModuleInstances,
      newRoyaltyPaymentSplitterInstance
    );
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) _platformPrimaryShare  Return the platform primary share for this drop.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_              The drop Id being queried
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function _platformPrimaryShare(
    string memory dropId_
  ) internal view returns (uint256 platformPrimaryShare_) {
    // See if there is any primary share override for this drop:
    if (primaryFeeOverrideByDrop[dropId_].isSet) {
      platformPrimaryShare_ = primaryFeeOverrideByDrop[dropId_].overrideValue;
    } else {
      // No override, set to default:
      platformPrimaryShare_ = defaultMetadropPrimaryShareBasisPoints;
    }
    return (platformPrimaryShare_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) _projectRoyaltyBasisPoints  Return the metadrop royalty basis points for this drop.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_              The drop Id being queried
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function _projectRoyaltyBasisPoints(
    string memory dropId_
  ) internal view returns (uint256 projectRoyaltyBasisPoints_) {
    // See if there is any project royalty basis points override for this drop:
    if (metadropRoyaltyOverrideByDrop[dropId_].isSet) {
      projectRoyaltyBasisPoints_ = metadropRoyaltyOverrideByDrop[dropId_]
        .overrideValue;
    } else {
      // No override, set to default:
      projectRoyaltyBasisPoints_ = defaultMetadropRoyaltyBasisPoints;
    }
    return (projectRoyaltyBasisPoints_);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) _createVestingContract  Create the vesting contract for primary funds.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vestingModule_           The configuration data for the vesting module
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function _createVestingContract(
    VestingModuleConfig memory vestingModule_,
    string memory dropId_
  ) internal returns (address) {
    // Template type(uint16).max indicates this module is not required
    if (vestingModule_.templateId == type(uint16).max) {
      return (address(0));
    }

    address payable targetVestingTemplate = contractTemplates[
      vestingModule_.templateId
    ].templateAddress;

    // Create the clone vesting contract:
    address newVestingInstance = targetVestingTemplate.clone();

    IPrimaryVestingByMetadrop(payable(newVestingInstance))
      .initialisePrimaryVesting(
        vestingModule_,
        platformTreasury,
        _platformPrimaryShare(dropId_)
      );

    return newVestingInstance;
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) _createRoyaltyPaymentSplitterContract  Create the royalty payment splitter.
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param royaltyModule_           The configuration data for the royalty module
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function _createRoyaltyPaymentSplitterContract(
    RoyaltySplitterModuleConfig memory royaltyModule_,
    string memory dropId_
  )
    internal
    returns (
      address newRoyaltySplitterInstance_,
      uint96 totalRoyaltyPercentage_
    )
  {
    // Template type(uint16).max indicates this module is not required
    if (royaltyModule_.templateId == type(uint16).max) {
      return (address(0), 0);
    }

    address payable targetRoyaltySplitterTemplate = contractTemplates[
      royaltyModule_.templateId
    ].templateAddress;

    // Create the clone vesting contract:
    address newRoyaltySplitterInstance = targetRoyaltySplitterTemplate.clone();

    uint96 royaltyFromSalesInBasisPoints = IRoyaltyPaymentSplitterByMetadrop(
      payable(newRoyaltySplitterInstance)
    ).initialiseRoyaltyPaymentSplitter(
        royaltyModule_,
        platformTreasury,
        _projectRoyaltyBasisPoints(dropId_)
      );

    return (newRoyaltySplitterInstance, royaltyFromSalesInBasisPoints);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) _createNFTContract  Create the NFT contract
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param primarySaleModules_          An array of primary sale module addresses for this NFT
   * ---------------------------------------------------------------------------------------------------------------------
   * @param nftModule_                   A struct containing configuration information for this NFT
   * ---------------------------------------------------------------------------------------------------------------------
   * @param royaltyPaymentSplitter_      Address of the royalty payment splitted for this drop
   * ---------------------------------------------------------------------------------------------------------------------
   * @param totalRoyaltyPercentage_      Total royalty percentage for this drop
   * ---------------------------------------------------------------------------------------------------------------------
   * @param collectionURIs_              An array of collection URIs (pre-reveal, ipfs and arweave)
   * ---------------------------------------------------------------------------------------------------------------------
   * @return nftContract_                The address of the deployed NFT contract clone
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function _createNFTContract(
    address caller_,
    PrimarySaleModuleInstance[] memory primarySaleModules_,
    NFTModuleConfig memory nftModule_,
    address royaltyPaymentSplitter_,
    uint96 totalRoyaltyPercentage_,
    address customNftAddress_,
    string[3] memory collectionURIs_
  ) internal returns (address nftContract_) {
    // Template type(uint16).max indicates this module is not required
    if (nftModule_.templateId == type(uint16).max) {
      return (customNftAddress_);
    }

    address payable targetTemplate = contractTemplates[nftModule_.templateId]
      .templateAddress;
    address newNFTInstance = targetTemplate.clone();

    // Initialise storage data:
    INFTByMetadrop(newNFTInstance).initialiseNFT(
      initialInstanceOwner,
      caller_,
      primarySaleModules_,
      nftModule_,
      royaltyPaymentSplitter_,
      totalRoyaltyPercentage_,
      collectionURIs_,
      pauseCutOffInDays
    );

    return newNFTInstance;
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) configHashMatches  Check the passed config against the stored config hash
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_                        The drop Id being approved
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vestingModule_                 Struct containing the relevant config for the vesting module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param nftModule_                     Struct containing the relevant config for the NFT module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param primarySaleModulesConfig_      Array of structs containing the config details for all primary sale modules
   *                                       associated with this drop (can be 1 to n)
   * ---------------------------------------------------------------------------------------------------------------------
   * @param royaltyPaymentSplitterModule_  Struct containing the relevant config for the royalty splitter module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param salesPageHash_                 A hash of sale page data
   * ---------------------------------------------------------------------------------------------------------------------
   * @param customNftAddress_              If this drop uses a custom NFT this will hold that contract's address
   * ---------------------------------------------------------------------------------------------------------------------
   * @return matches_                      Whether the hash matches (true) or not (false)
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function configHashMatches(
    string memory dropId_,
    VestingModuleConfig memory vestingModule_,
    NFTModuleConfig memory nftModule_,
    PrimarySaleModuleConfig[] memory primarySaleModulesConfig_,
    RoyaltySplitterModuleConfig memory royaltyPaymentSplitterModule_,
    bytes32 salesPageHash_,
    address customNftAddress_
  ) public view returns (bool matches_) {
    // Create the hash of the passed data for comparison:
    bytes32 passedConfigHash = createConfigHash(
      dropId_,
      vestingModule_,
      nftModule_,
      primarySaleModulesConfig_,
      royaltyPaymentSplitterModule_,
      salesPageHash_,
      customNftAddress_
    );
    // Must equal the stored hash:
    return (passedConfigHash == dropDetailsByDropId[dropId_].configHash);
  }

  /** ____________________________________________________________________________________________________________________
   *                                                                                                              -->DROPS
   * @dev (function) createConfigHash  Create the config hash
   *
   * ---------------------------------------------------------------------------------------------------------------------
   * @param dropId_                        The drop Id being approved
   * ---------------------------------------------------------------------------------------------------------------------
   * @param vestingModule_                 Struct containing the relevant config for the vesting module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param nftModule_                     Struct containing the relevant config for the NFT module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param primarySaleModulesConfig_      Array of structs containing the config details for all primary sale modules
   *                                       associated with this drop (can be 1 to n)
   * ---------------------------------------------------------------------------------------------------------------------
   * @param royaltyPaymentSplitterModule_  Struct containing the relevant config for the royalty splitter module
   * ---------------------------------------------------------------------------------------------------------------------
   * @param salesPageHash_                 A hash of sale page data
   * ---------------------------------------------------------------------------------------------------------------------
   * @param customNftAddress_              If this drop uses a custom NFT this will hold that contract's address
   * ---------------------------------------------------------------------------------------------------------------------
   * @return configHash_                   The bytes32 config hash
   * ---------------------------------------------------------------------------------------------------------------------
   * _____________________________________________________________________________________________________________________
   */
  function createConfigHash(
    string memory dropId_,
    VestingModuleConfig memory vestingModule_,
    NFTModuleConfig memory nftModule_,
    PrimarySaleModuleConfig[] memory primarySaleModulesConfig_,
    RoyaltySplitterModuleConfig memory royaltyPaymentSplitterModule_,
    bytes32 salesPageHash_,
    address customNftAddress_
  ) public pure returns (bytes32 configHash_) {
    // Hash the primary sales module data
    for (uint256 i = 0; i < primarySaleModulesConfig_.length; i++) {
      configHash_ = keccak256(
        abi.encodePacked(
          configHash_,
          primarySaleModulesConfig_[i].templateId,
          primarySaleModulesConfig_[i].configData
        )
      );
    }

    configHash_ = keccak256(
      // Hash remaining items:
      abi.encodePacked(
        configHash_,
        dropId_,
        vestingModule_.templateId,
        vestingModule_.configData,
        nftModule_.templateId,
        nftModule_.configData,
        royaltyPaymentSplitterModule_.templateId,
        royaltyPaymentSplitterModule_.configData,
        salesPageHash_,
        customNftAddress_
      )
    );

    return (configHash_);
  }
}