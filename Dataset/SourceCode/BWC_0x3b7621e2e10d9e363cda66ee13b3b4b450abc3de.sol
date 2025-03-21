// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Winter Collection
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                            //
//                                                                                            //
//                                                                                            //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣╬╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╣╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬Ñ╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╢▒╬╬╬╬╬╬╬╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╬╣▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣▓╬╬╬╬╬╬╬╬╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╫▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣╫▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╣╬╬╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╢╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╬╬╬╬╢╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╣█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╢╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬▓╬╬╬╬╬╬╬╬█▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬█▓╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬▓╬╬╬╬╬╬╬╬██╬╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╢╬╬╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╬▓╬╬╬╬╬╬╬╬██╬╬╬╬╬╬╬╬╬╣╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ▒╬╬╬╬╬╬╬╬╬╬╬╬╣█╣╬╬╬╬╬╬╬╬╬╬╣Ñ╬╢╬╬╬╬╬╬██╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ████▓╬╬╬╬╬╬╬╬╬█╬╬╬╬╬╬╬╬╬╬╬╣Ñ╬╬╬╬╬╬╬╬█▓╬╬╬╬╢╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ████████████▓▓█╬╬╬╬╬╬╬╬╬╬╬▓╬╬╬╬╬╬╬╬╬██╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╬╬╣╬╬╬╬╬╬╬╬╬██▀███████▓╬╬█╬╬╬╬╬╬╬╬╬██╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬    //
//        ╬╣╣╣╣╬╣╣╣╣╬╬╬╣█_»`  └╙╙▀█▒█╬╬╬╬╬╬╬╬╣█▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╣╬╬    //
//        ╣╬╬╣╬╬╬╬╣╬╬╬╬╬█░»_»`_»»,╫▓█╬╬╬╬╬╬╬╣╣█╬╬▓▓▓▓▓▓▓▓▓▓╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬╬▓▓▓▓███    //
//        ╬╬╬╣╣╬╬╬╣╬╣╬╣╣█M``»»»`»»╫Ñ█╬╬╬╬╬╬╬╬╣█╬╣▒╬╬╬╬╬╬╬╬╬╬╬╬████████▓╬╬╬▓▓██████████████    //
//        ╬╬╣╬╬╬╣╣╬╣╣╬╬╣█░``_`»``∩███▓╬╬╬╬╬╬╬╣█▓╣╬╬╬╬╬╬╬╬╬╬╬╬╠████████████████████████████    //
//        ╣╣╬╬╬╣╬╣╣╬╣╣╣╣█H``»»`»`»╫███████▓╬╬╣█▓▓╬╬╬╬╬╬╬╬╬╬╬╬╬███▀ÑÑ└`..``²░└│╙╙▀▀████████    //
//        ██████████▓▓╬╣█░``_` »`»╫████████████▓▓╬╬╬╬╠╠╬╬▄▓█▀▀└``                 ``²└╙▀▀█    //
//        █████████████████▓▄;_:``╟████████▌╠███▓╬╬╬▒▓█▀▀└              _  _                  //
//                                                                                            //
//                                                                                            //
//                                                                                            //
//                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////


contract BWC is ERC721Creator {
    constructor() ERC721Creator("Winter Collection", "BWC") {}
}