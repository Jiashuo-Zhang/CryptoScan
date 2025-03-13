// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Letter from Lenexy
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////////////////////////
//                                     //
//                                     //
//                                     //
//      _        _   _                 //
//     | |   ___| |_| |_ ___ _ _       //
//     | |__/ -_)  _|  _/ -_) '_|      //
//     |____\___|\__|\__\___|_|        //
//      / _|_ _ ___ _ __               //
//     |  _| '_/ _ \ '  \              //
//     |_| |_| \___/_|_|_|             //
//     | |   ___ _ _  _____ ___  _     //
//     | |__/ -_) ' \/ -_) \ / || |    //
//     |____\___|_||_\___/_\_\\_, |    //
//                            |__/     //
//                                     //
//                                     //
//                                     //
/////////////////////////////////////////


contract LETFL is ERC1155Creator {
    constructor() ERC1155Creator("Letter from Lenexy", "LETFL") {}
}