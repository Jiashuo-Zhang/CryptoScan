// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import { Forwarder } from "lib/gsn/packages/contracts/src/forwarder/Forwarder.sol";

/// @title Contract for minting SBT's that change based on performance metrics
/// @author bitbeckers
contract MintingForwarder is Forwarder {
    // solhint-disable-next-line const-name-snakecase
    string public constant name = "MintingForwarder";

    constructor() Forwarder() {}
}