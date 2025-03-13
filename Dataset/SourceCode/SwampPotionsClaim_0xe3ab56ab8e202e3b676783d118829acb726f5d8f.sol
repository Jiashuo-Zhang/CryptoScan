// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SwampPotionsClaim is Ownable {

    bytes32 public merkleRoot;
    uint256 public idsCount;
    uint256 public currentId;

    function setIds(uint256 _current, uint256 _count) public onlyOwner {
	currentId = _current;
	idsCount = _count;
    }

    function popId() internal returns (uint256) {
	uint256 id;
	if( idsCount > 0 )
	    id = currentId;
	    currentId++;
	    idsCount--;
	return id;
    }

    function claim(address _tokenAddress, address _recipient, uint256 _count, bytes32[] memory _proof) public {
	require(_count > 0, "Zero tokens to claim");
	require(_count <= idsCount, "Not enought tokens to claim");

	bytes32 leaf = keccak256(abi.encodePacked(msg.sender,_count));
	require(MerkleProof.verify(_proof, merkleRoot, leaf), "Invalid proof!");

        IERC721 token = IERC721(_tokenAddress);
        for (uint256 i = 0; i < _count; i++) {
            token.safeTransferFrom(address(this), _recipient, popId());
        }
    }

    function claimDrop(address _tokenAddress, address _recipient, uint256 _count) public onlyOwner {
	require(_count > 0, "Zero tokens to claim");
	require(_count <= idsCount, "Not enought tokens to claim");

        IERC721 token = IERC721(_tokenAddress);
        for (uint256 i = 0; i < _count; i++) {
            token.safeTransferFrom(address(this), _recipient, popId());
        }
    }

    function setRoot(bytes32 _root) external onlyOwner {
	merkleRoot = _root;
    }

}