/**

 *Submitted for verification at Etherscan.io on 2023-10-13

*/



// Potato Farm Socials:

// Twitter: https://twitter.com/PotatoFarmETH

// Telegram: https://t.me/PotatoFarmETH

// Dapp: https://potatoes.farm/

// Docs: https://docs.potatoes.farm/



// Sources flattened with hardhat v2.7.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @uniswap/v2-periphery/contracts/interfaces/[email protected]



pragma solidity >=0.6.2;



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





// File @uniswap/v2-periphery/contracts/interfaces/[email protected]



pragma solidity >=0.6.2;



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





// File @uniswap/v2-core/contracts/interfaces/[email protected]



pragma solidity >=0.5.0;



interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair);



    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}





// File @uniswap/v2-core/contracts/interfaces/[email protected]



pragma solidity >=0.5.0;



interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);



    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);



    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);



    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);



    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;



    event Mint(address indexed sender, uint amount0, uint amount1);

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);

    event Swap(

        address indexed sender,

        uint amount0In,

        uint amount1In,

        uint amount0Out,

        uint amount1Out,

        address indexed to

    );

    event Sync(uint112 reserve0, uint112 reserve1);



    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);



    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;



    function initialize(address, address) external;

}





// File @openzeppelin/contracts/utils/[email protected]





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





// File @openzeppelin/contracts/access/[email protected]





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





// File @openzeppelin/contracts/token/ERC20/[email protected]





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





// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]





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





// File @openzeppelin/contracts/token/ERC20/[email protected]





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





// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]





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





// File @openzeppelin/contracts/access/[email protected]





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





// File @openzeppelin/contracts/access/[email protected]





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





// File @openzeppelin/contracts/utils/math/[email protected]





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

        // Ôćĺ `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`

        // Ôćĺ `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`

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





// File @openzeppelin/contracts/utils/[email protected]





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





// File @openzeppelin/contracts/utils/introspection/[email protected]





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





// File @openzeppelin/contracts/utils/introspection/[email protected]





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





// File @openzeppelin/contracts/access/[email protected]





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





// File @openzeppelin/contracts/utils/structs/[email protected]





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





// File @openzeppelin/contracts/access/[email protected]





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





// File contracts/BaseToken.sol





pragma solidity =0.8.14;

/**

 * @notice An abstract token contract that provides core functionalities, that can be further extended.

 * @author iHux3

 */

abstract contract BaseToken is 

    ERC20Burnable, 

    Ownable,

    AccessControlEnumerable

