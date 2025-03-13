// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: RING DE RING
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//                                                                                                                                //
//     ..JWBTT"""TYUwa, ........ .                    .                                                                           //
//    JP=`.]R `_!??774,WsTFJTOu/#<+zy4...dY"""T,.JTM"<(?W,   ..                                                                   //
//    d]  .]D         ,hW-]z   %#,: ,/#"!,!F ~]MY!J(=   4?Nkd\..JJzZ74J.Jd"""TTOO&+JJ........                                     //
//    d]  .]R          ,[N]w  .]#,:  bj  .<]  ]H ((%     j([,}]      ?i?x(,!??77""""5 J<+((..JWKX@T7"WZTCu..........(s"Ta,        //
//    d]  .]R           WJ]w  .]#,:  J([ ,>]  ]H.\P       4(,)]        (,k,.        = ]      .nW,b) ,J(\_b#"7Hv74JY7F,^ Td,       //
//    d]  .[P           ,f]w  .]#,:  .b4 ,:]  ]W2,`       ,[M)]  ....   j(,.  .     1 ]       .PNb) ,J() (d. WI ,J JJ    (J,      //
//    d%  .[D  .....,   .b\w   t#,~   z,<,_]  ]M\P    ..   SJ}]  ]Z"ij, .[.. (..--J+&,]        (Jb) .(() .Z[ Xc ,J.u'     Gh      //
//    d%  ,%b  ,AKTT,W   H X  .]#,;   .]h,<]  ]H.\  .Y.J,  ((}]  FI  [6  n,~ (,MM#o-.}]        .Pb] ,J+)  Oh XI ,Jss      ,J;     //
//    d]  ,[P  ,XF  j,[  W X  .]N,:    W(->]  ]%J   f,`h(. .| ]  F$  j,  j,_ (""TT1u-[] .2<<+,  bC] ,J<)  ,J,XI ,JS]  .(,  Db     //
//    d\  ,[D  ,dN  ,-]  d 0  .]#,!    ,|H:]  ] K  .:] ,/) .>.]  ]$  (.. (,!       ,r]] .lF?3(  w.] ,J<[   DbuR ,JJ! .jWJ. jW     //
//    d\  ,\P  ,d#  .:F  d 0  .]#,.     5J<]  ].F  (.:  ]&J(d}]  ]R  J.  (.!       .l[] .{] ,.! (.] .J<[   (jy$ .(d  2y D] ,J.    //
//    d[  ,\P  ,d#  ,(]  d X  .]#,_  ,  (/`]  ].]  rJ&..m.,',}]  ]R  \J  J.; -<&zOOT+%] .[] .}) J.] ,J>]   .P#0 ,_K  b] jG.6Y     //
//    d\  ,\F  ,?5""5J`  K;k  .]N,: .b   b ]  ],[  ]d"=<Jb..,{]  ]4(>,'  \.! ,,MM#i..)$ .[] .<: (.] .J{]    X40 ,~F .d:.,JJ^      //
//    d)  ,\F   !????   .D]S  .]N,! .X.  j.]  ],\  [MO\,-.((,`]  7""=   ,..~ ,=711+(. $ .[5<?,  J.] .j}] ,. ,;I .<F ,J"=>...      //
//    M)  ,)F           .j]k  .]N,_  r]  .L]  ],}  )b._]    ) ]        .<W._        . r  ???7`  P.] .z)] -]  bk .>F ,J4hx++jJ;    //
//    M}  ,}F           PM]k  .]N,!  ]j   q]  ],)  [b.<]    [ ]      .,1P,.{        . I        .tP] .O[] ,G  JK .zF ,d.R{  .W]    //
//    M}  ,}F          ,uE]R  .]N,! .],[  ,]  ],]  ]S.;]    [.++zOtru.J' ,.TO77T7777".I        (.b] .O%] ,(| .# .vF ,J.R{  .S]    //
//    M}  ,}F         .P# ]R  .]N,~ .t|S   ^  r,]  ]q.:]    )d""""^` ?""WHHHMHHMN@""!\I       .$tP] .I\] ,($  4 .>F ,J(D{   S]    //
//    M{  .{]  .....   hM.]R  .]N._ .[N,,     [.F  1,,;"7X  )d                  JF   %I       ,Z;b] .I[] ,JJ.   .)@ .k2Pl.  R]    //
//    M{  .}F  -nea,;  jdy]K  .]N,~ .r#;b     ] b  -,#HH]Z  [d                  JF   %I  F-_]  FFb] .I[] ,gb]   .\W  DNNQJ` R]    //
//    M{  ,{F  -d](/]  ,db[K  .]N,~ .$@6(.    ].W  .[O .<%  ]d                  JF   [I  ]]}j  UOD] .I[] ,JXj   .6J. ju JJ  D]    //
//    M_  ,:]  -d].]6   PN[b  .]N,~ .rF,/]    ]h(.  j.i%(   ]d                  JF   [v  ]](,  (,F]  r[] ,J(f;   0d| .2oh]  D]    //
//    M:  .{]  .d] b(   Xd%K  .]N,~ .rb bj.   tN,]   7.J!   $d                  JF   [z  F].,; ,cFF  $]] ,J`W6   Rbb  (u=   D]    //
//    M:  ,>F  -d] d,;  (J[@  .]N,~ .$@ (,]   ]W]W          $d                  J@   [z  F] )t  ]DF  $]] ,J_(d.  RHd        D]    //
//    M!  ,:F  Jd] ,/]  .P[b  .]M,~ .$@  ]j   ]Wj,[         %d                  J@   %1  F] \1  C ]  $%% ,J_ Dt  KrP]       D]    //
//    M~  ,:]  Jd] .]n   b`b  .]M,~ .tF  j,;  ]W Lj.     .] rd                  (@   %1  ]] (,. , F  ]]% ,J_ dj  b[((,   .R b]    //
//    M!  ,>F  (d]  D(.  d b  .]M,~ .0F  .]6  ]W ,c4.    yb $d                  (#   %j..F] ,,&../b..]]I.,J~ ,Pl.D] 6j, ./J(5]    //
//    M~  ,;5++dj]  q,=177!"7773M,777uN.  Q.wuaK  ,n7+..9JJvak                  ,N...Jggggh..gggggggggMHYYNgmHMMHN,..dgJ(d"""`    //
//    ?MNNMMMW""TMHHMMMMMMH""HH"""""7`?"""""7!`TNgJgNg&V""!`                                                      ?"7!            //
//                                                                                                                                //
//                                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract RDR is ERC721Creator {
    constructor() ERC721Creator("RING DE RING", "RDR") {}
}