// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: CloneGirlsJBW2023tour
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////
//                         //
//                         //
//    CloneGirlsJBW2023    //
//                         //
//                         //
/////////////////////////////


contract CGJBW2023 is ERC721Creator {
    constructor() ERC721Creator("CloneGirlsJBW2023tour", "CGJBW2023") {}
}