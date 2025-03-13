// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: cc0hope
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////
//            //
//            //
//    hope    //
//            //
//            //
////////////////


contract cc0hope is ERC1155Creator {
    constructor() ERC1155Creator("cc0hope", "cc0hope") {}
}