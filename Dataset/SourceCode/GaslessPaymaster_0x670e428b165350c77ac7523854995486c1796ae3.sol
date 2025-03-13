// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

/* solhint-disable reason-string */

import "./BasePaymaster.sol";
import "../utils/HashLib.sol";

enum ModeKeys {
	LISTMODE,
	BLACKLIST,
	WHITELIST
}

/**
 * @title Gasless paymaster Contract
 * @author fun.xyz
 * @notice A contract that extends the BasePaymaster contract. This allows sponsors to pay for the gas of their users.
 */
contract GaslessPaymaster is BasePaymaster {
	using UserOperationLib for UserOperation;

	//calculated cost of the postOp
	uint256 public constant COST_OF_POST = 35000;

	/**
	 * @dev This constant is used to define the version of this contract.
	 */
	uint256 public constant VERSION = 1;

	mapping(bytes32 => bool) private sponsorApprovals;

	// Token and UnlockBlock
	mapping(address => uint256) private unlockBlock;
	mapping(address => uint256) private balances;

	constructor(IEntryPoint _entryPoint) BasePaymaster(_entryPoint) {}

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
					revert("FW344");
				} else if (bytes4(data[i][:4]) == this.addDepositTo.selector) {
					(address sponsor, uint256 amount) = abi.decode(data[i][4:], (address, uint256));
					value += amount;
					_addDepositTo(sponsor, amount);
				} else {
					(bool success, ) = address(this).delegatecall(data[i]);
					require(success, "FW302");
				}
			}
		}
		require(value == msg.value, "FW303");
		emit BatchActions(data);
	}

	// Internal Access Control Key Getters

	function _getListModeKey(address sponsor) internal pure returns (bytes32) {
		return HashLib.hash2(sponsor, uint8(ModeKeys.LISTMODE));
	}

	function _getSpenderBlacklistKey(address sponsor, address spender) internal pure returns (bytes32) {
		return HashLib.hash3(sponsor, spender, uint8(ModeKeys.BLACKLIST));
	}

	function _getSpenderWhitelistKey(address sponsor, address spender) internal pure returns (bytes32) {
		return HashLib.hash3(sponsor, spender, uint8(ModeKeys.WHITELIST));
	}

	///////////////////////
	// START INTERNAL OPS//
	///////////////////////

	/**
	 * @dev Helper function for addDepositTo()
	 */
	function _addDepositTo(address spender, uint256 amount) internal {
		entryPoint.depositTo{value: amount}(address(this));
		balances[spender] += amount;
	}

	/**
	 * @dev Helper function for withdrawDepositTo()
	 */
	function _withdrawDepositTo(address sender, address payable target, uint256 amount) internal {
		uint256 unlockBlockValue = unlockBlock[sender];
		require(block.number > unlockBlockValue && unlockBlockValue != 0, "FW304");
		require(balances[sender] >= amount, "FW305");
		balances[sender] -= amount;
		entryPoint.withdrawTo(target, amount);
	}

	/**
	 * @dev Helper function to set the unlock block for a sponsor
	 */
	function _setUnlockBlock(address sponsor, uint256 num) internal {
		unlockBlock[sponsor] = num;
	}

	// Basic access control Setters

	/**
	 * @dev helper function for setListMode()
	 */
	function _setListMode(address sponsor, bool mode) internal {
		sponsorApprovals[_getListModeKey(sponsor)] = mode;
	}

	/**
	 * @dev helper function for setSpenderBlacklistMode()
	 */
	function _setSpenderBlacklistMode(address sponsor, address spender, bool mode) internal {
		sponsorApprovals[_getSpenderBlacklistKey(sponsor, spender)] = mode;
	}

	/**
	 * @dev helper function for setSpenderWhitelistMode()
	 */
	function _setSpenderWhitelistMode(address sponsor, address spender, bool mode) internal {
		sponsorApprovals[_getSpenderWhitelistKey(sponsor, spender)] = mode;
	}

	/////////////////////
	// END INTERNAL OPS//
	/////////////////////
	function _getSponsorApproval(address spender, address sponsor) internal view returns (bool) {
		bool blackListMode = sponsorApprovals[_getListModeKey(sponsor)];
		if (blackListMode) {
			return !sponsorApprovals[_getSpenderBlacklistKey(sponsor, spender)];
		}
		return sponsorApprovals[_getSpenderWhitelistKey(sponsor, spender)];
	}

	// EIP4337 OPS
	/**
	 * Verify that the user has permission to use this gasless paymaster
	 * @param userOp ERC4337 UserOperation
	 * @param opHash keccak256 hash of the userOp
	 * @param maxCost The maximum gas cost for this userOp
	 * @return context The context containing the sponsor, spender, gasPriceUserOp, and opHash
	 * @return sigTimeRange A uint256 value indicating the result of the validation, always returns 0 in this implementation
	 */
	function _validatePaymasterUserOp(
		UserOperation calldata userOp,
		bytes32 opHash,
		uint256 maxCost
	) internal view override returns (bytes memory context, uint256 sigTimeRange) {
		require(userOp.paymasterAndData.length == 20 + 20, "FW306");
		// verificationGasLimit is dual-purposed, as gas limit for postOp. make sure it is high enough
		require(userOp.verificationGasLimit > COST_OF_POST, "FW307");

		address sponsor = address(bytes20(userOp.paymasterAndData[20:]));
		uint256 sponsorUnlockBlock = unlockBlock[sponsor];
		require(sponsorUnlockBlock == 0 || sponsorUnlockBlock > block.number, "FW308");

		address spender = userOp.getSender();
		require(_getSponsorApproval(spender, sponsor), "FW309");
		require(balances[sponsor] >= maxCost, "FW310");

		uint256 gasPriceUserOp = userOp.gasPrice();
		return (abi.encode(sponsor, spender, gasPriceUserOp, opHash), 0);
	}

	/**
	 * post-operation handler.
	 * Must verify sender is the entryPoint
	 * @param context - the context value returned by validatePaymasterUserOp
	 * @param actualGasCost - actual gas used so far (without this postOp call).
	 */
	function _postOp(PostOpMode, bytes calldata context, uint256 actualGasCost) internal override {
		(address sponsor, address spender, uint256 gasPricePostOp, bytes32 opHash) = abi.decode(context, (address, address, uint256, bytes32));
		//use same conversion rate as used for validation.
		balances[sponsor] -= actualGasCost + COST_OF_POST * gasPricePostOp;
		emit PostOpGasPaid(opHash, spender, sponsor, actualGasCost + COST_OF_POST * gasPricePostOp);
	}

	///////////////////////
	// START EXTERNAL OPS//
	///////////////////////

	/**
	 * @notice Adds the specified deposit amount to the deposit balance of the given sponsor address.
	 * @param sponsor The address of the sponsor whose deposit balance will be increased.
	 * @param amount The amount of the deposit to be added.
	 */
	function addDepositTo(address sponsor, uint256 amount) public payable {
		require(msg.value == amount, "FW311");
		_addDepositTo(sponsor, amount);
		emit AddDepositTo(sponsor, amount);
	}

	/**
	 * @notice Withdraws the specified deposit amount from the deposit balance of the calling sender and transfers it to the target address.
	 * @param target The address to which the deposit amount will be transferred.
	 * @param amount The amount of the deposit to be withdrawn and transferred.
	 */
	function withdrawDepositTo(address payable target, uint256 amount) public payable {
		_withdrawDepositTo(msg.sender, target, amount);
		emit WithdrawDepositTo(msg.sender, target, amount);
	}

	// Deposit Locking
	/**
	 * @notice Locks the deposit of the calling sender by setting the unlock block to zero.
	 */
	function lockDeposit() public payable {
		_setUnlockBlock(msg.sender, 0);
		emit LockDeposit(msg.sender);
	}

	/**
	 * @notice Unlocks the deposit of the calling sender after the specified number of blocks have passed.
	 * @param num The number of blocks to wait before unlocking the deposit.
	 */
	function unlockDepositAfter(uint256 num) public payable {
		_setUnlockBlock(msg.sender, block.number + num);
		emit UnlockDepositAfter(msg.sender, block.number + num);
	}

	// Basic access control Setters
	/**
	 * @notice Sets the list mode for the calling sender.
	 * @dev true means blacklist mode, false means whitelist mode.
	 * @param mode The boolean value to set the list mode to.
	 */
	function setListMode(bool mode) public payable {
		_setListMode(msg.sender, mode);
		emit SetListMode(msg.sender, mode);
	}

	/**
	 * @notice Sets the blacklist mode for the specified spender of the calling sponsor address.
	 * @param spender The address of the spender to set the blacklist mode for.
	 * @param mode The boolean value to set the blacklist mode to.
	 */
	function setSpenderBlacklistMode(address spender, bool mode) public payable {
		_setSpenderBlacklistMode(msg.sender, spender, mode);
		emit SetSpenderBlacklistMode(msg.sender, spender, mode);
	}

	/**
	 * @notice Sets the whitelist mode for the specified spender of the calling sponsor address.
	 * @param spender The address of the spender to set the whitelist mode for.
	 * @param mode The boolean value to set the whitelist mode to.
	 */
	function setSpenderWhitelistMode(address spender, bool mode) public payable {
		_setSpenderWhitelistMode(msg.sender, spender, mode);
		emit SetSpenderWhitelistMode(msg.sender, spender, mode);
	}

	// External Data Getters
	/**
	 * @notice Returns the deposit balance of the specified sponsor address.
	 * @param sponsor The address of the sponsor to retrieve the deposit balance for.
	 * @return The deposit balance of the specified sponsor address.
	 */
	function getBalance(address sponsor) public view returns (uint256) {
		return balances[sponsor];
	}

	/**
	 * @notice Returns the unlock block of the specified spender address.
	 * @param spender The address of the spender to retrieve the unlock block for.
	 * @return The unlock block of the specified spender address.
	 */
	function getUnlockBlock(address spender) public view returns (uint256) {
		return unlockBlock[spender];
	}

	/**
	 * @notice Returns the list mode of the specified spender address.
	 * @param spender The address of the spender to retrieve the list mode for.
	 * @return The list mode of the specified spender address.
	 */
	function getListMode(address spender) public view returns (bool) {
		return sponsorApprovals[_getListModeKey(spender)];
	}

	/**
	 * @notice Returns the whitelist mode of the specified spender address for the specified sponsor.
	 * @param sponsor The address of the sponsor to retrieve the whitelist mode for.
	 * @param spender The address of the spender to retrieve the whitelist mode for.
	 * @return The whitelist mode of the specified spender address for the specified sponsor.
	 */
	function getSpenderWhitelistMode(address spender, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSpenderWhitelistKey(sponsor, spender)];
	}

	/**
	 * @notice Returns the blacklist mode of the specified spender address for the specified sponsor.
	 * @param sponsor The address of the sponsor to retrieve the blacklist mode for.
	 * @param spender The address of the spender to retrieve the blacklist mode for.
	 * @return The blacklist mode of the specified spender address for the specified sponsor.
	 */
	function getSpenderBlacklistMode(address spender, address sponsor) public view returns (bool) {
		return sponsorApprovals[_getSpenderBlacklistKey(sponsor, spender)];
	}

	/////////////////////
	// END EXTERNAL OPS//
	/////////////////////
	event AddDepositTo(address indexed sponsor, uint256 amount);
	event BatchActions(bytes[] data);
	event LockDeposit(address indexed locker);
	event PostOpGasPaid(bytes32 indexed opHash, address indexed spender, address indexed sponsor, uint256 sponsorCost);
	event SetListMode(address indexed sponsor, bool mode);
	event SetSpenderBlacklistMode(address indexed sponsor, address indexed spender, bool mode);
	event SetSpenderWhitelistMode(address indexed sponsor, address indexed spender, bool mode);
	event UnlockDepositAfter(address indexed locker, uint256 unlockBlockNum);
	event WithdrawDepositTo(address indexed sponsor, address indexed target, uint256 amount);
}