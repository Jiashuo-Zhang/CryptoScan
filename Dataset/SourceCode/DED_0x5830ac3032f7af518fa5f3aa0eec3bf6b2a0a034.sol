// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Dedpool
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////////
//                                      //
//                                      //
//    $$$$$$$\  $$$$$$$$\ $$$$$$$\      //
//    $$  __$$\ $$  _____|$$  __$$\     //
//    $$ |  $$ |$$ |      $$ |  $$ |    //
//    $$ |  $$ |$$$$$\    $$ |  $$ |    //
//    $$ |  $$ |$$  __|   $$ |  $$ |    //
//    $$ |  $$ |$$ |      $$ |  $$ |    //
//    $$$$$$$  |$$$$$$$$\ $$$$$$$  |    //
//    \_______/ \________|\_______/     //
//                                      //
//                                      //
//////////////////////////////////////////


contract DED is ERC1155Creator {
    constructor() ERC1155Creator("Dedpool", "DED") {}
}