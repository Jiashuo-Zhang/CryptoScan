// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//                        888
//                        888
//                        888
// 88888b.d88b.   .d88b.  888888 888d888 .d88b.
// 888 "888 "88b d8P  Y8b 888    888P"  d88""88b
// 888  888  888 88888888 888    888    888  888
// 888  888  888 Y8b.     Y88b.  888    Y88..88P
// 888  888  888  "Y8888   "Y888 888     "Y88P"

// 888                    d8b          888                          888
// 888                    Y8P          888                          888
// 888                                 888                          888
// 88888b.  888  888      888 88888b.  888888       8888b.  888d888 888888
// 888 "88b 888  888      888 888 "88b 888             "88b 888P"   888
// 888  888 888  888      888 888  888 888         .d888888 888     888
// 888 d88P Y88b 888      888 888  888 Y88b.       888  888 888     Y88b.
// 88888P"   "Y88888      888 888  888  "Y888      "Y888888 888      "Y888
//               888
//          Y8b d88P
//           "Y88P"

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProofLib} from "solmate/src/utils/MerkleProofLib.sol";

import {IMetro} from "./interfaces/IMetro.sol";
import {ITheDudes} from "./interfaces/ITheDudes.sol";
import {IDelegationRegistry} from "./interfaces/IDelegationRegistry.sol";

