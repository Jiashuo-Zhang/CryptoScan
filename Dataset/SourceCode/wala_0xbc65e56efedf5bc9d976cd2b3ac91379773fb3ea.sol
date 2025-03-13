// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Wala
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////
//                //
//                //
//    walaatbp    //
//                //
//                //
////////////////////


contract wala is ERC721Creator {
    constructor() ERC721Creator("Wala", "wala") {}
}