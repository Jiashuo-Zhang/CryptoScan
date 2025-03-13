// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import "./libraries.sol";

/**
 *  name: Bitune AI Platform Token
 *  symble: TUNE
 *  website: Bitune.ai
 */
contract BituneAi is ERC20Permit {
	using SafeERC20 for IERC20;

    IERC20 public immutable matterToken;
    address constant dead = 0x000000000000000000000000000000000000dEaD;

    event Permutation(address indexed account,uint256 amount);

    constructor(address _token,string memory name, string memory symbol,uint8 decimals, uint256 totalSupply) ERC20Permit(name) ERC20(name,symbol,decimals){
        require(_token != address(0),'token can not be zero addr');
        matterToken = IERC20(_token);
        _mint(address(this), totalSupply);
    }

    function permutation(uint256 _amount) external {
        require(_amount > 0,'amount must gt 0');
        matterToken.safeTransferFrom(msg.sender, dead, _amount);
        _transfer(address(this),msg.sender,_amount);
        emit Permutation(msg.sender,_amount);
    }
}