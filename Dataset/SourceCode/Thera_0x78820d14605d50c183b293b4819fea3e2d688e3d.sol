// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: SpecksofDustThera
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//                                                                                                                                //
//                                                                                                                                //
//                                                                               .''.                                             //
//                                                                               cKKl                                             //
//                                                             .'.               .:c'                                             //
//                                        ,d,                .ckKklc.                                                             //
//                                  .:;.  ...                'OWWWWk.                                                             //
//                                 .oWX:                     .'lx:,,.                                                             //
//                                  .,'                                                                                           //
//                                                                                                                                //
//                                                                                                                                //
//                                                                                                                                //
//                                                                                                       ...                      //
//                  .,clc:'   .:dxxxxoc;.    .lkxxxxxxxkkc       .',:lolc;'.    .loooc.   'oddxxo.   .:dOKKK0ko;.                 //
//                'dKWMMMMNOc..xMMMMMMMWXx;  .kMMMMMMMMMMx.    ;xXNWMMMMMMNKx:. ;XMMMK, .oXMMMWk,   ;OWMMMMMMMMWO'                //
//               :XMMMMMMMMWx..kMMMMMMMMMMNd..kMMMMXOOOOk:   'kNMMMMMMWNWMMMMNo ;XMMMK;,OWMMMXl.   ,KMMMMNOk0WMXc.                //
//              '0MMMMKocoOx. .xMMMWxcOWMMMWl'OMMMWl        ;KMMMMMWOc,',:dK0l. ;XMMMXOXMMMWO,     :NMMMMK: .;c.                  //
//              '0MMMMXo.     .xMMMWo.dWMMMMd'kMMMWl....   '0MMMMWNd.      ..   ;XMMMMMMMMXo.      .xWMMMMNkl'                    //
//               cXMMMMWKd'   .xMMMMXXWMMMW0,.OMMMMXKKKKc  oWMMMMO:.            ;XMMMMMMM0,         .l0WMMMMMNOc.                 //
//                ,xXMMMMMXd. .xMMMMMMMMW0l. .OMMMMMMWWNc .kMMMMWo              ,KMMMMMMMXl.          .,oONMMMMWO,                //
//                  'cOWMMMM0, dMMMMN0ko;.   .OMMMWx;,,'. .dMMMMMx,.            ,KMMMMMMMMWk'             ,oKMMMM0'               //
//               ',.  ,KMMMMMx.lMMMMk.       .kMMMN:       ;XMMMMNKd.     .,'   ;XMMMKkXMMMMK:      .::.    dWMMMWc               //
//             .dNWKkkKWMMMMNl lWMMMx.       .kMMMNd;;;;.   cXMMMMMMXkoloxKWXc  ;XMMM0,;KMMMMNd.   .dWWXOddONMMMMK,               //
//             ,OWMMMMMMMMMKc  dMMMMx.       .kMMMMWWMMMx.   ,kNMMMMMMMMMMMMMX: ;XMMMK; 'kWMMMWk.  lNMMMMMMMMMMMX:                //
//              .,lk0KXNKkl.  .kMMMWd        .kMWMMWWWWNo     .;d0XNMMMMMMNKkc. ;XMMMX;  .oXMMMWx. .:x0XWMMMMWXx,                 //
//                  .....      ,::;,.         ';;;;;,,,'.        ..';cccc;'.    .clll:.    .;;;;'      .';:::;.                   //
//                                                                                                                                //
//                                                                                                                                //
//                         '.                                                                                                     //
//          .''           .c,                           ..''..       ';;;;;;;'                        ....                        //
//         .dNXc                                     .;x0XNWN0d,    ;XMMMMMMMK,                 .;ccldxkxoc'                      //
//          ,ol.                                    .xWMMMMMMMMNk,  ;XMMN0kkkl.                  ,ldOKXNNNXKkoc'                  //
//                                                 .xWMMW0oldXMMMKx,cNMMXdccc.                       ..';:cllll;.                 //
//                               ,:,.              :XMMMNc   dWMMNK:cWMMMMMMWc             ,c.                                    //
//                              ,0MK;              ,KMMMMXxokXMMM0o'cWMMNkdxo'             :o.                                    //
//                              .;c:.               ,OWMMMMMMMMMX:  cWMMO'                                           .'           //
//                                                   .:xKWMMMN0d'   cNWW0'                                          .xKc          //
//                                                      .,::;'.     .,,,'                                            ';.          //
//          :0o.                                                                                                                  //
//          .:,                                                                                                                   //
//                                                                                                                                //
//              ..           'clloooolc;,.       'llllc.   .;::cc.      .;ldxxdo;.  'llooooddddddddd,                             //
//              cO;          oWMMMMMMMMMWXOo'    oWMMMK,   ;XMMMMd.   .lKWMMMMMMWO, oWMMMMMMMMMMMMMWl                             //
//              ..           cWMMMMMMMMMMMMMXl.  oMMMM0'   ;XMMMMx'.  lWMMMMK0NMW0, :XNNNNMMMMMWNNNX:                             //
//                           cWMMMWkclxKWMMMMWd. oMMMMk.   ,KMMMMk;. .xMMMMMO:;oc.   .''.lXMMMMx'''.                              //
//                           :NMMMX:   .cKMMMMN: lWMMMO.   .OMMMMOc.  :XMMMMMNkc.        ;XMMMWl            ;dx:                  //
//                           cNMMMK;     :NMMMMd cWMMM0'   .OMMMM0o'   'dXMMMMMWKo.      ;XMMMNc            :O0l.                 //
//                           cWMMM0'     :XMMMMd lWMMM0'   .kMMMM0d,     .cxKWMMMMK;     ;XMMMX;             ..                   //
//                           lWMMMk.    .xWMMMNc lWMMMX:   '0MMMMOl'        .lXMMMMO.    :NMMMK,                                  //
//                           lWMMMk'.,cdKWMMMWd. lWMMMM0c.,kWMMMWo.   ;xo,.  .kMMMMO.    cWMMMX;                                  //
//                           lWMMMNXXWMMMMMMXo.  '0MMMMMWNNMMMMMO'  .dNMMN0doOWMMMMx.    cWMMMX;                                  //
//                           lWMMMMMMMMMMWXx,     'xNMMMMMMMMMNk'   'ONMMMMMMMMMMWk.     lWMMMN:                                  //
//                           :KNNWWNXK0xo;.         'lx0XNNKOo,       ,lkKNWWMWXk:.      :KXKX0;                                  //
//                            ..''''..                 ..'..             ..';;,.          .....                                   //
//                                          .'.                                                                                   //
//                                         'ONo                                                                                   //
//                                          ';.                            ,c:.                                                   //
//                                                 ..                     ,KMWO'                                                  //
//                                                 ;l.                    .lkx;.                                                  //
//                                                                                                                                //
//                                                                                                                                //
//                                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract Thera is ERC721Creator {
    constructor() ERC721Creator("SpecksofDustThera", "Thera") {}
}