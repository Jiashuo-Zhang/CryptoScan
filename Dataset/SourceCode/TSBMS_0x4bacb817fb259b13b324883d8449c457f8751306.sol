// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Mummy - Tonight (song)
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                            //
//                                                                                                                                            //
//                                                                                                                                            //
//                                                                                                                                            //
//     /__  ___/                                                                                                                              //
//       / /   ___       __     ( )  ___     / __    __  ___                                                                                  //
//      / /  //   ) ) //   ) ) / / //   ) ) //   ) )  / /                                                                                     //
//     / /  //   / / //   / / / / ((___/ / //   / /  / /                                                                                      //
//    / /  ((___/ / //   / / / /   //__   //   / /  / /                                                                                       //
//                                                                                                                                            //
//        //   ) )                                                                                                                            //
//       ((         ___       __      ___                                                                                                     //
//         \\     //   ) ) //   ) ) //   ) )                                                                                                  //
//           ) ) //   / / //   / / ((___/ /                                                                                                   //
//    ((___ / / ((___/ / //   / /   //__                                                                                                      //
//                                                                                                                                            //
//        //   ) )                                                                                                                            //
//       //___/ /                                                                                                                             //
//      / __  ( //   / /                                                                                                                      //
//     //    ) |(___/ /                                                                                                                       //
//    //____/ /    / /                                                                                                                        //
//                                                                                                                                            //
//        /|    //| |                                                    _  //   ) )  //   / /  //   ) )  //   / / //   ) )  //   / /  ))     //
//       //|   // | |              _   __      _   __                  //  ((        //____    //        //   / / //___/ /  //____    //      //
//      // |  //  | |   //   / / // ) )  ) ) // ) )  ) ) //   / /     //     \\     / ____    //        //   / / / ___ (   / ____    //       //
//     //  | //   | |  //   / / // / /  / / // / /  / / ((___/ /     //        ) ) //        //        //   / / //   | |  //        //        //
//    //   |//    | | ((___( ( // / /  / / // / /  / /      / /     ((  ((___ / / //____/ / ((____/ / ((___/ / //    | | //____/ / //         //
//                                                                                                                                            //
//                                                                                                                                            //
//                                                                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract TSBMS is ERC1155Creator {
    constructor() ERC1155Creator("Mummy - Tonight (song)", "TSBMS") {}
}