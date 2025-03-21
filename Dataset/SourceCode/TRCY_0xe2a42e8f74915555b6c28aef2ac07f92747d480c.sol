// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Tracyit Editions
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                          //
//                                                                                          //
//                                                                                          //
//     ____o__ __o____                                                 o     o              //
//      /   \   /   \                                                _<|>_  <|>             //
//           \o/                                                            < >             //
//            |        \o__ __o     o__ __o/      __o__   o      o     o     |              //
//           < >        |     |>   /v     |      />  \   <|>    <|>   <|>    o__/_          //
//            |        / \   < >  />     / \   o/        < >    < >   / \    |              //
//            o        \o/        \      \o/  <|          \o    o/    \o/    |              //
//           <|         |          o      |    \\          v\  /v      |     o              //
//           / \       / \         <\__  / \    _\o__</     <\/>      / \    <\__           //
//                                                           /                              //
//                                                          o                               //
//                                                       __/>                               //
//      o__ __o__/_         o     o     o        o                                          //
//     <|    v             <|>  _<|>_  <|>     _<|>_                                        //
//     < >                 < \         < >                                                  //
//      |             o__ __o/    o     |        o      o__ __o    \o__ __o       __o__     //
//      o__/_        /v     |    <|>    o__/_   <|>    /v     v\    |     |>     />  \      //
//      |           />     / \   / \    |       / \   />       <\  / \   / \     \o         //
//     <o>          \      \o/   \o/    |       \o/   \         /  \o/   \o/      v\        //
//      |            o      |     |     o        |     o       o    |     |        <\       //
//     / \  _\o__/_  <\__  / \   / \    <\__    / \    <\__ __/>   / \   / \  _\o__</       //
//                                                                                          //
//                                                                                          //
//                                                                                          //
//                                                                                          //
//                                                                                          //
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////


contract TRCY is ERC1155Creator {
    constructor() ERC1155Creator("Tracyit Editions", "TRCY") {}
}