// Sources flattened with hardhat v2.11.2 https://hardhat.org



// File contracts/interfaces/IEmergencyGuard.sol



// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



interface IEmergencyGuard {

    /**

     * Emitted on BNB withdrawal

     *

     * @param receiver address - Receiver of BNB

     * @param amount uint256 - BNB amount

     */

    event EmergencyWithdraw(address receiver, uint256 amount);



    /**

     * Emitted on token withdrawal

     *

     * @param receiver address - Receiver of token

     * @param token address - Token address

     * @param amount uint256 - token amount

     */

    event EmergencyWithdrawToken(

        address receiver,

        address token,

        uint256 amount

    );



    /**

     * Withdraws BNB stores at the contract

     *

     * @param amount uint256 - Amount of BNB to withdraw

     */

    function emergencyWithdraw(uint256 amount) external;



    /**

     * Withdraws token stores at the contract

     *

     * @param token address - Token to withdraw

     * @param amount uint256 - Amount of token to withdraw

     */

    function emergencyWithdrawToken(address token, uint256 amount) external;

}





// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20 {

    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by

     * a call to {approve}. `value` is the new allowance.

     */

    event Approval(address indexed owner, address indexed spender, uint256 value);



    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `to`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address to, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * Emits an {Approval} event.

     */

    function approve(address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `from` to `to` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

}





// File contracts/EmergencyGuard.sol





pragma solidity 0.8.17;



abstract contract EmergencyGuard is IEmergencyGuard {

    function _emergencyWithdraw(uint256 amount) internal virtual {

        address payable sender = payable(msg.sender);

        (bool sent, ) = sender.call{value: amount}("");

        require(sent, "EmergencyGuard: Failed to send BNB");



        emit EmergencyWithdraw(msg.sender, amount);

    }



    function _emergencyWithdrawToken(address token, uint256 amount)

        internal

        virtual

    {

        IERC20(token).transfer(msg.sender, amount);

        emit EmergencyWithdrawToken(msg.sender, token, amount);

    }

}





// File contracts/interfaces/IUniswapV2Router02.sol





pragma solidity 0.8.17;



interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);



    function addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);



    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}



interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountETH);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}





// File contracts/interfaces/IDynamicFeeManager.sol





pragma solidity 0.8.17;



/**

 * Fee entry structure

 */

struct FeeEntry {

    // Unique identifier for the fee entry

    // Generated out of (destination, doLiquify, doSwapForBusd, swapOrLiquifyAmount) to

    // always use the same feeEntryAmounts entry.

    bytes32 id;

    // Sender address OR wildcard address

    address from;

    // Receiver address OR wildcard address

    address to;

    // Fee percentage multiplied by 100000

    uint256 percentage;

    // Fee destination address

    address destination;

    // Indicator, if contracts should be excluded from this fee

    bool excludeContracts;

    // Indicator, if the fee amount should be used to add liquidation on DEX

    bool doLiquify;

    // Indicator, if the fee amount should be swapped to BUSD

    bool doSwapForBusd;

    // Amount used to add liquidation OR swap to BUSD

    uint256 swapOrLiquifyAmount;

    // Timestamp after which the fee won't be applied anymore

    uint256 expiresAt;

}



interface IDynamicFeeManager {

    /**

     * Emitted on fee addition

     *

     * @param id bytes32 - "Unique" identifier for fee entry

     * @param from address - Sender address OR address(0) for wildcard

     * @param to address - Receiver address OR address(0) for wildcard

     * @param percentage uint256 - Fee percentage to take multiplied by 100000

     * @param destination address - Destination address for the fee

     * @param excludeContracts bool - Indicates, if contracts should be excluded from this fee

     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX

     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD

     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap

     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore

     */

    event FeeAdded(

        bytes32 indexed id,

        address indexed from,

        address to,

        uint256 percentage,

        address indexed destination,

        bool excludeContracts,

        bool doLiquify,

        bool doSwapForBusd,

        uint256 swapOrLiquifyAmount,

        uint256 expiresAt

    );



    /**

     * Emitted on fee removal

     *

     * @param id bytes32 - "Unique" identifier for fee entry

     * @param index uint256 - Index of removed the fee

     */

    event FeeRemoved(bytes32 indexed id, uint256 index);



    /**

     * Emitted on fee reflection / distribution

     *

     * @param id bytes32 - "Unique" identifier for fee entry

     * @param token address - Token used for fee

     * @param from address - Sender address OR address(0) for wildcard

     * @param to address - Receiver address OR address(0) for wildcard

     * @param destination address - Destination address for the fee

     * @param excludeContracts bool - Indicates, if contracts should be excluded from this fee

     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX

     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD

     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap

     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore

     */

    event FeeReflected(

        bytes32 indexed id,

        address token,

        address indexed from,

        address to,

        uint256 tFee,

        address indexed destination,

        bool excludeContracts,

        bool doLiquify,

        bool doSwapForBusd,

        uint256 swapOrLiquifyAmount,

        uint256 expiresAt

    );



    /**

     * Emitted on fee state update

     *

     * @param enabled bool - Indicates if fees are enabled now

     */

    event FeeEnabledUpdated(bool enabled);



    /**

     * Emitted on pancake router address update

     *

     * @param newAddress address - New pancake router address

     */

    event PancakeRouterUpdated(address newAddress);



    /**

     * Emitted on BUSD address update

     *

     * @param newAddress address - New BUSD address

     */

    event BusdAddressUpdated(address newAddress);



    /**

     * Emitted on fee limits (fee percentage and transsaction limit) decrease

     */

    event FeeLimitsDecreased();



    /**

     * Emitted on volume percentage for swap events updated

     *

     * @param newPercentage uint256 - New volume percentage for swap events

     */

    event PercentageVolumeSwapUpdated(uint256 newPercentage);



    /**

     * Emitted on volume percentage for liquify events updated

     *

     * @param newPercentage uint256 - New volume percentage for liquify events

     */

    event PercentageVolumeLiquifyUpdated(uint256 newPercentage);



    /**

     * Emitted on Pancakeswap pair (Token <-> BUSD) address updated

     *

     * @param newAddress address - New pair address

     */

    event PancakePairBusdUpdated(address newAddress);



