// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: AncientBatz Avatar by Bananakin
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////
//           //
//           //
//    ABB    //
//           //
//           //
///////////////


contract ABB is ERC1155Creator {
    constructor() ERC1155Creator("AncientBatz Avatar by Bananakin", "ABB") {}
}