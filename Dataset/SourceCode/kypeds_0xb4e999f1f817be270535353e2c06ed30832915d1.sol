// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: KYP005-ED(S)
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////////
//                     //
//                     //
//    ✤✤✤(๑•̀ㅂ•́)و✧    //
//                     //
//                     //
/////////////////////////


contract kypeds is ERC1155Creator {
    constructor() ERC1155Creator("KYP005-ED(S)", "kypeds") {}
}