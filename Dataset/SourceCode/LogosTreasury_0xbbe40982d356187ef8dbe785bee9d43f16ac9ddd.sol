pragma solidity >=0.5.4 <0.6.0;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }





contract TheAO {

	address public theAO;

	address public nameTAOPositionAddress;



	// Check whether an address is whitelisted and granted access to transact

	// on behalf of others

	mapping (address => bool) public whitelist;



	constructor() public {

		theAO = msg.sender;

	}



	/**

	 * @dev Checks if msg.sender is in whitelist.

	 */

	modifier inWhitelist() {

		require (whitelist[msg.sender] == true);

		_;

	}



	/**

	 * @dev Transfer ownership of The AO to new address

	 * @param _theAO The new address to be transferred

	 */

	function transferOwnership(address _theAO) public {

		require (msg.sender == theAO);

		require (_theAO != address(0));

		theAO = _theAO;

	}



	/**

	 * @dev Whitelist `_account` address to transact on behalf of others

	 * @param _account The address to whitelist

	 * @param _whitelist Either to whitelist or not

	 */

	function setWhitelist(address _account, bool _whitelist) public {

		require (msg.sender == theAO);

		require (_account != address(0));

		whitelist[_account] = _whitelist;

	}

}





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



	/**

	 * @dev Multiplies two numbers, throws on overflow.

	 */

	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

		// Gas optimization: this is cheaper than asserting 'a' not being zero, but the

		// benefit is lost if 'b' is also tested.

		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

		if (a == 0) {

			return 0;

		}



		c = a * b;

		assert(c / a == b);

		return c;

	}



	/**

	 * @dev Integer division of two numbers, truncating the quotient.

	 */

	function div(uint256 a, uint256 b) internal pure returns (uint256) {

		// assert(b > 0); // Solidity automatically throws when dividing by 0

		// uint256 c = a / b;

		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return a / b;

	}



	/**

	 * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

	 */

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {

		assert(b <= a);

		return a - b;

	}



	/**

	 * @dev Adds two numbers, throws on overflow.

	 */

	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

		c = a + b;

		assert(c >= a);

		return c;

	}

}





interface INameTAOPosition {

	function senderIsAdvocate(address _sender, address _id) external view returns (bool);

	function senderIsListener(address _sender, address _id) external view returns (bool);

	function senderIsSpeaker(address _sender, address _id) external view returns (bool);

	function senderIsPosition(address _sender, address _id) external view returns (bool);

	function getAdvocate(address _id) external view returns (address);

	function nameIsAdvocate(address _nameId, address _id) external view returns (bool);

	function nameIsPosition(address _nameId, address _id) external view returns (bool);

	function initialize(address _id, address _advocateId, address _listenerId, address _speakerId) external returns (bool);

	function determinePosition(address _sender, address _id) external view returns (uint256);

}





interface INameFactory {

	function nonces(address _nameId) external view returns (uint256);

	function incrementNonce(address _nameId) external returns (uint256);

	function ethAddressToNameId(address _ethAddress) external view returns (address);

	function setNameNewAddress(address _id, address _newAddress) external returns (bool);

	function nameIdToEthAddress(address _nameId) external view returns (address);

}





interface ITAOCurrencyTreasury {

	function toBase(uint256 integerAmount, uint256 fractionAmount, bytes8 denominationName) external view returns (uint256);

	function isDenominationExist(bytes8 denominationName) external view returns (bool);

}































