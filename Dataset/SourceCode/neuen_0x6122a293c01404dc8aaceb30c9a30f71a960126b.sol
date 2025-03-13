// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: neuen
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////
//                       //
//                       //
//    Computational      //
//    artworks           //
//    made with          //
//    gradient           //
//    recursive          //
//    techniques.        //
//                       //
//    Marcelo Moura      //
//                       //
//    ₢ 2023             //
//                       //
//                       //
///////////////////////////


contract neuen is ERC721Creator {
    constructor() ERC721Creator("neuen", "neuen") {}
}