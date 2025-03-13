// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: debug loop drops
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//      _   _   _   _   _     _   _   _   _     _   _   _   _   _      //
//     / \ / \ / \ / \ / \   / \ / \ / \ / \   / \ / \ / \ / \ / \     //
//    ( d | e | b | u | g ) ( l | o | o | p ) ( d | r | o | p | s )    //
//     \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/     //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


contract BUGS is ERC1155Creator {
    constructor() ERC1155Creator("debug loop drops", "BUGS") {}
}