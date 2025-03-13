// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: OEA30
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////
//                                  //
//                                  //
//    Open Editions by Akashi30.    //
//    Free to use for holders.      //
//                                  //
//                                  //
//////////////////////////////////////


contract OEA30 is ERC1155Creator {
    constructor() ERC1155Creator("OEA30", "OEA30") {}
}