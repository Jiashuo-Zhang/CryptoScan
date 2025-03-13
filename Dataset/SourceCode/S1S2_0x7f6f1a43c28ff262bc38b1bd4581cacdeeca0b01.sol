// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: the $ubject
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////
//                                 //
//                                 //
//                                 //
//                                 //
//                                 //
//                                 //
//    ███╗   ███╗██╗██╗███████╗    //
//    ████╗ ████║██║██║██╔════╝    //
//    ██╔████╔██║██║██║███████╗    //
//    ██║╚██╔╝██║██║██║╚════██║    //
//    ██║ ╚═╝ ██║██║██║███████║    //
//    ╚═╝     ╚═╝╚═╝╚═╝╚══════╝    //
//                                 //
//                                 //
//                                 //
//                                 //
/////////////////////////////////////


contract S1S2 is ERC721Creator {
    constructor() ERC721Creator("the $ubject", "S1S2") {}
}