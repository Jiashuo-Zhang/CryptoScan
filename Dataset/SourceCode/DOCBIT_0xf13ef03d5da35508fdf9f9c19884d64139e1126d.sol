// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: FREERIZZN
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//                                                                                   //
//    MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWNNNNNNNWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMMMMMMMMMWNNXKK00OOOOOOOOOOO00KKXNNWMMMMMMMMMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMMMMWWNK0OOkkxxxxxxxxxxxxxxxxxxxkkOO0KXWWMMMMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMWNX0OkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkO0XNWMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMWNX0kxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkk0XNWMMMMMMMMMMMMM    //
//    MMMMMMMMMMMWNKOkxxxxxxxxxkkxxxxxkkkkxxxxxxxxxxxxxxxxxxxxxxxkOKNWMMMMMMMMMMM    //
//    MMMMMMMMMWN0kxxxxxxxxxk0XXXKkxk0XXX0kxxxxxxxxxxxxxxxxxxxxxxxxxk0XWMMMMMMMMM    //
//    MMMMMMMMNKkxxxxxxxxxxxkKWMMNOxkXWMMXkxxxxxxxxxxxxxxxxxxxxxxxxxxxkKNWMMMMMMM    //
//    MMMMMMWXOxxxxxxxxxxxxxkKWMMXOxkXMMMXkxxxxxxxxxxxxxxxxxxxxxxxxxxxxkOXWMMMMMM    //
//    MMMMMWKkxxxxxxkOOOOOOOOXWMMN000XMMMN0OOkkkxxxxxxxxxxxxxxxxxxxxxxxxxkKWMMMMM    //
//    MMMMWKkxxxxxxx0NWWWWWWWWMMMMWWWMMMMMWWWNNXK0OkxxxxxxxxxxxxxxxxxxxxxxkKNMMMM    //
//    MMMWKkxxxxxxxx0NWMMMMMMMMMMMMMMMMMMMMMMMMMMWNKOxxxxxxxxxxxxxxxxxxxxxxkKWMMM    //
//    MMWKkxxxxxxxxxkO000KWMMMMMMWX00KKKKXNWWMMMMMMWXOxxxxxxxxxxxxxxxxxxxxxxkKWMM    //
//    MWXOxxxxxxxxxxxxxxxkXWMMMMMNOxxxxxxkOOKWMMMMMMW0kxxxxxxxxxxxxxxxxxxxxxxOXMM    //
//    MN0kxxxxxxxxxxxxxxxkKWMMMMMNOxxxxxxxxxOXMMMMMMW0kxxxxxxxxxxxxxxxxxxxxxxx0WM    //
//    MXOxxxxxxxxxxxxxxxxkKWMMMMMNOxxxxxxxkOKNMMMMMMNOxxxxxxxxxxxxxxxxxxxxxxxxOXW    //
//    WKkxxxxxxxxxxxxxxxxkKWMMMMMWKOO000KXNWWMMMMMWXOxxxxxxxxxxxxxxxxxxxxxxxxxkKW    //
//    W0xxxxxxxxxxxxxxxxxkKWMMMMMMWWWWWMMMMMMMMMMMNKOkxxxxxxxxxxxxxxxxxxxxxxxxx0N    //
//    N0xxxxxxxxxxxxxxxxxkKWMMMMMMWNNNWWWWMMMMMMMMMMWN0kxxxxxxxxxxxxxxxxxxxxxxx0N    //
//    N0xxxxxxxxxxxxxxxxxkKWMMMMMN0OOkOOOO00KXWMMMMMMMWKkxxxxxxxxxxxxxxxxxxxxxxON    //
//    N0xxxxxxxxxxxxxxxxxkKWMMMMMNOxxxxxxxxxxk0NMMMMMMMNOxxxxxxxxxxxxxxxxxxxxxx0N    //
//    WKkxxxxxxxxxxxxxxxxkKWMMMMMN0xxxxxxxxxxxkXMMMMMMMNOxxxxxxxxxxxxxxxxxxxxxkKW    //
//    MXOxxxxxxxxxxxxxxxxkKWMMMMMN0xxxxxxxxxkkKWMMMMMMWXOxxxxxxxxxxxxxxxxxxxxxOXM    //
//    MN0kxxxxxxxxxxxkOOO0NMMMMMMWKOOOO000KKXNWMMMMMMMW0kxxxxxxxxxxxxxxxxxxxxx0WM    //
//    MWXOxxxxxxxxxxkKNWWWMMMMMMMMWWWWWWWMMMMMMMMMMMMMWXOkxxkO00OxxxxxxxxxxxxOXMM    //
//    MMWKkxxxxxxxxxOXMMMMMMMMMMMMMMMMMMMMMMMMWWWNXNWMMMWXOOKNWWN0kxxxxxxxxxkKWMM    //
//    MMMN0kxxxxxxxxk0KKKKKKKNWMMWXKKNMMMWXKK00OOkkk0NWMMMWWWMMWN0kxxxxxxxxkKWMMM    //
//    MMMMNKkxxxxxxxxxxxxxxxx0WMMNOxkKWMMNOxxxxxxxxxxk0NMMMMMMWKOxxxxxxxxxkKWMMMM    //
//    MMMMMWKkxxxxxxxxxxxxxxx0WMMNOxkKWMMNOxxxxxxxxxkOKWMMMMMMWXOkxxxxxxxkKWMMMMM    //
//    MMMMMMWXOkxxxxxxxxxxxxx0NWWNOxk0WWWXOxxxxxxxxkKNWMMWNNWMMMNKkxxxxkOXWMMMMMM    //
//    MMMMMMMMNKOxxxxxxxxxxxxkOOOOkxxkOOOOkxxxxxxxxkKNWWNKOO0NWWX0kxxxOKNMMMMMMMM    //
//    MMMMMMMMMWN0kxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkOK0Oxxxxk0Okxxxk0NWMMMMMMMMM    //
//    MMMMMMMMMMMWX0OkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkOKNWMMMMMMMMMMM    //
//    MMMMMMMMMMMMMWNX0kkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkk0XNWMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMWNK0OkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkO0KNWMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMMMMWWNK0OkkkxxxxxxxxxxxxxxxxxxxkkOO0KXWWMMMMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMMMMMMMMMWNNXKK00OOOOOOOOOOO00KKXNNWMMMMMMMMMMMMMMMMMMMMMMMM    //
//    MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWNNNNNNNWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM    //
//                                                                                   //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////


contract DOCBIT is ERC1155Creator {
    constructor() ERC1155Creator("FREERIZZN", "DOCBIT") {}
}