    /**

     * Emitted on Pancakeswap pair (Token <-> BNB) address updated

     *

     * @param newAddress address - New pair address

     */

    event PancakePairBnbUpdated(address newAddress);



    /**

     * Emitted on swap and liquify event

     *

     * @param firstHalf uint256 - Half of tokens

     * @param newBalance uint256 - Amount of BNB

     * @param secondHalf uint256 - Half of tokens for BNB swap

     */

    event SwapAndLiquify(

        uint256 firstHalf,

        uint256 newBalance,

        uint256 secondHalf

    );



    /**

     * Emitted on token swap to BUSD

     *

     * @param token address - Token used for swap

     * @param inputAmount uint256 - Amount used as input for swap

     * @param newBalance uint256 - Amount of received BUSD

     * @param destination address - Destination address for BUSD

     */

    event SwapTokenForBusd(

        address token,

        uint256 inputAmount,

        uint256 newBalance,

        address indexed destination

    );



    /**

     * Return the fee entry at the given index

     *

     * @param index uint256 - Index of the fee entry

     *

     * @return fee FeeEntry - Fee entry

     */

    function getFee(uint256 index) external view returns (FeeEntry memory fee);



    /**

     * Adds a fee entry to the list of fees

     *

     * @param from address - Sender address OR wildcard address

     * @param to address - Receiver address OR wildcard address

     * @param percentage uint256 - Fee percentage to take multiplied by 100000

     * @param destination address - Destination address for the fee

     * @param excludeContracts bool - Indicates, if contracts should be excluded from this fee

     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX

     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD

     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap

     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore

     *

     * @return index uint256 - Index of the newly added fee entry

     */

    function addFee(

        address from,

        address to,

        uint256 percentage,

        address destination,

        bool excludeContracts,

        bool doLiquify,

        bool doSwapForBusd,

        uint256 swapOrLiquifyAmount,

        uint256 expiresAt

    ) external returns (uint256 index);



    /**

     * Removes the fee entry at the given index

     *

     * @param index uint256 - Index to remove

     */

    function removeFee(uint256 index) external;



    /**

     * Reflects the fee for a transaction

     *

     * @param from address - Sender address

     * @param to address - Receiver address

     * @param amount uint256 - Transaction amount

     *

     * @return tTotal uint256 - Total transaction amount after fees

     * @return tFees uint256 - Total fee amount

     */

    function reflectFees(

        address from,

        address to,

        uint256 amount

    ) external returns (uint256 tTotal, uint256 tFees);



    /**

     * Returns the collected amount for swap / liquify fees

     *

     * @param id bytes32 - Fee entry id

     *

     * @return amount uint256 - Collected amount

     */

    function getFeeAmount(bytes32 id) external view returns (uint256 amount);



    /**

     * Returns true if fees are enabled, false when disabled

     *

     * @param value bool - Indicates if fees are enabled

     */

    function feesEnabled() external view returns (bool value);



    /**

     * Sets the transaction fee state

     *

     * @param value bool - true to enable fees, false to disable

     */

    function setFeesEnabled(bool value) external;



    /**

     * Returns the pancake router

     *

     * @return value IUniswapV2Router02 - Pancake router

     */

    function pancakeRouter() external view returns (IUniswapV2Router02 value);



    /**

     * Sets the pancake router

     *

     * @param value address - New pancake router address

     */

    function setPancakeRouter(address value) external;



    /**

     * Returns the BUSD address

     *

     * @return value address - BUSD address

     */

    function busdAddress() external view returns (address value);



    /**

     * Sets the BUSD address

     *

     * @param value address - BUSD address

     */

    function setBusdAddress(address value) external;



    /**

     * Returns the fee decrease status

     *

     * @return value bool - True if fees are already decreased, false if not

     */

    function feeDecreased() external view returns (bool value);



    /**

     * Returns the fee entry percentage limit

     *

     * @return value uint256 - Fee entry percentage limit

     */

    function feePercentageLimit() external view returns (uint256 value);



    /**

     * Returns the overall transaction fee limit

     *

     * @return value uint256 - Transaction fee limit in percent

     */

    function transactionFeeLimit() external view returns (uint256 value);



    /**

     * Decreases the fee limits from initial values (used for bot protection), to normal values

     */

    function decreaseFeeLimits() external;



    /**

     * Returns the current volume percentage for swap events

     *

     * @return value uint256 - Volume percentage for swap events

     */

    function percentageVolumeSwap() external view returns (uint256 value);



    /**

     * Sets the volume percentage for swap events

     * If set to zero, swapping based on volume will be disabled and fee.swapOrLiquifyAmount is used.

     *

     * @param value uint256 - New volume percentage for swapping

     */

    function setPercentageVolumeSwap(uint256 value) external;



    /**

     * Returns the current volume percentage for liquify events

     *

     * @return value uint256 - Volume percentage for liquify events

     */

    function percentageVolumeLiquify() external view returns (uint256 value);



    /**

     * Sets the volume percentage for liquify events

     * If set to zero, adding liquidity based on volume will be disabled and fee.swapOrLiquifyAmount is used.

     *

     * @param value uint256 - New volume percentage for adding liquidity

     */

    function setPercentageVolumeLiquify(uint256 value) external;



    /**

     * Returns the Pancakeswap pair address (Token <-> BUSD)

     *

     * @return value address - Pair address

     */

    function pancakePairBusdAddress() external view returns (address value);



    /**

     * Sets the Pancakeswap pair address (Token <-> BUSD)

     *

     * @param value address - New pair address

     */

    function setPancakePairBusdAddress(address value) external;



    /**

     * Returns the Pancakeswap pair address (Token <-> BNB)

     *

     * @return value address - Pair address

     */

    function pancakePairBnbAddress() external view returns (address value);



    /**

     * Sets the Pancakeswap pair address (Token <-> BNB)

     *

     * @param value address - New pair address

     */

    function setPancakePairBnbAddress(address value) external;



    /**

     * Returns the fee token instance

     *

     * @return value IERC20 - Fee Token instance

     */

    function token() external view returns (IERC20 value);

}





// File contracts/interfaces/IDeclanceToken.sol





pragma solidity 0.8.17;





interface IDeclanceToken {

    /**

     * Emitted on transaction unpause

     */

    event Unpaused();



