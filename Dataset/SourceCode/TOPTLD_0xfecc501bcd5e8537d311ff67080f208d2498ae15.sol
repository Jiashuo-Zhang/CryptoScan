// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: The Opentitled
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////////////////////
//                                       //
//                                       //
//    The Opentitled by viniciusbedum    //
//                                       //
//                                       //
///////////////////////////////////////////


contract TOPTLD is ERC721Creator {
    constructor() ERC721Creator("The Opentitled", "TOPTLD") {}
}