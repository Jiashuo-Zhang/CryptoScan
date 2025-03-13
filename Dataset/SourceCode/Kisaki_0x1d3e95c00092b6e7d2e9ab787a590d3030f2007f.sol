// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;



import "@thirdweb-dev/contracts/base/ERC721Drop.sol";



contract Kisaki is ERC721Drop {

    /* Script to transform hash to picture */

    string public script;



    function setScript(string calldata _script) public onlyOwner {

        script = _script;

    }



    /* Mappings to associate tokens and hashes */

    mapping(uint256 => bytes32) public tokenToHash;

    mapping(bytes32 => uint256) public hashToToken;



    constructor(

        address _royaltyRecipient,

        uint128 _royaltyBps,

        address _primarySaleRecipient,

        string memory _script

    )

        ERC721Drop(

            "Kisaki",

            "KST",

            _royaltyRecipient,

            _royaltyBps,

            _primarySaleRecipient

        )

    {

        script = _script;

    }



    function _mintGenerative(

        address _to,

        uint256 _startTokenId,

        uint256 _quantity

    ) internal virtual {

        for (uint256 i = 0; i < _quantity; i += 1) {

            uint256 _id = _startTokenId + i;



            bytes32 mintHash = keccak256(

                abi.encodePacked(_id, blockhash(block.number - 1), _to)

            );



            tokenToHash[_id] = mintHash;

            hashToToken[mintHash] = _id;

        }

    }



    function _transferTokensOnClaim(address _to, uint256 _quantityBeingClaimed)

        internal

        virtual

        override

        returns (uint256 startTokenId)

    {

        startTokenId = _currentIndex;



        _mintGenerative(_to, startTokenId, _quantityBeingClaimed);

        _safeMint(_to, _quantityBeingClaimed);

    }

}