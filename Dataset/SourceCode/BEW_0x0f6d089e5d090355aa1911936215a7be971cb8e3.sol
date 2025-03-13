// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Birds & Worms
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////
//                    //
//                    //
//    ...uuufff...    //
//                    //
//                    //
////////////////////////


contract BEW is ERC721Creator {
    constructor() ERC721Creator("Birds & Worms", "BEW") {}
}