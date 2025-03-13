// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Through the Lens of a Child
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                              //
//                                                                                              //
//    Seeing the world through the lens of a child, in all of it beauty, colours and shadows    //
//                                                                                              //
//                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////


contract LENS is ERC1155Creator {
    constructor() ERC1155Creator("Through the Lens of a Child", "LENS") {}
}