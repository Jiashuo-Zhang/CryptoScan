// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Nippy
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////
//            //
//            //
//    NIPS    //
//            //
//            //
////////////////


contract NIPS is ERC1155Creator {
    constructor() ERC1155Creator("Nippy", "NIPS") {}
}