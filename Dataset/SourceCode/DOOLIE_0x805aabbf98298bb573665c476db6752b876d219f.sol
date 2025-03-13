// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Doolieverse
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////
//                   //
//                   //
//    Doolieverse    //
//                   //
//                   //
///////////////////////


contract DOOLIE is ERC721Creator {
    constructor() ERC721Creator("Doolieverse", "DOOLIE") {}
}