// SPDX-License-Identifier: MIT
// Copyright 2023 SolidifyLabs
pragma solidity ^0.8.15;

import {FixedPricedMintPassForProjectIDRedeemer} from "solidifylabs/presets/MintPassRedeemer.sol";
import {ISellable} from "solidifylabs/sellers/interfaces/ISellable.sol";

import {Grails5} from "./Grails5.sol";
import {Grails5MintPass} from "./Grails5MintPass.sol";

/**
 * @title Grails V: Mint Pass Redeemer
 * @notice The mint pass redeemer for phase 2
 */
contract Grails5MintPassRedeemer is FixedPricedMintPassForProjectIDRedeemer {
    constructor(Grails5 sellable_, Grails5MintPass pass_, uint256 price)
        FixedPricedMintPassForProjectIDRedeemer(sellable_, pass_, price)
    {}
}