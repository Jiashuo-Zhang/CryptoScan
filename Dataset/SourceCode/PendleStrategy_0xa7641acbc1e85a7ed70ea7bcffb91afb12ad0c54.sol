/**

 *Submitted for verification at Etherscan.io on 2023-06-27

*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;



// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)



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



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)



// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)



/**

 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in

 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].

 *

 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by

 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't

 * need to send a transaction, and thus is not required to hold Ether at all.

 */

interface IERC20Permit {

    /**

     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,

     * given ``owner``'s signed approval.

     *

     * IMPORTANT: The same issues {IERC20-approve} has related to transaction

     * ordering also apply here.

     *

     * Emits an {Approval} event.

     *

     * Requirements:

     *

     * - `spender` cannot be the zero address.

     * - `deadline` must be a timestamp in the future.

     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`

     * over the EIP712-formatted function arguments.

     * - the signature must use ``owner``'s current nonce (see {nonces}).

     *

     * For more information on the signature format, see the

     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP

     * section].

     */

    function permit(

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external;



    /**

     * @dev Returns the current nonce for `owner`. This value must be

     * included whenever a signature is generated for {permit}.

     *

     * Every successful call to {permit} increases ``owner``'s nonce by one. This

     * prevents a signature from being used multiple times.

     */

    function nonces(address owner) external view returns (uint256);



    /**

     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.

     */

    // solhint-disable-next-line func-name-mixedcase

    function DOMAIN_SEPARATOR() external view returns (bytes32);

}



// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)



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



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using Address for address;



    function safeTransfer(

        IERC20 token,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));

    }



    function safeTransferFrom(

        IERC20 token,

        address from,

        address to,

        uint256 value

    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));

    }



    /**

     * @dev Deprecated. This function has issues similar to the ones found in

     * {IERC20-approve}, and its usage is discouraged.

     *

     * Whenever possible, use {safeIncreaseAllowance} and

     * {safeDecreaseAllowance} instead.

     */

    function safeApprove(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require(

            (value == 0) || (token.allowance(address(this), spender) == 0),

            "SafeERC20: approve from non-zero to non-zero allowance"

        );

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));

    }



    function safeIncreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }



    function safeDecreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        unchecked {

            uint256 oldAllowance = token.allowance(address(this), spender);

            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");

            uint256 newAllowance = oldAllowance - value;

            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

        }

    }



    function safePermit(

        IERC20Permit token,

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) internal {

        uint256 nonceBefore = token.nonces(owner);

        token.permit(owner, spender, value, deadline, v, r, s);

        uint256 nonceAfter = token.nonces(owner);

        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");

    }



    /**

     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement

     * on the return value: the return value is optional (but if data is returned, it must not be false).

     * @param token The token targeted by the call.

     * @param data The call data (encoded using abi.encode or one of its variants).

     */

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since

        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that

        // the target address contains contract code and also asserts for success in the low-level call.



        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {

            // Return data is optional

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");

        }

    }

}



interface ILiquidityGauge {

    struct Reward {

        address token;

        address distributor;

        uint256 period_finish;

        uint256 rate;

        uint256 last_update;

        uint256 integral;

    }



    // solhint-disable-next-line

    function deposit_reward_token(address _rewardToken, uint256 _amount) external;



    // solhint-disable-next-line

    function claim_rewards_for(address _user, address _recipient) external;



    function working_balances(address _address) external view returns (uint256);



    // // solhint-disable-next-line

    // function claim_rewards_for(address _user) external;



    // solhint-disable-next-line

    function deposit(uint256 _value, address _addr) external;



    // solhint-disable-next-line

    function reward_tokens(uint256 _i) external view returns (address);



    // solhint-disable-next-line

    function reward_data(address _tokenReward) external view returns (Reward memory);



    function balanceOf(address) external returns (uint256);



    function claimable_reward(address _user, address _reward_token) external view returns (uint256);



    function claimable_tokens(address _user) external returns (uint256);



    function user_checkpoint(address _user) external returns (bool);



    function commit_transfer_ownership(address) external;



    function claim_rewards(address) external;



    function add_reward(address, address) external;



    function set_claimer(address) external;



    function admin() external view returns (address);



    function set_reward_distributor(address _rewardToken, address _newDistrib) external;



    function initialize(

        address staking_token,

        address admin,

        address SDT,

        address voting_escrow,

        address veBoost_proxy,

        address distributor

    ) external;

}



interface IPendleMarket {

    function redeemRewards(address user) external;

    function getRewardTokens() external returns(address[] memory);

}



interface ILocker {

    function createLock(uint256, uint256) external;



    function claimAllRewards(address[] calldata _tokens, address _recipient) external;



    function increaseAmount(uint256) external;



    function increaseUnlockTime(uint256) external;



    function release() external;



    function claimRewards(address, address) external;



    function claimFXSRewards(address) external;



    function claimFPISRewards(address) external;



    function execute(address, uint256, bytes calldata) external returns (bool, bytes memory);



    function setGovernance(address) external;



    function voteGaugeWeight(address, uint256) external;



    function setAngleDepositor(address) external;



    function setFxsDepositor(address) external;



    function setYieldDistributor(address) external;



    function setGaugeController(address) external;



    function setAccumulator(address _accumulator) external;



    function governance() external view returns (address);

}



// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)



// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)



// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)



/**

 * @dev Collection of functions related to the address type

 */

