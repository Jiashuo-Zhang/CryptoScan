// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: KEK WIN$
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                      //
//                                                                                                                                                      //
//      ':::::::::::::::::::::::,.                             'ccccccccccccccccccccccccc;.                            .;ccccccccccccccccccccccc;.      //
//     lNMMMMMMMMMMMMMMMMMMMMMMMWO,                           :XMMMMMMMMMMMMMMMMMMMMMMMMMWx.                          'OWMMMMMMMMMMMMMMMMMMMMMMMWo      //
//     ;KMMMMMMMMMMMMMMMMMMMMMMMMMKc                          lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                         :KMMMMMMMMMMMMMMMMMMMMMMMMMK:      //
//      ,OWMMMMMMMMMMMMMMMMMMMMMMMMNd.                        lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                       .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,       //
//       .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,                       lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                      'OWMMMMMMMMMMMMMMMMMMMMMMMMNd.        //
//         cKMMMMMMMMMMMMMMMMMMMMMMMMMK:                      lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                     :KMMMMMMMMMMMMMMMMMMMMMMMMMXc          //
//          ,OWMMMMMMMMMMMMMMMMMMMMMMMMNd.                    lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                   .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,           //
//           .dNMMMMMMMMMMMMMMMMMMMMMMMMWO'                   lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                  'OWMMMMMMMMMMMMMMMMMMMMMMMMNd.            //
//             cKMMMMMMMMMMMMMMMMMMMMMMMMMK:                  lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                 :KMMMMMMMMMMMMMMMMMMMMMMMMMXc              //
//              ,OWMMMMMMMMMMMMMMMMMMMMMMMMNd.                lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.               .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,               //
//               .dNMMMMMMMMMMMMMMMMMMMMMMMMWO'               lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.              'OWMMMMMMMMMMMMMMMMMMMMMMMMNx.                //
//                 cXMMMMMMMMMMMMMMMMMMMMMMMMMK:              lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.             :KMMMMMMMMMMMMMMMMMMMMMMMMMXc                  //
//                  ,OWMMMMMMMMMMMMMMMMMMMMMMMMNd.            .d0KKKKKKKKKKKKKKKKKKKKKKK0O;            .oNMMMMMMMMMMMMMMMMMMMMMMMMWO,                   //
//                   .dNMMMMMMMMMMMMMMMMMMMMMMMMWO'             .........................             'kWMMMMMMMMMMMMMMMMMMMMMMMMNx.                    //
//                     cXMMMMMMMMMMMMMMMMMMMMMMMMMK:            .........................            :KMMMMMMMMMMMMMMMMMMMMMMMMMXc                      //
//                      ,OWMMMMMMMMMMMMMMMMMMMMMMMMNd.        .x0KKKKKKKKKKKKKKKKKKKKKKKKO:        .oNMMMMMMMMMMMMMMMMMMMMMMMMWO,                       //
//                       .xNMMMMMMMMMMMMMMMMMMMMMMMMWO'       lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.      'kWMMMMMMMMMMMMMMMMMMMMMMMMNx.                        //
//                         cXMMMMMMMMMMMMMMMMMMMMMMMMMK:      lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.     :KMMMMMMMMMMMMMMMMMMMMMMMMMXc                          //
//                          ,OWMMMMMMMMMMMMMMMMMMMMMMMMNo.    lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.   .oNMMMMMMMMMMMMMMMMMMMMMMMMW0,                           //
//                           .xNMMMMMMMMMMMMMMMMMMMMMMMMWk'   lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.  'kWMMMMMMMMMMMMMMMMMMMMMMMMNx.                            //
//                             lXMMMMMMMMMMMMMMMMMMMMMMMMMK;  lWMMMMMMMMMMMMMMMMMMMMMMMMMMO. ;KMMMMMMMMMMMMMMMMMMMMMMMMMXl.                             //
//                             .kMMMMMMMMMMMMMMMMMMMMMMMMMMk. lWMMMMMMMMMMMMMMMMMMMMMMMMMMO..xMMMMMMMMMMMMMMMMMMMMMMMMMMO.                              //
//                            .oNMMMMMMMMMMMMMMMMMMMMMMMMM0;  lWMMMMMMMMMMMMMMMMMMMMMMMMMMO. 'kWMMMMMMMMMMMMMMMMMMMMMMMMWx.                             //
//                           .kWMMMMMMMMMMMMMMMMMMMMMMMMWx.   lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.  .oNMMMMMMMMMMMMMMMMMMMMMMMMW0,                            //
//                          ;0MMMMMMMMMMMMMMMMMMMMMMMMMXl.    lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.    :KMMMMMMMMMMMMMMMMMMMMMMMMMXc.                          //
//                        .oXMMMMMMMMMMMMMMMMMMMMMMMMM0;      lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.     'kWMMMMMMMMMMMMMMMMMMMMMMMMNx.                         //
//                       .kWMMMMMMMMMMMMMMMMMMMMMMMMWx.       ;XMMMMMMMMMMMMMMMMMMMMMMMMMWd.      .oNMMMMMMMMMMMMMMMMMMMMMMMMW0,                        //
//                      ;0MMMMMMMMMMMMMMMMMMMMMMMMMXl.         ':cccccccccccccccccccccccc;.         :KMMMMMMMMMMMMMMMMMMMMMMMMMXc                       //
//                    .lXMMMMMMMMMMMMMMMMMMMMMMMMM0;                                                 'kWMMMMMMMMMMMMMMMMMMMMMMMMNx.                     //
//                   .kWMMMMMMMMMMMMMMMMMMMMMMMMWk.            .',,,,,,,,,,,,,,,,,,,,,,,,.            .oNMMMMMMMMMMMMMMMMMMMMMMMMWO,                    //
//                  ;0MMMMMMMMMMMMMMMMMMMMMMMMMXl.            ,ONWWWWWWWWWWWWWWWWWWWWWWWWXl.            :KMMMMMMMMMMMMMMMMMMMMMMMMMXc                   //
//                .lXMMMMMMMMMMMMMMMMMMMMMMMMM0;              lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.             'OWMMMMMMMMMMMMMMMMMMMMMMMMNx.                 //
//               .xWMMMMMMMMMMMMMMMMMMMMMMMMWk.               lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.              .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,                //
//              ;0MMMMMMMMMMMMMMMMMMMMMMMMMXl.                lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                :KMMMMMMMMMMMMMMMMMMMMMMMMMXc               //
//            .lXMMMMMMMMMMMMMMMMMMMMMMMMM0;                  lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                 'OWMMMMMMMMMMMMMMMMMMMMMMMMNd.             //
//           .xWMMMMMMMMMMMMMMMMMMMMMMMMWk.                   lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                  .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,            //
//          ;0MMMMMMMMMMMMMMMMMMMMMMMMMNo.                    lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                    :KMMMMMMMMMMMMMMMMMMMMMMMMMXc           //
//        .lXMMMMMMMMMMMMMMMMMMMMMMMMM0;                      lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                     'OWMMMMMMMMMMMMMMMMMMMMMMMMNd.         //
//       .xWMMMMMMMMMMMMMMMMMMMMMMMMWk.                       lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                      .dNMMMMMMMMMMMMMMMMMMMMMMMMWO,        //
//      ;0MMMMMMMMMMMMMMMMMMMMMMMMMNo.                        lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                        :KMMMMMMMMMMMMMMMMMMMMMMMMMXc       //
//     :XMMMMMMMMMMMMMMMMMMMMMMMMMK;                          lWMMMMMMMMMMMMMMMMMMMMMMMMMMO.                         'OWMMMMMMMMMMMMMMMMMMMMMMMMNl      //
//     cXMMMMMMMMMMMMMMMMMMMMMMMNx'                           ,0NWWWWWWWWWWWWWWWWWWWWWWWWXl.                          .oXWWWWWWWWWWWWWWWWWWWWWWWXc      //
//      .;;;;;;;;;;;;;;;;;;;;;;;'                              .',,,,,,,,,,,,,,,,,,,,,,,,.                              .,,,,,,,,,,,,,,,,,,,,,,,.       //
//                                                                                                                                                      //
//                                                                                                                                                      //
//                                                                                                                                                      //
//                                                                                                                                                      //
//      ,ccccc,   ,ccccc,   'ccccccccccc;.  'ccccc;.  'ccccc;.  .ccccccccccc:;.  .ccccc'        'ccccc.  'cccccccccccc;.  ,cccc;.      'ccccc:.         //
//     .OMMMMMK; ,KMMMMMO. .xMMMMMMMMMMMK, .xMMMMMNc .OMMMMMK,  oWMMMMMMMMMMNK:  oMMMMMd        dMMMMWl  dMMMMMMMMMMMM0' .OMMMMK,     .OMMMMMWo         //
//     .OMMMMMMd.oWMMMMMO. .xMMMMMWWWWWW0' .xMMMMMMk.cWMMMMMK,  oWMMMMWWWWWWX0;  oMMMMMd        dMMMMWl  dMMMMMMMMMMMM0' .OMMMMK,     cNMMMMMMK,        //
//     .OMMMMMM0o0MMMMMMO. .xMMMMNxcccc;.  .xMMMMMMXokMMMMMMK,  oWMMMWkcccc;'..  oMMMMMd        dMMMMWl  ,ooxXMMMMWOooc. .OMMMMK,    .OMMMMMMMWo        //
//     .OMMMMMMWNWMMMMMMO. .xMMMMWNKKXk'   .xMMMMMMWNWMMMMMMK,  oWMMMMNXKX0;     oMMMMMd        dMMMMWl     .kMMMMN:     .OMMMMK,    cNMMWKKMMMK,       //
//     .OMMMMWWMMMWWMMMMO. .xMMMMMMMMMK,   .xMMMMWWMMMMWWMMMK,  oWMMMMMMMMN:     oMMMMMd        dMMMMWl     .kMMMMN:     .OMMMMK,   .OMMMXldMMMWd       //
//     .OMMMW0KMMMK0WMMMO. .xMMMMNkoooc.   .xMMMMKKMMMX0NMMMK,  oWMMMWOoool.     oMMMMMx.....   dMMMMWl     .kMMMMN:     .OMMMMK,   cNMMMNk0MMMMK,      //
//     .OMMMWddWMWddWMMMO. .xMMMMNOdddddl. .xMMMMxdNMMkoXMMMK,  oWMMMW0dddddol'  oMMMMMWXXXX0,  dMMMMWl     .kMMMMN:     .OMMMMK,  .OMMMMMMMMMMMWd      //
//     .OMMMWl;KMK;lMMMMO. .xMMMMMMMMMMMK, .xMMMMd,OMN::NMMMK,  lWMMMMMMMMMMNK:  oWMMMMMMMMMX;  dMMMMWl     .kMMMMN:     .OMMMMK,  cNMMMNKOOXWMMMK,     //
//     .dK0K0:.lKl.:0K0Kd.  lKKKKKKKKK0Kk'  lK0KKl.:0d.,OK0Kk'  :0KKKKKKKKKKOk;  c0KKKKKKK0KO,  lKKKK0:     .oK0KKO,     .dK00Kk' .dK0KKo.  ,kK0K0c     //
//      .....   .   .....   .............   ......  ..  .....    .............    ...........   ......       ......       ......   ......    ......     //
//                                                                                                                                                      //
//                                                                                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract KW is ERC721Creator {
    constructor() ERC721Creator("KEK WIN$", "KW") {}
}