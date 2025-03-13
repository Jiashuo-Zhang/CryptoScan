// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Editions by Rossi
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////
//          //
//          //
//    RR    //
//          //
//          //
//////////////


contract RR is ERC721Creator {
    constructor() ERC721Creator("Editions by Rossi", "RR") {}
}