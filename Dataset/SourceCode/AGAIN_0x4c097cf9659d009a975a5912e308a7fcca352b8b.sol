// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: AGAIN, A SoulWorld Collection.
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                            //
//                                                                                                            //
//                                                                                                            //
//                                                                                                            //
//                                                    @@@                                                     //
//                                              @@@@@@@@@@@@@@@%                                              //
//                                     @@@@@@@@@@@@@@@@ .@@@@@@@@@@@@@@@                                      //
//                                @@@@@@@@@      @@@@   ...@@@@     &@@@@@@@@                                 //
//                 @@@@@@@@@@@@@@@@@@          @@@@     .....@@@@         &@@@@@@@@@@@@@@@@@@                 //
//                 @@@@,        .&@@@@@@     @@@@#      .......@@@      @@@@@@@@/       .@@@@                 //
//                 @@@@,,,     @@@@@&      @@@@@        ........,@@@@      @@@@@*     ,,,@@@                  //
//                  @@@,,,,,@@@@@     @@@@@@@@          ..........&@@@@@@,    #@@@@.,,,,,@@@                  //
//                  @@@.,,@@@@     @@@@@@         ,,,,,,,,,,,,.........@@@@@@    @@@@@.,,@@@                  //
//                 @@@@,@@@@    @@@@@(     .,&@@@@@@@@@@@@@@@@@@@@(,.......@@@@(    @@@@,@@@@                 //
//               @@@@@@@@@    @@@@@     .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&,.....,@@@@    @@@@@@@@                //
//              @@@@ @@@    @@@@*    .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/,.....@@@/    @@@ @@@               //
//             @@@,        @@@@    ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,.....@@@     @  @@@.             //
//            @@@@        @@@    ,,@@@@@             /@@@@             @@@@@@,,....@@@        @@@             //
//           ,@@@      @@@@@    ,@@@@@                                   @@@@@/,....@@@@@      @@@            //
//           @@@   &@@@@@      ,#@@@@                                      @@@@,,......*@@@@&  @@@.           //
//           @@@@@@@@*        .,@@@@         @@@@@@         @@  @@         @@@@@,..........@@@@@@@@           //
//          @@@@@@            ,/@@@@        @@@@@          @      @@       @@@@@,,.............@@@@@          //
//       @@@@@                ,%@@@@@       @@@@@          @     @@@@      @@@@@,,................@@@@@       //
//        *@@@@.,.............,,@@@@@@       @@@@@@#       &@    @@       @@@@@@,,,*******,,****.@@@@         //
//          @@@@@@@......,.,..,,@@@@@@@                      #@@@       /@@@@@@@,,*******,*,*(@@@@@           //
//          (@@@ @@@@@..........,@@@@@@@#       %                      @@@@@@@@,**,***,*,,@@@@@@@@@           //
//           @@@@   @@@@@@.......,(@@@@@@@@    @@@@,@  @@  @ @@@@    @@@@@@@@,,,,**,,,&@@@@&   @@@            //
//           @@@@      @@@@@@.....,.@@@@@@@@@       %@@  @@@      @@@@@@@@@@,,**,,*,@@@@.     @@@@            //
//            @@@@        @@@@.......,@@@@@@@@@@               @@@@@@@@@@/,,,**,*,*@@@       @@@@             //
//             @@@@ %@     @@@@#.......,,@@@@@@@@@@@       @@@@@@@@@@@@,,,*,*,*,,@@@@    @@ @@@@              //
//              @@@@@@@@*    @@@@*........,,&@@@@@@@@@@@@@@@@@@@@@@*.,**,**,,,,@@@@    @@@@@@@@               //
//               @@@@@@@@@(    @@@@%...........,,@@@@@@@@@@@@@&.,,*,**,,,,*,,@@@@@   @@@@@@@@@                //
//                 @@@@  @@@@    @@@@@(..............,.,,,,,**,*,***,*,***@@@@@   @@@@@  @@@@                 //
//                  @@@    @@@@.   .@@@@@@#,............,,*,**,,***,*(@@@@@@@   @@@@@    @@@                  //
//                 @@@&   ,.,&@@@@*    @@@@@@@*.........,*,,,,,,**@@@@@@@    @@@@@,..    @@@                  //
//                 @@@  ,,,,,,,,%@@@@@      @@@@,........,,**,*,@@@@     @@@@@@,,,.,,,,  @@@                  //
//                 @@@@@@@@@@@@@@@@@@@@@@     @@@@.......**,*,(@@@     @@@@@@@@@@@@@@@@@@@@@                  //
//                 @@@@@@@@@@@@@@@@@@@@@&      @@@@@,,...,***@@@@      @@@@@@@@@@@@@@@@@@@@@                  //
//                                @@@@@@@@@@@@@@@@@@@/...**@@@@@@@@@@@@@@@@@@                                 //
//                                     @@@@@@@@@@@@@@@@*.&@@@@@@@@@@@@@@                                      //
//                                              #@@@@@@@@@@@@@@                                               //
//                                                    ,@@@                                                    //
//                                                                                                            //
//                                   AGAIN, A SoulWorld collection by Karalang                                //
//                                                                                                            //
//                                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract AGAIN is ERC1155Creator {
    constructor() ERC1155Creator("AGAIN, A SoulWorld Collection.", "AGAIN") {}
}