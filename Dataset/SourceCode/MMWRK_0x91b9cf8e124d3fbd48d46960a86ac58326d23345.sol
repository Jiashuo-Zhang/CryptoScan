// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Memework
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////////////////////////////////////////////////////////////////
//                                                                       //
//                                                                       //
//    .___  ___. .___  ___. ____    __    ____ .______       __  ___     //
//    |   \/   | |   \/   | \   \  /  \  /   / |   _  \     |  |/  /     //
//    |  \  /  | |  \  /  |  \   \/    \/   /  |  |_)  |    |  '  /      //
//    |  |\/|  | |  |\/|  |   \            /   |      /     |    <       //
//    |  |  |  | |  |  |  |    \    /\    /    |  |\  \----.|  .  \      //
//    |__|  |__| |__|  |__|     \__/  \__/     | _| `._____||__|\__\     //
//                                                                       //
//                           .`";i~_-_~i;,`'                             //
//                      `!)c@$$$$$$$$$$$$$$$$#/<".                       //
//                  'ix$$$@n}!"`'.     ..`^;-t&$$$v+`                    //
//               .!z$$$$$$`                    't$$$$W-'                 //
//             .}@$$/;":[88i                     $$Wx@$$t`               //
//           .]@$B_.      -$/                   `$#  .!&$$t'             //
//          ,&$$[.         M$`                .;88`     >B$@>            //
//         [$$*`           u$^             `!f@#~.       .j$$j.          //
//        t$$t.            M$`          ^)%%\;'            _$$*.         //
//       \$$t              &$'        `v$1`                 <$$*.        //
//      l$$c               \$;       ,@*'                    1$$(        //
//     .B$$`               '8%`     '@%.                     .&$$`       //
//     >$$/                 'v$?.   1$>                       I$$t       //
//     v$$] .'``'             ,*@(_1uMf'.^I_1|\1_:`           .$$$.      //
//     @$$$$$#rn8$xi'           >B^   '*$z}i:"",</B%)"        I$$$`      //
//     $$$8:.    ';r$z+`.     .^rz     {(          ^]WB/l^`"<u$$$$`      //
//     &$$,         .,{z$8*zW@Bu{{fI":\$8i.           'I{tj|_lf$$$.      //
//     ($$i              .''..    `$@^..;M%i                  ^$$M       //
//     ^$$M                       <${     ?$r.                t$$<       //
//      r$$<                     ^@W.      ~$(               "$$&.       //
//      '%$$^                  .+@c'        $$.             .&$$"        //
//       ^@$@^              ';/@*;          @$'            'M$$!         //
//        `8$$!          "{W@ji'           .$$.           ^8$$;          //
//         'v$$r'      ,8%[^               .$$          .[$$&^           //
//           <@$@?.   ,$x.                  z$"        ;&$$1.            //
//            .}$$@{""W$^                   'c@-'   .<&$$f`              //
//              ._8$$$$$~                     ,@$8z&$$@1`                //
//                 "1%$$$u>^.               .^<$$$$@t:.                  //
//                    `<rB$$$@*j)]+<><+?1fz@$$$$v?".                     //
//                        '"i}fc&$$$$$$$8zj1<,'                          //
//                                                                       //
//                                                                       //
//                                                                       //
///////////////////////////////////////////////////////////////////////////


contract MMWRK is ERC1155Creator {
    constructor() ERC1155Creator("Memework", "MMWRK") {}
}