// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: LINE HUMAN WORLD
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//                                    ___           ___                         //
//                      ___          /__/\         /  /\                        //
//                     /  /\         \  \:\       /  /:/_                       //
//      ___     ___   /  /:/          \  \:\     /  /:/ /\                      //
//     /__/\   /  /\ /__/::\      _____\__\:\   /  /:/ /:/_                     //
//     \  \:\ /  /:/ \__\/\:\__  /__/::::::::\ /__/:/ /:/ /\                    //
//      \  \:\  /:/     \  \:\/\ \  \:\~~\~~\/ \  \:\/:/ /:/                    //
//       \  \:\/:/       \__\::/  \  \:\  ~~~   \  \::/ /:/                     //
//        \  \::/        /__/:/    \  \:\        \  \:\/:/                      //
//         \__\/         \__\/      \  \:\        \  \::/                       //
//                                   \__\/         \__\/                        //
//          ___           ___           ___           ___           ___         //
//         /__/\         /__/\         /__/\         /  /\         /__/\        //
//         \  \:\        \  \:\       |  |::\       /  /::\        \  \:\       //
//          \__\:\        \  \:\      |  |:|:\     /  /:/\:\        \  \:\      //
//      ___ /  /::\   ___  \  \:\   __|__|:|\:\   /  /:/~/::\   _____\__\:\     //
//     /__/\  /:/\:\ /__/\  \__\:\ /__/::::| \:\ /__/:/ /:/\:\ /__/::::::::\    //
//     \  \:\/:/__\/ \  \:\ /  /:/ \  \:\~~\__\/ \  \:\/:/__\/ \  \:\~~\~~\/    //
//      \  \::/       \  \:\  /:/   \  \:\        \  \::/       \  \:\  ~~~     //
//       \  \:\        \  \:\/:/     \  \:\        \  \:\        \  \:\         //
//        \  \:\        \  \::/       \  \:\        \  \:\        \  \:\        //
//         \__\/         \__\/         \__\/         \__\/         \__\/        //
//          ___           ___           ___                        _____        //
//         /__/\         /  /\         /  /\                      /  /::\       //
//        _\_ \:\       /  /::\       /  /::\                    /  /:/\:\      //
//       /__/\ \:\     /  /:/\:\     /  /:/\:\    ___     ___   /  /:/  \:\     //
//      _\_ \:\ \:\   /  /:/  \:\   /  /:/~/:/   /__/\   /  /\ /__/:/ \__\:|    //
//     /__/\ \:\ \:\ /__/:/ \__\:\ /__/:/ /:/___ \  \:\ /  /:/ \  \:\ /  /:/    //
//     \  \:\ \:\/:/ \  \:\ /  /:/ \  \:\/:::::/  \  \:\  /:/   \  \:\  /:/     //
//      \  \:\ \::/   \  \:\  /:/   \  \::/~~~~    \  \:\/:/     \  \:\/:/      //
//       \  \:\/:/     \  \:\/:/     \  \:\         \  \::/       \  \::/       //
//        \  \::/       \  \::/       \  \:\         \__\/         \__\/        //
//         \__\/         \__\/         \__\/                                    //
//                                                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////


contract LHWORLD is ERC721Creator {
    constructor() ERC721Creator("LINE HUMAN WORLD", "LHWORLD") {}
}