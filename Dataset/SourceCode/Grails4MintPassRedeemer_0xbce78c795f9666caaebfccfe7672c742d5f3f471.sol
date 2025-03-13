// SPDX-License-Identifier: MIT
// Copyright 2023 PROOF Holdings Inc
pragma solidity ^0.8.15;

import {
    MintPassForProjectIDRedeemer, FixedPricedMintPassForProjectIDRedeemer
} from "proof/presets/MintPassRedeemer.sol";
import {ISellable} from "proof/sellers/interfaces/ISellable.sol";

import {Grails4} from "./Grails4.sol";
import {Grails4MintPass} from "./Grails4MintPass.sol";

/**
 * @title Grails IV: Mint Pass Redeemer
 */
contract Grails4MintPassRedeemer is FixedPricedMintPassForProjectIDRedeemer {
    constructor(Grails4 sellable_, Grails4MintPass pass_, uint256 price)
        FixedPricedMintPassForProjectIDRedeemer(sellable_, pass_, price)
    {}
}