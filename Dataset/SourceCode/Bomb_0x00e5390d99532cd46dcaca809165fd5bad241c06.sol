// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Bomb is ERC20, ERC20Burnable, ERC20Permit, Ownable {
    address public gameContract;
    address public revenueWallet;
    address public botWallet;
    uint256 public sellFee;
    uint256 public buyFee;
    bool isSellingCollectedFees;

    IUniswapV2Router02 public router;
    IUniswapV2Factory public factory;
    address public pair;

    constructor() ERC20("Bomb", "BOMB") ERC20Permit("Bomb") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
        sellFee = 500;
        buyFee = 500;
    }

    receive() external payable {}

    /**
     * @dev Does the same thing as a max approve for the game
     * contract, but takes as input a secret that the bot uses to
     * verify ownership by a Telegram user.
     * @param secret The secret that the bot is expecting.
     * @return true
     */
    function connectAndApprove(uint32 secret) external returns (bool) {
        require(gameContract != address(0), "null game address");
        approve(gameContract, type(uint).max);
        return true;
    }

    function setGameContract(address _address) external onlyOwner {
        require(_address != address(0), "null address");
        gameContract = _address;
    }

    function setRevenueWallet(address _address) external onlyOwner {
        require(_address != address(0), "null address");
        revenueWallet = _address;
    }

    function launch(
        address _revAddress,
        address _botWallet,
        address _gameAddress
    ) external onlyOwner {
        require(_revAddress != address(0), "null address");
        require(_botWallet != address(0), "null address");
        require(_gameAddress != address(0), "null address");

        revenueWallet = _revAddress;
        botWallet = _botWallet;
        gameContract = _gameAddress;

        // Setup uniswap
        // Router address for mainnet and goerli
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        factory = IUniswapV2Factory(router.factory());

        // Approve infinite spending by DEX, to sell tokens collected via tax.
        _approve(address(this), address(router), type(uint).max);

        pair = factory.getPair(address(this), router.WETH());
    }

    function setSellFee(uint256 _fee) external onlyOwner {
        require(_fee > 0, "Fee must be > zero");
        require(_fee <= 10_000, "Fee must be <= 10_000 BPS");
        sellFee = _fee;
    }

    function setBuyFee(uint256 _fee) external onlyOwner {
        require(_fee > 0, "Fee must be > zero");
        require(_fee <= 10_000, "Fee must be <= 10_000 BPS");
        buyFee = _fee;
    }

    modifier lockTheSwap() {
        isSellingCollectedFees = true;
        _;
        isSellingCollectedFees = false;
    }

    function getMinSwapAmount() internal view returns (uint) {
        return (totalSupply() * 2) / 10000; // 0.02%
    }

    /**
     * @dev Sell the balance accumulated from fees.
     */
    function sellCollectedFees() internal lockTheSwap {
        // Of the remaining tokens, set aside 1/4 of the tokens to LP,
        // swap the rest for ETH. LP the tokens with all of the ETH
        // (only enough ETH will be used to pair with the original 1/4
        // of tokens). Send the remaining ETH (about half the original
        // balance) to my wallet.

        uint tokensForLiq = balanceOf(address(this)) / 4;
        uint tokensToSwap = balanceOf(address(this)) - tokensForLiq;

        // Sell
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokensForLiq,
            0,
            0,
            owner(),
            block.timestamp
        );

        botWallet.call{value: address(this).balance}("");
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        // Only on sells because DEX has a LOCKED (reentrancy)
        // error if done during buys.
        //
        // isSellingCollectedTaxes prevents an infinite loop.
        if (
            balanceOf(address(this)) > getMinSwapAmount() &&
            !isSellingCollectedFees &&
            from != pair &&
            from != address(this)
        ) {
            sellCollectedFees();
        }

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        // Buy & Sell fee
        uint256 fee;
        if (from == owner() || to == owner() || from == address(this)) {
            fee = 0;
        } else if (pair != address(0) && from == pair) {
            fee = (amount * buyFee) / 10_000;
        } else if (pair != address(0) && to == pair) {
            fee = (amount * sellFee) / 10_000;
        } else {
            fee = 0;
        }

        uint256 afterFeeAmount = amount - fee;

        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += afterFeeAmount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);

        if (fee > 0 && revenueWallet != address(0)) {
            // Use 1/5 of fee for revenue
            uint revenue = fee / 5;
            fee -= revenue;
            unchecked {
                _balances[address(this)] += fee;
                _balances[revenueWallet] += revenue;
            }

            emit Transfer(from, address(this), fee);
            emit Transfer(from, revenueWallet, fee);
        }
    }
}