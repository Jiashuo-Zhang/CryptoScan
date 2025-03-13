// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @author Syky - Nathan Rempel

/*
           @@@   @@@@@   @@@@@@@         @@@@    @@@@@@@      @@@@@     @@@@@@@        @@@@
         @@@@      @@@     @@@@@@        @@       @@@@@@       @@        @@@@@@        @@
         @@@@@      @@      @@@@@       @@        @@@@@       @            @@@@@      @@
         @@@@@@      @@      @@@@@     @@         @@@@@     @               @@@@     @@
          @@@@@@      @       @@@@@   @@          @@@@@    @                @@@@@    @
           @@@@@@@             @@@@@ @@           @@@@@  @@@                 @@@@@  @
             @@@@@@             @@@@@@            @@@@@@@@@@@                 @@@@@@
               @@@@@@           @@@@@             @@@@@  @@@@@                 @@@@@
                @@@@@@@         @@@@@             @@@@@   @@@@@                @@@@@
         @        @@@@@@        @@@@@             @@@@@    @@@@@               @@@@@
         @@        @@@@@        @@@@@             @@@@@     @@@@@              @@@@@
         @@@@      @@@@@        @@@@@             @@@@@@     @@@@@@           @@@@@@
         @@@@@@   @@@@         @@@@@@@           @@@@@@@     @@@@@@@          @@@@@@@
*/

import "../base/ProductMarket.sol";

contract SykyMarket is ProductMarket {
    /*//////////////////////////////////////////////////////////////
                            Version Info
    //////////////////////////////////////////////////////////////*/

    string public constant ENV = "MAINNET";
    string public constant VER = "1.0.1";

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(
        address defaultAdmin_,
        address defaultToken_,
        address vipContract_
    ) ProductMarket(defaultAdmin_, defaultToken_, vipContract_) {}
}