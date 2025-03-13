// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: romandrits
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////
//               //
//               //
//               //
//               //
//     ._ _|     //
//     | (_|     //
//     __        //
//               //
//               //
//               //
///////////////////


contract rd is ERC721Creator {
    constructor() ERC721Creator("romandrits", "rd") {}
}