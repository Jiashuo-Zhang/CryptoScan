// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;



import "solmate/tokens/ERC721.sol";

import "solmate/utils/LibString.sol";

import "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";

import "openzeppelin-contracts/access/Ownable.sol";

import "./AnonymiceLibrary.sol";

import "./HexAnonsGenerator.sol";

import "./HexAnonsErrors.sol";



contract HexAnons is HexAnonsErrors, ERC721, Ownable {

    using LibString for uint256;



    uint256 public constant MAX_SUPPLY = 256;

    uint256 public constant PRIORITY_MINT_START = 1679779800;

    uint256 public constant HOLDERS_MINT_START = PRIORITY_MINT_START + 24 hours;

    bytes32 constant PRIORITY_MINT_ROOT =

        0xef0d1359754f96f615b555cc0dc1c50ada628537f90689db0afa9a5276c04ebe;



    bytes32 constant HOLDERS_MINT_ROOT =

        0x7e0744664f3126f12a8a1888ab265ddd02d7ccc68d315e54b6df080a44067ed9;



    address constant toadAddress = 0xE4260Df86f5261A41D19c2066f1Eb2Eb4F009e84;

    address constant irrevAddress = 0x4533d1F65906368ebfd61259dAee561DF3f3559D;

    address constant circolorsAddress = 0x888f8AA938dbb18b28bdD111fa4A0D3B8e10C871;



    uint256 public totalSupply;



    string[] ogCols;



    mapping(address => bool) addressMinted;

    mapping(uint256 => TokenInfo) tokenIdToTokenInfo;

    bool teamMinted;



    HexAnonsGenerator hexAnonsGenerator;





    modifier paintYourOwn(uint256 _tokenId) {

        if (msg.sender != ownerOf(_tokenId)) revert PaintYourOwn();

        _;

    }



    constructor() ERC721("HexAnons", "HEXA") {

        hexAnonsGenerator = new HexAnonsGenerator();

        ogCols = ["FFFFFF"];

    }



    /**

     * @param _a The address to be used within the hash.

     * @param _tokenId, the tokenId the hash is for

     */

    function hashPattern(

        address _a,

        uint256 _tokenId

    ) internal view returns (TokenInfo memory) {

        uint32 _hash = uint32(

            uint256(

                keccak256(

                    abi.encodePacked(

                        block.timestamp,

                        block.difficulty,

                        _a,

                        _tokenId

                    )

                )

            )

        );



        uint8 _pattern = uint8(

            uint256(keccak256(abi.encodePacked(_a, _tokenId))) % 20 + 1

        );



        string[] memory cols;



        return TokenInfo(_pattern, _hash, cols);

    }



    function priorityMint(

        bytes32[] calldata merkleProof

    ) external payable {

        if (addressMinted[msg.sender]) revert AddressMinted();

        if (block.timestamp < PRIORITY_MINT_START) revert NotOpen();



        bytes32 node = keccak256(abi.encodePacked(msg.sender));



        if (!MerkleProof.verify(merkleProof, PRIORITY_MINT_ROOT, node))

            revert NotAllowlisted();



        addressMinted[msg.sender] = true;



        mintInternal(msg.sender);

    }



        function holdersMint(

        bytes32[] calldata merkleProof

    ) external payable {

        if (addressMinted[msg.sender]) revert AddressMinted();

        if (block.timestamp < HOLDERS_MINT_START) revert NotOpen();



        bytes32 node = keccak256(abi.encodePacked(msg.sender));



        if (!MerkleProof.verify(merkleProof, HOLDERS_MINT_ROOT, node))

            revert NotAllowlisted();



        addressMinted[msg.sender] = true;



        mintInternal(msg.sender);

    }



    function teamMint() external onlyOwner {

        if (teamMinted) revert TeamMinted();



        for (uint256 i; i < 5; ++i) {

            mintInternal(toadAddress);

        }

        for (uint256 i; i < 3; ++i) {

            mintInternal(irrevAddress);

        }

                for (uint256 i; i < 2; ++i) {

            mintInternal(circolorsAddress);

        }

    }



    function mintInternal(address _to) internal {

        if (totalSupply >= MAX_SUPPLY) revert SoldOut();

        uint256 nextTokenId = totalSupply;



        tokenIdToTokenInfo[nextTokenId] = hashPattern(_to, nextTokenId);

        ++totalSupply;



        _mint(_to, nextTokenId);

    }



    // Views



    function getTokenInfo(

        uint256 _tokenId

    ) external view returns (TokenInfo memory) {

        TokenInfo memory _info = tokenIdToTokenInfo[_tokenId];

        if (_info.cols.length == 0) {

            _info.cols = ogCols;

        }

        return _info;

    }



    function lickOfPaint(

        uint256 _tokenId,

        string[] memory _cols

    ) external paintYourOwn(_tokenId) {

        tokenIdToTokenInfo[_tokenId].cols = _cols;

    }



    function scrubPaint(uint256 _tokenId) external paintYourOwn(_tokenId) {

        string[] memory wipeCols;

        tokenIdToTokenInfo[_tokenId].cols = wipeCols;

    }



    function trialPaintJob(

        uint256 _tokenId,

        string[] memory _cols

    ) external view returns (string memory) {

        // FIXME: there are no tests for this

        if (_tokenId >= totalSupply) revert NonExistantId();

        TokenInfo memory _info = tokenIdToTokenInfo[_tokenId];

        _info.cols = _cols;

        return hexAnonsGenerator.buildSVG(_info);

    }



    function tokenURI(

        uint256 _tokenId

    ) public view override returns (string memory _URI) {

        if (_tokenId >= totalSupply) revert NonExistantId();

        TokenInfo memory _info = tokenIdToTokenInfo[_tokenId];

        if (_info.cols.length == 0) {

            _info.cols = ogCols;

        }

        return hexAnonsGenerator.buildToken(_tokenId, _info);

    }

}