contract TokenERC20 {

	// Public variables of the token

	string public name;

	string public symbol;

	uint8 public decimals = 18;

	// 18 decimals is the strongly suggested default, avoid changing it

	uint256 public totalSupply;



	// This creates an array with all balances

	mapping (address => uint256) public balanceOf;

	mapping (address => mapping (address => uint256)) public allowance;



	// This generates a public event on the blockchain that will notify clients

	event Transfer(address indexed from, address indexed to, uint256 value);



	// This generates a public event on the blockchain that will notify clients

	event Approval(address indexed _owner, address indexed _spender, uint256 _value);



	// This notifies clients about the amount burnt

	event Burn(address indexed from, uint256 value);



	/**

	 * Constructor function

	 *

	 * Initializes contract with initial supply tokens to the creator of the contract

	 */

	constructor (uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {

		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount

		balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens

		name = tokenName;                                   // Set the name for display purposes

		symbol = tokenSymbol;                               // Set the symbol for display purposes

	}



	/**

	 * Internal transfer, only can be called by this contract

	 */

	function _transfer(address _from, address _to, uint _value) internal {

		// Prevent transfer to 0x0 address. Use burn() instead

		require(_to != address(0));

		// Check if the sender has enough

		require(balanceOf[_from] >= _value);

		// Check for overflows

		require(balanceOf[_to] + _value > balanceOf[_to]);

		// Save this for an assertion in the future

		uint previousBalances = balanceOf[_from] + balanceOf[_to];

		// Subtract from the sender

		balanceOf[_from] -= _value;

		// Add the same to the recipient

		balanceOf[_to] += _value;

		emit Transfer(_from, _to, _value);

		// Asserts are used to use static analysis to find bugs in your code. They should never fail

		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

	}



	/**

	 * Transfer tokens

	 *

	 * Send `_value` tokens to `_to` from your account

	 *

	 * @param _to The address of the recipient

	 * @param _value the amount to send

	 */

	function transfer(address _to, uint256 _value) public returns (bool success) {

		_transfer(msg.sender, _to, _value);

		return true;

	}



	/**

	 * Transfer tokens from other address

	 *

	 * Send `_value` tokens to `_to` in behalf of `_from`

	 *

	 * @param _from The address of the sender

	 * @param _to The address of the recipient

	 * @param _value the amount to send

	 */

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

		require(_value <= allowance[_from][msg.sender]);     // Check allowance

		allowance[_from][msg.sender] -= _value;

		_transfer(_from, _to, _value);

		return true;

	}



	/**

	 * Set allowance for other address

	 *

	 * Allows `_spender` to spend no more than `_value` tokens in your behalf

	 *

	 * @param _spender The address authorized to spend

	 * @param _value the max amount they can spend

	 */

	function approve(address _spender, uint256 _value) public returns (bool success) {

		allowance[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;

	}



	/**

	 * Set allowance for other address and notify

	 *

	 * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it

	 *

	 * @param _spender The address authorized to spend

	 * @param _value the max amount they can spend

	 * @param _extraData some extra information to send to the approved contract

	 */

	function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {

		tokenRecipient spender = tokenRecipient(_spender);

		if (approve(_spender, _value)) {

			spender.receiveApproval(msg.sender, _value, address(this), _extraData);

			return true;

		}

	}



	/**

	 * Destroy tokens

	 *

	 * Remove `_value` tokens from the system irreversibly

	 *

	 * @param _value the amount of money to burn

	 */

	function burn(uint256 _value) public returns (bool success) {

		require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

		balanceOf[msg.sender] -= _value;            // Subtract from the sender

		totalSupply -= _value;                      // Updates totalSupply

		emit Burn(msg.sender, _value);

		return true;

	}



	/**

	 * Destroy tokens from other account

	 *

	 * Remove `_value` tokens from the system irreversibly on behalf of `_from`.

	 *

	 * @param _from the address of the sender

	 * @param _value the amount of money to burn

	 */

	function burnFrom(address _from, uint256 _value) public returns (bool success) {

		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough

		require(_value <= allowance[_from][msg.sender]);    // Check allowance

		balanceOf[_from] -= _value;                         // Subtract from the targeted balance

		allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance

		totalSupply -= _value;                              // Update totalSupply

		emit Burn(_from, _value);

		return true;

	}

}





/**

 * @title TAO

 */

contract TAO {

	using SafeMath for uint256;



	address public vaultAddress;

	string public name;				// the name for this TAO

	address public originId;		// the ID of the Name that created this TAO. If Name, it's the eth address



	// TAO's data

	string public datHash;

	string public database;

	string public keyValue;

	bytes32 public contentId;



	/**

	 * 0 = TAO

	 * 1 = Name

	 */

	uint8 public typeId;



	/**

	 * @dev Constructor function

	 */

	constructor (string memory _name,

		address _originId,

		string memory _datHash,

		string memory _database,

		string memory _keyValue,

		bytes32 _contentId,

		address _vaultAddress

	) public {

		name = _name;

		originId = _originId;

		datHash = _datHash;

		database = _database;

		keyValue = _keyValue;

		contentId = _contentId;



		// Creating TAO

		typeId = 0;



		vaultAddress = _vaultAddress;

	}



	/**

	 * @dev Checks if calling address is Vault contract

	 */

	modifier onlyVault {

		require (msg.sender == vaultAddress);

		_;

	}



	/**

	 * Will receive any ETH sent

	 */

	function () external payable {

	}



	/**

	 * @dev Allows Vault to transfer `_amount` of ETH from this TAO to `_recipient`

	 * @param _recipient The recipient address

	 * @param _amount The amount to transfer

	 * @return true on success

	 */

	function transferEth(address payable _recipient, uint256 _amount) public onlyVault returns (bool) {

		_recipient.transfer(_amount);

		return true;

	}



	/**

	 * @dev Allows Vault to transfer `_amount` of ERC20 Token from this TAO to `_recipient`

	 * @param _erc20TokenAddress The address of ERC20 Token

	 * @param _recipient The recipient address

	 * @param _amount The amount to transfer

	 * @return true on success

	 */

	function transferERC20(address _erc20TokenAddress, address _recipient, uint256 _amount) public onlyVault returns (bool) {

		TokenERC20 _erc20 = TokenERC20(_erc20TokenAddress);

		_erc20.transfer(_recipient, _amount);

		return true;

	}

}









/**

 * @title Name

 */

contract Name is TAO {

	/**

	 * @dev Constructor function

	 */

	constructor (string memory _name, address _originId, string memory _datHash, string memory _database, string memory _keyValue, bytes32 _contentId, address _vaultAddress)

		TAO (_name, _originId, _datHash, _database, _keyValue, _contentId, _vaultAddress) public {

		// Creating Name

		typeId = 1;

	}

}









/**

 * @title AOLibrary

 */

library AOLibrary {

	using SafeMath for uint256;



	uint256 constant private _MULTIPLIER_DIVISOR = 10 ** 6; // 1000000 = 1

	uint256 constant private _PERCENTAGE_DIVISOR = 10 ** 6; // 100% = 1000000



	/**

	 * @dev Check whether or not the given TAO ID is a TAO

	 * @param _taoId The ID of the TAO

	 * @return true if yes. false otherwise

	 */

	function isTAO(address _taoId) public view returns (bool) {

		return (_taoId != address(0) && bytes(TAO(address(uint160(_taoId))).name()).length > 0 && TAO(address(uint160(_taoId))).originId() != address(0) && TAO(address(uint160(_taoId))).typeId() == 0);

	}



	/**

	 * @dev Check whether or not the given Name ID is a Name

	 * @param _nameId The ID of the Name

	 * @return true if yes. false otherwise

	 */

	function isName(address _nameId) public view returns (bool) {

		return (_nameId != address(0) && bytes(TAO(address(uint160(_nameId))).name()).length > 0 && Name(address(uint160(_nameId))).originId() != address(0) && Name(address(uint160(_nameId))).typeId() == 1);

	}



	/**

	 * @dev Check if `_tokenAddress` is a valid ERC20 Token address

	 * @param _tokenAddress The ERC20 Token address to check

	 */

	function isValidERC20TokenAddress(address _tokenAddress) public view returns (bool) {

		if (_tokenAddress == address(0)) {

			return false;

		}

		TokenERC20 _erc20 = TokenERC20(_tokenAddress);

		return (_erc20.totalSupply() >= 0 && bytes(_erc20.name()).length > 0 && bytes(_erc20.symbol()).length > 0);

	}



	/**

	 * @dev Checks if the calling contract address is The AO

	 *		OR

	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate

	 * @param _sender The address to check

	 * @param _theAO The AO address

	 * @param _nameTAOPositionAddress The address of NameTAOPosition

	 * @return true if yes, false otherwise

	 */

	function isTheAO(address _sender, address _theAO, address _nameTAOPositionAddress) public view returns (bool) {

		return (_sender == _theAO ||

			(

				(isTAO(_theAO) || isName(_theAO)) &&

				_nameTAOPositionAddress != address(0) &&

				INameTAOPosition(_nameTAOPositionAddress).senderIsAdvocate(_sender, _theAO)

			)

		);

	}



	/**

	 * @dev Return the divisor used to correctly calculate percentage.

	 *		Percentage stored throughout AO contracts covers 4 decimals,

	 *		so 1% is 10000, 1.25% is 12500, etc

	 */

	function PERCENTAGE_DIVISOR() public pure returns (uint256) {

		return _PERCENTAGE_DIVISOR;

	}



	/**

	 * @dev Return the divisor used to correctly calculate multiplier.

	 *		Multiplier stored throughout AO contracts covers 6 decimals,

	 *		so 1 is 1000000, 0.023 is 23000, etc

	 */

	function MULTIPLIER_DIVISOR() public pure returns (uint256) {

		return _MULTIPLIER_DIVISOR;

	}



	/**

	 * @dev deploy a TAO

	 * @param _name The name of the TAO

	 * @param _originId The Name ID the creates the TAO

	 * @param _datHash The datHash of this TAO

	 * @param _database The database for this TAO

	 * @param _keyValue The key/value pair to be checked on the database

	 * @param _contentId The contentId related to this TAO

	 * @param _nameTAOVaultAddress The address of NameTAOVault

	 */

	function deployTAO(string memory _name,

		address _originId,

		string memory _datHash,

		string memory _database,

		string memory _keyValue,

		bytes32 _contentId,

		address _nameTAOVaultAddress

		) public returns (TAO _tao) {

		_tao = new TAO(_name, _originId, _datHash, _database, _keyValue, _contentId, _nameTAOVaultAddress);

	}



	/**

	 * @dev deploy a Name

	 * @param _name The name of the Name

	 * @param _originId The eth address the creates the Name

	 * @param _datHash The datHash of this Name

	 * @param _database The database for this Name

	 * @param _keyValue The key/value pair to be checked on the database

	 * @param _contentId The contentId related to this Name

	 * @param _nameTAOVaultAddress The address of NameTAOVault

	 */

	function deployName(string memory _name,

		address _originId,

		string memory _datHash,

		string memory _database,

		string memory _keyValue,

		bytes32 _contentId,

		address _nameTAOVaultAddress

		) public returns (Name _myName) {

		_myName = new Name(_name, _originId, _datHash, _database, _keyValue, _contentId, _nameTAOVaultAddress);

	}



	/**

	 * @dev Calculate the new weighted multiplier when adding `_additionalPrimordialAmount` at `_additionalWeightedMultiplier` to the current `_currentPrimordialBalance` at `_currentWeightedMultiplier`

	 * @param _currentWeightedMultiplier Account's current weighted multiplier

	 * @param _currentPrimordialBalance Account's current primordial ion balance

	 * @param _additionalWeightedMultiplier The weighted multiplier to be added

	 * @param _additionalPrimordialAmount The primordial ion amount to be added

	 * @return the new primordial weighted multiplier

	 */

	function calculateWeightedMultiplier(uint256 _currentWeightedMultiplier, uint256 _currentPrimordialBalance, uint256 _additionalWeightedMultiplier, uint256 _additionalPrimordialAmount) public pure returns (uint256) {

		if (_currentWeightedMultiplier > 0) {

			uint256 _totalWeightedIons = (_currentWeightedMultiplier.mul(_currentPrimordialBalance)).add(_additionalWeightedMultiplier.mul(_additionalPrimordialAmount));

			uint256 _totalIons = _currentPrimordialBalance.add(_additionalPrimordialAmount);

			return _totalWeightedIons.div(_totalIons);

		} else {

			return _additionalWeightedMultiplier;

		}

	}



	/**

	 * @dev Calculate the primordial ion multiplier on a given lot

	 *		Total Primordial Mintable = T

	 *		Total Primordial Minted = M

	 *		Starting Multiplier = S

	 *		Ending Multiplier = E

	 *		To Purchase = P

	 *		Multiplier for next Lot of Amount = (1 - ((M + P/2) / T)) x (S-E)

	 *

	 * @param _purchaseAmount The amount of primordial ion intended to be purchased

	 * @param _totalPrimordialMintable Total Primordial ion mintable

	 * @param _totalPrimordialMinted Total Primordial ion minted so far

	 * @param _startingMultiplier The starting multiplier in (10 ** 6)

	 * @param _endingMultiplier The ending multiplier in (10 ** 6)

	 * @return The multiplier in (10 ** 6)

	 */

	function calculatePrimordialMultiplier(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {

		if (_purchaseAmount > 0 && _purchaseAmount <= _totalPrimordialMintable.sub(_totalPrimordialMinted)) {

			/**

			 * Let temp = M + (P/2)

			 * Multiplier = (1 - (temp / T)) x (S-E)

			 */

			uint256 temp = _totalPrimordialMinted.add(_purchaseAmount.div(2));



			/**

			 * Multiply multiplier with _MULTIPLIER_DIVISOR/_MULTIPLIER_DIVISOR to account for 6 decimals

			 * so, Multiplier = (_MULTIPLIER_DIVISOR/_MULTIPLIER_DIVISOR) * (1 - (temp / T)) * (S-E)

			 * Multiplier = ((_MULTIPLIER_DIVISOR * (1 - (temp / T))) * (S-E)) / _MULTIPLIER_DIVISOR

			 * Multiplier = ((_MULTIPLIER_DIVISOR - ((_MULTIPLIER_DIVISOR * temp) / T)) * (S-E)) / _MULTIPLIER_DIVISOR

			 * Take out the division by _MULTIPLIER_DIVISOR for now and include in later calculation

			 * Multiplier = (_MULTIPLIER_DIVISOR - ((_MULTIPLIER_DIVISOR * temp) / T)) * (S-E)

			 */

			uint256 multiplier = (_MULTIPLIER_DIVISOR.sub(_MULTIPLIER_DIVISOR.mul(temp).div(_totalPrimordialMintable))).mul(_startingMultiplier.sub(_endingMultiplier));

			/**

			 * Since _startingMultiplier and _endingMultiplier are in 6 decimals

			 * Need to divide multiplier by _MULTIPLIER_DIVISOR

			 */

			return multiplier.div(_MULTIPLIER_DIVISOR);

		} else {

			return 0;

		}

	}



	/**

	 * @dev Calculate the bonus percentage of network ion on a given lot

	 *		Total Primordial Mintable = T

	 *		Total Primordial Minted = M

	 *		Starting Network Bonus Multiplier = Bs

	 *		Ending Network Bonus Multiplier = Be

	 *		To Purchase = P

	 *		AO Bonus % = B% = (1 - ((M + P/2) / T)) x (Bs-Be)

	 *

	 * @param _purchaseAmount The amount of primordial ion intended to be purchased

	 * @param _totalPrimordialMintable Total Primordial ion intable

	 * @param _totalPrimordialMinted Total Primordial ion minted so far

	 * @param _startingMultiplier The starting Network ion bonus multiplier

	 * @param _endingMultiplier The ending Network ion bonus multiplier

	 * @return The bonus percentage

	 */

	function calculateNetworkBonusPercentage(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {

		if (_purchaseAmount > 0 && _purchaseAmount <= _totalPrimordialMintable.sub(_totalPrimordialMinted)) {

			/**

			 * Let temp = M + (P/2)

			 * B% = (1 - (temp / T)) x (Bs-Be)

			 */

			uint256 temp = _totalPrimordialMinted.add(_purchaseAmount.div(2));



			/**

			 * Multiply B% with _PERCENTAGE_DIVISOR/_PERCENTAGE_DIVISOR to account for 6 decimals

			 * so, B% = (_PERCENTAGE_DIVISOR/_PERCENTAGE_DIVISOR) * (1 - (temp / T)) * (Bs-Be)

			 * B% = ((_PERCENTAGE_DIVISOR * (1 - (temp / T))) * (Bs-Be)) / _PERCENTAGE_DIVISOR

			 * B% = ((_PERCENTAGE_DIVISOR - ((_PERCENTAGE_DIVISOR * temp) / T)) * (Bs-Be)) / _PERCENTAGE_DIVISOR

			 * Take out the division by _PERCENTAGE_DIVISOR for now and include in later calculation

			 * B% = (_PERCENTAGE_DIVISOR - ((_PERCENTAGE_DIVISOR * temp) / T)) * (Bs-Be)

			 * But since Bs and Be are in 6 decimals, need to divide by _PERCENTAGE_DIVISOR

			 * B% = (_PERCENTAGE_DIVISOR - ((_PERCENTAGE_DIVISOR * temp) / T)) * (Bs-Be) / _PERCENTAGE_DIVISOR

			 */

			uint256 bonusPercentage = (_PERCENTAGE_DIVISOR.sub(_PERCENTAGE_DIVISOR.mul(temp).div(_totalPrimordialMintable))).mul(_startingMultiplier.sub(_endingMultiplier)).div(_PERCENTAGE_DIVISOR);

			return bonusPercentage;

		} else {

			return 0;

		}

	}



	/**

	 * @dev Calculate the bonus amount of network ion on a given lot

	 *		AO Bonus Amount = B% x P

	 *

	 * @param _purchaseAmount The amount of primordial ion intended to be purchased

	 * @param _totalPrimordialMintable Total Primordial ion intable

	 * @param _totalPrimordialMinted Total Primordial ion minted so far

	 * @param _startingMultiplier The starting Network ion bonus multiplier

	 * @param _endingMultiplier The ending Network ion bonus multiplier

	 * @return The bonus percentage

	 */

	function calculateNetworkBonusAmount(uint256 _purchaseAmount, uint256 _totalPrimordialMintable, uint256 _totalPrimordialMinted, uint256 _startingMultiplier, uint256 _endingMultiplier) public pure returns (uint256) {

		uint256 bonusPercentage = calculateNetworkBonusPercentage(_purchaseAmount, _totalPrimordialMintable, _totalPrimordialMinted, _startingMultiplier, _endingMultiplier);

		/**

		 * Since bonusPercentage is in _PERCENTAGE_DIVISOR format, need to divide it with _PERCENTAGE DIVISOR

		 * when calculating the network ion bonus amount

		 */

		uint256 networkBonus = bonusPercentage.mul(_purchaseAmount).div(_PERCENTAGE_DIVISOR);

		return networkBonus;

	}



	/**

	 * @dev Calculate the maximum amount of Primordial an account can burn

	 *		_primordialBalance = P

	 *		_currentWeightedMultiplier = M

	 *		_maximumMultiplier = S

	 *		_amountToBurn = B

	 *		B = ((S x P) - (P x M)) / S

	 *

	 * @param _primordialBalance Account's primordial ion balance

	 * @param _currentWeightedMultiplier Account's current weighted multiplier

	 * @param _maximumMultiplier The maximum multiplier of this account

	 * @return The maximum burn amount

	 */

	function calculateMaximumBurnAmount(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _maximumMultiplier) public pure returns (uint256) {

		return (_maximumMultiplier.mul(_primordialBalance).sub(_primordialBalance.mul(_currentWeightedMultiplier))).div(_maximumMultiplier);

	}



	/**

	 * @dev Calculate the new multiplier after burning primordial ion

	 *		_primordialBalance = P

	 *		_currentWeightedMultiplier = M

	 *		_amountToBurn = B

	 *		_newMultiplier = E

	 *		E = (P x M) / (P - B)

	 *

	 * @param _primordialBalance Account's primordial ion balance

	 * @param _currentWeightedMultiplier Account's current weighted multiplier

	 * @param _amountToBurn The amount of primordial ion to burn

	 * @return The new multiplier

	 */

	function calculateMultiplierAfterBurn(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _amountToBurn) public pure returns (uint256) {

		return _primordialBalance.mul(_currentWeightedMultiplier).div(_primordialBalance.sub(_amountToBurn));

	}



	/**

	 * @dev Calculate the new multiplier after converting network ion to primordial ion

	 *		_primordialBalance = P

	 *		_currentWeightedMultiplier = M

	 *		_amountToConvert = C

	 *		_newMultiplier = E

	 *		E = (P x M) / (P + C)

	 *

	 * @param _primordialBalance Account's primordial ion balance

	 * @param _currentWeightedMultiplier Account's current weighted multiplier

	 * @param _amountToConvert The amount of network ion to convert

	 * @return The new multiplier

	 */

	function calculateMultiplierAfterConversion(uint256 _primordialBalance, uint256 _currentWeightedMultiplier, uint256 _amountToConvert) public pure returns (uint256) {

		return _primordialBalance.mul(_currentWeightedMultiplier).div(_primordialBalance.add(_amountToConvert));

	}



	/**

	 * @dev count num of digits

	 * @param number uint256 of the nuumber to be checked

	 * @return uint8 num of digits

	 */

	function numDigits(uint256 number) public pure returns (uint8) {

		uint8 digits = 0;

		while(number != 0) {

			number = number.div(10);

			digits++;

		}

		return digits;

	}

}



















/**

 * @title TAOCurrency

 */

contract TAOCurrency is TheAO {

	using SafeMath for uint256;



	// Public variables of the contract

	string public name;

	string public symbol;

	uint8 public decimals;



	// To differentiate denomination of TAO Currency

	uint256 public powerOfTen;



	uint256 public totalSupply;



	// This creates an array with all balances

	// address is the address of nameId, not the eth public address

	mapping (address => uint256) public balanceOf;



	// This generates a public event on the blockchain that will notify clients

	// address is the address of TAO/Name Id, not eth public address

	event Transfer(address indexed from, address indexed to, uint256 value);



	// This notifies clients about the amount burnt

	// address is the address of TAO/Name Id, not eth public address

	event Burn(address indexed from, uint256 value);



	/**

	 * Constructor function

	 *

	 * Initializes contract with initial supply TAOCurrency to the creator of the contract

	 */

	constructor (string memory _name, string memory _symbol, address _nameTAOPositionAddress) public {

		name = _name;		// Set the name for display purposes

		symbol = _symbol;	// Set the symbol for display purposes



		powerOfTen = 0;

		decimals = 0;



		setNameTAOPositionAddress(_nameTAOPositionAddress);

	}



	/**

	 * @dev Checks if the calling contract address is The AO

	 *		OR

	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate

	 */

	modifier onlyTheAO {

		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));

		_;

	}



	/**

	 * @dev Check if `_id` is a Name or a TAO

	 */

	modifier isNameOrTAO(address _id) {

		require (AOLibrary.isName(_id) || AOLibrary.isTAO(_id));

		_;

	}



	/***** The AO ONLY METHODS *****/

	/**

	 * @dev Transfer ownership of The AO to new address

	 * @param _theAO The new address to be transferred

	 */

	function transferOwnership(address _theAO) public onlyTheAO {

		require (_theAO != address(0));

		theAO = _theAO;

	}



	/**

	 * @dev Whitelist `_account` address to transact on behalf of others

	 * @param _account The address to whitelist

	 * @param _whitelist Either to whitelist or not

	 */

	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {

		require (_account != address(0));

		whitelist[_account] = _whitelist;

	}



	/**

	 * @dev The AO set the NameTAOPosition Address

	 * @param _nameTAOPositionAddress The address of NameTAOPosition

	 */

	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {

		require (_nameTAOPositionAddress != address(0));

		nameTAOPositionAddress = _nameTAOPositionAddress;

	}



	/***** PUBLIC METHODS *****/

	/**

	 * @dev transfer TAOCurrency from other address

	 *

	 * Send `_value` TAOCurrency to `_to` in behalf of `_from`

	 *

	 * @param _from The address of the sender

	 * @param _to The address of the recipient

	 * @param _value the amount to send

	 */

	function transferFrom(address _from, address _to, uint256 _value) public inWhitelist isNameOrTAO(_from) isNameOrTAO(_to) returns (bool) {

		_transfer(_from, _to, _value);

		return true;

	}



	/**

	 * @dev Create `mintedAmount` TAOCurrency and send it to `target`

	 * @param target Address to receive TAOCurrency

	 * @param mintedAmount The amount of TAOCurrency it will receive

	 * @return true on success

	 */

	function mint(address target, uint256 mintedAmount) public inWhitelist isNameOrTAO(target) returns (bool) {

		_mint(target, mintedAmount);

		return true;

	}



	/**

	 *

	 * @dev Whitelisted address remove `_value` TAOCurrency from the system irreversibly on behalf of `_from`.

	 *

	 * @param _from the address of the sender

	 * @param _value the amount of money to burn

	 */

	function whitelistBurnFrom(address _from, uint256 _value) public inWhitelist isNameOrTAO(_from) returns (bool success) {

		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough

		balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the targeted balance

		totalSupply = totalSupply.sub(_value);              // Update totalSupply

		emit Burn(_from, _value);

		return true;

	}



	/***** INTERNAL METHODS *****/

	/**

	 * @dev Send `_value` TAOCurrency from `_from` to `_to`

	 * @param _from The address of sender

	 * @param _to The address of the recipient

	 * @param _value The amount to send

	 */

	function _transfer(address _from, address _to, uint256 _value) internal {

		require (_to != address(0));							// Prevent transfer to 0x0 address. Use burn() instead

		require (balanceOf[_from] >= _value);					// Check if the sender has enough

		require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows

		uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);

		balanceOf[_from] = balanceOf[_from].sub(_value);        // Subtract from the sender

		balanceOf[_to] = balanceOf[_to].add(_value);            // Add the same to the recipient

		emit Transfer(_from, _to, _value);

		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);

	}



	/**

	 * @dev Create `mintedAmount` TAOCurrency and send it to `target`

	 * @param target Address to receive TAOCurrency

	 * @param mintedAmount The amount of TAOCurrency it will receive

	 */

	function _mint(address target, uint256 mintedAmount) internal {

		balanceOf[target] = balanceOf[target].add(mintedAmount);

		totalSupply = totalSupply.add(mintedAmount);

		emit Transfer(address(0), address(this), mintedAmount);

		emit Transfer(address(this), target, mintedAmount);

	}

}







