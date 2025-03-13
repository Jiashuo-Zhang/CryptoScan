// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: AIC
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////////////////////////
//                                           //
//                                           //
//    AI Classicism artworks by Akashi30.    //
//                                           //
//                                           //
///////////////////////////////////////////////


contract AIC is ERC721Creator {
    constructor() ERC721Creator("AIC", "AIC") {}
}