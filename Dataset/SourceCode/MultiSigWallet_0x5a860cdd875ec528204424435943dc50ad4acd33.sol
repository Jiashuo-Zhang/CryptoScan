pragma solidity 0.6.6;



/*

 * @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.

 * @author Stefan George - <stefan.george@consensys.net>

 */

contract MultiSigWallet {



    /*

     *  Events

     */

    event Confirmation(address indexed sender, uint indexed transactionId);

    event Revocation(address indexed sender, uint indexed transactionId);

    event Submission(uint indexed transactionId);

    event Execution(uint indexed transactionId);

    event ExecutionFailure(uint indexed transactionId);

    event Deposit(address indexed sender, uint value);

    event OwnerAddition(address indexed owner);

    event OwnerRemoval(address indexed owner);

    event RequirementChange(uint required);



    uint constant public MAX_OWNER_COUNT = 50;

    bytes32  constant internal projectHash = keccak256(abi.encodePacked("CLAIM"));



    mapping (uint => Transaction) public transactions;

    mapping (uint => mapping (address => bool)) public confirmations;

    mapping (address => bool) public isOwner;

    address[] public owners;

    uint public required;

    uint public transactionCount;



    struct Transaction {

        address destination;

        uint value;

        bytes data;

        bool executed;

        uint submitTime;

    }



    /*

     *  Modifiers

     */

    modifier onlyWallet() {

        require(msg.sender == address(this), "msg.sender != address(this)");

        _;

    }



    modifier ownerDoesNotExist(address owner) {

        require(!isOwner[owner], "is already owner");

        _;

    }



    modifier ownerExists(address owner) {

        require(isOwner[owner],"is not owner");

        _;

    }



    modifier transactionExists(uint transactionId) {

        require(transactions[transactionId].destination != address(0),"transactionId is not exists");

        _;

    }



    modifier confirmed(uint transactionId, address owner) {

        require(confirmations[transactionId][owner],"is not confirmed");

        _;

    }



    modifier notConfirmed(uint transactionId, address owner) {

        require(!confirmations[transactionId][owner],"already confirmed");

        _;

    }



    modifier notExecuted(uint transactionId) {

        require(!transactions[transactionId].executed,"already executed");

        _;

    }



    modifier notNull(address _address) {

        require(_address != address(0),"_address == address(0)");

        _;

    }



    modifier validRequirement(uint ownerCount, uint _required) {

        require(ownerCount <= MAX_OWNER_COUNT

            && _required <= ownerCount

            && _required != 0

            && ownerCount != 0,"error: validRequirement()");

        _;

    }



    /// @dev Fallback function allows to deposit ether.

    fallback() external {

    }



    receive() external payable { 

        if (msg.value > 0)

            emit Deposit(msg.sender, msg.value);

    }



    /*

     * Public functions

     */

    /// @dev Contract constructor sets initial owners and required number of confirmations.

    /// @param _owners List of initial owners.

    /// @param _required Number of required confirmations.

    constructor(address[] memory _owners, uint _required)

        public

        validRequirement(_owners.length, _required)

    {

        for (uint i=0; i<_owners.length; i++) {

            require(!isOwner[_owners[i]] && _owners[i] != address(0));

            isOwner[_owners[i]] = true;

        }

        owners = _owners;

        required = _required;

    }



    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.

    /// @param owner Address of new owner.

    function addOwner(address owner)

        public

        onlyWallet

        ownerDoesNotExist(owner)

        notNull(owner)

        validRequirement(owners.length + 1, required)

    {

        isOwner[owner] = true;

        owners.push(owner);

        OwnerAddition(owner);

    }



    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.

    /// @param owner Address of owner.

    function removeOwner(address owner)

        public

        onlyWallet

        ownerExists(owner)

    {

        isOwner[owner] = false;

        for (uint i=0; i<owners.length - 1; i++)

            if (owners[i] == owner) {

                owners[i] = owners[owners.length - 1];

                break;

            }

        if (required > (owners.length - 1))

            changeRequirement(owners.length - 1);

        OwnerRemoval(owner);

    }



    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.

    /// @param owner Address of owner to be replaced.

    /// @param newOwner Address of new owner.

    function replaceOwner(address owner, address newOwner)

        public

        onlyWallet

        ownerExists(owner)

        ownerDoesNotExist(newOwner)

    {

        for (uint i=0; i<owners.length; i++)

            if (owners[i] == owner) {

                owners[i] = newOwner;

                break;

            }

        isOwner[owner] = false;

        isOwner[newOwner] = true;

        OwnerRemoval(owner);

        OwnerAddition(newOwner);

    }



    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.

    /// @param _required Number of required confirmations.

    function changeRequirement(uint _required)

        public

        onlyWallet

        validRequirement(owners.length, _required)

    {

        required = _required;

        RequirementChange(_required);

    }



    /*@dev Allows an owner to submit and confirm a transaction.

    @param destination Transaction target address.

    @param value Transaction ether value.

    @param data Transaction data payload.

    @return Returns transaction ID.*/

    function submitTransaction(address destination, uint value, bytes memory data)

        public

        returns (uint transactionId)

    {

        transactionId = addTransaction(destination, value, data);

        confirmTransaction(transactionId);

    }



    /// @dev Allows an owner to batch confirm  transactions.

    /// @param transactionIdArray Transaction ID array.

    function batchConfirmTransaction(uint[] memory transactionIdArray) public

    {

        for(uint i = 0; i < transactionIdArray.length; i++ ) {

            confirmTransaction(transactionIdArray[i]);

        }

    }

    

    /// @dev Allows an owner to confirm a transaction.

    /// @param transactionId Transaction ID.

    function confirmTransaction(uint transactionId) 

        public 

        ownerExists(msg.sender)

        transactionExists(transactionId)

        notConfirmed(transactionId, msg.sender)

    {

        confirmations[transactionId][msg.sender] = true;

        Confirmation(msg.sender, transactionId);

        executeTransaction(transactionId);

    }



    /// @dev Allows an owner to revoke a confirmation for a transaction.

    /// @param transactionId Transaction ID.

    function revokeConfirmation(uint transactionId)

        public

        ownerExists(msg.sender)

        confirmed(transactionId, msg.sender)

        notExecuted(transactionId)

    {

        confirmations[transactionId][msg.sender] = false;

        Revocation(msg.sender, transactionId);

    }



    /// @dev Allows anyone to execute a confirmed transaction.

    /// @param transactionId Transaction ID.

    function executeTransaction(uint transactionId)

        public

        ownerExists(msg.sender)

        confirmed(transactionId, msg.sender)

        notExecuted(transactionId)

    {

        if (isConfirmed(transactionId)) {

            Transaction storage txn = transactions[transactionId];

            txn.executed = true;

            // address(txn.destination).call(abi.encodeWithSignature(txn.data))

            (bool success, bytes memory data) = txn.destination.call{value: txn.value}(txn.data);

            if (success)

                emit Execution(transactionId);

            else {

                emit ExecutionFailure(transactionId);

                txn.executed = false;

            }

        }

    }



    /// @dev Returns the confirmation status of a transaction.

    /// @param transactionId Transaction ID.

    /// @return Confirmation status.

    function isConfirmed(uint transactionId)

        public

        view

        returns (bool)

    {

        uint count = 0;

        for (uint i=0; i<owners.length; i++) {

            if (confirmations[transactionId][owners[i]])

                count += 1;

            if (count == required)

                return true;

        }

        return false;

    }



    /*

     * Internal functions

     */

    /*@dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.

    @param destination Transaction target address.

    @param value Transaction ether value.

    @param data Transaction data payload.

    @return Returns transaction ID.*/

    function addTransaction(address destination, uint value, bytes memory data)

        internal

        notNull(destination)

        returns (uint transactionId)

    {

        transactionId = transactionCount;

        transactions[transactionId] = Transaction({

            destination: destination,

            value: value,

            data: data,

            executed: false,

            submitTime: block.timestamp

        });

        transactionCount += 1;

        Submission(transactionId);

    }



    /*

     * Web3 call functions

     */

    /*@dev Returns number of confirmations of a transaction.

    @param transactionId Transaction ID.

    @return Number of confirmations.*/

    function getConfirmationCount(uint transactionId)

        public

        view

        returns (uint count)

    {

        count = 0;

        for (uint i=0; i<owners.length; i++)

            if (confirmations[transactionId][owners[i]])

                count += 1;

    }



    /*@dev Returns total number of transactions after filers are applied.

    @param pending Include pending transactions.

    @param executed Include executed transactions.

    @return Total number of transactions after filters are applied.*/

    function getTransactionCount(bool pending, bool executed)

        public

        view

        returns (uint count)

    {

        count = 0;

        for (uint i=0; i<transactionCount; i++)

            if (   pending && !transactions[i].executed

                || executed && transactions[i].executed)

                count += 1;

    }



    /// @dev Returns list of owners.

    /// @return List of owner addresses.

    function getOwners()

        public

        view

        returns (address[] memory)

    {

        return owners;

    }



    /*@dev Returns array with owner addresses, which confirmed transaction.

    @param transactionId Transaction ID.

    @return Returns array of owner addresses.*/

    function getConfirmations(uint transactionId)

        public

        view

        returns (address[] memory _confirmations)

    {

        address[] memory confirmationsTemp = new address[](owners.length);

        uint count = 0;

        uint i;

        for (i=0; i<owners.length; i++)

            if (confirmations[transactionId][owners[i]]) {

                confirmationsTemp[count] = owners[i];

                count += 1;

            }

        _confirmations = new address[](count);

        for (i=0; i<count; i++)

            _confirmations[i] = confirmationsTemp[i];

    }



    /*@dev Returns list of transaction IDs in defined range.

    @param from Index start position of transaction array.

    @param to Index end position of transaction array.

    @param pending Include pending transactions.

    @param executed Include executed transactions.

    @return Returns array of transaction IDs.*/

    function getTransactionIds(uint from, uint to, bool pending, bool executed)

        public

        view

        returns (uint[] memory _transactionIds)

    {

        uint[] memory transactionIdsTemp = new uint[](transactionCount);

        uint count = 0;

        uint i;

        for (i=0; i<transactionCount; i++)

            if (   pending && !transactions[i].executed

                || executed && transactions[i].executed)

            {

                transactionIdsTemp[count] = i;

                count += 1;

            }

        _transactionIds = new uint[](to - from);

        for (i=from; i<to; i++)

            _transactionIds[i - from] = transactionIdsTemp[i];

    }



    function getBlockTimestamp() view internal returns (uint) {

        return block.timestamp;

    }

}