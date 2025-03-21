/**
 *  The Consumer Contract Wallet
 *  Copyright (C) 2018 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

pragma solidity ^0.4.25;

import "./oracle.sol";
import "./ownable.sol";
import "./controllable.sol";
import "./PublicResolver.sol";
import "./SafeMath.sol";
import "./Address.sol";

/// @title ERC20 interface is a subset of the ERC20 specification.
interface ERC20 {
    function transfer(address, uint) external returns (bool);
    function balanceOf(address) external view returns (uint);
}


/// @title ERC165 interface specifies a standard way of querying if a contract implements an interface.
interface ERC165 {
    function supportsInterface(bytes4) external view returns (bool);
}


/// @title Whitelist provides payee-whitelist functionality.
contract Whitelist is Controllable, Ownable {
    event AddedToWhitelist(address _sender, address[] _addresses);
    event SubmittedWhitelistAddition(address[] _addresses, bytes32 _hash);
    event CancelledWhitelistAddition(address _sender, bytes32 _hash);

    event RemovedFromWhitelist(address _sender, address[] _addresses);
    event SubmittedWhitelistRemoval(address[] _addresses, bytes32 _hash);
    event CancelledWhitelistRemoval(address _sender, bytes32 _hash);

    mapping(address => bool) public isWhitelisted;
    address[] private _pendingWhitelistAddition;
    address[] private _pendingWhitelistRemoval;
    bool public submittedWhitelistAddition;
    bool public submittedWhitelistRemoval;
    bool public initializedWhitelist;

    /// @dev Check if the provided addresses contain the owner or the zero-address address.
    modifier hasNoOwnerOrZeroAddress(address[] _addresses) {
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != owner(), "provided whitelist contains the owner address");
            require(_addresses[i] != address(0), "provided whitelist contains the zero address");
        }
        _;
    }

    /// @dev Check that neither addition nor removal operations have already been submitted.
    modifier noActiveSubmission() {
        require(!submittedWhitelistAddition && !submittedWhitelistRemoval, "whitelist operation has already been submitted");
        _;
    }

    /// @dev Getter for pending addition array.
    function pendingWhitelistAddition() external view returns(address[]) {
        return _pendingWhitelistAddition;
    }

    /// @dev Getter for pending removal array.
    function pendingWhitelistRemoval() external view returns(address[]) {
        return _pendingWhitelistRemoval;
    }

    /// @dev Getter for pending addition/removal array hash.
    function pendingWhitelistHash(address[] _pendingWhitelist) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_pendingWhitelist));
    }

    /// @dev Add initial addresses to the whitelist.
    /// @param _addresses are the Ethereum addresses to be whitelisted.
    function initializeWhitelist(address[] _addresses) external onlyOwner hasNoOwnerOrZeroAddress(_addresses) {
        // Require that the whitelist has not been initialized.
        require(!initializedWhitelist, "whitelist has already been initialized");
        // Add each of the provided addresses to the whitelist.
        for (uint i = 0; i < _addresses.length; i++) {
            isWhitelisted[_addresses[i]] = true;
        }
        initializedWhitelist = true;
        // Emit the addition event.
        emit AddedToWhitelist(msg.sender, _addresses);
    }

    /// @dev Add addresses to the whitelist.
    /// @param _addresses are the Ethereum addresses to be whitelisted.
    function submitWhitelistAddition(address[] _addresses) external onlyOwner noActiveSubmission hasNoOwnerOrZeroAddress(_addresses) {
        // Require that the whitelist has been initialized.
        require(initializedWhitelist, "whitelist has not been initialized");
        // Require this array of addresses not empty
        require(_addresses.length > 0, "pending whitelist addition is empty");
        // Set the provided addresses to the pending addition addresses.
        _pendingWhitelistAddition = _addresses;
        // Flag the operation as submitted.
        submittedWhitelistAddition = true;
        // Emit the submission event.
        emit SubmittedWhitelistAddition(_addresses, pendingWhitelistHash(_pendingWhitelistAddition));
    }

    /// @dev Confirm pending whitelist addition.
    function confirmWhitelistAddition(bytes32 _hash) external onlyController {
        // Require that the whitelist addition has been submitted.
        require(submittedWhitelistAddition, "whitelist addition has not been submitted");

        // Require that confirmation hash and the hash of the pending whitelist addition match
        require(_hash == pendingWhitelistHash(_pendingWhitelistAddition), "hash of the pending whitelist addition do not match");

        // Whitelist pending addresses.
        for (uint i = 0; i < _pendingWhitelistAddition.length; i++) {
            isWhitelisted[_pendingWhitelistAddition[i]] = true;
        }
        // Emit the addition event.
        emit AddedToWhitelist(msg.sender, _pendingWhitelistAddition);
        // Reset pending addresses.
        delete _pendingWhitelistAddition;
        // Reset the submission flag.
        submittedWhitelistAddition = false;
    }

    /// @dev Cancel pending whitelist addition.
    function cancelWhitelistAddition(bytes32 _hash) external onlyController {
        // Check if operation has been submitted.
        require(submittedWhitelistAddition, "whitelist addition has not been submitted");
        // Require that confirmation hash and the hash of the pending whitelist addition match
        require(_hash == pendingWhitelistHash(_pendingWhitelistAddition), "hash of the pending whitelist addition does not match");
        // Reset pending addresses.
        delete _pendingWhitelistAddition;
        // Reset the submitted operation flag.
        submittedWhitelistAddition = false;
        // Emit the cancellation event.
        emit CancelledWhitelistAddition(msg.sender, _hash);
    }

    /// @dev Remove addresses from the whitelist.
    /// @param _addresses are the Ethereum addresses to be removed.
    function submitWhitelistRemoval(address[] _addresses) external onlyOwner noActiveSubmission {
        // Require that the whitelist has been initialized.
        require(initializedWhitelist, "whitelist has not been initialized");
        // Require that the array of addresses is not empty
        require(_addresses.length > 0, "submitted whitelist removal is empty");
        // Add the provided addresses to the pending addition list.
        _pendingWhitelistRemoval = _addresses;
        // Flag the operation as submitted.
        submittedWhitelistRemoval = true;
        // Emit the submission event.
        emit SubmittedWhitelistRemoval(_addresses, pendingWhitelistHash(_pendingWhitelistRemoval));
    }

    /// @dev Confirm pending removal of whitelisted addresses.
    function confirmWhitelistRemoval(bytes32 _hash) external onlyController {
        // Require that the pending whitelist is not empty and the operation has been submitted.
        require(submittedWhitelistRemoval, "whitelist removal has not been submitted");
        // Require that confirmation hash and the hash of the pending whitelist removal match
        require(_hash == pendingWhitelistHash(_pendingWhitelistRemoval), "hash of the pending whitelist removal does not match the confirmed hash");
        // Remove pending addresses.
        for (uint i = 0; i < _pendingWhitelistRemoval.length; i++) {
            isWhitelisted[_pendingWhitelistRemoval[i]] = false;
        }
        // Emit the removal event.
        emit RemovedFromWhitelist(msg.sender, _pendingWhitelistRemoval);
        // Reset pending addresses.
        delete _pendingWhitelistRemoval;
        // Reset the submission flag.
        submittedWhitelistRemoval = false;
    }

    /// @dev Cancel pending removal of whitelisted addresses.
    function cancelWhitelistRemoval(bytes32 _hash) external onlyController {
        // Check if operation has been submitted.
        require(submittedWhitelistRemoval, "whitelist removal has not been submitted");
        // Require that confirmation hash and the hash of the pending whitelist removal match
        require(_hash == pendingWhitelistHash(_pendingWhitelistRemoval), "hash of the pending whitelist removal does not match");
        // Reset pending addresses.
        delete _pendingWhitelistRemoval;
        // Reset the submitted operation flag.
        submittedWhitelistRemoval = false;
        // Emit the cancellation event.
        emit CancelledWhitelistRemoval(msg.sender, _hash);
    }
}


//// @title SpendLimit provides daily spend limit functionality.
contract SpendLimit is Controllable, Ownable {
    event SetSpendLimit(address _sender, uint _amount);
    event SubmittedSpendLimitChange(uint _amount);
    event CancelledSpendLimitChange(address _sender, uint _amount);

    using SafeMath for uint256;

    uint public spendLimit;
    uint private _spendLimitDay;
    uint private _spendAvailable;

    uint public pendingSpendLimit;
    bool public submittedSpendLimit;
    bool public initializedSpendLimit;

    /// @dev Constructor initializes the daily spend limit in wei.
    constructor(uint _spendLimit) internal {
        spendLimit = _spendLimit;
        _spendLimitDay = now;
        _spendAvailable = spendLimit;
    }

    /// @dev Returns the available daily balance - accounts for daily limit reset.
    /// @return amount of ether in wei.
    function spendAvailable() public view returns (uint) {
        if (now > _spendLimitDay + 24 hours) {
            return spendLimit;
        } else {
            return _spendAvailable;
        }
    }

    /// @dev Initialize a daily spend (aka transfer) limit for non-whitelisted addresses.
    /// @param _amount is the daily limit amount in wei.
    function initializeSpendLimit(uint _amount) external onlyOwner {
        // Require that the spend limit has not been initialized.
        require(!initializedSpendLimit, "spend limit has already been initialized");
        // Modify spend limit based on the provided value.
        _modifySpendLimit(_amount);
        // Flag the operation as initialized.
        initializedSpendLimit = true;
        // Emit the set limit event.
        emit SetSpendLimit(msg.sender, _amount);
    }

    /// @dev Set a daily transfer limit for non-whitelisted addresses.
    /// @param _amount is the daily limit amount in wei.
    function submitSpendLimit(uint _amount) external onlyOwner {
        // Require that the spend limit has been initialized.
        require(initializedSpendLimit, "spend limit has not been initialized");
        // Assign the provided amount to pending daily limit change.
        pendingSpendLimit = _amount;
        // Flag the operation as submitted.
        submittedSpendLimit = true;
        // Emit the submission event.
        emit SubmittedSpendLimitChange(_amount);
    }

    /// @dev Confirm pending set daily limit operation.
    function confirmSpendLimit(uint _amount) external onlyController {
        // Require that the operation has been submitted.
        require(submittedSpendLimit, "spend limit has not been submitted");
        // Require that pending and confirmed spend limit are the same
        require(pendingSpendLimit == _amount, "confirmed and submitted spend limits dont match");
        // Modify spend limit based on the pending value.
        _modifySpendLimit(pendingSpendLimit);
        // Emit the set limit event.
        emit SetSpendLimit(msg.sender, pendingSpendLimit);
        // Reset the submission flag.
        submittedSpendLimit = false;
        // Reset pending daily limit.
        pendingSpendLimit = 0;
    }

    /// @dev Cancel pending set daily limit operation.
    function cancelSpendLimit(uint _amount) external onlyController {
        // Require a spendlimit has been submitted
        require(submittedSpendLimit, "a spendlimit needs to be submitted");
        // Require that pending and confirmed spend limit are the same
        require(pendingSpendLimit == _amount, "pending and cancelled spend limits dont match");
        // Reset pending daily limit.
        pendingSpendLimit = 0;
        // Reset the submitted operation flag.
        submittedSpendLimit = false;
        // Emit the cancellation event.
        emit CancelledSpendLimitChange(msg.sender, _amount);
    }

    // @dev Setter method for the available daily spend limit.
    function _setSpendAvailable(uint _amount) internal {
        _spendAvailable = _amount;
    }

    /// @dev Update available spend limit based on the daily reset.
    function _updateSpendAvailable() internal {
        if (now > _spendLimitDay.add(24 hours)) {
            // Advance the current day by how many days have passed.
            uint extraDays = now.sub(_spendLimitDay).div(24 hours);
            _spendLimitDay = _spendLimitDay.add(extraDays.mul(24 hours));
            // Set the available limit to the current spend limit.
            _spendAvailable = spendLimit;
        }
    }

    /// @dev Modify the spend limit and spend available based on the provided value.
    /// @dev _amount is the daily limit amount in wei.
    function _modifySpendLimit(uint _amount) private {
        // Account for the spend limit daily reset.
        _updateSpendAvailable();
        // Set the daily limit to the provided amount.
        spendLimit = _amount;
        // Lower the available limit if it's higher than the new daily limit.
        if (_spendAvailable > spendLimit) {
            _spendAvailable = spendLimit;
        }
    }
}


//// @title Asset store with extra security features.
contract Vault is Whitelist, SpendLimit, ERC165 {
    event Received(address _from, uint _amount);
    event Transferred(address _to, address _asset, uint _amount);
    event BulkTransferred(address _to, address[] _assets);

    using SafeMath for uint256;

    /// @dev Supported ERC165 interface ID.
    bytes4 private constant _ERC165_INTERFACE_ID = 0x01ffc9a7; // solium-disable-line uppercase

    /// @dev ENS points to the ENS registry smart contract.
    ENS internal _ENS;
    /// @dev Is the registered ENS name of the oracle contract.
    bytes32 internal _oracleNode;

    /// @dev Constructor initializes the vault with an owner address and spend limit. It also sets up the oracle and controller contracts.
    /// @param _owner is the owner account of the wallet contract.
    /// @param _transferable indicates whether the contract ownership can be transferred.
    /// @param _ens is the ENS public registry contract address.
    /// @param _oracleName is the ENS name of the Oracle.
    /// @param _controllerName is the ENS name of the controller.
    /// @param _spendLimit is the initial spend limit.
    constructor(address _owner, bool _transferable, address _ens, bytes32 _oracleName, bytes32 _controllerName, uint _spendLimit) SpendLimit(_spendLimit) Ownable(_owner, _transferable) Controllable(_ens, _controllerName) public {
        _ENS = ENS(_ens);
        _oracleNode = _oracleName;
    }

    /// @dev Checks if the value is not zero.
    modifier isNotZero(uint _value) {
        require(_value != 0, "provided value cannot be zero");
        _;
    }

    /// @dev Ether can be deposited from any source, so this contract must be payable by anyone.
    function() public payable {
        //TODO question: Why is this check here, is it necessary or are we building into a corner?
        require(msg.data.length == 0, "data in fallback");
        emit Received(msg.sender, msg.value);
    }

    /// @dev Returns the amount of an asset owned by the contract.
    /// @param _asset address of an ERC20 token or 0x0 for ether.
    /// @return balance associated with the wallet address in wei.
    function balance(address _asset) external view returns (uint) {
        if (_asset != address(0)) {
            return ERC20(_asset).balanceOf(this);
        } else {
            return address(this).balance;
        }
    }

    /// @dev This is a bulk transfer convenience function, used to migrate contracts.
    /// If any of the transfers fail, this will revert.
    /// @param _to is the recipient's address, can't be the zero (0x0) address: transfer() will revert.
    /// @param _assets is an array of addresses of ERC20 tokens or 0x0 for ether.
    function bulkTransfer(address _to, address[] _assets) public onlyOwner {
        // check to make sure that _assets isn't empty
        require(_assets.length != 0, "asset array should be non-empty");
        // This loops through all of the transfers to be made
        for (uint i = 0; i < _assets.length; i++) {
            uint amount;
            // Get amount based on whether eth or erc20
            if (_assets[i] == address(0)) {
                amount = address(this).balance;
            } else {
                amount = ERC20(_assets[i]).balanceOf(address(this));
            }
            // use our safe, daily limit protected transfer
            transfer(_to, _assets[i], amount);
        }
        emit BulkTransferred(_to, _assets);
    }

    /// @dev Transfers the specified asset to the recipient's address.
    /// @param _to is the recipient's address.
    /// @param _asset is the address of an ERC20 token or 0x0 for ether.
    /// @param _amount is the amount of tokens to be transferred in base units.
    function transfer(address _to, address _asset, uint _amount) public onlyOwner isNotZero(_amount) {
        // Checks if the _to address is not the zero-address
        require(_to != address(0), "_to address cannot be set to 0x0");

        // If address is not whitelisted, take daily limit into account.
        if (!isWhitelisted[_to]) {
            // Update the available spend limit.
            _updateSpendAvailable();
            // Convert token amount to ether value.
            uint etherValue;
            bool tokenExists;
            if (_asset != address(0)) {
                (tokenExists, etherValue) = IOracle(PublicResolver(_ENS.resolver(_oracleNode)).addr(_oracleNode)).convert(_asset, _amount);
            } else {
                etherValue = _amount;
            }

            // If token is supported by our oracle or is ether
            // Check against the daily spent limit and update accordingly
            if (tokenExists || _asset == address(0)) {
                // Require that the value is under remaining limit.
                require(etherValue <= spendAvailable(), "transfer amount exceeds available spend limit");
                // Update the available limit.
                _setSpendAvailable(spendAvailable().sub(etherValue));
            }
        }
        // Transfer token or ether based on the provided address.
        if (_asset != address(0)) {
            require(ERC20(_asset).transfer(_to, _amount), "ERC20 token transfer was unsuccessful");
        } else {
            _to.transfer(_amount);
        }
        // Emit the transfer event.
        emit Transferred(_to, _asset, _amount);
    }

    /// @dev Checks for interface support based on ERC165.
    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return interfaceID == _ERC165_INTERFACE_ID;
    }
}


//// @title Asset wallet with extra security features and gas top up management.
contract Wallet is Vault {

    using Address for address;

    event SetTopUpLimit(address _sender, uint _amount);
    event SubmittedTopUpLimitChange(uint _amount);
    event CancelledTopUpLimitChange(address _sender, uint _amount);

    event ToppedUpGas(address _sender, address _owner, uint _amount);

    event ExecutedTransaction(address _destination, uint _value, bytes _data);

    using SafeMath for uint256;

    uint constant private MINIMUM_TOPUP_LIMIT = 1 finney; // solium-disable-line uppercase
    uint constant private MAXIMUM_TOPUP_LIMIT = 500 finney; // solium-disable-line uppercase

    /// @dev these are needed to allow for the executeTransaction method
    uint32 private constant _TRANSFER= 0xa9059cbb;
    uint32 private constant _APPROVE = 0x095ea7b3;

    uint public topUpLimit;
    uint private _topUpLimitDay;
    uint private _topUpAvailable;

    uint public pendingTopUpLimit;
    bool public submittedTopUpLimit;
    bool public initializedTopUpLimit;

    /// @dev Constructor initializes the wallet top up limit and the vault contract.
    /// @param _owner is the owner account of the wallet contract.
    /// @param _transferable indicates whether the contract ownership can be transferred.
    /// @param _ens is the address of the ENS.
    /// @param _oracleName is the ENS name of the Oracle.
    /// @param _controllerName is the ENS name of the Controller.
    /// @param _spendLimit is the initial spend limit.
    constructor(address _owner, bool _transferable, address _ens, bytes32 _oracleName, bytes32 _controllerName, uint _spendLimit) Vault(_owner, _transferable, _ens, _oracleName, _controllerName, _spendLimit) public {
        _topUpLimitDay = now;
        topUpLimit = MAXIMUM_TOPUP_LIMIT;
        _topUpAvailable = topUpLimit;
    }

    /// @dev Returns the available daily gas top up balance - accounts for daily limit reset.
    /// @return amount of gas in wei.
    function topUpAvailable() external view returns (uint) {
        if (now > _topUpLimitDay + 24 hours) {
            return topUpLimit;
        } else {
            return _topUpAvailable;
        }
    }

    /// @dev Initialize a daily gas top up limit.
    /// @param _amount is the gas top up amount in wei.
    function initializeTopUpLimit(uint _amount) external onlyOwner {
        // Require that the top up limit has not been initialized.
        require(!initializedTopUpLimit, "top up limit has already been initialized");
        // Require that the limit amount is within the acceptable range.
        require(MINIMUM_TOPUP_LIMIT <= _amount && _amount <= MAXIMUM_TOPUP_LIMIT, "top up amount is outside of the min/max range");
        // Modify spend limit based on the provided value.
        _modifyTopUpLimit(_amount);
        // Flag operation as initialized.
        initializedTopUpLimit = true;
        // Emit the set limit event.
        emit SetTopUpLimit(msg.sender, _amount);
    }

    /// @dev Set a daily top up top up limit.
    /// @param _amount is the daily top up limit amount in wei.
    function submitTopUpLimit(uint _amount) external onlyOwner {
        // Require that the top up limit has been initialized.
        require(initializedTopUpLimit, "top up limit has not been initialized");
        // Require that the limit amount is within the acceptable range.
        require(MINIMUM_TOPUP_LIMIT <= _amount && _amount <= MAXIMUM_TOPUP_LIMIT, "top up amount is outside of the min/max range");
        // Assign the provided amount to pending daily limit change.
        pendingTopUpLimit = _amount;
        // Flag the operation as submitted.
        submittedTopUpLimit = true;
        // Emit the submission event.
        emit SubmittedTopUpLimitChange(_amount);
    }

    /// @dev Confirm pending set top up limit operation.
    function confirmTopUpLimit(uint _amount) external onlyController {
        // Require that the operation has been submitted.
        require(submittedTopUpLimit, "top up limit has not been submitted");
        // Assert that the pending top up limit amount is within the acceptable range.
        require(MINIMUM_TOPUP_LIMIT <= pendingTopUpLimit && pendingTopUpLimit <= MAXIMUM_TOPUP_LIMIT, "top up amount is outside the min/max range");
        // Assert that confirmed and pending topup limit are the same.
        require(_amount == pendingTopUpLimit, "confirmed and pending topup limit are not same");
        // Modify top up limit based on the pending value.
        _modifyTopUpLimit(pendingTopUpLimit);
        // Emit the set limit event.
        emit SetTopUpLimit(msg.sender, pendingTopUpLimit);
        // Reset pending daily limit.
        pendingTopUpLimit = 0;
        // Reset the submission flag.
        submittedTopUpLimit = false;
    }

    /// @dev Cancel pending set top up limit operation.
    function cancelTopUpLimit(uint _amount) external onlyController {
        // Make sure a topup limit update has been submitted
        require(submittedTopUpLimit, "a topup limit has to be submitted");
        // Require that pending and confirmed spend limit are the same
        require(pendingTopUpLimit == _amount, "pending and cancelled top up limits dont match");
        // Reset pending daily limit.
        pendingTopUpLimit = 0;
        // Reset the submitted operation flag.
        submittedTopUpLimit = false;
        // Emit the cancellation event.
        emit CancelledTopUpLimitChange(msg.sender, _amount);
    }

    /// @dev Refill owner's gas balance.
    /// @dev Revert if the transaction amount is too large
    /// @param _amount is the amount of ether to transfer to the owner account in wei.
    function topUpGas(uint _amount) external isNotZero(_amount) {
        // Require that the sender is either the owner or a controller.
        require(_isOwner() || _isController(msg.sender), "sender is neither an owner nor a controller");
        // Account for the top up limit daily reset.
        _updateTopUpAvailable();
        // Make sure the available top up amount is not zero.
        require(_topUpAvailable != 0, "available top up limit cannot be zero");
        // Fail if there isn't enough in the daily top up limit to perform topUp
        require(_amount <= _topUpAvailable, "available top up limit less than amount passed in");
        // Reduce the top up amount from available balance and transfer corresponding
        // ether to the owner's account.
        _topUpAvailable = _topUpAvailable.sub(_amount);
        owner().transfer(_amount);
        // Emit the gas top up event.
        emit ToppedUpGas(tx.origin, owner(), _amount);
    }

    /// @dev Modify the top up limit and top up available based on the provided value.
    /// @dev _amount is the daily limit amount in wei.
    function _modifyTopUpLimit(uint _amount) private {
        // Account for the top up limit daily reset.
        _updateTopUpAvailable();
        // Set the daily limit to the provided amount.
        topUpLimit = _amount;
        // Lower the available limit if it's higher than the new daily limit.
        if (_topUpAvailable > topUpLimit) {
            _topUpAvailable = topUpLimit;
        }
    }

    /// @dev Update available top up limit based on the daily reset.
    function _updateTopUpAvailable() private {
        if (now > _topUpLimitDay.add(24 hours)) {
            // Advance the current day by how many days have passed.
            uint extraDays = now.sub(_topUpLimitDay).div(24 hours);
            _topUpLimitDay = _topUpLimitDay.add(extraDays.mul(24 hours));
            // Set the available limit to the current top up limit.
            _topUpAvailable = topUpLimit;
        }
    }

    /// @dev This function allows for the owner to send transaction from the Wallet to arbitrary contracts
    /// @dev This function does not allow for the sending of data to arbitrary (non-contract) addresses
    /// @param _destination address of the transaction
    /// @param _value ETH amount in wei
    /// @param _data transaction payload binary
    function executeTransaction(address _destination, uint _value, bytes _data, bool _destinationIsContract) external onlyOwner {

        // Check if the Address is a Contract
        // This should avoid users accidentally sending Value and Data to a plain old address
        if (_destinationIsContract) {
            require(address(_destination).isContract(), "executeTransaction for a contract: call to non-contract");
        } else {
            require(!address(_destination).isContract(), "executeTransaction for a non-contract: call to contract");
        }

        // Check if there exists at least a method signature in the transaction payload
        if (_data.length >= 4) {
            // Get method signature
            uint32 signature = bytesToUint32(_data, 0);

            // Check if method is either ERC20 transfer or approve
            if (signature == _TRANSFER || signature == _APPROVE) {
                require(_data.length >= 4 + 32 + 32, "invalid transfer / approve transaction data");
                uint amount = sliceUint(_data, 4 + 32);
                // The "toOrSpender" is the '_to' address for a ERC20 transfer or the '_spender; in ERC20 approve
                // + 12 because address 20 bytes and this is padded to 32
                address toOrSpender = bytesToAddress(_data, 4 + 12);

                // Check if the toOrSpender is in the whitelist
                if (!isWhitelisted[toOrSpender]) {
                    (bool tokenExists,uint etherValue) = IOracle(PublicResolver(_ENS.resolver(_oracleNode)).addr(_oracleNode)).convert(_destination, amount);
                    // If token is supported by our oracle or is ether
                    // Check against the daily spent limit and update accordingly
                    if (tokenExists) {
                        // Require that the value is under remaining limit.
                        require(etherValue <= spendAvailable(), "transfer amount exceeds available spend limit");
                        // Update the available limit.
                        _setSpendAvailable(spendAvailable().sub(etherValue));
                    }
                }
            }
        }

        // If value is send across as a part of this executeTransaction, this will be sent to any payable
        // destination. As a result enforceLimit if destination is not whitelisted.
        if (!isWhitelisted[_destination]) {
            // Require that the value is under remaining limit.
            require(_value <= spendAvailable(), "transfer amount exceeds available spend limit");
            // Update the available limit.
            _setSpendAvailable(spendAvailable().sub(_value));
        }

        require(externalCall(_destination, _value, _data.length, _data), "executing transaction failed");

        emit ExecutedTransaction(_destination, _value, _data);
    }

    /// @dev This function is taken from the Gnosis MultisigWallet: https://github.com/gnosis/MultiSigWallet/
    /// @dev License: https://github.com/gnosis/MultiSigWallet/blob/master/LICENSE
    /// @dev thanks :)
    /// @dev This calls proxies arbitrary transactions to addresses
    /// @param _destination address of the transaction
    /// @param _value ETH amount in wei
    /// @param _dataLength length of the transaction data
    /// @param _data transaction payload binary
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function externalCall(address _destination, uint _value, uint _dataLength, bytes _data) private returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(_data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),    // 34710 is the value that solidity is currently emitting
                                    // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                    // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
               _destination,
               _value,
               d,
               _dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
               x,
               0                   // Output is ignored, therefore the output size is zero
               )
        }
        return result;
    }

    /// @dev This function converts to an address
    /// @param _bts bytes
    /// @param _from start position
    function bytesToAddress(bytes _bts, uint _from) private pure returns (address) {
        require(_bts.length >= _from + 20, "slicing out of range");

        uint160 m = 0;
        uint160 b = 0;

        for (uint8 i = 0; i < 20; i++) {
            m *= 256;
            b = uint160 (_bts[_from + i]);
            m += (b);
        }

        return address(m);
    }

    /// @dev This function slicing bytes into uint32
    /// @param _bts some bytes
    /// @param _from  a start position
    function bytesToUint32(bytes _bts, uint _from) private pure returns (uint32) {
        require(_bts.length >= _from + 4, "slicing out of range");

        uint32 m = 0;
        uint32 b = 0;

        for (uint8 i = 0; i < 4; i++) {
            m *= 256;
            b = uint32 (_bts[_from + i]);
            m += (b);
        }

        return m;
    }

    /// @dev This function slices a uint
    /// @param _bts some bytes
    /// @param _from  a start position
    // credit to https://ethereum.stackexchange.com/questions/51229/how-to-convert-bytes-to-uint-in-solidity
    // and Nick Johnson https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity/4177#4177
    function sliceUint(bytes _bts, uint _from) private pure returns (uint) {
        require(_bts.length >= _from + 32, "slicing out of range");

        uint x;
        assembly {
           x := mload(add(_bts, add(0x20, _from)))
        }

        return x;
    }
}