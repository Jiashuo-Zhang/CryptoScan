// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Reasoned Art - March 29th 2023
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////
//         //
//         //
//    /    //
//         //
//         //
/////////////


contract PRTNR is ERC721Creator {
    constructor() ERC721Creator("Reasoned Art - March 29th 2023", "PRTNR") {}
}