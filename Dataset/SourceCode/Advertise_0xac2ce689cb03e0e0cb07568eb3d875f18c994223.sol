// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Base64.sol";

import "./solidity-datetime/DateTime.sol";

import "./DecimalStrings.sol";

import "./SVGRenderer.sol";



contract Advertise is ERC721, Ownable {

	event update(address indexed from, uint256 timestamp, uint256 tokenId);



	SVGRenderer private renderer;

	uint256 private id = 0;

	uint256 private constant INIT_PRICE = 0.00001 ether;

	bool public isActive = true;



	mapping(uint256 => string) txtByTokenId;

	mapping(uint256 => uint256) payerByTokenId;

	mapping(uint256 => uint256) priceByTokenId;

	mapping(uint256 => uint256) timeByTokenId;



	constructor() ERC721("Advertise", "ADV") {

		renderer = new SVGRenderer();

	}



	function getPrice() public view returns (uint256) {

		uint256 today = getDays(block.timestamp);

		uint256 lastDay = getDays(timeByTokenId[id]);

		if (today != lastDay || id == 0) {

			return INIT_PRICE;

		} else {

			return priceByTokenId[id];

		}

	}



	function getDays(uint256 timestamp) private pure returns (uint256) {

		(uint256 year, uint256 month, uint256 day, , , ) = DateTime.timestampToDateTime(timestamp + 9 * 3600);

		return year * 365 + month * 30 + day;

	}



	function mint(string memory txt) public payable {

		require(isActive, "mint is inactive");

		require(msg.value >= getPrice(), "Incorrect payable amount");

		uint256 len = bytes(txt).length;

		require(len > 0 && len <= 10000, "Invalid text");



		uint256 tokenId = ++id;

		txtByTokenId[tokenId] = txt;

		payerByTokenId[tokenId] = uint256(uint160(msg.sender));

		timeByTokenId[tokenId] = block.timestamp;

		priceByTokenId[tokenId] = msg.value;

		_safeMint(_msgSender(), tokenId);



		emit update(msg.sender, block.timestamp, tokenId);

	}



	function tokenURI(uint256 tokenId) public view override returns (string memory) {

		require(_exists(tokenId), "nonexistent token");



		uint256 time = timeByTokenId[tokenId];

		string memory txt = txtByTokenId[tokenId];

		string memory payerAddress = Strings.toHexString(payerByTokenId[tokenId], 20);

		string memory priceStr = DecimalStrings.decimalString(

			(priceByTokenId[tokenId] / 10000000000000) * 10000000000000,

			18,

			false

		);

		(string memory svg, string memory mainColor, string memory subColor) = renderer.render(

			tokenId,

			payerAddress,

			address(this),

			time,

			priceStr

		);



		bytes memory json = abi.encodePacked(

			'{"name": "',

			string(abi.encodePacked("Certificate #", Strings.toString(tokenId))),

			'", "description": "',

			txt,

			'", "image": "data:image/svg+xml;base64,',

			Base64.encode(abi.encodePacked(svg)),

			'","metadata": {"payer":"',

			payerAddress,

			'","timestamp":"',

			Strings.toString(time),

			'","mainColor":"',

			mainColor,

			'","subColor":"',

			subColor,

			'","price":',

			priceStr,

			"}}"

		);



		return string(abi.encodePacked("data:application/json;base64,", Base64.encode(json)));

	}



	function updateActiveFlag(bool flag) public onlyOwner {

		isActive = flag;

	}



	function totalSupply() public view returns (uint256) {

		return id;

	}



	function withdraw() public onlyOwner {

		payable(owner()).transfer(address(this).balance);

	}

}