contract MetroMinter is Ownable {
    IMetro public immutable metro;
    ITheDudes public immutable theDudes;
    IDelegationRegistry public immutable delegationRegistry;

    bool isTheDudesMintOpen;
    bool isThePixelsMintOpen;
    bool isCollabMintOpen;
    bool isPublicMintOpen;
    address publicMintSigner = 0x305e0A36c6A43fbA881AF6dcD1e0703579a18033;

    mapping(uint256 => bool) public usedTheDudesTokenIds;
    mapping(address => uint256) public mintCountForPixelsIncAddresses;
    mapping(address => uint256) public mintCountForCollabAddresses;
    mapping(address => bool) public addressesForPublicMint;

    bytes32 public pixelsIncMerkleProof;
    bytes32 public communityMerkleProof;

    error MintNotOpen();
    error InvalidTheDudeOwner();
    error AlreadyMinted();
    error InvalidProof();
    error NotEligibleForMint();
    error InvalidAmount();
    error InvalidSignature();

    constructor(
        address metroAddress,
        address theDudesAddress,
        address delegateRegistry
    ) {
        metro = IMetro(metroAddress);
        theDudes = ITheDudes(theDudesAddress);
        delegationRegistry = IDelegationRegistry(delegateRegistry);
    }

    // - owner operations

    function setisMintEnabled(
        bool _isTheDudesMintOpen,
        bool _isThePixelsMintOpen,
        bool _isCollabMintOpen,
        bool _isPublicMintOpen
    ) public onlyOwner {
        isTheDudesMintOpen = _isTheDudesMintOpen;
        isThePixelsMintOpen = _isThePixelsMintOpen;
        isCollabMintOpen = _isCollabMintOpen;
        isPublicMintOpen = _isPublicMintOpen;
    }

    function updatePixelsIncMerkleProof(
        bytes32 _pixelsIncMerkleProof
    ) public onlyOwner {
        pixelsIncMerkleProof = _pixelsIncMerkleProof;
    }

    function updateCollabMerkleProof(
        bytes32 _communityMerkleProof
    ) public onlyOwner {
        communityMerkleProof = _communityMerkleProof;
    }

    function updatePublicMintSigner(
        address _publicMintSigner
    ) public onlyOwner {
        publicMintSigner = _publicMintSigner;
    }

    // - utils

    function getMintAvailibility()
        public
        view
        returns (bool, bool, bool, bool)
    {
        return (
            isTheDudesMintOpen,
            isThePixelsMintOpen,
            isCollabMintOpen,
            isPublicMintOpen
        );
    }

    // - delegate.cash requester

    function getRequester(address vault) public view returns (address) {
        if (vault != address(0)) {
            bool isDelegateValid = delegationRegistry.checkDelegateForContract(
                msg.sender,
                vault,
                address(this)
            );
            if (isDelegateValid) {
                return vault;
            }
        }
        return msg.sender;
    }

    // - 'the dudes' mint

    function availableTheDudesForMint(
        address vault
    ) public view returns (uint256[] memory, bool[] memory) {
        address requester = getRequester(vault);
        uint256[] memory theDudesTokens = theDudes.tokensOfOwner(requester);
        bool[] memory tokenStatus = new bool[](theDudesTokens.length);

        for (uint256 i; i < theDudesTokens.length; i++) {
            tokenStatus[i] = usedTheDudesTokenIds[theDudesTokens[i]];
        }
        return (theDudesTokens, tokenStatus);
    }

    function mintWithTheDudes(
        address vault,
        uint256[] calldata tokenIds
    ) public {
        if (!isTheDudesMintOpen) {
            revert MintNotOpen();
        }
        address requester = getRequester(vault);
        uint256 i;
        uint256 length = tokenIds.length;
        do {
            uint256 tokenId = tokenIds[i];
            if (theDudes.ownerOf(tokenId) != requester) {
                revert InvalidTheDudeOwner();
            }
            if (usedTheDudesTokenIds[tokenId]) {
                revert AlreadyMinted();
            }
            usedTheDudesTokenIds[tokenId] = true;
        } while (++i < length);

        metro.mint(requester, length);
    }

    // - 'the pixels inc' mint

    function mintAmountForPixelInc(
        address vault,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public view returns (uint256) {
        address requester = getRequester(vault);
        return
            mintAmountForPixelIncWithRequester(
                requester,
                quantity,
                merkleProof
            );
    }

    function mintAmountForPixelIncWithRequester(
        address requester,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public view returns (uint256) {
        bytes32 node = keccak256(abi.encodePacked(requester, quantity));
        if (!MerkleProofLib.verify(merkleProof, pixelsIncMerkleProof, node)) {
            revert InvalidProof();
        }
        return quantity - mintCountForPixelsIncAddresses[requester];
    }

    function mintWithPixelIncAddress(
        address vault,
        uint256 selectedQuantity,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public {
        address requester = getRequester(vault);
        if (!isThePixelsMintOpen) {
            revert MintNotOpen();
        }
        uint256 availableAmount = mintAmountForPixelIncWithRequester(
            requester,
            quantity,
            merkleProof
        );
        if (availableAmount == 0) {
            revert InvalidAmount();
        }
        if (selectedQuantity > quantity) {
            revert InvalidAmount();
        }
        mintCountForPixelsIncAddresses[requester] += selectedQuantity;
        metro.mint(requester, selectedQuantity);
    }

    // - community collab mint

    function mintAmountForCollab(
        address vault,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public view returns (uint256) {
        address requester = getRequester(vault);
        return
            mintAmountForCollabWithRequester(requester, quantity, merkleProof);
    }

    function mintAmountForCollabWithRequester(
        address requester,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public view returns (uint256) {
        bytes32 node = keccak256(abi.encodePacked(requester, quantity));
        if (!MerkleProofLib.verify(merkleProof, communityMerkleProof, node)) {
            revert InvalidProof();
        }
        return quantity - mintCountForCollabAddresses[requester];
    }

    function mintWithCollabAddress(
        address vault,
        uint256 selectedQuantity,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public {
        address requester = getRequester(vault);
        if (!isCollabMintOpen) {
            revert MintNotOpen();
        }
        uint256 availableAmount = mintAmountForCollabWithRequester(
            requester,
            quantity,
            merkleProof
        );
        if (availableAmount == 0) {
            revert InvalidAmount();
        }
        if (selectedQuantity > quantity) {
            revert InvalidAmount();
        }
        mintCountForCollabAddresses[requester] += selectedQuantity;
        metro.mint(requester, selectedQuantity);
    }

    // - public mint

    function mint(bytes memory signature) public {
        if (!isPublicMintOpen) {
            revert MintNotOpen();
        }
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(
            abi.encode(msg.sender)
        );
        (address signer, ) = ECDSA.tryRecover(messageHash, signature);
        if (signer != publicMintSigner) {
            revert InvalidSignature();
        }
        if (addressesForPublicMint[msg.sender]) {
            revert AlreadyMinted();
        }
        addressesForPublicMint[msg.sender] = true;
        metro.mint(msg.sender, 1);
    }
}