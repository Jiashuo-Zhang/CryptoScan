// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: With Love, B.
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////////
//                                                              //
//                                                              //
//                                                              //
//                                                    _         //
//     \    /  o  _|_  |_     |    _        _        |_)        //
//      \/\/   |   |_  | |    |_  (_)  \/  (/_  o    |_)  o     //
//                                              /               //
//                                                              //
//                                                              //
//                                                              //
//////////////////////////////////////////////////////////////////


contract WLB is ERC721Creator {
    constructor() ERC721Creator("With Love, B.", "WLB") {}
}