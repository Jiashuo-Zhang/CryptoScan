/**

 *Submitted for verification at Etherscan.io on 2020-02-25

*/



pragma solidity ^0.5.4;



library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;

    uint8 constant STRING_LONG_START  = 0xb8;

    uint8 constant LIST_SHORT_START   = 0xc0;

    uint8 constant LIST_LONG_START    = 0xf8;

    uint8 constant WORD_SIZE = 32;



    struct RLPItem {

        uint len;

        uint memPtr;

    }



    struct Iterator {

        RLPItem item;   // Item that's being iterated over.

        uint nextPtr;   // Position of the next item in the list.

    }



    /*

    * @dev Returns the next element in the iteration. Reverts if it has not next element.

    * @param self The iterator.

    * @return The next element in the iteration.

    */

    function next(Iterator memory self) internal pure returns (RLPItem memory) {

        require(hasNext(self));



        uint ptr = self.nextPtr;

        uint itemLength = _itemLength(ptr);

        self.nextPtr = ptr + itemLength;



        return RLPItem(itemLength, ptr);

    }



    /*

    * @dev Returns true if the iteration has more elements.

    * @param self The iterator.

    * @return true if the iteration has more elements.

    */

    function hasNext(Iterator memory self) internal pure returns (bool) {

        RLPItem memory item = self.item;

        return self.nextPtr < item.memPtr + item.len;

    }



    /*

    * @param item RLP encoded bytes

    */

    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {

        uint memPtr;

        assembly {

            memPtr := add(item, 0x20)

        }



        return RLPItem(item.length, memPtr);

    }



    /*

    * @dev Create an iterator. Reverts if item is not a list.

    * @param self The RLP item.

    * @return An 'Iterator' over the item.

    */

    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {

        require(isList(self));



        uint ptr = self.memPtr + _payloadOffset(self.memPtr);

        return Iterator(self, ptr);

    }



    /*

    * @param item RLP encoded bytes

    */

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;

    }



    /*

    * @param item RLP encoded bytes

    */

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        return item.len - _payloadOffset(item.memPtr);

    }



    /*

    * @param item RLP encoded list in bytes

    */

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {

        require(isList(item));



        uint items = numItems(item);

        RLPItem[] memory result = new RLPItem[](items);



        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);

        uint dataLen;

        for (uint i = 0; i < items; i++) {

            dataLen = _itemLength(memPtr);

            result[i] = RLPItem(dataLen, memPtr); 

            memPtr = memPtr + dataLen;

        }



        return result;

    }



    // @return indicator whether encoded payload is a list. negate this function call for isData.

    function isList(RLPItem memory item) internal pure returns (bool) {

        if (item.len == 0) return false;



        uint8 byte0;

        uint memPtr = item.memPtr;

        assembly {

            byte0 := byte(0, mload(memPtr))

        }



        if (byte0 < LIST_SHORT_START)

            return false;

        return true;

    }



    /** RLPItem conversions into data types **/



    // @returns raw rlp encoding in bytes

    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {

        bytes memory result = new bytes(item.len);

        if (result.length == 0) return result;

        

        uint ptr;

        assembly {

            ptr := add(0x20, result)

        }



        copy(item.memPtr, ptr, item.len);

        return result;

    }



    // any non-zero byte is considered true

    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(item.len == 1);

        uint result;

        uint memPtr = item.memPtr;

        assembly {

            result := byte(0, mload(memPtr))

        }



        return result == 0 ? false : true;

    }



    function toAddress(RLPItem memory item) internal pure returns (address) {

        // 1 byte for the length prefix

        require(item.len == 21);



        return address(toUint(item));

    }



    function toUint(RLPItem memory item) internal pure returns (uint) {

        require(item.len > 0 && item.len <= 33);



        uint offset = _payloadOffset(item.memPtr);

        uint len = item.len - offset;



        uint result;

        uint memPtr = item.memPtr + offset;

        assembly {

            result := mload(memPtr)



            // shfit to the correct location if neccesary

            if lt(len, 32) {

                result := div(result, exp(256, sub(32, len)))

            }

        }



        return result;

    }



    // enforces 32 byte length

    function toUintStrict(RLPItem memory item) internal pure returns (uint) {

        // one byte prefix

        require(item.len == 33);



        uint result;

        uint memPtr = item.memPtr + 1;

        assembly {

            result := mload(memPtr)

        }



        return result;

    }



    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0);



        uint offset = _payloadOffset(item.memPtr);

        uint len = item.len - offset; // data length

        bytes memory result = new bytes(len);



        uint destPtr;

        assembly {

            destPtr := add(0x20, result)

        }



        copy(item.memPtr + offset, destPtr, len);

        return result;

    }



    /*

    * Private Helpers

    */



    // @return number of payload items inside an encoded list.

    function numItems(RLPItem memory item) private pure returns (uint) {

        if (item.len == 0) return 0;



        uint count = 0;

        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);

        uint endPtr = item.memPtr + item.len;

        while (currPtr < endPtr) {

           currPtr = currPtr + _itemLength(currPtr); // skip over an item

           count++;

        }



        return count;

    }



    // @return entire rlp item byte length

    function _itemLength(uint memPtr) private pure returns (uint) {

        uint itemLen;

        uint byte0;

        assembly {

            byte0 := byte(0, mload(memPtr))

        }



        if (byte0 < STRING_SHORT_START)

            itemLen = 1;

        

        else if (byte0 < STRING_LONG_START)

            itemLen = byte0 - STRING_SHORT_START + 1;



        else if (byte0 < LIST_SHORT_START) {

            assembly {

                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is

                memPtr := add(memPtr, 1) // skip over the first byte

                

                /* 32 byte word size */

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len

                itemLen := add(dataLen, add(byteLen, 1))

            }

        }



        else if (byte0 < LIST_LONG_START) {

            itemLen = byte0 - LIST_SHORT_START + 1;

        } 



        else {

            assembly {

                let byteLen := sub(byte0, 0xf7)

                memPtr := add(memPtr, 1)



                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length

                itemLen := add(dataLen, add(byteLen, 1))

            }

        }



        return itemLen;

    }



    // @return number of bytes until the data

    function _payloadOffset(uint memPtr) private pure returns (uint) {

        uint byte0;

        assembly {

            byte0 := byte(0, mload(memPtr))

        }



        if (byte0 < STRING_SHORT_START) 

            return 0;

        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))

            return 1;

        else if (byte0 < LIST_SHORT_START)  // being explicit

            return byte0 - (STRING_LONG_START - 1) + 1;

        else

            return byte0 - (LIST_LONG_START - 1) + 1;

    }



    /*

    * @param src Pointer to source

    * @param dest Pointer to destination

    * @param len Amount of memory to copy from the source

    */

    function copy(uint src, uint dest, uint len) private pure {

        if (len == 0) return;



        // copy as many word sizes as possible

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {

            assembly {

                mstore(dest, mload(src))

            }



            src += WORD_SIZE;

            dest += WORD_SIZE;

        }



        // left over bytes. Mask is used to remove unwanted bytes from the word

        uint mask = 256 ** (WORD_SIZE - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask)) // zero out src

            let destpart := and(mload(dest), mask) // retrieve the bytes

            mstore(dest, or(destpart, srcpart))

        }

    }

}



