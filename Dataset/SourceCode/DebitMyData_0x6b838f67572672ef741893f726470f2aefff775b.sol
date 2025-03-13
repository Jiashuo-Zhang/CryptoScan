/**

 *Submitted for verification at Etherscan.io on 2023-04-26

*/



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**

@title Debit My Data Contract

@dev This contract defines a basic ERC20 token with the addition of mining rewards.

*/

contract DebitMyData {

// Token information

string public name;

string public symbol;

uint8 public decimals;

uint256 public totalSupply;

// Mining information

uint256 public difficulty;

uint256 public miningReward;

uint256 public nonce;

// Contract owner

address public owner;

// Token balances

mapping(address => uint256) public balanceOf;

// Events

event Transfer(address indexed from, address indexed to, uint256 value);

event Mine(address indexed miner, uint256 reward);

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

/**

@dev Contract constructor

@param _name Token name

@param _symbol Token symbol

@param _decimals Token decimals

@param _totalSupply Total token supply

@param _difficulty Mining difficulty

@param _miningReward Mining reward

*/

constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, uint256 _difficulty, uint256 _miningReward) {

name = _name;

symbol = _symbol;

decimals = _decimals;

totalSupply = _totalSupply;

difficulty = _difficulty;

miningReward = _miningReward;

balanceOf[msg.sender] = _totalSupply;

owner = msg.sender;

emit Transfer(address(0), msg.sender, _totalSupply);

}

/**

@dev Transfer tokens to another address

@param _to Recipient address

@param _value Amount of tokens to transfer

@return Returns true if transfer is successful

*/

function transfer(address _to, uint256 _value) public returns (bool) {

require(_to != address(0), "Invalid transfer recipient");

require(balanceOf[msg.sender] >= _value, "Insufficient balance");

balanceOf[msg.sender] -= _value;

balanceOf[_to] += _value;

emit Transfer(msg.sender, _to, _value);

return true;

}

/**

@dev Mine tokens by providing nonce value

@param _nonce Nonce value

@return Returns true if mining is successful

*/

function mine(uint256 _nonce) public returns (bool) {

bytes32 target = bytes32(uint256(2) ** (256 - difficulty));

bytes32 hash = sha256(abi.encodePacked(nonce, _nonce));

if (hash < target) {

require(balanceOf[msg.sender] + miningReward >= balanceOf[msg.sender], "Integer overflow detected");

balanceOf[msg.sender] += miningReward;

totalSupply += miningReward;

nonce += 1;

emit Mine(msg.sender, miningReward);

return true;

} else {

return false;

}

}

/**

@dev Transfer ownership of contract to another address

@param newOwner New owner address

*/

function transferOwnership(address newOwner) public {

require(msg.sender == owner, "Only the contract owner can transfer ownership");

require(newOwner != address(0), "Invalid new owner");

emit OwnershipTransferred(owner, newOwner);

owner = newOwner;

}

}