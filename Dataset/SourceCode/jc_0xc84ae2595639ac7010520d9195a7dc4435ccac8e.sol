// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: The Janitors Closet
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                            //
//                                                                                                            //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&G5YJJY5G#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&P?~~!7???!~~7P&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@P!^!5B#BBBB#B57^~5@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&?^~5##57~~~~7Y#&P!^?&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#7^!G&G!^^^^^^^^!P&B7^!B@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G~^?#&5~^^^^^^^^^^~5&#J^~P@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@5^^Y##Y^^^^^^^^^^^^^^J#&5^^Y@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&J^~P&#?^^^^^^^^^^^^^^^^7B&P~^?&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#7^!G&G7^^^^^^^^^^^^^^^^^^!G&B7^!#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@B!^?B&P~^^^^^^^^^^^^^^^^^^^^~5&#?^~G@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@P~^J##Y~^^^^^^^^^^^^^^^^^^^^^^^J##Y^^5@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Y^~5&#J^^^^^^^^^^^^^^^^^^^^^^^^^^?B&P~^J&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@&?^!G&B7^^^^^^^^^^^^^^^^^^^^^^^^^^^^!G&G!^7#@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@B!^7B&G!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~P&B?^!B@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@P~^J#&5~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Y##Y^^P@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@Y^^Y&#J^^^^7J5P5J7^^^^^^^^^^^^^^^!!~^^^^^^^?#&5~^J@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@&?^~P&B7^^^~5#######5~^^^^^^^^^^^~5##B7^^^^^^^7B&G!^?&@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@#!^7B&G!^^^^7&#######&7^^^^^^^^^^?B###P!^^^^^^^^!P&B7^!B@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@G~^?#&5~^^^^^~P#######P~~!~~~~~~!P####J^^^^^^^^^^^~5&#J^~P@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@5^^Y##Y^^^^^^^^~75PGPY?7YGBBBBBBB#&##G!^^^^^^^^^^^^^^J#&5~^Y@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@&J^~P&B?^^^^^^^^^^^^^^75B########BBBBBY~^^^^^^^^^^^^^^^^7B&P!^?&@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@#7^!G&G!^^^^^^^^^^^^^!5##########BJ~~!~^^^^^^~^^^^^^^^^^^^!G&B7^!#@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@G~^?B&P~^^^^^^^^^^^^~JB###GP########P!^^^^^!?5GGY!^^^^^^^^^^~5&#?^~G@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@5^^J##Y~^^^^^^^^^^^^!G###BY~^?B########Y~!JPB######57^^^^^^^^^^J##Y^^5@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@J^~5&#?^^^^^^^^^^^^^^!####?^^^^~5########B######B#####P?~^^^^^^^^?B&P~^J&@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@&7^!G&B7^^^^^^^^^^^^^^^~G###Y^^^^^^7G##########B5?~?P#####GJ~^^^^^^^!G&G!^7#@@@@@@@@@@@@    //
//    @@@@@@@@@@@B!^7B&P!^^^^^^^^^^^^^^^^^Y###G~^^^^^^~JB######57~^^^^^75#####BY!^^^^^^~P&#?^~G@@@@@@@@@@@    //
//    @@@@@@@@@@P~^J#&5~^^^^^^^^^^^^^^^^^^7####!^^^^^^^^!5#####G7^^^^^^^^!YB##&&5^^^^^^^^Y##Y^^5@@@@@@@@@@    //
//    @@@@@@@@@Y^^5&#J^^^^^^^^^^^^^^^^^^^^~P##B!^^^^^^^^^^7G#####Y~^^^^^^^^!JPPY!^^^^^^^^^?#&5~^J@@@@@@@@@    //
//    @@@@@@@&?^~P&B7^^^^^^^^^^^^^^^^^^^^^^~!7~^^^^^^^^^^^^~JB###&G~^^^^^^^^^^^^^~^^^^^^^^^7B&G!^7#@@@@@@@    //
//    @@@@@@#!^7B&G!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^P####G~^^^^^^^^^^^^^^^^^^^^^^^^~P&B7^!B@@@@@@    //
//    @@@@@G~^?#&5~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^J####B!^^^^^^^^^^^^^^^^^^^^^^^^^^~Y&#J^~P@@@@@    //
//    @@@@5^^Y##J^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^7#####7^^^^^^^^^^^^^^^^^^^^^^^^^^^^^J#&5~^Y@@@@    //
//    @@&J^~P&B?^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!B####J^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^7B&G!^?&@@    //
//    @&7^!G&G!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Y&##&5^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!G&B7^7&@    //
//    @Y^~G&G~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~YPPJ~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~P&B!^J@    //
//    &!^J&#7^^^^^^^^^^^^^^^^^^^^^^^^^JPPPPPPPPPPPPPPPPPPPP5PP5PPPPPPPPPPPPPY^^^^^^^^^^^^^^^^^^^^^^!#&Y^~#    //
//    &!^?&#J^^^^^^^^^^^^^^^^^^^^^^^^^!7777777777777777777777777777777777777!^^^^^^^^^^^^^^^^^^^^^^?#&J^~&    //
//    @P^^Y##57~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~7Y##5^^5@    //
//    @@G!^!5B#BBGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGBB#B57^~P@@    //
//    @@@&P?~~!7?JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ?7!~~75&@@@    //
//    @@@@@@&BPYJ??????????????????????????????????????????????????????????????????????????????JYPG&@@@@@@    //
//                                                                                                            //
//                                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract jc is ERC721Creator {
    constructor() ERC721Creator("The Janitors Closet", "jc") {}
}