contract Account {



    // The implementation of the proxy

    address public implementation;



    // Logic manager

    address public manager;

    

    // The enabled static calls

    mapping (bytes4 => address) public enabled;



    event EnabledStaticCall(address indexed module, bytes4 indexed method);

    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);

    event Received(uint indexed value, address indexed sender, bytes data);



    event AccountInit(address indexed account);

    event ManagerChanged(address indexed mgr);



    modifier allowAuthorizedLogicContractsCallsOnly {

        require(LogicManager(manager).isAuthorized(msg.sender), "not an authorized logic");

        _;

    }



    function init(address _manager, address _accountStorage, address[] calldata _logics, address[] calldata _keys, address[] calldata _backups)

        external

    {

        require(manager == address(0), "Account: account already initialized");

        require(_manager != address(0) && _accountStorage != address(0), "Account: address is null");

        manager = _manager;



        for (uint i = 0; i < _logics.length; i++) {

            address logic = _logics[i];

            require(LogicManager(manager).isAuthorized(logic), "must be authorized logic");



            BaseLogic(logic).initAccount(this);

        }



        AccountStorage(_accountStorage).initAccount(this, _keys, _backups);



        emit AccountInit(address(this));

    }



    function invoke(address _target, uint _value, bytes calldata _data)

        external

        allowAuthorizedLogicContractsCallsOnly

        returns (bytes memory _res)

    {

        bool success;

        // solium-disable-next-line security/no-call-value

        (success, _res) = _target.call.value(_value)(_data);

        require(success, "call to target failed");

        emit Invoked(msg.sender, _target, _value, _data);

    }



    /**

    * @dev Enables a static method by specifying the target module to which the call must be delegated.

    * @param _module The target module.

    * @param _method The static method signature.

    */

    function enableStaticCall(address _module, bytes4 _method) external allowAuthorizedLogicContractsCallsOnly {

        enabled[_method] = _module;

        emit EnabledStaticCall(_module, _method);

    }



    function changeManager(address _newMgr) external allowAuthorizedLogicContractsCallsOnly {

        require(_newMgr != address(0), "address cannot be null");

        require(_newMgr != manager, "already changed");

        manager = _newMgr;

        emit ManagerChanged(_newMgr);

    }



     /**

     * @dev This method makes it possible for the wallet to comply to interfaces expecting the wallet to

     * implement specific static methods. It delegates the static call to a target contract if the data corresponds

     * to an enabled method, or logs the call otherwise.

     */

    function() external payable {

        if(msg.data.length > 0) {

            address logic = enabled[msg.sig];

            if(logic == address(0)) {

                emit Received(msg.value, msg.sender, msg.data);

            }

            else {

                require(LogicManager(manager).isAuthorized(logic), "must be an authorized logic for static call");

                // solium-disable-next-line security/no-inline-assembly

                assembly {

                    calldatacopy(0, 0, calldatasize())

                    let result := staticcall(gas, logic, 0, calldatasize(), 0, 0)

                    returndatacopy(0, 0, returndatasize())

                    switch result

                    case 0 {revert(0, returndatasize())}

                    default {return (0, returndatasize())}

                }

            }

        }

    }

}



