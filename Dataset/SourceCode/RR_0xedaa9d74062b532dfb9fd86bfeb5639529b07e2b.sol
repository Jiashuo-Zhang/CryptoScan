// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol







/* 

    ____                _               ____             _      _   _       

    |  _ \ _   _ ___ ___(_) __ _ _ __   |  _ \ ___  _   _| | ___| |_| |_ ___ 

    | |_) | | | / __/ __| |/ _` | '_ \  | |_) / _ \| | | | |/ _ \ __| __/ _ \

    |  _ <| |_| \__ \__ \ | (_| | | | | |  _ < (_) | |_| | |  __/ |_| ||  __/

    |_| \_\\__,_|___/___/_|\__,_|_| |_| |_| \_\___/ \__,_|_|\___|\__|\__\___|

                                                                            

        _____              ____   ___    _____     _              

        | ____|_ __ ___    |___ \ / _ \  |_   _|__ | | _____ _ __  

        |  _| | '__/ __|____ __) | | | |   | |/ _ \| |/ / _ \ '_ \ 

        | |___| | | (_|_____/ __/| |_| |   | | (_) |   <  __/ | | |

        |_____|_|  \___|   |_____|\___/    |_|\___/|_|\_\___|_| |_|

        





    Welcome to the russian roulette of defi! 



    Holders are prized with a deflationary token and random loots.



    The high stakes come into play when holders decide to sell:

    this is when they play Russian Roulette: every time a holder approves a

    sale, there's a chance (starting at 1/6 in the first week from their

    first buy and gradually decreasing to 1/20 after one month) that they may

    not win the game. 

    In such a scenario, half of their balance will be burned, and the other

    half will be randomly distributed to another lucky holder.



    After 4 weeks of holding there will be no more approve risk.



    Approvals only last one sell transaction.



    A true game of luck and generosity.

    



    Good luck!





    Telegram: https://t.me/ruRouletteToken

     Twitter: https://twitter.com/ruRouletteToken

        Site: https://rr-token.eth.limo



*/





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



// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol



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



// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol



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



// File: @openzeppelin/contracts/utils/Address.sol





// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)



pragma solidity ^0.8.1;



/**

 * @dev Collection of functions related to the address type

 */

library Address {

    /**

     * @dev Returns true if `account` is a contract.

     *

     * [IMPORTANT]

     * ====

     * It is unsafe to assume that an address for which this function returns

     * false is an externally-owned account (EOA) and not a contract.

     *

     * Among others, `isContract` will return false for the following

     * types of addresses:

     *

     *  - an externally-owned account

     *  - a contract in construction

     *  - an address where a contract will be created

     *  - an address where a contract lived, but was destroyed

     *

     * Furthermore, `isContract` will also return true if the target contract within

     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,

     * which only has an effect at the end of a transaction.

     * ====

     *

     * [IMPORTANT]

     * ====

     * You shouldn't rely on `isContract` to protect against flash loan attacks!

     *

     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets

     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract

     * constructor.

     * ====

     */

    function isContract(address account) internal view returns (bool) {

        // This method relies on extcodesize/address.code.length, which returns 0

        // for contracts in construction, since the code is only stored at the end

        // of the constructor execution.



        return account.code.length > 0;

    }



    /**

     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to

     * `recipient`, forwarding all available gas and reverting on errors.

     *

     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost

     * of certain opcodes, possibly making contracts go over the 2300 gas limit

     * imposed by `transfer`, making them unable to receive funds via

     * `transfer`. {sendValue} removes this limitation.

     *

     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].

     *

     * IMPORTANT: because control is transferred to `recipient`, care must be

     * taken to not create reentrancy vulnerabilities. Consider using

     * {ReentrancyGuard} or the

     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].

     */

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        (bool success, ) = recipient.call{value: amount}("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



    /**

     * @dev Performs a Solidity function call using a low level `call`. A

     * plain `call` is an unsafe replacement for a function call: use this

     * function instead.

     *

     * If `target` reverts with a revert reason, it is bubbled up by this

     * function (like regular Solidity function calls).

     *

     * Returns the raw returned data. To convert to the expected return value,

     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].

     *

     * Requirements:

     *

     * - `target` must be a contract.

     * - calling `target` with `data` must not revert.

     *

     * _Available since v3.1._

     */

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, "Address: low-level call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with

     * `errorMessage` as a fallback revert reason when `target` reverts.

     *

     * _Available since v3.1._

     */

    function functionCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but also transferring `value` wei to `target`.

     *

     * Requirements:

     *

     * - the calling contract must have an ETH balance of at least `value`.

     * - the called Solidity function must be `payable`.

     *

     * _Available since v3.1._

     */

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }



    /**

     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but

     * with `errorMessage` as a fallback revert reason when `target` reverts.

     *

     * _Available since v3.1._

     */

    function functionCallWithValue(

        address target,

        bytes memory data,

        uint256 value,

        string memory errorMessage

    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        (bool success, bytes memory returndata) = target.call{value: value}(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but performing a static call.

     *

     * _Available since v3.3._

     */

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],

     * but performing a static call.

     *

     * _Available since v3.3._

     */

    function functionStaticCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal view returns (bytes memory) {

        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but performing a delegate call.

     *

     * _Available since v3.4._

     */

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],

     * but performing a delegate call.

     *

     * _Available since v3.4._

     */

    function functionDelegateCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        (bool success, bytes memory returndata) = target.delegatecall(data);

        return verifyCallResultFromTarget(target, success, returndata, errorMessage);

    }



    /**

     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling

     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.

     *

     * _Available since v4.8._

     */

    function verifyCallResultFromTarget(

        address target,

        bool success,

        bytes memory returndata,

        string memory errorMessage

    ) internal view returns (bytes memory) {

        if (success) {

            if (returndata.length == 0) {

                // only check isContract if the call was successful and the return data is empty

                // otherwise we already know that it was a contract

                require(isContract(target), "Address: call to non-contract");

            }

            return returndata;

        } else {

            _revert(returndata, errorMessage);

        }

    }



    /**

     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the

     * revert reason or using the provided one.

     *

     * _Available since v4.3._

     */

    function verifyCallResult(

        bool success,

        bytes memory returndata,

        string memory errorMessage

    ) internal pure returns (bytes memory) {

        if (success) {

            return returndata;

        } else {

            _revert(returndata, errorMessage);

        }

    }



    function _revert(bytes memory returndata, string memory errorMessage) private pure {

        // Look for revert reason and bubble it up if present

        if (returndata.length > 0) {

            // The easiest way to bubble the revert reason is using memory via assembly

            /// @solidity memory-safe-assembly

            assembly {

                let returndata_size := mload(returndata)

                revert(add(32, returndata), returndata_size)

            }

        } else {

            revert(errorMessage);

        }

    }

}



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)



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

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol





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



