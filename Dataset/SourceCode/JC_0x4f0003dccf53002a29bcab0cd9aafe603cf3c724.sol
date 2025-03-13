// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: JUUNI Community
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////////////////////////////////
//                                                   //
//                                                   //
//           _   _    _   _    _   _   _   _____     //
//          | | | |  | | | |  | | | \ | | |_   _|    //
//          | | | |  | | | |  | | |  \| |   | |      //
//      _   | | | |  | | | |  | | | . ` |   | |      //
//     | |__| | | |__| | | |__| | | |\  |  _| |_     //
//      \____/   \____/   \____/  |_| \_| |_____|    //
//                                                   //
//                                                   //
//                                                   //
//                                                   //
//                                                   //
//                                                   //
///////////////////////////////////////////////////////


contract JC is ERC721Creator {
    constructor() ERC721Creator("JUUNI Community", "JC") {}
}