contract Owned {



    // The owner

    address public owner;



    event OwnerChanged(address indexed _newOwner);



    /**

     * @dev Throws if the sender is not the owner.

     */

    modifier onlyOwner {

        require(msg.sender == owner, "Must be owner");

        _;

    }



    constructor() public {

        owner = msg.sender;

    }



    /**

     * @dev Lets the owner transfer ownership of the contract to a new owner.

     * @param _newOwner The new owner.

     */

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Address must not be null");

        owner = _newOwner;

        emit OwnerChanged(_newOwner);

    }

}



contract LogicManager is Owned {



    event UpdateLogicSubmitted(address indexed logic, bool value);

    event UpdateLogicCancelled(address indexed logic);

    event UpdateLogicDone(address indexed logic, bool value);



    struct pending {

        bool value;

        uint dueTime;

    }



    // The authorized logic modules

    mapping (address => bool) public authorized;



    /*

    array

    index 0: AccountLogic address

          1: TransferLogic address

          2: DualsigsLogic address

          3: DappLogic address

          4: ...

     */

    address[] public authorizedLogics;



    // updated logics and their due time of becoming effective

    mapping (address => pending) public pendingLogics;



    // pending time before updated logics take effect

    struct pendingTime {

        uint curPendingTime;

        uint nextPendingTime;

        uint dueTime;

    }



    pendingTime public pt;



    // how many authorized logics

    uint public logicCount;



    constructor(address[] memory _initialLogics, uint256 _pendingTime) public

    {

        for (uint i = 0; i < _initialLogics.length; i++) {

            address logic = _initialLogics[i];

            authorized[logic] = true;

            logicCount += 1;

        }

        authorizedLogics = _initialLogics;



        pt.curPendingTime = _pendingTime;

        pt.nextPendingTime = _pendingTime;

        pt.dueTime = now;

    }



    function submitUpdatePendingTime(uint _pendingTime) external onlyOwner {

        pt.nextPendingTime = _pendingTime;

        pt.dueTime = pt.curPendingTime + now;

    }



    function triggerUpdatePendingTime() external {

        require(pt.dueTime <= now, "too early to trigger updatePendingTime");

        pt.curPendingTime = pt.nextPendingTime;

    }



    function isAuthorized(address _logic) external view returns (bool) {

        return authorized[_logic];

    }



    function getAuthorizedLogics() external view returns (address[] memory) {

        return authorizedLogics;

    }



    function submitUpdate(address _logic, bool _value) external onlyOwner {

        pending storage p = pendingLogics[_logic];

        p.value = _value;

        p.dueTime = now + pt.curPendingTime;

        emit UpdateLogicSubmitted(_logic, _value);

    }



    function cancelUpdate(address _logic) external onlyOwner {

        delete pendingLogics[_logic];

        emit UpdateLogicCancelled(_logic);

    }



    function triggerUpdateLogic(address _logic) external {

        pending memory p = pendingLogics[_logic];

        require(p.dueTime > 0, "pending logic not found");

        require(p.dueTime <= now, "too early to trigger updateLogic");

        updateLogic(_logic, p.value);

        delete pendingLogics[_logic];

    }



    function updateLogic(address _logic, bool _value) internal {

        if (authorized[_logic] != _value) {

            if(_value) {

                logicCount += 1;

                authorized[_logic] = true;

                authorizedLogics.push(_logic);

            }

            else {

                logicCount -= 1;

                require(logicCount > 0, "must have at least one logic module");

                delete authorized[_logic];

                removeLogic(_logic);

            }

            emit UpdateLogicDone(_logic, _value);

        }

    }



    function removeLogic(address _logic) internal {

        uint len = authorizedLogics.length;

        address lastLogic = authorizedLogics[len - 1];

        if (_logic != lastLogic) {

            for (uint i = 0; i < len; i++) {

                 if (_logic == authorizedLogics[i]) {

                     authorizedLogics[i] = lastLogic;

                     break;

                 }

            }

        }

        authorizedLogics.length--;

    }

}



