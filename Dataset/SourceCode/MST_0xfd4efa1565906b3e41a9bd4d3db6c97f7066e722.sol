// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Mista's 1/1
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////////////////////////////////////////////
//                                                                         //
//                                                                         //
//    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣨⣝⣙⣿⣿⣿⠟⢯⣹⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢄⣄⠀⠀⠀⠀⠀⠀    //
//    ⠀⠀⠀⠀⠀⠀⠀⢀⢀⢂⣬⣴⣿⢿⣻⠟⣫⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣗⣗⠀⠀⠀⠀⠀    //
//    ⠀⠀⠀⠀⠀⠀⢀⣀⠄⣼⠿⣫⢞⣯⣶⣿⣿⣿⣿⣿⣿⣿⢻⣽⣾⣟⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡍⣏⢮⡄⠂⡀⠀    //
//    ⠀⠀⠀⠀⠀⢰⣽⠕⣊⢵⣺⣽⣿⣿⣿⣿⣿⣿⡿⢿⣙⣾⣿⡿⣏⣾⡿⢯⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⡸⣿⣌⢹⣮⣁⠂    //
//    ⠀⠀⠀⠀⠀⡀⣠⣮⢶⣿⣿⣿⣿⣿⣿⡿⣿⢫⣝⣷⣟⡿⣯⣛⢾⡝⡵⢯⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⠿⢯⣞⣽⣋⠑    //
//    ⠀⠀⠀⢀⣲⡵⢿⣿⣿⣿⣿⣿⡿⣿⣫⠟⣥⡿⣛⣾⣫⡿⣕⡯⡳⢞⣭⣷⣿⣿⣿⣟⢾⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣵⣿⣿⣿⣿⣿⡿⣿⢻⣶⡟⣹    //
//    ⠀⠀⠐⠋⠀⢀⣾⣿⣿⣿⡿⣹⣽⠞⣥⡿⣋⢾⣽⡾⢫⢵⡯⣞⣽⣾⣿⣿⣿⣿⣻⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣾⣳⣏⠮    //
//    ⠀⠀⠀⠀⢠⣟⣾⠟⢹⡏⣵⠟⣡⡾⢋⣶⡽⢟⣱⣾⣿⣿⣿⣿⣿⣿⡿⣷⡿⢯⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⢽⣞⣿⣿⣿⣿⣾⣿⣾⣷    //
//    ⠀⠀⠀⡠⢟⡼⠃⢀⣿⡼⢃⣼⠛⣠⡿⣃⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⣟⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⢻⣿⣿⣾⣿⣿⣿    //
//    ⠀⠀⣠⡽⠋⠀⣰⡿⢣⠞⣫⣴⢻⣏⣿⣽⣿⣿⣿⣿⣿⣿⡿⣽⢣⣿⢋⣾⣿⣿⣿⣿⣳⣿⣽⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣞⣿⣿⣿⣿⣿⣿⣿⣿⣽⣯⣿⣿⣿⣿⣿⣿⡿    //
//    ⠀⠰⠋⠀⢀⡼⢋⢜⣥⣞⣯⣾⣷⣿⣿⣿⣿⢿⣻⣿⣿⡟⣵⢫⣟⣶⣿⣿⣿⣿⡿⣷⣿⣳⣿⣿⣿⣿⣿⢋⣿⣿⣿⣿⢳⣿⣿⣿⡾⣿⣿⣿⣿⣿⣿⣿⣷⣿⡿⣿⣿⣿⣿⣿⣏    //
//    ⠀⠀⠀⡤⢋⣴⢿⣯⣾⣿⣿⣿⣿⣿⣿⣿⢏⣼⣿⣿⠳⣼⡷⣻⣾⣿⣿⣿⣿⣟⢿⣿⡾⣿⣿⣿⣿⣿⣣⣳⣼⣿⣿⣿⠹⣾⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿    //
//    ⠀⠠⠀⣬⢫⢾⣿⣟⣿⣿⣿⣿⣿⣿⣿⢋⣼⣿⠿⣡⣿⣿⣾⣿⢿⣏⣿⣿⡟⣾⣿⡟⣴⣿⣿⣿⣿⡿⢿⡛⣏⣿⣿⢧⡛⣖⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⣿    //
//    ⠀⠠⠋⠐⠁⢸⡷⣾⢿⣿⣿⣿⣿⣿⢃⣾⠿⣩⣾⠿⣿⣯⡟⣽⡟⣾⣿⣷⣿⣿⡟⣜⣾⣿⣿⡿⢧⣛⣧⢻⠴⣿⣿⢣⡝⣬⢛⣿⣿⣿⣿⣿⢼⣿⣧⢾⣿⣿⣾⣿⡾⣿⣿⣿⣿    //
//    ⠀⠀⠀⠀⠀⣿⣵⢣⣛⣿⣿⣿⡿⢡⣾⣋⣾⡿⢭⣾⣿⣧⢻⡼⣽⡟⣿⣿⣿⠟⡸⢼⣿⣿⢿⡹⣏⣷⣾⢯⡿⣿⣟⢧⡞⣼⣙⢾⣿⣿⣿⣿⣿⢼⣿⣧⣿⣿⣿⣿⢿⡯⠜⣶⠀    //
//    ⠀⠀⠀⠀⢸⣿⠣⡗⣼⣿⣿⡿⣡⣿⣷⠟⣼⣼⣿⣷⣶⣿⣽⣿⣯⢼⣿⣿⠏⠐⠭⣿⣿⢯⢳⣿⣿⣿⡿⣿⣿⡿⣿⣿⣿⣏⢮⢏⣿⣿⣿⣿⣿⣻⣿⣿⣯⢿⣿⣷⡯⣿⣷⠨⠀    //
//    ⠀⠀⠀⠀⣸⢇⡻⣼⠟⣿⣿⡱⣽⣿⣿⠘⠋⠀⠠⠌⠈⠀⣿⠋⠙⣿⣿⠏⠀⠈⣸⣿⢏⠧⢃⠋⡑⢣⠙⡔⢣⠎⡝⢬⢋⡟⡬⢏⣿⣿⣿⣿⣿⣿⣽⣿⡿⣟⡷⣟⣿⣽⣿⡾⠀    //
//    ⠀⠈⠀⠠⢏⣲⣽⠋⠀⣿⡷⣽⣿⢹⣿⡃⠀⠀⠂⠀⠀⠀⠁⠀⠀⣿⡟⠀⠀⠀⡾⢉⠎⡘⠠⠀⠀⠡⠘⠠⠃⠜⡘⠦⡩⣜⡱⢏⡾⣿⣿⣿⣿⣿⣿⡿⡽⢯⣳⣿⣿⣿⣾⣽⢿    //
//    ⠀⢌⡀⠞⣰⠟⠁⠠⢐⣿⣽⡿⣿⠈⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⠟⠀⠀⠀⠈⠁⢌⠢⣁⠆⡁⠀⠀⠀⠀⠁⠂⢁⠒⡱⢢⡝⣹⢞⣿⣿⣿⣿⣿⣿⣟⡧⣿⡟⢯⣓⢮⡹⢿⣿    //
//    ⡘⠦⢀⠣⠋⣀⠊⠅⠨⣷⣿⠀⣯⠀⢹⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢨⡑⢆⡒⠄⠀⠀⠀⠀⠀⢀⠂⠥⣑⢣⡝⢮⢾⣿⣿⣿⣿⣿⣿⣾⣿⣿⣝⡳⡜⡶⣹⣍⠿    //
//    ⠈⠖⡈⢁⠂⠠⠈⠄⠐⣿⡟⠀⢄⠠⡀⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠰⡘⢦⡱⠀⠄⠀⠀⠀⠀⠄⢊⠴⢡⡓⣞⡹⣞⣿⣿⣿⣿⣿⣿⣿⣿⣿⢯⡷⣟⡷⣳⢎⡛    //
//    ⡈⠔⠠⢡⠈⢂⠡⢂⠐⣿⠇⡸⢠⢃⡖⡸⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣰⣣⣽⠚⡄⢣⠘⡠⢀⡀⠐⡈⢆⡍⢶⡹⢬⡳⣝⣻⣿⣿⣿⣷⣾⣿⣿⣿⢯⣻⡼⡱⢇⡯⣜    //
//    ⡜⣈⡁⢦⡌⢎⡆⢧⡒⢼⡸⢥⡓⣎⢶⡱⣿⣿⣆⠀⠀⠀⠀⠀⢀⡀⠀⠀⠈⠙⠻⠛⠁⠡⢈⣤⣱⣾⡿⠗⣢⠙⡔⣎⢧⣝⣣⢟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣭⣛⢯⣞⡵    //
//    ⡳⢥⡛⢦⣛⡞⣜⣣⡽⣲⡽⢧⣟⣮⢷⣻⣽⣿⣿⣧⡀⠀⠀⠀⠈⠙⢻⡉⠒⠒⠒⠒⠚⠛⠛⣩⡽⢏⡱⢊⠴⣙⠼⣜⣞⡲⣝⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣽    //
//    ⡟⣧⢻⢳⣯⡟⣾⣵⣯⣷⢻⣿⣾⣽⣿⢻⣯⣿⡟⣿⣿⣦⠀⠀⠀⠀⠀⠈⠓⠒⣶⢲⡖⠛⠉⢱⣼⠊⣴⢩⡞⣥⢻⡜⣶⣽⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⣿⡜⣯⣛⣾⣿⡿⣷⢿⣻⣟⣯⢷⣏⡯⣟⢾⣹⡟⣿⡿⣏⣷⣄⠀⠀⠀⠀⠀⠤⢤⢤⣴⡶⠿⣋⠇⡞⣥⢫⢶⡹⣎⣷⡿⣯⢷⣯⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⣿⣽⣷⣿⣿⣿⣿⣿⣿⣯⢿⣞⣯⢾⣵⣻⢾⣷⡿⢫⣴⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠐⠠⢎⡵⢮⡝⣮⢷⣟⣯⢷⢯⡷⣯⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⣿⣿⣿⣿⣿⣿⣿⡿⣷⣫⣷⢿⣞⡿⢋⣴⣿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀⠠⡌⣝⢮⡵⣯⢾⡽⣛⣾⢺⣽⣫⢷⣻⢾⡽⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⣿⣿⣿⣿⣿⣿⣿⣿⣷⣯⣟⣯⠟⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡖⠀⠤⢢⠳⠝⢮⡻⡼⣏⢷⡻⡽⣞⣻⡼⢯⣻⡽⢾⡽⣻⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⣿⣿⣿⣿⣿⣻⢯⡽⣱⢮⣹⢃⡔⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⣿⠀⠀⠀⠀⠈⠄⡱⠙⡜⢣⢟⡽⣞⢧⣟⢯⢷⡹⢧⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⠋⣍⢩⠎⣡⢎⡓⡐⠓⢻⣣⣞⢦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣛⡿⠁⠀⠀⠀⠀⠈⠐⠀⠁⠈⠠⡉⢞⠹⡚⣜⢫⣾⡿⣿⡿⣷⢻⣭⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⣛⡬⢃⣞⣥⢫⠗⡓⠦⡘⣿⢎⡷⣺⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⣼⣟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠁⢂⣥⣽⣿⡿⠷⠟⣝⠲⣏⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿    //
//    ⡛⠷⣟⣮⠖⠋⢄⠍⢦⡘⣯⢞⡵⣻⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⣹⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢄⣴⣟⡧⠞⢋⣀⠉⢜⣠⣭⣾⣿⣿⣿⣿⣿⣿⣿⣿⢿⣻⣽⣻⢾    //
//                                                                         //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////


contract MST is ERC721Creator {
    constructor() ERC721Creator("Mista's 1/1", "MST") {}
}