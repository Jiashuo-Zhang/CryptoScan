// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Season One Patron Pass
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////////////////////
//                                                  //
//                                                  //
//    ######                                        //
//    #     #   ##   ##### #####   ####  #    #     //
//    #     #  #  #    #   #    # #    # ##   #     //
//    ######  #    #   #   #    # #    # # #  #     //
//    #       ######   #   #####  #    # #  # #     //
//    #       #    #   #   #   #  #    # #   ##     //
//    #       #    #   #   #    #  ####  #    #     //
//                                                  //
//                                                  //
//                                                  //
//////////////////////////////////////////////////////


contract Patron is ERC1155Creator {
    constructor() ERC1155Creator("Season One Patron Pass", "Patron") {}
}