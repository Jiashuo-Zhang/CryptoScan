// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: art3mis
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////////////////////////
//                                                     //
//                                                     //
//                   __                 .__            //
//    _____ ________/  |_  ____   _____ |__| ______    //
//    \__  \\_  __ \   __\/ __ \ /     \|  |/  ___/    //
//     / __ \|  | \/|  | \  ___/|  Y Y  \  |\___ \     //
//    (____  /__|   |__|  \___  >__|_|  /__/____  >    //
//         \/                 \/      \/        \/     //
//                                                     //
//                                                     //
/////////////////////////////////////////////////////////


contract ART3 is ERC721Creator {
    constructor() ERC721Creator("art3mis", "ART3") {}
}