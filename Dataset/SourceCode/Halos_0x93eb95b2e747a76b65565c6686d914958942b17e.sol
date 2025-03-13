// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;



import "erc721a/contracts/IERC721A.sol";

import "erc721a/contracts/extensions/ERC721AQueryable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";



contract Halos is ERC721AQueryable, Ownable {

    mapping(address => bool) public whitelistedAddresses;

    mapping(address => uint256) private __mintCounts;

    mapping(address => uint256) private __mintLimits;



    bool private __isPublicMint = false;

    uint256 public constant MAX_SUPPLY = 1111;



    constructor() ERC721A("Halos", "HALOS") Ownable(msg.sender) {}



    function mint(uint256 quantity) external payable onlyWhitelisted {

        require(totalSupply() + quantity <= MAX_SUPPLY, "Exceeds maximum supply");

        if (!__isPublicMint) {

            require(__mintCounts[msg.sender] + quantity <= __mintLimits[msg.sender], "Mint limit exceeded");

        } else {

            require(__mintCounts[msg.sender] + quantity <= 3, "Mint limit exceeded");

        }

        __mintCounts[msg.sender] += quantity;

        _mint(msg.sender, quantity);

    }



    modifier onlyWhitelisted() {

        if (!__isPublicMint) {

            require(whitelistedAddresses[msg.sender], "Address not whitelisted");

        }

        _;

    }



    function setPublicMint(bool publicMint) external onlyOwner {

        __isPublicMint = publicMint;

    }



    function addToWhitelist(address[] calldata _addresses, uint256[] calldata _mintLimits) external onlyOwner {

        require(_addresses.length == _mintLimits.length, "Arrays must be of equal length");



        for (uint256 i = 0; i < _addresses.length; i++) {

            whitelistedAddresses[_addresses[i]] = true;

            __mintLimits[_addresses[i]] = _mintLimits[i];

        }

    }





    function removeFromWhitelist(address[] calldata _addresses) external onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            whitelistedAddresses[_addresses[i]] = false;

            __mintLimits[_addresses[i]] = 0;

        }

    }



    function _startTokenId() internal view virtual override returns (uint256) {

        return 1;

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return "https://assets.n3onhalos.xyz/";

    }

}