// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Super street Fridge alpha turbo ex spécial édition
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////
//                                //
//                                //
//    Super spécial collection    //
//                                //
//                                //
////////////////////////////////////


contract SSFA is ERC721Creator {
    constructor() ERC721Creator(unicode"Super street Fridge alpha turbo ex spécial édition", "SSFA") {}
}