// File: @openzeppelin/contracts/utils/Context.sol





// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)



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



    function _contextSuffixLength() internal view virtual returns (uint256) {

        return 0;

    }

}



// File: @openzeppelin/contracts/token/ERC20/ERC20.sol





// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)



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

 * The default value of {decimals} is 18. To change this, you should override

 * this function so it returns a different value.

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

     * Ether and Wei. This is the default value returned by this function, unless

     * it's overridden.

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

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {

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

    function _transfer(address from, address to, uint256 amount) internal virtual {

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

    function _approve(address owner, address spender, uint256 amount) internal virtual {

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

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {

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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}



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

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}



// File: @openzeppelin/contracts/access/Ownable.sol





// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)



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

     * `onlyOwner` functions. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby disabling any functionality that is only available to the owner.

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



// File: RR.sol







/* 

    ____                _               ____             _      _   _       

    |  _ \ _   _ ___ ___(_) __ _ _ __   |  _ \ ___  _   _| | ___| |_| |_ ___ 

    | |_) | | | / __/ __| |/ _` | '_ \  | |_) / _ \| | | | |/ _ \ __| __/ _ \

    |  _ <| |_| \__ \__ \ | (_| | | | | |  _ < (_) | |_| | |  __/ |_| ||  __/

    |_| \_\\__,_|___/___/_|\__,_|_| |_| |_| \_\___/ \__,_|_|\___|\__|\__\___|

                                                                            

        _____              ____   ___    _____     _              

        | ____|_ __ ___    |___ \ / _ \  |_   _|__ | | _____ _ __  

        |  _| | '__/ __|____ __) | | | |   | |/ _ \| |/ / _ \ '_ \ 

        | |___| | | (_|_____/ __/| |_| |   | | (_) |   <  __/ | | |

        |_____|_|  \___|   |_____|\___/    |_|\___/|_|\_\___|_| |_|

        





    Welcome to the russian roulette of defi! 



    Holders are prized with a deflationary token and random loots.



    The high stakes come into play when holders decide to sell:

    this is when they play Russian Roulette: every time a holder approves a

    sale, there's a chance (starting at 1/6 in the first week from their

    first buy and gradually decreasing to 1/20 after one month) that they may

    not win the game. 

    In such a scenario, half of their balance will be burned, and the other

    half will be randomly distributed to another lucky holder.



    After 4 weeks of holding there will be no more approve risk.



    Approvals only last one sell transaction.



    A true game of luck and generosity.

    



    Good luck!





    Telegram: https://t.me/ruRouletteToken

     Twitter: https://twitter.com/ruRouletteToken

        Site: https://rr-token.eth.limo



*/



pragma solidity ^0.8.21;













contract RR is ERC20, Ownable {

    using Address for address payable;



    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;



    uint256 public constant BUY_FEE = 5;

    uint256 public constant SELL_FEE = 5;

    uint256 public constant TRANSFER_FEE = 5;

    uint256 public constant SPONSOR_CUT_DENOMINATOR = 3;



    address public teamWallet;

    address public sponsorWallet;



    mapping(address => bool) private _excludedFromConstraints;

    uint256 public maxWalletAmount;



    bool public launched = false;

    uint256 public launchBlock = type(uint256).max;

    uint256 public launchTime;



    bool private _inTHEloop;



    bool public noBotsAllowed = false;



    address[] private _holdersArray;

    struct HolderToArrayIndex {

        bool isPresent;

        uint256 atIndex;

    }

    mapping(address => HolderToArrayIndex) private _holderToArrayIndex;



    mapping(address => address[]) private _approved;

    mapping(address => uint256) private _lastAllowance;

    mapping(address => uint256) private _firstBuy;



    uint256 private _dust;



    event Bang(address indexed from, uint256 amount);

    event Loot(address indexed to, address indexed from, uint256 amount);



    constructor() payable ERC20("Russian Roulette ERC20", "RR") {

        if (

            block.chainid == 1 || block.chainid == 5 || block.chainid == 31337

        ) {

            uniswapV2Router = IUniswapV2Router02(

                0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

            );

        } else {

            revert("Constructor failed. Sorry.");

        }



        _excludedFromConstraints[address(this)] = true;

        _excludedFromConstraints[address(0xdead)] = true;

        _excludedFromConstraints[address(0x0)] = true;



        _approve(address(this), address(uniswapV2Router), type(uint256).max);



        uint256 _maxSupply = 1e9 * (10 ** decimals());

        _mint(address(this), _maxSupply);

        maxWalletAmount = (totalSupply() * 30) / 1_000; // 3.00% or 30M $RR

        _dust = (totalSupply()) / 10_000_000; // 100 Tokens



        teamWallet = _msgSender();

        sponsorWallet = _msgSender();

    }



    function launch() external onlyOwner {

        require(!launched, "Already launched.");



        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(

                address(this),

                uniswapV2Router.WETH()

            );

        _approve(address(this), address(uniswapV2Pair), type(uint256).max);

        IERC20(uniswapV2Pair).approve(

            address(uniswapV2Router),

            type(uint256).max

        );



        uniswapV2Router.addLiquidityETH{value: address(this).balance}(

            address(this),

            balanceOf(address(this)),

            0,

            0,

            teamWallet,

            block.timestamp

        );



        launchBlock = block.number;

        launchTime = block.timestamp;

        launched = true;

    }



    function approve(

        address spender,

        uint256 amount

    ) public virtual override returns (bool) {

        require(

            _isExcludedFromConstraints(msg.sender) ||

                (balanceOf(_msgSender()) > 0),

            "Balance must be greater than 0"

        );

        // anti cheat

        if (noBotsAllowed) {

            require(

                _isExcludedFromConstraints(msg.sender) ||

                    !Address.isContract(msg.sender),

                "No bots allowed"

            );

        }

        uint256 randomNumber = _randomNumber();



        if (!_lucky(randomNumber)) {

            _bang(randomNumber);

            return true;

        }



        // this branch should cost more gas than _bang() branch

        // or users may cheat making the tx fail if it takes the _bang() branch

        _spendGas();



        _approved[_msgSender()].push(spender);

        _lastAllowance[_msgSender()] = block.number;



        return super.approve(spender, amount);

    }



    function _lucky(uint256 randomNumber) private view returns (bool) {

        if (_isExcludedFromConstraints(_msgSender())) {

            return true;

        }



        if (currentDice(_msgSender()) == 0) {

            return true;

        }



        // Roll the dice

        uint256 random = (randomNumber % currentDice(_msgSender())) + 1;



        // Rolling 1 is not lucky

        return random != 1;

    }



    function _randomNumber() private view returns (uint256) {

        // yeah, we know...

        return

            uint256(

                keccak256(

                    abi.encodePacked(

                        block.timestamp,

                        _msgSender(),

                        block.number,

                        _holdersArray.length,

                        block.basefee,

                        block.prevrandao

                    )

                )

            );

    }



    function currentDice(address address_) public view returns (uint256) {

        require(_isHolder(address_), "address is not holder");

        if (block.timestamp > _firstBuy[_msgSender()] + (4 weeks)) {

            return 0;

        } else if (block.timestamp > _firstBuy[address_] + (3 weeks)) {

            return 20;

        } else if (block.timestamp > _firstBuy[address_] + (2 weeks)) {

            return 12;

        } else if (block.timestamp > _firstBuy[address_] + (1 weeks)) {

            return 8;

        } else {

            return 6;

        }

    }



    function _bang(uint256 randomNumber) private {

        // sic

        uint256 arrayIndex = randomNumber % (_holdersArray.length);

        address winner = _holdersArray[arrayIndex];

        uint256 amount = balanceOf(_msgSender());

        uint256 halfAmount = amount / 2;

        _burn(_msgSender(), amount - halfAmount);

        _transfer(_msgSender(), winner, halfAmount);

        emit Bang(_msgSender(), halfAmount);

        emit Loot(winner, _msgSender(), halfAmount);

    }



    function _spendGas() private pure {

        for (uint256 i = 0; i < 400; i++) {}

    }



    // solhint-disable-next-line function-max-lines

    function _transfer(

        address from,

        address to,

        uint256 amount

    ) internal override {

        require(from != address(0), "Transfer from 0x0");

        require(to != address(0), "Transfer to 0x0");

        require(

            launched ||

                _isExcludedFromConstraints(from) ||

                _isExcludedFromConstraints(to),

            "Not launched yet"

        );



        if (amount == 0) {

            super._transfer(from, to, 0);

            return;

        }



        if (!_inTHEloop && to == uniswapV2Pair && launched) {

            _inTHEloop = true;

            _swapAndSendTeamAndSponsor();

            _inTHEloop = false;

        }



        uint256 _buyFee;

        uint256 _sellFee;

        bool _isSelling = false;



        if (block.timestamp > launchTime + (5 minutes)) {

            _buyFee = BUY_FEE;

            _sellFee = SELL_FEE;

        } else if (block.timestamp > launchTime + (4 minutes)) {

            _buyFee = 8;

            _sellFee = 12;

        } else if (block.timestamp > launchTime + (3 minutes)) {

            _buyFee = 12;

            _sellFee = 20;

        } else if (block.timestamp > launchTime + (2 minutes)) {

            _buyFee = 20;

            _sellFee = 30;

        } else if (block.timestamp > launchTime + (1 minutes)) {

            _buyFee = 28;

            _sellFee = 35;

        } else {

            _buyFee = 35;

            _sellFee = 39;

        }



        uint256 _totalFees;



        if (

            _isExcludedFromConstraints(from) ||

            _isExcludedFromConstraints(to) ||

            _inTHEloop

        ) {

            _totalFees = 0;

        } else if (from == uniswapV2Pair) {

            if (block.number <= launchBlock) {

                _totalFees = 99;

            } else {

                // buying and not excluded from constraints

                _totalFees = _buyFee;

                _updateFirstBuyMappingOnBuy(to);

            }

        } else if (to == uniswapV2Pair || Address.isContract(to)) {

            // selling and not excluded from constraints

            _totalFees = _sellFee;

            _isSelling = true;

            require(

                _lastAllowance[_msgSender()] < block.number,

                "Please wait next block"

            );

        } else {

            // transfer between addresses

            _totalFees = TRANSFER_FEE;

        }



        if (_totalFees > 0) {

            uint256 fees = (amount * _totalFees) / 100;

            amount = amount - fees;

            super._transfer(from, address(this), fees);

        }



        // maxWalletAmount check

        if (

            !_isExcludedFromConstraints(to) &&

            to != address(uniswapV2Router) &&

            to != uniswapV2Pair

        ) {

            uint256 balance = balanceOf(to);

            require(

                balance + amount <= maxWalletAmount,

                "Exceeds the maxWalletAmount"

            );

        }



        super._transfer(from, to, amount);



        if (_isSelling) {

            _resetCountersOnSell(from);

        }



        _updateHolders(from, to);

    }



    function _updateHolders(address from, address to) private {

        // to

        if (

            !(_isExcludedFromConstraints(to) || Address.isContract(to)) &&

            !_isHolder(to) &&

            balanceOf(to) >= _dust

        ) {

            _addHolder(to);

        }



        // from

        if (balanceOf(from) <= _dust) {

            _removeHolder(from);

        }

    }



    function _isHolder(address address_) private view returns (bool) {

        return _holderToArrayIndex[address_].isPresent;

    }



    function _addHolder(address address_) private {

        if (!_isHolder(address_)) {

            _holderToArrayIndex[address_].atIndex = _holdersArray.length;

            _holderToArrayIndex[address_].isPresent = true;

            _holdersArray.push(address_);

        }

    }



    function _removeHolder(address address_) private {

        if (_holderToArrayIndex[address_].isPresent) {

            // overwriting the element to remove with the last one in the array

            // and then remove last element of the array

            address lastAddress = _holdersArray[_holdersArray.length - 1];

            uint256 indexToReplace = _holderToArrayIndex[address_].atIndex;

            _holderToArrayIndex[lastAddress].atIndex = indexToReplace;

            _holdersArray[indexToReplace] = lastAddress;

            _holdersArray.pop();

            // deleting _holderAddressToHolderIndex reference to removed address

            delete _holderToArrayIndex[address_];

        }

    }



    function _resetCountersOnSell(address sellerAddress_) private {

        if (_isExcludedFromConstraints(sellerAddress_)) {

            return;

        }



        _resetApproves(sellerAddress_);

        _updateFirstBuyMappingOnSell(sellerAddress_);

    }



    function _resetApproves(address address_) private {

        for (uint256 i = 0; i < _approved[address_].length; i++) {

            super._approve(address_, _approved[address_][i], 0);

        }



        delete _approved[address_];

        _lastAllowance[address_] = 0;

    }



    function swapAndSendTeamAndSponsor() external onlyOwnerOrTeam {

        _swapAndSendTeamAndSponsor();

    }



    function _updateFirstBuyMappingOnBuy(address address_) private {

        if (_firstBuy[address_] == 0x0) {

            _firstBuy[address_] = block.timestamp;

        }

    }



    function _updateFirstBuyMappingOnSell(address address_) private {

        // must run after the swap

        if (balanceOf(address_) <= _dust) {

            delete _firstBuy[address_];

        }

    }



    function _swapAndSendTeamAndSponsor() private {

        uint256 tokenAmount = balanceOf(address(this));



        address[] memory path = new address[](2);

        path[0] = address(this);

        path[1] = uniswapV2Router.WETH();



        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(

            tokenAmount,

            0,

            path,

            address(this),

            block.timestamp

        );



        uint256 balance = address(this).balance;

        if (teamWallet == sponsorWallet) {

            payable(teamWallet).sendValue(balance);

        } else {

            uint256 sponsorAmount = address(this).balance /

                SPONSOR_CUT_DENOMINATOR;

            payable(teamWallet).sendValue(balance - sponsorAmount);

            payable(sponsorWallet).sendValue(sponsorAmount);

        }

    }



    function _isExcludedFromConstraints(

        address address_

    ) private view returns (bool) {

        if (address_ == teamWallet || address_ == owner()) {

            return true;

        }

        return _excludedFromConstraints[address_];

    }



    function setNoBotsAllowed(bool newValue_) external onlyOwnerOrTeam {

        noBotsAllowed = newValue_;

    }



    receive() external payable {}



    function claimStuckTokens(address token) external onlyOwnerOrTeam {

        if (token == address(0x0)) {

            payable(msg.sender).sendValue(address(this).balance);

            return;

        }

        IERC20 tokenContract = IERC20(token);

        uint256 balance = tokenContract.balanceOf(address(this));

        tokenContract.transfer(msg.sender, balance);

    }



    function setTeamWallet(address newTeamWallet) external onlyOwnerOrTeam {

        require(newTeamWallet != address(0), "Team wallet cannot be 0x0");

        teamWallet = newTeamWallet;

    }



    function setExcludedFromConstraints(

        address account,

        bool value

    ) external onlyOwnerOrTeam {

        _excludedFromConstraints[account] = value;

    }



    function setMaxWalletAmount(uint256 amount) external onlyOwnerOrTeam {

        maxWalletAmount = amount;

    }



    function setDust(uint256 value) external onlyOwnerOrTeam {

        _dust = value;

    }



    function setSponsorWallet(address sponsorWallet_) external onlySponsor {

        require(sponsorWallet_ != address(0), "wallet cannot be 0x0");

        sponsorWallet = sponsorWallet_;

    }



    modifier onlyOwnerOrTeam() {

        require(

            _msgSender() == owner() || _msgSender() == teamWallet,

            "Caller is not allowed"

        );

        _;

    }



    modifier onlySponsor() {

        require(_msgSender() == sponsorWallet, "Caller is not allowed");

        _;

    }

}