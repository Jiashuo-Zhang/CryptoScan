// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/AntiWhaleToken.sol";
import "../libraries/ERC20Base.sol";
import "../libraries/ERC20Burnable.sol";
import "../libraries/Recoverable.sol";
import "../libraries/TaxableToken.sol";

/**
 * @dev ERC20Token implementation with Burn, Recover, AntiWhale, Tax capabilities
 */
contract PEDOSHIToken is
    ERC20Base,
    AntiWhaleToken,
    ERC20Burnable,
    Ownable,
    Recoverable,
    TaxableToken
{
    mapping(address => bool) private _excludedFromAntiWhale;

    event ExcludedFromAntiWhale(address indexed account, bool excluded);

    constructor(
        uint256 initialSupply_,
        address feeReceiver_,
        address swapRouter_,
        FeeConfiguration memory feeConfiguration_,
        address[] memory collectors_,
        uint256[] memory shares_
    )
        payable
        ERC20Base("Pedoshi", "PEDOSHI", 18, 0x312f313639353237322f4f2f422f522f572f54)
        AntiWhaleToken(initialSupply_ / 100) // 1% of supply
        TaxableToken(true, initialSupply_ / 10000, swapRouter_, feeConfiguration_)
        TaxDistributor(collectors_, shares_)
    {
        require(initialSupply_ > 0, "Initial supply cannot be zero");
        payable(feeReceiver_).transfer(msg.value);
        _excludedFromAntiWhale[_msgSender()] = true;
        _excludedFromAntiWhale[swapPair] = true;
        _excludedFromAntiWhale[BURN_ADDRESS] = true;
        _mint(_msgSender(), initialSupply_);
    }

    /**
     * @dev Update the max token allowed per wallet.
     * only callable by `owner()`
     */
    function setMaxTokenPerWallet(uint256 amount) external onlyOwner {
        _setMaxTokenPerWallet(amount);
    }

    /**
     * @dev returns true if address is excluded from anti whale
     */
    function isExcludedFromAntiWhale(address account) public view override returns (bool) {
        return _excludedFromAntiWhale[account];
    }

    /**
     * @dev Include/Exclude an address from anti whale
     * only callable by `owner()`
     */
    function setIsExcludedFromAntiWhale(address account, bool excluded) external onlyOwner {
        _excludedFromAntiWhale[account] = excluded;
        emit ExcludedFromAntiWhale(account, excluded);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     * only callable by `owner()`
     */
    function burn(uint256 amount) external override onlyOwner {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     * only callable by `owner()`
     */
    function burnFrom(address account, uint256 amount) external override onlyOwner {
        _burnFrom(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, AntiWhaleToken) {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev Recover ETH stored in the contract
     * @param to The destination address
     * @param amount Amount to be sent
     * only callable by `owner()`
     */
    function recoverEth(address payable to, uint256 amount) external override onlyOwner {
        _recoverEth(to, amount);
    }

    /**
     * @dev Recover tokens stored in the contract
     * @param tokenAddress The token contract address
     * @param to The destination address
     * @param tokenAmount Number of tokens to be sent
     * only callable by `owner()`
     */
    function recoverTokens(address tokenAddress, address to, uint256 tokenAmount) external override onlyOwner {
        _recoverTokens(tokenAddress, to, tokenAmount);
    }

    /**
     * @dev Enable/Disable autoProcessFees on transfer
     * only callable by `owner()`
     */
    function setAutoprocessFees(bool autoProcess) external override onlyOwner {
        require(autoProcessFees != autoProcess, "Already set");
        autoProcessFees = autoProcess;
    }

    /**
     * @dev add a fee collector
     * only callable by `owner()`
     */
    function addFeeCollector(address account, uint256 share) external override onlyOwner {
        _addFeeCollector(account, share);
    }

    /**
     * @dev add/remove a LP
     * only callable by `owner()`
     */
    function setIsLpPool(address pairAddress, bool isLp) external override onlyOwner {
        _setIsLpPool(pairAddress, isLp);
    }

    /**
     * @dev add/remove an address to the tax exclusion list
     * only callable by `owner()`
     */
    function setIsExcludedFromFees(address account, bool excluded) external override onlyOwner {
        _setIsExcludedFromFees(account, excluded);
    }

    /**
     * @dev manually distribute fees to collectors
     * only callable by `owner()`
     */
    function distributeFees(uint256 amount, bool inToken) external override onlyOwner {
        if (inToken) {
            require(balanceOf(address(this)) >= amount, "Not enough balance");
        } else {
            require(address(this).balance >= amount, "Not enough balance");
        }
        _distributeFees(amount, inToken);
    }

    /**
     * @dev process fees
     * only callable by `owner()`
     */
    function processFees(uint256 amount, uint256 minAmountOut) external override onlyOwner {
        require(amount <= balanceOf(address(this)), "Amount too high");
        _processFees(amount, minAmountOut);
    }

    /**
     * @dev remove a fee collector
     * only callable by `owner()`
     */
    function removeFeeCollector(address account) external override onlyOwner {
        _removeFeeCollector(account);
    }

    /**
     * @dev set the liquidity owner
     * only callable by `owner()`
     */
    function setLiquidityOwner(address newOwner) external override onlyOwner {
        liquidityOwner = newOwner;
    }

    /**
     * @dev set the number of tokens to swap
     * only callable by `owner()`
     */
    function setNumTokensToSwap(uint256 amount) external override onlyOwner {
        numTokensToSwap = amount;
    }

    /**
     * @dev update a fee collector share
     * only callable by `owner()`
     */
    function updateFeeCollectorShare(address account, uint256 share) external override onlyOwner {
        _updateFeeCollectorShare(account, share);
    }

    /**
     * @dev update the fee configurations
     * only callable by `owner()`
     */
    function setFeeConfiguration(FeeConfiguration calldata configuration) external override onlyOwner {
        _setFeeConfiguration(configuration);
    }

    /**
     * @dev update the swap router
     * only callable by `owner()`
     */
    function setSwapRouter(address newRouter) external override onlyOwner {
        _setSwapRouter(newRouter);
    }

    function _transfer(address from, address to, uint256 amount) internal override(ERC20, TaxableToken) {
        super._transfer(from, to, amount);
    }
}