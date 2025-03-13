// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Drug Store - Yessir (original mix)
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////////////////////////////////
//                                                   //
//                                                   //
//      __         .__        __             .___    //
//    _/  |______  |__| _____/  |_  ____   __| _/    //
//    \   __\__  \ |  |/    \   __\/ __ \ / __ |     //
//     |  |  / __ \|  |   |  \  | \  ___// /_/ |     //
//     |__| (____  /__|___|  /__|  \___  >____ |     //
//               \/        \/          \/     \/     //
//                                                   //
//                                                   //
///////////////////////////////////////////////////////


contract DSY is ERC721Creator {
    constructor() ERC721Creator("Drug Store - Yessir (original mix)", "DSY") {}
}