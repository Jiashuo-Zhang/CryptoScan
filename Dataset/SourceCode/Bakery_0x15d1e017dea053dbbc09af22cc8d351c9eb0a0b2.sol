// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Token.sol";

contract Bakery {

	struct Info {
		Token[] tokens;
		mapping(address => uint256) nonce;
		address template;
		address team;
	}
	Info private info;


	event NewToken(address indexed creator, address indexed token, bool proxy, string name, string symbol, uint256 totalSupply, uint256 initialMarketCap, uint256 upperMarketCap, uint256 creatorFee, uint256 transferLimit, uint256 transferLimitTime, uint256 value, uint256 launchTime);


	constructor() {
		Token _template = new Token();
		_template.lock();
		info.template = address(_template);
		Team _team = new Team();
		_team.initialize(msg.sender);
		info.team = address(_team);
	}
	
	function salt() public returns (bytes32) {
		return keccak256(abi.encodePacked(msg.sender, info.nonce[msg.sender]++));
	}

	function launch(bool _deployProxy, string memory _name, string memory _symbol, uint256 _totalSupply, uint256 _initialMarketCap, uint256 _upperMarketCap, uint256 _creatorFee, uint256 _transferLimit, uint256 _transferLimitTime) external payable returns (address) {
		Token _token;
		{
			bytes32 _salt = salt();
			if (_deployProxy) {
				address _proxy;
				bytes20 _template = bytes20(info.template);
				assembly {
					let _clone := mload(0x40)
					mstore(_clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
					mstore(add(_clone, 0x14), _template)
					mstore(add(_clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
					_proxy := create2(0, _clone, 0x37, _salt)
				}
				_token = Token(_proxy);
			} else {
				_token = new Token{salt:_salt}();
			}
		}
		_token.initialize{value:msg.value}(msg.sender, _name, _symbol, _totalSupply, _initialMarketCap, _upperMarketCap, _creatorFee, _transferLimit, _transferLimitTime);
		info.tokens.push(_token);
		emit NewToken(msg.sender, address(_token), _deployProxy, _name, _symbol, _totalSupply, _initialMarketCap, _upperMarketCap, _creatorFee, _transferLimit, _transferLimitTime, msg.value, block.timestamp);
		return address(_token);
	}


	function template() public view returns (address) {
		return info.template;
	}

	function teamTemplate() public view returns (address) {
		return info.team;
	}
	
	function totalTokens() public view returns (uint256) {
		return info.tokens.length;
	}

	function tokenAtIndex(uint256 _index) public view returns (Token) {
		return info.tokens[_index];
	}

	function allTokens() public view returns (Token[] memory) {
		return info.tokens;
	}
}