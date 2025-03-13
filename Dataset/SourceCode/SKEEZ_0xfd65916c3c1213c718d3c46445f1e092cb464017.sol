// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Skeezard's Chop Shop
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                  //
//                                                                                                                  //
//     o-o  o  o o--o o--o o---o   O  o--o  o-o   o  o-o        o-o o  o  o-o  o--o       o-o  o  o  o-o  o--o      //
//    |     | /  |    |       /   / \ |   | |  \  | |          /    |  | o   o |   |     |     |  | o   o |   |     //
//     o-o  OO   O-o  O-o   -O-  o---oO-Oo  |   O    o-o      O     O--O |   | O--o       o-o  O--O |   | O--o      //
//        | | \  |    |     /    |   ||  \  |  /        |      \    |  | o   o |             | |  | o   o |         //
//    o--o  o  o o--o o--o o---o o   oo   o o-o     o--o        o-o o  o  o-o  o         o--o  o  o  o-o  o         //
//                                                                                                                  //
//                                                                                                                  //
//                                                                                                                  //
//                                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract SKEEZ is ERC721Creator {
    constructor() ERC721Creator("Skeezard's Chop Shop", "SKEEZ") {}
}