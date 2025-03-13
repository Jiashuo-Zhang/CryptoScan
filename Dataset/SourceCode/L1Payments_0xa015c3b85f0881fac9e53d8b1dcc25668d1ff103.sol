// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Interfaces/IL1Payments.sol";
import "./CreditBundle.sol";
import "./LayerZero/LzApp.sol";

/**
 * @title Execute ETH payments on mainnet and receive them on L2
 *
 * @author Niftydude, Jack Chuma
 */
contract L1Payments is LzApp, IL1Payments {
    uint16 public immutable L2_CHAIN_ID;

    constructor(
        address _endpoint,
        address _admin,
        uint256 _l2ChainId
    ) LzApp(_admin) {
        if (_endpoint == address(0)) revert ZeroAddress();

        lzEndpoint = ILayerZeroEndpoint(_endpoint);

        L2_CHAIN_ID = uint16(_l2ChainId);
    }

    function estimateFees(
        uint64 _bundleId,
        uint256 _amount,
        uint256 _maxPrice,
        uint256 _gasForDestinationLzReceive
    ) external view returns (uint256 messageFee) {
        bytes memory payload = abi.encode(
            _bundleId,
            _amount,
            msg.sender,
            _maxPrice
        );

        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(
            version,
            _gasForDestinationLzReceive
        );

        (messageFee, ) = lzEndpoint.estimateFees(
            L2_CHAIN_ID,
            address(this),
            payload,
            false,
            adapterParams
        );
    }

    function purchaseCreditBundle(
        uint64 _bundleId,
        uint256 _amount,
        uint256 _maxPrice,
        uint256 _gasForDestinationLzReceive
    ) external payable {
        if (msg.value <= _maxPrice) revert InsufficientPayment();

        bytes memory payload = abi.encode(
            _bundleId,
            _amount,
            msg.sender,
            _maxPrice
        );

        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(
            version,
            _gasForDestinationLzReceive
        );

        _lzSend(
            L2_CHAIN_ID,
            payload,
            payable(msg.sender),
            address(0x0),
            adapterParams,
            msg.value - _maxPrice
        );

        uint256 _nonce = lzEndpoint.getOutboundNonce(
            L2_CHAIN_ID,
            address(this)
        );

        emit BundlePurchaseInitiated(
            _nonce,
            _bundleId,
            msg.sender,
            _amount,
            msg.value
        );
    }

    /**
     * @notice withdraw eth balance to a given address
     *
     * @param _receiver the receiving address
     * @param _amount amount to withdrawin wei
     */
    function withdrawETH(
        address _receiver,
        uint256 _amount
    ) external onlyRole(ADMIN_ROLE) {
        if (_receiver == address(0)) revert ZeroAddress();
        if (address(this).balance < _amount) revert InsufficientBalance();

        (bool sent, ) = _receiver.call{value: _amount}("");
        if (!sent) revert TransferFailed();

        emit ETHWithdrawn(_receiver, _amount);
    }
}