contract AccountStorage {



    modifier allowAccountCallsOnly(Account _account) {

        require(msg.sender == address(_account), "caller must be account");

        _;

    }



    modifier allowAuthorizedLogicContractsCallsOnly(address payable _account) {

        require(LogicManager(Account(_account).manager()).isAuthorized(msg.sender), "not an authorized logic");

        _;

    }



    struct KeyItem {

        address pubKey;

        uint256 status;

    }



    struct BackupAccount {

        address backup;

        uint256 effectiveDate;//means not effective until this timestamp

        uint256 expiryDate;//means effective until this timestamp

    }



    struct DelayItem {

        bytes32 hash;

        uint256 dueTime;

    }



    struct Proposal {

        bytes32 hash;

        address[] approval;

    }



    // account => quantity of operation keys (index >= 1)

    mapping (address => uint256) operationKeyCount;



    // account => index => KeyItem

    mapping (address => mapping(uint256 => KeyItem)) keyData;



    // account => index => backup account

    mapping (address => mapping(uint256 => BackupAccount)) backupData;



    /* account => actionId => DelayItem



       delayData applies to these 4 actions:

       changeAdminKey, changeAllOperationKeys, unfreeze, changeAdminKeyByBackup

    */

    mapping (address => mapping(bytes4 => DelayItem)) delayData;



    // client account => proposer account => proposed actionId => Proposal

    mapping (address => mapping(address => mapping(bytes4 => Proposal))) proposalData;



    // *************** keyCount ********************** //



    function getOperationKeyCount(address _account) external view returns(uint256) {

        return operationKeyCount[_account];

    }



    function increaseKeyCount(address payable _account) external allowAuthorizedLogicContractsCallsOnly(_account) {

        operationKeyCount[_account] = operationKeyCount[_account] + 1;

    }



    // *************** keyData ********************** //



    function getKeyData(address _account, uint256 _index) public view returns(address) {

        KeyItem memory item = keyData[_account][_index];

        return item.pubKey;

    }



    function setKeyData(address payable _account, uint256 _index, address _key) external allowAuthorizedLogicContractsCallsOnly(_account) {

        require(_key != address(0), "invalid _key value");

        KeyItem storage item = keyData[_account][_index];

        item.pubKey = _key;

    }



    // *************** keyStatus ********************** //



    function getKeyStatus(address _account, uint256 _index) external view returns(uint256) {

        KeyItem memory item = keyData[_account][_index];

        return item.status;

    }



    function setKeyStatus(address payable _account, uint256 _index, uint256 _status) external allowAuthorizedLogicContractsCallsOnly(_account) {

        KeyItem storage item = keyData[_account][_index];

        item.status = _status;

    }



    // *************** backupData ********************** //



    function getBackupAddress(address _account, uint256 _index) external view returns(address) {

        BackupAccount memory b = backupData[_account][_index];

        return b.backup;

    }



    function getBackupEffectiveDate(address _account, uint256 _index) external view returns(uint256) {

        BackupAccount memory b = backupData[_account][_index];

        return b.effectiveDate;

    }



    function getBackupExpiryDate(address _account, uint256 _index) external view returns(uint256) {

        BackupAccount memory b = backupData[_account][_index];

        return b.expiryDate;

    }



    function setBackup(address payable _account, uint256 _index, address _backup, uint256 _effective, uint256 _expiry)

        external

        allowAuthorizedLogicContractsCallsOnly(_account)

    {

        BackupAccount storage b = backupData[_account][_index];

        b.backup = _backup;

        b.effectiveDate = _effective;

        b.expiryDate = _expiry;

    }



    function setBackupExpiryDate(address payable _account, uint256 _index, uint256 _expiry)

        external

        allowAuthorizedLogicContractsCallsOnly(_account)

    {

        BackupAccount storage b = backupData[_account][_index];

        b.expiryDate = _expiry;

    }



    function clearBackupData(address payable _account, uint256 _index) external allowAuthorizedLogicContractsCallsOnly(_account) {

        delete backupData[_account][_index];

    }



    // *************** delayData ********************** //



    function getDelayDataHash(address payable _account, bytes4 _actionId) external view returns(bytes32) {

        DelayItem memory item = delayData[_account][_actionId];

        return item.hash;

    }



    function getDelayDataDueTime(address payable _account, bytes4 _actionId) external view returns(uint256) {

        DelayItem memory item = delayData[_account][_actionId];

        return item.dueTime;

    }



    function setDelayData(address payable _account, bytes4 _actionId, bytes32 _hash, uint256 _dueTime) external allowAuthorizedLogicContractsCallsOnly(_account) {

        DelayItem storage item = delayData[_account][_actionId];

        item.hash = _hash;

        item.dueTime = _dueTime;

    }



    function clearDelayData(address payable _account, bytes4 _actionId) external allowAuthorizedLogicContractsCallsOnly(_account) {

        delete delayData[_account][_actionId];

    }



    // *************** proposalData ********************** //



    function getProposalDataHash(address _client, address _proposer, bytes4 _actionId) external view returns(bytes32) {

        Proposal memory p = proposalData[_client][_proposer][_actionId];

        return p.hash;

    }



    function getProposalDataApproval(address _client, address _proposer, bytes4 _actionId) external view returns(address[] memory) {

        Proposal memory p = proposalData[_client][_proposer][_actionId];

        return p.approval;

    }



    function setProposalData(address payable _client, address _proposer, bytes4 _actionId, bytes32 _hash, address _approvedBackup)

        external

        allowAuthorizedLogicContractsCallsOnly(_client)

    {

        Proposal storage p = proposalData[_client][_proposer][_actionId];

        if (p.hash > 0) {

            if (p.hash == _hash) {

                for (uint256 i = 0; i < p.approval.length; i++) {

                    require(p.approval[i] != _approvedBackup, "backup already exists");

                }

                p.approval.push(_approvedBackup);

            } else {

                p.hash = _hash;

                p.approval.length = 0;

            }

        } else {

            p.hash = _hash;

            p.approval.push(_approvedBackup);

        }

    }



    function clearProposalData(address payable _client, address _proposer, bytes4 _actionId) external allowAuthorizedLogicContractsCallsOnly(_client) {

        delete proposalData[_client][_proposer][_actionId];

    }





    // *************** init ********************** //

    function initAccount(Account _account, address[] calldata _keys, address[] calldata _backups)

        external

        allowAccountCallsOnly(_account)

    {

        require(getKeyData(address(_account), 0) == address(0), "AccountStorage: account already initialized!");

        require(_keys.length > 0, "empty keys array");



        operationKeyCount[address(_account)] = _keys.length - 1;



        for (uint256 index = 0; index < _keys.length; index++) {

            address _key = _keys[index];

            require(_key != address(0), "_key cannot be 0x0");

            KeyItem storage item = keyData[address(_account)][index];

            item.pubKey = _key;

            item.status = 0;

        }



        // avoid backup duplication if _backups.length > 1

        // normally won't check duplication, in most cases only one initial backup when initialization

        if (_backups.length > 1) {

            address[] memory bkps = _backups;

            for (uint256 i = 0; i < _backups.length; i++) {

                for (uint256 j = 0; j < i; j++) {

                    require(bkps[j] != _backups[i], "duplicate backup");

                }

            }

        }



        for (uint256 index = 0; index < _backups.length; index++) {

            address _backup = _backups[index];

            require(_backup != address(0), "backup cannot be 0x0");

            require(_backup != address(_account), "cannot be backup of oneself");



            backupData[address(_account)][index] = BackupAccount(_backup, now, uint256(-1));

        }

    }

}



