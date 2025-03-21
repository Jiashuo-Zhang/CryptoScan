// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Abominable Dragons
/// @author: manifold.xyz

import "./ERC721Creator.sol";

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                                                           //
//                                                                           //
//       _____ ___.                  .__             ___.   .__              //
//      /  _  \\_ |__   ____   _____ |__| ____ _____ \_ |__ |  |   ____      //
//     /  /_\  \| __ \ /  _ \ /     \|  |/    \\__  \ | __ \|  | _/ __ \     //
//    /    |    \ \_\ (  <_> )  Y Y  \  |   |  \/ __ \| \_\ \  |_\  ___/     //
//    \____|__  /___  /\____/|__|_|  /__|___|  (____  /___  /____/\___  >    //
//            \/    \/             \/        \/     \/    \/          \/     //
//                                                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


contract ABDR is ERC721Creator {
    constructor() ERC721Creator("Abominable Dragons", "ABDR") {}
}