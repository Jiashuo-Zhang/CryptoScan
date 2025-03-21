// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: M A D K 1 N G 5
/// @author: manifold.xyz

import "./ERC721Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                            //
//                                                                                                            //
//              _____                    _____                    _____                    _____              //
//             /\    \                  /\    \                  /\    \                  /\    \             //
//            /::\____\                /::\    \                /::\    \                /::\____\            //
//           /::::|   |               /::::\    \              /::::\    \              /:::/    /            //
//          /:::::|   |              /::::::\    \            /::::::\    \            /:::/    /             //
//         /::::::|   |             /:::/\:::\    \          /:::/\:::\    \          /:::/    /              //
//        /:::/|::|   |            /:::/__\:::\    \        /:::/  \:::\    \        /:::/____/               //
//       /:::/ |::|   |           /::::\   \:::\    \      /:::/    \:::\    \      /::::\    \               //
//      /:::/  |::|___|______    /::::::\   \:::\    \    /:::/    / \:::\    \    /::::::\____\________      //
//     /:::/   |::::::::\    \  /:::/\:::\   \:::\    \  /:::/    /   \:::\ ___\  /:::/\:::::::::::\    \     //
//    /:::/    |:::::::::\____\/:::/  \:::\   \:::\____\/:::/____/     \:::|    |/:::/  |:::::::::::\____\    //
//    \::/    / ~~~~~/:::/    /\::/    \:::\  /:::/    /\:::\    \     /:::|____|\::/   |::|~~~|~~~~~         //
//     \/____/      /:::/    /  \/____/ \:::\/:::/    /  \:::\    \   /:::/    /  \/____|::|   |              //
//                 /:::/    /            \::::::/    /    \:::\    \ /:::/    /         |::|   |              //
//                /:::/    /              \::::/    /      \:::\    /:::/    /          |::|   |              //
//               /:::/    /               /:::/    /        \:::\  /:::/    /           |::|   |              //
//              /:::/    /               /:::/    /          \:::\/:::/    /            |::|   |              //
//             /:::/    /               /:::/    /            \::::::/    /             |::|   |              //
//            /:::/    /               /:::/    /              \::::/    /              \::|   |              //
//            \::/    /                \::/    /                \::/____/                \:|   |              //
//             \/____/                  \/____/                  ~~                       \|___|              //
//                                                                                                            //
//              _____                    _____                    _____                    _____              //
//             /\    \                  /\    \                  /\    \                  /\    \             //
//            /::\    \                /::\    \                /::\____\                /::\    \            //
//           /::::\    \              /::::\    \              /::::|   |                \:::\    \           //
//          /::::::\    \            /::::::\    \            /:::::|   |                 \:::\    \          //
//         /:::/\:::\    \          /:::/\:::\    \          /::::::|   |                  \:::\    \         //
//        /:::/__\:::\    \        /:::/  \:::\    \        /:::/|::|   |                   \:::\    \        //
//        \:::\   \:::\    \      /:::/    \:::\    \      /:::/ |::|   |                   /::::\    \       //
//      ___\:::\   \:::\    \    /:::/    / \:::\    \    /:::/  |::|   | _____    ____    /::::::\    \      //
//     /\   \:::\   \:::\    \  /:::/    /   \:::\ ___\  /:::/   |::|   |/\    \  /\   \  /:::/\:::\    \     //
//    /::\   \:::\   \:::\____\/:::/____/  ___\:::|    |/:: /    |::|   /::\____\/::\   \/:::/  \:::\____\    //
//    \:::\   \:::\   \::/    /\:::\    \ /\  /:::|____|\::/    /|::|  /:::/    /\:::\  /:::/    \::/    /    //
//     \:::\   \:::\   \/____/  \:::\    /::\ \::/    /  \/____/ |::| /:::/    /  \:::\/:::/    / \/____/     //
//      \:::\   \:::\    \       \:::\   \:::\ \/____/           |::|/:::/    /    \::::::/    /              //
//       \:::\   \:::\____\       \:::\   \:::\____\             |::::::/    /      \::::/____/               //
//        \:::\  /:::/    /        \:::\  /:::/    /             |:::::/    /        \:::\    \               //
//         \:::\/:::/    /          \:::\/:::/    /              |::::/    /          \:::\    \              //
//          \::::::/    /            \::::::/    /               /:::/    /            \:::\    \             //
//           \::::/    /              \::::/    /               /:::/    /              \:::\____\            //
//            \::/    /                \::/____/                \::/    /                \::/    /            //
//             \/____/                                           \/____/                  \/____/             //
//                                                                                                            //
//                                                                                                            //
//                                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract MK is ERC721Creator {
    constructor() ERC721Creator("M A D K 1 N G 5", "MK") {}
}