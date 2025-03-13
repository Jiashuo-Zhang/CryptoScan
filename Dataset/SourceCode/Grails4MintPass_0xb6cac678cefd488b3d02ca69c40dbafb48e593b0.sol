// SPDX-License-Identifier: MIT
// Copyright 2023 PROOF Holdings Inc
pragma solidity ^0.8.15;

import {ERC721ACommon, BaseTokenURI} from "ethier/erc721/BaseTokenURI.sol";

import {SellableRedeemableRestrictableERC721} from "proof/presets/SellableRedeemableRestrictableERC721.sol";

/**
 * @title Grails IV: Mint Pass
 */
contract Grails4MintPass is SellableRedeemableRestrictableERC721 {
    constructor(address admin, address steerer, address payable secondaryReceiver)
        ERC721ACommon(admin, steerer, "Grails IV: Mint Pass", "G4PASS", secondaryReceiver, 500)
        BaseTokenURI("https://metadata.proof.xyz/grails-iv/pass/")
    {}
}