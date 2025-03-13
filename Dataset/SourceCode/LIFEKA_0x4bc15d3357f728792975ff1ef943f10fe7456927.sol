// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: LIFE
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////
//                                 //
//                                 //
//    LIFE BY KEVIN ABOSCH 2023    //
//                                 //
//                                 //
/////////////////////////////////////


contract LIFEKA is ERC721Creator {
    constructor() ERC721Creator("LIFE", "LIFEKA") {}
}