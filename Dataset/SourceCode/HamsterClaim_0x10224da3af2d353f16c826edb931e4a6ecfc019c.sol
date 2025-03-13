// SPDX-License-Identifier: None
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interface/IDelegationRegistry.sol";

contract HamsterClaim is Ownable {
  using ECDSA for bytes32;

  // ERRORS *****************************************************

  error NoAuthSigner();
  error InvalidSignature();
  error AlreadyClaimedSnapshot();
  error AlreadyClaimedMong(uint256 tokenId);
  error NotOwnerOfMong(uint256 mongId);

  // Storage *****************************************************

  // Public ****************************

  /// @dev The $HAM contract
  IERC20 public immutable Hamster;
  IERC721 public immutable mongsNFT;
  IDelegationRegistry public immutable delegationRegistry;
  address public immutable hamsterStorageWallet;

  /// @dev Keeps track of whether a wallet has claimed its allocation from the snapshot
  mapping(address => bool) public snapshotClaimed;

  /// @dev Keeps track of whether each Mong NFT has claimed
  mapping(uint256 => bool) public mongClaimed;

  /// @dev The public address of the authorized signer used to validate the claim
  address public authSigner;

  // Private ****************************

  /// @dev used for decoding the claim signature
  bytes32 private DOMAIN_SEPARATOR;
  bytes32 private SNAPSHOT_TYPEHASH = keccak256("claim(address account,uint256 amount)");
  bytes32 private MONG_TYPEHASH = keccak256("claim(address account,uint256 amount,bytes32 monghash)");

  // Constructor *****************************************************

  constructor(address hamsterContractAddress_, address hamsterStorageWallet_, address mongsNftContractAddress_) {
    Hamster = IERC20(hamsterContractAddress_);
    mongsNFT = IERC721(mongsNftContractAddress_);
    hamsterStorageWallet = hamsterStorageWallet_;
    delegationRegistry = IDelegationRegistry(0x00000000000076A84feF008CDAbe6409d2FE638B);

    uint256 chainId;
    assembly {
      chainId := chainid()
    }

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes("HamsterClaim")),
        keccak256(bytes("1")),
        chainId,
        address(this)
      )
    );
  }

  // Public Methods *****************************************************

  /// @notice Function for eligible users to claim $HAMSTR
  /// @dev eligible claimants verified through offchain process via authSigner, claims for wallet snapshot and mong nft are processed separately
  /// @param snapshotSignature The signature produced by the authSigner to validate that the recipient is eligible for the snapshot claim
  /// @param snapshotAmount The number of tokens allocated from snapshot
  /// @param mongSignature The signature produced by the authSigner to validate the claim for mong nfts
  /// @param mongAmount The number of tokens eligible based on supplied mongTokenIds
  /// @param mongTokenIds The mong nft tokenIds to claim
  function claim(
    bytes calldata snapshotSignature,
    uint256 snapshotAmount,
    bytes calldata mongSignature,
    uint256 mongAmount,
    uint256[] calldata mongTokenIds
  ) external {
    if (authSigner == address(0)) revert NoAuthSigner();

    if (mongAmount > 0) validateMongClaim(mongSignature, mongAmount, mongTokenIds);
    if (snapshotAmount > 0) validateSnapshotClaim(snapshotSignature, snapshotAmount);

    Hamster.transferFrom(hamsterStorageWallet, msg.sender, mongAmount + snapshotAmount);
  }

  function mongHasClaimed(uint256[] calldata tokenIds) external view returns (bool[] memory claimed) {
    claimed = new bool[](tokenIds.length);

    for (uint i = 0; i < tokenIds.length; ) {
      claimed[i] = mongClaimed[tokenIds[i]];

      unchecked {
        ++i;
      }
    }
  }

  // Owner Methods *****************************************************

  /// @notice Allows the contract owner to set the address of the authSigner
  /// @param signer address of the new signer
  function setAuthSigner(address signer) external onlyOwner {
    authSigner = signer;
  }

  // Private Methods *****************************************************

  function validateMongClaim(bytes memory signature, uint256 amount, uint256[] calldata tokenIds) private {
    bytes32 mongHash = keccak256(abi.encodePacked(tokenIds));

    bytes32 digest = keccak256(
      abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(MONG_TYPEHASH, msg.sender, amount, mongHash)))
    );

    address signer = digest.recover(signature);

    if (signer != authSigner) revert InvalidSignature();

    for (uint i = 0; i < tokenIds.length; ) {
      uint256 mongId = tokenIds[i];

      if (mongClaimed[mongId]) revert AlreadyClaimedMong(mongId);

      //check NFT owner
      address nftOwner = mongsNFT.ownerOf(mongId);
      if (nftOwner != msg.sender) {
        if (!delegationRegistry.checkDelegateForToken(msg.sender, nftOwner, address(mongsNFT), mongId)) {
          revert NotOwnerOfMong(mongId);
        }
      }

      mongClaimed[tokenIds[i]] = true;

      unchecked {
        ++i;
      }
    }
  }

  function validateSnapshotClaim(bytes memory signature, uint256 amount) private {
    bytes32 digest = keccak256(
      abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(SNAPSHOT_TYPEHASH, msg.sender, amount)))
    );

    address signer = digest.recover(signature);

    if (signer != authSigner) revert InvalidSignature();

    if (snapshotClaimed[msg.sender]) revert AlreadyClaimedSnapshot();

    snapshotClaimed[msg.sender] = true;
  }
}