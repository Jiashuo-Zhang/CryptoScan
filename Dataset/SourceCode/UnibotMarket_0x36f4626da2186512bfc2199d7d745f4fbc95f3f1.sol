// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { SafeTransferLib, ERC20 } from "solmate/utils/SafeTransferLib.sol";
import { Owned } from "solmate/auth/Owned.sol";

contract UnibotMarket is Owned {
    address public immutable sellToken;
    address public immutable buyToken;

    uint256 public fee;

    uint256 public currentId;
    mapping(uint256 => MarketInfo) public markets;

    struct MarketInfo {
        uint128 price;
        uint128 amount;
        address seller;
        bool filled;
    }

    event MarketCreated(uint256 marketId, address seller, uint256 salePrice);
    event MarketFilled(uint256 marketId, address buyer, address seller, uint256 amountPaid);
    event MarketCanceled(uint256 marketId);

    constructor(address _sellToken, address _buyToken, uint256 _fee) Owned(msg.sender) {
        require(_sellToken != address(0) && _sellToken.code.length > 0);
        require(_buyToken != address(0) && _buyToken.code.length > 0);

        sellToken = _sellToken;
        buyToken = _buyToken;
        setFee(_fee);
    }

    /// @dev Doesn't tx tokens or verify approval. Make sure approval happens before market is filled
    function createMarket(uint128 amount, uint128 price) external {
        uint256 id = currentId++;
        markets[id] = MarketInfo(price, amount, msg.sender, false);

        emit MarketCreated(id, msg.sender, price);
    }

    function fillMarket(uint256 marketId) external {
        MarketInfo memory info = markets[marketId];
        require(!info.filled && info.seller != address(0));
        markets[marketId].filled = true;
        
        address seller = info.seller;
        uint256 buyFee = info.price * fee / 10_000;
        uint256 sellFee = info.amount * fee / 10_000;

        emit MarketFilled(marketId, msg.sender, seller, info.price);

        // Take fee on both sides
        SafeTransferLib.safeTransferFrom(ERC20(sellToken), seller, owner, sellFee);
        SafeTransferLib.safeTransferFrom(ERC20(sellToken), seller, msg.sender, info.amount - sellFee);
        
        SafeTransferLib.safeTransferFrom(ERC20(buyToken), msg.sender, owner, buyFee);
        SafeTransferLib.safeTransferFrom(ERC20(buyToken), msg.sender, info.seller, info.price - buyFee);
    }

    function cancelMarket(uint256 marketId) external {
        MarketInfo storage info = markets[marketId];
        require(msg.sender == info.seller && !info.filled);

        info.seller = address(0);

        emit MarketCanceled(marketId);
    }

    struct MarketView {
        MarketInfo info;
        bool finalized;
        uint256 approval;
        uint256 balance;
    }

    function getMarkets(uint256 start, uint256 end, bool onlyUnfilled)
        external
        view
        returns (MarketView[] memory _markets)
    {
        _markets = new MarketView[](end - start);
        uint256 i;

        for (; start < end; start++) {
            MarketInfo memory info = markets[start];
            bool finalized = info.filled;
            if (!onlyUnfilled || !finalized) {
                _markets[i] = MarketView({
                    info: info,
                    finalized: finalized,
                    approval: ERC20(sellToken).allowance(info.seller, address(this)),
                    balance: ERC20(sellToken).balanceOf(info.seller)
                });
                i++;
            }
        }

        // Modify length
        assembly {
            mstore(_markets, i)
        }
    }

    function setFee(uint256 _fee) public onlyOwner {
        // fee <= 2.5%
        require(_fee <= 250);
        fee = _fee;
    }
}