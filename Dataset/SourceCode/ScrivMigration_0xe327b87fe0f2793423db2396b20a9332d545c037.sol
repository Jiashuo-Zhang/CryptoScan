/**

 *Submitted for verification at Etherscan.io on 2023-10-07

*/



// SPDX-License-Identifier: MIT



pragma solidity ^0.8.18;



/*

 * @dev Provides information about the current execution context, including the

 * sender of the transaction and its data. While these are generally available

 * via msg.sender and msg.data, they should not be accessed in such a direct

 * manner, since when dealing with GSN meta-transactions the account sending and

 * paying for execution may not be the actual sender (as far as an application

 * is concerned).

 *

 * This contract is only required for intermediate, library-like contracts.

 */

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {

        return payable(msg.sender);

    }



    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}





pragma solidity ^0.8.18;



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

contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () {

        address msgSender = _msgSender();

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

        require(_owner == _msgSender(), "Ownable: caller is not the owner");

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

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}





pragma solidity ^0.8.18;



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





pragma solidity ^0.8.18;



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

     *

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

     *

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

     *

     * - Subtraction cannot overflow.

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

     *

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

     *

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

     *

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

     *

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

     *

     * - The divisor cannot be zero.

     */

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}





pragma solidity ^0.8.18;



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

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

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



        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value

        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }



    /**

     * @dev Performs a Solidity function call using a low level `call`. A

     * plain`call` is an unsafe replacement for a function call: use this

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

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);

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

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        return _functionCallWithValue(target, data, value, errorMessage);

    }



    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);

        if (success) {

            return returndata;

        } else {

            // Look for revert reason and bubble it up if present

            if (returndata.length > 0) {

                // The easiest way to bubble the revert reason is using memory via assembly



                // solhint-disable-next-line no-inline-assembly

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



pragma solidity ^0.8.18;











/**

 * @dev Implementation of the {IERC20} interface.

 *

 * This implementation is agnostic to the way tokens are created. This means

 * that a supply mechanism has to be added in a derived contract using {_mint}.

 * For a generic mechanism see {ERC20PresetMinterPauser}.

 *

 * TIP: For a detailed writeup see our guide

 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How

 * to implement supply mechanisms].

 *

 * We have followed general OpenZeppelin guidelines: functions revert instead

 * of returning `false` on failure. This behavior is nonetheless conventional

 * and does not conflict with the expectations of ERC20 applications.

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    using Address for address;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;

    uint8 private _decimals;



    /**

     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with

     * a default value of 18.

     *

     * To select a different value for {decimals}, use {_setupDecimals}.

     *

     * All three of these values are immutable: they can only be set once during

     * construction.

     */

    constructor (string memory n, string memory s) {

        _name = n;

        _symbol = s;

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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev See {IERC20-balanceOf}.

     */

    function balanceOf(address account) public view override returns (uint256) {

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

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

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);

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

     * - the caller must have allowance for ``sender``'s tokens of at least

     * `amount`.

     */

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

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

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

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

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _beforeTokenTransfer(sender, recipient, amount);



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

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _beforeTokenTransfer(address(0), account, amount);



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

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _beforeTokenTransfer(account, address(0), amount);



        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

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

     * @dev Sets {decimals} to a value other than the default one of 18.

     *

     * WARNING: This function should only be called from the constructor. Most

     * applications that interact with token contracts will not expect

     * {decimals} to ever change, and may work incorrectly if it does.

     */

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;

    }



    /**

     * @dev Hook that is called before any transfer of tokens. This includes

     * minting and burning.

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

     * will be to transferred to `to`.

     * - when `from` is zero, `amount` tokens will be minted for `to`.

     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.

     * - `from` and `to` are never both zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}





pragma solidity ^0.8.18;

pragma experimental ABIEncoderV2;



/// @title Scriv Migration Contract

/// @author Scriv Team

/// @notice This contract allows for the allocation of ERC20 tokens to accounts identified by a public key







contract ScrivMigration is Ownable{

    

    struct TimedBalance {

        uint256 blockHeight;

        uint256 amount;

        bool paid;

    }

    

    struct AccountStatus {

        uint256 pending;

        uint256 available;

        uint256 released;

    }

    

    struct SetBalance {

        bytes20 account;

        TimedBalance[] balances;

    }

     

    

    address private _tokenContract;

    bool private _finalizeImport;

    

    //for balances with a Scriv core address

    mapping (bytes20 => TimedBalance[]) private _balances;



    event ScrivMigrated(address account,uint256 amount);

    event AccountReferencedTo(bytes20 account);

    

    constructor() {

        _finalizeImport = false;

    }



    function setTokenContract(address tokenContract) public onlyOwner{

        require(_finalizeImport == false,

            "tokenContract cannot be changed after import has been finalized");

        _tokenContract = tokenContract;



    } 

    

    function finalizeImport() public onlyOwner{

        require(_finalizeImport == false,

            "Action cannot be taken after import has been finalized");

        _finalizeImport = true;

    }



    function isFinalized() public view returns(bool){

        return _finalizeImport;

    }



    function getTokenContract() public view returns(address){

        return _tokenContract;

    }



    function checkTokenBalance() public view returns(uint256){

        ERC20 token = ERC20(_tokenContract);

        return token.balanceOf(address(this));

    }



    function setAccountBalance(bytes20 account, TimedBalance[] memory balances) public onlyOwner{

        require(_finalizeImport == false,

            "Action cannot be taken after import has been finalized");

        for(uint256 i = 0; i < balances.length; i++){

            _balances[account].push(balances[i]);

        }

    }



    function setAccountBalances(SetBalance[] memory balances) public onlyOwner{

        require(_finalizeImport == false,

            "Action cannot be taken after import has been finalized");

        for (uint i=0; i < balances.length; i++){

            setAccountBalance(balances[i].account,balances[i].balances);

        }

    }

    



    function getAccountBalances(bytes20 account) public view returns (TimedBalance[] memory) {

        return _balances[account];

    }

    



    function getAccountAvailable(bytes20 account) public view returns (uint256) {

        AccountStatus memory status = generateAccountStatus(_balances[account]);

        return status.available;

    }

       



    function getAccountStatus(bytes20 account) public view returns (AccountStatus memory) {

        return generateAccountStatus(_balances[account]);

    }

    

    function totalAccountBalance(bytes memory publicKey) public view returns (AccountStatus memory) {

        AccountStatus memory totalAccountStatus;

        bytes20 accountReference = getAccountReference(publicKey);       

        AccountStatus memory status = getAccountStatus(accountReference);

        totalAccountStatus.pending = status.pending;

        totalAccountStatus.available = status.available;

        totalAccountStatus.released = status.released;

        return totalAccountStatus;

    }



    function withdrawBalance(bytes memory publicKey) public {

        ERC20 token = ERC20(_tokenContract);

        address ethAddress = getEthereumAddress(publicKey);

        

        //check that the public key matches the msg.sender

        require(msg.sender == ethAddress,

            "msg.sender must equal the ethereum address from the public key");

        

        //retrieve the balance from the public key

        bytes20 accountRef = getAccountReference(publicKey);



        emit AccountReferencedTo(accountRef);



        uint256 withdrawAmount = getAccountAvailable(accountRef);

        

        //check that the balance allocated to this contract is enough to cover the withdrawal       

        require(withdrawAmount > 0 && token.balanceOf(address(this)) >= withdrawAmount,

            "Migration Contract has insufficient funds");

        

        //send the balance to the msg.sender

        token.transfer(msg.sender,withdrawAmount);

        

        //mark the items as paid

        updateBalances(accountRef);

        emit ScrivMigrated(msg.sender,withdrawAmount);

    }



    function getAccountReference(bytes memory publicKey) private pure returns(bytes20){

        bytes32 firstSha256 = sha256(abi.encodePacked(publicKey));

        bytes20 ripemd = ripemd160(abi.encodePacked(firstSha256));      



        return ripemd;        

    }



    function getEthereumAddress(bytes memory publicKey) private pure returns(address addr){

        uint256 x = toUint256(slice(publicKey, 1, 32), 0);

        uint256 y = deriveY(toUint8(slice(publicKey, 0, 1), 0), x, A, B, P);



        bytes32 hash = keccak256(abi.encodePacked(x,y));

        assembly {

            mstore(0, hash)

            addr := mload(0)

        }    

    }



 function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");

        uint8 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x1), _start))

        }



        return tempUint;

    }



 function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");

        uint256 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x20), _start))

        }



        return tempUint;

    }





    function slice(

        bytes memory _bytes,

        uint256 _start,

        uint256 _length

    )

        internal

        pure

        returns (bytes memory)

    {

        require(_length + 31 >= _length, "slice_overflow");

        require(_bytes.length >= _start + _length, "slice_outOfBounds");



        bytes memory tempBytes;



        assembly {

            switch iszero(_length)

            case 0 {

                // Get a location of some free memory and store it in tempBytes as

                // Solidity does for memory variables.

                tempBytes := mload(0x40)



                // The first word of the slice result is potentially a partial

                // word read from the original array. To read it, we calculate

                // the length of that partial word and start copying that many

                // bytes into the array. The first word we copy will start with

                // data we don't care about, but the last `lengthmod` bytes will

                // land at the beginning of the contents of the new array. When

                // we're done copying, we overwrite the full first word with

                // the actual length of the slice.

                let lengthmod := and(_length, 31)



                // The multiplication in the next line is necessary

                // because when slicing multiples of 32 bytes (lengthmod == 0)

                // the following copy loop was copying the origin's length

                // and then ending prematurely not copying everything it should.

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))

                let end := add(mc, _length)



                for {

                    // The multiplication in the next line has the same exact purpose

                    // as the one above.

                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)

                } lt(mc, end) {

                    mc := add(mc, 0x20)

                    cc := add(cc, 0x20)

                } {

                    mstore(mc, mload(cc))

                }



                mstore(tempBytes, _length)



                //update free-memory pointer

                //allocating the array padded to 32 bytes like the compiler does now

                mstore(0x40, and(add(mc, 31), not(31)))

            }

            //if we want a zero-length slice let's just return a zero-length array

            default {

                tempBytes := mload(0x40)

                //zero out the 32 bytes slice we are about to return

                //we need to do it because Solidity does not garbage collect

                mstore(tempBytes, 0)



                mstore(0x40, add(tempBytes, 0x20))

            }

        }



        return tempBytes;

    }



  // Pre-computed constant for 2 ** 255

  uint256 constant private U255_MAX_PLUS_1 = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  uint256 constant private P = 115792089237316195423570985008687907853269984665640564039457584007908834671663;

  uint256 constant private A = 0;

  uint256 constant private B = 7;



  /// @dev Modular exponentiation, b^e % _pp.

  /// Source: https://github.com/androlo/standard-contracts/blob/master/contracts/src/crypto/ECCMath.sol

  /// @param _base base

  /// @param _exp exponent

  /// @param _pp modulus

  /// @return r such that r = b**e (mod _pp)

  function expMod(uint256 _base, uint256 _exp, uint256 _pp) internal pure returns (uint256) {

    require(_pp!=0, "Modulus is zero");



    if (_base == 0)

      return 0;

    if (_exp == 0)

      return 1;



    uint256 r = 1;

    uint256 bit = U255_MAX_PLUS_1;

    assembly {

      for { } gt(bit, 0) { }{

        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, bit)))), _pp)

        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 2))))), _pp)

        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 4))))), _pp)

        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 8))))), _pp)

        bit := div(bit, 16)

      }

    }



    return r;

  }



  /// @dev Derives the y coordinate from a compressed-format point x [[SEC-1]](https://www.secg.org/SEC1-Ver-1.0.pdf).

  /// @param _prefix parity byte (0x02 even, 0x03 odd)

  /// @param _x coordinate x

  /// @param _aa constant of curve

  /// @param _bb constant of curve

  /// @param _pp the modulus

  /// @return y coordinate y

  function deriveY(

    uint8 _prefix,

    uint256 _x,

    uint256 _aa,

    uint256 _bb,

    uint256 _pp)

  internal pure returns (uint256)

  {

    require(_prefix == 0x02 || _prefix == 0x03, "Invalid compressed EC point prefix");



    // x^3 + ax + b

    uint256 y2 = addmod(mulmod(_x, mulmod(_x, _x, _pp), _pp), addmod(mulmod(_x, _aa, _pp), _bb, _pp), _pp);

    y2 = expMod(y2, (_pp + 1) / 4, _pp);

    // uint256 cmp = yBit ^ y_ & 1;

    uint256 y = (y2 + _prefix) % 2 == 0 ? y2 : _pp - y2;



    return y;

  }

/*

    function getCompressedPublicKey(bytes32 publicKeyX,bytes32 publicKeyY) public pure returns(bytes memory){

        uint256 yAsInt = uint256(publicKeyY);

        uint8 yOdd = uint8(yAsInt&1);

        uint8 leadingByte;

        if(yOdd == 1) 

            leadingByte = 0x03; 

        else 

            leadingByte = 0x02;

        bytes memory cPublicKey = abi.encodePacked(leadingByte,publicKeyX);

        return cPublicKey;

    }

    */

    function generateAccountStatus(TimedBalance[] memory balances) private view returns (AccountStatus memory) {

        uint256 currentBlockHeight = block.number;

        AccountStatus memory currentStatus;

        

        currentStatus.pending = 0;

        currentStatus.available = 0;

        currentStatus.released = 0;

        

        for(uint256 i = 0; i < balances.length; i++){

            if(currentBlockHeight >= balances[i].blockHeight && balances[i].paid == false){

                currentStatus.available += balances[i].amount;

            }

            if(balances[i].blockHeight > currentBlockHeight && balances[i].paid == false){

                currentStatus.pending += balances[i].amount;

            }

            if(balances[i].paid == true){

                currentStatus.released += balances[i].amount;

            }

        }

        return currentStatus;

    }

    

    function updateBalances(bytes20 accountRef) private {

        uint currentBlockHeight = block.number;

        

        for(uint256 i = 0; i < _balances[accountRef].length; i++){

            if(currentBlockHeight >= _balances[accountRef][i].blockHeight && !_balances[accountRef][i].paid){

                _balances[accountRef][i].paid = true;

            }

        }

    }

}