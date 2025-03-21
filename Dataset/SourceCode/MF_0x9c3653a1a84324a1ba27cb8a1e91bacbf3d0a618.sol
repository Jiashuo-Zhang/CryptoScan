// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Marco Fine
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
//            :::   :::              :::           :::::::::         //
//          :+:+: :+:+:           :+: :+:         :+:    :+:         //
//        +:+ +:+:+ +:+         +:+   +:+        +:+    +:+          //
//       +#+  +:+  +#+        +#++:++#++:       +#++:++#:            //
//      +#+       +#+        +#+     +#+       +#+    +#+            //
//     #+#       #+#        #+#     #+#       #+#    #+#             //
//    ###       ###        ###     ###       ###    ###              //
//          ::::::::          ::::::::          ::::::::::           //
//        :+:    :+:        :+:    :+:         :+:                   //
//       +:+               +:+    +:+         +:+                    //
//      +#+               +#+    +:+         :#::+::#                //
//     +#+               +#+    +#+         +#+                      //
//    #+#    #+#        #+#    #+#         #+#                       //
//    ########          ########          ###                        //
//          :::::::::::          ::::    :::          ::::::::::     //
//             :+:              :+:+:   :+:          :+:             //
//            +:+              :+:+:+  +:+          +:+              //
//           +#+              +#+ +:+ +#+          +#++:++#          //
//          +#+              +#+  +#+#+#          +#+                //
//         #+#              #+#   #+#+#          #+#                 //
//    ###########          ###    ####          ##########           //
//                                                                   //
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////


contract MF is ERC1155Creator {
    constructor() ERC1155Creator("Marco Fine", "MF") {}
}