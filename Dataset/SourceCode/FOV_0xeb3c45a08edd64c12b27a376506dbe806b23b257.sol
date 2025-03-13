// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Faces Of Vandalism
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////
//                 //
//                 //
//    ---------    //
//                 //
//                 //
/////////////////////


contract FOV is ERC721Creator {
    constructor() ERC721Creator("Faces Of Vandalism", "FOV") {}
}