{

    uint32 constant public HUNDRED_PERCENT = 1e6;

    address constant internal ETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    uint32 constant internal MAX_TOTAL_FEE = 22e4;

    uint32 constant internal DEFAULT_MIN_BALANCE_PERCENTAGE = 1e2;

    

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    

    struct BaseParameters {

        string name;

        string symbol;

        IUniswapV2Router02 router;

        IERC20 pairToken;

        uint32[] feePercentages;

        address teamWallet;

        uint initSupply;

    }



    IUniswapV2Router02 public router;

    IERC20 public pairToken;

    IUniswapV2Pair public pair;

    uint32[] public feePercentages; // team, farm rewards

    address public teamWallet;

    address public farmAddress;

    

    uint32 public minBalancePercentage;



    mapping(address => bool) public isExcludedFromFees;



    bool internal _processingFee;

    bool internal _totalSupplyInitialized;



    event InitTotalSupply(

        uint totalSupply

    );

    

    event ExcludeFromFees(

        address targetAddress, 

        bool state

    );



    event SetMinBalancePercentage(

        uint minBalancePercentage

    );



    event SetTeamWallet(

        address teamWallet

    );

    

    event SetFarmAddress(

        address farmAddress

    );



    /**

     * @notice Initializes the BaseToken contract.

     * @param baseParameters The parameters to initialize the contract with.

     */

    constructor(

        BaseParameters memory baseParameters

    ) ERC20(baseParameters.name, baseParameters.symbol) {

        router = baseParameters.router;

        pairToken = address(baseParameters.pairToken) == ETH ? 

            IERC20(router.WETH()) : baseParameters.pairToken;



        pair = IUniswapV2Pair(IUniswapV2Factory(

            baseParameters.router.factory()).createPair(address(this), address(pairToken)

        ));



        feePercentages = baseParameters.feePercentages;

        require(feePercentages.length >= 2, "invalid fees length");

        require(

            getTotalFeePercentage() <= MAX_TOTAL_FEE, 

            "total fees greater than the max fee"

        );



        require(baseParameters.teamWallet != address(0));

        teamWallet = baseParameters.teamWallet;



        isExcludedFromFees[owner()] = true;

        isExcludedFromFees[address(this)] = true;

        isExcludedFromFees[address(0xdead)] = true;



        minBalancePercentage = DEFAULT_MIN_BALANCE_PERCENTAGE;



        _approve(address(this), address(router), 2 ** 256 - 1);



        _initTotalSupply(baseParameters.initSupply);



        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());

    }



    // ================ OWNER FUNCTIONS ================ //



    /**

     * @notice Transfers ownership of the contract to a new owner.

     * @dev Overrides parent function by swapping `isExcludedFromFees`.

     * 

     * @param newOwner The address of the new owner.

     *

     * Requirements:

     * - The caller must be the current owner.

     *

     * Emits an {OwnershipTransferred} event.

     */

    function transferOwnership(

        address newOwner

    ) public override onlyOwner {

        isExcludedFromFees[owner()] = false;

        super.transferOwnership(newOwner);

        isExcludedFromFees[newOwner] = true;

    }



    /**

     * @notice Allows the contract owner to exclude or include an address from fees on transfer.

     * 

     * @param targetAddress The address to exclude or include.

     * @param state A boolean indicating whether the address should be excluded (true) or included (false).

     * 

     * Requirements:

     * - The caller must be the contract owner.

     * 

     * Emits an {ExcludeFromFees} event.

     */

    function excludeFromFees(

        address targetAddress, 

        bool state

    ) external onlyOwner {

        isExcludedFromFees[targetAddress] = state;

        emit ExcludeFromFees(targetAddress, state);

    }



    /**

     * @notice Sets the farm address that receives tx fees.

     * @param _farmAddress The farm address.

     */

    function setFarmAddress(address _farmAddress) external onlyOwner {

        farmAddress = _farmAddress;

        isExcludedFromFees[_farmAddress] = true;

        emit SetFarmAddress(_farmAddress);

    }



    /**

     * @notice Allows to mint tokens if the sender has the minter role.

     * @param account The account to mint tokens for

     * @param amount Amount of tokens to mint

     */

    function mint(address account, uint amount) external returns (bool) {

        require(hasRole(MINTER_ROLE, msg.sender), "unauthorized"); 

        _mint(account, amount);

        return true;

    }



    // ================ TEAM WALLET FUNCTIONS ================ //



    /**

     * @notice Allows to change team wallet to set a new team wallet address.

     * @param newTeamWallet The address of the new team wallet

     */

    function setTeamWallet(

        address newTeamWallet

    ) external {

        require(msg.sender == teamWallet || msg.sender == owner(), "unauthorized");

        require(newTeamWallet != address(0), "zero address");

        teamWallet = newTeamWallet;

        emit SetTeamWallet(newTeamWallet);

    }



    /**

     * @notice Allows the team wallet to swap to eth manually rather than waiting for minimum balance.

     */

    function swapTokensToETHManual() external {

        require(msg.sender == teamWallet || msg.sender == owner(), "unauthorized");

        _swapTokensForETH();

    }



    /**

     * @notice Sets new percentage for required minimum balance for swapping team tokens to ETH.

     * @param newMinBalancePercentage the new percentage

     */

    function setMinBalancePercentage(uint32 newMinBalancePercentage) external {

        require(msg.sender == teamWallet || msg.sender == owner(), "unauthorized");

        require(newMinBalancePercentage <= HUNDRED_PERCENT, "too high");



        minBalancePercentage = newMinBalancePercentage;

        emit SetMinBalancePercentage(newMinBalancePercentage);

    }



    // ================ INTERNAL FUNCTIONS ================ //



    /**

     * @notice Transfers tokens from one address to another address.

     * @param from The address to transfer tokens from

     * @param to The address to transfer tokens to

     * @param amount The amount of tokens to transfer

     * 

     * Requirements:

     * - from and to cannot be the zero address

     * - The from address must have a balance of at least amount

     * - The contract must have sufficient allowance from from to spend amount 

     * 

     * Emits a {Transfer} event.

     */

    function _transfer(

        address from, 

        address to, 

        uint amount

    ) internal virtual override {

        (uint fee,) = _processFee(from, to, amount);

        amount -= fee;

        super._transfer(from, to, amount);

    }



    /**

     * @notice Processes the fees for the transaction and returns the total fee and a flag indicating if the fee was taken.

     * 

     * @param from The address from which the tokens are transferred

     * @param to The address to which the tokens are transferred

     * @param amount The amount of tokens being transferred

     * 

     * @return fee The total fee amount

     * @return tookFee A boolean indicating if the fee was taken

     * 

     * Emits a {Transfer} event if any fee is transferred to another address.

     */

    function _processFee(

        address from, 

        address to, 

        uint amount

    ) internal virtual returns (

        uint fee, 

        bool tookFee

    ) {

        if (

            isExcludedFromFees[from] || 

            isExcludedFromFees[to] || 

            _processingFee

        ) {

            return (0, false);

        }



        _processingFee = true;

        

        uint teamAmount = _applyPercentage(amount, feePercentages[0]);

        if (teamAmount > 0 && teamWallet != address(0)) {

            fee += teamAmount;

            _transfer(from, address(this), teamAmount);

        }



        uint farmRewardAmount = _applyPercentage(amount, feePercentages[1]);

        if (farmRewardAmount > 0 && farmAddress != address(0)) {

            fee += farmRewardAmount;

            _transfer(from, farmAddress, farmRewardAmount);

        }



        uint minBalance = _applyPercentage(totalSupply(), minBalancePercentage);

        if (

            balanceOf(address(this)) >= minBalance &&

            from != address(pair)

        ) {

            _swapTokensForETH();

        }



        _processingFee = false;



        return (fee, true);

    }



    /**

     * @notice Swaps accumulated team fee tokens for ETH tokens.

     */

    function _swapTokensForETH() internal {

        uint swapAmount = balanceOf(address(this));

        if (swapAmount == 0) return;



        address[] memory swapPath = new address[](2);

        swapPath[0] = address(this);

        swapPath[1] = router.WETH();



        try 

            router.swapExactTokensForETH(

                swapAmount,

                0,

                swapPath,

                teamWallet,

                block.timestamp

            )

        {} catch {}

    }



    /**

     * @notice Initializes total supply of the token.

     * @param initSupply The initial total supply.

     */

    function _initTotalSupply(uint initSupply) internal virtual {

        require(!_totalSupplyInitialized, "initialized already");

        require(initSupply > 0, "0 total supply");



        _mint(owner(), initSupply);

        emit InitTotalSupply(initSupply);



        _totalSupplyInitialized = true;

    }



    // ================ VIEW FUNCTIONS ================ //



    /**

     * @notice Returns the total fee percentage applied to transactions.

     * @return totalFeePercentage The total fee percentage.

     */

    function getTotalFeePercentage() public view returns (

        uint totalFeePercentage

    ) {

        for (uint i; i < feePercentages.length; i++) {

            totalFeePercentage += feePercentages[i];

        }

    }



    /**

     * @notice This function is used to calculate the result of applying a percentage to a given value.

     * 

     * @param value The value to which the percentage will be applied.

     * @param percentage The percentage to apply to the value.

     * 

     * @return The result of applying the percentage to the value.

    */

    function _applyPercentage(

        uint value, 

        uint percentage

    ) internal pure returns (uint) {

        return value * percentage / HUNDRED_PERCENT;

    }

}





