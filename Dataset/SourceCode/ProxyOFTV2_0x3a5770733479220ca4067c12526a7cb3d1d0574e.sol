// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "tokens/lz/BaseOFTV2.sol";
import "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract ProxyOFTV2 is BaseOFTV2 {
    using SafeERC20 for IERC20;

    IERC20 internal immutable innerToken;
    uint internal immutable ld2sdRate;

    constructor(address _token, uint8 _sharedDecimals, address _lzEndpoint) BaseOFTV2(_sharedDecimals, _lzEndpoint) {
        innerToken = IERC20(_token);

        (bool success, bytes memory data) = _token.staticcall(abi.encodeWithSignature("decimals()"));
        require(success, "ProxyOFT: failed to get token decimals");
        uint8 decimals = abi.decode(data, (uint8));

        require(_sharedDecimals <= decimals, "ProxyOFT: sharedDecimals must be <= decimals");
        ld2sdRate = 10 ** (decimals - _sharedDecimals);
    }

    /************************************************************************
     * public functions
     ************************************************************************/
    function circulatingSupply() public view virtual override returns (uint) {
        return innerToken.totalSupply() - innerToken.balanceOf(address(this));
    }

    function token() public view virtual override returns (address) {
        return address(innerToken);
    }

    /************************************************************************
     * internal functions
     ************************************************************************/
    function _debitFrom(address _from, uint16, bytes32, uint _amount) internal virtual override returns (uint) {
        require(_from == _msgSender(), "ProxyOFT: owner is not send caller");

        innerToken.safeTransferFrom(_from, address(this), _amount);

        return _amount;
    }

    function _creditTo(uint16, address _toAddress, uint _amount) internal virtual override returns (uint) {
        innerToken.safeTransfer(_toAddress, _amount);
        return _amount;
    }

    function _ld2sdRate() internal view virtual override returns (uint) {
        return ld2sdRate;
    }

    function rescueInnerToken() external onlyOwner {
        innerToken.safeTransfer(msg.sender, innerToken.balanceOf(address(this)));
    }
}