// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;



import "./IKey.sol";



contract Key is IKey {

    address _owner;

    bytes32 immutable _hash;

    event OnOwner(address owner);



    constructor(bytes32 keyHash_) {

        _hash = keyHash_;

    }



    function owner() external view returns (address) {

        return _owner;

    }



    function claim(string calldata key) external {

        require(isKeyValid(key), "The key is wrong or in the wrong order.");

        require(_owner == address(0), "owner already exists");

        _owner = msg.sender;

        emit OnOwner(_owner);

    }



    function isKeyValid(string calldata key) public view returns (bool) {

        return sha256(bytes(key)) == _hash;

    }

}