// File contracts/DebaseProtect.sol





pragma solidity =0.8.14;

/**

 * @notice An abstract contract for `DebaseToken` which adds functions to protect tokens from debasing.

 * @author iHux3

 */

abstract contract DebaseProtect {

    struct Depositor {

        uint amount;

        uint lockEndsAt;

    }



    uint public lockDuration;

    uint public totalDeposited;

    mapping(address => bool) public isExcludedFromDebase;



    mapping(address => Depositor) public depositors;



    event Deposit(address indexed depositor, uint amount);

    event Withdraw(address indexed depositor, uint amount);



    function _burn(address account, uint amount) internal virtual;

    function _mint(address account, uint amount) internal virtual;



    /**

     * @notice Allows users to deposit tokens and burn them in order to protect them from debasing.

     * 

     * @param amount The amount of tokens to deposit and burn.

     * 

     * @dev The deposited tokens are burned, reducing the total supply of tokens in circulation.

     * @dev The user's deposit amount is recorded, and the tokens are locked for a period of time, after which the user can withdraw them.

     * 

     * Requirements:

     * - The amount must be greater than 0.

     * - The user must not be excluded from debase in order to make a deposit.

     * 

     * @dev Emits a {Deposit} event with the user's address and deposit amount.

     */

    function deposit(uint amount) external {

        require(amount > 0, "zero amount");

        require(!isExcludedFromDebase[msg.sender], "excluded from debase");



        Depositor storage depositor = depositors[msg.sender];

        depositor.lockEndsAt = block.timestamp + lockDuration;

        _burn(msg.sender, amount);



        totalDeposited += amount;

        depositor.amount += amount;

        emit Deposit(msg.sender, amount);

    }



    /**

    * @notice Allows users to withdraw their protected deposited tokens by minting them.

    * 

    * @param amount The amount of tokens to withdraw.

    * 

    * Requirements:

    * - amount must be greater than 0.

    * - The depositor must have unlocked their deposit.

    * - The depositor must have enough deposited tokens.

    * 

    * Emits a {Withdraw} event.

    */

    function withdraw(uint amount) external {

        require(amount > 0, "zero amount");



        Depositor storage depositor = depositors[msg.sender];

        require(depositor.lockEndsAt <= block.timestamp, "locked");

        require(depositor.amount >= amount, "not enough amount");



        depositor.lockEndsAt = block.timestamp + lockDuration;

        depositor.amount -= amount;

        totalDeposited -= amount;

        _mint(address(msg.sender), amount);



        emit Withdraw(msg.sender, amount);

    }

}