    /**

     * Emitted on dynamic fee manager update

     *

     * @param newAddress address - New dynamic fee manager address

     */

    event DynamicFeeManagerUpdated(address newAddress);



    /**

     * Returns true if transactions are pause, false if unpaused

     *

     * @param value bool - Indicates if transactions are paused

     */

    function paused() external view returns (bool value);



    /**

     * Sets the transaction pause state to false and therefor, allowing any transactions

     */

    function unpause() external;



    /**

     * Returns the dynamic fee manager

     *

     * @return value IDynamicFeeManager - Dynamic Fee Manager

     */

    function dynamicFeeManager()

        external

        view

        returns (IDynamicFeeManager value);



    /**

     * Sets the dynamic fee manager

     * Can be set to zero address to disable fee reflection.

     *

     * @param value address - New dynamic fee manager address

     */

    function setDynamicFeeManager(address value) external;

}





// File contracts/interfaces/IFeeToken.sol





pragma solidity 0.8.17;



interface IFeeToken {

    /**

     * Transfers token from <from> to <to> without applying fees

     *

     * @param from address - Sender address

     * @param to address - Receiver address

     * @param amount uin256 - Transaction amount

     */

    function transferFromNoFees(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

}





// File @openzeppelin/contracts/utils/Context.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



pragma solidity ^0.8.0;



/**

 * @dev Provides information about the current execution context, including the

 * sender of the transaction and its data. While these are generally available

 * via msg.sender and msg.data, they should not be accessed in such a direct

 * manner, since when dealing with meta-transactions the account sending and

 * paying for execution may not be the actual sender (as far as an application

 * is concerned).

 *

 * This contract is only required for intermediate, library-like contracts.

 */

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}





// File @openzeppelin/contracts/access/Ownable.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



pragma solidity ^0.8.0;



/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * By default, the owner account will be the one that deploys the contract. This

 * can later be changed with {transferOwnership}.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be applied to your functions to restrict their use to

 * the owner.

 */

abstract contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor() {

        _transferOwnership(_msgSender());

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        _checkOwner();

        _;

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view virtual returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if the sender is not the owner.

     */

    function _checkOwner() internal view virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public virtual onlyOwner {

        _transferOwnership(address(0));

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Internal function without access restriction.

     */

    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}





// File @openzeppelin/contracts/access/IAccessControl.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)



pragma solidity ^0.8.0;



/**

 * @dev External interface of AccessControl declared to support ERC165 detection.

 */

interface IAccessControl {

    /**

     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`

     *

     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite

     * {RoleAdminChanged} not being emitted signaling this.

     *

     * _Available since v3.1._

     */

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);



    /**

     * @dev Emitted when `account` is granted `role`.

     *

     * `sender` is the account that originated the contract call, an admin role

     * bearer except when using {AccessControl-_setupRole}.

     */

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Emitted when `account` is revoked `role`.

     *

     * `sender` is the account that originated the contract call:

     *   - if using `revokeRole`, it is the admin role bearer

     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)

     */

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) external view returns (bool);



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {AccessControl-_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) external view returns (bytes32);



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function grantRole(bytes32 role, address account) external;



    /**

     * @dev Revokes `role` from `account`.

     *

     * If `account` had been granted `role`, emits a {RoleRevoked} event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function revokeRole(bytes32 role, address account) external;



    /**

     * @dev Revokes `role` from the calling account.

     *

     * Roles are often managed via {grantRole} and {revokeRole}: this function's

     * purpose is to provide a mechanism for accounts to lose their privileges

     * if they are compromised (such as when a trusted device is misplaced).

     *

     * If the calling account had been granted `role`, emits a {RoleRevoked}

     * event.

     *

     * Requirements:

     *

     * - the caller must be `account`.

     */

    function renounceRole(bytes32 role, address account) external;

}





// File @openzeppelin/contracts/access/IAccessControlEnumerable.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)



pragma solidity ^0.8.0;



/**

 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.

 */

interface IAccessControlEnumerable is IAccessControl {

    /**

     * @dev Returns one of the accounts that have `role`. `index` must be a

     * value between 0 and {getRoleMemberCount}, non-inclusive.

     *

     * Role bearers are not sorted in any particular way, and their ordering may

     * change at any point.

     *

     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure

     * you perform all queries on the same block. See the following

     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]

     * for more information.

     */

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);



    /**

     * @dev Returns the number of accounts that have `role`. Can be used

     * together with {getRoleMember} to enumerate all bearers of a role.

     */

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}





// File @openzeppelin/contracts/utils/math/Math.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)



pragma solidity ^0.8.0;



/**

 * @dev Standard math utilities missing in the Solidity language.

 */

