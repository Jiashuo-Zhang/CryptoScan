// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";

contract PaymentProcessor {
    // Event to be emitted after a payment is processed
    event PaymentProcessed(uint256 indexed orderId, bytes32 hash);

    // Mapping to store the hash of amounts and recipients for each Order ID
    mapping(uint256 => bytes32) private orderHashes;

    // Address of the PYUSD token
    address private PYUSD_ADDRESS;

    // Constructor to set the PYUSD token address
    constructor(address _pyusdAddress) {
        PYUSD_ADDRESS = _pyusdAddress;
    }

    // Function to process a payment
    function processPayment(
        uint256 orderId,
        uint256[] memory amounts,
        address[] memory recipients
    ) external {
        require(
            amounts.length == recipients.length,
            "Amounts and recipients length mismatch"
        );
        require(
            orderHashes[orderId] == bytes32(0),
            "Order ID already used"
        );
        bytes32 hash = keccak256(
            abi.encodePacked(orderId, amounts, recipients)
        );
        orderHashes[orderId] = hash;
        IERC20 pyusd = IERC20(PYUSD_ADDRESS);

        for (uint256 i = 0; i < amounts.length; i++) {
            // Ensure that the token transfer is successful
            require(
                pyusd.transferFrom(msg.sender, recipients[i], amounts[i]),
                "Transfer failed"
            );
        }

        emit PaymentProcessed(orderId, hash);
    }

    // Function to get the hash of amounts and recipients for a given Order ID
    function getOrderHash(uint256 orderId) external view returns (bytes32) {
        return orderHashes[orderId];
    }
}