// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: OneOfOne
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////
//           //
//           //
//    1/1    //
//           //
//           //
///////////////


contract OOO is ERC721Creator {
    constructor() ERC721Creator("OneOfOne", "OOO") {}
}