library Math {

    enum Rounding {

        Down, // Toward negative infinity

        Up, // Toward infinity

        Zero // Toward zero

    }



    /**

     * @dev Returns the largest of two numbers.

     */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;

    }



    /**

     * @dev Returns the smallest of two numbers.

     */

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    /**

     * @dev Returns the average of two numbers. The result is rounded towards

     * zero.

     */

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b) / 2 can overflow.

        return (a & b) + (a ^ b) / 2;

    }



    /**

     * @dev Returns the ceiling of the division of two numbers.

     *

     * This differs from standard division with `/` in that it rounds up instead

     * of rounding down.

     */

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b - 1) / b can overflow on addition, so we distribute.

        return a == 0 ? 0 : (a - 1) / b + 1;

    }



    /**

     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0

     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)

     * with further edits by Uniswap Labs also under MIT license.

     */

    function mulDiv(

        uint256 x,

        uint256 y,

        uint256 denominator

    ) internal pure returns (uint256 result) {

        unchecked {

            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use

            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256

            // variables such that product = prod1 * 2^256 + prod0.

            uint256 prod0; // Least significant 256 bits of the product

            uint256 prod1; // Most significant 256 bits of the product

            assembly {

                let mm := mulmod(x, y, not(0))

                prod0 := mul(x, y)

                prod1 := sub(sub(mm, prod0), lt(mm, prod0))

            }



            // Handle non-overflow cases, 256 by 256 division.

            if (prod1 == 0) {

                return prod0 / denominator;

            }



            // Make sure the result is less than 2^256. Also prevents denominator == 0.

            require(denominator > prod1);



            ///////////////////////////////////////////////

            // 512 by 256 division.

            ///////////////////////////////////////////////



            // Make division exact by subtracting the remainder from [prod1 prod0].

            uint256 remainder;

            assembly {

                // Compute remainder using mulmod.

                remainder := mulmod(x, y, denominator)



                // Subtract 256 bit number from 512 bit number.

                prod1 := sub(prod1, gt(remainder, prod0))

                prod0 := sub(prod0, remainder)

            }



            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.

            // See https://cs.stackexchange.com/q/138556/92363.



            // Does not overflow because the denominator cannot be zero at this stage in the function.

            uint256 twos = denominator & (~denominator + 1);

            assembly {

                // Divide denominator by twos.

                denominator := div(denominator, twos)



                // Divide [prod1 prod0] by twos.

                prod0 := div(prod0, twos)



                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.

                twos := add(div(sub(0, twos), twos), 1)

            }



            // Shift in bits from prod1 into prod0.

            prod0 |= prod1 * twos;



            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such

            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for

            // four bits. That is, denominator * inv = 1 mod 2^4.

            uint256 inverse = (3 * denominator) ^ 2;



            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works

            // in modular arithmetic, doubling the correct bits in each step.

            inverse *= 2 - denominator * inverse; // inverse mod 2^8

            inverse *= 2 - denominator * inverse; // inverse mod 2^16

            inverse *= 2 - denominator * inverse; // inverse mod 2^32

            inverse *= 2 - denominator * inverse; // inverse mod 2^64

            inverse *= 2 - denominator * inverse; // inverse mod 2^128

            inverse *= 2 - denominator * inverse; // inverse mod 2^256



            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.

            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is

            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1

            // is no longer required.

            result = prod0 * inverse;

            return result;

        }

    }



    /**

     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.

     */

    function mulDiv(

        uint256 x,

        uint256 y,

        uint256 denominator,

        Rounding rounding

    ) internal pure returns (uint256) {

        uint256 result = mulDiv(x, y, denominator);

        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {

            result += 1;

        }

        return result;

    }



    /**

     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.

     *

     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).

     */

    function sqrt(uint256 a) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.

        //

        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have

        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.

        //

        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`

        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`

        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`

        //

        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.

        uint256 result = 1 << (log2(a) >> 1);



        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,

        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at

        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision

        // into the expected uint128 result.

        unchecked {

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            return min(result, a / result);

        }

    }



    /**

     * @notice Calculates sqrt(a), following the selected rounding direction.

     */

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = sqrt(a);

            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 2, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log2(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >> 128 > 0) {

                value >>= 128;

                result += 128;

            }

            if (value >> 64 > 0) {

                value >>= 64;

                result += 64;

            }

            if (value >> 32 > 0) {

                value >>= 32;

                result += 32;

            }

            if (value >> 16 > 0) {

                value >>= 16;

                result += 16;

            }

            if (value >> 8 > 0) {

                value >>= 8;

                result += 8;

            }

            if (value >> 4 > 0) {

                value >>= 4;

                result += 4;

            }

            if (value >> 2 > 0) {

                value >>= 2;

                result += 2;

            }

            if (value >> 1 > 0) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log2(value);

            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 10, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >= 10**64) {

                value /= 10**64;

                result += 64;

            }

            if (value >= 10**32) {

                value /= 10**32;

                result += 32;

            }

            if (value >= 10**16) {

                value /= 10**16;

                result += 16;

            }

            if (value >= 10**8) {

                value /= 10**8;

                result += 8;

            }

            if (value >= 10**4) {

                value /= 10**4;

                result += 4;

            }

            if (value >= 10**2) {

                value /= 10**2;

                result += 2;

            }

            if (value >= 10**1) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log10(value);

            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 256, rounded down, of a positive value.

     * Returns 0 if given 0.

     *

     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.

     */

    function log256(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >> 128 > 0) {

                value >>= 128;

                result += 16;

            }

            if (value >> 64 > 0) {

                value >>= 64;

                result += 8;

            }

            if (value >> 32 > 0) {

                value >>= 32;

                result += 4;

            }

            if (value >> 16 > 0) {

                value >>= 16;

                result += 2;

            }

            if (value >> 8 > 0) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log256(value);

            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);

        }

    }

}





// File @openzeppelin/contracts/utils/Strings.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)



pragma solidity ^0.8.0;



/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory) {

        unchecked {

            uint256 length = Math.log10(value) + 1;

            string memory buffer = new string(length);

            uint256 ptr;

            /// @solidity memory-safe-assembly

            assembly {

                ptr := add(buffer, add(32, length))

            }

            while (true) {

                ptr--;

                /// @solidity memory-safe-assembly

                assembly {

                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))

                }

                value /= 10;

                if (value == 0) break;

            }

            return buffer;

        }

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.

     */

    function toHexString(uint256 value) internal pure returns (string memory) {

        unchecked {

            return toHexString(value, Math.log256(value) + 1);

        }

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

     */

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);

        buffer[0] = "0";

        buffer[1] = "x";

        for (uint256 i = 2 * length + 1; i > 1; --i) {

            buffer[i] = _SYMBOLS[value & 0xf];

            value >>= 4;

        }

        require(value == 0, "Strings: hex length insufficient");

        return string(buffer);

    }



    /**

     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.

     */

    function toHexString(address addr) internal pure returns (string memory) {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);

    }

}





// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC165 standard, as defined in the

 * https://eips.ethereum.org/EIPS/eip-165[EIP].

 *

 * Implementers can declare support of contract interfaces, which can then be

 * queried by others ({ERC165Checker}).

 *

 * For an implementation, see {ERC165}.

 */

interface IERC165 {

    /**

     * @dev Returns true if this contract implements the interface defined by

     * `interfaceId`. See the corresponding

     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]

     * to learn more about how these ids are created.

     *

     * This function call must use less than 30 000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)



pragma solidity ^0.8.0;



/**

 * @dev Implementation of the {IERC165} interface.

 *

 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check

 * for the additional interface id that will be supported. For example:

 *

 * ```solidity

 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);

 * }

 * ```

 *

 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.

 */

abstract contract ERC165 is IERC165 {

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}





// File @openzeppelin/contracts/access/AccessControl.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)



pragma solidity ^0.8.0;









/**

 * @dev Contract module that allows children to implement role-based access

 * control mechanisms. This is a lightweight version that doesn't allow enumerating role

 * members except through off-chain means by accessing the contract event logs. Some

 * applications may benefit from on-chain enumerability, for those cases see

 * {AccessControlEnumerable}.

 *

 * Roles are referred to by their `bytes32` identifier. These should be exposed

 * in the external API and be unique. The best way to achieve this is by

 * using `public constant` hash digests:

 *

 * ```

 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");

 * ```

 *

 * Roles can be used to represent a set of permissions. To restrict access to a

 * function call, use {hasRole}:

 *

 * ```

 * function foo() public {

 *     require(hasRole(MY_ROLE, msg.sender));

 *     ...

 * }

 * ```

 *

 * Roles can be granted and revoked dynamically via the {grantRole} and

 * {revokeRole} functions. Each role has an associated admin role, and only

 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.

 *

 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means

 * that only accounts with this role will be able to grant or revoke other

 * roles. More complex role relationships can be created by using

 * {_setRoleAdmin}.

 *

 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to

 * grant and revoke this role. Extra precautions should be taken to secure

 * accounts that have been granted it.

 */

abstract contract AccessControl is Context, IAccessControl, ERC165 {

    struct RoleData {

        mapping(address => bool) members;

        bytes32 adminRole;

    }



    mapping(bytes32 => RoleData) private _roles;



    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;



    /**

     * @dev Modifier that checks that an account has a specific role. Reverts

     * with a standardized message including the required role.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/

     *

     * _Available since v4.1._

     */

    modifier onlyRole(bytes32 role) {

        _checkRole(role);

        _;

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {

        return _roles[role].members[account];

    }



    /**

     * @dev Revert with a standard message if `_msgSender()` is missing `role`.

     * Overriding this function changes the behavior of the {onlyRole} modifier.

     *

     * Format of the revert message is described in {_checkRole}.

     *

     * _Available since v4.6._

     */

    function _checkRole(bytes32 role) internal view virtual {

        _checkRole(role, _msgSender());

    }



    /**

     * @dev Revert with a standard message if `account` is missing `role`.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/

     */

    function _checkRole(bytes32 role, address account) internal view virtual {

        if (!hasRole(role, account)) {

            revert(

                string(

                    abi.encodePacked(

                        "AccessControl: account ",

                        Strings.toHexString(account),

                        " is missing role ",

                        Strings.toHexString(uint256(role), 32)

                    )

                )

            );

        }

    }



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {

        return _roles[role].adminRole;

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     *

     * May emit a {RoleGranted} event.

     */

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {

        _grantRole(role, account);

    }



    /**

     * @dev Revokes `role` from `account`.

     *

     * If `account` had been granted `role`, emits a {RoleRevoked} event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     *

     * May emit a {RoleRevoked} event.

     */

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {

        _revokeRole(role, account);

    }



    /**

     * @dev Revokes `role` from the calling account.

     *

     * Roles are often managed via {grantRole} and {revokeRole}: this function's

     * purpose is to provide a mechanism for accounts to lose their privileges

     * if they are compromised (such as when a trusted device is misplaced).

     *

     * If the calling account had been revoked `role`, emits a {RoleRevoked}

     * event.

     *

     * Requirements:

     *

     * - the caller must be `account`.

     *

     * May emit a {RoleRevoked} event.

     */

    function renounceRole(bytes32 role, address account) public virtual override {

        require(account == _msgSender(), "AccessControl: can only renounce roles for self");



        _revokeRole(role, account);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event. Note that unlike {grantRole}, this function doesn't perform any

     * checks on the calling account.

     *

     * May emit a {RoleGranted} event.

     *

     * [WARNING]

     * ====

     * This function should only be called from the constructor when setting

     * up the initial roles for the system.

     *

     * Using this function in any other way is effectively circumventing the admin

     * system imposed by {AccessControl}.

     * ====

     *

     * NOTE: This function is deprecated in favor of {_grantRole}.

     */

    function _setupRole(bytes32 role, address account) internal virtual {

        _grantRole(role, account);

    }



    /**

     * @dev Sets `adminRole` as ``role``'s admin role.

     *

     * Emits a {RoleAdminChanged} event.

     */

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {

        bytes32 previousAdminRole = getRoleAdmin(role);

        _roles[role].adminRole = adminRole;

        emit RoleAdminChanged(role, previousAdminRole, adminRole);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * Internal function without access restriction.

     *

     * May emit a {RoleGranted} event.

     */

    function _grantRole(bytes32 role, address account) internal virtual {

        if (!hasRole(role, account)) {

            _roles[role].members[account] = true;

            emit RoleGranted(role, account, _msgSender());

        }

    }



    /**

     * @dev Revokes `role` from `account`.

     *

     * Internal function without access restriction.

     *

     * May emit a {RoleRevoked} event.

     */

    function _revokeRole(bytes32 role, address account) internal virtual {

        if (hasRole(role, account)) {

            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, _msgSender());

        }

    }

}





// File @openzeppelin/contracts/utils/structs/EnumerableSet.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)

// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.



pragma solidity ^0.8.0;



/**

 * @dev Library for managing

 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive

 * types.

 *

 * Sets have the following properties:

 *

 * - Elements are added, removed, and checked for existence in constant time

 * (O(1)).

 * - Elements are enumerated in O(n). No guarantees are made on the ordering.

 *

 * ```

 * contract Example {

 *     // Add the library methods

 *     using EnumerableSet for EnumerableSet.AddressSet;

 *

 *     // Declare a set state variable

 *     EnumerableSet.AddressSet private mySet;

 * }

 * ```

 *

 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)

 * and `uint256` (`UintSet`) are supported.

 *

 * [WARNING]

 * ====

 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure

 * unusable.

 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.

 *

 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an

 * array of EnumerableSet.

 * ====

 */

library EnumerableSet {

    // To implement this library for multiple types with as little code

    // repetition as possible, we write it in terms of a generic Set type with

    // bytes32 values.

    // The Set implementation uses private functions, and user-facing

    // implementations (such as AddressSet) are just wrappers around the

    // underlying Set.

    // This means that we can only create new EnumerableSets for types that fit

    // in bytes32.



    struct Set {

        // Storage of set values

        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0

        // means a value is not in the set.

        mapping(bytes32 => uint256) _indexes;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {

            set._values.push(value);

            // The value is stored at length-1, but we add 1 to all indexes

            // and use 0 as a sentinel value

            set._indexes[value] = set._values.length;

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        // We read and store the value's index to prevent multiple reads from the same storage slot

        uint256 valueIndex = set._indexes[value];



        if (valueIndex != 0) {

            // Equivalent to contains(set, value)

            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in

            // the array, and then remove the last element (sometimes called as 'swap and pop').

            // This modifies the order of the array, as noted in {at}.



            uint256 toDeleteIndex = valueIndex - 1;

            uint256 lastIndex = set._values.length - 1;



            if (lastIndex != toDeleteIndex) {

                bytes32 lastValue = set._values[lastIndex];



                // Move the last value to the index where the value to delete is

                set._values[toDeleteIndex] = lastValue;

                // Update the index for the moved value

                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex

            }



            // Delete the slot where the moved value was stored

            set._values.pop();



            // Delete the index for the deleted slot

            delete set._indexes[value];



            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;

    }



    /**

     * @dev Returns the number of values on the set. O(1).

     */

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];

    }



    /**

     * @dev Return the entire set in an array

     *

     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed

     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that

     * this function has an unbounded cost, and using it as part of a state-changing function may render the function

     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.

     */

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;

    }



    // Bytes32Set



    struct Bytes32Set {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);

    }



    /**

     * @dev Return the entire set in an array

     *

     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed

     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that

     * this function has an unbounded cost, and using it as part of a state-changing function may render the function

     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.

     */

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        bytes32[] memory store = _values(set._inner);

        bytes32[] memory result;



        /// @solidity memory-safe-assembly

        assembly {

            result := store

        }



        return result;

    }



    // AddressSet



    struct AddressSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));

    }



    /**

     * @dev Return the entire set in an array

     *

     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed

     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that

     * this function has an unbounded cost, and using it as part of a state-changing function may render the function

     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.

     */

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);

        address[] memory result;



        /// @solidity memory-safe-assembly

        assembly {

            result := store

        }



        return result;

    }



    // UintSet



    struct UintSet {

        Set _inner;

    }



    /**

     * @dev Add a value to a set. O(1).

     *

     * Returns true if the value was added to the set, that is if it was not

     * already present.

     */

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));

    }



    /**

     * @dev Removes a value from a set. O(1).

     *

     * Returns true if the value was removed from the set, that is if it was

     * present.

     */

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));

    }



    /**

     * @dev Returns true if the value is in the set. O(1).

     */

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));

    }



    /**

     * @dev Returns the number of values in the set. O(1).

     */

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);

    }



    /**

     * @dev Returns the value stored at position `index` in the set. O(1).

     *

     * Note that there are no guarantees on the ordering of values inside the

     * array, and it may change when more values are added or removed.

     *

     * Requirements:

     *

     * - `index` must be strictly less than {length}.

     */

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));

    }



    /**

     * @dev Return the entire set in an array

     *

     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed

     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that

     * this function has an unbounded cost, and using it as part of a state-changing function may render the function

     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.

     */

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);

        uint256[] memory result;



        /// @solidity memory-safe-assembly

        assembly {

            result := store

        }



        return result;

    }

}





// File @openzeppelin/contracts/access/AccessControlEnumerable.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)



pragma solidity ^0.8.0;







/**

 * @dev Extension of {AccessControl} that allows enumerating the members of each role.

 */

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {

    using EnumerableSet for EnumerableSet.AddressSet;



    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @dev Returns one of the accounts that have `role`. `index` must be a

     * value between 0 and {getRoleMemberCount}, non-inclusive.

     *

     * Role bearers are not sorted in any particular way, and their ordering may

     * change at any point.

     *

     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure

     * you perform all queries on the same block. See the following

     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]

     * for more information.

     */

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {

        return _roleMembers[role].at(index);

    }



    /**

     * @dev Returns the number of accounts that have `role`. Can be used

     * together with {getRoleMember} to enumerate all bearers of a role.

     */

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {

        return _roleMembers[role].length();

    }



    /**

     * @dev Overload {_grantRole} to track enumerable memberships

     */

    function _grantRole(bytes32 role, address account) internal virtual override {

        super._grantRole(role, account);

        _roleMembers[role].add(account);

    }



    /**

     * @dev Overload {_revokeRole} to track enumerable memberships

     */

    function _revokeRole(bytes32 role, address account) internal virtual override {

        super._revokeRole(role, account);

        _roleMembers[role].remove(account);

    }

}





// File contracts/BaseDeclanceToken.sol





pragma solidity 0.8.17;









abstract contract BaseDeclanceToken is

    IDeclanceToken,

    IFeeToken,

    EmergencyGuard,

    AccessControlEnumerable,

    Ownable

{

    // Total token supply

    uint256 public constant TOTAL_SUPPLY = 420_000_000 ether;



    // Role allowed to do admin operations like adding to fee whitelist, withdraw, etc.

    bytes32 public constant ADMIN = keccak256("ADMIN");



    // Role allowed to bypass pause

    bytes32 public constant BYPASS_PAUSE = keccak256("BYPASS_PAUSE");



    // Indicator, if transactions are paused

    bool private _paused = true;



    // Dynamic Fee Manager instance

    IDynamicFeeManager private _dynamicFeeManager;



    constructor() {

        _setupRole(ADMIN, _msgSender());

        _setRoleAdmin(ADMIN, ADMIN);

        _setRoleAdmin(BYPASS_PAUSE, ADMIN);

    }



    /**

     * Getter & Setter

     */

    function unpause() external override onlyRole(ADMIN) {

        _paused = false;

        emit Unpaused();

    }



    function setDynamicFeeManager(

        address value

    ) external override onlyRole(ADMIN) {

        _dynamicFeeManager = IDynamicFeeManager(value);

        emit DynamicFeeManagerUpdated(value);

    }



    function emergencyWithdraw(

        uint256 amount

    ) external override onlyRole(ADMIN) {

        super._emergencyWithdraw(amount);

    }



    function emergencyWithdrawToken(

        address token,

        uint256 amount

    ) external override onlyRole(ADMIN) {

        super._emergencyWithdrawToken(token, amount);

    }



    function paused() public view override returns (bool) {

        return _paused;

    }



    function dynamicFeeManager()

        public

        view

        override

        returns (IDynamicFeeManager manager)

    {

        return _dynamicFeeManager;

    }

}





// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface for the optional metadata functions from the ERC20 standard.

 *

 * _Available since v4.1._

 */

interface IERC20Metadata is IERC20 {

    /**

     * @dev Returns the name of the token.

     */

    function name() external view returns (string memory);



    /**

     * @dev Returns the symbol of the token.

     */

    function symbol() external view returns (string memory);



    /**

     * @dev Returns the decimals places of the token.

     */

    function decimals() external view returns (uint8);

}





// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)



pragma solidity ^0.8.0;







/**

 * @dev Implementation of the {IERC20} interface.

 *

 * This implementation is agnostic to the way tokens are created. This means

 * that a supply mechanism has to be added in a derived contract using {_mint}.

 * For a generic mechanism see {ERC20PresetMinterPauser}.

 *

 * TIP: For a detailed writeup see our guide

 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How

 * to implement supply mechanisms].

 *

 * We have followed general OpenZeppelin Contracts guidelines: functions revert

 * instead returning `false` on failure. This behavior is nonetheless

 * conventional and does not conflict with the expectations of ERC20

 * applications.

 *

 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.

 * This allows applications to reconstruct the allowance for all accounts just

 * by listening to said events. Other implementations of the EIP may not emit

 * these events, as it isn't required by the specification.

 *

 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}

 * functions have been added to mitigate the well-known issues around setting

 * allowances. See {IERC20-approve}.

 */

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;



    mapping(address => mapping(address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;



    /**

     * @dev Sets the values for {name} and {symbol}.

     *

     * The default value of {decimals} is 18. To select a different value for

     * {decimals} you should overload it.

     *

     * All two of these values are immutable: they can only be set once during

     * construction.

     */

    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view virtual override returns (string memory) {

        return _name;

    }



    /**

     * @dev Returns the symbol of the token, usually a shorter version of the

     * name.

     */

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the number of decimals used to get its user representation.

     * For example, if `decimals` equals `2`, a balance of `505` tokens should

     * be displayed to a user as `5.05` (`505 / 10 ** 2`).

     *

     * Tokens usually opt for a value of 18, imitating the relationship between

     * Ether and Wei. This is the value {ERC20} uses, unless this function is

     * overridden;

     *

     * NOTE: This information is only used for _display_ purposes: it in

     * no way affects any of the arithmetic of the contract, including

     * {IERC20-balanceOf} and {IERC20-transfer}.

     */

    function decimals() public view virtual override returns (uint8) {

        return 18;

    }



    /**

     * @dev See {IERC20-totalSupply}.

     */

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See {IERC20-balanceOf}.

     */

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];

    }



    /**

     * @dev See {IERC20-transfer}.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - the caller must have a balance of at least `amount`.

     */

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _transfer(owner, to, amount);

        return true;

    }



    /**

     * @dev See {IERC20-allowance}.

     */

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    /**

     * @dev See {IERC20-approve}.

     *

     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on

     * `transferFrom`. This is semantically equivalent to an infinite approval.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, amount);

        return true;

    }



    /**

     * @dev See {IERC20-transferFrom}.

     *

     * Emits an {Approval} event indicating the updated allowance. This is not

     * required by the EIP. See the note at the beginning of {ERC20}.

     *

     * NOTE: Does not update the allowance if the current allowance

     * is the maximum `uint256`.

     *

     * Requirements:

     *

     * - `from` and `to` cannot be the zero address.

     * - `from` must have a balance of at least `amount`.

     * - the caller must have allowance for ``from``'s tokens of at least

     * `amount`.

     */

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) public virtual override returns (bool) {

        address spender = _msgSender();

        _spendAllowance(from, spender, amount);

        _transfer(from, to, amount);

        return true;

    }



    /**

     * @dev Atomically increases the allowance granted to `spender` by the caller.

     *

     * This is an alternative to {approve} that can be used as a mitigation for

     * problems described in {IERC20-approve}.

     *

     * Emits an {Approval} event indicating the updated allowance.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, allowance(owner, spender) + addedValue);

        return true;

    }



    /**

     * @dev Atomically decreases the allowance granted to `spender` by the caller.

     *

     * This is an alternative to {approve} that can be used as a mitigation for

     * problems described in {IERC20-approve}.

     *

     * Emits an {Approval} event indicating the updated allowance.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     * - `spender` must have allowance for the caller of at least

     * `subtractedValue`.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();

        uint256 currentAllowance = allowance(owner, spender);

        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {

            _approve(owner, spender, currentAllowance - subtractedValue);

        }



        return true;

    }



    /**

     * @dev Moves `amount` of tokens from `from` to `to`.

     *

     * This internal function is equivalent to {transfer}, and can be used to

     * e.g. implement automatic token fees, slashing mechanisms, etc.

     *

     * Emits a {Transfer} event.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `from` must have a balance of at least `amount`.

     */

    function _transfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(from, to, amount);



        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {

            _balances[from] = fromBalance - amount;

            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by

            // decrementing then incrementing.

            _balances[to] += amount;

        }



        emit Transfer(from, to, amount);



        _afterTokenTransfer(from, to, amount);

    }



    /** @dev Creates `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a {Transfer} event with `from` set to the zero address.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     */

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



        _totalSupply += amount;

        unchecked {

            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.

            _balances[account] += amount;

        }

        emit Transfer(address(0), account, amount);



        _afterTokenTransfer(address(0), account, amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`, reducing the

     * total supply.

     *

     * Emits a {Transfer} event with `to` set to the zero address.

     *

     * Requirements:

     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens.

     */

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _beforeTokenTransfer(account, address(0), amount);



        uint256 accountBalance = _balances[account];

        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        unchecked {

            _balances[account] = accountBalance - amount;

            // Overflow not possible: amount <= accountBalance <= totalSupply.

            _totalSupply -= amount;

        }



        emit Transfer(account, address(0), amount);



        _afterTokenTransfer(account, address(0), amount);

    }



    /**

     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.

     *

     * This internal function is equivalent to `approve`, and can be used to

     * e.g. set automatic allowances for certain subsystems, etc.

     *

     * Emits an {Approval} event.

     *

     * Requirements:

     *

     * - `owner` cannot be the zero address.

     * - `spender` cannot be the zero address.

     */

    function _approve(

        address owner,

        address spender,

        uint256 amount

    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    /**

     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.

     *

     * Does not update the allowance amount in case of infinite allowance.

     * Revert if not enough allowance is available.

     *

     * Might emit an {Approval} event.

     */

    function _spendAllowance(

        address owner,

        address spender,

        uint256 amount

    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);

        if (currentAllowance != type(uint256).max) {

            require(currentAllowance >= amount, "ERC20: insufficient allowance");

            unchecked {

                _approve(owner, spender, currentAllowance - amount);

            }

        }

    }



    /**

     * @dev Hook that is called before any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * will be transferred to `to`.

     * - when `from` is zero, `amount` tokens will be minted for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}



    /**

     * @dev Hook that is called after any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * has been transferred to `to`.

     * - when `from` is zero, `amount` tokens have been minted for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _afterTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual {}

}





// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol@v4.8.0





// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)



pragma solidity ^0.8.0;



/**

 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.

 */

abstract contract ERC20Capped is ERC20 {

    uint256 private immutable _cap;



    /**

     * @dev Sets the value of the `cap`. This value is immutable, it can only be

     * set once during construction.

     */

    constructor(uint256 cap_) {

        require(cap_ > 0, "ERC20Capped: cap is 0");

        _cap = cap_;

    }



    /**

     * @dev Returns the cap on the token's total supply.

     */

    function cap() public view virtual returns (uint256) {

        return _cap;

    }



    /**

     * @dev See {ERC20-_mint}.

     */

    function _mint(address account, uint256 amount) internal virtual override {

        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");

        super._mint(account, amount);

    }

}





// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol@v4.8.0





// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)



pragma solidity ^0.8.0;





/**

 * @dev Extension of {ERC20} that allows token holders to destroy both their own

 * tokens and those that they have an allowance for, in a way that can be

 * recognized off-chain (via event analysis).

 */

abstract contract ERC20Burnable is Context, ERC20 {

    /**

     * @dev Destroys `amount` tokens from the caller.

     *

     * See {ERC20-_burn}.

     */

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`, deducting from the caller's

     * allowance.

     *

     * See {ERC20-_burn} and {ERC20-allowance}.

     *

     * Requirements:

     *

     * - the caller must have allowance for ``accounts``'s tokens of at least

     * `amount`.

     */

    function burnFrom(address account, uint256 amount) public virtual {

        _spendAllowance(account, _msgSender(), amount);

        _burn(account, amount);

    }

}





