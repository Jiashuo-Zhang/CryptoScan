// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * BlockOneOptOut NFT
 *
 * NFT intended to contact holders of EOS ERC-20 token who are automatically a participant in the ongoing lawsuit Williams, et al. v. Block.one, et al. Case No. 1:20-cv-2809-LAK.
 *
 * Contact details:
 * W: cryptogroupactions.com
 */

abstract contract MerkelTree {
    /**
     * @dev a function to verify that an address is part of the merket root
     * @param proof supplied by the ownwer
     * @param root supplied by the owner
     * @param data address that forms part of the merket root.
     */
    function _verify(
        bytes32[] memory proof,
        bytes32 root,
        address data
    ) internal pure returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(data))));
        return MerkleProof.verify(proof, root, leaf);
    }
}

contract BlockOneOptOut is ERC721URIStorage, Ownable, MerkelTree {
    /**
     * @dev Storage
     */
    uint16 public _ids;

    bytes32 private _merketRoot;

    address private _admin;

    mapping(uint16 => address) idToOwner;

    mapping(address => uint16) ownerToId;

    /**
     * @dev events
     */

    event BlockOneOptOutMint(string message, address owner, uint256 id);

    event MerketRootUpdate(address owner); // Review whether to add timestamp

    /**
     * Modifier
     */

    modifier onlyAdmin() {
        require(
            msg.sender == owner() || msg.sender == _admin,
            "Caller is not the owner or admin"
        );
        _;
    }

    constructor(
        bytes32 _root,
        address _adminAccount
    ) ERC721("BlockOneOptOut", "BlockOneOptOut") {
        _merketRoot = _root;
        _admin = _adminAccount;
    }

    function updateMerketRoot(bytes32 _root) external onlyOwner {
        _merketRoot = _root;
    }

    function createNft(
        string memory _uri,
        address _user,
        bytes32[] memory _proof
    ) external onlyAdmin {
        require(_verify(_proof, _merketRoot, _user), "Proof not valid");
        require(ownerToId[_user] == 0, "NFT already minted");
        incrementIds();

        _safeMint(_user, _ids);
        _setTokenURI(_ids, _uri);

        idToOwner[_ids] = _user;
        ownerToId[_user] = _ids;

        emit BlockOneOptOutMint("BlockOneOptOutMint", _user, _ids);
    }

    function incrementIds() internal {
        unchecked {
            _ids++;
        }
    }

    function getLatestId() external view returns (uint16) {
        return _ids;
    }

    function getNftOwner(uint16 id) public view returns (address) {
        require(idToOwner[id] != address(0), "id of nft not recognised");
        return idToOwner[id];
    }

    function ownerToNft(address _owner) public view returns (uint256) {
        require(_owner != address(0), "invalid address");
        return ownerToId[_owner];
    }
}