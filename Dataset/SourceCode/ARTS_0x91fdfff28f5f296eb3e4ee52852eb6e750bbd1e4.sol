// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: artifacts
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////////////////////
//                                                 //
//                                                 //
//                                                 //
//                _   _  __            _           //
//      __ _ _ __| |_(_)/ _| __ _  ___| |_ ___     //
//     / _` | '__| __| | |_ / _` |/ __| __/ __|    //
//    | (_| | |  | |_| |  _| (_| | (__| |_\__ \    //
//     \__,_|_|   \__|_|_|  \__,_|\___|\__|___/    //
//                                                 //
//    by pale kirill                               //
//                                                 //
//                                                 //
/////////////////////////////////////////////////////


contract ARTS is ERC721Creator {
    constructor() ERC721Creator("artifacts", "ARTS") {}
}