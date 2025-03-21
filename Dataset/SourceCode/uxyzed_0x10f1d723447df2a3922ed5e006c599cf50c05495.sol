// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: untitled, xyz - editions
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////////////////////////////
//                                                          //
//                                                          //
//     __  __  __  __  __  __  ______  ______  _____        //
//    /\ \/\ \/\_\_\_\/\ \_\ \/\___  \/\  ___\/\  __-.      //
//    \ \ \_\ \/_/\_\/\ \____ \/_/  /_\ \  __\\ \ \/\ \     //
//     \ \_____\/\_\/\_\/\_____\/\_____\ \_____\ \____-     //
//      \/_____/\/_/\/_/\/_____/\/_____/\/_____/\/____/     //
//                                                          //
//                                                          //
//                                                          //
//////////////////////////////////////////////////////////////


contract uxyzed is ERC1155Creator {
    constructor() ERC1155Creator("untitled, xyz - editions", "uxyzed") {}
}