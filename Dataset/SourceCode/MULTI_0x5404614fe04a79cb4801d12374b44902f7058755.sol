// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Multistate
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////
//                                                //
//                                                //
//                      ■ ■ ■                     //
//                    ■   ■ ■                     //
//                    ■ ■ ■ ■                     //
//                    ■ ■ ■                       //
//                                                //
//     MULTISTATE COMPOSITIONS by ADAM SWAAB      //
//                                                //
//                                                //
////////////////////////////////////////////////////


contract MULTI is ERC721Creator {
    constructor() ERC721Creator("Multistate", "MULTI") {}
}