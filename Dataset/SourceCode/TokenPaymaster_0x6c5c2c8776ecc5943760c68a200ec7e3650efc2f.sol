// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

/* solhint-disable reason-string */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./BasePaymaster.sol";
import "../interfaces/oracles/ITokenPriceOracle.sol";
import "../utils/HashLib.sol";
import "../utils/DataLib.sol";
import "../interfaces/wallet/IWalletModules.sol";
import "../interfaces/deploy/IImplementationRegistry.sol";

/**
 * A token-based paymaster that accepts token deposit
 * The deposit is only a safeguard: the spender pays with his token balance.
 *  only if the spender didn't approve() the paymaster, or if the token balance is not enough, the deposit will be used.
 *  thus the required deposit is to cover just one method call.
 * The deposit is locked for the current block: the spender must issue unlockTokenDeposit() to be allowed to withdraw
 *  (but can't use the deposit for this or further operations)
 *
 * paymasterAndData holds the paymaster address followed by the token address to use.
 * @notice This paymaster will be rejected by the standard rules of EIP4337, as it uses an external oracle.
 * (the standard rules ban accessing data of an external contract)
 * It can only be used if it is "whitelisted" by the bundler.
 * (technically, it can be used by an "oracle" which returns a static value, without accessing any storage)
 */

enum DataStoreType {
	UNLOCK_BLOCK,
	TOKEN,
	LISTMODE,
	TOKENLISTMODE,
	BLACKLIST,
	WHITELIST
}
struct TokenContext {
	address spender;
	address sponsor;
	address token;
	uint256 gasPrice;
	uint256 maxTokenCost;
	uint256 maxCost;
	bytes32 opHash;
	uint256 postCost;
}
struct TokenData {
	ITokenPriceOracle oracle;
	IERC20 token;
	uint8 decimals;
	address aggregator;
}

/**
 * @title Token paymaster Contract
 * @dev A contract that extends the BasePaymaster contract and uses the UserOperationLib and SafeERC20 libraries.
 */
