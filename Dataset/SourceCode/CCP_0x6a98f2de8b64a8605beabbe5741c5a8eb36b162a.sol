// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Chef's capricious PFP
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////
//                      //
//                      //
//    　　∧,,∧            //
//    　(`・ω・）　｡･ﾟ･⌒）    //
//    　/　　 ｏ━ヽニニフ))     //
//    　しー-Ｊ             //
//                      //
//                      //
//////////////////////////


contract CCP is ERC721Creator {
    constructor() ERC721Creator("Chef's capricious PFP", "CCP") {}
}