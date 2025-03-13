// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';

/**
 * @title AzarusVesting
 * @dev This contract handles the vesting of ERC20 tokens for given
 * beneficiaries. The Contract does not hold any token, instead it allows a 
 * beneficiary to claim a token held by a wallet holding the supply for all 
 * beneficiaries.
 * The contract supports custom vesting schedules based on epochs (months).
 * For every new epoch to occur, the contract needs to be approved to spent the
 * amount of tokens vesting during the new epoch, then calling the
 * "nextEpoch()" function starts the new epoch
 *
 */

contract AzarusVesting is Context, Pausable, AccessControl {
    event Claim(bytes32 beneficiary, uint256 amount, address recipient);
		event NewSchedule(bytes32 beneficiary, uint256 total);
		event WalletUpdate(bytes32 beneficiary, address wallet);

		IERC20 public azarusToken;
    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
		bytes32 public constant VESTING_ROLE = keccak256('VESTING_ROLE');

		uint[] public epochTimes; //list of the times for vesting releases, starts at TGE

		uint public claimed; // amount of tokens claimed

		address public sourceWallet; //Wallet where tokens will be claimed from
		bytes32[] public _accounts; //list of accounts keccak256('Contract Name')

    mapping (bytes32 => address) private _accountWallet; //address authorized to claim
		mapping (bytes32 => uint256) private _claimedAccount; //total claimed
		mapping (bytes32 => uint256[]) private _scheduleAccount; //future vestings

    /**
     * @dev Instantiate the Vesting smart contract
		 * token: address of the token
		 * wallet: address of the wallet holding the tokens to vest. The wallet 
		 *         must approve the contract to spend the tokens
		 * _epochTimes: array of dates starting at the TGE when the 
     */
    constructor(address token, address wallet, uint[] memory _epochTimes) {
			_grantRole(PAUSER_ROLE, msg.sender);
			_grantRole(VESTING_ROLE, msg.sender);
			_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
			epochTimes = _epochTimes;
			sourceWallet = wallet;
			claimed = 0;
			azarusToken = IERC20(token);
    }

		/**
     * @dev Set the Wallet providing the supply of vested tokens, verifies 
		 * that there are enough tokens allowed to be spent for the entire vesting
		 * authorized
     */
		function setSourceWallet(address _wallet) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
			sourceWallet = _wallet;
		}

		/**
     * @dev Set vesting schedule
		 * will overwrite vesting of existing account
     */
		function setVesting(bytes32 account, uint256[] calldata _schedule)
		public onlyRole(VESTING_ROLE) whenNotPaused{
			require(_schedule.length == epochTimes.length, "The release schedule must match the length of the vesting");
			_scheduleAccount[account] = _schedule;
			// NB _claimedAccount[account] is automatically set at 0
			uint _total = 0;
			for(uint i = 0; i < _schedule.length; i++){
				_total += _schedule[i];
			}
			emit NewSchedule(account, _total);
		}


		/**
     * @dev Getter for the vesting schedule of an account
     */
		function accountSchedule(bytes32 _account)
		public view virtual returns(uint256[] memory){
			return _scheduleAccount[_account];
		}

    /**
     * @dev Getter for the beneficiary address for a given account
     */
    function accountWallet(bytes32 _account) public view returns (address) {
        return _accountWallet[_account];
    }

	  /**
     * @dev Getter the amount already claimed
     */
    function accountClaimed(bytes32 _account) public view returns (uint256) {
        return _claimedAccount[_account];
    }



		/**
     * @dev Setter for the beneficiary address for a given account
		 * setting the wallet to address(0) will block claims.
		 * Must be called by the current recipient's address
		 *
		 * emits {WalletUpdate}
     */
    function updateAccountWallet(bytes32 _accountName, address _wallet)
			public whenNotPaused{
				require(_accountWallet[_accountName] == msg.sender, "Only current account owner can update the wallet address of an account");
				_setAccountWallet(_accountName, _wallet);
    }

		/**
     * @dev Setter for the beneficiary address for a given account
		 * setting the wallet to address(0) will block claims
		 * Must be call by a vesting manager
		 *
		 * emits {WalletUpdate}
     */
    function setAccountWallet(bytes32 _accountName, address _wallet)
			public whenNotPaused  onlyRole(VESTING_ROLE){
			_setAccountWallet(_accountName, _wallet);
    }

		/**
		 * _setAccountWallet updates the account -> wallet relationship
		 * and ensures has one and only.
		 */

		function _setAccountWallet(bytes32 _accountName, address _wallet) private{
				_accountWallet[_accountName] = _wallet;
				emit WalletUpdate(_accountName, _wallet);
		}

		function unpause() public onlyRole(PAUSER_ROLE) {
			_unpause();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
      _pause();
    }

    /**
     * @dev Transfers the tokens that have already vested to the 
		 * recipient address. Must be called by the recipient.
     *
     * Emits a {Claim} event.
     */
    function claim(bytes32 _account) public whenNotPaused{			
			require(_account != 0, "Account can't be null");
			require(_accountWallet[_account] == msg.sender, "Must be called by the authorized wallet for this account");
			require(_scheduleAccount[_account].length == epochTimes.length, "Vesting schedule has an invalid length");
			uint _vested = 0;
			uint _epoch = 0;
			do{
				_vested += _scheduleAccount[_account][_epoch];
				_epoch += 1;
			}
			while( _epoch < epochTimes.length && epochTimes[_epoch] < block.timestamp);
			require(_vested > _claimedAccount[_account], "Nothing to claim");

			uint256 _distribution = _vested - _claimedAccount[_account];

			SafeERC20.safeTransferFrom(azarusToken,
				sourceWallet,
				_accountWallet[_account], 
				_distribution);
			
			_claimedAccount[_account] += _distribution;

			emit Claim(_account, _distribution, msg.sender);
    }

		function recordManualClaim(bytes32 _account, uint _amount, address _recipient) public whenNotPaused onlyRole(VESTING_ROLE){
			require(_account != 0, "Account can't be null");
			require(_amount > 0, "The claim adjust amount must be positive");
			require(_scheduleAccount[_account].length == epochTimes.length, "Vesting schedule has an invalid length");
			_claimedAccount[_account] += _amount;
			emit Claim(_account, _amount, _recipient);

		}
}