contract TokenPaymaster is BasePaymaster {
	using UserOperationLib for UserOperation;
	using SafeERC20 for IERC20;

	//calculated cost of the postOp
	uint256 public constant COST_OF_SIG = 40_000;
	uint256 public constant COST_OF_TRANSFER = 180_000;

	address public constant ETH = address(0);
	uint256 public accumulatedEthDust = 0;
	/**
	 * @dev This constant is used to define the version of this contract.
	 */
	uint256 public constant VERSION = 1;

	IImplementationRegistry public immutable implementationRegistry;

	mapping(bytes32 => bool) private sponsorApprovals;
	mapping(bytes32 => uint256) private dataStore;
	mapping(address => TokenData) public tokens;

	address[] private tokenList;

	constructor(IEntryPoint _entryPoint, IImplementationRegistry _implementationRegistry) BasePaymaster(_entryPoint) {
		implementationRegistry = _implementationRegistry;
	}

	function withdrawEthDust() external onlyOwner {
		uint256 ethWithdrawn = entryPoint.getDepositInfo(address(this)).deposit - accumulatedEthDust;
		entryPoint.withdrawTo(payable(owner()), ethWithdrawn);
	}

	function calculatePostOpGas(bool usePermit, bytes memory signature) internal pure returns (uint256) {
		if (!usePermit) return COST_OF_SIG + COST_OF_TRANSFER;
		(uint8 authType, , , , bytes memory sig, ) = DataLib.getAuthData(signature);
		if (authType == 0) {
			return COST_OF_SIG + COST_OF_TRANSFER;
		} else if (authType == 1) {
			(uint8[] memory pos, ) = abi.decode(sig, (uint8[], bytes[]));
			return COST_OF_SIG * pos.length + COST_OF_TRANSFER;
		} else {
			revert("FW349");
		}
	}

	/**
	 * @notice batch call method
	 * @dev Executes a batch of transactions.
	 * @param data An array of transaction data to execute.
	 */
	function batchActions(bytes[] calldata data) public payable {
		uint256 value = 0;
		unchecked {
			for (uint256 i = 0; i < data.length; ++i) {
				if (bytes4(data[i][:4]) == this.batchActions.selector) {
					revert("FW345");
				} else if (bytes4(data[i][:4]) == this.addEthDepositTo.selector) {
					(address sponsor, uint256 amount) = abi.decode(data[i][4:], (address, uint256));
					value += amount;
					_addEthDepositTo(msg.sender, sponsor, amount);
				} else {
					(bool success, ) = address(this).delegatecall(data[i]);
					require(success, "FW312");
				}
			}
		}
		require(value == msg.value, "FW313");
		emit BatchActions(data);
	}

	// Key Hash Generators

	function _getDataStoreKey(address _token, address spender, DataStoreType dataType) internal pure returns (bytes32) {
		return HashLib.hash3(_token, spender, uint8(dataType));
	}

	function _getUnlockBlockKey(address _token, address spender) internal pure returns (bytes32) {
		return _getDataStoreKey(_token, spender, DataStoreType.UNLOCK_BLOCK);
	}

	function _getTokenBalanceKey(address _token, address spender) internal pure returns (bytes32) {
		return _getDataStoreKey(_token, spender, DataStoreType.TOKEN);
	}

	function _getListModeKey(address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(sponsor, uint8(DataStoreType.LISTMODE));
	}

	function _getSpenderBlacklistKey(address spender, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(spender, sponsor, uint8(DataStoreType.BLACKLIST));
	}

	function _getSpenderWhitelistKey(address spender, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(spender, sponsor, uint8(DataStoreType.WHITELIST));
	}

	function _getSponsorTokenKey(address _token, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(_token, sponsor);
	}

	function _getTokenListModeKey(address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(sponsor, uint8(DataStoreType.TOKENLISTMODE));
	}

	function _getTokenBlacklistKey(address token, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(token, sponsor, uint8(DataStoreType.BLACKLIST));
	}

	function _getTokenWhitelistKey(address token, address sponsor) internal pure returns (bytes32) {
		return HashLib.hash3(token, sponsor, uint8(DataStoreType.WHITELIST));
	}

	///////////////////////
	// START INTERNAL OPS//
	///////////////////////

	// Tokens Stake

	function _addTokenDepositTo(address _token, address sender, address spender, uint256 amount) internal {
		require(tokens[_token].decimals != 0, "FW314");
		IERC20 token = tokens[_token].token;

		uint256 beforeBalance = token.balanceOf(address(this));
		token.safeTransferFrom(sender, address(this), amount);
		uint256 afterBalance = token.balanceOf(address(this));
		dataStore[_getTokenBalanceKey(_token, spender)] += afterBalance - beforeBalance;
	}

	function _withdrawTokenDepositTo(address _token, address sender, address target, uint256 amount) internal {
		uint256 unlockBlockValue = getUnlockBlock(_token, sender);
		require(block.number > unlockBlockValue && unlockBlockValue != 0, "FW315");

		bytes32 tokenBalanceKey = _getTokenBalanceKey(_token, sender);
		require(dataStore[tokenBalanceKey] >= amount, "FW316");
		dataStore[tokenBalanceKey] -= amount;

		IERC20 token = tokens[_token].token;
		token.safeTransfer(target, amount);
	}

	function _addEthDepositTo(address sender, address spender, uint256 amount) internal {
		entryPoint.depositTo{value: amount}(address(this));
		dataStore[_getTokenBalanceKey(ETH, spender)] += amount;
		accumulatedEthDust += amount;
		if (sender == spender) {
			_setUnlockBlock(ETH, sender, 0);
		}
	}

	function _withdrawEthDepositTo(address sender, address payable target, uint256 amount) internal {
		uint256 unlockBlockValue = getUnlockBlock(ETH, sender);
		require(block.number > unlockBlockValue && unlockBlockValue != 0, "FW317");

		bytes32 ethBalanceKey = _getTokenBalanceKey(ETH, sender);
		require(dataStore[ethBalanceKey] >= amount, "FW318");

		dataStore[ethBalanceKey] -= amount;
		accumulatedEthDust -= amount;
		entryPoint.withdrawTo(target, amount);
	}

	// Access Control

	function _setUnlockBlock(address _token, address spender, uint256 num) internal {
		dataStore[_getUnlockBlockKey(_token, spender)] = num;
	}

	function _setListMode(address sponsor, bool mode) internal {
		sponsorApprovals[_getListModeKey(sponsor)] = mode;
	}

	function _setSpenderBlacklistMode(address spender, address sponsor, bool mode) internal {
		sponsorApprovals[_getSpenderBlacklistKey(spender, sponsor)] = mode;
	}

	function _setSpenderWhitelistMode(address spender, address sponsor, bool mode) internal {
		sponsorApprovals[_getSpenderWhitelistKey(spender, sponsor)] = mode;
	}

	function _setTokenListMode(address sponsor, bool mode) internal {
		sponsorApprovals[_getTokenListModeKey(sponsor)] = mode;
	}

	function _setTokenBlacklistMode(address token, address sponsor, bool mode) internal {
		sponsorApprovals[_getTokenBlacklistKey(token, sponsor)] = mode;
	}

	function _setTokenWhitelistMode(address token, address sponsor, bool mode) internal {
		sponsorApprovals[_getTokenWhitelistKey(token, sponsor)] = mode;
	}

	function _setTokensApproval(address[] calldata _tokens, address sponsor, bool mode) internal {
		for (uint256 i = 0; i < _tokens.length; ++i) {
			_setTokensApprovalMode(_tokens[i], sponsor, mode);
		}
	}

	function _setTokensApprovalMode(address token, address sponsor, bool mode) internal {
		bytes32 tokeApprovalKey = _getSponsorTokenKey(token, sponsor);
		sponsorApprovals[tokeApprovalKey] = mode;
	}

	/////////////////////
	// END INTERNAL OPS//
	/////////////////////

	// Approval Bool Generators

	function _getSponsorApproval(address spender, address sponsor) internal view returns (bool) {
		bool blackListMode = sponsorApprovals[_getListModeKey(sponsor)];
		if (blackListMode) {
			bool isSpenderBlacklisted = sponsorApprovals[_getSpenderBlacklistKey(spender, sponsor)];
			return !isSpenderBlacklisted;
		}
		return sponsorApprovals[_getSpenderWhitelistKey(spender, sponsor)];
	}

	function _getSponsorTokenApproval(address token, address sponsor) internal view returns (bool) {
		bool blackListMode = sponsorApprovals[_getTokenListModeKey(sponsor)];
		if (blackListMode) {
			bool isTokenBlacklisted = sponsorApprovals[_getTokenBlacklistKey(token, sponsor)];
			return !isTokenBlacklisted;
		}
		return sponsorApprovals[_getTokenWhitelistKey(token, sponsor)];
	}

	function getCanPayThroughApproval(address _token, address spender, uint256 tokenAmount) public view returns (bool) {
		IERC20 token = tokens[_token].token;
		uint256 paymasterAllownace = token.allowance(spender, address(this));
		return getHasBalance(token, spender, tokenAmount) && paymasterAllownace >= tokenAmount;
	}

	function getHasBalance(IERC20 token, address spender, uint256 tokenAmount) public view returns (bool) {
		uint256 userBalance = token.balanceOf(spender);
		return userBalance >= tokenAmount;
	}

	function _getHasEnoughDeposit(address _token, address spender, uint256 tokenAmount) internal view returns (bool) {
		return dataStore[_getTokenBalanceKey(_token, spender)] >= tokenAmount;
	}

	function _getTokenIsUsable(address _token, address sponsor) internal view returns (bool) {
		return sponsorApprovals[_getSponsorTokenKey(_token, sponsor)];
	}

	// EIP-4337

	function getTokenValueOfEth(address _token, uint256 ethBought) public view virtual returns (uint256, uint256) {
		TokenData memory token = tokens[_token];
		bytes memory tokenCallData = abi.encodeWithSelector(ITokenPriceOracle.getTokenValueOfEth.selector, token.aggregator, ethBought, token.decimals);
		(bool success, bytes memory returnData) = address(token.oracle).staticcall(tokenCallData);
		require(success && returnData.length > 0, "FW319");
		return abi.decode(returnData, (uint256, uint256));
	}

	/**
	 * @notice Reimburse the paymaster for the value of gas the UserOperation spent in this transaction with _token.
	 * @param _token The address of the token used for payment.
	 * @param spender The address that made the payment.
	 * @param actualTokenCost The actual token cost of the payment.
	 * @param permitData The permit data used for token approval (if applicable).
	 */
	function _reimbursePaymaster(address _token, address spender, uint256 actualTokenCost, bytes memory permitData) internal {
		// attempt to pay with tokens:
		IERC20 erc20Token = tokens[_token].token;
		if (permitData.length > 0) {
			_transferPermit(permitData, erc20Token, spender, actualTokenCost);
		} else if (getCanPayThroughApproval(_token, spender, actualTokenCost)) {
			uint256 beforeBalance = erc20Token.balanceOf(address(this));
			erc20Token.safeTransferFrom(spender, address(this), actualTokenCost);
			uint256 afterBalance = erc20Token.balanceOf(address(this));
			require(afterBalance - beforeBalance == actualTokenCost, "FW321");
		} else {
			bytes32 spenderTokenKey = _getTokenBalanceKey(_token, spender);
			require(dataStore[spenderTokenKey] >= actualTokenCost, "FW321");
			dataStore[spenderTokenKey] -= actualTokenCost;
		}
	}

	/**
	 * @notice Transfers tokens using permit data for approval.
	 * @param permitData The permit data containing the token transfer details.
	 * @param erc20Token The ERC20 token contract instance.
	 * @param spender The address performing the token transfer.
	 */
	function _transferPermit(bytes memory permitData, IERC20 erc20Token, address spender, uint256 actualTokenCost) internal {
		(address permitToken, address to, uint256 amount, uint256 nonce, bytes memory sig) = abi.decode(
			permitData,
			(address, address, uint256, uint256, bytes)
		);
		uint256 prePermitBalance = erc20Token.balanceOf(address(this));
		(bool success, bytes memory ret) = spender.call(
			abi.encodeWithSelector(IWalletModules.permitTransfer.selector, permitToken, to, amount, nonce, sig)
		);
		{
			if (success && abi.decode(ret, (bool))) {
				uint256 postPermitBalance = erc20Token.balanceOf(address(this));
				require(postPermitBalance - prePermitBalance == amount, "FW346");
				dataStore[_getTokenBalanceKey(permitToken, spender)] += amount - actualTokenCost;
			} else {
				assembly {
					mstore(add(ret, 4), sub(mload(ret), 4))
					ret := add(ret, 4)
				}
				revert(string.concat("FW320: ", string(ret)));
			}
		}
	}

	function _validatePaymasterUserOp(
		UserOperation calldata userOp,
		bytes32 opHash,
		uint256 maxCost
	) internal view override returns (bytes memory context, uint256 sigTimeRange) {
		uint256 postCost = calculatePostOpGas(false, userOp.signature);
		require(userOp.paymasterAndData.length >= 20 + 20 + 20, "FW322");

		implementationRegistry.verifyIsValidContractAndImplementation(userOp.sender);

		address sponsor;
		address token;

		if (userOp.paymasterAndData.length == 60) {
			sponsor = address(bytes20(userOp.paymasterAndData[20:40]));
			token = address(bytes20(userOp.paymasterAndData[40:]));
		} else {
			(bytes memory addrs, ) = abi.decode(userOp.paymasterAndData[20:], (bytes, bytes));
			(sponsor, token) = abi.decode(addrs, (address, address));
		}
		{
			uint256 sponsorUnlockBlock = dataStore[_getUnlockBlockKey(ETH, sponsor)];
			require(sponsorUnlockBlock == 0, "FW324");
		}

		address spender = userOp.getSender();
		{
			uint256 accountUnlockBlock = dataStore[_getUnlockBlockKey(token, spender)];
			uint256 sponsorEthBalance = dataStore[_getTokenBalanceKey(ETH, sponsor)];

			require(accountUnlockBlock == 0, "FW325");
			require(sponsorEthBalance >= maxCost, "FW326");
		}

		bytes memory permit = "";
		(uint256 maxTokenCost, uint256 oracleValidUntil) = getTokenValueOfEth(token, maxCost);
		require(_getSponsorApproval(spender, sponsor), "FW327");
		require(_getSponsorTokenApproval(token, sponsor), "FW328");
		if (userOp.paymasterAndData.length > 60) {
			(, bytes memory permitData) = abi.decode(userOp.paymasterAndData[20:], (bytes, bytes));
			(address _token, address to, uint256 amount, uint256 nonce, bytes memory sig) = abi.decode(
				permitData,
				(address, address, uint256, uint256, bytes)
			);
			postCost = calculatePostOpGas(true, sig);

			require(_token == token, "FW329");
			require(to == address(this), "FW330");
			require(amount >= maxTokenCost, "FW331");
			require(getHasBalance(tokens[_token].token, spender, amount), "FW350");
			sigTimeRange = IWalletModules(spender).validatePermit(token, to, amount, nonce, sig);
			permit = permitData;
		} else {
			require(getCanPayThroughApproval(token, spender, maxTokenCost) || _getHasEnoughDeposit(token, spender, maxTokenCost), "FW332");
		}
		require(userOp.verificationGasLimit > postCost, "FW323");

		uint256 gasPriceUserOp = userOp.gasPrice();
		ValidationData memory data = DataLib.parseValidationData(sigTimeRange);

		if (data.validUntil == 0 || (uint48(oracleValidUntil) < data.validUntil && oracleValidUntil != 0)) {
			data.validUntil = uint48(oracleValidUntil);
		}

		return (
			abi.encode(TokenContext(spender, sponsor, token, gasPriceUserOp, maxTokenCost, maxCost, opHash, postCost), permit),
			DataLib.getValidationData(data)
		);
	}

	function _postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) internal override {
		uint256 startingGas = gasleft();
		(TokenContext memory ctx, bytes memory permitData) = abi.decode(context, (TokenContext, bytes));
		uint256 actualTokenCost = ((actualGasCost + ctx.postCost * ctx.gasPrice) * ctx.maxTokenCost) / ctx.maxCost;

		_reimbursePaymaster(ctx.token, ctx.spender, actualTokenCost, permitData);

		dataStore[_getTokenBalanceKey(ctx.token, ctx.sponsor)] += actualTokenCost;
		dataStore[_getTokenBalanceKey(ETH, ctx.sponsor)] -= actualGasCost + ctx.postCost * ctx.gasPrice;
		accumulatedEthDust -= actualGasCost + ctx.postCost * ctx.gasPrice;

		emit PostOpGasPaid(ctx.opHash, ctx.spender, ctx.sponsor, actualTokenCost, actualGasCost + ctx.postCost * ctx.gasPrice);
		require(startingGas - gasleft() <= ctx.postCost, "FW514");
		if (mode == PostOpMode.postOpReverted) {
			emit PostOpReverted(context, actualGasCost);
			// Do nothing here to not revert the whole bundle and harm reputation - From ethInfinitism
			return;
		}
	}

	///////////////////////
	// START EXTERNAL OPS//
	///////////////////////

	// Tokens Stake

	/**
	 * @notice Allows a user to deposit ETH and assign the deposit to a sponsor.
	 * @param sponsor The address of the sponsor to assign the deposit to.
	 * @param amount The amount of ETH to deposit.
	 */
	function addEthDepositTo(address sponsor, uint256 amount) public payable {
		require(msg.value == amount, "FW333");
		require(sponsor != address(0), "FW334");
		_addEthDepositTo(msg.sender, sponsor, amount);
		emit AddEthDepositTo(msg.sender, sponsor, amount);
	}

	/**
	 * @notice Allows a user to withdraw their assigned ETH deposit to a specified target address.
	 * @param target The address to withdraw the ETH to.
	 * @param amount The amount of ETH to withdraw.
	 */
	function withdrawEthDepositTo(address payable target, uint256 amount) public payable {
		require(target != address(0), "FW335");
		_withdrawEthDepositTo(msg.sender, target, amount);
		emit WithdrawEthDepositTo(msg.sender, target, amount);
	}

	/**
	 * @notice Allows a user to deposit tokens and assign the deposit to a spender.
	 * @param token The address of the token to deposit.
	 * @param spender The address of the spender to assign the deposit to.
	 * @param amount The amount of tokens to deposit.
	 */
	function addTokenDepositTo(address token, address spender, uint256 amount) public payable {
		require(token != address(0), "FW336");
		require(spender != address(0), "FW337");
		_addTokenDepositTo(token, msg.sender, spender, amount);
		emit AddTokenDepositTo(token, msg.sender, spender, amount);
	}

	/**
	 * @notice Allows a user to withdraw their assigned tokens deposit to a specified target address.
	 * @param token The address of the token to withdraw.
	 * @param target The address to withdraw the tokens to.
	 * @param amount The amount of tokens to withdraw.
	 */
	function withdrawTokenDepositTo(address token, address target, uint256 amount) public payable {
		_withdrawTokenDepositTo(token, msg.sender, target, amount);
		emit WithdrawTokenDepositTo(token, msg.sender, target, amount);
	}

	// Access Control

	/**
	 * @notice Locks the token deposit of the caller for the specified token.
	 * @param token The address of the token to lock the deposit for
	 */
	function lockTokenDeposit(address token) public payable {
		_setUnlockBlock(token, msg.sender, 0);
		emit LockTokenDeposit(token, msg.sender);
	}

	/**
	 * @notice Unlocks the token deposit of the caller for the specified token after a specified number of blocks
	 * @param token The address of the token to unlock the deposit for
	 * @param num The number of blocks after which the deposit will be unlocked
	 */
	function unlockTokenDepositAfter(address token, uint256 num) public payable {
		_setUnlockBlock(token, msg.sender, block.number + num);
		emit UnlockTokenDepositAfter(token, msg.sender, block.number + num);
	}

	/**
	 * @notice Sets the list mode to either blacklist or whitelist
	 * @param mode Boolean value to set the list mode to blacklist (true) or whitelist (false)
	 */
	function setListMode(bool mode) public payable {
		_setListMode(msg.sender, mode);
		emit SetListMode(msg.sender, mode);
	}

	/**
	 * @notice Sets the spender blacklist mode for the specified spender
	 * @param spender The address of the spender to set the blacklist mode for
	 * @param mode Boolean value to set the spender blacklist mode to blacklist (true) or whitelist (false)
	 */
	function setSpenderBlacklistMode(address spender, bool mode) public payable {
		_setSpenderBlacklistMode(spender, msg.sender, mode);
		emit SetSpenderBlacklistMode(spender, msg.sender, mode);
	}

	/**
	 * @notice Sets the spender whitelist mode for the specified spender
	 * @param spender The address of the spender to set the whitelist mode for
	 * @param mode Boolean value to set the spender whitelist mode to whitelist (true) or blacklist (false)
	 */
	function setSpenderWhitelistMode(address spender, bool mode) public payable {
		_setSpenderWhitelistMode(spender, msg.sender, mode);
		emit SetSpenderWhitelistMode(spender, msg.sender, mode);
	}

	/**
	 * @notice Sets the list mode to either blacklist or whitelist
	 * @param mode Boolean value to set the list mode to blacklist (true) or whitelist (false)
	 */
	function setTokenListMode(bool mode) public payable {
		_setTokenListMode(msg.sender, mode);
		emit SetTokenListMode(msg.sender, mode);
	}

	/**
	 * @notice Sets the token blacklist mode for the specified token
	 * @param token The address of the token to set the blacklist mode for
	 * @param mode Boolean value to set the token blacklist mode to blacklist (true) or whitelist (false)
	 */
	function setTokenBlacklistMode(address token, bool mode) public payable {
		_setTokenBlacklistMode(token, msg.sender, mode);
		emit SetTokenBlacklistMode(token, msg.sender, mode);
	}

	/**
	 * @notice Sets the token whitelist mode for the specified token.
	 * @param token The address of the token to set the whitelist mode for
	 * @param mode Boolean value to set the token whitelist mode to whitelist (true) or blacklist (false)
	 */
	function setTokenWhitelistMode(address token, bool mode) public payable {
		_setTokenWhitelistMode(token, msg.sender, mode);
		emit SetTokenWhitelistMode(token, msg.sender, mode);
	}

	/**
	 * @notice Grants approval for the caller to use the specified tokens
	 * @param _tokens An array of token addresses to grant approval for
	 */
	function addTokens(address[] calldata _tokens) public payable {
		_setTokensApproval(_tokens, msg.sender, true);
		emit AddTokens(_tokens, msg.sender);
	}

	/**
	 * @notice Removes approval for the caller to use the specified tokens
	 * @param _tokens An array of token addresses to remove approval for
	 */
	function removeTokens(address[] calldata _tokens) public payable {
		_setTokensApproval(_tokens, msg.sender, false);
		emit RemoveTokens(_tokens, msg.sender);
	}

	// Owner Only

	/**
	 * @notice Sets the data for a token
	 * @param data A struct containing the required data for the token.
	 */
	function setTokenData(TokenData calldata data) public onlyOwner {
		address tokenAddress = address(data.token);
		require(address(data.oracle) != address(0), "FW338");
		require(tokenAddress != address(0), "FW339");
		require(data.decimals > 0, "FW340");
		require(data.aggregator != address(0), "FW341");

		if (address(tokens[tokenAddress].token) == address(0)) {
			tokenList.push(tokenAddress);
		}
		tokens[tokenAddress] = data;
		emit SetTokenData(data);
	}

	/**
	 * Remove a token from the paymaster for all sponsors.
	 * @param tokenAddress Address of the token to remove data for.
	 * @param tokenListIndex Index of tokenAddress in tokenList. This is meant to avoid having to iterate over tokenList onchain.
	 */
	function removeTokenData(address tokenAddress, uint256 tokenListIndex) public onlyOwner {
		require(address(tokens[tokenAddress].token) != address(0), "FW342");
		require(tokenList[tokenListIndex] == tokenAddress, "FW343");
		tokenList[tokenListIndex] = tokenList[tokenList.length - 1];
		tokenList.pop();
		delete tokens[tokenAddress];
		emit RemoveTokenData(tokenAddress);
	}

	// Data Getters
	/**
	 * @notice Returns the unlock block for the specified token and spender.
	 * @param token Address of the token.
	 * @param spender Address of the spender.
	 * @return unlockBlock The unlock block for the specified token and spender.
	 */
	function getUnlockBlock(address token, address spender) public view returns (uint256 unlockBlock) {
		unlockBlock = dataStore[_getUnlockBlockKey(token, spender)];
	}

	/**
	 * @notice Returns the token balance for the specified token and spender.
	 * @param token Address of the token.
	 * @param spender Address of the spender.
	 * @return tokenAmount The token balance for the specified token and spender.
	 */
	function getTokenBalance(address token, address spender) public view returns (uint256 tokenAmount) {
		tokenAmount = dataStore[_getTokenBalanceKey(token, spender)];
	}

	/**
	 * @notice Returns the unlock block and token balance for the specified token and spender.
	 * @param token Address of the token.
	 * @param spender Address of the spender.
	 * @return unlockBlock The unlock block for the specified token and spender.
	 * @return tokenAmount The token balance for the specified token and spender.
	 */
	function getAllTokenData(address token, address spender) public view returns (uint256 unlockBlock, uint256 tokenAmount) {
		unlockBlock = getUnlockBlock(token, spender);
		tokenAmount = getTokenBalance(token, spender);
	}

	/**
	 * @notice Returns the token data for the specified token.
	 * @param token Address of the token.
	 * @return The token data for the specified token.
	 */
	function getToken(address token) public view returns (TokenData memory) {
		return tokens[token];
	}

	/**
	 * @notice Returns an array of all supported tokens.
	 * @return An array of all supported tokens.
	 */
	function getAllTokens() public view returns (address[] memory) {
		return tokenList;
	}

	/**
	 * @notice Returns true if the specified sponsor has enabled token usage for the specified token.
	 * @param token Address of the token.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified sponsor has enabled token usage for the specified token.
	 */
	function getSponsorTokenUsage(address token, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSponsorTokenKey(token, sponsor)];
	}

	/**
	 * @notice Returns true if the specified sponsor is in blacklist mode.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified sponsor is in blacklist mode.
	 */
	function getListMode(address sponsor) public view returns (bool) {
		return sponsorApprovals[_getListModeKey(sponsor)];
	}

	/**
	 * @notice Returns true if the specified spender is whitelisted for the specified sponsor.
	 * @param spender Address of the spender.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified spender is whitelisted for the specified sponsor.
	 */
	function getSpenderWhitelisted(address spender, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSpenderWhitelistKey(spender, sponsor)];
	}

	/**
	 * @notice Returns true if the specified spender is blacklisted for the specified sponsor.
	 * @param spender Address of the spender.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified spender is blacklisted for the specified sponsor.
	 */
	function getSpenderBlacklisted(address spender, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSpenderBlacklistKey(spender, sponsor)];
	}

	/**
	 * @notice Returns true if the specified token is in blacklist mode.
	 * @param sponsor Address of the sponsor who is changing list modes.
	 * @return True if the specified token is in blacklist mode.
	 */
	function getTokenListMode(address sponsor) public view returns (bool) {
		return sponsorApprovals[_getTokenListModeKey(sponsor)];
	}

	/**
	 * @notice Returns true if the specified token is whitelisted for the specified sponsor.
	 * @param token Address of the token.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified token is whitelisted for the specified sponsor.
	 */
	function getTokenWhitelisted(address token, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getTokenWhitelistKey(token, sponsor)];
	}

	/**
	 * @notice Returns true if the specified token is blacklisted for the specified sponsor.
	 * @param token Address of the token.
	 * @param sponsor Address of the sponsor.
	 * @return True if the specified token is blacklisted for the specified sponsor.
	 */
	function getTokenBlacklisted(address token, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getTokenBlacklistKey(token, sponsor)];
	}

	event AddEthDepositTo(address indexed caller, address indexed sponsor, uint256 amount);
	event AddTokenDepositTo(address indexed token, address indexed recipient, address indexed spender, uint256 amount);
	event AddTokens(address[] indexed tokens, address indexed sponsor);
	event BatchActions(bytes[] data);
	event LockTokenDeposit(address indexed token, address indexed spender);
	event PostOpGasPaid(bytes32 indexed opHash, address indexed spender, address indexed sponsor, uint256 spenderCost, uint256 sponsorCost);
	event PostOpReverted(bytes context, uint256 actualGasCost);
	event RemoveTokens(address[] indexed tokens, address indexed sponsor);
	event RemoveTokenData(address indexed token);
	event SetListMode(address indexed sponsor, bool mode);
	event SetSpenderBlacklistMode(address indexed spender, address indexed sponsor, bool mode);
	event SetSpenderWhitelistMode(address indexed spender, address indexed sponsor, bool mode);
	event SetTokenData(TokenData indexed data);
	event SetTokenBlacklistMode(address indexed token, address indexed sponsor, bool mode);
	event SetTokenListMode(address indexed sponsor, bool mode);
	event SetTokenWhitelistMode(address indexed token, address indexed sponsor, bool mode);
	event UnlockTokenDepositAfter(address indexed token, address indexed spender, uint256 indexed unlockBlockNum);
	event WithdrawEthDepositTo(address indexed caller, address indexed target, uint256 amount);
	event WithdrawTokenDepositTo(address indexed token, address indexed recipient, address indexed target, uint256 amount);
}