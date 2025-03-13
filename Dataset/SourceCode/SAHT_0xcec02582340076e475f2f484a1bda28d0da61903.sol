// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: sahtyre
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////
//                                  //
//                                  //
//                                  //
//     ▄████████    ▄█    █▄        //
//    ███    ███   ███    ███       //
//    ███    █▀    ███    ███       //
//    ███         ▄███▄▄▄▄███▄▄     //
//    ███        ▀▀███▀▀▀▀███▀      //
//    ███    █▄    ███    ███       //
//    ███    ███   ███    ███       //
//    ████████▀    ███    █▀        //
//                                  //
//                                  //
//                                  //
//                                  //
//////////////////////////////////////


contract SAHT is ERC721Creator {
    constructor() ERC721Creator("sahtyre", "SAHT") {}
}