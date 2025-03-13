// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Drew's Dimension
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                     //
//                                                                                                                     //
//    8888b.  88""Yb 888888 Yb        dP  .o. .dP"Y8    8888b.  88 8b    d8 888888 88b 88 .dP"Y8 88  dP"Yb  88b 88     //
//     8I  Yb 88__dP 88__    Yb  db  dP  ,dP' `Ybo."     8I  Yb 88 88b  d88 88__   88Yb88 `Ybo." 88 dP   Yb 88Yb88     //
//     8I  dY 88"Yb  88""     YbdPYbdP        o.`Y8b     8I  dY 88 88YbdP88 88""   88 Y88 o.`Y8b 88 Yb   dP 88 Y88     //
//    8888Y"  88  Yb 888888    YP  YP         8bodP'    8888Y"  88 88 YY 88 888888 88  Y8 8bodP' 88  YbodP  88  Y8     //
//                                                                                                                     //
//                                                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract DrewsDimension is ERC1155Creator {
    constructor() ERC1155Creator("Drew's Dimension", "DrewsDimension") {}
}