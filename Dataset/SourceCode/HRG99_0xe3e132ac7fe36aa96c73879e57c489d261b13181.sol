// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: HOPEROOM GENESIS
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////
//                                 //
//                                 //
//                                 //
//    ██╗░░██╗██████╗░░██████╗░    //
//    ██║░░██║██╔══██╗██╔════╝░    //
//    ███████║██████╔╝██║░░██╗░    //
//    ██╔══██║██╔══██╗██║░░╚██╗    //
//    ██║░░██║██║░░██║╚██████╔╝    //
//    ╚═╝░░╚═╝╚═╝░░╚═╝░╚═════╝░    //
//                                 //
//                                 //
/////////////////////////////////////


contract HRG99 is ERC721Creator {
    constructor() ERC721Creator("HOPEROOM GENESIS", "HRG99") {}
}