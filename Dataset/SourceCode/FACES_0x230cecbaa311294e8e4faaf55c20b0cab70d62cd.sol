// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: The Faces 2023
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////////////
//                   //
//                   //
//    2023 Faces     //
//                   //
//                   //
///////////////////////


contract FACES is ERC1155Creator {
    constructor() ERC1155Creator("The Faces 2023", "FACES") {}
}