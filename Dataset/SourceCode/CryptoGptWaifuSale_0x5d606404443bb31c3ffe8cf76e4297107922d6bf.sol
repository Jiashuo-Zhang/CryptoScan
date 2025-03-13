// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import "../RefundableNftSale.sol";

contract CryptoGptWaifuSale is RefundableNftSale {
    constructor(
        address _nftToken,
        address _paymentToken,
        uint256 _startTime,
        uint256 _price,
        uint256 _refundTimeLimit
    )
        RefundableNftSale(
            _nftToken,
            _paymentToken,
            _startTime,
            _startTime + 4 days,
            _price,
            _refundTimeLimit
        )
    {}
}