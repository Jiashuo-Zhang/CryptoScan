// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Oibots on the rise!
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                 ▓█▌                                                         ▄▄,      //
//                ╟████                                        ╓              ████▌     //
//                ╟█▌▐█▌                    @█L          ┌▀▓▄æ█╗█,            ██▓██     //
//                 ▀███▀                    ▐██          ╟▀`      ▀█▀█         ╙▀╙      //
//                                  ,▄       ██       ┌▀█─          ▀▌           _▄▄    //
//                  ▓█              ╙██▄     ╟█▌      _█⌐_▄æ▀▀╙╙└└└└╙▀▄      ▐██▄╟█▌    //
//                  ██─               ▀██     └_       █▀└            ╟      ▐█████     //
//                  ██─                 ██      _▄▄Æ▀▀▀█▄╓      ,,,,   █     ▐█▌ '      //
//                  ██─         "██▄,         ▄▀╙         ╙▀▓└'       └█      ▀         //
//                   '            └▀███     ▄▀_              ▀▄        ▐▄               //
//                ▄▄▄▄                     ▓▀                 ╙▄       _▌               //
//               ╙█████                   ▐▀ ╓Æ▄         ╓▄    █"""""^"∞▌   ╒██▓▓▄▓▓    //
//                ╟███▌         ▄▄,,     ]▌ ▐▀▓██       ███▀█  ╘▌       █    └└╟█▌╙`    //
//                ╟█▌▀██       └▀▀▀██⌐   █ _█_███▌     ]███^╙▌  █       █      ▐█▌      //
//                ▐██▄██_               _▌ ╟▌▐███▌     ╫███▌└█  █"^^""*═▌       ██      //
//                ███▀╙                 ▐▌ █,╟███▌     ████▄,▌  █       ▌       ▀▀      //
//                                      ╫  █,▓███      ████▄▄▌  █      j▌               //
//                  ╓▄╥                 █_ ╟▄▄██▀      ╟███*█   █  '└""╫─    ▓▓ ▐█▌     //
//                 _████                █   ▀▓█▀        ▀███   j▌      █    _█████▌     //
//                  ████                 ██▄ ▌            ╠   _▓─     _▌     ██╜██▌     //
//                   └└                  ╫  █▀╗▄,       ,,▓▄▀█▌_  └""∞▓¬     ╚█─        //
//                ,▄▄▄▄,,,             ▐▓█  ▌  ▐¬└└╟▀╙╙╙⌐  ▌ █       _█      ,,╓▄,      //
//                ▀▀▀██▀▀▀▀             █ ╙▀█▄,▐   ▐   ▐  _▌▄▀█╓,    ╫─   _███▀▀▀└      //
//                  j██                ▄▀▌     └╙▀▀▀▀▀▀▀▀╙╙_ ▓─   └"╗▌     ██████µ      //
//                  _██              ╓▀' └▓,               ,█`      █      ╙███▄▄▄      //
//                   ██           ,#▀╙█    └▀▄,         ,▄▀└└█*w,  ▐▀        ╙╙▀▀▀      //
//                   ▀▀          █└   ▐⌐       ╙▀▀▀▀▀▀╙╙_    ╙▌  └}▌                    //
//                             ╓▀  └""╟─           ▌          ╙▄ _█        _,           //
//                 ┌████      ▄▀      █            ▌           █ █        ▓████         //
//                  ██▌      ▐▀└"""""`█            ▌            █¬        ╙███▀_        //
//                   ╙██    _▌       #▀▀▀▀▀▀Wmæ▄▄, ╟            ╘▌        _███▓         //
//                ╒████▀    ╟▄,µ╓═"└_╜    ▐     ▌ └╙▀▌╗▓▀▄       █         ██╙███µ      //
//                 '        █      ,▀     ▌    _▌   ▐b  ╙▀Q      _▌       _██  '╙       //
//                          █     é'     ▐     ▐    ╫     └█╟b    █        ╙╙           //
//                           █▄æ"       ╒`    _▀   _█      ▐▌     ╟µ         ▓▄         //
//                          ]▌ ▀▄     _É     _▀    ▐⌐     _█      _▌        ▐██         //
//                          █    └▀¥▄▄¬     ,▀    ┌▌    ╓▓▌█       █        _██         //
//                   ╒█▌    █        '╙▀▀W╗▄▄╓,,,▄█▄▄▓█▀_ '        █         └└         //
//                   ▐█▌   j▌                      ▌ └'            █      _▄▄▄▄         //
//                   j█▌   ▐b                      ▌               █      ███╙▀¬        //
//                   j█▌   ╟▄                      ▌               ▌       ▀██▄         //
//                ██µj██    └▀¥▄                   ▌           ,▄▀╙     ┌▄▓███▀         //
//                ╟█▌ ██▄▄▄,    └╙▀¥▄,            _─       ▄æ▀▀'         ╙╙' ,,,        //
//                ▐█▌  ╙▀▀▀█▀         └╙╙▀▀▀▀ªWKKKKWª▀▀▀▀╙'               ████▀▀█▀      //
//                 ███▓µ                                                  ██████⌐       //
//                   └╙                                                   ▀████▓▓▄      //
//                                                                           '└╙╙       //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////


contract OIBOTs is ERC1155Creator {
    constructor() ERC1155Creator("Oibots on the rise!", "OIBOTs") {}
}