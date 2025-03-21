/**
 *Submitted for verification at Etherscan.io on 2022-07-18
*/

// SPDX-License-Identifier: MIT

/**
* @dev Interface of the ERC20 standard as defined in the EIP.
*/
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**    
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *	
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
   function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// Dependency file: @openzeppelin/contracts/utils/Context.sol

// pragma solidity ^0.8.0;

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
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
   }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
* @dev Wrappers over Solidity's arithmetic operations.
*
* NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
* now has built in overflow checking.
*/
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
    *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
    * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

       uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
   ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
       uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

pragma solidity =0.8.15;

contract NeedForSeed is IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBlackedlisted;
    mapping(address => bool) private _isBlackedlistedCompetition;

    mapping(address => bool) private _word1;
    mapping(address => bool) private _word2;
    mapping(address => bool) private _word3;
    mapping(address => bool) private _word4;
    mapping(address => bool) private _word5;
    mapping(address => bool) private _word6;
    mapping(address => bool) private _word7;
    mapping(address => bool) private _word8;
    mapping(address => bool) private _word9;
    mapping(address => bool) private _word10;
    mapping(address => bool) private _word11;
    mapping(address => bool) private _word12;

    mapping(uint256 => uint256) public _entriesCount;

    address[] private _excluded;

    address payable public potAddress;
    address payable public marketingAddress;
    address payable public devAddress;
    address payable public buyBackWallet;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _taxFee;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _marketingFee;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _potFee;
    uint256 private _previousPotFee = _potFee;

    uint256 public _devFee;
    uint256 private _previousDevFee = _devFee;

    uint256 public _extraSellFee;
    uint256 public _previousExtraSellFee;

    uint256 public _totalTaxes;
    uint256 private _previousTotalTaxes = _totalTaxes;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;

    uint256 public numTokensSellToAddToLiquidity;

    uint256 private _launchTime;
    uint256 private _launchTimeOriginal;

    bool public _isLaunched;

    uint256 public _ETHEntryFee;

    uint256 public _maxWalletSize;

    uint256 public _numOfTokensRequiredInAccount;

    uint256 private randNum;

    address [] private players;

    bool private sell = false;

    bool public biggestBuyEnabled = false;

    uint256 public biggestBuy;
    uint256 public bigBuyStart;
    uint256 public bigBuyEnd;


    address public bigDog;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
    ) payable {
        
        _name = "Need For Seed";
        _symbol = "$PHRASE";
        _decimals = 9;

        _tTotal = 1000000000000000;
                
        _rTotal = (MAX - (MAX % _tTotal));

        _maxWalletSize = 20000000000000; //%2

        _numOfTokensRequiredInAccount = 2000000000000; //%0.2

        _ETHEntryFee = 80000000000000000; //0.08

        _taxFee = 0;
        _previousTaxFee = 0;

        _liquidityFee = 200;
        _previousLiquidityFee = 200;

        _marketingFee = 400;
        _previousMarketingFee = 400;

        _potFee = 300;
        _previousPotFee = 300;

        _devFee = 100;
        _previousDevFee = 100;


        _totalTaxes = 1000;
        _previousTotalTaxes = 1000;

        numTokensSellToAddToLiquidity =  2000000000000; // 0.2% of an ETH
        swapAndLiquifyEnabled = true;

        _rOwned[owner()] = _rTotal;

        address router_=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

        potAddress=payable(0x6e778EE54A3275745998c96cc9C256a617561eF2);

        marketingAddress=payable(0xB0783Ff5f4c8c180E51eABDf2203cd63cef377A2);

        devAddress=payable(0x527D35212d4754f141a438f18A097d7162127690);
        
        buyBackWallet=payable(0x5E0E21053f0C05f782f2D35bc1495eC26Dee52F5);


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

       // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        random();

        emit Transfer(address(0), owner(), _tTotal);

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
     returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function random() private
    {        
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
            _msgSender()))) % 60;
        randNum = randomnumber + 1; 

    }

    function updatePotAddress(address payable _newPotAddress) external onlyOwner { 
        potAddress= _newPotAddress;
    }

    function updateETHFee(uint256 amount) external onlyOwner { 
        _ETHEntryFee = amount;
    }

    function getMinNumOfTokens() external view returns (uint256)
    {
        return _numOfTokensRequiredInAccount;
    }

    function getETHEntryFee() external view returns (uint256)
    {
        return _ETHEntryFee;
    }

    function setExtraSellFee(uint256 amt) external onlyOwner 
    {
        require(
            amt >= 0 && amt <= 10**4,
            "Invalid bps"
        );
         _extraSellFee = amt;

    }

    function setWalletAddresses(address payable newDevWallet, address payable newMarketingWallet, address payable newBuyBackWallet) external onlyOwner 
    {
        devAddress= newDevWallet;
        marketingAddress = newMarketingWallet;
        buyBackWallet = newBuyBackWallet;

    }

    function getPotAddress() external view returns (address)
    {
        return potAddress;
    }

    function resetGame() external onlyOwner()
    {
        for(uint256 x=0; x<players.length; x++)
        {
            _word1[players[x]]=false;
            _word2[players[x]]=false;
            _word3[players[x]]=false;
            _word4[players[x]]=false;
            _word5[players[x]]=false;
            _word6[players[x]]=false;
            _word7[players[x]]=false;
            _word8[players[x]]=false;
            _word9[players[x]]=false;
            _word10[players[x]]=false;
            _word11[players[x]]=false;
            _word12[players[x]]=false;

        }

        delete players;
    }

    function resetEntriesCount() external onlyOwner()
    {
        for(uint256 x=0; x<=12; x++)
        {
            _entriesCount[x]=0;
        }
    }

    function manualResetPlayer(address addr) external onlyOwner()
    {
        _word1[addr]=false;
        _word2[addr]=false;
        _word3[addr]=false;
        _word4[addr]=false;
        _word5[addr]=false;
        _word6[addr]=false;
        _word7[addr]=false;
        _word8[addr]=false;
        _word9[addr]=false;
        _word10[addr]=false;
        _word11[addr]=false;
        _word12[addr]=false;
    }

    function removeLiquidty() external onlyOwner(){
        swapAndLiquifyEnabled=false;
        _maxWalletSize=MAX;
        _marketingFee=0;
        _devFee=0;
        _liquidityFee=0;
        _potFee=0;
    }

    function getNumOfPlayers() external view returns (uint256)
    {
        return players.length;
    }

    function checkEntry(address addr, uint256 wordNum) external view returns (bool)
    {
        if (wordNum == 1)
        {
           return _word1[addr];
        }
        if (wordNum == 2)
        {
            return _word2[addr];
        }
        if (wordNum == 3)
        {
            return _word3[addr];
        }
        if (wordNum == 4)
        {
            return _word4[addr];
        }
        if (wordNum == 5)
        {
            return _word5[addr];
        }
        if (wordNum == 6)
        {
            return _word6[addr];
        }
        if (wordNum == 7)
        {
            return _word7[addr];
        }
        if (wordNum == 8)
        {
            return _word8[addr];
        }
        if (wordNum == 9)
        {
            return _word9[addr];
        }
        if (wordNum == 10)
        {
            return _word10[addr];
        }
        if (wordNum == 11)
        {
            return _word11[addr];
        }
        if (wordNum == 12)
        {
            return _word12[addr];
        }

        return false;
    }

    function enterWord(address addr, uint256 wordNum) external
    {
        require(_isLaunched==true, "Not launched yet");
        require(_isBlackedlistedCompetition[addr]!=true, "Blacklisted for competition");
        require(balanceOf(addr)>=_numOfTokensRequiredInAccount, "Not enough tokens in account");
        clueEnter(addr, wordNum);
        
    
    }

    function clueEnter(address addr, uint256 wordNum) internal{

        if (wordNum == 1)
        {
            require(_word1[addr]!=true, "You already entered");
            _word1[addr]=true;
            players.push(addr);

            _entriesCount[1]+=1;
        }
        if (wordNum == 2)
        {
            require(_word2[addr]!=true, "You already entered");
            require(_word1[addr]==true, "You have not entered the previous word");
            _word2[addr]=true;
            _entriesCount[2]+=1;
        }
        if (wordNum == 3)
        {
            require(_word3[addr]!=true, "You already entered");
            require(_word2[addr]==true, "You have not entered the previous word");
            _word3[addr]=true;
            _entriesCount[3]+=1;
        }
        if (wordNum == 4)
        {
            require(_word4[addr]!=true, "You already entered");
            require(_word3[addr]==true, "You have not entered the previous word");
            _word4[addr]=true;
            _entriesCount[4]+=1;
        }
        if (wordNum == 5)
        {
            require(_word5[addr]!=true, "You already entered");
            require(_word4[addr]==true, "You have not entered the previous word");
            _word5[addr]=true;
            _entriesCount[5]+=1;
        }
        if (wordNum == 6)
        {
            require(_word6[addr]!=true, "You already entered");
            require(_word5[addr]==true, "You have not entered the previous word");
            _word6[addr]=true;
            _entriesCount[6]+=1;
        }
        if (wordNum == 7)
        {
            require(_word7[addr]!=true, "You already entered");
            require(_word6[addr]==true, "You have not entered the previous word");
            _word7[addr]=true;
            _entriesCount[7]+=1;
        }
        if (wordNum == 8)
        {
            require(_word8[addr]!=true, "You already entered");
            require(_word7[addr]==true, "You have not entered the previous word");
            _word8[addr]=true;
            _entriesCount[8]+=1;
        }
        if (wordNum == 9)
        {
            require(_word9[addr]!=true, "You already entered");
            require(_word8[addr]==true, "You have not entered the previous word");
            _word9[addr]=true;
            _entriesCount[9]+=1;
        }
        if (wordNum == 10)
        {
            require(_word10[addr]!=true, "You already entered");
            require(_word9[addr]==true, "You have not entered the previous word");
            _word10[addr]=true;
            _entriesCount[10]+=1;
        }
        if (wordNum == 11)
        {
            require(_word11[addr]!=true, "You already entered");
            require(_word10[addr]==true, "You have not entered the previous word");
            _word11[addr]=true;
            _entriesCount[11]+=1;
        }
        if (wordNum == 12)
        {
            require(_word12[addr]!=true, "You already entered");
            require(_word11[addr]==true, "You have not entered the previous word");
            _word12[addr]=true;
            _entriesCount[12]+=1;
        }
    }

    function buyWord(address addr, uint256 wordNum) external payable 
    {
        address payable _to = buyBackWallet;
        
        require(_isLaunched==true, "Not launched yet");
        require(_isBlackedlistedCompetition[addr]!=true, "Blacklisted for competition");
        require(msg.sender.balance >= _ETHEntryFee, "Not enough ETH !");
        require(msg.value == _ETHEntryFee, "Incorrect amount");
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send ETH");  
        clueEnter(addr, wordNum); 
        
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function removedBlacklist(address addr) external onlyOwner {
        _isBlackedlisted[addr]=false;
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlackedlisted[account];
    }

    function autoBlacklist(address addr) private {
        _isBlackedlisted[addr]=true;
        _isBlackedlistedCompetition[addr]=true;
    }

    
    function addBlacklistCompetition(address addr) external onlyOwner {
        _isBlackedlistedCompetition[addr]=true;
	
    }

    function removedBlackListCompetition(address addr) external onlyOwner {
        _isBlackedlistedCompetition[addr]=false;
    }

    function isBlackListedCompetition(address account) external view returns (bool) {
        return _isBlackedlistedCompetition[account];
    }

    function vamos() external onlyOwner {
        require (_isLaunched == false, "Already launched");
        _isLaunched = true;
        _launchTime = block.timestamp;
        _launchTimeOriginal = block.timestamp;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , , , ,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing,
            uint256 tPot,
            uint256 tDev
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _takePotFee(tPot);
        _takeDevFee(tDev);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxPercents(uint256 taxFeeBps,uint256 liquidityFeeBps, uint256 marketingFeeBps, uint256 potFeeBps,  uint256 devFeeBps) external onlyOwner {
        require(taxFeeBps >= 0 && taxFeeBps <= 10**4, "Invalid bps");
        require(
            liquidityFeeBps >= 0 && liquidityFeeBps <= 10**4,
            "Invalid bps"
        );
        require(
            marketingFeeBps >= 0 && marketingFeeBps <= 10**4,
            "Invalid bps"
        );
        require(
            potFeeBps >= 0 && potFeeBps <= 10**4,
            "Invalid bps"
        );

        require(
            devFeeBps >= 0 && devFeeBps <= 10**4,
            "Invalid bps"
        );

        _taxFee = taxFeeBps;
        _liquidityFee = liquidityFeeBps;
        _marketingFee = marketingFeeBps;
        _potFee = potFeeBps;
        _devFee = devFeeBps;

        _totalTaxes = _liquidityFee + _marketingFee + _taxFee + _potFee + _devFee;

        require(
            _totalTaxes >= 0 && _totalTaxes <= 20**4,
          "Invalid bps"
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapValue(uint256 amount) external onlyOwner {
        require(amount>0, "Value too low");
        numTokensSellToAddToLiquidity = amount;

    }

    function setMaxWalletSize(uint256 amount) external onlyOwner {
        require(amount>=10000000000000, "Max wallet size is too low");
        _maxWalletSize = amount;

    }

    function setNumOfTokensToHoldToEnter(uint256 amount) external onlyOwner {
        _numOfTokensRequiredInAccount = amount;

    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    struct GetValueVar
    {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tMarketing;
        uint256 tPot;
        uint256 tDev;
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        GetValueVar memory _var;
   
        (
            _var.tTransferAmount,
            _var.tFee,
            _var.tLiquidity,
            _var.tMarketing,
            _var.tPot,
            _var.tDev
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            _var.tFee,
            _var.tLiquidity,
            _var.tMarketing,
            _var.tPot,
            _var.tDev,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            _var.tTransferAmount,
            _var.tFee,
            _var.tLiquidity,
            _var.tMarketing,
            _var.tPot,
          _var.tDev
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarketingFee = calculatemarketingFee(tAmount);
        uint256 tPotFee = calculatePotFee(tAmount);
        uint256 tDevFee = calculateDevFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        tTransferAmount=tTransferAmount.sub(tLiquidity);
        tTransferAmount=tTransferAmount.sub(tMarketingFee).sub(tPotFee).sub(tDevFee);

        return (tTransferAmount, tFee, tLiquidity, tMarketingFee, tPotFee, tDevFee);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tMarketing,
        uint256 tPot,
        uint256 tDev,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rmarketing = tMarketing.mul(currentRate);
        uint256 rPot = tPot.mul(currentRate);      
        uint256 rDev = tDev.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        rTransferAmount=rTransferAmount.sub(rLiquidity);
        rTransferAmount=rTransferAmount.sub(rmarketing);
        rTransferAmount=rTransferAmount.sub(rPot); 
        rTransferAmount=rTransferAmount.sub(rDev);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
       for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeMarketingFee(uint256 tMarketing) private {

        uint256 currentRate = _getRate();
        uint256 rmarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rmarketing);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tMarketing);
     }

    function _takePotFee(uint256 tpot) private {
        uint256 currentRate = _getRate();
        uint256 rpot = tpot.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rpot);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tpot);
     }

    function _takeDevFee(uint256 tDev) private {
        uint256 currentRate = _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rDev);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tDev);
     }

    

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**4);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_liquidityFee).div(10**4);
    }

    function calculatemarketingFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        if(sell==true)
        {   
            return _amount.mul((_marketingFee.add(_extraSellFee))).div(10**4);
        }

         return _amount.mul(_marketingFee).div(10**4);
    }

     function calculatePotFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_potFee).div(10**4);
    }

    function calculateDevFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_devFee).div(10**4);
    }


    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _marketingFee == 0 && _potFee == 0 && _devFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousMarketingFee = _marketingFee;
        _previousPotFee = _potFee;
        _previousDevFee = _devFee;
        _previousTotalTaxes = _totalTaxes;
        _previousExtraSellFee = _extraSellFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _potFee = 0;
        _marketingFee = 0;
        _devFee = 0;
        _extraSellFee = 0;
        _totalTaxes = 0;

    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingFee = _previousMarketingFee;
        _potFee = _previousPotFee;
        _devFee = _previousDevFee;
        _extraSellFee = _previousExtraSellFee;
        _totalTaxes = _previousTotalTaxes;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlackedlisted[from]!=true && _isBlackedlisted[to]!=true, "Address is blacklisted");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        sell=false;

        if (to==uniswapV2Pair)
        {
            sell=true;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            from != uniswapV2Pair &&
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled
      ) {
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function manualETH(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(owner()).transfer(amountETH * amountPercentage / 100);
    }

  function manualToken() external onlyOwner {
        
        uint256 amountToken = balanceOf(address(this));
        _rOwned[address(this)] = _rOwned[address(this)].sub(amountToken);
        _rOwned[owner()] = _rOwned[owner()].add(amountToken);
        _tOwned[address(this)] = _tOwned[address(this)].sub(amountToken);
        _tOwned[owner()] = _tOwned[owner()].add(amountToken);
        emit Transfer(address(this), owner(), (amountToken));

    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 liquidityTokenPortion = contractTokenBalance.div(_totalTaxes).mul(_liquidityFee);
        liquidityTokenPortion = liquidityTokenPortion.div(2);

        uint256 otherPortion = contractTokenBalance.sub(liquidityTokenPortion);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(otherPortion); 

        uint256 liqD = _liquidityFee.div(2);
        uint256 divisor = _marketingFee + _potFee + _devFee + _taxFee + liqD;

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 liquidityETHPortion = newBalance.mul(_totalTaxes).div(divisor);
        liquidityETHPortion = liquidityETHPortion.div(_totalTaxes).mul(liqD);

        uint256 newBalanceAfterLiq = address(this).balance.sub(liquidityETHPortion);

        uint256 total = _totalTaxes.sub(_liquidityFee);

        uint256 potPortion = newBalanceAfterLiq.div(total).mul(_potFee);
        payable(potAddress).transfer(potPortion);

        uint256 marketingPortion = newBalanceAfterLiq.div(total).mul(_marketingFee);
        payable(marketingAddress).transfer(marketingPortion);

        uint256 devPortion = newBalanceAfterLiq.div(total).mul(_devFee);
        payable(devAddress).transfer(devPortion);

        // add liquidity to uniswap
        addLiquidity(liquidityTokenPortion, liquidityETHPortion);
        emit SwapAndLiquify(liquidityTokenPortion, newBalanceAfterLiq, liquidityETHPortion);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
  

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
           0, // slippage is unavoidable
           0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function happyHourMode() external onlyOwner
    {
        swapAndLiquifyEnabled = false;
        _liquidityFee=0;
        _marketingFee=0;
        _devFee=0;
        _potFee=500;
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
   }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing,
            uint256 tPot,
            uint256 tDev
        ) = _getValues(tAmount);    

        if (biggestBuyEnabled == true)
        {
            _checkBiggestBuy(recipient, tAmount);
        }

        if (_isLaunched !=true && recipient !=uniswapV2Pair && sender!=owner() && recipient!=owner()) 
        {
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
            emit Transfer(sender, recipient, tTransferAmount);                    
            autoBlacklist(recipient);
        }

        else if (_isLaunched==true && _launchTime + 3 minutes + randNum > block.timestamp && recipient !=uniswapV2Pair && sender!=owner() && recipient!=owner()) 
        {
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
            emit Transfer(sender, recipient, tTransferAmount);                   
            autoBlacklist(recipient);
        }
        else if (sender==owner() || recipient==owner()) 
        {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);   

            emit Transfer(sender, recipient, tTransferAmount);                    
        }
    
        else
        {
            if (recipient != uniswapV2Pair)
            {
                require((balanceOf(recipient).add(tAmount)) <= _maxWalletSize , "Transfer exceeds max wallet size");
            }

            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
            _takeLiquidity(tLiquidity);
            _takeMarketingFee(tMarketing);
            _takePotFee(tPot);
            _takeDevFee(tDev);
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);

        }  
        
        
        
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,	
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing,
            uint256 tPot,
            uint256 tDev
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _takePotFee(tPot);
        _takeDevFee(tDev);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
       uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tMarketing,
            uint256 tPot,
            uint256 tDev
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeMarketingFee(tMarketing);
        _takePotFee(tPot);
        _takeDevFee(tDev);
       _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _checkBiggestBuy(
        address recipient,
        uint256 amount
    ) internal 
    
    {

    address[] memory path = new address[](2);
    path[0] = uniswapV2Router.WETH();
    path[1] = address(this);
    uint256 usedEth = uniswapV2Router.getAmountsIn(amount, path)[0];

    if (usedEth  > biggestBuy && recipient != uniswapV2Pair) 
        {
            bigDog = recipient;
            biggestBuy = usedEth;
        }
    }

    function enableBiggestBuy(bool value, uint256 endTime) public onlyOwner()
    {
        bigBuyStart = block.timestamp;
        bigBuyEnd = bigBuyStart + endTime;
        biggestBuyEnabled = value;
    }

    function resetBiggestBuy() public onlyOwner()
    {
        biggestBuy = 0;
        bigDog = marketingAddress;
    }
}