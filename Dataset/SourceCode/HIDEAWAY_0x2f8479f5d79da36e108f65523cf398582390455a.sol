// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: HIDEAWAY by CHIARA ALEXA
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////
//            //
//            //
//    HIDE    //
//    AWAY    //
//            //
//            //
////////////////


contract HIDEAWAY is ERC1155Creator {
    constructor() ERC1155Creator("HIDEAWAY by CHIARA ALEXA", "HIDEAWAY") {}
}