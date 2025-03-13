// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Ethereal Visions
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////
//                        //
//                        //
//    ETHEREAL VISIONS    //
//                        //
//                        //
////////////////////////////


contract VISIONS is ERC721Creator {
    constructor() ERC721Creator("Ethereal Visions", "VISIONS") {}
}