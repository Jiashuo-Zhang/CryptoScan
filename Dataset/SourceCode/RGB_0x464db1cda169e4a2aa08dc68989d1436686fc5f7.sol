// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: RedGreenBLeUPP
/// @author: manifold.xyz

import "./ERC1155Creator.sol";

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                 //
//                                                                                                                                 //
//     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.               *%@@@%//(/,         ,#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&, ./&@@@@@@@@@@@@@@@@#.  *%&%&@@@@@@@@@@%/   *%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@% ,%@@@@@@@@@@@@@@@@@@&*./@@@@@@@@@@@@@@@@@@@@@%* .#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/ *(/.       *%@@@@@@(,  .,*/*.      ,#@@@@@@@@@@@@@@@&  (@@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*.//*/%@@@@@@#. ,(*.(@@@@@@@@@@@@@@@@@#. /%@@@@@@@@@@@@&,.(@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#, .*,..*/.   (&@@@@&/ ,%/         .,,. *%@@/.*@@@@@@@@@@@@/ ,@@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,.(,..,. ,#&#*. .*   ,((,     .* ,#@&@(.,%@@@( ,&@@@@@@@@@&/ *@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,  ,,  .(&&&&@@%*  ..,.  .  ..  ,//*. ./@@@@@@@@@@@@@@@@@@#,.%@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,/*              *%@@@&%%###(#((#%@@@@&/.,#@@@@@@@@@@@@/.,#@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@%(%@&*,%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&,.,, . .#@@@@@@@@@@@@(.,@@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@#, &@@@@&%%%(*,,,,..   ..... .,.....,...,(@@%*.@&*,%@@@@@@@@@@@@&/ &@@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@#.  ,*/*#%%%&@@@@@@@@@@@@@@@@@@&####((//*,,(&@@(./&@@@@@@@@@@@@@@%..%@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@/.*&@@@&%%&@@@&&&%((((*,,,*#%&&@@@&#//*,.      .&@@@@@@@@@@@@@@@@&* #@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.(@&(.  ...     .*(#####(/,/&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&* #@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*,%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&( #@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/,#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&( #@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@#**/%@@@@@@@@@@@@@@@@@@@@#,.&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*,%@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@(,/@@%/, ,#@@@@@@@@@@@@@@@%,,%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#.(&@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@&. .*,(&@@@**/,   ./%@@@@@@@@&#(/,   ./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/   .%@@@@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@#/.  ,&@@@(.(@@@@@@@@/.  *#&@@@@@@@@@%/,/,..  ... ...  .,**********,.        .  ....,#@@@@/ .#@@@@@@@@@@@@@@@@@@@@@     //
//    @@@@@&*  *@@@@&*,#@@@@@@@@@@@@@@#*   .(@@*./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/ /%@@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@&#(***  .(@@@@@@@@@@@@@@@@@@@&/ /&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@* *@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@&/.    *#%&@@@@@@@@@%,.#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/ (&@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@&#/,  ,%@@@%,,%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&.,#@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@#. ,* (&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@##&@@@@@@@*.*@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@#,   ,/%@@@@@@@@@@@@(..&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*,%@@@@@@@/./@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@%/. .,,,(&@@@@@@@@@(./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@( /&@@@@@@( (&@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@&/   ,/%&%/*#@@@@@@&*,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%,.%@@@@@@&( (&@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@&(,    .(@@@#,,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%, %@@@@@@@@#,*&@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*,#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%, /&@@@@@@@@%*,&@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@# /,.(@@@@@@@@%, &@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&.*%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@# #@#, &@@@@@@@# (&@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&# (@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@% *&@% *%@@@@@@% ,%@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%..%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&* #@&( (@@@@@@&*.#@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@# (&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..#@@,.(@@@@@@# (@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%* &@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#./@@&,*%@@@@@#.(@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(.,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%##/,.    *&@@/.,%###(, #@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/ *%%###(*****,.                   . .   ....          .*(#%&@@@@@@@*,(@@*.(@@@@@@,*#@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*,%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.*@%,/@@@@@@@/./@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(,*@/,(#  /&&%&*/@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(,*@#. .(,    ,./@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(.*@@@@@&*(&@@#(%@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(.*@@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.(@@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#, #&@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/.#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&( ,..%@((&@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(,*@@@@@@@@@@@@@@@@@@@@@@@@@@@(. ****, *%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@* /&/  .*@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.*@@@@@@@@@@@@@@@@@@@@@@@@@@/.*@@@@@@@* *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*,&%,,%@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,%@@@@@@@@@@@@@@@@@@@@@@@@&..#@@@@@@@@@#,.&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&#* #@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#/,                      ,*, (&@@@@@@@@@@@#.,****************** ./(/(*.,##%&@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&# (&&* /&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/ ,@@@#,,&@@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(..&@(.#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/ %@@% ,%@@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.*&@@/./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@% /&@@,,#@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#, (&@&( *%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&/.#@@@#,/@@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@(.        *%@@&/ .&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&( #@@@@*./@@@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@(,/@/. .(@@@@@..(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@# (/*/%@#**@&@@@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@%,*@@%*..(&&/ ,%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/.(%*,*,&/*//./*,@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@#. .  .  ./&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(,.%@@(,(&**(.#/**,.#@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%. *&@/,(% (#%@@@@@@@@     //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#. *%@@@@@@@@@@@@      //
//                                                                                                                                 //
//                                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract RGB is ERC1155Creator {
    constructor() ERC1155Creator() {}
}