// File contracts/DebaseToken.sol





pragma solidity =0.8.14;

/**

 * @dev `DebaseToken` extends `BaseToken` by adding decreasing (debasing) wallet balances.

 * @author iHux3

 */

contract DebaseToken is 

    BaseToken

{



    uint64 public constant BASE = 1e18;



    struct Parameters {

        uint32 startTime;

        uint32 debasePeriod;

        uint64 debaseRate;

    }



    uint private _underlyingTotalSupply;

    uint private _totalSupplyExcluded;

    mapping(address => uint) private _balances;



    uint32 public startTime;

    uint32 public debasePeriod;

    uint64 public debaseRate;

    uint64 public debaseFactor; 

    uint public lastDebaseTimestamp;



    mapping(address => bool) public isExcludedFromDebase;



    event ExcludeFromDebase(

        address addr, 

        bool excluded

    );



    event Debase(

        uint periodsPassed,

        uint debaseFactor

    );



    modifier withDebase() {

        _;

        debase();

    }



    /**

     * @notice Initializes the contract with the given parameters.

     * 

     * @param baseParameters The base token parameters.

     * @param parameters The debase token parameters.

    */

    constructor(

        BaseParameters memory baseParameters,

        Parameters memory parameters

    ) BaseToken(baseParameters) {

        require(parameters.startTime >= block.timestamp, "starts in past");

        require(parameters.debasePeriod > 0, "debase period zero");

        require(parameters.debaseRate > 0 && parameters.debaseRate < BASE / 2, "debase rate range");



        startTime = parameters.startTime;

        debasePeriod = parameters.debasePeriod;

        debaseRate = parameters.debaseRate;



        lastDebaseTimestamp = startTime;

        debaseFactor = BASE;



        isExcludedFromDebase[address(this)] = true;

        isExcludedFromDebase[address(pair)] = true;

    }



    // ================ EXTERNAL FUNCTIONS ================ //



    /**

     * @notice This function debases the token based on the `debaseRate` and `debasePeriod`.

     * 

     * @dev Decreases debaseFactor, resulting in a decrease of all wallets' non-underlying balances.

     * @dev If `debaseFactor` equals 1 or the current timestamp is less than `startTime`, this function will not execute.

     * @dev This function calculates the number of periods that have passed since the last time debase was called,

     * and updates debaseFactor accordingly. It limits the maximum number of periods to 1000.

     * 

     * Emits a {Debase} event with the number of periods passed and the updated `debaseFactor`.

     */

    function debase() public {

        uint currentTimestamp = block.timestamp;

        if (currentTimestamp < startTime || debaseFactor == 1) {

            return;

        }



        uint periodsPassed = (currentTimestamp - lastDebaseTimestamp) / debasePeriod;

        if (periodsPassed > 1000) {

            periodsPassed = 1000;

        }



        uint totalSupplyBefore = totalSupply();



        if (periodsPassed > 0) {

            uint64 _debaseFactor = debaseFactor;

            uint64 _debaseRate = debaseRate;



            for (uint i = 0; i < periodsPassed; i++) {

                _debaseFactor = uint64(uint(_debaseFactor) * (BASE - _debaseRate) / BASE);

            }



            debaseFactor = _debaseFactor;

            lastDebaseTimestamp += periodsPassed * debasePeriod;

            

            if (debaseFactor == 0) debaseFactor = 1;



            emit Debase(

                periodsPassed,

                debaseFactor

            );

        }



        uint totalSupplyAfter = totalSupply();



        uint debasedTokens = totalSupplyBefore - totalSupplyAfter;



        if (debasedTokens > 1) {

            _mint(farmAddress, debasedTokens / 2); // mint 50% as rewards for stakers

        }   

    }



    // ================ INTERNAL FUNCTIONS ================ //



    /**

     * @notice Transfer tokens from one address to another.

     * 

     * @param from The address to transfer tokens from

     * @param to The address to transfer tokens to

     * @param amount The amount of tokens to be transferred

     * 

     * @dev This function is internal and will only be called from within the contract.

     * It processes the transfer fees, converts the amount and fees to underlying, checks the balance of the from address,

     * updates the balances and total supply based on whether the addresses are excluded from debase or not.

     * 

     * Emits a {Transfer} event.

     */

    function _transfer(

        address from, 

        address to, 

        uint amount

    ) internal override withDebase {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");



        (uint fee, ) = _processFee(from, to, amount);



        uint underlyingAmount = convertToUnderlying(amount);

        uint underlyingFee = convertToUnderlying(fee);



        amount -= fee;

        underlyingAmount -= underlyingFee;



        uint fromBalance = _balances[from];

        if (!isExcludedFromDebase[from]) {

            require(

                fromBalance >= underlyingAmount, 

                "ERC20: transfer amount exceeds balance"

            );

            _balances[from] -= underlyingAmount;

        } else {

            require(

                fromBalance >= amount, 

                "ERC20: transfer amount exceeds balance"

            );

            _balances[from] -= amount;

            _totalSupplyExcluded -= amount;

            _underlyingTotalSupply += underlyingAmount;

        }



        if (!isExcludedFromDebase[to]) {

            _balances[to] += underlyingAmount;

        } else {

            _balances[to] += amount;

            _totalSupplyExcluded += amount;

            _underlyingTotalSupply -= underlyingAmount;

        }



        emit Transfer(from, to, amount);

    }



    /**

     * @notice Destroys amount tokens from account, reducing the total supply of the token.

     * 

     * @dev Decreases underlying balances (or non-underlying if the account is excluded from debase).

     * 

     * @param account The address of the account to burn tokens from.

     * @param amount The amount of tokens to burn.

     * 

     * Requirements:

     * - The account cannot be the zero address.

     * - The account must have at least amount tokens.

     * 

     * Emits a {Transfer} event with to set to the zero address.

     */

    function _burn(address account, uint amount) internal override withDebase {

        require(account != address(0), "ERC20: burn from the zero address");



        uint underlyingAmount = convertToUnderlying(amount);

        uint accountBalance = _balances[account];



        if (!isExcludedFromDebase[account]) {

            require(accountBalance >= underlyingAmount, "ERC20: burn amount exceeds balance");

            _balances[account] -= underlyingAmount;

            _underlyingTotalSupply -= underlyingAmount;

        } else {

            require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

            _balances[account] -= amount;

            _totalSupplyExcluded -= amount;

        }



        emit Transfer(account, address(0), amount);

    }



    /** 

     * @notice Mints new tokens to the specified account.

     * 

     * @dev Increases the balance of account and the underlying total supply by underlyingAmount.

     * 

     * @param account The account to receive the minted tokens.

     * @param amount The amount of tokens to mint.

     * 

     * Requirements:

     * - The account cannot be the zero address.

     * - The account must not be excluded from debase.

     * 

     * Emits a {Transfer} event with from address as the zero address and to address as the account address.

     */

    function _mint(address account, uint amount) internal override withDebase {

        require(account != address(0), "ERC20: burn from the zero address");



        uint underlyingAmount = convertToUnderlying(amount);



        if (!isExcludedFromDebase[account]) {

            _balances[account] += underlyingAmount;

            _underlyingTotalSupply += underlyingAmount;

        } else {

            _balances[account] += amount;

            _totalSupplyExcluded += amount;

        }



        emit Transfer(address(0), account, amount);

    }



     /**

     * @notice Initializes total supply of the token.

     * @param initSupply The initial total supply.

     */

    function _initTotalSupply(

        uint initSupply

    ) internal override {

        require(!_totalSupplyInitialized, "initialized already");

        require(initSupply > 0, "0 total supply");

        

        _underlyingTotalSupply = initSupply;

        _balances[owner()] = _underlyingTotalSupply;



        emit Transfer(address(0), owner(), initSupply);

        emit InitTotalSupply(initSupply);



        _totalSupplyInitialized = true;

    }

    

    // ================ VIEW FUNCTIONS ================ //



    /**

     * @notice Converts given amount of tokens to underlying asset units.

     * @param amount Amount of tokens to convert.

     * @return The equivalent amount of underlying asset units.

     */

    function convertToUnderlying(uint amount) public view returns (uint) {

        return amount * BASE / debaseFactor;

    }



    /**

     * @notice Converts a given amount of underlying token to its corresponding amount of token based on the current debase factor.

     * @param underlyingAmount The amount of underlying token to convert to token.

     * @return The corresponding amount of token based on the current debase factor.

     */

    function convertFromUnderlying(uint underlyingAmount) public view returns (uint) {

        return underlyingAmount * debaseFactor / BASE;

    }



    /**

     * @notice Get the balance of an address.

     * 

     * @dev If the address is excluded from debase, their balance is stored directly in the _balances mapping.

     * Otherwise, the balance is converted from underlying units to token units using the current debase factor.

     * 

     * @param account The address to get the balance for.

     * 

     * @return The balance of the address.

     */

    function balanceOf(

        address account

    ) public view override returns (uint) {

        if (isExcludedFromDebase[account]) {

            return _balances[account];

        }



        return convertFromUnderlying(_balances[account]);

    }



    /**

     * @notice Gets the token total supply.

     * @dev Gets total supply by converting underlying total supply and adding debase-excluded total supply.

     * @return The token total supply.

     */

    function totalSupply() public view override returns (uint) {

        return convertFromUnderlying(_underlyingTotalSupply) + _totalSupplyExcluded;

    }

}