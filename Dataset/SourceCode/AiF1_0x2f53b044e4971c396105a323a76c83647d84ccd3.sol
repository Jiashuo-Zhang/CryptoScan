// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: AiFrica
/// @author: manifold.xyz

import "./ERC721Creator.sol";

////////////////////////////////////////////////////////
//                                                    //
//                                                    //
//    ,---.   .--.    .-''-.     .-'''-.              //
//    |    \  |  |  .'_ _   \   / _     \             //
//    |  ,  \ |  | / ( ` )   ' (`' )/`--'             //
//    |  |\_ \|  |. (_ o _)  |(_ o _).                //
//    |  _( )_\  ||  (_,_)___| (_,_). '.              //
//    | (_ o _)  |'  \   .---..---.  \  :             //
//    |  (_,_)\  | \  `-'    /\    `-'  |             //
//    |  |    |  |  \       /  \       /              //
//    '--'    '--'   `'-..-'    `-...-'               //
//    .-------.        ,-----.     _____     __       //
//    |  _ _   \     .'  .-,  '.   \   _\   /  /      //
//    | ( ' )  |    / ,-.|  \ _ \  .-./ ). /  '       //
//    |(_ o _) /   ;  \  '_ /  | : \ '_ .') .'        //
//    | (_,_).' __ |  _`,/ \ _/  |(_ (_) _) '         //
//    |  |\ \  |  |: (  '\_/ \   ;  /    \   \        //
//    |  | \ `'   / \ `"/  \  ) /   `-'`-'    \       //
//    |  |  \    /   '. \_/``".'   /  /   \    \      //
//    ''-'   `'-'      '-----'    '--'     '----'     //
//                                                    //
//                                                    //
//                                                    //
////////////////////////////////////////////////////////


contract AiF1 is ERC721Creator {
    constructor() ERC721Creator("AiFrica", "AiF1") {}
}