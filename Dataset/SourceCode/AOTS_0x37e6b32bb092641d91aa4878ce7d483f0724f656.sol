// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Art of the Square
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////
//               //
//               //
//               //
//      Art      //
//     of the    //
//     Square    //
//               //
//               //
//               //
///////////////////


contract AOTS is ERC721Creator {
    constructor() ERC721Creator("Art of the Square", "AOTS") {}
}