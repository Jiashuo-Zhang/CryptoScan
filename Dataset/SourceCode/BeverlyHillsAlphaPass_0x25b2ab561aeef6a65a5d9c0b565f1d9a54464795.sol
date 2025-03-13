// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import "./ERC721A.sol";



error NotMeetWhiteListMint();

error InvalidSignature();



contract BeverlyHillsAlphaPass is Ownable, ERC721A {

    struct WhiteItem {

        uint64 whiteFutures;

        uint64 whitePriceWei;

        uint64 whiteStartTime;

        uint64 whiteEndTime;

        uint256 total;

        address checkAddress;

    }

    string _baseTokenURI;

    WhiteItem public WConfig;

    mapping(address => uint64) whiteListAddress;



    uint256 public constant MAX_SUPPLY = 500;

    uint256 public constant AIRDROP_LOCK = 30 days;    



    constructor() ERC721A("Beverly Hills Alpha Pass", "BHAC", 50) {}



    modifier callerIsUser() {

        require(tx.origin == msg.sender, "The caller is another contract");

        _;

    }



    function setWConfig(WhiteItem calldata cData) external onlyOwner {

        WConfig = cData;

    }



    function endWhiteList() external onlyOwner {

        WConfig = WhiteItem(

            WConfig.whiteFutures,

            0,

            WConfig.whiteStartTime,

            uint64(block.timestamp),

            0,

            WConfig.checkAddress

        );

    }



    function airdropMint(address[] calldata to, uint256[] calldata nums, bool isLock) external onlyOwner {

        uint256 length = to.length;

        require(length == nums.length,"Parameter length error");        

        uint256 total = totalSupply();

        for(uint256 t=0; t<length; t++){

            total += nums[t];

        }

        require(total <= AIRDROP_LOCK,"Not enough for mint");



        uint64 lockTime = isLock ? uint64(block.timestamp + AIRDROP_LOCK) : 0;

        for (uint256 i = 0; i < length; i++) {

            _safeMint(to[i], nums[i], lockTime);

        }

    }



    function isWhiteSaleOn() public view returns (bool) {

        return

            WConfig.total > 0 &&

            WConfig.whitePriceWei > 0 &&

            WConfig.whiteStartTime <= uint64(block.timestamp) &&

            WConfig.whiteEndTime > uint64(block.timestamp);

    }



    function whitelistMint(uint256 salt, bytes calldata signature) public payable callerIsUser {

        if (!isWhiteSaleOn()) {

            revert NotMeetWhiteListMint();

        }



        WhiteItem memory config = WConfig;

        require(config.total >= 1, "Not enough for mint");

        require(msg.value >= uint256(config.whitePriceWei), "Need to send more ETH.");

        require(whiteListAddress[msg.sender] != config.whiteFutures, "Whitelist Restriction");



        checkSigna(salt,signature,config.checkAddress);

        _safeMint(msg.sender, 1 , 0);

        config.total -= 1;



        WConfig.total = config.total;

        whiteListAddress[msg.sender] = config.whiteFutures;

    }





    function _baseURI() internal view virtual override returns (string memory) {

        return _baseTokenURI;

    }



    function setBaseURI(string calldata baseURI) external onlyOwner {

        _baseTokenURI = baseURI;

    }



    function checkSigna(uint256 salt, bytes calldata signature,address checkAddr) private view{

        bytes32 HashData = keccak256(abi.encodePacked(msg.sender, salt));

        if (

            !SignatureChecker.isValidSignatureNow(

                checkAddr,

                HashData,

                signature

            )

        ) {

            revert InvalidSignature();

        }

    }

}