// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: azukinyc events deployer
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////
//                                          //
//                                          //
//                                          //
//                                          //
//    _____    ____ ___.__. ____  ____      //
//    \__  \  /    <   |  |/ ___\/ __ \     //
//     / __ \|   |  \___  \  \__\  ___/     //
//    (____  /___|  / ____|\___  >___  >    //
//         \/     \/\/         \/    \/     //
//                                          //
//                                          //
//                                          //
//////////////////////////////////////////////


contract anyce is ERC721Creator {
    constructor() ERC721Creator("azukinyc events deployer", "anyce") {}
}