/* The MIT License (MIT)



Copyright (c) 2016 Smart Contract Solutions, Inc.



Permission is hereby granted, free of charge, to any person obtaining

a copy of this software and associated documentation files (the

"Software"), to deal in the Software without restriction, including

without limitation the rights to use, copy, modify, merge, publish,

distribute, sublicense, and/or sell copies of the Software, and to

permit persons to whom the Software is furnished to do so, subject to

the following conditions:



The above copyright notice and this permission notice shall be included

in all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS

OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY

CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,

TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE

SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }



    /**

    * @dev Returns ceil(a / b).

    */

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        if(a % b == 0) {

            return c;

        }

        else {

            return c + 1;

        }

    }

}



contract BaseLogic {



    bytes constant internal SIGN_HASH_PREFIX = "\x19Ethereum Signed Message:\n32";



    mapping (address => uint256) keyNonce;

    AccountStorage public accountStorage;



    modifier allowSelfCallsOnly() {

        require (msg.sender == address(this), "only internal call is allowed");

        _;

    }



    modifier allowAccountCallsOnly(Account _account) {

        require(msg.sender == address(_account), "caller must be account");

        _;

    }



    event LogicInitialised(address wallet);



    // *************** Constructor ********************** //



    constructor(AccountStorage _accountStorage) public {

        accountStorage = _accountStorage;

    }



    // *************** Initialization ********************* //



    function initAccount(Account _account) external allowAccountCallsOnly(_account){

        emit LogicInitialised(address(_account));

    }



    // *************** Getter ********************** //



    function getKeyNonce(address _key) external view returns(uint256) {

        return keyNonce[_key];

    }



    // *************** Signature ********************** //



    function getSignHash(bytes memory _data, uint256 _nonce) internal view returns(bytes32) {

        // use EIP 191

        // 0x1900 + this logic address + data + nonce of signing key

        bytes32 msgHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), _data, _nonce));

        bytes32 prefixedHash = keccak256(abi.encodePacked(SIGN_HASH_PREFIX, msgHash));

        return prefixedHash;

    }



    function verifySig(address _signingKey, bytes memory _signature, bytes32 _signHash) internal pure {

        require(_signingKey != address(0), "invalid signing key");

        address recoveredAddr = recover(_signHash, _signature);

        require(recoveredAddr == _signingKey, "signature verification failed");

    }



    /**

     * @dev Returns the address that signed a hashed message (`hash`) with

     * `signature`. This address can then be used for verification purposes.

     *

     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:

     * this function rejects them by requiring the `s` value to be in the lower

     * half order, and the `v` value to be either 27 or 28.

     *

     * NOTE: This call _does not revert_ if the signature is invalid, or

     * if the signer is otherwise unable to be retrieved. In those scenarios,

     * the zero address is returned.

     *

     * IMPORTANT: `hash` _must_ be the result of a hash operation for the

     * verification to be secure: it is possible to craft signatures that

     * recover to arbitrary addresses for non-hashed data. A safe way to ensure

     * this is by receiving a hash of the original message (which may otherwise)

     * be too long), and then calling {toEthSignedMessageHash} on it.

     */

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        // Check the signature length

        if (signature.length != 65) {

            return (address(0));

        }



        // Divide the signature in r, s and v variables

        bytes32 r;

        bytes32 s;

        uint8 v;



        // ecrecover takes the signature parameters, and the only way to get them

        // currently is to use assembly.

        // solhint-disable-next-line no-inline-assembly

        assembly {

            r := mload(add(signature, 0x20))

            s := mload(add(signature, 0x40))

            v := byte(0, mload(add(signature, 0x60)))

        }



        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature

        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines

        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most

        // signatures from current libraries generate a unique signature with an s-value in the lower half order.

        //

        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value

        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or

        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept

        // these malleable signatures as well.

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {

            return address(0);

        }



        if (v != 27 && v != 28) {

            return address(0);

        }



        // If the signature is valid (and not malleable), return the signer address

        return ecrecover(hash, v, r, s);

    }



    /* get signer address from data

    * @dev Gets an address encoded as the first argument in transaction data

    * @param b The byte array that should have an address as first argument

    * @returns a The address retrieved from the array

    */

    function getSignerAddress(bytes memory _b) internal pure returns (address _a) {

        require(_b.length >= 36, "invalid bytes");

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

            _a := and(mask, mload(add(_b, 36)))

            // b = {length:32}{method sig:4}{address:32}{...}

            // 36 is the offset of the first parameter of the data, if encoded properly.

            // 32 bytes for the length of the bytes array, and the first 4 bytes for the function signature.

            // 32 bytes is the length of the bytes array!!!!

        }

    }



    // get method id, first 4 bytes of data

    function getMethodId(bytes memory _b) internal pure returns (bytes4 _a) {

        require(_b.length >= 4, "invalid data");

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            // 32 bytes is the length of the bytes array

            _a := mload(add(_b, 32))

        }

    }



    function checkKeyStatus(address _account, uint256 _index) internal {

        // check operation key status

        if (_index > 0) {

            require(accountStorage.getKeyStatus(_account, _index) != 1, "frozen key");

        }

    }



    // _nonce is timestamp in microsecond(1/1000000 second)

    function checkAndUpdateNonce(address _key, uint256 _nonce) internal {

        require(_nonce > keyNonce[_key], "nonce too small");

        require(SafeMath.div(_nonce, 1000000) <= now + 86400, "nonce too big"); // 86400=24*3600 seconds



        keyNonce[_key] = _nonce;

    }

}