library AddressUpgradeable {

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



/**

 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed

 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an

 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer

 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.

 *

 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be

 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in

 * case an upgrade adds a module that needs to be initialized.

 *

 * For example:

 *

 * [.hljs-theme-light.nopadding]

 * ```

 * contract MyToken is ERC20Upgradeable {

 *     function initialize() initializer public {

 *         __ERC20_init("MyToken", "MTK");

 *     }

 * }

 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {

 *     function initializeV2() reinitializer(2) public {

 *         __ERC20Permit_init("MyToken");

 *     }

 * }

 * ```

 *

 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as

 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.

 *

 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure

 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.

 *

 * [CAUTION]

 * ====

 * Avoid leaving a contract uninitialized.

 *

 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation

 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke

 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:

 *

 * [.hljs-theme-light.nopadding]

 * ```

 * /// @custom:oz-upgrades-unsafe-allow constructor

 * constructor() {

 *     _disableInitializers();

 * }

 * ```

 * ====

 */

abstract contract Initializable {

    /**

     * @dev Indicates that the contract has been initialized.

     * @custom:oz-retyped-from bool

     */

    uint8 private _initialized;



    /**

     * @dev Indicates that the contract is in the process of being initialized.

     */

    bool private _initializing;



    /**

     * @dev Triggered when the contract has been initialized or reinitialized.

     */

    event Initialized(uint8 version);



    /**

     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,

     * `onlyInitializing` functions can be used to initialize parent contracts.

     *

     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a

     * constructor.

     *

     * Emits an {Initialized} event.

     */

    modifier initializer() {

        bool isTopLevelCall = !_initializing;

        require(

            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),

            "Initializable: contract is already initialized"

        );

        _initialized = 1;

        if (isTopLevelCall) {

            _initializing = true;

        }

        _;

        if (isTopLevelCall) {

            _initializing = false;

            emit Initialized(1);

        }

    }



    /**

     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the

     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be

     * used to initialize parent contracts.

     *

     * A reinitializer may be used after the original initialization step. This is essential to configure modules that

     * are added through upgrades and that require initialization.

     *

     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`

     * cannot be nested. If one is invoked in the context of another, execution will revert.

     *

     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in

     * a contract, executing them in the right order is up to the developer or operator.

     *

     * WARNING: setting the version to 255 will prevent any future reinitialization.

     *

     * Emits an {Initialized} event.

     */

    modifier reinitializer(uint8 version) {

        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");

        _initialized = version;

        _initializing = true;

        _;

        _initializing = false;

        emit Initialized(version);

    }



    /**

     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the

     * {initializer} and {reinitializer} modifiers, directly or indirectly.

     */

    modifier onlyInitializing() {

        require(_initializing, "Initializable: contract is not initializing");

        _;

    }



    /**

     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.

     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized

     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called

     * through proxies.

     *

     * Emits an {Initialized} event the first time it is successfully executed.

     */

    function _disableInitializers() internal virtual {

        require(!_initializing, "Initializable: contract is initializing");

        if (_initialized < type(uint8).max) {

            _initialized = type(uint8).max;

            emit Initialized(type(uint8).max);

        }

    }



    /**

     * @dev Returns the highest version that has been initialized. See {reinitializer}.

     */

    function _getInitializedVersion() internal view returns (uint8) {

        return _initialized;

    }



    /**

     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.

     */

    function _isInitializing() internal view returns (bool) {

        return _initializing;

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

 */

abstract contract ReentrancyGuardUpgradeable is Initializable {

    // Booleans are more expensive than uint256 or any type that takes up a full

    // word because each write operation emits an extra SLOAD to first read the

    // slot's contents, replace the bits taken up by the boolean, and then write

    // back. This is the compiler's defense against contract upgrades and

    // pointer aliasing, and it cannot be disabled.



    // The values being non-zero value makes deployment a bit more expensive,

    // but in exchange the refund on every call to nonReentrant will be lower in

    // amount. Since refunds are capped to a percentage of the total

    // transaction's gas, it is best to keep them low in cases like this one, to

    // increase the likelihood of the full refund coming into effect.

    uint256 private constant _NOT_ENTERED = 1;

    uint256 private constant _ENTERED = 2;



    uint256 private _status;



    function __ReentrancyGuard_init() internal onlyInitializing {

        __ReentrancyGuard_init_unchained();

    }



    function __ReentrancyGuard_init_unchained() internal onlyInitializing {

        _status = _NOT_ENTERED;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and making it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _nonReentrantBefore();

        _;

        _nonReentrantAfter();

    }



    function _nonReentrantBefore() private {

        // On the first call to nonReentrant, _status will be _NOT_ENTERED

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _status = _ENTERED;

    }



    function _nonReentrantAfter() private {

        // By storing the original value once again, a refund is triggered (see

        // https://eips.ethereum.org/EIPS/eip-2200)

        _status = _NOT_ENTERED;

    }



    /**

     * @dev This empty reserved space is put in place to allow future versions to add new

     * variables without shifting down storage in the inheritance chain.

     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps

     */

    uint256[49] private __gap;

}



interface IGaugeController {

    struct VotedSlope {

        uint256 slope;

        uint256 power;

        uint256 end;

    }



    function admin() external view returns (address);



    function gauges(uint256) external view returns (address);



    //solhint-disable-next-line

    function gauge_types(address addr) external view returns (int128);



    //solhint-disable-next-line

    function gauge_relative_weight_write(address addr, uint256 timestamp) external returns (uint256);



    //solhint-disable-next-line

    function gauge_relative_weight(address addr) external view returns (uint256);



    //solhint-disable-next-line

    function gauge_relative_weight(address addr, uint256 timestamp) external view returns (uint256);



    //solhint-disable-next-line

    function get_total_weight() external view returns (uint256);



    //solhint-disable-next-line

    function get_gauge_weight(address addr) external view returns (uint256);



    function get_type_weight(int128) external view returns (uint256);



    function vote_for_gauge_weights(address, uint256) external;



    function vote_user_slopes(address, address) external returns (VotedSlope memory);



    function last_user_vote(address _user, address _gauge) external view returns (uint256);



    function checkpoint_gauge(address _gauge) external;



    function add_gauge(address, int128, uint256) external;



    function add_type(string memory, uint256) external;



    function commit_transfer_ownership(address) external;



    function accept_transfer_ownership() external;

}



interface ISdtMiddlemanGauge {

    function notifyReward(address gauge, uint256 amount) external;

}



/// @title IStakingRewardsFunctions

/// @author StakeDAO Core Team

/// @notice Interface for the staking rewards contract that interact with the `RewardsDistributor` contract

interface IStakingRewardsFunctions {

    function notifyRewardAmount(uint256 reward) external;



    function recoverERC20(address tokenAddress, address to, uint256 tokenAmount) external;



    function setNewRewardsDistribution(address newRewardsDistribution) external;

}



/// @title IStakingRewards

/// @author StakeDAO Core Team

/// @notice Previous interface with additionnal getters for public variables

interface IStakingRewards is IStakingRewardsFunctions {

    function rewardToken() external view returns (IERC20);

}



interface IMasterchef {

    function deposit(uint256, uint256) external;



    function withdraw(uint256, uint256) external;



    function userInfo(uint256, address) external view returns (uint256, uint256);



    function poolInfo(uint256) external returns (address, uint256, uint256, uint256);



    function totalAllocPoint() external view returns (uint256);



    function sdtPerBlock() external view returns (uint256);



    function pendingSdt(uint256, address) external view returns (uint256);



    function owner() external view returns (address);



    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) external;



    function poolLength() external view returns (uint256);

}



// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)



// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)



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



// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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



// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



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



contract MasterchefMasterToken is ERC20, Ownable {

    constructor() ERC20("Masterchef Master Token", "MMT") {

        _mint(msg.sender, 1e18);

    }

}



// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)



// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)



/**

 * @dev Standard math utilities missing in the Solidity language.

 */

library MathUpgradeable {

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



/**

 * @dev String operations.

 */

library StringsUpgradeable {

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory) {

        unchecked {

            uint256 length = MathUpgradeable.log10(value) + 1;

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

            return toHexString(value, MathUpgradeable.log256(value) + 1);

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



/// @title IAccessControl

/// @author Forked from OpenZeppelin

/// @notice Interface for `AccessControl` contracts

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);



    function getRoleAdmin(bytes32 role) external view returns (bytes32);



    function grantRole(bytes32 role, address account) external;



    function revokeRole(bytes32 role, address account) external;



    function renounceRole(bytes32 role, address account) external;

}



/**

 * @dev This contract is fully forked from OpenZeppelin `AccessControlUpgradeable`.

 * The only difference is the removal of the ERC165 implementation as it's not

 * needed in Angle.

 *

 * Contract module that allows children to implement role-based access

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

 * require(hasRole(MY_ROLE, msg.sender));

 * ...

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

abstract contract AccessControlUpgradeable is Initializable, IAccessControl {

    function __AccessControl_init() internal initializer {

        __AccessControl_init_unchained();

    }



    function __AccessControl_init_unchained() internal initializer {}



    struct RoleData {

        mapping(address => bool) members;

        bytes32 adminRole;

    }



    mapping(bytes32 => RoleData) private _roles;



    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;



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

     * bearer except when using {_setupRole}.

     */

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Emitted when `account` is revoked `role`.

     *

     * `sender` is the account that originated the contract call:

     * - if using `revokeRole`, it is the admin role bearer

     * - if using `renounceRole`, it is the role bearer (i.e. `account`)

     */

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Modifier that checks that an account has a specific role. Reverts

     * with a standardized message including the required role.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     * /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/

     *

     * _Available since v4.1._

     */

    modifier onlyRole(bytes32 role) {

        _checkRole(role, msg.sender);

        _;

    }



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) public view override returns (bool) {

        return _roles[role].members[account];

    }



    /**

     * @dev Revert with a standard message if `account` is missing `role`.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     * /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/

     */

    function _checkRole(bytes32 role, address account) internal view {

        if (!hasRole(role, account)) {

            revert(

                string(

                    abi.encodePacked(

                        "AccessControl: account ",

                        StringsUpgradeable.toHexString(uint160(account), 20),

                        " is missing role ",

                        StringsUpgradeable.toHexString(uint256(role), 32)

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

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {

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

     */

    function grantRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {

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

     */

    function revokeRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {

        _revokeRole(role, account);

    }



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

    function renounceRole(bytes32 role, address account) external override {

        require(account == msg.sender, "71");



        _revokeRole(role, account);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event. Note that unlike {grantRole}, this function doesn't perform any

     * checks on the calling account.

     *

     * [WARNING]

     * ====

     * This function should only be called from the constructor when setting

     * up the initial roles for the system.

     *

     * Using this function in any other way is effectively circumventing the admin

     * system imposed by {AccessControl}.

     * ====

     */

    function _setupRole(bytes32 role, address account) internal {

        _grantRole(role, account);

    }



    /**

     * @dev Sets `adminRole` as ``role``'s admin role.

     *

     * Emits a {RoleAdminChanged} event.

     */

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {

        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);

        _roles[role].adminRole = adminRole;

    }



    function _grantRole(bytes32 role, address account) internal {

        if (!hasRole(role, account)) {

            _roles[role].members[account] = true;

            emit RoleGranted(role, account, msg.sender);

        }

    }



    function _revokeRole(bytes32 role, address account) internal {

        if (hasRole(role, account)) {

            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, msg.sender);

        }

    }



    uint256[49] private __gap;

}



/// @title SdtDistributorEvents

/// @author StakeDAO Core Team

/// @notice All the events used in `SdtDistributor` contract

abstract contract SdtDistributorEvents {

    event DelegateGaugeUpdated(address indexed _gaugeAddr, address indexed _delegateGauge);

    event DistributionsToggled(bool _distributionsOn);

    event GaugeControllerUpdated(address indexed _controller);

    event GaugeToggled(address indexed gaugeAddr, bool newStatus);

    event InterfaceKnownToggled(address indexed _delegateGauge, bool _isInterfaceKnown);

    event RateUpdated(uint256 _newRate);

    event Recovered(address indexed tokenAddress, address indexed to, uint256 amount);

    event RewardDistributed(address indexed gaugeAddr, uint256 sdtDistributed, uint256 lastMasterchefPull);

    event UpdateMiningParameters(uint256 time, uint256 rate, uint256 supply);

}



/// @title SdtDistributorV2

/// @notice Earn from Masterchef SDT and distribute it to gauges

contract SdtDistributorV2 is ReentrancyGuardUpgradeable, AccessControlUpgradeable, SdtDistributorEvents {

    using SafeERC20 for IERC20;



    ////////////////////////////////////////////////////////////////

    /// --- CONSTANTS

    ///////////////////////////////////////////////////////////////



    /// @notice Accounting

    uint256 public constant BASE_UNIT = 10_000;



    /// @notice Address of the SDT token given as a reward.

    IERC20 public constant rewardToken = IERC20(0x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F);



    /// @notice Address of the masterchef.

    IMasterchef public constant masterchef = IMasterchef(0xfEA5E213bbD81A8a94D0E1eDB09dBD7CEab61e1c);



    /// @notice Role for governors only.

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    /// @notice Role for the guardian

    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");



    ////////////////////////////////////////////////////////////////

    /// --- STORAGE SLOTS

    ///////////////////////////////////////////////////////////////



    /// @notice Time between SDT Harvest.

    uint256 public timePeriod;



    /// @notice Address of the token that will be deposited in masterchef.

    IERC20 public masterchefToken;



    /// @notice Address of the `GaugeController` contract.

    IGaugeController public controller;



    /// @notice Address responsible for pulling rewards of type >= 2 gauges and distributing it to the

    /// associated contracts if there is not already an address delegated for this specific contract.

    address public delegateGauge;



    /// @notice Whether SDT distribution through this contract is on or no.

    bool public distributionsOn;



    /// @notice Maps the address of a type >= 2 gauge to a delegate address responsible

    /// for giving rewards to the actual gauge.

    mapping(address => address) public delegateGauges;



    /// @notice Maps the address of a gauge to whether it was killed or not

    /// A gauge killed in this contract cannot receive any rewards.

    mapping(address => bool) public killedGauges;



    /// @notice Maps the address of a gauge delegate to whether this delegate supports the `notifyReward` interface

    /// and is therefore built for automation.

    mapping(address => bool) public isInterfaceKnown;



    /// @notice Masterchef PID

    uint256 public masterchefPID;



    /// @notice Timestamp of the last pull from masterchef.

    uint256 public lastMasterchefPull;



    /// @notice Maps the timestamp of pull action to the amount of SDT that pulled.

    mapping(uint256 => uint256) public pulls; // day => SDT amount



    /// @notice Maps the timestamp of last pull to the gauge addresses then keeps the data if particular gauge paid in the last pull.

    mapping(uint256 => mapping(address => bool)) public isGaugePaid;



    /// @notice Incentive for caller.

    uint256 public claimerFee;



    /// @notice Number of days to go through for past distributing.

    uint256 public lookPastDays;



    ////////////////////////////////////////////////////////////////

    /// --- INITIALIZATION LOGIC

    ///////////////////////////////////////////////////////////////



    /// @notice Initialize function

    /// @param _controller gauge controller to manage votes

    /// @param _governor governor address

    /// @param _guardian guardian address

    /// @param _delegateGauge delegate gauge address

    function initialize(address _controller, address _governor, address _guardian, address _delegateGauge)

        external

        initializer

    {

        require(_controller != address(0) && _guardian != address(0) && _governor != address(0), "0");



        controller = IGaugeController(_controller);

        delegateGauge = _delegateGauge;



        masterchefToken = IERC20(address(new MasterchefMasterToken()));

        distributionsOn = false;



        timePeriod = 3600 * 24; // One day in seconds

        lookPastDays = 45; // for past 45 days check



        _setRoleAdmin(GOVERNOR_ROLE, GOVERNOR_ROLE);

        _setRoleAdmin(GUARDIAN_ROLE, GOVERNOR_ROLE);



        _setupRole(GUARDIAN_ROLE, _guardian);

        _setupRole(GOVERNOR_ROLE, _governor);

        _setupRole(GUARDIAN_ROLE, _governor);

    }



    /// @custom:oz-upgrades-unsafe-allow constructor

    constructor() initializer {}



    /// @notice Initialize the masterchef depositing the master token

    /// @param _pid pool id to deposit the token

    function initializeMasterchef(uint256 _pid) external onlyRole(GOVERNOR_ROLE) {

        masterchefPID = _pid;

        masterchefToken.approve(address(masterchef), 1e18);

        masterchef.deposit(_pid, 1e18);

    }



    ////////////////////////////////////////////////////////////////

    /// --- DISTRIBUTION LOGIC

    ///////////////////////////////////////////////////////////////



    /// @notice Distribute SDT to Gauges

    /// @param gaugeAddr Address of the gauge to distribute.

    function distribute(address gaugeAddr) external nonReentrant {

        _distribute(gaugeAddr);

    }



    /// @notice Distribute SDT to Multiple Gauges

    /// @param gaugeAddr Array of addresses of the gauge to distribute.

    function distributeMulti(address[] calldata gaugeAddr) public nonReentrant {

        uint256 length = gaugeAddr.length;

        for (uint256 i; i < length; i++) {

            _distribute(gaugeAddr[i]);

        }

    }



    /// @notice Internal implementation of distribute logic.

    /// @param gaugeAddr Address of the gauge to distribute rewards to

    function _distribute(address gaugeAddr) internal {

        require(distributionsOn, "not allowed");

        (bool success, bytes memory result) =

            address(controller).call(abi.encodeWithSignature("gauge_types(address)", gaugeAddr));

        if (!success || killedGauges[gaugeAddr]) {

            return;

        }

        int128 gaugeType = abi.decode(result, (int128));



        // Rounded to beginning of the day -> 00:00 UTC

        uint256 roundedTimestamp = (block.timestamp / 1 days) * 1 days;



        uint256 totalDistribute;



        if (block.timestamp > lastMasterchefPull + timePeriod) {

            uint256 sdtBefore = rewardToken.balanceOf(address(this));

            _pullSDT();

            pulls[roundedTimestamp] = rewardToken.balanceOf(address(this)) - sdtBefore;

            lastMasterchefPull = roundedTimestamp;

        }

        // check past n days

        for (uint256 i; i < lookPastDays; i++) {

            uint256 currentTimestamp = roundedTimestamp - (i * 86_400);



            if (pulls[currentTimestamp] > 0) {

                bool isPaid = isGaugePaid[currentTimestamp][gaugeAddr];

                if (isPaid) {

                    break;

                }



                // Retrieve the amount pulled from Masterchef at the given timestamp.

                uint256 sdtBalance = pulls[currentTimestamp];

                uint256 gaugeRelativeWeight;



                if (i == 0) {

                    // Makes sure the weight is checkpointed. Also returns the weight.

                    gaugeRelativeWeight = controller.gauge_relative_weight_write(gaugeAddr, currentTimestamp);

                } else {

                    gaugeRelativeWeight = controller.gauge_relative_weight(gaugeAddr, currentTimestamp);

                }



                uint256 sdtDistributed = (sdtBalance * gaugeRelativeWeight) / 1e18;

                totalDistribute += sdtDistributed;

                isGaugePaid[currentTimestamp][gaugeAddr] = true;

            }

        }

        if (totalDistribute > 0) {

            if (gaugeType == 1) {

                rewardToken.safeTransfer(gaugeAddr, totalDistribute);

                IStakingRewards(gaugeAddr).notifyRewardAmount(totalDistribute);

            } else if (gaugeType >= 2) {

                // If it is defined, we use the specific delegate attached to the gauge

                address delegate = delegateGauges[gaugeAddr];

                if (delegate == address(0)) {

                    // If not, we check if a delegate common to all gauges with type >= 2 can be used

                    delegate = delegateGauge;

                }

                if (delegate != address(0)) {

                    // In the case where the gauge has a delegate (specific or not), then rewards are transferred to this gauge

                    rewardToken.safeTransfer(delegate, totalDistribute);

                    // If this delegate supports a specific interface, then rewards sent are notified through this

                    // interface

                    if (isInterfaceKnown[delegate]) {

                        ISdtMiddlemanGauge(delegate).notifyReward(gaugeAddr, totalDistribute);

                    }

                } else {

                    rewardToken.safeTransfer(gaugeAddr, totalDistribute);

                }

            } else {

                ILiquidityGauge(gaugeAddr).deposit_reward_token(address(rewardToken), totalDistribute);

            }



            emit RewardDistributed(gaugeAddr, totalDistribute, lastMasterchefPull);

        }

    }



    /// @notice Internal function to pull SDT from the MasterChef

    function _pullSDT() internal {

        masterchef.withdraw(masterchefPID, 0);

    }



    ////////////////////////////////////////////////////////////////

    /// --- RESTRICTIVE FUNCTIONS

    ///////////////////////////////////////////////////////////////



    /// @notice Sets the distribution state (on/off)

    /// @param _state new distribution state

    function setDistribution(bool _state) external onlyRole(GOVERNOR_ROLE) {

        distributionsOn = _state;

    }



    /// @notice Sets a new gauge controller

    /// @param _controller Address of the new gauge controller

    function setGaugeController(address _controller) external onlyRole(GOVERNOR_ROLE) {

        require(_controller != address(0), "0");

        controller = IGaugeController(_controller);

        emit GaugeControllerUpdated(_controller);

    }



    /// @notice Sets a new delegate gauge for pulling rewards of a type >= 2 gauges or of all type >= 2 gauges

    /// @param gaugeAddr Gauge to change the delegate of

    /// @param _delegateGauge Address of the new gauge delegate related to `gaugeAddr`

    /// @param toggleInterface Whether we should toggle the fact that the `_delegateGauge` is built for automation or not

    /// @dev This function can be used to remove delegating or introduce the pulling of rewards to a given address

    /// @dev If `gaugeAddr` is the zero address, this function updates the delegate gauge common to all gauges with type >= 2

    /// @dev The `toggleInterface` parameter has been added for convenience to save one transaction when adding a gauge delegate

    /// which supports the `notifyReward` interface

    function setDelegateGauge(address gaugeAddr, address _delegateGauge, bool toggleInterface)

        external

        onlyRole(GOVERNOR_ROLE)

    {

        if (gaugeAddr != address(0)) {

            delegateGauges[gaugeAddr] = _delegateGauge;

        } else {

            delegateGauge = _delegateGauge;

        }

        emit DelegateGaugeUpdated(gaugeAddr, _delegateGauge);



        if (toggleInterface) {

            _toggleInterfaceKnown(_delegateGauge);

        }

    }



    /// @notice Toggles the status of a gauge to either killed or unkilled

    /// @param gaugeAddr Gauge to toggle the status of

    /// @dev It is impossible to kill a gauge in the `GaugeController` contract, for this reason killing of gauges

    /// takes place in the `SdtDistributor` contract

    /// @dev This means that people could vote for a gauge in the gauge controller contract but that rewards are not going

    /// to be distributed to it in the end: people would need to remove their weights on the gauge killed to end the diminution

    /// in rewards

    /// @dev In the case of a gauge being killed, this function resets the timestamps at which this gauge has been approved and

    /// disapproves the gauge to spend the token

    /// @dev It should be cautiously called by governance as it could result in less SDT overall rewards than initially planned

    /// if people do not remove their voting weights to the killed gauge

    function toggleGauge(address gaugeAddr) external onlyRole(GOVERNOR_ROLE) {

        bool gaugeKilledMem = killedGauges[gaugeAddr];

        if (!gaugeKilledMem) {

            rewardToken.safeApprove(gaugeAddr, 0);

        }

        killedGauges[gaugeAddr] = !gaugeKilledMem;

        emit GaugeToggled(gaugeAddr, !gaugeKilledMem);

    }



    /// @notice Notifies that the interface of a gauge delegate is known or has changed

    /// @param _delegateGauge Address of the gauge to change

    /// @dev Gauge delegates that are built for automation should be toggled

    function toggleInterfaceKnown(address _delegateGauge) external onlyRole(GUARDIAN_ROLE) {

        _toggleInterfaceKnown(_delegateGauge);

    }



    /// @notice Toggles the fact that a gauge delegate can be used for automation or not and therefore supports

    /// the `notifyReward` interface

    /// @param _delegateGauge Address of the gauge to change

    function _toggleInterfaceKnown(address _delegateGauge) internal {

        bool isInterfaceKnownMem = isInterfaceKnown[_delegateGauge];

        isInterfaceKnown[_delegateGauge] = !isInterfaceKnownMem;

        emit InterfaceKnownToggled(_delegateGauge, !isInterfaceKnownMem);

    }



    /// @notice Gives max approvement to the gauge

    /// @param gaugeAddr Address of the gauge

    function approveGauge(address gaugeAddr) external onlyRole(GOVERNOR_ROLE) {

        rewardToken.safeApprove(gaugeAddr, type(uint256).max);

    }



    /// @notice Set the time period to pull SDT from Masterchef

    /// @param _timePeriod new timePeriod value in seconds

    function setTimePeriod(uint256 _timePeriod) external onlyRole(GOVERNOR_ROLE) {

        require(_timePeriod >= 1 days, "TOO_LOW");

        timePeriod = _timePeriod;

    }



    function setClaimerFee(uint256 _newFee) external onlyRole(GOVERNOR_ROLE) {

        require(_newFee <= BASE_UNIT, "TOO_HIGH");

        claimerFee = _newFee;

    }



    /// @notice Set the how many days we should look back for reward distribution

    /// @param _newLookPastDays new value for how many days we should look back

    function setLookPastDays(uint256 _newLookPastDays) external onlyRole(GOVERNOR_ROLE) {

        lookPastDays = _newLookPastDays;

    }



    /// @notice Withdraws ERC20 tokens that could accrue on this contract

    /// @param tokenAddress Address of the ERC20 token to withdraw

    /// @param to Address to transfer to

    /// @param amount Amount to transfer

    /// @dev Added to support recovering LP Rewards and other mistaken tokens

    /// from other systems to be distributed to holders

    /// @dev This function could also be used to recover SDT tokens in case the rate got smaller

    function recoverERC20(address tokenAddress, address to, uint256 amount) external onlyRole(GOVERNOR_ROLE) {

        IERC20(tokenAddress).safeTransfer(to, amount);

        emit Recovered(tokenAddress, to, amount);

    }

}



contract PendleStrategy {

    using SafeERC20 for IERC20;



    error CALL_FAILED();

    error FEE_TOO_HIGH();

    error NOT_ALLOWED();

    error WRONG_TRANSFER();

    error VAULT_NOT_APPROVED();

    error ZERO_ADDRESS();



    enum MANAGEFEE {

        DAOFEE,

        VESDTFEE,

        ACCUMULATORFEE,

        CLAIMERFEE

    }



    address public constant LOCKER = 0xD8fa8dC5aDeC503AcC5e026a98F32Ca5C1Fa289A;

    address public governance;

    address public vaultGaugeFactory;

    address public sdtDistributor;



    // Fees

    uint256 public constant BASE_FEE = 10_000;

    address public daoRecipient;

    uint256 public daoFee = 500; // 5%

    address public accRecipient;

    uint256 public accFee = 500; // 5%

    address public veSdtFeeRecipient;

    uint256 public veSdtFeeFee = 500; // 5%

    uint256 public claimerFee = 50; // 0.5%



    mapping(address => bool) public vaults;

    mapping(address => address) public sdGauges;



    event AccRecipientSet(address _oldR, address _newR);

    event Claimed(address _token, uint256 _amount);

    event DaoRecipientSet(address _oldR, address _newR);

    event GovernanceSet(address _oldG, address _newG);

    event SdGaugeSet(address _oldG, address _newG);

    event SdtDistributorSet(address _oldD, address _newD);

    event VaultGaugeFactorySet(address _oldVgf, address _newVgf);

    event VaultToggled(address _vault, bool _newState);

    event VeSdtFeeRecipientSet(address _oldR, address _newR);

    event Withdrawn(address _token, uint256 _amount);



    /* ========== CONSTRUCTOR ========== */

    constructor(

        address _governance,

        address _daoRecipient,

        address _accRecipient,

        address _veSdtFeeRecipient,

        address _sdtDistributor

    ) {

        governance = _governance;

        daoRecipient = _daoRecipient;

        accRecipient = _accRecipient;

        veSdtFeeRecipient = _veSdtFeeRecipient;

        sdtDistributor = _sdtDistributor;

    }



    /* ========== MUTATIVE FUNCTIONS ========== */

    /// @notice function to withdraw the lpt token from the locker

    /// @param _token LPT token to claim the reward

    /// @param _amount amount to withdraw

    /// @param _user user that called the withdraw on vault

    function withdraw(address _token, uint256 _amount, address _user) external {

        if (!vaults[msg.sender]) revert VAULT_NOT_APPROVED();



        uint256 _before = IERC20(_token).balanceOf(LOCKER);

        (bool success,) = ILocker(LOCKER).execute(

            _token, 0, abi.encodeWithSignature("transfer(address,uint256)", _user, _amount)

        );

        uint256 _after = IERC20(_token).balanceOf(LOCKER);

        if (_before - _after != _amount) revert WRONG_TRANSFER();

        if (!success) revert CALL_FAILED();

        emit Withdrawn(_token, _amount);

    }



    /// @notice function to claim the reward for the pendle market token

    /// @param _token LPT token to claim the reward

    function claim(address _token) external {

        address[] memory rewardTokens = IPendleMarket(_token).getRewardTokens();

        uint256[] memory balancesBefore = new uint256[](rewardTokens.length);

        for (uint8 i; i < rewardTokens.length;) {

            balancesBefore[i] = IERC20(rewardTokens[i]).balanceOf(LOCKER);

            unchecked {

                ++i;

            }

        }



        // redeem rewards

        IPendleMarket(_token).redeemRewards(LOCKER);



        uint256 reward;

        bool success;

        for (uint8 i; i < rewardTokens.length; ++i) {

            reward = IERC20(rewardTokens[i]).balanceOf(LOCKER) - balancesBefore[i];

            if (reward == 0) {

                continue;

            }

            // tranfer here only reward claimed

            (success,) = ILocker(LOCKER).execute(

                rewardTokens[i], 0, abi.encodeWithSignature("transfer(address,uint256)", address(this), reward)

            );

            if (!success) revert CALL_FAILED();



            // charge fee

            uint256 rewardToNotify = _chargeFees(rewardTokens[i], reward);

            _approveTokenIfNeeded(rewardTokens[i], sdGauges[_token], rewardToNotify);

            ILiquidityGauge(sdGauges[_token]).deposit_reward_token(rewardTokens[i], rewardToNotify);

            emit Claimed(rewardTokens[i], rewardToNotify);

        }

        // Distribute SDT

        SdtDistributorV2(sdtDistributor).distribute(sdGauges[_token]);

    }



    /// @dev This function should not be used frequently, it is only used to claim the pending rewards in case of someone claims on behalf of the locker.

    function claimPendingRewards(address token, address[] calldata rewardTokens, uint256[] calldata amount) external {

        if (msg.sender != governance) revert NOT_ALLOWED();



        uint256 _length = rewardTokens.length;

        for (uint8 i; i < _length;) {

            /// Tranfer here only reward claimed

            ILocker(LOCKER).execute(

                rewardTokens[i], 0, abi.encodeWithSignature("transfer(address,uint256)", address(this), amount[i])

            );



            // charge fee

            uint256 rewardToNotify = _chargeFees(rewardTokens[i], amount[i]);



            // Notify the reward to the gauge

            _approveTokenIfNeeded(rewardTokens[i], sdGauges[token], rewardToNotify);

            ILiquidityGauge(sdGauges[token]).deposit_reward_token(rewardTokens[i], rewardToNotify);



            emit Claimed(rewardTokens[i], rewardToNotify);



            unchecked {

                ++i;

            }

        }

    }



    /// @notice internal function to calculate fees and sent them to recipients

    /// @param _token token to charge fees

    /// @param _amount total amount to charge fees

    function _chargeFees(address _token, uint256 _amount) internal returns (uint256 amountToNotify) {

        uint256 daoPart;

        uint256 accPart;

        uint256 veSdtFeePart;

        uint256 claimerPart;

        if (daoFee > 0) {

            daoPart = (_amount * daoFee) / BASE_FEE;

            IERC20(_token).safeTransfer(daoRecipient, daoPart);

        }

        if (accFee > 0) {

            accPart = (_amount * accFee) / BASE_FEE;

            IERC20(_token).safeTransfer(accRecipient, accPart);

        }

        if (veSdtFeeFee > 0) {

            veSdtFeePart = (_amount * veSdtFeeFee) / BASE_FEE;

            IERC20(_token).safeTransfer(veSdtFeeRecipient, veSdtFeePart);

        }

        if (claimerFee > 0) {

            claimerPart = (_amount * claimerFee) / BASE_FEE;

            IERC20(_token).safeTransfer(msg.sender, claimerPart);

        }

        amountToNotify = _amount - daoPart - accPart - veSdtFeePart - claimerPart;

    }



    /// @notice function to set new fees

    /// @param _manageFee manageFee

    /// @param _newFee new fee to set

    function manageFee(MANAGEFEE _manageFee, uint256 _newFee) external {

        if (msg.sender != governance && msg.sender != vaultGaugeFactory) revert NOT_ALLOWED();

        if (_manageFee == MANAGEFEE.DAOFEE) {

            // 0

            daoFee = _newFee;

        } else if (_manageFee == MANAGEFEE.VESDTFEE) {

            // 1

            veSdtFeeFee = _newFee;

        } else if (_manageFee == MANAGEFEE.ACCUMULATORFEE) {

            //2

            accFee = _newFee;

        } else if (_manageFee == MANAGEFEE.CLAIMERFEE) {

            // 3

            claimerFee = _newFee;

        }

    }



    function toggleVault(address _vault) external {

        if (msg.sender != governance && msg.sender != vaultGaugeFactory) revert NOT_ALLOWED();

        vaults[_vault] = !vaults[_vault];

        emit VaultToggled(_vault, vaults[_vault]);

    }



    /// @notice function to set the sd gauge related to the LPT token

    /// @param _token pendle LPT token address

    /// @param _sdGauge stake dao gauge address

    function setSdGauge(address _token, address _sdGauge) external {

        if (msg.sender != governance && msg.sender != vaultGaugeFactory) revert NOT_ALLOWED();

        emit SdGaugeSet(sdGauges[_token], _sdGauge);

        sdGauges[_token] = _sdGauge;

    }



    /// @notice function to set the dao fee recipient

    /// @param _daoRecipient recipient address

    function setDaoRecipient(address _daoRecipient) external {

        if (msg.sender != governance) revert NOT_ALLOWED();

        emit DaoRecipientSet(daoRecipient, _daoRecipient);

        daoRecipient = _daoRecipient;

    }



    /// @notice function to set the accumulator fee recipient

    /// @param _accRecipient recipient address

    function setAccRecipient(address _accRecipient) external {

        if (msg.sender != governance) revert NOT_ALLOWED();

        emit AccRecipientSet(accRecipient, _accRecipient);

        accRecipient = _accRecipient;

    }



    /// @notice function to set the veSdtFee fee recipient

    /// @param _veSdtFeeRecipient recipient address

    function setVeSdtFeeRecipient(address _veSdtFeeRecipient) external {

        if (msg.sender != governance) revert NOT_ALLOWED();

        emit VeSdtFeeRecipientSet(veSdtFeeRecipient, _veSdtFeeRecipient);

        veSdtFeeRecipient = _veSdtFeeRecipient;

    }



    /// @notice function to set the governance

    /// @param _governance governance address

    function setGovernance(address _governance) external {

        if (msg.sender != governance) revert NOT_ALLOWED();

        if (_governance == address(0)) revert ZERO_ADDRESS();

        emit GovernanceSet(governance, _governance);

        governance = _governance;

    }



    /// @notice function to set the sdt Distributor

    /// @param _sdtDistributor governance address

    function setSdtDistributor(address _sdtDistributor) external {

        if (msg.sender != governance) revert NOT_ALLOWED();

        emit SdtDistributorSet(sdtDistributor, _sdtDistributor);

        sdtDistributor = _sdtDistributor;

    }



    /// @notice function to set the vault gauge factory

    /// @param _vaultGaugeFactory vault gauge factory address

    function setVaultGaugeFactory(address _vaultGaugeFactory) external {

        if (msg.sender != governance) revert NOT_ALLOWED();

        emit VaultGaugeFactorySet(vaultGaugeFactory, _vaultGaugeFactory);

        vaultGaugeFactory = _vaultGaugeFactory;

    }



    /// @notice execute a function

    /// @param to Address to sent the value to

    /// @param value Value to be sent

    /// @param data Call function data

    function execute(address to, uint256 value, bytes calldata data) external returns (bool, bytes memory) {

        if (msg.sender != governance) revert NOT_ALLOWED();

        (bool success, bytes memory result) = to.call{value: value}(data);

        return (success, result);

    }



    /// @notice internal function to increase the allowance if needed 

    /// @param _token token to approve

    /// @param _spender address to give the allowance

    /// @param _amount amount transferable by the spender 

    function _approveTokenIfNeeded(address _token, address _spender, uint256 _amount) internal {

        if (IERC20(_token).allowance(address(this), _spender) < _amount) {

            IERC20(_token).safeApprove(_spender, type(uint256).max);

        }

    }

}