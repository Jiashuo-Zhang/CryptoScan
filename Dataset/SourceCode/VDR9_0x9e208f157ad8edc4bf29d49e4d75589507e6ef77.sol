// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: victorvdr9 | Collections
/// @author: manifold.xyz

import "./ERC1155Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                      //
//                                                                                                                                      //
//    [size=9px][font=monospace]▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░                   //
//    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░                                           //
//    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                                          //
//    ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░'''░'░░░╙╜╜▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                                         //
//    ░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░ ░                 '╙╙▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                                       //
//    ░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░╖╖╖╖╖╖╖╖░░,,,          '╙▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                                      //
//    ░░░░░░░░░░░░░░░▒▒▒▒▒░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒╢╢╢▒╖╖,,       '╙▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                                     //
//    ░░░░░░░░░░░░░░▒▒▒░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒╖╖,      '▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                                    //
//     ░ ░░░░░░░░░▒▒▒░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒╖,      ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                                   //
//         ░ ░░░▒▒░░░░░░▒▒▒░░░░░▒▒▒æ▒▒▒▒▒▒▒▒▒▒▒▒╜╜╜╜╜╜╜╜╜╜╨╢▒▒▒▒▒▒▒▒▒▒▒▒▒║▒░     ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                                  //
//           ░▒▒░░░░░░▒▒░░░░░░░░░▓▓▓▓██▄▒▒░░░░░░░░░░░░░░░░░░░░░╙╜╢▒▒▒▒▒╢▒▒▒╙▒░     ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                                 //
//          ▒▒▒░░░░▒▒▒░░░░░░░░░░▓▓╣╢▓▓███░░░░░░░░░░░░░░░░░░░░░░░░░░░╙╢▒▓▓▓▓@╢╢▒░    ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                                 //
//        ░▒▒▒▒▒▒▒▒▒    ░ ░░░░░╠█▓▓▓▓▓▓▓██@░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒╖░░░░░░░░▒▀▒▒▒▒╬▓║▒▒╢▒░    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                                //
//       ░▒▒▒▒▒▒▒▒           ░░╫███▓▓▓▓▓▓██▌░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░╥▒░░▒▒╢╢▓║▒▒▒▒▒░░ ░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░                               //
//      ░▒▒▒▒▒▒▒`           ╓▒░▐████▓▓▓▓▓▓▓█▒▒░░░░▒▒░▒▒▒▒▒░░░░░▒▒▒▓╜ ╓╢▓▓▓▓█║▒▒▒▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                               //
//     ░▒▒▒▒▒▒░           ,▒▒▒▒▐██▀▀▀█▓▓▓▓███Ñ▒░▒▒╢╫╣▒╢╬╬╣╫╬Ñ@╖░ª▓▓ ]╫▓▓▓▓█▌╙▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                               //
//    ░░░░░░▒            ,▒▒▒▒▒▐▀  ▒░h╣▀▓▓▓▓░░'   ░░╜g@▓▓▓▓▄@▄▄Mpr*╨╜▓███▀▀ ▒░▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                              //
//    ░░░░░░            ╓▒▒▒▒▒▒'G╖,p╙▒▄▌ ▓╟▒░   ░░▒▒ ▓▓▀▄██▓▓▓▓▓▓▓▒╖  ▀ ,╗▒` ┘╢▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                              //
//    ░░░░░            ░▒▒▒▒▒░  ╫█▒▓░▒▒µ█▓▓▒`▌▓ ╢▓▓▓▓▓████▓▓▓▓▓███▓▓▓▓▓W.▓╥╩ W║▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                              //
//     ░░░             ▒░Ñ╩▒░░░▒▓▓█▌╥▄█▓▓░╓m╬╢▓▌▐▓█▌"`"█▌▀█▓▓▓████ ▓██▓▓╢▓▓Ñ ╢░░▒▒▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                              //
//                    ╓╓,  ╜▀Ñ     [▒▌▄g▓╣▄▐▌╟▓▓ ▓ µ,  ]▄Ü██▓▓▓▓█▓▐▐███▓▓▓▓▒" """`▄▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                              //
//                   δ▓▓▓▌    ▌    W, ▐▀▓▓▓g▓▓▓▓▓@█▓▓M$`███▓▓▓▓▓▓███▓█▒▓▓▓▓▓m▒     ▌` ╙░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░                              //
//                  █▓Φ█╣█ ,╓▄█╖ ,┐╙╙╝ ▄███▀╜╖▓▓,▀▓███▀▄██▓▓▓▓▓▓▓▒▓█████▌▌╫▓ m π»  ▐   ╣▒░░▒▒▒▒▒▒▒▒▒▒▒▒▒░░                              //
//            ```"""▌▓╣█▓█  ░╟█║  ▒▄▓▓▄▀▒▄▄██████▄,▀▀▄████▓▓████▓▄▓▓▓▓▌ ╙╫]▌ ▒ «▒▒¿█▓▒┐╟▒░▒▒░▒▒░▒▒▒▒▒▒▒▒░░                              //
//                  ▀g▓██▌    ▌░░▒▒▓██████▓▓▓▓▓▓▓▓▓▓▓▓███████████▓▓╣▒╙▓NA╝▒╙ ,█▓▒░ █╩* ▓▒▒╢▒░▒▒▒░░░░▒▒▒▒░░                              //
//                   Y▓▓▀ ,,▒▐▒▒▒▒╢▓▌▓██▓▓▓╣╣╣▓▓▓▓▓▓▓▓▓███████████▓╣▒░j   ╫▌ ██▌░░░▐   ╣╢▒░░░░░░░░░░░▒▒░░░                              //
//                    ▒,`╝▓▓█▓╬▓▓▓▓█▒█▓▓▓▓▓╢▓▓▓▓▓▓▓▓▓▓▓▓██████████▓╢▒▒ ╖  ╨ ╣▒▐M░░╓▓╥H╓░░▒░░░░░░░░░░▒▒░░░░                              //
//                       ░  ▐▌▓▓▓▓▓█▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████▓╜▒`   *┐╖▒▄░▓▒╓╓▒▒▒░░▒▒ ░ ░░░░░░░░▒▒░░░░                              //
//                         ,"▓╣█▓▓█▒▓╢▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓███▀▄▄Å╩▀▀Mm,,,   ,▒╜▒▓░▓ ▒▒▒▒▒▒▒░      ░░░░░▒▒░░░░░                              //
//                        ╝ █▌▓█▓▀╫███▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀R█▀  ,╓╖╖,, █▀▌ ╖╜  k╟,▒▒▒▒▒▒▒▒`          ░▒▒░░░░▒▒                              //
//                       ╜  ▓█▓▓███▓███▓▓▓▓▓▓▓▓▓▓▓▓▀▓██▓▓q▓▓▀▓▓▓░▐Ü▓▓█,,    ░░▒▒▒▒▒▒`           ░▒▒░░░░▒▒░                              //
//                       ┐ ]╢▓█▓▓████████▓▓███▓▓▓▓▌▄▒▒╜▒▒╬▓▄╥▄▓▓h^██▄ ▀▓),∩▒▒▒▒▒▒▒`            ▒▒▒▒▒▒▒▒▒░░                              //
//                      ▐]  ║▓╢█▓▓▓███████▓▓▓▓▓▓▓▓▌Æ▓╣▒▒,`╙╩▀▀▀╨░╙████▄▄j▓▒░░▒▒▒`            ,▒▒▒▒▒▒▒▒░                                 //
//                    ,*j╣▄ ▒╢▓╢███▓▓█████▓▓▓▓▓▓▓▓▓▓▐╣╢▒╜ W╖,,,  /▐████▓▓▓▄▒▒`              ▒▒▒▒▒▒▒▒░                                   //
//                 ,+` `╖▓▓█@▓▓▓▓╣▓█▓▓█████▓▓▓▓▓▓▓▓▓▌▓╢╟]╖╙▒╣║▒~║≥▐███▓▓█▓▓╜              ░▒▒▒▒▒▒▒░                                     //
//             ,⌐^` ,╓╥@▓▓▓▓█▓▓▓▓▓▓▓▓▓▓▓▓███▓▓▓▓▓▓▓▓╜▄╜╬W╠╫@µ╣╓Φ▓╢▒█████▓▓▓▄æ╖         ,▒▒░░░░▒▒░                                       //
//        ⌐^` ╓,╖µ╫▒▒@╣▓▓▓▓▓▓███▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▓▓▄╟▓▒▓▓▓╢▓██▓▓▓▓▓█████▓▓m╣&gt;▄      ,░░░░░░▒░                                       //
//    ╣ß▒▓▒╥╖▒▒▒╢╣╣╣▓▓▓▓▓▓▓▓▓▓██████████▓▓▓▓▓▓▓██████▓▓▓▄╫████▓█▓▓▓█████▓▓▌▀║,╖µ▒Y,░  ░░░░░                                             //
//    ▒▀▓Ç*º ▓╣╣▓▓▓▓▓▓█████▓█▓▓▓█████████████▓▓▓▓██▓▓▓▓▓╙▀▓████▓▓██████▓▓█▓▄ █▓x▒▒ ▄  ░'                                                //
//    ╢╣▒▓█▄▓▓▓▓▓█████▓▓▓▓▓████▓▓▓███████████████▓██▓▓▓█▓█▄▓██████▓▀██▓▓██T▓  ▓▄  ▒º1                                                   //
//    ╢╣▓▓▓█████▓▓▓▓▓▓▓▓▓▓▓▓██▓██▓▓▓██████████████████▓▓███████████▓▓▐▀▓▀▄█▌¿,≡╙▀▀▄▄ L                                                  //
//    ▓███▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▓▓▓██▓▓▓▓██████████████████▓▓▓▓▓███▓▓▓▓▓▓▓▓█▓█▌┌]║╖╖▒j▓ ▐                                                  //
//    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓▓▓█████████████████▓▓║▓▓▓▓▓▓▓▓▓▓▓██▓█ .▒▓▓▓▓╟▓                                                    //
//    ▓▓▓█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓███▓▓▓▓▓█████████████████▓▄▒▀████████████,╟▓▓▓██▓▓░                                                   //
//    ▓▓▓▓█▓▓▓▓▓▓▓█▓▓▓▓▓▓▓▓█▓▓███▓████▓▓▓▓▓████████████████▓▓▓@U▀█████████▌▓▓▓████▓"░                                                   //
//    """""""""""""""""""""""""""▀▀"""""""""""""▀""""""""""""""""""▀"""""▀"""""""""""`          ''''''''''                              //
//                                                                                                                                      //
//                                                                                                                                      //
//                                                                                                                                      //
//                                                                                                                                      //
//    [/font][/size]                                                                                                                    //
//                                                                                                                                      //
//                                                                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract VDR9 is ERC1155Creator {
    constructor() ERC1155Creator() {}
}