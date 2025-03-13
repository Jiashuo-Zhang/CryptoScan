// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Saxy Seal
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////
//                        //
//                        //
//    Saxy Seal by Axe    //
//                        //
//                        //
////////////////////////////


contract Saxy is ERC721Creator {
    constructor() ERC721Creator("Saxy Seal", "Saxy") {}
}