contract DappLogic is BaseLogic {

    

    using RLPReader for RLPReader.RLPItem;

    using RLPReader for bytes;



    /*

    index 0: admin key

          1: asset(transfer)

          2: adding

          3: reserved(dapp)

          4: assist

     */

    uint constant internal DAPP_KEY_INDEX = 3;



    // *************** Events *************************** //



    event DappLogicInitialised(address indexed account);

    event DappLogicEntered(bytes data, uint256 indexed nonce);



    // *************** Constructor ********************** //

    constructor(AccountStorage _accountStorage)

        BaseLogic(_accountStorage)

        public

    {

    }



    // *************** Initialization ********************* //



    function initAccount(Account _account) external allowAccountCallsOnly(_account){

        emit DappLogicInitialised(address(_account));

    }



    // *************** action entry ********************* //



    function enter(bytes calldata _data, bytes calldata _signature, uint256 _nonce) external {

        address account = getSignerAddress(_data);

        checkKeyStatus(account, DAPP_KEY_INDEX);



        address dappKey = accountStorage.getKeyData(account, DAPP_KEY_INDEX);

        checkAndUpdateNonce(dappKey, _nonce);

        bytes32 signHash = getSignHash(_data, _nonce);

        verifySig(dappKey, _signature, signHash);



        // solium-disable-next-line security/no-low-level-calls

        (bool success,) = address(this).call(_data);

        require(success, "calling self failed");

        emit DappLogicEntered(_data, _nonce);

    }



    // *************** call Dapp ********************* //



    // called from 'enter'

    // call other contract from base account

    function callContract(address payable _account, address payable _target, uint256 _value, bytes calldata _methodData) external allowSelfCallsOnly {

        // Account(_account).invoke(_target, _value, _methodData);

        bool success;

        // solium-disable-next-line security/no-low-level-calls

        (success,) = _account.call(abi.encodeWithSignature("invoke(address,uint256,bytes)", _target, _value, _methodData));

        require(success, "calling invoke failed");

    }

    

    // called from 'enter'

    // call serveral other contracts at a time

    // rlp encode _methodData array into rlpBytes

    function callMultiContract(address payable _account, address[] calldata _targets, uint256[] calldata _values, bytes calldata _rlpBytes) external allowSelfCallsOnly {

        RLPReader.RLPItem[] memory ls = _rlpBytes.toRlpItem().toList();



        uint256 len = _targets.length;

        require(len == _values.length && len == ls.length, "length mismatch");

        for (uint256 i = 0; i < len; i++) {

            bool success;

            RLPReader.RLPItem memory item = ls[i];

            // solium-disable-next-line security/no-low-level-calls

            (success,) = _account.call(abi.encodeWithSignature("invoke(address,uint256,bytes)", _targets[i], _values[i], bytes(item.toBytes())));

            require(success, "calling invoke failed");

        }

    }



}