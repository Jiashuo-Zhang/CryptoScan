// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract superkek is ERC20, Ownable {
    IUniswapV2Router02 private uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 private constant ONE_HOUR = 3600;
    uint256 private constant ONE_DAY = 24 * ONE_HOUR;
    uint256 private lotteryStartTime;

    constructor() ERC20("SuperKEK", "SKEK") {
        _mint(msg.sender, 69000000000000 * 10**decimals());
        lotteryStartTime = block.timestamp;
    }

    function nextWindowStart(address seller) public view returns (uint256) {
        uint256 dayOffset = (block.timestamp - lotteryStartTime) / ONE_DAY;
        bytes32 hash = keccak256(abi.encodePacked(seller, dayOffset));
        uint256 windowOffset = (uint256(hash) % 24);
        uint256 windowStart = lotteryStartTime + dayOffset * ONE_DAY + windowOffset * ONE_HOUR;

        // If the current window has ended, move to the next day and calculate a new random window
        if (block.timestamp > windowStart + 1 hours) {
            dayOffset += 1;
            hash = keccak256(abi.encodePacked(seller, dayOffset));
            windowOffset = (uint256(hash) % 24);
            windowStart = lotteryStartTime + dayOffset * ONE_DAY + windowOffset * ONE_HOUR;
        }

        return windowStart;
    }

    // owner has permissions to transfer so that they can create LP token, then ownership is renounced
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0)) { // Exclude minting
            uint256 nextWindow = nextWindowStart(from);
            uint256 currentTime = block.timestamp;

            address uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).getPair(address(this), uniswapRouter.WETH());

            // Check if it's a sell on Uniswap or a transfer between wallets, and not the owner
            if (from != owner() && (to == uniswapPair || (from != uniswapPair && to != uniswapPair))) {
                require(currentTime >= nextWindow && currentTime < nextWindow + 1 hours, "SUPERKEK: Not in the allowed window for selling/transferring");
            }
        }
    }
}