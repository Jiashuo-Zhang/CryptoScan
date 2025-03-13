// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import '../interfaces/IRelativePriceProvider.sol';
import './DynamicAsset.sol';

interface IStakeManager {
    function getStETHByWstETH(uint256 _wstETHAmount) external view returns (uint256);
}

/**
 * @title Asset with Dynamic Price
 * @notice Contract presenting an asset in a pool
 * @dev The relative price of an asset may change over time.
 * On mainnet, we can directly get the ratio from wstETH contract, without oracles.
 */
contract WstETHAsset_Mainnet is DynamicAsset {
    IStakeManager stakeManager;

    constructor(
        address underlyingToken_,
        string memory name_,
        string memory symbol_,
        IStakeManager _stakeManager
    ) DynamicAsset(underlyingToken_, name_, symbol_) {
        stakeManager = _stakeManager;
    }

    /**
     * @notice get the relative price in WAD
     */
    function getRelativePrice() external view override returns (uint256) {
        return stakeManager.getStETHByWstETH(1e18);
    }
}