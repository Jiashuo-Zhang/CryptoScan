/**

 *Submitted for verification at Etherscan.io on 2019-11-19

*/



pragma solidity ^0.5.8;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Integer division of two numbers, rounding up and truncating the quotient

  */

  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {

    if (_a == 0) {

      return 0;

    }



    return ((_a - 1) / _b) + 1;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



contract Timelock {

    using SafeMath for uint;



    event NewAdmin(address indexed newAdmin);

    event NewPendingAdmin(address indexed newPendingAdmin);

    event NewDelay(uint256 indexed newDelay);

    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature,  bytes data, uint256 eta);

    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature,  bytes data, uint256 eta);

    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);



    uint256 public constant GRACE_PERIOD = 14 days;

    uint256 public constant MINIMUM_DELAY = 12 hours;

    uint256 public constant MAXIMUM_DELAY = 30 days;



    address public admin;

    address public pendingAdmin;

    uint256 public delay;



    mapping (bytes32 => bool) public queuedTransactions;





    constructor(address admin_, uint256 delay_) public {

        require(delay_ >= MINIMUM_DELAY, "Timelock::constructor: Delay must exceed minimum delay.");

        require(delay_ <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");



        admin = admin_;

        delay = delay_;

    }



    function() external payable { }



    function setDelay(uint256 delay_) public {

        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");

        require(delay_ >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");

        require(delay_ <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");

        delay = delay_;



        emit NewDelay(delay);

    }



    function acceptAdmin() public {

        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Call must come from pendingAdmin.");

        admin = msg.sender;

        pendingAdmin = address(0);



        emit NewAdmin(admin);

    }



    function setPendingAdmin(address pendingAdmin_) public {

        require(msg.sender == address(this), "Timelock::setPendingAdmin: Call must come from Timelock.");

        pendingAdmin = pendingAdmin_;



        emit NewPendingAdmin(pendingAdmin);

    }



    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) public returns (bytes32) {

        require(msg.sender == admin, "Timelock::queueTransaction: Call must come from admin.");

        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");



        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));

        queuedTransactions[txHash] = true;



        emit QueueTransaction(txHash, target, value, signature, data, eta);

        return txHash;

    }



    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) public {

        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.");



        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));

        queuedTransactions[txHash] = false;



        emit CancelTransaction(txHash, target, value, signature, data, eta);

    }



    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) public payable returns (bytes memory) {

        require(msg.sender == admin, "Timelock::executeTransaction: Call must come from admin.");



        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));

        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");

        require(getBlockTimestamp() >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");

        require(getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock::executeTransaction: Transaction is stale.");



        queuedTransactions[txHash] = false;



        bytes memory callData;



        if (bytes(signature).length == 0) {

            callData = data;

        } else {

            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);

        }



        // solium-disable-next-line security/no-call-value

        (bool success, bytes memory returnData) = target.call.value(value)(callData);

        require(success, "Timelock::executeTransaction: Transaction execution reverted.");



        emit ExecuteTransaction(txHash, target, value, signature, data, eta);



        return returnData;

    }



    function getBlockTimestamp() internal view returns (uint256) {

        // solium-disable-next-line security/no-block-members

        return block.timestamp;

    }

}