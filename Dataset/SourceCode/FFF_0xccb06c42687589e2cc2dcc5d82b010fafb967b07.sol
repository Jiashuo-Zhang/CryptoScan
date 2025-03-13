// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Flipped Play
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////////////////////////////
//                                   //
//                                   //
//    Let play the Flipped world!    //
//                                   //
//                                   //
///////////////////////////////////////


contract FFF is ERC1155Creator {
    constructor() ERC1155Creator("Flipped Play", "FFF") {}
}