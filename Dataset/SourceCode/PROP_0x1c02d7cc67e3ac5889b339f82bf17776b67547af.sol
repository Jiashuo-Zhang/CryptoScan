// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: PROPAGÆNDA
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////
//                      //
//                      //
//                      //
//          _______     //
//         /   ____|    //
//        /   |__       //
//       / /|  __|      //
//      / ___ |____     //
//     /_/  |______|    //
//                      //
//                      //
//                      //
//                      //
//////////////////////////


contract PROP is ERC1155Creator {
    constructor() ERC1155Creator(unicode"PROPAGÆNDA", "PROP") {}
}