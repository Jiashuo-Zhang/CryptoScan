// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import { CometPrePay } from "../extensions/CometPrePay.sol";

/**
 * @dev This implements an optional extension of {CometPrePay}
 */
contract ShatnerCosmicExplorerPrePay is CometPrePay {
    /**
     * @notice Comet PrePay constructor.
     *
     * @param initialMaxSupply The max supply of the sale.
     * @param price The price of an item.
     * @param slug The slug of the collection.
     */
    constructor(
        uint256 initialMaxSupply,
        uint256 price,
        string memory slug
    ) CometPrePay(initialMaxSupply, price, slug) {}
}