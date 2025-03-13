// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Colombo Splinters
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////
//                 //
//                 //
//    Splinters    //
//                 //
//                 //
/////////////////////


contract CS is ERC721Creator {
    constructor() ERC721Creator("Colombo Splinters", "CS") {}
}