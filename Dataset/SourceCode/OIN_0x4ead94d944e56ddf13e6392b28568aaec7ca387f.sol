// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Organized Insanity
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////////////////////////
//                                                     //
//                                                     //
//    Brain is Insanely Organized, thus it Works...    //
//                                                     //
//                                                     //
/////////////////////////////////////////////////////////


contract OIN is ERC721Creator {
    constructor() ERC721Creator("Organized Insanity", "OIN") {}
}