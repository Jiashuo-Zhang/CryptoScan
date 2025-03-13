// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Seed of Feed
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////////////////////////////////////////////
//                                                         //
//                                                         //
//                                                         //
//                                                         //
//                                                         //
//                  `  `  `   `   `` ` ``   `  `           //
//          `  .....MMMMMMMB.,  ..MMMMMMMM....,    `       //
//           .-J""""_-.---_("G(--"<_-_..--""""4-.          //
//       `  um<!..(+++++<~_~.(TMF.~~~(+++++<..(<qm         //
//        ,Mr_-((::~~_~_-?<_:(??>:_(?~-~_.:::(-__(M[  `    //
//        ,"n-""Bge((-:~~_(<:~:~~:<>__::((((gW""a-"^       //
//          ?"   "4ggm+++++++<:~(+++++++gggf"   7=         //
//                 ``(NNNNNNNb??jNNNNNNN]```               //
//               ........   Mb??dM~  ........              //
//           ....HHHHHHHB...M8zrdMJ..dHHHHHHH(...          //
//          (gYYY:++:<+udYYWNKrrqNYYYC++++:++TYYQg         //
//        ,M$<=>::+l=llllllludMM#XOz:;<lllpRl==l<jM)       //
//       .,M$+ll=lll=zzzl=zzwdMM#wlz<<+l==l=l=dWzJML.      //
//       M#+1=l=ll=l=vUIl=ZUzyzM#zzl=l=l=ll=ll=llz+d#      //
//       M#=lzkZ=ldkzllll=llzzuMBzll=ll=lzky=ldkZ=ld#      //
//       M#=ll=l=l=ll=l=l=wuzzzbRzuZ=ll==ll=l=l=ll=d#      //
//       HBazlzzl=1u=zzUWzzuXXppRXzzuWSzzluz=lzzzjQMB      //
//        ,"QgXyzzdUwzzuXXXQNNNNNNkXXXzuwzUSzzdXgk"^       //
//          _?NNNWWWWWWWWNN#??????NNNHWWWWWWWNNN=!         //
//               MMMMMMM#            dMMMMMMM              //
//    Kintama                                              //
//                                                         //
//                                                         //
/////////////////////////////////////////////////////////////


contract SOF is ERC1155Creator {
    constructor() ERC1155Creator("Seed of Feed", "SOF") {}
}