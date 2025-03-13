// SPDX-License-Identifier: BUSL-1.1
// Licensor: Flashstake DAO
// Licensed Works: (this contract, source below)
// Change Date: The earlier of 2026-12-01 or a date specified by Flashstake DAO publicly
// Change License: GNU General Public License v2.0 or later
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/Flashstake/IFlashStrategy.sol";
import "./interfaces/Flashstake/IFlashFToken.sol";
import "./interfaces/RocketPool/RocketStorageInterface.sol";
import "./interfaces/RocketPool/RocketDepositPoolInterface.sol";
import "./interfaces/RocketPool/RocketTokenRETHInterface.sol";
import "./interfaces/IWETH.sol";

contract FlashStrategyRocketPool is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;

    event BurnedFToken(address indexed _address, uint256 _tokenAmount, uint256 _yieldReturned);

    address immutable flashProtocolAddress;
    address payable constant principalTokenAddress = payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address fTokenAddress;

    uint256 principalBalance;

    RocketStorageInterface public rocketStorage;

    uint256 maxStakeDuration = 14515200;
    bool public maxStakeDurationLocked = false;

    constructor(address _flashProtocolAddress, address _rocketStorageAddress) {
        flashProtocolAddress = _flashProtocolAddress;
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
    }

    // @notice Retrieves relevant addresses as per RocketPool docs
    // @dev this can be called by anyone
    function getAddresses() public view returns(address _depositAddress, address _withdrawAddress) {
        _depositAddress = rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", "rocketDepositPool")));
        _withdrawAddress = rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", "rocketTokenRETH")));
    }

    // @notice Allows Flashstake Protocol to deposit principal tokens
    // @dev this can only be called by the Flashstake Protocol
    function depositPrincipal(uint256 _tokenAmount) external onlyAuthorised returns (uint256) {
        IWETH(principalTokenAddress).approve(principalTokenAddress, _tokenAmount);
        IWETH(principalTokenAddress).withdraw(_tokenAmount);

        (address _depositAddress, address _withdrawAddress) = getAddresses();

        uint256 rETHBefore = IERC20Metadata(_withdrawAddress).balanceOf(address(this));
        RocketDepositPoolInterface(_depositAddress).deposit{ value: address(this).balance }();
        uint256 rETHAfter = IERC20Metadata(_withdrawAddress).balanceOf(address(this));

        uint256 redeemableValue = RocketTokenRETHInterface(_withdrawAddress).getEthValue(rETHAfter - rETHBefore);

        principalBalance += redeemableValue;

        return redeemableValue;
    }

    // @notice Allows Flashstake Protocol to withdraw principal tokens
    // @dev this can only be called by the Flashstake Protocol
    function withdrawPrincipal(uint256 _tokenAmount) external onlyAuthorised {
        require(_tokenAmount <= principalBalance, "WITHDRAW TOO HIGH");

        (, address _withdrawAddress) = getAddresses();
        uint256 rETHtoBurn = ((_tokenAmount * 10**18) / RocketTokenRETHInterface(_withdrawAddress).getExchangeRate()) + 1;

        RocketTokenRETHInterface(_withdrawAddress).approve(_withdrawAddress, rETHtoBurn);
        RocketTokenRETHInterface(_withdrawAddress).burn(rETHtoBurn);

        IWETH(principalTokenAddress).deposit{ value: address(this).balance }();
        IERC20Metadata(principalTokenAddress).safeTransfer(msg.sender, _tokenAmount);

        principalBalance -= _tokenAmount;
    }

    // @notice retrieve the total principal locked within this strategy
    function getPrincipalBalance() public view returns (uint256) {
        return principalBalance;
    }

    // @notice retrieve the total amount of yield currently in the yield pool
    function getYieldBalance() public view returns (uint256) {
        (, address _withdrawAddress) = getAddresses();

        uint256 totalrETHBalance = RocketTokenRETHInterface(_withdrawAddress).balanceOf(address(this));
        uint256 totalEtherBalance = RocketTokenRETHInterface(_withdrawAddress).getEthValue(totalrETHBalance);

        if(principalBalance > totalEtherBalance) {
            return 0;
        }

        // Yield balance is the difference between total redeemable and principalBalance (as recorded)
        return totalEtherBalance - principalBalance;
    }

    // @notice retrieve the principal token address this strategy accepts
    function getPrincipalAddress() external view returns (address) {
        return principalTokenAddress;
    }

    // @notice retrieve the fToken address associated with this strategy
    function getFTokenAddress() external view returns (address) {
        return fTokenAddress;
    }

    // @notice sets the fToken address
    // @dev this can only be called once when registering the strategy against the Flashstake Protocol
    // @dev this can only be called by the Flashstake Protocol
    function setFTokenAddress(address _fTokenAddress) external onlyAuthorised {
        require(fTokenAddress == address(0), "FTOKEN ADDRESS ALREADY SET");
        fTokenAddress = _fTokenAddress;
    }

    // @notice returns the number of fTokens to mint given some principal and duration
    // @dev this can only be called by anyone
    function quoteMintFToken(uint256 _tokenAmount, uint256 _duration) external pure returns (uint256) {
        // Enforce minimum _duration
        require(_duration >= 60, "DURATION TOO LOW");

        // 1 ERC20 for 365 DAYS = 1 fERC20
        // 1 second = 0.000000031709792000
        // eg (100000000000000000 * (1 second * 31709792000)) / 10**18
        uint256 amountToMint = (_tokenAmount * (_duration * 31709792000)) / (10**18);

        return amountToMint;
    }

    // @notice returns the number (estimate) of principal tokens returned when burning some amount of fTokens
    // @dev this can only be called by anyone with fTokens
    function quoteBurnFToken(uint256 _tokenAmount) public view returns (uint256) {
        uint256 totalSupply = IERC20Metadata(fTokenAddress).totalSupply();
        require(totalSupply > 0, "INSUFFICIENT fERC20 TOKEN SUPPLY");

        if (_tokenAmount > totalSupply) {
            _tokenAmount = totalSupply;
        }

        uint256 totalYield = getYieldBalance();
        return (totalYield * _tokenAmount) / totalSupply;
    }

    // @notice burns fTokens to redeem yield from yield pool
    // @dev this can only be called by anyone with fTokens
    function burnFToken(
        uint256 _tokenAmount,
        uint256 _minimumReturned,
        address _yieldTo
    ) external nonReentrant returns (uint256) {

        uint256 tokensOwed = quoteBurnFToken(_tokenAmount);
        require(tokensOwed >= _minimumReturned, "INSUFFICIENT OUTPUT");

        IFlashFToken(fTokenAddress).burnFrom(msg.sender, _tokenAmount);

        // Withdraw the yield
        (, address _withdrawAddress) = getAddresses();
        uint256 rETHtoBurn = ((tokensOwed * 10**18) / RocketTokenRETHInterface(_withdrawAddress).getExchangeRate()) + 1;

        RocketTokenRETHInterface(_withdrawAddress).approve(_withdrawAddress, rETHtoBurn);
        RocketTokenRETHInterface(_withdrawAddress).burn(rETHtoBurn);
        IWETH(principalTokenAddress).deposit{ value: address(this).balance }();

        IERC20Metadata(principalTokenAddress).safeTransfer(_yieldTo, tokensOwed);

        emit BurnedFToken(msg.sender, _tokenAmount, tokensOwed);

        return tokensOwed;
    }

    modifier onlyAuthorised() {
        require(msg.sender == flashProtocolAddress || msg.sender == address(this), "NOT FLASH PROTOCOL");
        _;
    }

    // @notice withdraw any ERC20 token in this strategy that is not the principal or share token
    // @dev this can only be called by the strategy owner
    function withdrawERC20(address[] calldata _tokenAddresses, uint256[] calldata _tokenAmounts) external onlyOwner {
        require(_tokenAddresses.length == _tokenAmounts.length, "ARRAY SIZE MISMATCH");
        (, address _withdrawAddress) = getAddresses();

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            // Ensure the token being withdrawn is not the principal token
            require(_tokenAddresses[i] != principalTokenAddress &&
                _tokenAddresses[i] != _withdrawAddress, "TOKEN ADDRESS PROHIBITED");

            // Transfer the token to the caller
            IERC20Metadata(_tokenAddresses[i]).safeTransfer(msg.sender, _tokenAmounts[i]);
        }
    }

    // @notice retrieve the maximum stake duration in seconds
    // @dev this is usually called by the Flashstake Protocol
    function getMaxStakeDuration() public view returns (uint256) {
        return maxStakeDuration;
    }

    // @notice sets the new maximum stake duration
    // @dev this can only be called by the strategy owner
    function setMaxStakeDuration(uint256 _newMaxStakeDuration) external onlyOwner {
        require(maxStakeDurationLocked == false);
        maxStakeDuration = _newMaxStakeDuration;
    }

    // @notice permanently locks the max stake duration
    // @dev this can only be called by the strategy owner
    function lockMaxStakeDuration() external onlyOwner {
        maxStakeDurationLocked = true;
    }

    fallback() external payable {}
}