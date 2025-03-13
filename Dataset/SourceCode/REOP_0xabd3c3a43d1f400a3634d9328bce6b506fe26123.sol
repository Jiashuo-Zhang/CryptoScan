// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Re Opepen
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////
//                          //
//                          //
//    For the Culture       //
//                          //
//    For the Burn          //
//                          //
//    For the Unexpected    //
//                          //
//                          //
//////////////////////////////


contract REOP is ERC1155Creator {
    constructor() ERC1155Creator("Re Opepen", "REOP") {}
}