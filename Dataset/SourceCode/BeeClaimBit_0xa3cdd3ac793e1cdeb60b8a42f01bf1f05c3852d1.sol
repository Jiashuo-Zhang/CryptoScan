// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;



import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";



interface ITheGardens {

    function hiveMint(address _to, uint256 _amount) external;



    function ownerOf(uint256 tokenId) external view returns (address);

}



contract BeeClaimBit is Ownable {

    ITheGardens public theGardens;

    address public beekeeper;

    bool claimFinished = false;



    uint256 private constant CHUNK_SIZE = 256;

    uint256 private constant OFFSET = 0;

    uint256[10] public claimedBitmap;



    event Claimed(address indexed _to, uint16 indexed _count);



    error AccessError();

    error AlreadyClaimed();

    error MinterIsContract();

    error NotOwnerOfToken();

    error OutOfRange();

    error ClaimIsDone();



    constructor(address _mintBees, address _beekeeper) {

        theGardens = ITheGardens(_mintBees);

        beekeeper = _beekeeper;

    }



    modifier onlyBeekeeper() {

        if (!(msg.sender == beekeeper || msg.sender == owner())) {

            revert AccessError();

        }

        _;

    }



    /**

     * @dev Modifier to ensure that the caller is not a contract. This is useful for

     *      preventing potential exploits or automated actions from contracts.

     *      Reverts the transaction with a `MinterNotContract` error if the caller is a contract.

     */

    modifier beeCallerOnly() {

        // Revert the transaction if the caller is a contract

        if (msg.sender != tx.origin) {

            revert MinterIsContract();

        }



        _;

    }



    modifier claimStatus() {

        if (claimFinished == true) {

            revert ClaimIsDone();

        }

        _;

    }



    function setBeekeeper(address _beekeeper) public onlyOwner {

        beekeeper = _beekeeper;

    }



    function setStatus(bool _status) public onlyBeekeeper {

        claimFinished = _status;

    }



    function checkOwner(uint256 _tokenId) internal view returns (bool) {

        return theGardens.ownerOf(_tokenId) == msg.sender;

    }



    function isClaimedLoop(

        uint256[] memory _tokenIds

    ) public view returns (bool[] memory) {

        bool[] memory _isClaimed = new bool[](_tokenIds.length);

        for (uint256 i = 0; i < _tokenIds.length; i++) {

            _isClaimed[i] = isClaimed(_tokenIds[i]);

        }

        return _isClaimed;

    }



    function isClaimed(uint256 tokenId) public view returns (bool) {

        if (tokenId > 2499) {

            revert OutOfRange();

        }



        unchecked {

            uint256 index = tokenId / CHUNK_SIZE;

            uint256 position = tokenId % CHUNK_SIZE;

            // Bitwise AND operation to get the bit at the position.

            // If it's 1, the function will return true; if it's 0, it will return false.

            return claimedBitmap[index] & (1 << position) != 0;

        }

    }



    function claim(

        uint256[] memory _tokenIds

    ) public claimStatus beeCallerOnly {

        for (uint256 i = 0; i < _tokenIds.length; i++) {

            uint256 _tokenId = _tokenIds[i];



            if (!checkOwner(_tokenId)) {

                revert NotOwnerOfToken();

            }



            if (isClaimed(_tokenId)) {

                revert AlreadyClaimed();

            }



            unchecked {

                uint256 adjustedTokenId = _tokenId - OFFSET;

                uint256 index = adjustedTokenId / CHUNK_SIZE;

                uint256 position = adjustedTokenId % CHUNK_SIZE;



                // Bitwise OR operation to set the bit at the position to 1.

                claimedBitmap[index] = claimedBitmap[index] | (1 << position);

            }

        }

        theGardens.hiveMint(msg.sender, _tokenIds.length);

        emit Claimed(msg.sender, uint16(_tokenIds.length));

    }

}