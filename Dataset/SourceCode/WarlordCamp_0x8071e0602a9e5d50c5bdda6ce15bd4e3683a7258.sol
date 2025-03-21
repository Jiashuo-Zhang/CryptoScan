/**

 *Submitted for verification at Etherscan.io on 2020-10-04

*/



pragma solidity ^0.5.0;



/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.

 *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 */

library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `+` operator.

     *

     * Requirements:

     * - Addition cannot overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     *

     * _Available since v2.4.0._

     */

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Returns the multiplication of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `*` operator.

     *

     * Requirements:

     * - Multiplication cannot overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0, errorMessage);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts with custom message when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see {ERC20Detailed}.

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

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



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



contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name, string memory symbol) public {

        _name = name;

        _symbol = symbol;

        _decimals = 18;

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @dev Returns the symbol of the token, usually a shorter version of the

     * name.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the number of decimals used to get its user representation.

     * For example, if `decimals` equals `2`, a balance of `505` tokens should

     * be displayed to a user as `5,05` (`505 / 10 ** 2`).

     *

     * Tokens usually opt for a value of 18, imitating the relationship between

     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is

     * called.

     *

     * NOTE: This information is only used for _display_ purposes: it in

     * no way affects any of the arithmetic of the contract, including

     * {IERC20-balanceOf} and {IERC20-transfer}.

     */



    function decimals() public view returns (uint8) {

        return _decimals;

    }

    

    /**

     * @dev See {IERC20-totalSupply}.

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See {IERC20-balanceOf}.

     */

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }



    /**

     * @dev See {IERC20-transfer}.

     *

     * Requirements:

     *

     * - `recipient` cannot be the zero address.

     * - the caller must have a balance of at least `amount`.

     */

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    /**

     * @dev See {IERC20-allowance}.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];

    }



    /**

     * @dev See {IERC20-approve}.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(msg.sender, spender, amount);

        return true;

    }



    /**

     * @dev See {IERC20-transferFrom}.

     *

     * Emits an {Approval} event indicating the updated allowance. This is not

     * required by the EIP. See the note at the beginning of {ERC20};

     *

     * Requirements:

     * - `sender` and `recipient` cannot be the zero address.

     * - `sender` must have a balance of at least `amount`.

     * - the caller must have allowance for `sender`'s tokens of at least

     * `amount`.

     */

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));

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

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));

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

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    /**

     * @dev Moves tokens `amount` from `sender` to `recipient`.

     *

     * This is internal function is equivalent to {transfer}, and can be used to

     * e.g. implement automatic token fees, slashing mechanisms, etc.

     *

     * Emits a {Transfer} event.

     *

     * Requirements:

     *

     * - `sender` cannot be the zero address.

     * - `recipient` cannot be the zero address.

     * - `sender` must have a balance of at least `amount`.

     */

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    /** @dev Creates `amount` tokens and assigns them to `account`, increasing

     * the total supply.

     *

     * Emits a {Transfer} event with `from` set to the zero address.

     *

     * Requirements

     *

     * - `to` cannot be the zero address.

     */

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");



        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`, reducing the

     * total supply.

     *

     * Emits a {Transfer} event with `to` set to the zero address.

     *

     * Requirements

     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens.

     */

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");



        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

    }



    /**

     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.

     *

     * This is internal function is equivalent to `approve`, and can be used to

     * e.g. set automatic allowances for certain subsystems, etc.

     *

     * Emits an {Approval} event.

     *

     * Requirements:

     *

     * - `owner` cannot be the zero address.

     * - `spender` cannot be the zero address.

     */

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted

     * from the caller's allowance.

     *

     * See {_burn} and {_approve}.

     */

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);

        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));

    }

}



contract MultiOwnable {

  address[] private _owner;



  event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);



  constructor() internal {

    _owner.push(msg.sender);

    emit OwnershipTransferred(address(0), _owner[0]);

  }



  function checkOwner() private view returns (bool) {

    for (uint8 i = 0; i < _owner.length; i++) {

      if (_owner[i] == msg.sender) {

        return true;

      }

    }

    return false;

  }



  function checkNewOwner(address _address) private view returns (bool) {

    for (uint8 i = 0; i < _owner.length; i++) {

      if (_owner[i] == _address) {

        return false;

      }

    }

    return true;

  }



  modifier isAnOwner() {

    require(checkOwner(), "Ownable: caller is not the owner");

    _;

  }



  function renounceOwnership() public isAnOwner {

    for (uint8 i = 0; i < _owner.length; i++) {

      if (_owner[i] == msg.sender) {

        _owner[i] = address(0);

        emit OwnershipTransferred(_owner[i], msg.sender);

      }

    }

  }



  function getOwners() public view returns (address[] memory) {

    return _owner;

  }



  function addOwnerShip(address newOwner) public isAnOwner {

    _addOwnerShip(newOwner);

  }



  function _addOwnerShip(address newOwner) internal {

    require(newOwner != address(0), "Ownable: new owner is the zero address");

    require(checkNewOwner(newOwner), "Owner already exists");

    _owner.push(newOwner);

    emit OwnershipTransferred(_owner[_owner.length - 1], newOwner);

  }

}



contract WarLordToken is MultiOwnable, ERC20{

    constructor (string memory name, string memory symbol) public ERC20(name, symbol) MultiOwnable(){

    

	}

	

	function warlordMint(address account, uint256 amount) external isAnOwner{

        _mint(account, amount);

    }



    function warlordBurn(address account, uint256 amount) external isAnOwner{

        _burn(account, amount);

    }

	

	function addOwner(address _newOwner) external isAnOwner {

        addOwnerShip(_newOwner);

    }



    function getOwner() external view isAnOwner{

        getOwners();

    }



    function renounceOwner() external isAnOwner {

        renounceOwnership();

    }

}





/**

 * @dev Optional functions from the ERC20 standard.

 */

contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    /**

     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of

     * these values are immutable: they can only be set once during

     * construction.

     */

    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @dev Returns the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @dev Returns the symbol of the token, usually a shorter version of the

     * name.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @dev Returns the number of decimals used to get its user representation.

     * For example, if `decimals` equals `2`, a balance of `505` tokens should

     * be displayed to a user as `5,05` (`505 / 10 ** 2`).

     *

     * Tokens usually opt for a value of 18, imitating the relationship between

     * Ether and Wei.

     *

     * NOTE: This information is only used for _display_ purposes: it in

     * no way affects any of the arithmetic of the contract, including

     * {IERC20-balanceOf} and {IERC20-transfer}.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



/**

 * @dev Collection of functions related to the address type,

 */

library Address {

    /**

     * @dev Returns true if `account` is a contract.

     *

     * This test is non-exhaustive, and there may be false-negatives: during the

     * execution of a contract's constructor, its address will be reported as

     * not containing a contract.

     *

     * > It is unsafe to assume that an address for which this function returns

     * false is an externally-owned account (EOA) and not a contract.

     */

    function isContract(address account) internal view returns (bool) {

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

    }

}



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */



library SafeERC20 {

    using SafeMath for uint256;

    using Address for address;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        // solhint-disable-next-line max-line-length

        require((value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves.



        // A Solidity high level call has three parts:

        //  1. The target address is checked to verify it contains contract code

        //  2. The call itself is made, and success asserted

        //  3. The return value is decoded, which in turn checks the size of the returned data.

        // solhint-disable-next-line max-line-length

        require(address(token).isContract(), "SafeERC20: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = address(token).call(data);

        require(success, "SafeERC20: low-level call failed");



        if (returndata.length > 0) { // Return data is optional

            // solhint-disable-next-line max-line-length

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}





/**

 * @dev Contract module that helps prevent reentrant calls to a function.

 *

 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier

 * available, which can be applied to functions to make sure there are no nested

 * (reentrant) calls to them.

 *

 * Note that because there is a single `nonReentrant` guard, functions marked as

 * `nonReentrant` may not call one another. This can be worked around by making

 * those functions `private`, and then adding `external` `nonReentrant` entry

 * points to them.

 *

 * TIP: If you would like to learn more about reentrancy and alternative ways

 * to protect against it, check out our blog post

 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].

 *

 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas

 * metering changes introduced in the Istanbul hardfork.

 */

contract ReentrancyGuard {

    bool private _notEntered;



    constructor () internal {

        // Storing an initial non-zero value makes deployment a bit more

        // expensive, but in exchange the refund on every call to nonReentrant

        // will be lower in amount. Since refunds are capped to a percetange of

        // the total transaction's gas, it is best to keep them low in cases

        // like this one, to increase the likelihood of the full refund coming

        // into effect.

        _notEntered = true;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        // On the first call to nonReentrant, _notEntered will be true

        require(_notEntered, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _notEntered = false;



        _;



        // By storing the original value once again, a refund is triggered (see

        // https://eips.ethereum.org/EIPS/eip-2200)

        _notEntered = true;

    }

}





/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be applied to your functions to restrict their use to

 * the owner.

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        address msgSender = msg.sender;

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Returns true if the caller is the current owner.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract WarlordCamp is Ownable, ReentrancyGuard {

	using SafeMath for uint256;

	using SafeERC20 for WarLordToken;

	using SafeERC20 for IERC20;



	uint256 private _epochCampkStart;

	uint8 private _warriorTOknight;

	uint8 private _knightTOlegend;

	

	uint256 private _legedWarLordfirstReward;

	uint256 private _legedWarLordotherReward;

	uint256 private _decimalConverter = 10**18;



	struct  warlordToken{

		WarLordToken token;

		uint256 totalSupply;

		uint256 durationReward;

		mapping(address => uint256)  balances;

		mapping(address => uint256)  periodFinish;

		mapping(address => uint256)  countReward;

	}



	warlordToken[4] private _warlordToken;



	constructor(address _WarLordToken,address _warriorWarLordToken, address _knightWarLordToken, address _legendWarLordToken) public Ownable() {

		_warlordToken[0].token = WarLordToken(_WarLordToken);

		_warlordToken[0].durationReward = 60 * 60 * 24; // 1 Day Duration in second

		

		_warlordToken[1].token = WarLordToken(_warriorWarLordToken);

		_warlordToken[1].durationReward = 60 * 60 * 24 * 2; // 2 Days Duration in second

		

		_warlordToken[2].token = WarLordToken(_knightWarLordToken);

		_warlordToken[2].durationReward = 60 * 60 * 24 * 3; // 3 Days Duration in second

		

		_warlordToken[3].token = WarLordToken(_legendWarLordToken);

		_warlordToken[3].durationReward = 60 * 60 * 24 * 7; // 1 Week Duration in second

		

		_warriorTOknight = 5;

		_knightTOlegend = 25;

		

		_legedWarLordfirstReward = 20;

		_legedWarLordotherReward = 15;

		

		_epochCampkStart = 1601906400; // October 5, 2020 2:00:00 PM GMT

	}

	

	function warlordType(string memory name) internal pure returns (uint8) {

		if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("WLT"))) {

			return 0;

		}

		

		if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("wWLT"))) {

			return 1;

		}

		

		if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("kWLT"))) {

			return 2;

		}

		

		if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("lWLT"))) {

			return 3;

		} else {

			return 99;

		}

	}

	

	function totalSupply(string calldata name) external view returns (uint256) {

		uint8 i = warlordType(name);

		return _warlordToken[i].totalSupply;

	}

	

	function balanceOf(address account, string calldata name) external view returns (uint256) {

		uint8 i = warlordType(name);

		return _warlordToken[i].balances[account];

	}

	

	function durationRemaining(address account, string calldata name) external view returns (uint256) {

		uint8 i = warlordType(name);



		uint256 timeRemaining = 0;

		uint256 durationReward = 0;



		durationReward = _warlordToken[i].durationReward;



		if(_warlordToken[i].balances[account] > 0){

			if((_warlordToken[i].periodFinish[account] - now) < durationReward){

				timeRemaining = _warlordToken[i].periodFinish[account] - now;

			}

		}



		return timeRemaining;

	}

	

	function rewardCount(address account, string calldata name) external view returns (uint256) {

		uint8 i = warlordType(name);

		return _warlordToken[i].countReward[account];

	}

	

	function checkKingdomReward(address account) external view returns (uint256) {

		uint256 countReward = _warlordToken[3].countReward[account];

		uint256 timeperiodFinish = _warlordToken[3].periodFinish[account];

		uint256 timeFirstStaking = timeperiodFinish - _warlordToken[3].durationReward;

		uint256 stakingPeriod = now - timeFirstStaking;

		uint256 countStakingReward = stakingPeriod / _warlordToken[3].durationReward;

		uint256 value = 0;



		for (uint256 i = countStakingReward; i != 0; i--) {

			if(countReward == 0){

				value = value.add(_legedWarLordfirstReward);

			} else {

				value = value.add(_legedWarLordotherReward);

			}

			countReward++;

		}



		return value * _warlordToken[3].balances[account];

	}

	

	function army(uint256 amount, string calldata name) external nonReentrant {    

		require(now > _epochCampkStart, "The Camp is being set up!");



		uint8 i = warlordType(name);

		require(i < 99, "Not a valid warlord name");



		require(amount >= 1, "Cannot stake less than 1");



		if(i == 0){

			uint256 modulo = amount % 1;

			require(modulo == 0, "If send a warlord token to Recruit Camp, has to be multiple of 1");

		} else {

			if(i == 1){

				uint256 modulo = amount % _warriorTOknight;

				require(modulo == 0, "If send a warrior warlord to Training Camp, has to be multiple of 5");

			} else {

				if(i == 2){

					uint256 modulo = amount % _knightTOlegend;

					require(modulo == 0, "If send a knight warlord to Dungeon, has to be multiple of 25");

				} else {

					if(i == 3){

						uint256 modulo = amount % 1;

						require(modulo == 0, "If send a legend warlord to Kingdom, has to be multiple of 1");

					}

				}

			}

		}



		require(_warlordToken[i].balances[msg.sender] == 0 && (_warlordToken[i].periodFinish[msg.sender] == 0 || now > _warlordToken[i].periodFinish[msg.sender]), 

		"You must withdraw the previous army before send more!");



		_warlordToken[i].token.safeTransferFrom(msg.sender, address(this), amount.mul(_decimalConverter));

		_warlordToken[i].totalSupply = _warlordToken[i].totalSupply.add(amount);

		_warlordToken[i].balances[msg.sender] = _warlordToken[i].balances[msg.sender].add(amount);

		_warlordToken[i].periodFinish[msg.sender] = now + _warlordToken[i].durationReward;



		emit Staked(msg.sender, amount);

	}

	

	function getarmy(string memory name) public nonReentrant {

		uint8 i = warlordType(name);

		require(i < 99, "Not a valid warlord name");



		require(_warlordToken[i].balances[msg.sender] > 0, "Cannot get army 0");

		require(now > _warlordToken[i].periodFinish[msg.sender], "Cannot get army until the action finished!");



		uint256 tempAmount;

		uint256 tempcountReward;



		if (i == 3) {

			tempAmount = setLegendWarLordRewardAmount();

			tempcountReward = getLegendWarLordRewardCount();

			_warlordToken[0].token.warlordMint(msg.sender, tempAmount.mul(_decimalConverter));

			_warlordToken[i].periodFinish[msg.sender] = now + _warlordToken[3].durationReward;

			_warlordToken[i].countReward[msg.sender] = tempcountReward;

		} else {

			_warlordToken[i].token.warlordBurn(address(this), _warlordToken[i].balances[msg.sender].mul(_decimalConverter));

			if(i == 2){

				tempAmount = _warlordToken[i].balances[msg.sender].div(_knightTOlegend);

			} else{

				if(i == 1){

					tempAmount = _warlordToken[i].balances[msg.sender].div(_warriorTOknight);

				} else {

					tempAmount = _warlordToken[i].balances[msg.sender];

				}

			}



			_warlordToken[i + 1].token.warlordMint(msg.sender, tempAmount.mul(_decimalConverter));



			zeroHoldings(i);

		}

		emit RewardPaid(msg.sender, tempAmount);

	}

	

	function withdraw(string memory name) public nonReentrant {

		uint8 i = warlordType(name);



		require(i < 99, "Not a valid warlord name");



		require(_warlordToken[i].balances[msg.sender] > 0, "Cannot withdraw 0");

		_warlordToken[i].token.safeTransfer(msg.sender, _warlordToken[i].balances[msg.sender].mul(_decimalConverter));



		emit Withdrawn(msg.sender,_warlordToken[i].balances[msg.sender]);



		zeroHoldings(i);

	}

	

	function zeroHoldings(uint8 i) internal{

		_warlordToken[i].totalSupply = _warlordToken[i].totalSupply - _warlordToken[i].balances[msg.sender];

		_warlordToken[i].balances[msg.sender] = 0;

		_warlordToken[i].periodFinish[msg.sender] = 0;

	}



	function setLegendWarLordRewardAmount() internal view returns (uint256) {

		uint256 countReward = _warlordToken[3].countReward[msg.sender];

		uint256 timeperiodFinish = _warlordToken[3].periodFinish[msg.sender];

		uint256 timeFirstStaking = timeperiodFinish - _warlordToken[3].durationReward;

		uint256 stakingPeriod = now - timeFirstStaking;

		uint256 countStakingReward = stakingPeriod / _warlordToken[3].durationReward;

		uint256 value = 0;



		for (uint256 i = countStakingReward; i != 0; i--) {

			if(countReward == 0){

				value = value.add(_legedWarLordfirstReward);

			} else {

				value = value.add(_legedWarLordotherReward);

			}

			countReward++;

		}



		return value * _warlordToken[3].balances[msg.sender];

	}



	function getLegendWarLordRewardCount() internal view returns (uint256) {

		uint256 countReward = _warlordToken[3].countReward[msg.sender];

		uint256 timeperiodFinish = _warlordToken[3].periodFinish[msg.sender];

		uint256 timeFirstStaking = timeperiodFinish - _warlordToken[3].durationReward;

		uint256 stakingPeriod = now - timeFirstStaking;

		uint256 countStakingReward = stakingPeriod / _warlordToken[3].durationReward;



		for (uint256 i = countStakingReward; i != 0; i--) {

			countReward++;

		}



		return countReward;

	}

	

	function addTokenOwner(address _token, address _newOwner) external onlyOwner {

		require(now > _epochCampkStart.add(14 days), "Time before Arena Opening");



		WarLordToken tempToken = WarLordToken(_token);

		tempToken.addOwner(_newOwner);

	}



	function renounceTokenOwner(address _token) external onlyOwner {

		require(now > _epochCampkStart.add(14 days), "Time before Arena Opening");



		WarLordToken tempToken = WarLordToken(_token);

		tempToken.renounceOwner();

	}



	function changeOwner(address _newOwner) external onlyOwner {

		transferOwnership(_newOwner);

	}

	

	event Staked(address indexed user, uint256 amount);

	event Withdrawn(address indexed user, uint256 amount);

	event RewardPaid(address indexed user, uint256 reward);

}