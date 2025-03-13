// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/solmate/src/tokens/ERC20.sol";

interface IJPEGZ {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract MyBags is ERC20("Buy My Bags", "MyBags", 18) {
    address public constant GHOULZ = 0xeF1a89cbfAbE59397FfdA11Fc5DF293E9bC5Db90;
    address public constant LOBZ = 0x026224A2940bFE258D0dbE947919B62fE321F042;

    uint public constant CLAIM_AMOUNT = 69_420_420_420 ether;

    enum jpegz {
        GHOULZ,
        LOBZ
    }

    mapping(jpegz => mapping(uint256 => bool)) public hazBagz;

    error NotYourBagz();
    error AlreadyHazBagz();

    constructor() {
        _mint(msg.sender, CLAIM_AMOUNT * 100); // take 100 to add single sized lp
    }

    function getMyBags(jpegz _jpegz, uint256 _id) public {
        if (hazBagz[_jpegz][_id]) revert AlreadyHazBagz();
        if (IJPEGZ(_jpegz == jpegz.GHOULZ ? GHOULZ : LOBZ).ownerOf(_id) != msg.sender) revert NotYourBagz();
        hazBagz[_jpegz][_id] = true;

        _mint(msg.sender, CLAIM_AMOUNT);
    }
}