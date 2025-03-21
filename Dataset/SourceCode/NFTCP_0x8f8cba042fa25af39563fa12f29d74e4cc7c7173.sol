// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: NFT Catcher Podcast
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
//                                                                                                  //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$\,c$$$+`8M`````%`````>$$$$$*I`'`;$$$$|M$$+`````@&<`''"8$`I$$$I`$$^````l$[```"($$$$$$$$$    //
//    $$$(  ^f$; W* :MM&$BW ,B@$$$$u `v@8c$$$/~-8$@B^ %B8..r@%u$$ `***` $$.`vvv%$i n%: z$$$$$$$$    //
//    $$$( ]+.`` W* .``-$$8 :$$$$$$[ [$$$$$$r_M[]B$$^ @$n :$$$$$$ .^^". $$..^^"c$i '' ,@c'^-)($$    //
//    $$$( {$@[' W* l$$$$$8 :$$$$$$B" ;?+;Bv~z$&_{@$^ @$$l ,-_:M$ ^$$$^ $$..___}$i n/.^8" ^"i.#$    //
//    $$$#}*$$$$|%%}n$$$$$@}r$$$$$$$$#)?]j@c*$$$Mv&$t{$@$$&|?]/%@{t$$$t{$$1}}}}($u}8$M}(.."">`$$    //
//    $$$&uvcB$&uu*$$uvv#$$%vuz@$&z$$%vvzMvnv#$$B$cB$%8W8&$$$%%@u&@$@$$$$$$$$$$$$$$$$$$t'"/xtx$$    //
//    $$$nr$&[ut@$M{$?$$#{#)B$8@8)rn$/j*8$$?$$&Wfu1rn)jrnf#B@nnx}(|uz#WB$#B*%*$%W&8MB&$$$:^)$$$$    //
//    $$$n)uu%z|W8n|$-8&n|W)#8c%1nv)c#W*?B$?$$zj{|})1[1(\)rz#\t|][](ttjM$~%;${%x1[[]z]$$$x)*$$$$    //
//    $$$%%$$$$@M*%$$###B$$$M*8%%$$$WB#*%$$W$$@$M%fW%u**#z%$$W#W|uz%%$$$$%@%$@@B%B@%@B$$$M[r$$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$&@$$@8@@$$$@@$&$$$$$$$$$$$$$$$$$$$$$$$$$u*#$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$$$$@@B%88&&&&8%%B@$$$$$$$$$$$$$$$$$$$$$$@@B%8&&&&&&&8%B@$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$@%&Mzuxj\){}}{(tjnv*W8B@$$$$$$$$$$$$$@B8M*vxj/)}[][{(tjnc#W%B@$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$@%Wzx\_;"`''''''''''`,![fv#8B$$$$$$$$$B&*uf[l"`''''''''''`^,>1jv#8@$$$$$$$$$$$$    //
//    $$$$$$$$$@8#x(!^''''''''''.........',-tvM%$$$$@%Mvt_,''''`````````````''.`:]fcWB$$$$$$$$$$    //
//    $$$$$$$@%*r1,'.''''`,,,,,,,,^'........`!\uWB@BMu/i`.'``````";;li:;```````''.`~/v&@$$$$$$$$    //
//    $$$$$$@Wv|;'.'''':;"````````^::"........`_fz#cf_`.'``````+[_;`;,^";`````````'.^]r#%$$$$$$$    //
//    $$$$$@Wn)^..''',!``````````````^~.........l|/(I..````````/[,`",":i-:`````````'.'~f*%$$$$$$    //
//    $$$$@&v(^....',:````````````````<'..    ...;+:.'`````````}>;!!>>!!i<"``````````.'_f#B$$$$$    //
//    $$$$%*tI.....'_`````i,_--:<:""""!::I,,` ...',..``````:!i,(]-+I,^:I:;:^^`````````.'{nW$$$$$    //
//    $$$@Wu)'.....,,`````~,:`^`;^....,:l^:;'.......'`````,-""(]]-::^:^|-;l[``````````'.;t*$$$$$    //
//    $$$BMr?......:"`:,,-'.^,,:",;;:<.l '. ...'''..``````:;:if*>(_~;""">^I;```````````.^|v$$$$$    //
//    $$$B#r+'.....`I+'`"........l!^I(.i   ..''``'.'``````^,:;<\\}\{,,I^:`:"```````````.`|v$$$$$    //
//    $$$@Mx}'......-i`.`",.......'^`.';  ..''```'''```````````!|f-,:,"^""::^``````````'^\c$$$$$    //
//    $$$$8c\^'.....:""::^_...........>""..'```^`''''``````````>;n|:^:,",l~:"``'```````'lf*$$$$$    //
//    $$$$BMr?'......]````:]"'.....'",..^,'``^^^'`;''`````````![rj{;:l,:;l_-,,`'``````'`)u&$$$$$    //
//    $$$$$%*fi'...'^{`````l^`"^^"?`....I::^^^"``_]l''```````<-)//){I,"::l:`![i,:````'`]rMB$$$$$    //
//    $$$$$$%*j<`':`'+``````>`....;'.`"'...,!^'^{jrt<`'```^,>-x;r{*/[^^``````:+,I```'`?r#%$$$$$$    //
//    $$$$$$$%Mx{,'`:````````}^^^I),^'.,"...^`l/vW&#x}"'`!<~|])+|1MW}?i:```````^```',)nM%$$$$$$$    //
//    $$$$$$$$@&zr[,`````````_...",^....;''`l|x#%@$@&cf_"'"+r>>-{{_t}~]->```````'',]fz8@$$$$$$$$    //
//    $$$$$$$$$$B8*x\<,`'```:^.......'''`:]fvM8@$$$$$BWcj};``'``^:~}!``r-````''^l1rzWB$$$$$$$$$$    //
//    $$$$$$$$$$$$@%W*nf{<;,^`````^",I_(jv#&B@$$$$$$$$$B8#vj{>,^`''`'''^`'`^:~(rv#8B$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$@B%&#cvnxrrrxxuc*M&%@$@$$$$$$$$$$$$$$B%W*vxjt({[][{|tjnc#W%B@$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$v($$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$B1n;}$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$ux"|'_c$$$#cxvvzvvczjzxunnuz$#rc*vununrWuv%8r*$*z#cr&vux#*8vBzjzM$cnu*xunnzzM$$$$    //
//    $$$$@1v*ti(+\",|&$Wfj)|[\j{|x[r\r11/|@t(fj/&{$nuctj*v((#n{)(}cfu(\x\/\r-x/&j)xx}|11//u$$$$    //
//    $$$$u?:}ux,}u&fn$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$@@$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$    //
//                                                                                                  //
//                                                                                                  //
//                                                                                                  //
//                                                                                                  //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////


contract NFTCP is ERC721Creator {
    constructor() ERC721Creator("NFT Catcher Podcast", "NFTCP") {}
}