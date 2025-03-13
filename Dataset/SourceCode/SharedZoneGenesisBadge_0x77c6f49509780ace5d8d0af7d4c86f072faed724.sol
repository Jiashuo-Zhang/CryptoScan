/**

 * SharedZone: Protocol (On-chain SocialFi)

 * Twitter: https://twitter.com/SharedZoneProto

 * Website: https://shared.zone

 */



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;



import "erc721a/contracts/ERC721A.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/Strings.sol";



contract SharedZoneGenesisBadge is ERC721A, Ownable {

    constructor() ERC721A("SharedZone: Protocol (Genesis Badge)", "BADGE") {

        config = Config(3000, 1, 0, 0);

    }



    Config public config;



    struct Config {

        uint256 maxSupply;

        uint256 maxMint;

        uint256 price;

        uint256 phase;

    }



    function claim() external {

        require(config.phase == 1, "Invalid phase.");

        

        _mint(1);

    }



    function _mint(uint256 count) private {

        require(totalSupply() + count <= config.maxSupply, "Exceed maxmiumn.");

        require(

            _numberMinted(msg.sender) + count <= config.maxMint,

            "Cant mint more."

        );



        _safeMint(msg.sender, count);

    }



    function devMint(uint256 _quantity) external onlyOwner {

        require(totalSupply() + _quantity <= config.maxSupply, "");

        _safeMint(msg.sender, _quantity);

    }



    string private _baseTokenURI;



    function _baseURI() internal view virtual override returns (string memory) {

        return _baseTokenURI;

    }

    

    function setBaseURI(string calldata baseURI) external onlyOwner {

        _baseTokenURI = baseURI;

    }



    function numberMinted(address _addr) public view returns (uint256) {

        return _numberMinted(_addr);

    }



    function getHolders() public view returns (address[] memory){

        address[] memory holders = new address[](totalSupply());

        for(uint i=1; i <= totalSupply(); i++){

            holders[i -1] = ownerOf(i);

        }

        return holders;

    }



    function setMaxSupply(uint256 max) external onlyOwner {

        require(max <= config.maxSupply, "invalid.");

        config.maxSupply = max;

    }



    function setMaxMint(uint256 max) external onlyOwner {

        config.maxMint = max;

    }



    function setPhase(uint256 phase) external onlyOwner {

        config.phase = phase;

    }



    function withdraw() external onlyOwner {

        (bool success, ) = msg.sender.call{value: address(this).balance}("");

        require(success, "");

    }



    function _startTokenId()

        internal

        view

        virtual

        override(ERC721A)

        returns (uint256)

    {

        return 1;

    }

}