/**

 * @title TAOCurrency

 *

 * The purpose of this contract is to list all of the valid denominations of TAOCurrency and do the conversion between denominations

 */

contract TAOCurrencyTreasury is TheAO, ITAOCurrencyTreasury {

	using SafeMath for uint256;



	uint256 public totalDenominations;

	uint256 public totalDenominationExchanges;



	address public nameFactoryAddress;



	INameFactory internal _nameFactory;



	struct Denomination {

		bytes8 name;

		address denominationAddress;

	}



	struct DenominationExchange {

		bytes32 exchangeId;

		address nameId;			// The nameId that perform this exchange

		address fromDenominationAddress;	// The address of the from denomination

		address toDenominationAddress;		// The address of the target denomination

		uint256 amount;

	}



	// Mapping from denomination index to Denomination object

	// The list is in order from lowest denomination to highest denomination

	// i.e, denominations[1] is the base denomination

	mapping (uint256 => Denomination) internal denominations;



	// Mapping from denomination ID to index of denominations

	mapping (bytes8 => uint256) internal denominationIndex;



	// Mapping from exchange id to DenominationExchange object

	mapping (uint256 => DenominationExchange) internal denominationExchanges;

	mapping (bytes32 => uint256) internal denominationExchangeIdLookup;



	// Event to be broadcasted to public when a exchange between denominations happens

	event ExchangeDenomination(address indexed nameId, bytes32 indexed exchangeId, uint256 amount, address fromDenominationAddress, string fromDenominationSymbol, address toDenominationAddress, string toDenominationSymbol);



	/**

	 * @dev Constructor function

	 */

	constructor(address _nameFactoryAddress, address _nameTAOPositionAddress) public {

		setNameFactoryAddress(_nameFactoryAddress);

		setNameTAOPositionAddress(_nameTAOPositionAddress);

	}



	/**

	 * @dev Checks if the calling contract address is The AO

	 *		OR

	 *		If The AO is set to a Name/TAO, then check if calling address is the Advocate

	 */

	modifier onlyTheAO {

		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));

		_;

	}



	/**

	 * @dev Checks if denomination is valid

	 */

	modifier isValidDenomination(bytes8 denominationName) {

		require (this.isDenominationExist(denominationName));

		_;

	}



	/***** The AO ONLY METHODS *****/

	/**

	 * @dev Transfer ownership of The AO to new address

	 * @param _theAO The new address to be transferred

	 */

	function transferOwnership(address _theAO) public onlyTheAO {

		require (_theAO != address(0));

		theAO = _theAO;

	}



	/**

	 * @dev Whitelist `_account` address to transact on behalf of others

	 * @param _account The address to whitelist

	 * @param _whitelist Either to whitelist or not

	 */

	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {

		require (_account != address(0));

		whitelist[_account] = _whitelist;

	}



	/**

	 * @dev The AO set the NameTAOPosition Address

	 * @param _nameTAOPositionAddress The address of NameTAOPosition

	 */

	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {

		require (_nameTAOPositionAddress != address(0));

		nameTAOPositionAddress = _nameTAOPositionAddress;

	}



	/**

	 * @dev The AO set the NameFactory Address

	 * @param _nameFactoryAddress The address of NameFactory

	 */

	function setNameFactoryAddress(address _nameFactoryAddress) public onlyTheAO {

		require (_nameFactoryAddress != address(0));

		nameFactoryAddress = _nameFactoryAddress;

		_nameFactory = INameFactory(_nameFactoryAddress);

	}



	/**

	 * @dev The AO adds denomination and the contract address associated with it

	 * @param denominationName The name of the denomination, i.e ao, kilo, mega, etc.

	 * @param denominationAddress The address of the denomination TAOCurrency

	 * @return true on success

	 */

	function addDenomination(bytes8 denominationName, address denominationAddress) public onlyTheAO returns (bool) {

		require (denominationName.length > 0);

		require (denominationName[0] != 0);

		require (denominationAddress != address(0));

		require (denominationIndex[denominationName] == 0);

		totalDenominations++;

		// Make sure the new denomination is higher than the previous

		if (totalDenominations > 1) {

			TAOCurrency _lastDenominationTAOCurrency = TAOCurrency(denominations[totalDenominations - 1].denominationAddress);

			TAOCurrency _newDenominationTAOCurrency = TAOCurrency(denominationAddress);

			require (_newDenominationTAOCurrency.powerOfTen() > _lastDenominationTAOCurrency.powerOfTen());

		}

		denominations[totalDenominations].name = denominationName;

		denominations[totalDenominations].denominationAddress = denominationAddress;

		denominationIndex[denominationName] = totalDenominations;

		return true;

	}



	/**

	 * @dev The AO updates denomination address or activates/deactivates the denomination

	 * @param denominationName The name of the denomination, i.e ao, kilo, mega, etc.

	 * @param denominationAddress The address of the denomination TAOCurrency

	 * @return true on success

	 */

	function updateDenomination(bytes8 denominationName, address denominationAddress) public onlyTheAO isValidDenomination(denominationName) returns (bool) {

		require (denominationAddress != address(0));

		uint256 _denominationNameIndex = denominationIndex[denominationName];

		TAOCurrency _newDenominationTAOCurrency = TAOCurrency(denominationAddress);

		if (_denominationNameIndex > 1) {

			TAOCurrency _prevDenominationTAOCurrency = TAOCurrency(denominations[_denominationNameIndex - 1].denominationAddress);

			require (_newDenominationTAOCurrency.powerOfTen() > _prevDenominationTAOCurrency.powerOfTen());

		}

		if (_denominationNameIndex < totalDenominations) {

			TAOCurrency _lastDenominationTAOCurrency = TAOCurrency(denominations[totalDenominations].denominationAddress);

			require (_newDenominationTAOCurrency.powerOfTen() < _lastDenominationTAOCurrency.powerOfTen());

		}

		denominations[denominationIndex[denominationName]].denominationAddress = denominationAddress;

		return true;

	}



	/***** PUBLIC METHODS *****/

	/**

	 * @dev Check if denomination exist given a name

	 * @param denominationName The denomination name to check

	 * @return true if yes. false otherwise

	 */

	function isDenominationExist(bytes8 denominationName) external view returns (bool) {

		return (denominationName.length > 0 &&

			denominationName[0] != 0 &&

			denominationIndex[denominationName] > 0 &&

			denominations[denominationIndex[denominationName]].denominationAddress != address(0)

	   );

	}



	/**

	 * @dev Get denomination info based on name

	 * @param denominationName The name to be queried

	 * @return the denomination short name

	 * @return the denomination address

	 * @return the denomination public name

	 * @return the denomination symbol

	 * @return the denomination num of decimals

	 * @return the denomination multiplier (power of ten)

	 */

	function getDenominationByName(bytes8 denominationName) public isValidDenomination(denominationName) view returns (bytes8, address, string memory, string memory, uint8, uint256) {

		TAOCurrency _tc = TAOCurrency(denominations[denominationIndex[denominationName]].denominationAddress);

		return (

			denominations[denominationIndex[denominationName]].name,

			denominations[denominationIndex[denominationName]].denominationAddress,

			_tc.name(),

			_tc.symbol(),

			_tc.decimals(),

			_tc.powerOfTen()

		);

	}



	/**

	 * @dev Get denomination info by index

	 * @param index The index to be queried

	 * @return the denomination short name

	 * @return the denomination address

	 * @return the denomination public name

	 * @return the denomination symbol

	 * @return the denomination num of decimals

	 * @return the denomination multiplier (power of ten)

	 */

	function getDenominationByIndex(uint256 index) public view returns (bytes8, address, string memory, string memory, uint8, uint256) {

		require (index > 0 && index <= totalDenominations);

		require (denominations[index].denominationAddress != address(0));

		TAOCurrency _tc = TAOCurrency(denominations[index].denominationAddress);

		return (

			denominations[index].name,

			denominations[index].denominationAddress,

			_tc.name(),

			_tc.symbol(),

			_tc.decimals(),

			_tc.powerOfTen()

		);

	}



	/**

	 * @dev Get base denomination info

	 * @return the denomination short name

	 * @return the denomination address

	 * @return the denomination public name

	 * @return the denomination symbol

	 * @return the denomination num of decimals

	 * @return the denomination multiplier (power of ten)

	 */

	function getBaseDenomination() public view returns (bytes8, address, string memory, string memory, uint8, uint256) {

		require (totalDenominations > 0);

		return getDenominationByIndex(1);

	}



	/**

	 * @dev convert TAOCurrency from `denominationName` denomination to base denomination,

	 *		in this case it's similar to web3.toWei() functionality

	 *

	 * Example:

	 * 9.1 Kilo should be entered as 9 integerAmount and 100 fractionAmount

	 * 9.02 Kilo should be entered as 9 integerAmount and 20 fractionAmount

	 * 9.001 Kilo should be entered as 9 integerAmount and 1 fractionAmount

	 *

	 * @param integerAmount uint256 of the integer amount to be converted

	 * @param fractionAmount uint256 of the frational amount to be converted

	 * @param denominationName bytes8 name of the TAOCurrency denomination

	 * @return uint256 converted amount in base denomination from target denomination

	 */

	function toBase(uint256 integerAmount, uint256 fractionAmount, bytes8 denominationName) external view returns (uint256) {

		uint256 _fractionAmount = fractionAmount;

		if (this.isDenominationExist(denominationName) && (integerAmount > 0 || _fractionAmount > 0)) {

			Denomination memory _denomination = denominations[denominationIndex[denominationName]];

			TAOCurrency _denominationTAOCurrency = TAOCurrency(_denomination.denominationAddress);

			uint8 fractionNumDigits = AOLibrary.numDigits(_fractionAmount);

			require (fractionNumDigits <= _denominationTAOCurrency.decimals());

			uint256 baseInteger = integerAmount.mul(10 ** _denominationTAOCurrency.powerOfTen());

			if (_denominationTAOCurrency.decimals() == 0) {

				_fractionAmount = 0;

			}

			return baseInteger.add(_fractionAmount);

		} else {

			return 0;

		}

	}



	/**

	 * @dev convert TAOCurrency from base denomination to `denominationName` denomination,

	 *		in this case it's similar to web3.fromWei() functionality

	 * @param integerAmount uint256 of the base amount to be converted

	 * @param denominationName bytes8 name of the target TAOCurrency denomination

	 * @return uint256 of the converted integer amount in target denomination

	 * @return uint256 of the converted fraction amount in target denomination

	 */

	function fromBase(uint256 integerAmount, bytes8 denominationName) public view returns (uint256, uint256) {

		if (this.isDenominationExist(denominationName)) {

			Denomination memory _denomination = denominations[denominationIndex[denominationName]];

			TAOCurrency _denominationTAOCurrency = TAOCurrency(_denomination.denominationAddress);

			uint256 denominationInteger = integerAmount.div(10 ** _denominationTAOCurrency.powerOfTen());

			uint256 denominationFraction = integerAmount.sub(denominationInteger.mul(10 ** _denominationTAOCurrency.powerOfTen()));

			return (denominationInteger, denominationFraction);

		} else {

			return (0, 0);

		}

	}



	/**

	 * @dev exchange `amount` TAOCurrency from `fromDenominationName` denomination to TAOCurrency in `toDenominationName` denomination

	 * @param amount The amount of TAOCurrency to exchange

	 * @param fromDenominationName The origin denomination

	 * @param toDenominationName The target denomination

	 */

	function exchangeDenomination(uint256 amount, bytes8 fromDenominationName, bytes8 toDenominationName) public isValidDenomination(fromDenominationName) isValidDenomination(toDenominationName) {

		address _nameId = _nameFactory.ethAddressToNameId(msg.sender);

		require (_nameId != address(0));

		require (amount > 0);

		Denomination memory _fromDenomination = denominations[denominationIndex[fromDenominationName]];

		Denomination memory _toDenomination = denominations[denominationIndex[toDenominationName]];

		TAOCurrency _fromDenominationCurrency = TAOCurrency(_fromDenomination.denominationAddress);

		TAOCurrency _toDenominationCurrency = TAOCurrency(_toDenomination.denominationAddress);

		require (_fromDenominationCurrency.whitelistBurnFrom(_nameId, amount));

		require (_toDenominationCurrency.mint(_nameId, amount));



		// Store the DenominationExchange information

		totalDenominationExchanges++;

		bytes32 _exchangeId = keccak256(abi.encodePacked(this, _nameId, totalDenominationExchanges));

		denominationExchangeIdLookup[_exchangeId] = totalDenominationExchanges;



		DenominationExchange storage _denominationExchange = denominationExchanges[totalDenominationExchanges];

		_denominationExchange.exchangeId = _exchangeId;

		_denominationExchange.nameId = _nameId;

		_denominationExchange.fromDenominationAddress = _fromDenomination.denominationAddress;

		_denominationExchange.toDenominationAddress = _toDenomination.denominationAddress;

		_denominationExchange.amount = amount;



		emit ExchangeDenomination(_nameId, _exchangeId, amount, _fromDenomination.denominationAddress, TAOCurrency(_fromDenomination.denominationAddress).symbol(), _toDenomination.denominationAddress, TAOCurrency(_toDenomination.denominationAddress).symbol());

	}



	/**

	 * @dev Get DenominationExchange information given an exchange ID

	 * @param _exchangeId The exchange ID to query

	 * @return The name ID that performed the exchange

	 * @return The from denomination address

	 * @return The to denomination address

	 * @return The from denomination symbol

	 * @return The to denomination symbol

	 * @return The amount exchanged

	 */

	function getDenominationExchangeById(bytes32 _exchangeId) public view returns (address, address, address, string memory, string memory, uint256) {

		require (denominationExchangeIdLookup[_exchangeId] > 0);

		DenominationExchange memory _denominationExchange = denominationExchanges[denominationExchangeIdLookup[_exchangeId]];

		return (

			_denominationExchange.nameId,

			_denominationExchange.fromDenominationAddress,

			_denominationExchange.toDenominationAddress,

			TAOCurrency(_denominationExchange.fromDenominationAddress).symbol(),

			TAOCurrency(_denominationExchange.toDenominationAddress).symbol(),

			_denominationExchange.amount

		);

	}



	/**

	 * @dev Return the highest possible denomination given a base amount

	 * @param amount The amount to be converted

	 * @return the denomination short name

	 * @return the denomination address

	 * @return the integer amount at the denomination level

	 * @return the fraction amount at the denomination level

	 * @return the denomination public name

	 * @return the denomination symbol

	 * @return the denomination num of decimals

	 * @return the denomination multiplier (power of ten)

	 */

	function toHighestDenomination(uint256 amount) public view returns (bytes8, address, uint256, uint256, string memory, string memory, uint8, uint256) {

		uint256 integerAmount;

		uint256 fractionAmount;

		uint256 index;

		for (uint256 i=totalDenominations; i>0; i--) {

			Denomination memory _denomination = denominations[i];

			(integerAmount, fractionAmount) = fromBase(amount, _denomination.name);

			if (integerAmount > 0) {

				index = i;

				break;

			}

		}

		require (index > 0 && index <= totalDenominations);

		require (integerAmount > 0 || fractionAmount > 0);

		require (denominations[index].denominationAddress != address(0));

		TAOCurrency _tc = TAOCurrency(denominations[index].denominationAddress);

		return (

			denominations[index].name,

			denominations[index].denominationAddress,

			integerAmount,

			fractionAmount,

			_tc.name(),

			_tc.symbol(),

			_tc.decimals(),

			_tc.powerOfTen()

		);

	}

}





/**

 * @title LogosTreasury

 *

 * The purpose of this contract is to list all of the valid denominations of Logos and do the conversion between denominations

 */

contract LogosTreasury is TAOCurrencyTreasury {

	/**

	 * @dev Constructor function

	 */

	constructor(address _nameFactoryAddress, address _nameTAOPositionAddress)

		TAOCurrencyTreasury(_nameFactoryAddress, _nameTAOPositionAddress) public {}

}