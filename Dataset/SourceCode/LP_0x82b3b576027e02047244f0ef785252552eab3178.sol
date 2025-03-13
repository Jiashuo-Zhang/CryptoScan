// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Loyalty_Park
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////
//                                                          //
//                                                          //
//    Loyal_T                                               //
//                                                          //
//                                                          //
//////////////////////////////////////////////////////////////


contract LP is ERC721Creator {
    constructor() ERC721Creator("Loyalty_Park", "LP") {}
}