// File contracts/DeclanceToken.sol





pragma solidity 0.8.17;







/**

 * @title The Declance ERC20 token

 */

contract DeclanceToken is BaseDeclanceToken, ERC20Capped, ERC20Burnable {

    constructor(

        address addressTotalSupply

    )

        ERC20("Declance", "DCA")

        ERC20Capped(TOTAL_SUPPLY)

        BaseDeclanceToken()

    {

        _mint(addressTotalSupply, TOTAL_SUPPLY);

    }



    /**

     * Transfer token from without fee reflection

     *

     * @param from address - Address to transfer token from

     * @param to address - Address to transfer token to

     * @param amount uint256 - Amount of token to transfer

     *

     * @return bool - Indicator if transfer was successful

     */

    function transferFromNoFees(

        address from,

        address to,

        uint256 amount

    ) external virtual override returns (bool) {

        require(

            _msgSender() == address(dynamicFeeManager()),

            "Declance: Can only be called by Dynamic Fee Manager"

        );



        return super.transferFrom(from, to, amount);

    }



    /**

     * Transfer token with fee reflection

     *

     * @inheritdoc ERC20

     */

    function transfer(

        address to,

        uint256 amount

    ) public virtual override returns (bool) {

        // Reflect fees

        (uint256 tTotal, ) = _reflectFees(_msgSender(), to, amount);



        // Execute normal transfer

        return super.transfer(to, tTotal);

    }



    /**

     * Transfer token from with fee reflection

     *

     * @inheritdoc ERC20

     */

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) public virtual override returns (bool) {

        // Reflect fees

        (uint256 tTotal, ) = _reflectFees(from, to, amount);



        // Execute normal transfer

        return super.transferFrom(from, to, tTotal);

    }



    /**

     * @inheritdoc ERC20

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 amount

    ) internal virtual override {

        super._beforeTokenTransfer(from, to, amount);



        _preValidateTransfer(from);

    }



    // Needed since we inherit from ERC20 and ERC20Capped

    function _mint(

        address account,

        uint256 amount

    ) internal virtual override(ERC20, ERC20Capped) {

        super._mint(account, amount);

    }



    /**

     * Reflects fees using the dynamic fee manager

     *

     * @param from address - Sender address

     * @param to address - Receiver address

     * @param amount uint256 - Transaction amount

     */

    function _reflectFees(

        address from,

        address to,

        uint256 amount

    ) private returns (uint256 tTotal, uint256 tFees) {

        if (address(dynamicFeeManager()) == address(0)) {

            return (amount, 0);

        } else {

            // Allow dynamic fee manager to spent amount for fees if needed

            _approve(from, address(dynamicFeeManager()), amount);



            // Reflect fees

            (tTotal, tFees) = dynamicFeeManager().reflectFees(from, to, amount);



            // Reset fee manager approval to zero for security reason

            _approve(from, address(dynamicFeeManager()), 0);



            return (tTotal, tFees);

        }

    }



    /**

     * Checks if the minimum transaction amount is exceeded and if pause is enabled

     *

     * @param from address - Sender address

     */

    function _preValidateTransfer(address from) private view {

        /**

         * Only allow transfers if:

         * - token is not paused

         * - sender is owner

         * - sender is admin

         * - sender has bypass role

         */

        require(

            !paused() ||

                from == address(0) ||

                from == owner() ||

                hasRole(ADMIN, from) ||

                hasRole(BYPASS_PAUSE, from),

            "Declance: transactions are paused"

        );

    }

}