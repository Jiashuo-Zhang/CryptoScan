// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: JeffJag Edition
/// @author: manifold.xyz

import "./ERC1155Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//                                                                                                                                //
//                                                             ╖╓╓╓╓                                                              //
//                                                ╓╓╦╢╫╬╣╬╬╣╣▀╣╣╟╣▌▓╣▓╣╬╣▓▓▓▓▓ ╔╓                                                 //
//                                            ╦▒╬╬╬╬╠╟╡╡▒╟▒▄▓▄▓▓▌▓▄▄▄▄▌▄▄▐▄▒╢╨╩▀╣╬╬▒▒╓                                            //
//                                      ╓╗▌╫╬╩╠▒╔▄╬╬╫▓████████████████████████▓▓▄▒▄╠╬╬╣╬▒▒╦                                       //
//                                   ╓▒╬╫╬╠║▒▄▓█▓████████▓▓▓▀▀▀╠╬╬╠▀╬╬╩▀▀███████████▌╢▄▒╙║╝╬╣▄┐                                   //
//                                ┌╬▓╬╠▒▒╣▓▓▓████▓▓▀▀▀░╠╠░└┌┌ ┌┌░└╞▒▒ ░░╒▒╡╔╬╬╬▓▓██████▓▓▄╦▒╨▀╬╬╦                                 //
//                              ▄██╬▒▓╬▓▓████▀╫▒╙░═  ╚┘│═╔▓▄▄▓▓▓█▓██▓▒ ╙▒▄▄▄▄╟╣╠░░ └╠▀███████▌▒╠╠╬╠╦                              //
//                           ┌╦╬╬╠╬╣╬▓███▓██▓▒░░▒╓╓▄▓▌╘█▌┌╬▓╬╬╬╬▒╬▒▒▒╠▒ ╬██▀╙▀╙█▓▄▄░─┌▒╙║███████▓▒╬╬▒═                            //
//                          ░╟╬╬╠╬╫████▀╙▓╣╬▓╬▓█▀▀▀╝╬╝╕└╜╩╬╢▓╬╬╠╢╙╩╬╬╣╩ └   └╬  ╢█▀╨▄ ╬▓╬╬▒╙▓█████▓▄╠╫╬╗                          //
//                        ╦╬╬╬╢▌▓▓█▓█╬▒▒╚░▀████  ▒▒   ┌  ╘╬╬▓▌╣╫╫╬╦┌   ╓▒ └╬▒╓ ╧╫▌ ╦▀ ╟███▓░ ╘╠▓███▓▓▄╠╬╠╦                        //
//                      ▄╠╣╬╢╣▓▓██▓┤└╙▌╬╣▒╫███╬▒ ╟╬  ╒╬▒╝╓██╙╙█▌╬╬╣╫╠╬╬╩╫▒▒╗┐╔╬▒░  ╚▌╠▓─┌═ █▌ └ ╠█████▓▒╬╬╬                       //
//                     ▓▓╬╠╣▓╫▓██▓╣╛░╔┌░╚░╚███╣▓▓▄╦╓▄▓▓▓▓▓█   ▐█╬╬╟╩╨▓╝▓╣╬╠▓╠╣╢╠  ▒╔ ╙ ▒╬  ▓█▓╓╣╬░╠▓███▓▌╠╣▌╔                     //
//                   ┌█▓╬╬╬╬▓▓█▓█▓▌ ╧░╙  ▒╫███▌█▓└┘      ┌█    █╩╚╓    ╠╬▀╨╬╩▓▓▓╓▄▓▌  ┐ ╬▓▌▒╣██▌    ▓████▓▒╢╬║                    //
//                  ╒╬╬╬╣╢▓███▓╣╬▌╠▄╫╬ └  ╔ ╙███╓        ─█    ██▀▀██       ╔▄╙▓▓▓╬▓╓╓▒▒ ╚╬╬▒╠╣░ ┐ ▄╚▀████▓╬╩╬▒                   //
//                 ╒╣╣╬╬╫██J╙▀█▌ ╗  └╩▒╠░╩└╓███╨          █▄   █    ██     ▄█████▓▓╬▌██▒╓ ╙╬╩└ ╓▒░╟░░░└▓███▓╬╢╫█                  //
//                ┌▓╫╬╬╬╬█▌  ██▄░▌─ ╔╕╕  └└███╩           █▌   █     █▌   ╫█    ██▓╩▓▓▓▌▌▄┌╓ ╓╠╫░─╩╥░▒▐╩▓██╫╣╣╟╬▓                 //
//                █▓╣╣╣╫▓███▄  ▀██▄ └▀▒  ╗▓███            █▌   █─     █    ██    ╙▀██▓╬▓█╬▌╣ ╒╔ ╚█ ╣╪ ▌▒╬███▓▓╟╠╬▒                //
//               ╫█▓╬╫▓╫▓█╬╬██▄  └▀█▓▄ ┌▐╬███▌            ▓█   █▌  ▄  ██    └▀█▄    └▀██▄▀█▀  └  ╔▓▓┐╠╬▓▓╬▓██▓▓╣╣╠▄               //
//               ▄╫▓╣╫╫▓█▓▒╬╟╣╬██▄   ╙▀██▄███        ▄█▀▀▀█    ██  ▐   █      ╔╠██▌    └▀██╬▌░═ ┌▄▓▓██████▀▀███╫╢╬╫               //
//              ▐█▓╬╬╬▓▓█╣╬╢▄╬▒╦╚╚▀██▄   ╙▀██▓▄    ╓█▀  ▄      ██      █▒     ▄╬╣╦▓██▓J    ▀██▄█▀─     █▀  ▄  ███╬╣▌              //
//     ▄▓██▀▀▀▀▀▀▀▀▀█████▌╠╬╟╣╬╫▒ ╙╜╢╬███▓▄┌  └▀▀▀██▌  ▐       ██▌     ████████▀▀▀▀▀▀▀███▄   └█▌      a█        g▀██▄▄            //
//    █▀     ╓▄▄▄▓▓█████▓╣╬▓╣╬╟  ▓  ▓ ▐▓███████▀          ▄█▌  ╫█▌               └▀▀▀▀▀▀▀▀▀     ▄▄▄▄   ╙╟██▓█▓╓      ╙▀██▄        //
//    █▓        ╙╙▀▀▀▀█████████████▀▀▀▀▀╙└         ╓▄▄▄▄███▄   ▐██    ▄                        ▓█▀╩██████╫╟╬█████▓▄      └▀█      //
//     ▀▀▀██▄▄▄                           ╓▄▄▓████▀▀─═e   ▓█▄         ╙█▓▀▀▀▀██████████████████╬ ╔░   ╪▓▓╪░░▓█▓╬╬╫╬███▓┌    █▄    //
//            ███████████▓▓▓▓▓▓▓██████████▓███╖ ┌─└╒        █─  ▄▄▓█   f█        ├╝╘  ╤░╓╚░╛▐░░╢ ┘░┌  ─╔╢║╣╬██▓╣╫╬▓╢─  █▌   ╫█    //
//              ╬╣▓╫▓▓╫╫▓╬▓▓╢░╫╬╬└╙╬▓▓╫╬▓▓▓███─├░─          ██  ╙█ ▀█▄▄██       ─▐▒▀╓▒└╚╣╙│╔╩╗▓█▌╛╙░ ╔╩▒║▒╬║▓▓╬╬╬▓▓╣─  █▌   ▓█    //
//              └╬█▓╣╫╬╬█╣╬░╬▒╠╬█   ╙╨╙ ╠▓▓███▌ ░       ╘▒  └█   ██           ┐ ╙╣▐▒ ─  ╙╚╓╩╔▓█╨╠═  ╠╬▒╠╠▒╡╫█▓▓╣╬▓▓╣  █▀    █     //
//               ▓▓█▓▓╬╬╣▓╠╢▌▒╞╬█▓▓  ╒▓▓╬▀▓███▓┐─    ░░  ┌░─ ██   █        ═ ─▒▒╟│▌╣█▀██▄▄░╒▓█▌ ╘▒╠  ╔░ ╚ ╗▓▓▓▓▓▓▓╣███    ╓█─     //
//               ╫╫██╬▓╣╫█╩╩╣▌╫▓█╚▓▓▓ ╫█▓╬███▌╚░╙╪┌─╡ ┬╩▀┘ ─ ═█─  █▌      ─▐░╟░░▒║╠ ██ └▀█▓▓██└       ╙╦  ╫█▓▓╬▓███▀     ██       //
//                ╬▓█▓╣╬▌╬▓╬▓╠▓▌  ╣▓▓▒ └▀ ╓╠██▐─ ╔▓▄▒╬▓▒╓┌   ┐╨█  █▀    ╤╝╠╠╣▓╢╬╬▀▓ └▀█▄   ╙▀▀█████▓▓▓▄▄▄█████▀▀└     ╓██         //
//                ╙▓███▓▌╬╬▓╬╬╬╫▄  ╬▀▀   ▓▓▒██▌▒░╢░╚╫├┘╨▀╢╣▒╔  ╘▀▀f  ═╓▒▌╙▓▄▓▌╠╣▒▒▌└░  ██▄                         ▄▓█▀           //
//                 ╠▓██▓▓╬╬▓▓▒╬╬▓▒  ╔▄▓╬▓╫╣▓███░▒┐╠╤▄▄▄▄▄▄▄╙╠╚░   ═ ▒╠▒▓╣▒▒╔╛▒▒╠╢╫╟╠▒▄▄███▀██▄▄              ┌▄▄██▀╙              //
//                  ╫▓███▓▓╬╫▓╫╣▒╬╬░▓███▓╦╥╫▓███╟▌▄░░   ── ╓ ┌│░ ╓╖╦║╪╪╟▓▓▓▀╬▒╟╬╬┐▒╣████▓▒╫╕ ─╙▓███████████████╟                  //
//                   ╙╬██▓▓╬╬╬██▓▓▓E███▓▓▓▄█▓▓██D▄▄╠║▒▄▓▓I▄▄▄▄▄▄▄▓▄▄T█▓▄█▄▓█I██▓╣████O█▓╣╬▌█▄▓▄▄▄▒▒N▄▓███╫▓▓█▓░                   //
//                    ╙╬██▓▓╣╬██▌  ▄██▄▄ ██▄  ▀██▄╙▀████  ▐██  ▄█   █▄  ██   █████▀▄███▄▀█▓██▌  ╙█▌███╙███▓██▒                    //
//                     └█████╬╬█   █████▄██▌  █████  ███  ███▓███   ███▐██  ▐██▀  ██▓▓██  ███ █   ████ ████╬░                     //
//                       ╚▓█████  ╨▀▀ █████  ▐████▌  ▐█╬  █▓▓▓▓█▌  █▓╬███▌  ██▌  ▓█▓▓▓█▌  ▐█ ▐██   ╙█ ████╣                       //
//                        └▓███   ██▌█████▌  ██▓██   ██  ▓█▓▓▓▓█  ▐█▓▓▓██  ▐██   █▓▓▓▓█   ██ ████▄   ███╬╙                        //
//                          ███  █████▀ ██  ╒████  ▄██▀  ██▓▓▓█▌  ██▓▓▓█▌  ████  ██▓▓█  ▄██ ██████  ███                           //
//                          ███▓▓████▓▓███▓▓██████████▓▓▓██████▓▓▓██████▓▓▓███▓██▓█████████▓██████████                            //
//                              ╙▓███████▓▌╣▓╬▓▓▄╫╩████▌╣▓╬╫╬╣╣╫▓████▓▓▓▓█▓╣▒▄▒║╟╫▓▓▓╣╬▒╠╫▓██████╬╙                               //
//                                 ╙████████▓█▓▓▓╬▓███╬█▀╩╚╣╬▓╬╬█▓█▓█▓╣╬╣╬╟╬╬█▓█▓▓╠╟▓▓▓███████▌╚╙                                 //
//                                    ▀███████████▓▓▓▓╬█▌█▓▀█╣▓█▓▓▓╬█╣▓▀▀▓╬╬▌╬╫▓▓██████████▓╩╙                                    //
//                                       └└╣██████████████▓█▒▓▓╣╣╫╣╫▓▓▓▓████████████████▓▀                                        //
//                                            ╙╚███████████████████████████████████▀▀╙                                            //
//                                                ╙▀▀▀████████████████████╝╨╨▀╙                                                   //
//                                                        JEFFJAG EDITION                                                         //
//                                                                                                                                //
//                                                                                                                                //
//                                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract JEFFJAG is ERC1155Creator {
    constructor() ERC1155Creator() {}
}