/**

 *Submitted for verification at Etherscan.io on 2023-01-03

*/



// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0;



contract Ownable

{	

// Variable that maintains

// owner address

address private _owner;

//user address that can call notarization methods

address private _user;

// Sets the original owner of

// contract when it is deployed

constructor()

{

	_owner = msg.sender;

    _user = msg.sender;

}



// Publicly exposes who is the

// owner of this contract

function owner() public view returns(address)

{

	return _owner;

}



function user() public view returns(address)

{

	return _user;

}

// onlyOwner modifier that validates only

// if caller of function is contract owner,

// otherwise not

modifier onlyOwner()

{

	require(isOwner(),

	"Function accessible only by the owner !!");

	_;

}



modifier onlyUser()

{

	require(isUser(),

	"Function accessible only by the permissioned user !!");

	_;

}



// function for owners to verify their ownership.

// Returns true for owners otherwise false

function isOwner() public view returns(bool)

{

	return msg.sender == _owner;

}



// Returns true for user otherwise false

function isUser() public view returns(bool)

{

	return msg.sender == _user;

}

function transferOwnership(address newOwner) public  onlyOwner {

    require(newOwner != address(0), "Ownable: new owner is the zero address");

    _owner = newOwner;

    }



function setUser(address newUser) public  onlyOwner {

    require(newUser != address(0), "Ownable: new user is the zero address");

    _user = newUser;

    }

}





contract Notarizer is Ownable

{

    uint256 public prevBlock;

    event Hash(bytes32 hash, uint256 indexed prevBlock);

    event SignedHash(bytes32 hash, bytes32 signature, uint256 indexed prevBlock);    



    //Store proof and emit event  

    function storeHash(bytes32 _hash) onlyUser external {

        emit Hash(_hash, prevBlock);

        prevBlock = block.number;

    }



    //Store proof and corresponding signature and emit event  

    function storeSignedHash(bytes32 _hash, bytes32 _signature) onlyUser external {

        emit SignedHash(_hash, _signature, prevBlock);

        prevBlock = block.number;

    }



    function verify(bytes32 root, bytes32 leaf, bytes32[] memory proof) external pure returns (bool) {

    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {

        bytes32 proofElement = proof[i];

        if (computedHash < proofElement) {

            // Hash(current computed hash + current element of the proof)

            computedHash = keccak256(

                abi.encodePacked(computedHash, proofElement)

            );

        } else {

            // Hash(current element of the proof + current computed hash)

            computedHash = keccak256(

                abi.encodePacked(proofElement, computedHash)

            );

        }

    }

    // Check if the computed hash (root) is equal to the provided root

    return computedHash == root;

    }

}