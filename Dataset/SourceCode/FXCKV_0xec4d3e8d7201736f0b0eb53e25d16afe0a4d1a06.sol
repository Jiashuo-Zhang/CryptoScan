// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: FXCKVATAR
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                        //
//                                                                                        //
//    ████████████████████████████████████████████████████████████████████████████████    //
//                                                                                        //
//    ████████████████████████████████████▀▀▀█████████████████████████████████████████    //
//                                                                                        //
//    ███████████████████████████████████     ▀███████████████████████████████████████    //
//                                                                                        //
//    ████████████████████▀    ▀████████▌  ▐▄  ▀██████████████████████████████████████    //
//                                                                                        //
//    ███████████████████   ▄▄   '███████  ▐█▄  ██████████████████████████████████████    //
//                                                                                        //
//    ██████████████████▌  ▄███▄   ▀█████  ▐██   █████████████████████████████████████    //
//                                                                                        //
//    ██████████████████▌  ██████▄  ▀████▌ ▐██▌  ▀████████████████████████████████████    //
//                                                                                        //
//    ██████████████████▌  ████████▄ ▐▀▀`        ▐▀▀    ▀█████████████████████████████    //
//                                                                                        //
//    ███████████████████  ▐███████▀              ,▄▄▄,  ▐████████████████████████████    //
//                                                                                        //
//    ███████████████████▌  █████▀                   ∞   █████████████████████████████    //
//                                                                                        //
//    ████████████████████               ¬ ▄╒ K  ╔"* ` ,██████████████████████████████    //
//                                                                                        //
//    ███████████████████     ▐█▀    ∞▄/▐▌╪▀ `'       ▄J▄▄▀███████████████████████████    //
//                                                                                        //
//    ██████████████████▌   +    ▄    '`             ▐▐█▐█▌███████████████████████████    //
//                                                                                        //
//    ███████████████████▄                           ▐▐█▌█▐███████████████████████████    //
//                                                                                        //
//    ██████████████████████▄▄                        ▓█▌▀████████████████████████████    //
//                                                                                        //
//    ████████████████████████ █ ▄,                   ██▀▐████████████████████████████    //
//                                                                                        //
//    █████████████████████████▄▀▀██▌▄                █,▌█████████████████████████████    //
//                                                                                        //
//    ███████████████████████████▄`▀██▌                ▀▌█████████████████████████████    //
//                                                                                        //
//    █████████████████████████████▄V▀█▀              ▄▄   ▀██████████████████████████    //
//                                                                                        //
//    █████████████████████████████▀^`             ,▄µ██ ▌  '█████████████████████████    //
//                                                                                        //
//    ████▀▀▀██████████████████▀▀   ,▄▄▓          '▀▌"'` ▀█  ██████████████████▀▀█████    //
//                                                                                        //
//    ████  ,████████████████▀    R▀▀▀"▀▀           ▌        ╟▀▀▀▀█████████████  ▐████    //
//                                                                                        //
//    ███▀  █████████████▀▀  ▄H╜╜                   ═    ╚    "    .]██████████  █████    //
//                                                                                        //
//    █▌`   █████████▀,─`   ▐  `. \                              r √▄██████``█▌  ▀▀▀▀█    //
//                                                                                        //
//    █     ▀   ▀▀██▌ ╕     ]     `           ^`            ,╔@    ╚╙██▌  █  █▌      █    //
//                                                                                        //
//    █           ▐██▌m       ,^                      Æ╨ ═Mm    ▒    ╙▀  ▐█  ▄   P  ▄█    //
//                                                                                        //
//    █       ╓   █████`                               .   `   "▀    ▄▄      ▀  ▐  ▄██    //
//                                                                                        //
//    █          ▐████          ╓▒                    ╚  ,   ╩  ∞,╩  ▀▌            ███    //
//                                                                                        //
//    █▄▄         ▀███         ╙▓                     \    ╥▀'    ,   ▌            ███    //
//                                                                                        //
//    ███▌    ,    ██▌           '`            ¿─          ╚ -"      ,▌           ████    //
//                                                                                        //
//    ████         ██         ,       .,                    /        █   ║      ,█████    //
//                                                                                        //
//    █████        █▌   ⌐ ╛▄-     '          `         -       ▀               ▄██████    //
//                                                                                        //
//    █████▄▄ `           ██▌     ╓L                ╓     ╔`   ▀`           ,▄████████    //
//                                                                                        //
//    ███████▀           ▐██     ╓  ╖  `                ,╫ ▓  ▓█▀           ▐█████████    //
//                                                                                        //
//    ██████             ██▌                           :      ▀             ▐█████████    //
//                                                                                        //
//    ██████         ╖  ▐██▌                           ]                    ▐█████████    //
//                                                                                        //
//    ██████▌           ████  ║    \             K      -     ██▄           ╙▀▀▀▀▀▀▀▀▀    //
//                                                                                        //
//    ███████    ,▄     ████         , `                ┌    ,████▌           ▄▄▄▄▄▄▄,    //
//                                                                                        //
//    ███████▌         ▐████▌╟], m                  ╛     ▐ ▐██████        ▐▄  ▀██████    //
//                                                                                        //
//    ████████         ███████¿,                          ╒████████        ▐██▄ '█████    //
//                                                                                        //
//    ████████         █████████                          ▐████████▌       ▐████, ████    //
//                                                                                        //
//    ████████        ▐█████████                          ▐█████████       ██████▌ ▀██    //
//                                                                                        //
//    ████████        ██████████                          ▐█████████       █████████▄█    //
//                                                                                        //
//    ████████      ( █████████▌                          ▐█████████▀      ▐██████████    //
//                                                                                        //
//    ████████▄       ▐██████▀                            ▐█████████ `     ▐██████████    //
//                                                                                        //
//                                                                                        //
////////////////////////////////////////////////////////////////////////////////////////////


contract FXCKV is ERC1155Creator {
    constructor() ERC1155Creator("FXCKVATAR", "FXCKV") {}
}