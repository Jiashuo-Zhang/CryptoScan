/**

 *Submitted for verification at Etherscan.io on 2020-02-07

*/



/**

* Commit sha: fb3871bb35402a3e08487f77180c9b36d48d9f12

* GitHub repository: https://github.com/aragonone/court-registry-migrator

**/



// File: @aragon/court/contracts/lib/os/ERC20.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/token/ERC20.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity ^0.5.8;





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

    function totalSupply() public view returns (uint256);



    function balanceOf(address _who) public view returns (uint256);



    function allowance(address _owner, address _spender) public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool);



    function approve(address _spender, uint256 _value) public returns (bool);



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);



    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}



// File: @aragon/court/contracts/lib/os/SafeERC20.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/SafeERC20.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity ^0.5.8;







library SafeERC20 {

    // Before 0.5, solidity has a mismatch between `address.transfer()` and `token.transfer()`:

    // https://github.com/ethereum/solidity/issues/3544

    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;



    /**

    * @dev Same as a standards-compliant ERC20.transfer() that never reverts (returns false).

    *      Note that this makes an external call to the token.

    */

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(

            TRANSFER_SELECTOR,

            _to,

            _amount

        );

        return invokeAndCheckSuccess(address(_token), transferCallData);

    }



    /**

    * @dev Same as a standards-compliant ERC20.transferFrom() that never reverts (returns false).

    *      Note that this makes an external call to the token.

    */

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(

            _token.transferFrom.selector,

            _from,

            _to,

            _amount

        );

        return invokeAndCheckSuccess(address(_token), transferFromCallData);

    }



    /**

    * @dev Same as a standards-compliant ERC20.approve() that never reverts (returns false).

    *      Note that this makes an external call to the token.

    */

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(

            _token.approve.selector,

            _spender,

            _amount

        );

        return invokeAndCheckSuccess(address(_token), approveCallData);

    }



    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {

        bool ret;

        assembly {

            let ptr := mload(0x40)    // free memory pointer



            let success := call(

                gas,                  // forward all gas

                _addr,                // address

                0,                    // no value

                add(_calldata, 0x20), // calldata start

                mload(_calldata),     // calldata length

                ptr,                  // write output over free memory

                0x20                  // uint256 return

            )



            if gt(success, 0) {

            // Check number of bytes returned from last function call

                switch returndatasize



                // No bytes returned: assume success

                case 0 {

                    ret := 1

                }



                // 32 bytes returned: check if non-zero

                case 0x20 {

                // Only return success if returned data was true

                // Already have output in ptr

                    ret := eq(mload(ptr), 1)

                }



                // Not sure what was returned: don't mark as success

                default { }

            }

        }

        return ret;

    }

}



// File: @aragon/court/contracts/lib/os/SafeMath.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/math/SafeMath.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity >=0.4.24 <0.6.0;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";

    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";

    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";

    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (_a == 0) {

            return 0;

        }



        uint256 c = _a * _b;

        require(c / _a == _b, ERROR_MUL_OVERFLOW);



        return c;

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0

        uint256 c = _a / _b;

        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);

        uint256 c = _a - _b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;

        require(c >= _a, ERROR_ADD_OVERFLOW);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);

        return a % b;

    }

}



// File: @aragon/court/contracts/registry/IJurorsRegistry.sol



pragma solidity ^0.5.8;







interface IJurorsRegistry {



    /**

    * @dev Assign a requested amount of juror tokens to a juror

    * @param _juror Juror to add an amount of tokens to

    * @param _amount Amount of tokens to be added to the available balance of a juror

    */

    function assignTokens(address _juror, uint256 _amount) external;



    /**

    * @dev Burn a requested amount of juror tokens

    * @param _amount Amount of tokens to be burned

    */

    function burnTokens(uint256 _amount) external;



    /**

    * @dev Draft a set of jurors based on given requirements for a term id

    * @param _params Array containing draft requirements:

    *        0. bytes32 Term randomness

    *        1. uint256 Dispute id

    *        2. uint64  Current term id

    *        3. uint256 Number of seats already filled

    *        4. uint256 Number of seats left to be filled

    *        5. uint64  Number of jurors required for the draft

    *        6. uint16  Permyriad of the minimum active balance to be locked for the draft

    *

    * @return jurors List of jurors selected for the draft

    * @return length Size of the list of the draft result

    */

    function draft(uint256[7] calldata _params) external returns (address[] memory jurors, uint256 length);



    /**

    * @dev Slash a set of jurors based on their votes compared to the winning ruling

    * @param _termId Current term id

    * @param _jurors List of juror addresses to be slashed

    * @param _lockedAmounts List of amounts locked for each corresponding juror that will be either slashed or returned

    * @param _rewardedJurors List of booleans to tell whether a juror's active balance has to be slashed or not

    * @return Total amount of slashed tokens

    */

    function slashOrUnlock(uint64 _termId, address[] calldata _jurors, uint256[] calldata _lockedAmounts, bool[] calldata _rewardedJurors)

        external

        returns (uint256 collectedTokens);



    /**

    * @dev Try to collect a certain amount of tokens from a juror for the next term

    * @param _juror Juror to collect the tokens from

    * @param _amount Amount of tokens to be collected from the given juror and for the requested term id

    * @param _termId Current term id

    * @return True if the juror has enough unlocked tokens to be collected for the requested term, false otherwise

    */

    function collectTokens(address _juror, uint256 _amount, uint64 _termId) external returns (bool);



    /**

    * @dev Lock a juror's withdrawals until a certain term ID

    * @param _juror Address of the juror to be locked

    * @param _termId Term ID until which the juror's withdrawals will be locked

    */

    function lockWithdrawals(address _juror, uint64 _termId) external;



    /**

    * @dev Tell the active balance of a juror for a given term id

    * @param _juror Address of the juror querying the active balance of

    * @param _termId Term ID querying the active balance for

    * @return Amount of active tokens for juror in the requested past term id

    */

    function activeBalanceOfAt(address _juror, uint64 _termId) external view returns (uint256);



    /**

    * @dev Tell the total amount of active juror tokens at the given term id

    * @param _termId Term ID querying the total active balance for

    * @return Total amount of active juror tokens at the given term id

    */

    function totalActiveBalanceAt(uint64 _termId) external view returns (uint256);

}



// File: @aragon/court/contracts/lib/BytesHelpers.sol



pragma solidity ^0.5.8;





library BytesHelpers {

    function toBytes4(bytes memory _self) internal pure returns (bytes4 result) {

        if (_self.length < 4) {

            return bytes4(0);

        }



        assembly { result := mload(add(_self, 0x20)) }

    }

}



// File: @aragon/court/contracts/lib/Checkpointing.sol



pragma solidity ^0.5.8;





/**

* @title Checkpointing - Library to handle a historic set of numeric values

*/

library Checkpointing {

    uint256 private constant MAX_UINT192 = uint256(uint192(-1));



    string private constant ERROR_VALUE_TOO_BIG = "CHECKPOINT_VALUE_TOO_BIG";

    string private constant ERROR_CANNOT_ADD_PAST_VALUE = "CHECKPOINT_CANNOT_ADD_PAST_VALUE";



    /**

    * @dev To specify a value at a given point in time, we need to store two values:

    *      - `time`: unit-time value to denote the first time when a value was registered

    *      - `value`: a positive numeric value to registered at a given point in time

    *

    *      Note that `time` does not need to refer necessarily to a timestamp value, any time unit could be used

    *      for it like block numbers, terms, etc.

    */

    struct Checkpoint {

        uint64 time;

        uint192 value;

    }



    /**

    * @dev A history simply denotes a list of checkpoints

    */

    struct History {

        Checkpoint[] history;

    }



    /**

    * @dev Add a new value to a history for a given point in time. This function does not allow to add values previous

    *      to the latest registered value, if the value willing to add corresponds to the latest registered value, it

    *      will be updated.

    * @param self Checkpoints history to be altered

    * @param _time Point in time to register the given value

    * @param _value Numeric value to be registered at the given point in time

    */

    function add(History storage self, uint64 _time, uint256 _value) internal {

        require(_value <= MAX_UINT192, ERROR_VALUE_TOO_BIG);

        _add192(self, _time, uint192(_value));

    }



    /**

    * @dev Fetch the latest registered value of history, it will return zero if there was no value registered

    * @param self Checkpoints history to be queried

    */

    function getLast(History storage self) internal view returns (uint256) {

        uint256 length = self.history.length;

        if (length > 0) {

            return uint256(self.history[length - 1].value);

        }



        return 0;

    }



    /**

    * @dev Fetch the most recent registered past value of a history based on a given point in time that is not known

    *      how recent it is beforehand. It will return zero if there is no registered value or if given time is

    *      previous to the first registered value.

    *      It uses a binary search.

    * @param self Checkpoints history to be queried

    * @param _time Point in time to query the most recent registered past value of

    */

    function get(History storage self, uint64 _time) internal view returns (uint256) {

        return _binarySearch(self, _time);

    }



    /**

    * @dev Fetch the most recent registered past value of a history based on a given point in time. It will return zero

    *      if there is no registered value or if given time is previous to the first registered value.

    *      It uses a linear search starting from the end.

    * @param self Checkpoints history to be queried

    * @param _time Point in time to query the most recent registered past value of

    */

    function getRecent(History storage self, uint64 _time) internal view returns (uint256) {

        return _backwardsLinearSearch(self, _time);

    }



    /**

    * @dev Private function to add a new value to a history for a given point in time. This function does not allow to

    *      add values previous to the latest registered value, if the value willing to add corresponds to the latest

    *      registered value, it will be updated.

    * @param self Checkpoints history to be altered

    * @param _time Point in time to register the given value

    * @param _value Numeric value to be registered at the given point in time

    */

    function _add192(History storage self, uint64 _time, uint192 _value) private {

        uint256 length = self.history.length;

        if (length == 0 || self.history[self.history.length - 1].time < _time) {

            // If there was no value registered or the given point in time is after the latest registered value,

            // we can insert it to the history directly.

            self.history.push(Checkpoint(_time, _value));

        } else {

            // If the point in time given for the new value is not after the latest registered value, we must ensure

            // we are only trying to update the latest value, otherwise we would be changing past data.

            Checkpoint storage currentCheckpoint = self.history[length - 1];

            require(_time == currentCheckpoint.time, ERROR_CANNOT_ADD_PAST_VALUE);

            currentCheckpoint.value = _value;

        }

    }



    /**

    * @dev Private function to execute a backwards linear search to find the most recent registered past value of a

    *      history based on a given point in time. It will return zero if there is no registered value or if given time

    *      is previous to the first registered value. Note that this function will be more suitable when we already know

    *      that the time used to index the search is recent in the given history.

    * @param self Checkpoints history to be queried

    * @param _time Point in time to query the most recent registered past value of

    */

    function _backwardsLinearSearch(History storage self, uint64 _time) private view returns (uint256) {

        // If there was no value registered for the given history return simply zero

        uint256 length = self.history.length;

        if (length == 0) {

            return 0;

        }



        uint256 index = length - 1;

        Checkpoint storage checkpoint = self.history[index];

        while (index > 0 && checkpoint.time > _time) {

            index--;

            checkpoint = self.history[index];

        }



        return checkpoint.time > _time ? 0 : uint256(checkpoint.value);

    }



    /**

    * @dev Private function execute a binary search to find the most recent registered past value of a history based on

    *      a given point in time. It will return zero if there is no registered value or if given time is previous to

    *      the first registered value. Note that this function will be more suitable when don't know how recent the

    *      time used to index may be.

    * @param self Checkpoints history to be queried

    * @param _time Point in time to query the most recent registered past value of

    */

    function _binarySearch(History storage self, uint64 _time) private view returns (uint256) {

        // If there was no value registered for the given history return simply zero

        uint256 length = self.history.length;

        if (length == 0) {

            return 0;

        }



        // If the requested time is equal to or after the time of the latest registered value, return latest value

        uint256 lastIndex = length - 1;

        if (_time >= self.history[lastIndex].time) {

            return uint256(self.history[lastIndex].value);

        }



        // If the requested time is previous to the first registered value, return zero to denote missing checkpoint

        if (_time < self.history[0].time) {

            return 0;

        }



        // Execute a binary search between the checkpointed times of the history

        uint256 low = 0;

        uint256 high = lastIndex;



        while (high > low) {

            // No need for SafeMath: for this to overflow array size should be ~2^255

            uint256 mid = (high + low + 1) / 2;

            Checkpoint storage checkpoint = self.history[mid];

            uint64 midTime = checkpoint.time;



            if (_time > midTime) {

                low = mid;

            } else if (_time < midTime) {

                // No need for SafeMath: high > low >= 0 => high >= 1 => mid >= 1

                high = mid - 1;

            } else {

                return uint256(checkpoint.value);

            }

        }



        return uint256(self.history[low].value);

    }

}



// File: @aragon/court/contracts/lib/HexSumTree.sol



pragma solidity ^0.5.8;









/**

* @title HexSumTree - Library to operate checkpointed 16-ary (hex) sum trees.

* @dev A sum tree is a particular case of a tree where the value of a node is equal to the sum of the values of its

*      children. This library provides a set of functions to operate 16-ary sum trees, i.e. trees where every non-leaf

*      node has 16 children and its value is equivalent to the sum of the values of all of them. Additionally, a

*      checkpointed tree means that each time a value on a node is updated, its previous value will be saved to allow

*      accessing historic information.

*

*      Example of a checkpointed binary sum tree:

*

*                                          CURRENT                                      PREVIOUS

*

*             Level 2                        100  ---------------------------------------- 70

*                                       ______|_______                               ______|_______

*                                      /              \                             /              \

*             Level 1                 34              66 ------------------------- 23              47

*                                _____|_____      _____|_____                 _____|_____      _____|_____

*                               /           \    /           \               /           \    /           \

*             Level 0          22           12  53           13 ----------- 22            1  17           30

*

*/

library HexSumTree {

    using SafeMath for uint256;

    using Checkpointing for Checkpointing.History;



    string private constant ERROR_UPDATE_OVERFLOW = "SUM_TREE_UPDATE_OVERFLOW";

    string private constant ERROR_KEY_DOES_NOT_EXIST = "SUM_TREE_KEY_DOES_NOT_EXIST";

    string private constant ERROR_SEARCH_OUT_OF_BOUNDS = "SUM_TREE_SEARCH_OUT_OF_BOUNDS";

    string private constant ERROR_MISSING_SEARCH_VALUES = "SUM_TREE_MISSING_SEARCH_VALUES";



    // Constants used to perform tree computations

    // To change any the following constants, the following relationship must be kept: 2^BITS_IN_NIBBLE = CHILDREN

    // The max depth of the tree will be given by: BITS_IN_NIBBLE * MAX_DEPTH = 256 (so in this case it's 64)

    uint256 private constant CHILDREN = 16;

    uint256 private constant BITS_IN_NIBBLE = 4;



    // All items are leaves, inserted at height or level zero. The root height will be increasing as new levels are inserted in the tree.

    uint256 private constant ITEMS_LEVEL = 0;



    // Tree nodes are identified with a 32-bytes length key. Leaves are identified with consecutive incremental keys

    // starting with 0x0000000000000000000000000000000000000000000000000000000000000000, while non-leaf nodes' keys

    // are computed based on their level and their children keys.

    uint256 private constant BASE_KEY = 0;



    // Timestamp used to checkpoint the first value of the tree height during initialization

    uint64 private constant INITIALIZATION_INITIAL_TIME = uint64(0);



    /**

    * @dev The tree is stored using the following structure:

    *      - nodes: A mapping indexed by a pair (level, key) with a history of the values for each node (level -> key -> value).

    *      - height: A history of the heights of the tree. Minimum height is 1, a root with 16 children.

    *      - nextKey: The next key to be used to identify the next new value that will be inserted into the tree.

    */

    struct Tree {

        uint256 nextKey;

        Checkpointing.History height;

        mapping (uint256 => mapping (uint256 => Checkpointing.History)) nodes;

    }



    /**

    * @dev Search params to traverse the tree caching previous results:

    *      - time: Point in time to query the values being searched, this value shouldn't change during a search

    *      - level: Level being analyzed for the search, it starts at the level under the root and decrements till the leaves

    *      - parentKey: Key of the parent of the nodes being analyzed at the given level for the search

    *      - foundValues: Number of values in the list being searched that were already found, it will go from 0 until the size of the list

    *      - visitedTotal: Total sum of values that were already visited during the search, it will go from 0 until the tree total

    */

    struct SearchParams {

        uint64 time;

        uint256 level;

        uint256 parentKey;

        uint256 foundValues;

        uint256 visitedTotal;

    }



    /**

    * @dev Initialize tree setting the next key and first height checkpoint

    */

    function init(Tree storage self) internal {

        self.height.add(INITIALIZATION_INITIAL_TIME, ITEMS_LEVEL + 1);

        self.nextKey = BASE_KEY;

    }



    /**

    * @dev Insert a new item to the tree at given point in time

    * @param _time Point in time to register the given value

    * @param _value New numeric value to be added to the tree

    * @return Unique key identifying the new value inserted

    */

    function insert(Tree storage self, uint64 _time, uint256 _value) internal returns (uint256) {

        // As the values are always stored in the leaves of the tree (level 0), the key to index each of them will be

        // always incrementing, starting from zero. Add a new level if necessary.

        uint256 key = self.nextKey++;

        _addLevelIfNecessary(self, key, _time);



        // If the new value is not zero, first set the value of the new leaf node, then add a new level at the top of

        // the tree if necessary, and finally update sums cached in all the non-leaf nodes.

        if (_value > 0) {

            _add(self, ITEMS_LEVEL, key, _time, _value);

            _updateSums(self, key, _time, _value, true);

        }

        return key;

    }



    /**

    * @dev Set the value of a leaf node indexed by its key at given point in time

    * @param _time Point in time to set the given value

    * @param _key Key of the leaf node to be set in the tree

    * @param _value New numeric value to be set for the given key

    */

    function set(Tree storage self, uint256 _key, uint64 _time, uint256 _value) internal {

        require(_key < self.nextKey, ERROR_KEY_DOES_NOT_EXIST);



        // Set the new value for the requested leaf node

        uint256 lastValue = getItem(self, _key);

        _add(self, ITEMS_LEVEL, _key, _time, _value);



        // Update sums cached in the non-leaf nodes. Note that overflows are being checked at the end of the whole update.

        if (_value > lastValue) {

            _updateSums(self, _key, _time, _value - lastValue, true);

        } else if (_value < lastValue) {

            _updateSums(self, _key, _time, lastValue - _value, false);

        }

    }



    /**

    * @dev Update the value of a non-leaf node indexed by its key at given point in time based on a delta

    * @param _key Key of the leaf node to be updated in the tree

    * @param _time Point in time to update the given value

    * @param _delta Numeric delta to update the value of the given key

    * @param _positive Boolean to tell whether the given delta should be added to or subtracted from the current value

    */

    function update(Tree storage self, uint256 _key, uint64 _time, uint256 _delta, bool _positive) internal {

        require(_key < self.nextKey, ERROR_KEY_DOES_NOT_EXIST);



        // Update the value of the requested leaf node based on the given delta

        uint256 lastValue = getItem(self, _key);

        uint256 newValue = _positive ? lastValue.add(_delta) : lastValue.sub(_delta);

        _add(self, ITEMS_LEVEL, _key, _time, newValue);



        // Update sums cached in the non-leaf nodes. Note that overflows is being checked at the end of the whole update.

        _updateSums(self, _key, _time, _delta, _positive);

    }



    /**

    * @dev Search a list of values in the tree at a given point in time. It will return a list with the nearest

    *      high value in case a value cannot be found. This function assumes the given list of given values to be

    *      searched is in ascending order. In case of searching a value out of bounds, it will return zeroed results.

    * @param _values Ordered list of values to be searched in the tree

    * @param _time Point in time to query the values being searched

    * @return keys List of keys found for each requested value in the same order

    * @return values List of node values found for each requested value in the same order

    */

    function search(Tree storage self, uint256[] memory _values, uint64 _time) internal view

        returns (uint256[] memory keys, uint256[] memory values)

    {

        require(_values.length > 0, ERROR_MISSING_SEARCH_VALUES);



        // Throw out-of-bounds error if there are no items in the tree or the highest value being searched is greater than the total

        uint256 total = getRecentTotalAt(self, _time);

        // No need for SafeMath: positive length of array already checked

        require(total > 0 && total > _values[_values.length - 1], ERROR_SEARCH_OUT_OF_BOUNDS);



        // Build search params for the first iteration

        uint256 rootLevel = getRecentHeightAt(self, _time);

        SearchParams memory searchParams = SearchParams(_time, rootLevel.sub(1), BASE_KEY, 0, 0);



        // These arrays will be used to fill in the results. We are passing them as parameters to avoid extra copies

        uint256 length = _values.length;

        keys = new uint256[](length);

        values = new uint256[](length);

        _search(self, _values, searchParams, keys, values);

    }



    /**

    * @dev Tell the sum of the all the items (leaves) stored in the tree, i.e. value of the root of the tree

    */

    function getTotal(Tree storage self) internal view returns (uint256) {

        uint256 rootLevel = getHeight(self);

        return getNode(self, rootLevel, BASE_KEY);

    }



    /**

    * @dev Tell the sum of the all the items (leaves) stored in the tree, i.e. value of the root of the tree, at a given point in time

    *      It uses a binary search for the root node, a linear one for the height.

    * @param _time Point in time to query the sum of all the items (leaves) stored in the tree

    */

    function getTotalAt(Tree storage self, uint64 _time) internal view returns (uint256) {

        uint256 rootLevel = getRecentHeightAt(self, _time);

        return getNodeAt(self, rootLevel, BASE_KEY, _time);

    }



    /**

    * @dev Tell the sum of the all the items (leaves) stored in the tree, i.e. value of the root of the tree, at a given point in time

    *      It uses a linear search starting from the end.

    * @param _time Point in time to query the sum of all the items (leaves) stored in the tree

    */

    function getRecentTotalAt(Tree storage self, uint64 _time) internal view returns (uint256) {

        uint256 rootLevel = getRecentHeightAt(self, _time);

        return getRecentNodeAt(self, rootLevel, BASE_KEY, _time);

    }



    /**

    * @dev Tell the value of a certain leaf indexed by a given key

    * @param _key Key of the leaf node querying the value of

    */

    function getItem(Tree storage self, uint256 _key) internal view returns (uint256) {

        return getNode(self, ITEMS_LEVEL, _key);

    }



    /**

    * @dev Tell the value of a certain leaf indexed by a given key at a given point in time

    *      It uses a binary search.

    * @param _key Key of the leaf node querying the value of

    * @param _time Point in time to query the value of the requested leaf

    */

    function getItemAt(Tree storage self, uint256 _key, uint64 _time) internal view returns (uint256) {

        return getNodeAt(self, ITEMS_LEVEL, _key, _time);

    }



    /**

    * @dev Tell the value of a certain node indexed by a given (level,key) pair

    * @param _level Level of the node querying the value of

    * @param _key Key of the node querying the value of

    */

    function getNode(Tree storage self, uint256 _level, uint256 _key) internal view returns (uint256) {

        return self.nodes[_level][_key].getLast();

    }



    /**

    * @dev Tell the value of a certain node indexed by a given (level,key) pair at a given point in time

    *      It uses a binary search.

    * @param _level Level of the node querying the value of

    * @param _key Key of the node querying the value of

    * @param _time Point in time to query the value of the requested node

    */

    function getNodeAt(Tree storage self, uint256 _level, uint256 _key, uint64 _time) internal view returns (uint256) {

        return self.nodes[_level][_key].get(_time);

    }



    /**

    * @dev Tell the value of a certain node indexed by a given (level,key) pair at a given point in time

    *      It uses a linear search starting from the end.

    * @param _level Level of the node querying the value of

    * @param _key Key of the node querying the value of

    * @param _time Point in time to query the value of the requested node

    */

    function getRecentNodeAt(Tree storage self, uint256 _level, uint256 _key, uint64 _time) internal view returns (uint256) {

        return self.nodes[_level][_key].getRecent(_time);

    }



    /**

    * @dev Tell the height of the tree

    */

    function getHeight(Tree storage self) internal view returns (uint256) {

        return self.height.getLast();

    }



    /**

    * @dev Tell the height of the tree at a given point in time

    *      It uses a linear search starting from the end.

    * @param _time Point in time to query the height of the tree

    */

    function getRecentHeightAt(Tree storage self, uint64 _time) internal view returns (uint256) {

        return self.height.getRecent(_time);

    }



    /**

    * @dev Private function to update the values of all the ancestors of the given leaf node based on the delta updated

    * @param _key Key of the leaf node to update the ancestors of

    * @param _time Point in time to update the ancestors' values of the given leaf node

    * @param _delta Numeric delta to update the ancestors' values of the given leaf node

    * @param _positive Boolean to tell whether the given delta should be added to or subtracted from ancestors' values

    */

    function _updateSums(Tree storage self, uint256 _key, uint64 _time, uint256 _delta, bool _positive) private {

        uint256 mask = uint256(-1);

        uint256 ancestorKey = _key;

        uint256 currentHeight = getHeight(self);

        for (uint256 level = ITEMS_LEVEL + 1; level <= currentHeight; level++) {

            // Build a mask to get the key of the ancestor at a certain level. For example:

            // Level  0: leaves don't have children

            // Level  1: 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0 (up to 16 leaves)

            // Level  2: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00 (up to 32 leaves)

            // ...

            // Level 63: 0x0000000000000000000000000000000000000000000000000000000000000000 (up to 16^64 leaves - tree max height)

            mask = mask << BITS_IN_NIBBLE;



            // The key of the ancestor at that level "i" is equivalent to the "(64 - i)-th" most significant nibbles

            // of the ancestor's key of the previous level "i - 1". Thus, we can compute the key of an ancestor at a

            // certain level applying the mask to the ancestor's key of the previous level. Note that for the first

            // iteration, the key of the ancestor of the previous level is simply the key of the leaf being updated.

            ancestorKey = ancestorKey & mask;



            // Update value

            uint256 lastValue = getNode(self, level, ancestorKey);

            uint256 newValue = _positive ? lastValue.add(_delta) : lastValue.sub(_delta);

            _add(self, level, ancestorKey, _time, newValue);

        }



        // Check if there was an overflow. Note that we only need to check the value stored in the root since the

        // sum only increases going up through the tree.

        require(!_positive || getNode(self, currentHeight, ancestorKey) >= _delta, ERROR_UPDATE_OVERFLOW);

    }



    /**

    * @dev Private function to add a new level to the tree based on a new key that will be inserted

    * @param _newKey New key willing to be inserted in the tree

    * @param _time Point in time when the new key will be inserted

    */

    function _addLevelIfNecessary(Tree storage self, uint256 _newKey, uint64 _time) private {

        uint256 currentHeight = getHeight(self);

        if (_shouldAddLevel(currentHeight, _newKey)) {

            // Max height allowed for the tree is 64 since we are using node keys of 32 bytes. However, note that we

            // are not checking if said limit has been hit when inserting new leaves to the tree, for the purpose of

            // this system having 2^256 items inserted is unrealistic.

            uint256 newHeight = currentHeight + 1;

            uint256 rootValue = getNode(self, currentHeight, BASE_KEY);

            _add(self, newHeight, BASE_KEY, _time, rootValue);

            self.height.add(_time, newHeight);

        }

    }



    /**

    * @dev Private function to register a new value in the history of a node at a given point in time

    * @param _level Level of the node to add a new value at a given point in time to

    * @param _key Key of the node to add a new value at a given point in time to

    * @param _time Point in time to register a value for the given node

    * @param _value Numeric value to be registered for the given node at a given point in time

    */

    function _add(Tree storage self, uint256 _level, uint256 _key, uint64 _time, uint256 _value) private {

        self.nodes[_level][_key].add(_time, _value);

    }



    /**

    * @dev Recursive pre-order traversal function

    *      Every time it checks a node, it traverses the input array to find the initial subset of elements that are

    *      below its accumulated value and passes that sub-array to the next iteration. Actually, the array is always

    *      the same, to avoid making extra copies, it just passes the number of values already found , to avoid

    *      checking values that went through a different branch. The same happens with the result lists of keys and

    *      values, these are the same on every recursion step. The visited total is carried over each iteration to

    *      avoid having to subtract all elements in the array.

    * @param _values Ordered list of values to be searched in the tree

    * @param _params Search parameters for the current recursive step

    * @param _resultKeys List of keys found for each requested value in the same order

    * @param _resultValues List of node values found for each requested value in the same order

    */

    function _search(

        Tree storage self,

        uint256[] memory _values,

        SearchParams memory _params,

        uint256[] memory _resultKeys,

        uint256[] memory _resultValues

    )

        private

        view

    {

        uint256 levelKeyLessSignificantNibble = _params.level.mul(BITS_IN_NIBBLE);



        for (uint256 childNumber = 0; childNumber < CHILDREN; childNumber++) {

            // Return if we already found enough values

            if (_params.foundValues >= _values.length) {

                break;

            }



            // Build child node key shifting the child number to the position of the less significant nibble of

            // the keys for the level being analyzed, and adding it to the key of the parent node. For example,

            // for a tree with height 5, if we are checking the children of the second node of the level 3, whose

            // key is    0x0000000000000000000000000000000000000000000000000000000000001000, its children keys are:

            // Child  0: 0x0000000000000000000000000000000000000000000000000000000000001000

            // Child  1: 0x0000000000000000000000000000000000000000000000000000000000001100

            // Child  2: 0x0000000000000000000000000000000000000000000000000000000000001200

            // ...

            // Child 15: 0x0000000000000000000000000000000000000000000000000000000000001f00

            uint256 childNodeKey = _params.parentKey.add(childNumber << levelKeyLessSignificantNibble);

            uint256 childNodeValue = getRecentNodeAt(self, _params.level, childNodeKey, _params.time);



            // Check how many values belong to the subtree of this node. As they are ordered, it will be a contiguous

            // subset starting from the beginning, so we only need to know the length of that subset.

            uint256 newVisitedTotal = _params.visitedTotal.add(childNodeValue);

            uint256 subtreeIncludedValues = _getValuesIncludedInSubtree(_values, _params.foundValues, newVisitedTotal);



            // If there are some values included in the subtree of the child node, visit them

            if (subtreeIncludedValues > 0) {

                // If the child node being analyzed is a leaf, add it to the list of results a number of times equals

                // to the number of values that were included in it. Otherwise, descend one level.

                if (_params.level == ITEMS_LEVEL) {

                    _copyFoundNode(_params.foundValues, subtreeIncludedValues, childNodeKey, _resultKeys, childNodeValue, _resultValues);

                } else {

                    SearchParams memory nextLevelParams = SearchParams(

                        _params.time,

                        _params.level - 1, // No need for SafeMath: we already checked above that the level being checked is greater than zero

                        childNodeKey,

                        _params.foundValues,

                        _params.visitedTotal

                    );

                    _search(self, _values, nextLevelParams, _resultKeys, _resultValues);

                }

                // Update the number of values that were already found

                _params.foundValues = _params.foundValues.add(subtreeIncludedValues);

            }

            // Update the visited total for the next node in this level

            _params.visitedTotal = newVisitedTotal;

        }

    }



    /**

    * @dev Private function to check if a new key can be added to the tree based on the current height of the tree

    * @param _currentHeight Current height of the tree to check if it supports adding the given key

    * @param _newKey Key willing to be added to the tree with the given current height

    * @return True if the current height of the tree should be increased to add the new key, false otherwise.

    */

    function _shouldAddLevel(uint256 _currentHeight, uint256 _newKey) private pure returns (bool) {

        // Build a mask that will match all the possible keys for the given height. For example:

        // Height  1: 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0 (up to 16 keys)

        // Height  2: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00 (up to 32 keys)

        // ...

        // Height 64: 0x0000000000000000000000000000000000000000000000000000000000000000 (up to 16^64 keys - tree max height)

        uint256 shift = _currentHeight.mul(BITS_IN_NIBBLE);

        uint256 mask = uint256(-1) << shift;



        // Check if the given key can be represented in the tree with the current given height using the mask.

        return (_newKey & mask) != 0;

    }



    /**

    * @dev Private function to tell how many values of a list can be found in a subtree

    * @param _values List of values being searched in ascending order

    * @param _foundValues Number of values that were already found and should be ignore

    * @param _subtreeTotal Total sum of the given subtree to check the numbers that are included in it

    * @return Number of values in the list that are included in the given subtree

    */

    function _getValuesIncludedInSubtree(uint256[] memory _values, uint256 _foundValues, uint256 _subtreeTotal) private pure returns (uint256) {

        // Look for all the values that can be found in the given subtree

        uint256 i = _foundValues;

        while (i < _values.length && _values[i] < _subtreeTotal) {

            i++;

        }

        return i - _foundValues;

    }



    /**

    * @dev Private function to copy a node a given number of times to a results list. This function assumes the given

    *      results list have enough size to support the requested copy.

    * @param _from Index of the results list to start copying the given node

    * @param _times Number of times the given node will be copied

    * @param _key Key of the node to be copied

    * @param _resultKeys Lists of key results to copy the given node key to

    * @param _value Value of the node to be copied

    * @param _resultValues Lists of value results to copy the given node value to

    */

    function _copyFoundNode(

        uint256 _from,

        uint256 _times,

        uint256 _key,

        uint256[] memory _resultKeys,

        uint256 _value,

        uint256[] memory _resultValues

    )

        private

        pure

    {

        for (uint256 i = 0; i < _times; i++) {

            _resultKeys[_from + i] = _key;

            _resultValues[_from + i] = _value;

        }

    }

}



// File: @aragon/court/contracts/lib/PctHelpers.sol



pragma solidity ^0.5.8;







library PctHelpers {

    using SafeMath for uint256;



    uint256 internal constant PCT_BASE = 10000; // ‱ (1 / 10,000)



    function isValid(uint16 _pct) internal pure returns (bool) {

        return _pct <= PCT_BASE;

    }



    function pct(uint256 self, uint16 _pct) internal pure returns (uint256) {

        return self.mul(uint256(_pct)) / PCT_BASE;

    }



    function pct256(uint256 self, uint256 _pct) internal pure returns (uint256) {

        return self.mul(_pct) / PCT_BASE;

    }



    function pctIncrease(uint256 self, uint16 _pct) internal pure returns (uint256) {

        // No need for SafeMath: for addition note that `PCT_BASE` is lower than (2^256 - 2^16)

        return self.mul(PCT_BASE + uint256(_pct)) / PCT_BASE;

    }

}



// File: @aragon/court/contracts/lib/JurorsTreeSortition.sol



pragma solidity ^0.5.8;









/**

* @title JurorsTreeSortition - Library to perform jurors sortition over a `HexSumTree`

*/

library JurorsTreeSortition {

    using SafeMath for uint256;

    using HexSumTree for HexSumTree.Tree;



    string private constant ERROR_INVALID_INTERVAL_SEARCH = "TREE_INVALID_INTERVAL_SEARCH";

    string private constant ERROR_SORTITION_LENGTHS_MISMATCH = "TREE_SORTITION_LENGTHS_MISMATCH";



    /**

    * @dev Search random items in the tree based on certain restrictions

    * @param _termRandomness Randomness to compute the seed for the draft

    * @param _disputeId Identification number of the dispute to draft jurors for

    * @param _termId Current term when the draft is being computed

    * @param _selectedJurors Number of jurors already selected for the draft

    * @param _batchRequestedJurors Number of jurors to be selected in the given batch of the draft

    * @param _roundRequestedJurors Total number of jurors requested to be drafted

    * @param _sortitionIteration Number of sortitions already performed for the given draft

    * @return jurorsIds List of juror ids obtained based on the requested search

    * @return jurorsBalances List of active balances for each juror obtained based on the requested search

    */

    function batchedRandomSearch(

        HexSumTree.Tree storage tree,

        bytes32 _termRandomness,

        uint256 _disputeId,

        uint64 _termId,

        uint256 _selectedJurors,

        uint256 _batchRequestedJurors,

        uint256 _roundRequestedJurors,

        uint256 _sortitionIteration

    )

        internal

        view

        returns (uint256[] memory jurorsIds, uint256[] memory jurorsBalances)

    {

        (uint256 low, uint256 high) = getSearchBatchBounds(tree, _termId, _selectedJurors, _batchRequestedJurors, _roundRequestedJurors);

        uint256[] memory balances = _computeSearchRandomBalances(

            _termRandomness,

            _disputeId,

            _sortitionIteration,

            _batchRequestedJurors,

            low,

            high

        );



        (jurorsIds, jurorsBalances) = tree.search(balances, _termId);



        require(jurorsIds.length == jurorsBalances.length, ERROR_SORTITION_LENGTHS_MISMATCH);

        require(jurorsIds.length == _batchRequestedJurors, ERROR_SORTITION_LENGTHS_MISMATCH);

    }



    /**

    * @dev Get the bounds for a draft batch based on the active balances of the jurors

    * @param _termId Term ID of the active balances that will be used to compute the boundaries

    * @param _selectedJurors Number of jurors already selected for the draft

    * @param _batchRequestedJurors Number of jurors to be selected in the given batch of the draft

    * @param _roundRequestedJurors Total number of jurors requested to be drafted

    * @return low Low bound to be used for the sortition to draft the requested number of jurors for the given batch

    * @return high High bound to be used for the sortition to draft the requested number of jurors for the given batch

    */

    function getSearchBatchBounds(

        HexSumTree.Tree storage tree,

        uint64 _termId,

        uint256 _selectedJurors,

        uint256 _batchRequestedJurors,

        uint256 _roundRequestedJurors

    )

        internal

        view

        returns (uint256 low, uint256 high)

    {

        uint256 totalActiveBalance = tree.getRecentTotalAt(_termId);

        low = _selectedJurors.mul(totalActiveBalance).div(_roundRequestedJurors);



        uint256 newSelectedJurors = _selectedJurors.add(_batchRequestedJurors);

        high = newSelectedJurors.mul(totalActiveBalance).div(_roundRequestedJurors);

    }



    /**

    * @dev Get a random list of active balances to be searched in the jurors tree for a given draft batch

    * @param _termRandomness Randomness to compute the seed for the draft

    * @param _disputeId Identification number of the dispute to draft jurors for (for randomness)

    * @param _sortitionIteration Number of sortitions already performed for the given draft (for randomness)

    * @param _batchRequestedJurors Number of jurors to be selected in the given batch of the draft

    * @param _lowBatchBound Low bound to be used for the sortition batch to draft the requested number of jurors

    * @param _highBatchBound High bound to be used for the sortition batch to draft the requested number of jurors

    * @return Random list of active balances to be searched in the jurors tree for the given draft batch

    */

    function _computeSearchRandomBalances(

        bytes32 _termRandomness,

        uint256 _disputeId,

        uint256 _sortitionIteration,

        uint256 _batchRequestedJurors,

        uint256 _lowBatchBound,

        uint256 _highBatchBound

    )

        internal

        pure

        returns (uint256[] memory)

    {

        // Calculate the interval to be used to search the balances in the tree. Since we are using a modulo function to compute the

        // random balances to be searched, intervals will be closed on the left and open on the right, for example [0,10).

        require(_highBatchBound > _lowBatchBound, ERROR_INVALID_INTERVAL_SEARCH);

        uint256 interval = _highBatchBound - _lowBatchBound;



        // Compute an ordered list of random active balance to be searched in the jurors tree

        uint256[] memory balances = new uint256[](_batchRequestedJurors);

        for (uint256 batchJurorNumber = 0; batchJurorNumber < _batchRequestedJurors; batchJurorNumber++) {

            // Compute a random seed using:

            // - The inherent randomness associated to the term from blockhash

            // - The disputeId, so 2 disputes in the same term will have different outcomes

            // - The sortition iteration, to avoid getting stuck if resulting jurors are dismissed due to locked balance

            // - The juror number in this batch

            bytes32 seed = keccak256(abi.encodePacked(_termRandomness, _disputeId, _sortitionIteration, batchJurorNumber));



            // Compute a random active balance to be searched in the jurors tree using the generated seed within the

            // boundaries computed for the current batch.

            balances[batchJurorNumber] = _lowBatchBound.add(uint256(seed) % interval);



            // Make sure it's ordered, flip values if necessary

            for (uint256 i = batchJurorNumber; i > 0 && balances[i] < balances[i - 1]; i--) {

                uint256 tmp = balances[i - 1];

                balances[i - 1] = balances[i];

                balances[i] = tmp;

            }

        }

        return balances;

    }

}



// File: @aragon/court/contracts/standards/ERC900.sol



pragma solidity ^0.5.8;





// Interface for ERC900: https://eips.ethereum.org/EIPS/eip-900

interface ERC900 {

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);

    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);



    /**

    * @dev Stake a certain amount of tokens

    * @param _amount Amount of tokens to be staked

    * @param _data Optional data that can be used to add signalling information in more complex staking applications

    */

    function stake(uint256 _amount, bytes calldata _data) external;



    /**

    * @dev Stake a certain amount of tokens in favor of someone

    * @param _user Address to stake an amount of tokens to

    * @param _amount Amount of tokens to be staked

    * @param _data Optional data that can be used to add signalling information in more complex staking applications

    */

    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;



    /**

    * @dev Unstake a certain amount of tokens

    * @param _amount Amount of tokens to be unstaked

    * @param _data Optional data that can be used to add signalling information in more complex staking applications

    */

    function unstake(uint256 _amount, bytes calldata _data) external;



    /**

    * @dev Tell the total amount of tokens staked for an address

    * @param _addr Address querying the total amount of tokens staked for

    * @return Total amount of tokens staked for an address

    */

    function totalStakedFor(address _addr) external view returns (uint256);



    /**

    * @dev Tell the total amount of tokens staked

    * @return Total amount of tokens staked

    */

    function totalStaked() external view returns (uint256);



    /**

    * @dev Tell the address of the token used for staking

    * @return Address of the token used for staking

    */

    function token() external view returns (address);



    /*

    * @dev Tell if the current registry supports historic information or not

    * @return True if the optional history functions are implemented, false otherwise

    */

    function supportsHistory() external pure returns (bool);

}



// File: @aragon/court/contracts/standards/ApproveAndCall.sol



pragma solidity ^0.5.8;





interface ApproveAndCallFallBack {

    /**

    * @dev This allows users to use their tokens to interact with contracts in one function call instead of two

    * @param _from Address of the account transferring the tokens

    * @param _amount The amount of tokens approved for in the transfer

    * @param _token Address of the token contract calling this function

    * @param _data Optional data that can be used to add signalling information in more complex staking applications

    */

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external;

}



// File: @aragon/court/contracts/lib/os/IsContract.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/IsContract.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity ^0.5.8;





contract IsContract {

    /*

    * NOTE: this should NEVER be used for authentication

    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).

    *

    * This is only intended to be used as a sanity check that an address is actually a contract,

    * RATHER THAN an address not being a contract.

    */

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {

            return false;

        }



        uint256 size;

        assembly { size := extcodesize(_target) }

        return size > 0;

    }

}



// File: @aragon/court/contracts/lib/os/SafeMath64.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/math/SafeMath64.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity ^0.5.8;





/**

 * @title SafeMath64

 * @dev Math operations for uint64 with safety checks that revert on error

 */

library SafeMath64 {

    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";

    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";

    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";

    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint256 c = uint256(_a) * uint256(_b);

        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW); // 2**64 (less gas this way)



        return uint64(c);

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0

        uint64 c = _a / _b;

        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);

        uint64 c = _a - _b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint64 c = _a + _b;

        require(c >= _a, ERROR_ADD_OVERFLOW);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, ERROR_DIV_ZERO);

        return a % b;

    }

}



// File: @aragon/court/contracts/lib/os/Uint256Helpers.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Uint256Helpers.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity ^0.5.8;





library Uint256Helpers {

    uint256 private constant MAX_UINT8 = uint8(-1);

    uint256 private constant MAX_UINT64 = uint64(-1);



    string private constant ERROR_UINT8_NUMBER_TOO_BIG = "UINT8_NUMBER_TOO_BIG";

    string private constant ERROR_UINT64_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";



    function toUint8(uint256 a) internal pure returns (uint8) {

        require(a <= MAX_UINT8, ERROR_UINT8_NUMBER_TOO_BIG);

        return uint8(a);

    }



    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_UINT64_NUMBER_TOO_BIG);

        return uint64(a);

    }

}



// File: @aragon/court/contracts/lib/os/TimeHelpers.sol



// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/TimeHelpers.sol

// Adapted to use pragma ^0.5.8 and satisfy our linter rules



pragma solidity ^0.5.8;







contract TimeHelpers {

    using Uint256Helpers for uint256;



    /**

    * @dev Returns the current block number.

    *      Using a function rather than `block.number` allows us to easily mock the block number in

    *      tests.

    */

    function getBlockNumber() internal view returns (uint256) {

        return block.number;

    }



    /**

    * @dev Returns the current block number, converted to uint64.

    *      Using a function rather than `block.number` allows us to easily mock the block number in

    *      tests.

    */

    function getBlockNumber64() internal view returns (uint64) {

        return getBlockNumber().toUint64();

    }



    /**

    * @dev Returns the current timestamp.

    *      Using a function rather than `block.timestamp` allows us to easily mock it in

    *      tests.

    */

    function getTimestamp() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members

    }



    /**

    * @dev Returns the current timestamp, converted to uint64.

    *      Using a function rather than `block.timestamp` allows us to easily mock it in

    *      tests.

    */

    function getTimestamp64() internal view returns (uint64) {

        return getTimestamp().toUint64();

    }

}



// File: @aragon/court/contracts/court/clock/IClock.sol



pragma solidity ^0.5.8;





interface IClock {

    /**

    * @dev Ensure that the current term of the clock is up-to-date

    * @return Identification number of the current term

    */

    function ensureCurrentTerm() external returns (uint64);



    /**

    * @dev Transition up to a certain number of terms to leave the clock up-to-date

    * @param _maxRequestedTransitions Max number of term transitions allowed by the sender

    * @return Identification number of the term ID after executing the heartbeat transitions

    */

    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64);



    /**

    * @dev Ensure that a certain term has its randomness set

    * @return Randomness of the current term

    */

    function ensureCurrentTermRandomness() external returns (bytes32);



    /**

    * @dev Tell the last ensured term identification number

    * @return Identification number of the last ensured term

    */

    function getLastEnsuredTermId() external view returns (uint64);



    /**

    * @dev Tell the current term identification number. Note that there may be pending term transitions.

    * @return Identification number of the current term

    */

    function getCurrentTermId() external view returns (uint64);



    /**

    * @dev Tell the number of terms the clock should transition to be up-to-date

    * @return Number of terms the clock should transition to be up-to-date

    */

    function getNeededTermTransitions() external view returns (uint64);



    /**

    * @dev Tell the information related to a term based on its ID

    * @param _termId ID of the term being queried

    * @return startTime Term start time

    * @return randomnessBN Block number used for randomness in the requested term

    * @return randomness Randomness computed for the requested term

    */

    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness);



    /**

    * @dev Tell the randomness of a term even if it wasn't computed yet

    * @param _termId Identification number of the term being queried

    * @return Randomness of the requested term

    */

    function getTermRandomness(uint64 _termId) external view returns (bytes32);

}



// File: @aragon/court/contracts/court/clock/CourtClock.sol



pragma solidity ^0.5.8;











contract CourtClock is IClock, TimeHelpers {

    using SafeMath64 for uint64;



    string private constant ERROR_TERM_DOES_NOT_EXIST = "CLK_TERM_DOES_NOT_EXIST";

    string private constant ERROR_TERM_DURATION_TOO_LONG = "CLK_TERM_DURATION_TOO_LONG";

    string private constant ERROR_TERM_RANDOMNESS_NOT_YET = "CLK_TERM_RANDOMNESS_NOT_YET";

    string private constant ERROR_TERM_RANDOMNESS_UNAVAILABLE = "CLK_TERM_RANDOMNESS_UNAVAILABLE";

    string private constant ERROR_BAD_FIRST_TERM_START_TIME = "CLK_BAD_FIRST_TERM_START_TIME";

    string private constant ERROR_TOO_MANY_TRANSITIONS = "CLK_TOO_MANY_TRANSITIONS";

    string private constant ERROR_INVALID_TRANSITION_TERMS = "CLK_INVALID_TRANSITION_TERMS";

    string private constant ERROR_CANNOT_DELAY_STARTED_COURT = "CLK_CANNOT_DELAY_STARTED_COURT";

    string private constant ERROR_CANNOT_DELAY_PAST_START_TIME = "CLK_CANNOT_DELAY_PAST_START_TIME";



    // Maximum number of term transitions a callee may have to assume in order to call certain functions that require the Court being up-to-date

    uint64 internal constant MAX_AUTO_TERM_TRANSITIONS_ALLOWED = 1;



    // Max duration in seconds that a term can last

    uint64 internal constant MAX_TERM_DURATION = 365 days;



    // Max time until first term starts since contract is deployed

    uint64 internal constant MAX_FIRST_TERM_DELAY_PERIOD = 2 * MAX_TERM_DURATION;



    struct Term {

        uint64 startTime;              // Timestamp when the term started

        uint64 randomnessBN;           // Block number for entropy

        bytes32 randomness;            // Entropy from randomnessBN block hash

    }



    // Duration in seconds for each term of the Court

    uint64 private termDuration;



    // Last ensured term id

    uint64 private termId;



    // List of Court terms indexed by id

    mapping (uint64 => Term) private terms;



    event Heartbeat(uint64 previousTermId, uint64 currentTermId);

    event StartTimeDelayed(uint64 previousStartTime, uint64 currentStartTime);



    /**

    * @dev Ensure a certain term has already been processed

    * @param _termId Identification number of the term to be checked

    */

    modifier termExists(uint64 _termId) {

        require(_termId <= termId, ERROR_TERM_DOES_NOT_EXIST);

        _;

    }



    /**

    * @dev Constructor function

    * @param _termParams Array containing:

    *        0. _termDuration Duration in seconds per term

    *        1. _firstTermStartTime Timestamp in seconds when the court will open (to give time for juror on-boarding)

    */

    constructor(uint64[2] memory _termParams) public {

        uint64 _termDuration = _termParams[0];

        uint64 _firstTermStartTime = _termParams[1];



        require(_termDuration < MAX_TERM_DURATION, ERROR_TERM_DURATION_TOO_LONG);

        require(_firstTermStartTime >= getTimestamp64() + _termDuration, ERROR_BAD_FIRST_TERM_START_TIME);

        require(_firstTermStartTime <= getTimestamp64() + MAX_FIRST_TERM_DELAY_PERIOD, ERROR_BAD_FIRST_TERM_START_TIME);



        termDuration = _termDuration;



        // No need for SafeMath: we already checked values above

        terms[0].startTime = _firstTermStartTime - _termDuration;

    }



    /**

    * @notice Ensure that the current term of the Court is up-to-date. If the Court is outdated by more than `MAX_AUTO_TERM_TRANSITIONS_ALLOWED`

    *         terms, the heartbeat function must be called manually instead.

    * @return Identification number of the current term

    */

    function ensureCurrentTerm() external returns (uint64) {

        return _ensureCurrentTerm();

    }



    /**

    * @notice Transition up to `_maxRequestedTransitions` terms

    * @param _maxRequestedTransitions Max number of term transitions allowed by the sender

    * @return Identification number of the term ID after executing the heartbeat transitions

    */

    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64) {

        return _heartbeat(_maxRequestedTransitions);

    }



    /**

    * @notice Ensure that a certain term has its randomness set. As we allow to draft disputes requested for previous terms, if there

    *      were mined more than 256 blocks for the current term, the blockhash of its randomness BN is no longer available, given

    *      round will be able to be drafted in the following term.

    * @return Randomness of the current term

    */

    function ensureCurrentTermRandomness() external returns (bytes32) {

        // If the randomness for the given term was already computed, return

        uint64 currentTermId = termId;

        Term storage term = terms[currentTermId];

        bytes32 termRandomness = term.randomness;

        if (termRandomness != bytes32(0)) {

            return termRandomness;

        }



        // Compute term randomness

        bytes32 newRandomness = _computeTermRandomness(currentTermId);

        require(newRandomness != bytes32(0), ERROR_TERM_RANDOMNESS_UNAVAILABLE);

        term.randomness = newRandomness;

        return newRandomness;

    }



    /**

    * @dev Tell the term duration of the Court

    * @return Duration in seconds of the Court term

    */

    function getTermDuration() external view returns (uint64) {

        return termDuration;

    }



    /**

    * @dev Tell the last ensured term identification number

    * @return Identification number of the last ensured term

    */

    function getLastEnsuredTermId() external view returns (uint64) {

        return _lastEnsuredTermId();

    }



    /**

    * @dev Tell the current term identification number. Note that there may be pending term transitions.

    * @return Identification number of the current term

    */

    function getCurrentTermId() external view returns (uint64) {

        return _currentTermId();

    }



    /**

    * @dev Tell the number of terms the Court should transition to be up-to-date

    * @return Number of terms the Court should transition to be up-to-date

    */

    function getNeededTermTransitions() external view returns (uint64) {

        return _neededTermTransitions();

    }



    /**

    * @dev Tell the information related to a term based on its ID. Note that if the term has not been reached, the

    *      information returned won't be computed yet. This function allows querying future terms that were not computed yet.

    * @param _termId ID of the term being queried

    * @return startTime Term start time

    * @return randomnessBN Block number used for randomness in the requested term

    * @return randomness Randomness computed for the requested term

    */

    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness) {

        Term storage term = terms[_termId];

        return (term.startTime, term.randomnessBN, term.randomness);

    }



    /**

    * @dev Tell the randomness of a term even if it wasn't computed yet

    * @param _termId Identification number of the term being queried

    * @return Randomness of the requested term

    */

    function getTermRandomness(uint64 _termId) external view termExists(_termId) returns (bytes32) {

        return _computeTermRandomness(_termId);

    }



    /**

    * @dev Internal function to ensure that the current term of the Court is up-to-date. If the Court is outdated by more than

    *      `MAX_AUTO_TERM_TRANSITIONS_ALLOWED` terms, the heartbeat function must be called manually.

    * @return Identification number of the resultant term ID after executing the corresponding transitions

    */

    function _ensureCurrentTerm() internal returns (uint64) {

        // Check the required number of transitions does not exceeds the max allowed number to be processed automatically

        uint64 requiredTransitions = _neededTermTransitions();

        require(requiredTransitions <= MAX_AUTO_TERM_TRANSITIONS_ALLOWED, ERROR_TOO_MANY_TRANSITIONS);



        // If there are no transitions pending, return the last ensured term id

        if (uint256(requiredTransitions) == 0) {

            return termId;

        }



        // Process transition if there is at least one pending

        return _heartbeat(requiredTransitions);

    }



    /**

    * @dev Internal function to transition the Court terms up to a requested number of terms

    * @param _maxRequestedTransitions Max number of term transitions allowed by the sender

    * @return Identification number of the resultant term ID after executing the requested transitions

    */

    function _heartbeat(uint64 _maxRequestedTransitions) internal returns (uint64) {

        // Transition the minimum number of terms between the amount requested and the amount actually needed

        uint64 neededTransitions = _neededTermTransitions();

        uint256 transitions = uint256(_maxRequestedTransitions < neededTransitions ? _maxRequestedTransitions : neededTransitions);

        require(transitions > 0, ERROR_INVALID_TRANSITION_TERMS);



        uint64 blockNumber = getBlockNumber64();

        uint64 previousTermId = termId;

        uint64 currentTermId = previousTermId;

        for (uint256 transition = 1; transition <= transitions; transition++) {

            // Term IDs are incremented by one based on the number of time periods since the Court started. Since time is represented in uint64,

            // even if we chose the minimum duration possible for a term (1 second), we can ensure terms will never reach 2^64 since time is

            // already assumed to fit in uint64.

            Term storage previousTerm = terms[currentTermId++];

            Term storage currentTerm = terms[currentTermId];

            _onTermTransitioned(currentTermId);



            // Set the start time of the new term. Note that we are using a constant term duration value to guarantee

            // equally long terms, regardless of heartbeats.

            currentTerm.startTime = previousTerm.startTime.add(termDuration);



            // In order to draft a random number of jurors in a term, we use a randomness factor for each term based on a

            // block number that is set once the term has started. Note that this information could not be known beforehand.

            currentTerm.randomnessBN = blockNumber + 1;

        }



        termId = currentTermId;

        emit Heartbeat(previousTermId, currentTermId);

        return currentTermId;

    }



    /**

    * @dev Internal function to delay the first term start time only if it wasn't reached yet

    * @param _newFirstTermStartTime New timestamp in seconds when the court will open

    */

    function _delayStartTime(uint64 _newFirstTermStartTime) internal {

        require(_currentTermId() == 0, ERROR_CANNOT_DELAY_STARTED_COURT);



        Term storage term = terms[0];

        uint64 currentFirstTermStartTime = term.startTime.add(termDuration);

        require(_newFirstTermStartTime > currentFirstTermStartTime, ERROR_CANNOT_DELAY_PAST_START_TIME);



        // No need for SafeMath: we already checked above that `_newFirstTermStartTime` > `currentFirstTermStartTime` >= `termDuration`

        term.startTime = _newFirstTermStartTime - termDuration;

        emit StartTimeDelayed(currentFirstTermStartTime, _newFirstTermStartTime);

    }



    /**

    * @dev Internal function to notify when a term has been transitioned. This function must be overridden to provide custom behavior.

    * @param _termId Identification number of the new current term that has been transitioned

    */

    function _onTermTransitioned(uint64 _termId) internal;



    /**

    * @dev Internal function to tell the last ensured term identification number

    * @return Identification number of the last ensured term

    */

    function _lastEnsuredTermId() internal view returns (uint64) {

        return termId;

    }



    /**

    * @dev Internal function to tell the current term identification number. Note that there may be pending term transitions.

    * @return Identification number of the current term

    */

    function _currentTermId() internal view returns (uint64) {

        return termId.add(_neededTermTransitions());

    }



    /**

    * @dev Internal function to tell the number of terms the Court should transition to be up-to-date

    * @return Number of terms the Court should transition to be up-to-date

    */

    function _neededTermTransitions() internal view returns (uint64) {

        // Note that the Court is always initialized providing a start time for the first-term in the future. If that's the case,

        // no term transitions are required.

        uint64 currentTermStartTime = terms[termId].startTime;

        if (getTimestamp64() < currentTermStartTime) {

            return uint64(0);

        }



        // No need for SafeMath: we already know that the start time of the current term is in the past

        return (getTimestamp64() - currentTermStartTime) / termDuration;

    }



    /**

    * @dev Internal function to compute the randomness that will be used to draft jurors for the given term. This

    *      function assumes the given term exists. To determine the randomness factor for a term we use the hash of a

    *      block number that is set once the term has started to ensure it cannot be known beforehand. Note that the

    *      hash function being used only works for the 256 most recent block numbers.

    * @param _termId Identification number of the term being queried

    * @return Randomness computed for the given term

    */

    function _computeTermRandomness(uint64 _termId) internal view returns (bytes32) {

        Term storage term = terms[_termId];

        require(getBlockNumber64() > term.randomnessBN, ERROR_TERM_RANDOMNESS_NOT_YET);

        return blockhash(term.randomnessBN);

    }

}



// File: @aragon/court/contracts/court/config/IConfig.sol



pragma solidity ^0.5.8;







interface IConfig {



    /**

    * @dev Tell the full Court configuration parameters at a certain term

    * @param _termId Identification number of the term querying the Court config of

    * @return token Address of the token used to pay for fees

    * @return fees Array containing:

    *         0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *         1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *         2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *         0. evidenceTerms Max submitting evidence period duration in terms

    *         1. commitTerms Commit period duration in terms

    *         2. revealTerms Reveal period duration in terms

    *         3. appealTerms Appeal period duration in terms

    *         4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @return pcts Array containing:

    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @return roundParams Array containing params for rounds:

    *         0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *         1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    * @return appealCollateralParams Array containing params for appeal collateral:

    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling

    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal

    * @return minActiveBalance Minimum amount of tokens jurors have to activate to participate in the Court

    */

    function getConfig(uint64 _termId) external view

        returns (

            ERC20 feeToken,

            uint256[3] memory fees,

            uint64[5] memory roundStateDurations,

            uint16[2] memory pcts,

            uint64[4] memory roundParams,

            uint256[2] memory appealCollateralParams,

            uint256 minActiveBalance

        );



    /**

    * @dev Tell the draft config at a certain term

    * @param _termId Identification number of the term querying the draft config of

    * @return feeToken Address of the token used to pay for fees

    * @return draftFee Amount of fee tokens per juror to cover the drafting cost

    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    */

    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct);



    /**

    * @dev Tell the min active balance config at a certain term

    * @param _termId Term querying the min active balance config of

    * @return Minimum amount of tokens jurors have to activate to participate in the Court

    */

    function getMinActiveBalance(uint64 _termId) external view returns (uint256);



    /**

    * @dev Tell whether a certain holder accepts automatic withdrawals of tokens or not

    * @return True if the given holder accepts automatic withdrawals of their tokens, false otherwise

    */

    function areWithdrawalsAllowedFor(address _holder) external view returns (bool);

}



// File: @aragon/court/contracts/court/config/CourtConfigData.sol



pragma solidity ^0.5.8;







contract CourtConfigData {

    struct Config {

        FeesConfig fees;                        // Full fees-related config

        DisputesConfig disputes;                // Full disputes-related config

        uint256 minActiveBalance;               // Minimum amount of tokens jurors have to activate to participate in the Court

    }



    struct FeesConfig {

        ERC20 token;                            // ERC20 token to be used for the fees of the Court

        uint16 finalRoundReduction;             // Permyriad of fees reduction applied for final appeal round (‱ - 1/10,000)

        uint256 jurorFee;                       // Amount of tokens paid to draft a juror to adjudicate a dispute

        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors

        uint256 settleFee;                      // Amount of tokens paid per round to cover the costs of slashing jurors

    }



    struct DisputesConfig {

        uint64 evidenceTerms;                   // Max submitting evidence period duration in terms

        uint64 commitTerms;                     // Committing period duration in terms

        uint64 revealTerms;                     // Revealing period duration in terms

        uint64 appealTerms;                     // Appealing period duration in terms

        uint64 appealConfirmTerms;              // Confirmation appeal period duration in terms

        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

        uint64 firstRoundJurorsNumber;          // Number of jurors drafted on first round

        uint64 appealStepFactor;                // Factor in which the jurors number is increased on each appeal

        uint64 finalRoundLockTerms;             // Period a coherent juror in the final round will remain locked

        uint256 maxRegularAppealRounds;         // Before the final appeal

        uint256 appealCollateralFactor;         // Permyriad multiple of dispute fees required to appeal a preliminary ruling (‱ - 1/10,000)

        uint256 appealConfirmCollateralFactor;  // Permyriad multiple of dispute fees required to confirm appeal (‱ - 1/10,000)

    }



    struct DraftConfig {

        ERC20 feeToken;                         // ERC20 token to be used for the fees of the Court

        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors

    }

}



// File: @aragon/court/contracts/court/config/CourtConfig.sol



pragma solidity ^0.5.8;















contract CourtConfig is IConfig, CourtConfigData {

    using SafeMath64 for uint64;

    using PctHelpers for uint256;



    string private constant ERROR_TOO_OLD_TERM = "CONF_TOO_OLD_TERM";

    string private constant ERROR_INVALID_PENALTY_PCT = "CONF_INVALID_PENALTY_PCT";

    string private constant ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT = "CONF_INVALID_FINAL_ROUND_RED_PCT";

    string private constant ERROR_INVALID_MAX_APPEAL_ROUNDS = "CONF_INVALID_MAX_APPEAL_ROUNDS";

    string private constant ERROR_LARGE_ROUND_PHASE_DURATION = "CONF_LARGE_ROUND_PHASE_DURATION";

    string private constant ERROR_BAD_INITIAL_JURORS_NUMBER = "CONF_BAD_INITIAL_JURORS_NUMBER";

    string private constant ERROR_BAD_APPEAL_STEP_FACTOR = "CONF_BAD_APPEAL_STEP_FACTOR";

    string private constant ERROR_ZERO_COLLATERAL_FACTOR = "CONF_ZERO_COLLATERAL_FACTOR";

    string private constant ERROR_ZERO_MIN_ACTIVE_BALANCE = "CONF_ZERO_MIN_ACTIVE_BALANCE";



    // Max number of terms that each of the different adjudication states can last (if lasted 1h, this would be a year)

    uint64 internal constant MAX_ADJ_STATE_DURATION = 8670;



    // Cap the max number of regular appeal rounds

    uint256 internal constant MAX_REGULAR_APPEAL_ROUNDS_LIMIT = 10;



    // Future term ID in which a config change has been scheduled

    uint64 private configChangeTermId;



    // List of all the configs used in the Court

    Config[] private configs;



    // List of configs indexed by id

    mapping (uint64 => uint256) private configIdByTerm;



    // Holders opt-in config for automatic withdrawals

    mapping (address => bool) private withdrawalsAllowed;



    event NewConfig(uint64 fromTermId, uint64 courtConfigId);

    event AutomaticWithdrawalsAllowedChanged(address indexed holder, bool allowed);



    /**

    * @dev Constructor function

    * @param _feeToken Address of the token contract that is used to pay for fees

    * @param _fees Array containing:

    *        0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *        1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *        2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *        0. evidenceTerms Max submitting evidence period duration in terms

    *        1. commitTerms Commit period duration in terms

    *        2. revealTerms Reveal period duration in terms

    *        3. appealTerms Appeal period duration in terms

    *        4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @param _pcts Array containing:

    *        0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @param _roundParams Array containing params for rounds:

    *        0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *        1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    *        3. finalRoundLockTerms Number of terms that a coherent juror in a final round is disallowed to withdraw (to prevent 51% attacks)

    * @param _appealCollateralParams Array containing params for appeal collateral:

    *        0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling

    *        1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal

    * @param _minActiveBalance Minimum amount of juror tokens that can be activated

    */

    constructor(

        ERC20 _feeToken,

        uint256[3] memory _fees,

        uint64[5] memory _roundStateDurations,

        uint16[2] memory _pcts,

        uint64[4] memory _roundParams,

        uint256[2] memory _appealCollateralParams,

        uint256 _minActiveBalance

    )

        public

    {

        // Leave config at index 0 empty for non-scheduled config changes

        configs.length = 1;

        _setConfig(

            0,

            0,

            _feeToken,

            _fees,

            _roundStateDurations,

            _pcts,

            _roundParams,

            _appealCollateralParams,

            _minActiveBalance

        );

    }



    /**

    * @notice Set the automatic withdrawals config for the sender to `_allowed`

    * @param _allowed Whether or not the automatic withdrawals are allowed by the sender

    */

    function setAutomaticWithdrawals(bool _allowed) external {

        withdrawalsAllowed[msg.sender] = _allowed;

        emit AutomaticWithdrawalsAllowedChanged(msg.sender, _allowed);

    }



    /**

    * @dev Tell the full Court configuration parameters at a certain term

    * @param _termId Identification number of the term querying the Court config of

    * @return token Address of the token used to pay for fees

    * @return fees Array containing:

    *         0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *         1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *         2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *         0. evidenceTerms Max submitting evidence period duration in terms

    *         1. commitTerms Commit period duration in terms

    *         2. revealTerms Reveal period duration in terms

    *         3. appealTerms Appeal period duration in terms

    *         4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @return pcts Array containing:

    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @return roundParams Array containing params for rounds:

    *         0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *         1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    * @return appealCollateralParams Array containing params for appeal collateral:

    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling

    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal

    * @return minActiveBalance Minimum amount of tokens jurors have to activate to participate in the Court

    */

    function getConfig(uint64 _termId) external view

        returns (

            ERC20 feeToken,

            uint256[3] memory fees,

            uint64[5] memory roundStateDurations,

            uint16[2] memory pcts,

            uint64[4] memory roundParams,

            uint256[2] memory appealCollateralParams,

            uint256 minActiveBalance

        );



    /**

    * @dev Tell the draft config at a certain term

    * @param _termId Identification number of the term querying the draft config of

    * @return feeToken Address of the token used to pay for fees

    * @return draftFee Amount of fee tokens per juror to cover the drafting cost

    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    */

    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct);



    /**

    * @dev Tell the min active balance config at a certain term

    * @param _termId Term querying the min active balance config of

    * @return Minimum amount of tokens jurors have to activate to participate in the Court

    */

    function getMinActiveBalance(uint64 _termId) external view returns (uint256);



    /**

    * @dev Tell whether a certain holder accepts automatic withdrawals of tokens or not

    * @param _holder Address of the token holder querying if withdrawals are allowed for

    * @return True if the given holder accepts automatic withdrawals of their tokens, false otherwise

    */

    function areWithdrawalsAllowedFor(address _holder) external view returns (bool) {

        return withdrawalsAllowed[_holder];

    }



    /**

    * @dev Tell the term identification number of the next scheduled config change

    * @return Term identification number of the next scheduled config change

    */

    function getConfigChangeTermId() external view returns (uint64) {

        return configChangeTermId;

    }



    /**

    * @dev Internal to make sure to set a config for the new term, it will copy the previous term config if none

    * @param _termId Identification number of the new current term that has been transitioned

    */

    function _ensureTermConfig(uint64 _termId) internal {

        // If the term being transitioned had no config change scheduled, keep the previous one

        uint256 currentConfigId = configIdByTerm[_termId];

        if (currentConfigId == 0) {

            uint256 previousConfigId = configIdByTerm[_termId.sub(1)];

            configIdByTerm[_termId] = previousConfigId;

        }

    }



    /**

    * @dev Assumes that sender it's allowed (either it's from governor or it's on init)

    * @param _termId Identification number of the current Court term

    * @param _fromTermId Identification number of the term in which the config will be effective at

    * @param _feeToken Address of the token contract that is used to pay for fees.

    * @param _fees Array containing:

    *        0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *        1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *        2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *        0. evidenceTerms Max submitting evidence period duration in terms

    *        1. commitTerms Commit period duration in terms

    *        2. revealTerms Reveal period duration in terms

    *        3. appealTerms Appeal period duration in terms

    *        4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @param _pcts Array containing:

    *        0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @param _roundParams Array containing params for rounds:

    *        0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *        1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    *        3. finalRoundLockTerms Number of terms that a coherent juror in a final round is disallowed to withdraw (to prevent 51% attacks)

    * @param _appealCollateralParams Array containing params for appeal collateral:

    *        0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling

    *        1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal

    * @param _minActiveBalance Minimum amount of juror tokens that can be activated

    */

    function _setConfig(

        uint64 _termId,

        uint64 _fromTermId,

        ERC20 _feeToken,

        uint256[3] memory _fees,

        uint64[5] memory _roundStateDurations,

        uint16[2] memory _pcts,

        uint64[4] memory _roundParams,

        uint256[2] memory _appealCollateralParams,

        uint256 _minActiveBalance

    )

        internal

    {

        // If the current term is not zero, changes must be scheduled at least after the current period.

        // No need to ensure delays for on-going disputes since these already use their creation term for that.

        require(_termId == 0 || _fromTermId > _termId, ERROR_TOO_OLD_TERM);



        // Make sure appeal collateral factors are greater than zero

        require(_appealCollateralParams[0] > 0 && _appealCollateralParams[1] > 0, ERROR_ZERO_COLLATERAL_FACTOR);



        // Make sure the given penalty and final round reduction pcts are not greater than 100%

        require(PctHelpers.isValid(_pcts[0]), ERROR_INVALID_PENALTY_PCT);

        require(PctHelpers.isValid(_pcts[1]), ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT);



        // Disputes must request at least one juror to be drafted initially

        require(_roundParams[0] > 0, ERROR_BAD_INITIAL_JURORS_NUMBER);



        // Prevent that further rounds have zero jurors

        require(_roundParams[1] > 0, ERROR_BAD_APPEAL_STEP_FACTOR);



        // Make sure the max number of appeals allowed does not reach the limit

        uint256 _maxRegularAppealRounds = _roundParams[2];

        bool isMaxAppealRoundsValid = _maxRegularAppealRounds > 0 && _maxRegularAppealRounds <= MAX_REGULAR_APPEAL_ROUNDS_LIMIT;

        require(isMaxAppealRoundsValid, ERROR_INVALID_MAX_APPEAL_ROUNDS);



        // Make sure each adjudication round phase duration is valid

        for (uint i = 0; i < _roundStateDurations.length; i++) {

            require(_roundStateDurations[i] > 0 && _roundStateDurations[i] < MAX_ADJ_STATE_DURATION, ERROR_LARGE_ROUND_PHASE_DURATION);

        }



        // Make sure min active balance is not zero

        require(_minActiveBalance > 0, ERROR_ZERO_MIN_ACTIVE_BALANCE);



        // If there was a config change already scheduled, reset it (in that case we will overwrite last array item).

        // Otherwise, schedule a new config.

        if (configChangeTermId > _termId) {

            configIdByTerm[configChangeTermId] = 0;

        } else {

            configs.length++;

        }



        uint64 courtConfigId = uint64(configs.length - 1);

        Config storage config = configs[courtConfigId];



        config.fees = FeesConfig({

            token: _feeToken,

            jurorFee: _fees[0],

            draftFee: _fees[1],

            settleFee: _fees[2],

            finalRoundReduction: _pcts[1]

        });



        config.disputes = DisputesConfig({

            evidenceTerms: _roundStateDurations[0],

            commitTerms: _roundStateDurations[1],

            revealTerms: _roundStateDurations[2],

            appealTerms: _roundStateDurations[3],

            appealConfirmTerms: _roundStateDurations[4],

            penaltyPct: _pcts[0],

            firstRoundJurorsNumber: _roundParams[0],

            appealStepFactor: _roundParams[1],

            maxRegularAppealRounds: _maxRegularAppealRounds,

            finalRoundLockTerms: _roundParams[3],

            appealCollateralFactor: _appealCollateralParams[0],

            appealConfirmCollateralFactor: _appealCollateralParams[1]

        });



        config.minActiveBalance = _minActiveBalance;



        configIdByTerm[_fromTermId] = courtConfigId;

        configChangeTermId = _fromTermId;



        emit NewConfig(_fromTermId, courtConfigId);

    }



    /**

    * @dev Internal function to get the Court config for a given term

    * @param _termId Identification number of the term querying the Court config of

    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court

    * @return token Address of the token used to pay for fees

    * @return fees Array containing:

    *         0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *         1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *         2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *         0. evidenceTerms Max submitting evidence period duration in terms

    *         1. commitTerms Commit period duration in terms

    *         2. revealTerms Reveal period duration in terms

    *         3. appealTerms Appeal period duration in terms

    *         4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @return pcts Array containing:

    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @return roundParams Array containing params for rounds:

    *         0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *         1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    *         3. finalRoundLockTerms Number of terms that a coherent juror in a final round is disallowed to withdraw (to prevent 51% attacks)

    * @return appealCollateralParams Array containing params for appeal collateral:

    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling

    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal

    * @return minActiveBalance Minimum amount of juror tokens that can be activated

    */

    function _getConfigAt(uint64 _termId, uint64 _lastEnsuredTermId) internal view

        returns (

            ERC20 feeToken,

            uint256[3] memory fees,

            uint64[5] memory roundStateDurations,

            uint16[2] memory pcts,

            uint64[4] memory roundParams,

            uint256[2] memory appealCollateralParams,

            uint256 minActiveBalance

        )

    {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);



        FeesConfig storage feesConfig = config.fees;

        feeToken = feesConfig.token;

        fees = [feesConfig.jurorFee, feesConfig.draftFee, feesConfig.settleFee];



        DisputesConfig storage disputesConfig = config.disputes;

        roundStateDurations = [

            disputesConfig.evidenceTerms,

            disputesConfig.commitTerms,

            disputesConfig.revealTerms,

            disputesConfig.appealTerms,

            disputesConfig.appealConfirmTerms

        ];

        pcts = [disputesConfig.penaltyPct, feesConfig.finalRoundReduction];

        roundParams = [

            disputesConfig.firstRoundJurorsNumber,

            disputesConfig.appealStepFactor,

            uint64(disputesConfig.maxRegularAppealRounds),

            disputesConfig.finalRoundLockTerms

        ];

        appealCollateralParams = [disputesConfig.appealCollateralFactor, disputesConfig.appealConfirmCollateralFactor];



        minActiveBalance = config.minActiveBalance;

    }



    /**

    * @dev Tell the draft config at a certain term

    * @param _termId Identification number of the term querying the draft config of

    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court

    * @return feeToken Address of the token used to pay for fees

    * @return draftFee Amount of fee tokens per juror to cover the drafting cost

    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    */

    function _getDraftConfig(uint64 _termId,  uint64 _lastEnsuredTermId) internal view

        returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct)

    {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);

        return (config.fees.token, config.fees.draftFee, config.disputes.penaltyPct);

    }



    /**

    * @dev Internal function to get the min active balance config for a given term

    * @param _termId Identification number of the term querying the min active balance config of

    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court

    * @return Minimum amount of juror tokens that can be activated at the given term

    */

    function _getMinActiveBalance(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);

        return config.minActiveBalance;

    }



    /**

    * @dev Internal function to get the Court config for a given term

    * @param _termId Identification number of the term querying the min active balance config of

    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court

    * @return Court config for the given term

    */

    function _getConfigFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (Config storage) {

        uint256 id = _getConfigIdFor(_termId, _lastEnsuredTermId);

        return configs[id];

    }



    /**

    * @dev Internal function to get the Court config ID for a given term

    * @param _termId Identification number of the term querying the Court config of

    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court

    * @return Identification number of the config for the given terms

    */

    function _getConfigIdFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {

        // If the given term is lower or equal to the last ensured Court term, it is safe to use a past Court config

        if (_termId <= _lastEnsuredTermId) {

            return configIdByTerm[_termId];

        }



        // If the given term is in the future but there is a config change scheduled before it, use the incoming config

        uint64 scheduledChangeTermId = configChangeTermId;

        if (scheduledChangeTermId <= _termId) {

            return configIdByTerm[scheduledChangeTermId];

        }



        // If no changes are scheduled, use the Court config of the last ensured term

        return configIdByTerm[_lastEnsuredTermId];

    }

}



// File: @aragon/court/contracts/court/controller/Controller.sol



pragma solidity ^0.5.8;











contract Controller is IsContract, CourtClock, CourtConfig {

    string private constant ERROR_SENDER_NOT_GOVERNOR = "CTR_SENDER_NOT_GOVERNOR";

    string private constant ERROR_INVALID_GOVERNOR_ADDRESS = "CTR_INVALID_GOVERNOR_ADDRESS";

    string private constant ERROR_IMPLEMENTATION_NOT_CONTRACT = "CTR_IMPLEMENTATION_NOT_CONTRACT";

    string private constant ERROR_INVALID_IMPLS_INPUT_LENGTH = "CTR_INVALID_IMPLS_INPUT_LENGTH";



    address private constant ZERO_ADDRESS = address(0);



    // DisputeManager module ID - keccak256(abi.encodePacked("DISPUTE_MANAGER"))

    bytes32 internal constant DISPUTE_MANAGER = 0x14a6c70f0f6d449c014c7bbc9e68e31e79e8474fb03b7194df83109a2d888ae6;



    // Treasury module ID - keccak256(abi.encodePacked("TREASURY"))

    bytes32 internal constant TREASURY = 0x06aa03964db1f7257357ef09714a5f0ca3633723df419e97015e0c7a3e83edb7;



    // Voting module ID - keccak256(abi.encodePacked("VOTING"))

    bytes32 internal constant VOTING = 0x7cbb12e82a6d63ff16fe43977f43e3e2b247ecd4e62c0e340da8800a48c67346;



    // JurorsRegistry module ID - keccak256(abi.encodePacked("JURORS_REGISTRY"))

    bytes32 internal constant JURORS_REGISTRY = 0x3b21d36b36308c830e6c4053fb40a3b6d79dde78947fbf6b0accd30720ab5370;



    // Subscriptions module ID - keccak256(abi.encodePacked("SUBSCRIPTIONS"))

    bytes32 internal constant SUBSCRIPTIONS = 0x2bfa3327fe52344390da94c32a346eeb1b65a8b583e4335a419b9471e88c1365;



    /**

    * @dev Governor of the whole system. Set of three addresses to recover funds, change configuration settings and setup modules

    */

    struct Governor {

        address funds;      // This address can be unset at any time. It is allowed to recover funds from the ControlledRecoverable modules

        address config;     // This address is meant not to be unset. It is allowed to change the different configurations of the whole system

        address modules;    // This address can be unset at any time. It is allowed to plug/unplug modules from the system

    }



    // Governor addresses of the system

    Governor private governor;



    // List of modules registered for the system indexed by ID

    mapping (bytes32 => address) internal modules;



    event ModuleSet(bytes32 id, address addr);

    event FundsGovernorChanged(address previousGovernor, address currentGovernor);

    event ConfigGovernorChanged(address previousGovernor, address currentGovernor);

    event ModulesGovernorChanged(address previousGovernor, address currentGovernor);



    /**

    * @dev Ensure the msg.sender is the funds governor

    */

    modifier onlyFundsGovernor {

        require(msg.sender == governor.funds, ERROR_SENDER_NOT_GOVERNOR);

        _;

    }



    /**

    * @dev Ensure the msg.sender is the modules governor

    */

    modifier onlyConfigGovernor {

        require(msg.sender == governor.config, ERROR_SENDER_NOT_GOVERNOR);

        _;

    }



    /**

    * @dev Ensure the msg.sender is the modules governor

    */

    modifier onlyModulesGovernor {

        require(msg.sender == governor.modules, ERROR_SENDER_NOT_GOVERNOR);

        _;

    }



    /**

    * @dev Constructor function

    * @param _termParams Array containing:

    *        0. _termDuration Duration in seconds per term

    *        1. _firstTermStartTime Timestamp in seconds when the court will open (to give time for juror on-boarding)

    * @param _governors Array containing:

    *        0. _fundsGovernor Address of the funds governor

    *        1. _configGovernor Address of the config governor

    *        2. _modulesGovernor Address of the modules governor

    * @param _feeToken Address of the token contract that is used to pay for fees

    * @param _fees Array containing:

    *        0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *        1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *        2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *        0. evidenceTerms Max submitting evidence period duration in terms

    *        1. commitTerms Commit period duration in terms

    *        2. revealTerms Reveal period duration in terms

    *        3. appealTerms Appeal period duration in terms

    *        4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @param _pcts Array containing:

    *        0. penaltyPct Permyriad of min active tokens balance to be locked to each drafted jurors (‱ - 1/10,000)

    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @param _roundParams Array containing params for rounds:

    *        0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *        1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    *        3. finalRoundLockTerms Number of terms that a coherent juror in a final round is disallowed to withdraw (to prevent 51% attacks)

    * @param _appealCollateralParams Array containing params for appeal collateral:

    *        1. appealCollateralFactor Permyriad multiple of dispute fees required to appeal a preliminary ruling

    *        2. appealConfirmCollateralFactor Permyriad multiple of dispute fees required to confirm appeal

    * @param _minActiveBalance Minimum amount of juror tokens that can be activated

    */

    constructor(

        uint64[2] memory _termParams,

        address[3] memory _governors,

        ERC20 _feeToken,

        uint256[3] memory _fees,

        uint64[5] memory _roundStateDurations,

        uint16[2] memory _pcts,

        uint64[4] memory _roundParams,

        uint256[2] memory _appealCollateralParams,

        uint256 _minActiveBalance

    )

        public

        CourtClock(_termParams)

        CourtConfig(_feeToken, _fees, _roundStateDurations, _pcts, _roundParams, _appealCollateralParams, _minActiveBalance)

    {

        _setFundsGovernor(_governors[0]);

        _setConfigGovernor(_governors[1]);

        _setModulesGovernor(_governors[2]);

    }



    /**

    * @notice Change Court configuration params

    * @param _fromTermId Identification number of the term in which the config will be effective at

    * @param _feeToken Address of the token contract that is used to pay for fees

    * @param _fees Array containing:

    *        0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *        1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *        2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *        0. evidenceTerms Max submitting evidence period duration in terms

    *        1. commitTerms Commit period duration in terms

    *        2. revealTerms Reveal period duration in terms

    *        3. appealTerms Appeal period duration in terms

    *        4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @param _pcts Array containing:

    *        0. penaltyPct Permyriad of min active tokens balance to be locked to each drafted jurors (‱ - 1/10,000)

    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @param _roundParams Array containing params for rounds:

    *        0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *        1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    *        3. finalRoundLockTerms Number of terms that a coherent juror in a final round is disallowed to withdraw (to prevent 51% attacks)

    * @param _appealCollateralParams Array containing params for appeal collateral:

    *        1. appealCollateralFactor Permyriad multiple of dispute fees required to appeal a preliminary ruling

    *        2. appealConfirmCollateralFactor Permyriad multiple of dispute fees required to confirm appeal

    * @param _minActiveBalance Minimum amount of juror tokens that can be activated

    */

    function setConfig(

        uint64 _fromTermId,

        ERC20 _feeToken,

        uint256[3] calldata _fees,

        uint64[5] calldata _roundStateDurations,

        uint16[2] calldata _pcts,

        uint64[4] calldata _roundParams,

        uint256[2] calldata _appealCollateralParams,

        uint256 _minActiveBalance

    )

        external

        onlyConfigGovernor

    {

        uint64 currentTermId = _ensureCurrentTerm();

        _setConfig(

            currentTermId,

            _fromTermId,

            _feeToken,

            _fees,

            _roundStateDurations,

            _pcts,

            _roundParams,

            _appealCollateralParams,

            _minActiveBalance

        );

    }



    /**

    * @notice Delay the Court start time to `_newFirstTermStartTime`

    * @param _newFirstTermStartTime New timestamp in seconds when the court will open

    */

    function delayStartTime(uint64 _newFirstTermStartTime) external onlyConfigGovernor {

        _delayStartTime(_newFirstTermStartTime);

    }



    /**

    * @notice Change funds governor address to `_newFundsGovernor`

    * @param _newFundsGovernor Address of the new funds governor to be set

    */

    function changeFundsGovernor(address _newFundsGovernor) external onlyFundsGovernor {

        require(_newFundsGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);

        _setFundsGovernor(_newFundsGovernor);

    }



    /**

    * @notice Change config governor address to `_newConfigGovernor`

    * @param _newConfigGovernor Address of the new config governor to be set

    */

    function changeConfigGovernor(address _newConfigGovernor) external onlyConfigGovernor {

        require(_newConfigGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);

        _setConfigGovernor(_newConfigGovernor);

    }



    /**

    * @notice Change modules governor address to `_newModulesGovernor`

    * @param _newModulesGovernor Address of the new governor to be set

    */

    function changeModulesGovernor(address _newModulesGovernor) external onlyModulesGovernor {

        require(_newModulesGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);

        _setModulesGovernor(_newModulesGovernor);

    }



    /**

    * @notice Remove the funds governor. Set the funds governor to the zero address.

    * @dev This action cannot be rolled back, once the funds governor has been unset, funds cannot be recovered from recoverable modules anymore

    */

    function ejectFundsGovernor() external onlyFundsGovernor {

        _setFundsGovernor(ZERO_ADDRESS);

    }



    /**

    * @notice Remove the modules governor. Set the modules governor to the zero address.

    * @dev This action cannot be rolled back, once the modules governor has been unset, system modules cannot be changed anymore

    */

    function ejectModulesGovernor() external onlyModulesGovernor {

        _setModulesGovernor(ZERO_ADDRESS);

    }



    /**

    * @notice Set module `_id` to `_addr`

    * @param _id ID of the module to be set

    * @param _addr Address of the module to be set

    */

    function setModule(bytes32 _id, address _addr) external onlyModulesGovernor {

        _setModule(_id, _addr);

    }



    /**

    * @notice Set many modules at once

    * @param _ids List of ids of each module to be set

    * @param _addresses List of addressed of each the module to be set

    */

    function setModules(bytes32[] calldata _ids, address[] calldata _addresses) external onlyModulesGovernor {

        require(_ids.length == _addresses.length, ERROR_INVALID_IMPLS_INPUT_LENGTH);



        for (uint256 i = 0; i < _ids.length; i++) {

            _setModule(_ids[i], _addresses[i]);

        }

    }



    /**

    * @dev Tell the full Court configuration parameters at a certain term

    * @param _termId Identification number of the term querying the Court config of

    * @return token Address of the token used to pay for fees

    * @return fees Array containing:

    *         0. jurorFee Amount of fee tokens that is paid per juror per dispute

    *         1. draftFee Amount of fee tokens per juror to cover the drafting cost

    *         2. settleFee Amount of fee tokens per juror to cover round settlement cost

    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:

    *         0. evidenceTerms Max submitting evidence period duration in terms

    *         1. commitTerms Commit period duration in terms

    *         2. revealTerms Reveal period duration in terms

    *         3. appealTerms Appeal period duration in terms

    *         4. appealConfirmationTerms Appeal confirmation period duration in terms

    * @return pcts Array containing:

    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)

    * @return roundParams Array containing params for rounds:

    *         0. firstRoundJurorsNumber Number of jurors to be drafted for the first round of disputes

    *         1. appealStepFactor Increasing factor for the number of jurors of each round of a dispute

    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered

    *         3. finalRoundLockTerms Number of terms that a coherent juror in a final round is disallowed to withdraw (to prevent 51% attacks)

    * @return appealCollateralParams Array containing params for appeal collateral:

    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling

    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal

    */

    function getConfig(uint64 _termId) external view

        returns (

            ERC20 feeToken,

            uint256[3] memory fees,

            uint64[5] memory roundStateDurations,

            uint16[2] memory pcts,

            uint64[4] memory roundParams,

            uint256[2] memory appealCollateralParams,

            uint256 minActiveBalance

        )

    {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();

        return _getConfigAt(_termId, lastEnsuredTermId);

    }



    /**

    * @dev Tell the draft config at a certain term

    * @param _termId Identification number of the term querying the draft config of

    * @return feeToken Address of the token used to pay for fees

    * @return draftFee Amount of fee tokens per juror to cover the drafting cost

    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)

    */

    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct) {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();

        return _getDraftConfig(_termId, lastEnsuredTermId);

    }



    /**

    * @dev Tell the min active balance config at a certain term

    * @param _termId Identification number of the term querying the min active balance config of

    * @return Minimum amount of tokens jurors have to activate to participate in the Court

    */

    function getMinActiveBalance(uint64 _termId) external view returns (uint256) {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();

        return _getMinActiveBalance(_termId, lastEnsuredTermId);

    }



    /**

    * @dev Tell the address of the funds governor

    * @return Address of the funds governor

    */

    function getFundsGovernor() external view returns (address) {

        return governor.funds;

    }



    /**

    * @dev Tell the address of the config governor

    * @return Address of the config governor

    */

    function getConfigGovernor() external view returns (address) {

        return governor.config;

    }



    /**

    * @dev Tell the address of the modules governor

    * @return Address of the modules governor

    */

    function getModulesGovernor() external view returns (address) {

        return governor.modules;

    }



    /**

    * @dev Tell address of a module based on a given ID

    * @param _id ID of the module being queried

    * @return Address of the requested module

    */

    function getModule(bytes32 _id) external view returns (address) {

        return _getModule(_id);

    }



    /**

    * @dev Tell the address of the DisputeManager module

    * @return Address of the DisputeManager module

    */

    function getDisputeManager() external view returns (address) {

        return _getDisputeManager();

    }



    /**

    * @dev Tell the address of the Treasury module

    * @return Address of the Treasury module

    */

    function getTreasury() external view returns (address) {

        return _getModule(TREASURY);

    }



    /**

    * @dev Tell the address of the Voting module

    * @return Address of the Voting module

    */

    function getVoting() external view returns (address) {

        return _getModule(VOTING);

    }



    /**

    * @dev Tell the address of the JurorsRegistry module

    * @return Address of the JurorsRegistry module

    */

    function getJurorsRegistry() external view returns (address) {

        return _getModule(JURORS_REGISTRY);

    }



    /**

    * @dev Tell the address of the Subscriptions module

    * @return Address of the Subscriptions module

    */

    function getSubscriptions() external view returns (address) {

        return _getSubscriptions();

    }



    /**

    * @dev Internal function to set the address of the funds governor

    * @param _newFundsGovernor Address of the new config governor to be set

    */

    function _setFundsGovernor(address _newFundsGovernor) internal {

        emit FundsGovernorChanged(governor.funds, _newFundsGovernor);

        governor.funds = _newFundsGovernor;

    }



    /**

    * @dev Internal function to set the address of the config governor

    * @param _newConfigGovernor Address of the new config governor to be set

    */

    function _setConfigGovernor(address _newConfigGovernor) internal {

        emit ConfigGovernorChanged(governor.config, _newConfigGovernor);

        governor.config = _newConfigGovernor;

    }



    /**

    * @dev Internal function to set the address of the modules governor

    * @param _newModulesGovernor Address of the new modules governor to be set

    */

    function _setModulesGovernor(address _newModulesGovernor) internal {

        emit ModulesGovernorChanged(governor.modules, _newModulesGovernor);

        governor.modules = _newModulesGovernor;

    }



    /**

    * @dev Internal function to set a module

    * @param _id Id of the module to be set

    * @param _addr Address of the module to be set

    */

    function _setModule(bytes32 _id, address _addr) internal {

        require(isContract(_addr), ERROR_IMPLEMENTATION_NOT_CONTRACT);

        modules[_id] = _addr;

        emit ModuleSet(_id, _addr);

    }



    /**

    * @dev Internal function to notify when a term has been transitioned

    * @param _termId Identification number of the new current term that has been transitioned

    */

    function _onTermTransitioned(uint64 _termId) internal {

        _ensureTermConfig(_termId);

    }



    /**

    * @dev Internal function to tell the address of the DisputeManager module

    * @return Address of the DisputeManager module

    */

    function _getDisputeManager() internal view returns (address) {

        return _getModule(DISPUTE_MANAGER);

    }



    /**

    * @dev Internal function to tell the address of the Subscriptions module

    * @return Address of the Subscriptions module

    */

    function _getSubscriptions() internal view returns (address) {

        return _getModule(SUBSCRIPTIONS);

    }



    /**

    * @dev Internal function to tell address of a module based on a given ID

    * @param _id ID of the module being queried

    * @return Address of the requested module

    */

    function _getModule(bytes32 _id) internal view returns (address) {

        return modules[_id];

    }

}



// File: @aragon/court/contracts/court/config/ConfigConsumer.sol



pragma solidity ^0.5.8;











contract ConfigConsumer is CourtConfigData {

    /**

    * @dev Internal function to fetch the address of the Config module from the controller

    * @return Address of the Config module

    */

    function _courtConfig() internal view returns (IConfig);



    /**

    * @dev Internal function to get the Court config for a certain term

    * @param _termId Identification number of the term querying the Court config of

    * @return Court config for the given term

    */

    function _getConfigAt(uint64 _termId) internal view returns (Config memory) {

        (ERC20 _feeToken,

        uint256[3] memory _fees,

        uint64[5] memory _roundStateDurations,

        uint16[2] memory _pcts,

        uint64[4] memory _roundParams,

        uint256[2] memory _appealCollateralParams,

        uint256 _minActiveBalance) = _courtConfig().getConfig(_termId);



        Config memory config;



        config.fees = FeesConfig({

            token: _feeToken,

            jurorFee: _fees[0],

            draftFee: _fees[1],

            settleFee: _fees[2],

            finalRoundReduction: _pcts[1]

        });



        config.disputes = DisputesConfig({

            evidenceTerms: _roundStateDurations[0],

            commitTerms: _roundStateDurations[1],

            revealTerms: _roundStateDurations[2],

            appealTerms: _roundStateDurations[3],

            appealConfirmTerms: _roundStateDurations[4],

            penaltyPct: _pcts[0],

            firstRoundJurorsNumber: _roundParams[0],

            appealStepFactor: _roundParams[1],

            maxRegularAppealRounds: _roundParams[2],

            finalRoundLockTerms: _roundParams[3],

            appealCollateralFactor: _appealCollateralParams[0],

            appealConfirmCollateralFactor: _appealCollateralParams[1]

        });



        config.minActiveBalance = _minActiveBalance;



        return config;

    }



    /**

    * @dev Internal function to get the draft config for a given term

    * @param _termId Identification number of the term querying the draft config of

    * @return Draft config for the given term

    */

    function _getDraftConfig(uint64 _termId) internal view returns (DraftConfig memory) {

        (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct) = _courtConfig().getDraftConfig(_termId);

        return DraftConfig({ feeToken: feeToken, draftFee: draftFee, penaltyPct: penaltyPct });

    }



    /**

    * @dev Internal function to get the min active balance config for a given term

    * @param _termId Identification number of the term querying the min active balance config of

    * @return Minimum amount of juror tokens that can be activated

    */

    function _getMinActiveBalance(uint64 _termId) internal view returns (uint256) {

        return _courtConfig().getMinActiveBalance(_termId);

    }

}



// File: @aragon/court/contracts/voting/ICRVotingOwner.sol



pragma solidity ^0.5.8;





interface ICRVotingOwner {

    /**

    * @dev Ensure votes can be committed for a vote instance, revert otherwise

    * @param _voteId ID of the vote instance to request the weight of a voter for

    */

    function ensureCanCommit(uint256 _voteId) external;



    /**

    * @dev Ensure a certain voter can commit votes for a vote instance, revert otherwise

    * @param _voteId ID of the vote instance to request the weight of a voter for

    * @param _voter Address of the voter querying the weight of

    */

    function ensureCanCommit(uint256 _voteId, address _voter) external;



    /**

    * @dev Ensure a certain voter can reveal votes for vote instance, revert otherwise

    * @param _voteId ID of the vote instance to request the weight of a voter for

    * @param _voter Address of the voter querying the weight of

    * @return Weight of the requested juror for the requested vote instance

    */

    function ensureCanReveal(uint256 _voteId, address _voter) external returns (uint64);

}



// File: @aragon/court/contracts/voting/ICRVoting.sol



pragma solidity ^0.5.8;







interface ICRVoting {

    /**

    * @dev Create a new vote instance

    * @dev This function can only be called by the CRVoting owner

    * @param _voteId ID of the new vote instance to be created

    * @param _possibleOutcomes Number of possible outcomes for the new vote instance to be created

    */

    function create(uint256 _voteId, uint8 _possibleOutcomes) external;



    /**

    * @dev Get the winning outcome of a vote instance

    * @param _voteId ID of the vote instance querying the winning outcome of

    * @return Winning outcome of the given vote instance or refused in case it's missing

    */

    function getWinningOutcome(uint256 _voteId) external view returns (uint8);



    /**

    * @dev Get the tally of an outcome for a certain vote instance

    * @param _voteId ID of the vote instance querying the tally of

    * @param _outcome Outcome querying the tally of

    * @return Tally of the outcome being queried for the given vote instance

    */

    function getOutcomeTally(uint256 _voteId, uint8 _outcome) external view returns (uint256);



    /**

    * @dev Tell whether an outcome is valid for a given vote instance or not

    * @param _voteId ID of the vote instance to check the outcome of

    * @param _outcome Outcome to check if valid or not

    * @return True if the given outcome is valid for the requested vote instance, false otherwise

    */

    function isValidOutcome(uint256 _voteId, uint8 _outcome) external view returns (bool);



    /**

    * @dev Get the outcome voted by a voter for a certain vote instance

    * @param _voteId ID of the vote instance querying the outcome of

    * @param _voter Address of the voter querying the outcome of

    * @return Outcome of the voter for the given vote instance

    */

    function getVoterOutcome(uint256 _voteId, address _voter) external view returns (uint8);



    /**

    * @dev Tell whether a voter voted in favor of a certain outcome in a vote instance or not

    * @param _voteId ID of the vote instance to query if a voter voted in favor of a certain outcome

    * @param _outcome Outcome to query if the given voter voted in favor of

    * @param _voter Address of the voter to query if voted in favor of the given outcome

    * @return True if the given voter voted in favor of the given outcome, false otherwise

    */

    function hasVotedInFavorOf(uint256 _voteId, uint8 _outcome, address _voter) external view returns (bool);



    /**

    * @dev Filter a list of voters based on whether they voted in favor of a certain outcome in a vote instance or not

    * @param _voteId ID of the vote instance to be checked

    * @param _outcome Outcome to filter the list of voters of

    * @param _voters List of addresses of the voters to be filtered

    * @return List of results to tell whether a voter voted in favor of the given outcome or not

    */

    function getVotersInFavorOf(uint256 _voteId, uint8 _outcome, address[] calldata _voters) external view returns (bool[] memory);

}



// File: @aragon/court/contracts/treasury/ITreasury.sol



pragma solidity ^0.5.8;







interface ITreasury {

    /**

    * @dev Assign a certain amount of tokens to an account

    * @param _token ERC20 token to be assigned

    * @param _to Address of the recipient that will be assigned the tokens to

    * @param _amount Amount of tokens to be assigned to the recipient

    */

    function assign(ERC20 _token, address _to, uint256 _amount) external;



    /**

    * @dev Withdraw a certain amount of tokens

    * @param _token ERC20 token to be withdrawn

    * @param _to Address of the recipient that will receive the tokens

    * @param _amount Amount of tokens to be withdrawn from the sender

    */

    function withdraw(ERC20 _token, address _to, uint256 _amount) external;

}



// File: @aragon/court/contracts/arbitration/IArbitrator.sol



pragma solidity ^0.5.8;







interface IArbitrator {

    /**

    * @dev Create a dispute over the Arbitrable sender with a number of possible rulings

    * @param _possibleRulings Number of possible rulings allowed for the dispute

    * @param _metadata Optional metadata that can be used to provide additional information on the dispute to be created

    * @return Dispute identification number

    */

    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256);



    /**

    * @dev Close the evidence period of a dispute

    * @param _disputeId Identification number of the dispute to close its evidence submitting period

    */

    function closeEvidencePeriod(uint256 _disputeId) external;



    /**

    * @dev Execute the Arbitrable associated to a dispute based on its final ruling

    * @param _disputeId Identification number of the dispute to be executed

    */

    function executeRuling(uint256 _disputeId) external;



    /**

    * @dev Tell the dispute fees information to create a dispute

    * @return recipient Address where the corresponding dispute fees must be transferred to

    * @return feeToken ERC20 token used for the fees

    * @return feeAmount Total amount of fees that must be allowed to the recipient

    */

    function getDisputeFees() external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);



    /**

    * @dev Tell the subscription fees information for a subscriber to be up-to-date

    * @param _subscriber Address of the account paying the subscription fees for

    * @return recipient Address where the corresponding subscriptions fees must be transferred to

    * @return feeToken ERC20 token used for the subscription fees

    * @return feeAmount Total amount of fees that must be allowed to the recipient

    */

    function getSubscriptionFees(address _subscriber) external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);

}



// File: @aragon/court/contracts/standards/ERC165.sol



pragma solidity ^0.5.8;





interface ERC165 {

    /**

    * @dev Query if a contract implements a certain interface

    * @param _interfaceId The interface identifier being queried, as specified in ERC-165

    * @return True if the contract implements the requested interface and if its not 0xffffffff, false otherwise

    */

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool);

}



// File: @aragon/court/contracts/arbitration/IArbitrable.sol



pragma solidity ^0.5.8;









contract IArbitrable is ERC165 {

    bytes4 internal constant ERC165_INTERFACE_ID = bytes4(0x01ffc9a7);

    bytes4 internal constant ARBITRABLE_INTERFACE_ID = bytes4(0x88f3ee69);



    /**

    * @dev Emitted when an IArbitrable instance's dispute is ruled by an IArbitrator

    * @param arbitrator IArbitrator instance ruling the dispute

    * @param disputeId Identification number of the dispute being ruled by the arbitrator

    * @param ruling Ruling given by the arbitrator

    */

    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);



    /**

    * @dev Emitted when new evidence is submitted for the IArbitrable instance's dispute

    * @param disputeId Identification number of the dispute receiving new evidence

    * @param submitter Address of the account submitting the evidence

    * @param evidence Data submitted for the evidence of the dispute

    * @param finished Whether or not the submitter has finished submitting evidence

    */

    event EvidenceSubmitted(uint256 indexed disputeId, address indexed submitter, bytes evidence, bool finished);



    /**

    * @dev Submit evidence for a dispute

    * @param _disputeId Id of the dispute in the Court

    * @param _evidence Data submitted for the evidence related to the dispute

    * @param _finished Whether or not the submitter has finished submitting evidence

    */

    function submitEvidence(uint256 _disputeId, bytes calldata _evidence, bool _finished) external;



    /**

    * @dev Give a ruling for a certain dispute, the account calling it must have rights to rule on the contract

    * @param _disputeId Identification number of the dispute to be ruled

    * @param _ruling Ruling given by the arbitrator, where 0 is reserved for "refused to make a decision"

    */

    function rule(uint256 _disputeId, uint256 _ruling) external;



    /**

    * @dev ERC165 - Query if a contract implements a certain interface

    * @param _interfaceId The interface identifier being queried, as specified in ERC-165

    * @return True if this contract supports the given interface, false otherwise

    */

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {

        return _interfaceId == ARBITRABLE_INTERFACE_ID || _interfaceId == ERC165_INTERFACE_ID;

    }

}



// File: @aragon/court/contracts/disputes/IDisputeManager.sol



pragma solidity ^0.5.8;









interface IDisputeManager {

    enum DisputeState {

        PreDraft,

        Adjudicating,

        Ruled

    }



    enum AdjudicationState {

        Invalid,

        Committing,

        Revealing,

        Appealing,

        ConfirmingAppeal,

        Ended

    }



    /**

    * @dev Create a dispute to be drafted in a future term

    * @param _subject Arbitrable instance creating the dispute

    * @param _possibleRulings Number of possible rulings allowed for the drafted jurors to vote on the dispute

    * @param _metadata Optional metadata that can be used to provide additional information on the dispute to be created

    * @return Dispute identification number

    */

    function createDispute(IArbitrable _subject, uint8 _possibleRulings, bytes calldata _metadata) external returns (uint256);



    /**

    * @dev Close the evidence period of a dispute

    * @param _subject IArbitrable instance requesting to close the evidence submission period

    * @param _disputeId Identification number of the dispute to close its evidence submitting period

    */

    function closeEvidencePeriod(IArbitrable _subject, uint256 _disputeId) external;



    /**

    * @dev Draft jurors for the next round of a dispute

    * @param _disputeId Identification number of the dispute to be drafted

    */

    function draft(uint256 _disputeId) external;



    /**

    * @dev Appeal round of a dispute in favor of a certain ruling

    * @param _disputeId Identification number of the dispute being appealed

    * @param _roundId Identification number of the dispute round being appealed

    * @param _ruling Ruling appealing a dispute round in favor of

    */

    function createAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;



    /**

    * @dev Confirm appeal for a round of a dispute in favor of a ruling

    * @param _disputeId Identification number of the dispute confirming an appeal of

    * @param _roundId Identification number of the dispute round confirming an appeal of

    * @param _ruling Ruling being confirmed against a dispute round appeal

    */

    function confirmAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;



    /**

    * @dev Compute the final ruling for a dispute

    * @param _disputeId Identification number of the dispute to compute its final ruling

    * @return subject Arbitrable instance associated to the dispute

    * @return finalRuling Final ruling decided for the given dispute

    */

    function computeRuling(uint256 _disputeId) external returns (IArbitrable subject, uint8 finalRuling);



    /**

    * @dev Settle penalties for a round of a dispute

    * @param _disputeId Identification number of the dispute to settle penalties for

    * @param _roundId Identification number of the dispute round to settle penalties for

    * @param _jurorsToSettle Maximum number of jurors to be slashed in this call

    */

    function settlePenalties(uint256 _disputeId, uint256 _roundId, uint256 _jurorsToSettle) external;



    /**

    * @dev Claim rewards for a round of a dispute for juror

    * @dev For regular rounds, it will only reward winning jurors

    * @param _disputeId Identification number of the dispute to settle rewards for

    * @param _roundId Identification number of the dispute round to settle rewards for

    * @param _juror Address of the juror to settle their rewards

    */

    function settleReward(uint256 _disputeId, uint256 _roundId, address _juror) external;



    /**

    * @dev Settle appeal deposits for a round of a dispute

    * @param _disputeId Identification number of the dispute to settle appeal deposits for

    * @param _roundId Identification number of the dispute round to settle appeal deposits for

    */

    function settleAppealDeposit(uint256 _disputeId, uint256 _roundId) external;



    /**

    * @dev Tell the amount of token fees required to create a dispute

    * @return feeToken ERC20 token used for the fees

    * @return feeAmount Total amount of fees to be paid for a dispute at the given term

    */

    function getDisputeFees() external view returns (ERC20 feeToken, uint256 feeAmount);



    /**

    * @dev Tell information of a certain dispute

    * @param _disputeId Identification number of the dispute being queried

    * @return subject Arbitrable subject being disputed

    * @return possibleRulings Number of possible rulings allowed for the drafted jurors to vote on the dispute

    * @return state Current state of the dispute being queried: pre-draft, adjudicating, or ruled

    * @return finalRuling The winning ruling in case the dispute is finished

    * @return lastRoundId Identification number of the last round created for the dispute

    * @return createTermId Identification number of the term when the dispute was created

    */

    function getDispute(uint256 _disputeId) external view

        returns (IArbitrable subject, uint8 possibleRulings, DisputeState state, uint8 finalRuling, uint256 lastRoundId, uint64 createTermId);



    /**

    * @dev Tell information of a certain adjudication round

    * @param _disputeId Identification number of the dispute being queried

    * @param _roundId Identification number of the round being queried

    * @return draftTerm Term from which the requested round can be drafted

    * @return delayedTerms Number of terms the given round was delayed based on its requested draft term id

    * @return jurorsNumber Number of jurors requested for the round

    * @return selectedJurors Number of jurors already selected for the requested round

    * @return settledPenalties Whether or not penalties have been settled for the requested round

    * @return collectedTokens Amount of juror tokens that were collected from slashed jurors for the requested round

    * @return coherentJurors Number of jurors that voted in favor of the final ruling in the requested round

    * @return state Adjudication state of the requested round

    */

    function getRound(uint256 _disputeId, uint256 _roundId) external view

        returns (

            uint64 draftTerm,

            uint64 delayedTerms,

            uint64 jurorsNumber,

            uint64 selectedJurors,

            uint256 jurorFees,

            bool settledPenalties,

            uint256 collectedTokens,

            uint64 coherentJurors,

            AdjudicationState state

        );



    /**

    * @dev Tell appeal-related information of a certain adjudication round

    * @param _disputeId Identification number of the dispute being queried

    * @param _roundId Identification number of the round being queried

    * @return maker Address of the account appealing the given round

    * @return appealedRuling Ruling confirmed by the appealer of the given round

    * @return taker Address of the account confirming the appeal of the given round

    * @return opposedRuling Ruling confirmed by the appeal taker of the given round

    */

    function getAppeal(uint256 _disputeId, uint256 _roundId) external view

        returns (address maker, uint64 appealedRuling, address taker, uint64 opposedRuling);



    /**

    * @dev Tell information related to the next round due to an appeal of a certain round given.

    * @param _disputeId Identification number of the dispute being queried

    * @param _roundId Identification number of the round requesting the appeal details of

    * @return nextRoundStartTerm Term ID from which the next round will start

    * @return nextRoundJurorsNumber Jurors number for the next round

    * @return newDisputeState New state for the dispute associated to the given round after the appeal

    * @return feeToken ERC20 token used for the next round fees

    * @return jurorFees Total amount of fees to be distributed between the winning jurors of the next round

    * @return totalFees Total amount of fees for a regular round at the given term

    * @return appealDeposit Amount to be deposit of fees for a regular round at the given term

    * @return confirmAppealDeposit Total amount of fees for a regular round at the given term

    */

    function getNextRoundDetails(uint256 _disputeId, uint256 _roundId) external view

        returns (

            uint64 nextRoundStartTerm,

            uint64 nextRoundJurorsNumber,

            DisputeState newDisputeState,

            ERC20 feeToken,

            uint256 totalFees,

            uint256 jurorFees,

            uint256 appealDeposit,

            uint256 confirmAppealDeposit

        );



    /**

    * @dev Tell juror-related information of a certain adjudication round

    * @param _disputeId Identification number of the dispute being queried

    * @param _roundId Identification number of the round being queried

    * @param _juror Address of the juror being queried

    * @return weight Juror weight drafted for the requested round

    * @return rewarded Whether or not the given juror was rewarded based on the requested round

    */

    function getJuror(uint256 _disputeId, uint256 _roundId, address _juror) external view returns (uint64 weight, bool rewarded);

}



// File: @aragon/court/contracts/subscriptions/ISubscriptions.sol



pragma solidity ^0.5.8;







interface ISubscriptions {

    /**

    * @dev Tell whether a certain subscriber has paid all the fees up to current period or not

    * @param _subscriber Address of subscriber being checked

    * @return True if subscriber has paid all the fees up to current period, false otherwise

    */

    function isUpToDate(address _subscriber) external view returns (bool);



    /**

    * @dev Tell the minimum amount of fees to pay and resulting last paid period for a given subscriber in order to be up-to-date

    * @param _subscriber Address of the subscriber willing to pay

    * @return feeToken ERC20 token used for the subscription fees

    * @return amountToPay Amount of subscription fee tokens to be paid

    * @return newLastPeriodId Identification number of the resulting last paid period

    */

    function getOwedFeesDetails(address _subscriber) external view returns (ERC20, uint256, uint256);

}



// File: @aragon/court/contracts/court/controller/Controlled.sol



pragma solidity ^0.5.8;























contract Controlled is IsContract, ConfigConsumer {

    string private constant ERROR_CONTROLLER_NOT_CONTRACT = "CTD_CONTROLLER_NOT_CONTRACT";

    string private constant ERROR_SENDER_NOT_CONTROLLER = "CTD_SENDER_NOT_CONTROLLER";

    string private constant ERROR_SENDER_NOT_CONFIG_GOVERNOR = "CTD_SENDER_NOT_CONFIG_GOVERNOR";

    string private constant ERROR_SENDER_NOT_DISPUTES_MODULE = "CTD_SENDER_NOT_DISPUTES_MODULE";



    // Address of the controller

    Controller internal controller;



    /**

    * @dev Ensure the msg.sender is the controller's config governor

    */

    modifier onlyConfigGovernor {

        require(msg.sender == _configGovernor(), ERROR_SENDER_NOT_CONFIG_GOVERNOR);

        _;

    }



    /**

    * @dev Ensure the msg.sender is the controller

    */

    modifier onlyController() {

        require(msg.sender == address(controller), ERROR_SENDER_NOT_CONTROLLER);

        _;

    }



    /**

    * @dev Ensure the msg.sender is the DisputeManager module

    */

    modifier onlyDisputeManager() {

        require(msg.sender == address(_disputeManager()), ERROR_SENDER_NOT_DISPUTES_MODULE);

        _;

    }



    /**

    * @dev Constructor function

    * @param _controller Address of the controller

    */

    constructor(Controller _controller) public {

        require(isContract(address(_controller)), ERROR_CONTROLLER_NOT_CONTRACT);

        controller = _controller;

    }



    /**

    * @dev Tell the address of the controller

    * @return Address of the controller

    */

    function getController() external view returns (Controller) {

        return controller;

    }



    /**

    * @dev Internal function to ensure the Court term is up-to-date, it will try to update it if not

    * @return Identification number of the current Court term

    */

    function _ensureCurrentTerm() internal returns (uint64) {

        return _clock().ensureCurrentTerm();

    }



    /**

    * @dev Internal function to fetch the last ensured term ID of the Court

    * @return Identification number of the last ensured term

    */

    function _getLastEnsuredTermId() internal view returns (uint64) {

        return _clock().getLastEnsuredTermId();

    }



    /**

    * @dev Internal function to tell the current term identification number

    * @return Identification number of the current term

    */

    function _getCurrentTermId() internal view returns (uint64) {

        return _clock().getCurrentTermId();

    }



    /**

    * @dev Internal function to fetch the controller's config governor

    * @return Address of the controller's governor

    */

    function _configGovernor() internal view returns (address) {

        return controller.getConfigGovernor();

    }



    /**

    * @dev Internal function to fetch the address of the DisputeManager module from the controller

    * @return Address of the DisputeManager module

    */

    function _disputeManager() internal view returns (IDisputeManager) {

        return IDisputeManager(controller.getDisputeManager());

    }



    /**

    * @dev Internal function to fetch the address of the Treasury module implementation from the controller

    * @return Address of the Treasury module implementation

    */

    function _treasury() internal view returns (ITreasury) {

        return ITreasury(controller.getTreasury());

    }



    /**

    * @dev Internal function to fetch the address of the Voting module implementation from the controller

    * @return Address of the Voting module implementation

    */

    function _voting() internal view returns (ICRVoting) {

        return ICRVoting(controller.getVoting());

    }



    /**

    * @dev Internal function to fetch the address of the Voting module owner from the controller

    * @return Address of the Voting module owner

    */

    function _votingOwner() internal view returns (ICRVotingOwner) {

        return ICRVotingOwner(address(_disputeManager()));

    }



    /**

    * @dev Internal function to fetch the address of the JurorRegistry module implementation from the controller

    * @return Address of the JurorRegistry module implementation

    */

    function _jurorsRegistry() internal view returns (IJurorsRegistry) {

        return IJurorsRegistry(controller.getJurorsRegistry());

    }



    /**

    * @dev Internal function to fetch the address of the Subscriptions module implementation from the controller

    * @return Address of the Subscriptions module implementation

    */

    function _subscriptions() internal view returns (ISubscriptions) {

        return ISubscriptions(controller.getSubscriptions());

    }



    /**

    * @dev Internal function to fetch the address of the Clock module from the controller

    * @return Address of the Clock module

    */

    function _clock() internal view returns (IClock) {

        return IClock(controller);

    }



    /**

    * @dev Internal function to fetch the address of the Config module from the controller

    * @return Address of the Config module

    */

    function _courtConfig() internal view returns (IConfig) {

        return IConfig(controller);

    }

}



// File: @aragon/court/contracts/court/controller/ControlledRecoverable.sol



pragma solidity ^0.5.8;











contract ControlledRecoverable is Controlled {

    using SafeERC20 for ERC20;



    string private constant ERROR_SENDER_NOT_FUNDS_GOVERNOR = "CTD_SENDER_NOT_FUNDS_GOVERNOR";

    string private constant ERROR_INSUFFICIENT_RECOVER_FUNDS = "CTD_INSUFFICIENT_RECOVER_FUNDS";

    string private constant ERROR_RECOVER_TOKEN_FUNDS_FAILED = "CTD_RECOVER_TOKEN_FUNDS_FAILED";



    event RecoverFunds(ERC20 token, address recipient, uint256 balance);



    /**

    * @dev Ensure the msg.sender is the controller's funds governor

    */

    modifier onlyFundsGovernor {

        require(msg.sender == controller.getFundsGovernor(), ERROR_SENDER_NOT_FUNDS_GOVERNOR);

        _;

    }



    /**

    * @dev Constructor function

    * @param _controller Address of the controller

    */

    constructor(Controller _controller) Controlled(_controller) public {

        // solium-disable-previous-line no-empty-blocks

    }



    /**

    * @notice Transfer all `_token` tokens to `_to`

    * @param _token ERC20 token to be recovered

    * @param _to Address of the recipient that will be receive all the funds of the requested token

    */

    function recoverFunds(ERC20 _token, address _to) external onlyFundsGovernor {

        uint256 balance = _token.balanceOf(address(this));

        require(balance > 0, ERROR_INSUFFICIENT_RECOVER_FUNDS);

        require(_token.safeTransfer(_to, balance), ERROR_RECOVER_TOKEN_FUNDS_FAILED);

        emit RecoverFunds(_token, _to, balance);

    }

}



// File: @aragon/court/contracts/registry/JurorsRegistry.sol



pragma solidity ^0.5.8;





























contract JurorsRegistry is ControlledRecoverable, IJurorsRegistry, ERC900, ApproveAndCallFallBack {

    using SafeERC20 for ERC20;

    using SafeMath for uint256;

    using PctHelpers for uint256;

    using BytesHelpers for bytes;

    using HexSumTree for HexSumTree.Tree;

    using JurorsTreeSortition for HexSumTree.Tree;



    string private constant ERROR_NOT_CONTRACT = "JR_NOT_CONTRACT";

    string private constant ERROR_INVALID_ZERO_AMOUNT = "JR_INVALID_ZERO_AMOUNT";

    string private constant ERROR_INVALID_ACTIVATION_AMOUNT = "JR_INVALID_ACTIVATION_AMOUNT";

    string private constant ERROR_INVALID_DEACTIVATION_AMOUNT = "JR_INVALID_DEACTIVATION_AMOUNT";

    string private constant ERROR_INVALID_LOCKED_AMOUNTS_LENGTH = "JR_INVALID_LOCKED_AMOUNTS_LEN";

    string private constant ERROR_INVALID_REWARDED_JURORS_LENGTH = "JR_INVALID_REWARDED_JURORS_LEN";

    string private constant ERROR_ACTIVE_BALANCE_BELOW_MIN = "JR_ACTIVE_BALANCE_BELOW_MIN";

    string private constant ERROR_NOT_ENOUGH_AVAILABLE_BALANCE = "JR_NOT_ENOUGH_AVAILABLE_BALANCE";

    string private constant ERROR_CANNOT_REDUCE_DEACTIVATION_REQUEST = "JR_CANT_REDUCE_DEACTIVATION_REQ";

    string private constant ERROR_TOKEN_TRANSFER_FAILED = "JR_TOKEN_TRANSFER_FAILED";

    string private constant ERROR_TOKEN_APPROVE_NOT_ALLOWED = "JR_TOKEN_APPROVE_NOT_ALLOWED";

    string private constant ERROR_BAD_TOTAL_ACTIVE_BALANCE_LIMIT = "JR_BAD_TOTAL_ACTIVE_BAL_LIMIT";

    string private constant ERROR_TOTAL_ACTIVE_BALANCE_EXCEEDED = "JR_TOTAL_ACTIVE_BALANCE_EXCEEDED";

    string private constant ERROR_WITHDRAWALS_LOCK = "JR_WITHDRAWALS_LOCK";



    // Address that will be used to burn juror tokens

    address internal constant BURN_ACCOUNT = address(0x000000000000000000000000000000000000dEaD);



    // Maximum number of sortition iterations allowed per draft call

    uint256 internal constant MAX_DRAFT_ITERATIONS = 10;



    /**

    * @dev Jurors have three kind of balances, these are:

    *      - active: tokens activated for the Court that can be locked in case the juror is drafted

    *      - locked: amount of active tokens that are locked for a draft

    *      - available: tokens that are not activated for the Court and can be withdrawn by the juror at any time

    *

    *      Due to a gas optimization for drafting, the "active" tokens are stored in a `HexSumTree`, while the others

    *      are stored in this contract as `lockedBalance` and `availableBalance` respectively. Given that the jurors'

    *      active balances cannot be affected during the current Court term, if jurors want to deactivate some of their

    *      active tokens, their balance will be updated for the following term, and they won't be allowed to

    *      withdraw them until the current term has ended.

    *

    *      Note that even though jurors balances are stored separately, all the balances are held by this contract.

    */

    struct Juror {

        uint256 id;                                 // Key in the jurors tree used for drafting

        uint256 lockedBalance;                      // Maximum amount of tokens that can be slashed based on the juror's drafts

        uint256 availableBalance;                   // Available tokens that can be withdrawn at any time

        uint64 withdrawalsLockTermId;               // Term ID until which the juror's withdrawals will be locked

        DeactivationRequest deactivationRequest;    // Juror's pending deactivation request

    }



    /**

    * @dev Given that the jurors balances cannot be affected during a Court term, if jurors want to deactivate some

    *      of their tokens, the tree will always be updated for the following term, and they won't be able to

    *      withdraw the requested amount until the current term has finished. Thus, we need to keep track the term

    *      when a token deactivation was requested and its corresponding amount.

    */

    struct DeactivationRequest {

        uint256 amount;                             // Amount requested for deactivation

        uint64 availableTermId;                     // Term ID when jurors can withdraw their requested deactivation tokens

    }



    /**

    * @dev Internal struct to wrap all the params required to perform jurors drafting

    */

    struct DraftParams {

        bytes32 termRandomness;                     // Randomness seed to be used for the draft

        uint256 disputeId;                          // ID of the dispute being drafted

        uint64 termId;                              // Term ID of the dispute's draft term

        uint256 selectedJurors;                     // Number of jurors already selected for the draft

        uint256 batchRequestedJurors;               // Number of jurors to be selected in the given batch of the draft

        uint256 roundRequestedJurors;               // Total number of jurors requested to be drafted

        uint256 draftLockAmount;                    // Amount of tokens to be locked to each drafted juror

        uint256 iteration;                          // Sortition iteration number

    }



    // Maximum amount of total active balance that can be held in the registry

    uint256 internal totalActiveBalanceLimit;



    // Juror ERC20 token

    ERC20 internal jurorsToken;



    // Mapping of juror data indexed by address

    mapping (address => Juror) internal jurorsByAddress;



    // Mapping of juror addresses indexed by id

    mapping (uint256 => address) internal jurorsAddressById;



    // Tree to store jurors active balance by term for the drafting process

    HexSumTree.Tree internal tree;



    event JurorActivated(address indexed juror, uint64 fromTermId, uint256 amount, address sender);

    event JurorDeactivationRequested(address indexed juror, uint64 availableTermId, uint256 amount);

    event JurorDeactivationProcessed(address indexed juror, uint64 availableTermId, uint256 amount, uint64 processedTermId);

    event JurorDeactivationUpdated(address indexed juror, uint64 availableTermId, uint256 amount, uint64 updateTermId);

    event JurorBalanceLocked(address indexed juror, uint256 amount);

    event JurorBalanceUnlocked(address indexed juror, uint256 amount);

    event JurorSlashed(address indexed juror, uint256 amount, uint64 effectiveTermId);

    event JurorTokensAssigned(address indexed juror, uint256 amount);

    event JurorTokensBurned(uint256 amount);

    event JurorTokensCollected(address indexed juror, uint256 amount, uint64 effectiveTermId);

    event TotalActiveBalanceLimitChanged(uint256 previousTotalActiveBalanceLimit, uint256 currentTotalActiveBalanceLimit);



    /**

    * @dev Constructor function

    * @param _controller Address of the controller

    * @param _jurorToken Address of the ERC20 token to be used as juror token for the registry

    * @param _totalActiveBalanceLimit Maximum amount of total active balance that can be held in the registry

    */

    constructor(Controller _controller, ERC20 _jurorToken, uint256 _totalActiveBalanceLimit)

        ControlledRecoverable(_controller)

        public

    {

        // No need to explicitly call `Controlled` constructor since `ControlledRecoverable` is already doing it

        require(isContract(address(_jurorToken)), ERROR_NOT_CONTRACT);



        jurorsToken = _jurorToken;

        _setTotalActiveBalanceLimit(_totalActiveBalanceLimit);



        tree.init();

        // First tree item is an empty juror

        assert(tree.insert(0, 0) == 0);

    }



    /**

    * @notice Activate `_amount == 0 ? 'all available tokens' : @tokenAmount(self.token(), _amount)` for the next term

    * @param _amount Amount of juror tokens to be activated for the next term

    */

    function activate(uint256 _amount) external {

        _activateTokens(msg.sender, _amount, msg.sender);

    }



    /**

    * @notice Deactivate `_amount == 0 ? 'all unlocked tokens' : @tokenAmount(self.token(), _amount)` for the next term

    * @param _amount Amount of juror tokens to be deactivated for the next term

    */

    function deactivate(uint256 _amount) external {

        uint64 termId = _ensureCurrentTerm();

        Juror storage juror = jurorsByAddress[msg.sender];

        uint256 unlockedActiveBalance = _lastUnlockedActiveBalanceOf(juror);

        uint256 amountToDeactivate = _amount == 0 ? unlockedActiveBalance : _amount;

        require(amountToDeactivate > 0, ERROR_INVALID_ZERO_AMOUNT);

        require(amountToDeactivate <= unlockedActiveBalance, ERROR_INVALID_DEACTIVATION_AMOUNT);



        // No need for SafeMath: we already checked values above

        uint256 futureActiveBalance = unlockedActiveBalance - amountToDeactivate;

        uint256 minActiveBalance = _getMinActiveBalance(termId);

        require(futureActiveBalance == 0 || futureActiveBalance >= minActiveBalance, ERROR_INVALID_DEACTIVATION_AMOUNT);



        _createDeactivationRequest(msg.sender, amountToDeactivate);

    }



    /**

    * @notice Stake `@tokenAmount(self.token(), _amount)` for the sender to the Court

    * @param _amount Amount of tokens to be staked

    * @param _data Optional data that can be used to request the activation of the transferred tokens

    */

    function stake(uint256 _amount, bytes calldata _data) external {

        _stake(msg.sender, msg.sender, _amount, _data);

    }



    /**

    * @notice Stake `@tokenAmount(self.token(), _amount)` for `_to` to the Court

    * @param _to Address to stake an amount of tokens to

    * @param _amount Amount of tokens to be staked

    * @param _data Optional data that can be used to request the activation of the transferred tokens

    */

    function stakeFor(address _to, uint256 _amount, bytes calldata _data) external {

        _stake(msg.sender, _to, _amount, _data);

    }



    /**

    * @notice Unstake `@tokenAmount(self.token(), _amount)` for `_to` from the Court

    * @param _amount Amount of tokens to be unstaked

    * @param _data Optional data is never used by this function, only logged

    */

    function unstake(uint256 _amount, bytes calldata _data) external {

        _unstake(msg.sender, _amount, _data);

    }



    /**

    * @dev Callback of approveAndCall, allows staking directly with a transaction to the token contract.

    * @param _from Address making the transfer

    * @param _amount Amount of tokens to transfer

    * @param _token Address of the token

    * @param _data Optional data that can be used to request the activation of the transferred tokens

    */

    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external {

        require(msg.sender == _token && _token == address(jurorsToken), ERROR_TOKEN_APPROVE_NOT_ALLOWED);

        _stake(_from, _from, _amount, _data);

    }



    /**

    * @notice Process a token deactivation requested for `_juror` if there is any

    * @param _juror Address of the juror to process the deactivation request of

    */

    function processDeactivationRequest(address _juror) external {

        uint64 termId = _ensureCurrentTerm();

        _processDeactivationRequest(_juror, termId);

    }



    /**

    * @notice Assign `@tokenAmount(self.token(), _amount)` to the available balance of `_juror`

    * @param _juror Juror to add an amount of tokens to

    * @param _amount Amount of tokens to be added to the available balance of a juror

    */

    function assignTokens(address _juror, uint256 _amount) external onlyDisputeManager {

        if (_amount > 0) {

            _updateAvailableBalanceOf(_juror, _amount, true);

            emit JurorTokensAssigned(_juror, _amount);

        }

    }



    /**

    * @notice Burn `@tokenAmount(self.token(), _amount)`

    * @param _amount Amount of tokens to be burned

    */

    function burnTokens(uint256 _amount) external onlyDisputeManager {

        if (_amount > 0) {

            _updateAvailableBalanceOf(BURN_ACCOUNT, _amount, true);

            emit JurorTokensBurned(_amount);

        }

    }



    /**

    * @notice Draft a set of jurors based on given requirements for a term id

    * @param _params Array containing draft requirements:

    *        0. bytes32 Term randomness

    *        1. uint256 Dispute id

    *        2. uint64  Current term id

    *        3. uint256 Number of seats already filled

    *        4. uint256 Number of seats left to be filled

    *        5. uint64  Number of jurors required for the draft

    *        6. uint16  Permyriad of the minimum active balance to be locked for the draft

    *

    * @return jurors List of jurors selected for the draft

    * @return length Size of the list of the draft result

    */

    function draft(uint256[7] calldata _params) external onlyDisputeManager returns (address[] memory jurors, uint256 length) {

        DraftParams memory draftParams = _buildDraftParams(_params);

        jurors = new address[](draftParams.batchRequestedJurors);



        // Jurors returned by the tree multi-sortition may not have enough unlocked active balance to be drafted. Thus,

        // we compute several sortitions until all the requested jurors are selected. To guarantee a different set of

        // jurors on each sortition, the iteration number will be part of the random seed to be used in the sortition.

        // Note that we are capping the number of iterations to avoid an OOG error, which means that this function could

        // return less jurors than the requested number.



        for (draftParams.iteration = 0;

             length < draftParams.batchRequestedJurors && draftParams.iteration < MAX_DRAFT_ITERATIONS;

             draftParams.iteration++

        ) {

            (uint256[] memory jurorIds, uint256[] memory activeBalances) = _treeSearch(draftParams);



            for (uint256 i = 0; i < jurorIds.length && length < draftParams.batchRequestedJurors; i++) {

                // We assume the selected jurors are registered in the registry, we are not checking their addresses exist

                address jurorAddress = jurorsAddressById[jurorIds[i]];

                Juror storage juror = jurorsByAddress[jurorAddress];



                // Compute new locked balance for a juror based on the penalty applied when being drafted

                uint256 newLockedBalance = juror.lockedBalance.add(draftParams.draftLockAmount);



                // Check if there is any deactivation requests for the next term. Drafts are always computed for the current term

                // but we have to make sure we are locking an amount that will exist in the next term.

                uint256 nextTermDeactivationRequestAmount = _deactivationRequestedAmountForTerm(juror, draftParams.termId + 1);



                // Check if juror has enough active tokens to lock the requested amount for the draft, skip it otherwise.

                uint256 currentActiveBalance = activeBalances[i];

                if (currentActiveBalance >= newLockedBalance) {



                    // Check if the amount of active tokens for the next term is enough to lock the required amount for

                    // the draft. Otherwise, reduce the requested deactivation amount of the next term.

                    // Next term deactivation amount should always be less than current active balance, but we make sure using SafeMath

                    uint256 nextTermActiveBalance = currentActiveBalance.sub(nextTermDeactivationRequestAmount);

                    if (nextTermActiveBalance < newLockedBalance) {

                        // No need for SafeMath: we already checked values above

                        _reduceDeactivationRequest(jurorAddress, newLockedBalance - nextTermActiveBalance, draftParams.termId);

                    }



                    // Update the current active locked balance of the juror

                    juror.lockedBalance = newLockedBalance;

                    jurors[length++] = jurorAddress;

                    emit JurorBalanceLocked(jurorAddress, draftParams.draftLockAmount);

                }

            }

        }

    }



    /**

    * @notice Slash a set of jurors based on their votes compared to the winning ruling. This function will unlock the

    *         corresponding locked balances of those jurors that are set to be slashed.

    * @param _termId Current term id

    * @param _jurors List of juror addresses to be slashed

    * @param _lockedAmounts List of amounts locked for each corresponding juror that will be either slashed or returned

    * @param _rewardedJurors List of booleans to tell whether a juror's active balance has to be slashed or not

    * @return Total amount of slashed tokens

    */

    function slashOrUnlock(uint64 _termId, address[] calldata _jurors, uint256[] calldata _lockedAmounts, bool[] calldata _rewardedJurors)

        external

        onlyDisputeManager

        returns (uint256)

    {

        require(_jurors.length == _lockedAmounts.length, ERROR_INVALID_LOCKED_AMOUNTS_LENGTH);

        require(_jurors.length == _rewardedJurors.length, ERROR_INVALID_REWARDED_JURORS_LENGTH);



        uint64 nextTermId = _termId + 1;

        uint256 collectedTokens;



        for (uint256 i = 0; i < _jurors.length; i++) {

            uint256 lockedAmount = _lockedAmounts[i];

            address jurorAddress = _jurors[i];

            Juror storage juror = jurorsByAddress[jurorAddress];

            juror.lockedBalance = juror.lockedBalance.sub(lockedAmount);



            // Slash juror if requested. Note that there's no need to check if there was a deactivation

            // request since we're working with already locked balances.

            if (_rewardedJurors[i]) {

                emit JurorBalanceUnlocked(jurorAddress, lockedAmount);

            } else {

                collectedTokens = collectedTokens.add(lockedAmount);

                tree.update(juror.id, nextTermId, lockedAmount, false);

                emit JurorSlashed(jurorAddress, lockedAmount, nextTermId);

            }

        }



        return collectedTokens;

    }



    /**

    * @notice Try to collect `@tokenAmount(self.token(), _amount)` from `_juror` for the term #`_termId + 1`.

    * @dev This function tries to decrease the active balance of a juror for the next term based on the requested

    *      amount. It can be seen as a way to early-slash a juror's active balance.

    * @param _juror Juror to collect the tokens from

    * @param _amount Amount of tokens to be collected from the given juror and for the requested term id

    * @param _termId Current term id

    * @return True if the juror has enough unlocked tokens to be collected for the requested term, false otherwise

    */

    function collectTokens(address _juror, uint256 _amount, uint64 _termId) external onlyDisputeManager returns (bool) {

        if (_amount == 0) {

            return true;

        }



        uint64 nextTermId = _termId + 1;

        Juror storage juror = jurorsByAddress[_juror];

        uint256 unlockedActiveBalance = _lastUnlockedActiveBalanceOf(juror);

        uint256 nextTermDeactivationRequestAmount = _deactivationRequestedAmountForTerm(juror, nextTermId);



        // Check if the juror has enough unlocked tokens to collect the requested amount

        // Note that we're also considering the deactivation request if there is any

        uint256 totalUnlockedActiveBalance = unlockedActiveBalance.add(nextTermDeactivationRequestAmount);

        if (_amount > totalUnlockedActiveBalance) {

            return false;

        }



        // Check if the amount of active tokens is enough to collect the requested amount, otherwise reduce the requested deactivation amount of

        // the next term. Note that this behaviour is different to the one when drafting jurors since this function is called as a side effect

        // of a juror deliberately voting in a final round, while drafts occur randomly.

        if (_amount > unlockedActiveBalance) {

            // No need for SafeMath: amounts were already checked above

            uint256 amountToReduce = _amount - unlockedActiveBalance;

            _reduceDeactivationRequest(_juror, amountToReduce, _termId);

        }

        tree.update(juror.id, nextTermId, _amount, false);



        emit JurorTokensCollected(_juror, _amount, nextTermId);

        return true;

    }



    /**

    * @notice Lock `_juror`'s withdrawals until term #`_termId`

    * @dev This is intended for jurors who voted in a final round and were coherent with the final ruling to prevent 51% attacks

    * @param _juror Address of the juror to be locked

    * @param _termId Term ID until which the juror's withdrawals will be locked

    */

    function lockWithdrawals(address _juror, uint64 _termId) external onlyDisputeManager {

        Juror storage juror = jurorsByAddress[_juror];

        juror.withdrawalsLockTermId = _termId;

    }



    /**

    * @notice Set new limit of total active balance of juror tokens

    * @param _totalActiveBalanceLimit New limit of total active balance of juror tokens

    */

    function setTotalActiveBalanceLimit(uint256 _totalActiveBalanceLimit) external onlyConfigGovernor {

        _setTotalActiveBalanceLimit(_totalActiveBalanceLimit);

    }



    /**

    * @dev ERC900 - Tell the address of the token used for staking

    * @return Address of the token used for staking

    */

    function token() external view returns (address) {

        return address(jurorsToken);

    }



    /**

    * @dev ERC900 - Tell the total amount of juror tokens held by the registry contract

    * @return Amount of juror tokens held by the registry contract

    */

    function totalStaked() external view returns (uint256) {

        return jurorsToken.balanceOf(address(this));

    }



    /**

    * @dev Tell the total amount of active juror tokens

    * @return Total amount of active juror tokens

    */

    function totalActiveBalance() external view returns (uint256) {

        return tree.getTotal();

    }



    /**

    * @dev Tell the total amount of active juror tokens at the given term id

    * @param _termId Term ID querying the total active balance for

    * @return Total amount of active juror tokens at the given term id

    */

    function totalActiveBalanceAt(uint64 _termId) external view returns (uint256) {

        return _totalActiveBalanceAt(_termId);

    }



    /**

    * @dev ERC900 - Tell the total amount of tokens of juror. This includes the active balance, the available

    *      balances, and the pending balance for deactivation. Note that we don't have to include the locked

    *      balances since these represent the amount of active tokens that are locked for drafts, i.e. these

    *      are included in the active balance of the juror.

    * @param _juror Address of the juror querying the total amount of tokens staked of

    * @return Total amount of tokens of a juror

    */

    function totalStakedFor(address _juror) external view returns (uint256) {

        return _totalStakedFor(_juror);

    }



    /**

    * @dev Tell the balance information of a juror

    * @param _juror Address of the juror querying the balance information of

    * @return active Amount of active tokens of a juror

    * @return available Amount of available tokens of a juror

    * @return locked Amount of active tokens that are locked due to ongoing disputes

    * @return pendingDeactivation Amount of active tokens that were requested for deactivation

    */

    function balanceOf(address _juror) external view returns (uint256 active, uint256 available, uint256 locked, uint256 pendingDeactivation) {

        return _balanceOf(_juror);

    }



    /**

    * @dev Tell the balance information of a juror, fecthing tree one at a given term

    * @param _juror Address of the juror querying the balance information of

    * @param _termId Term ID querying the active balance for

    * @return active Amount of active tokens of a juror

    * @return available Amount of available tokens of a juror

    * @return locked Amount of active tokens that are locked due to ongoing disputes

    * @return pendingDeactivation Amount of active tokens that were requested for deactivation

    */

    function balanceOfAt(address _juror, uint64 _termId) external view

        returns (uint256 active, uint256 available, uint256 locked, uint256 pendingDeactivation)

    {

        Juror storage juror = jurorsByAddress[_juror];



        active = _existsJuror(juror) ? tree.getItemAt(juror.id, _termId) : 0;

        (available, locked, pendingDeactivation) = _getBalances(juror);

    }



    /**

    * @dev Tell the active balance of a juror for a given term id

    * @param _juror Address of the juror querying the active balance of

    * @param _termId Term ID querying the active balance for

    * @return Amount of active tokens for juror in the requested past term id

    */

    function activeBalanceOfAt(address _juror, uint64 _termId) external view returns (uint256) {

        return _activeBalanceOfAt(_juror, _termId);

    }



    /**

    * @dev Tell the amount of active tokens of a juror at the last ensured term that are not locked due to ongoing disputes

    * @param _juror Address of the juror querying the unlocked balance of

    * @return Amount of active tokens of a juror that are not locked due to ongoing disputes

    */

    function unlockedActiveBalanceOf(address _juror) external view returns (uint256) {

        Juror storage juror = jurorsByAddress[_juror];

        return _currentUnlockedActiveBalanceOf(juror);

    }



    /**

    * @dev Tell the pending deactivation details for a juror

    * @param _juror Address of the juror whose info is requested

    * @return amount Amount to be deactivated

    * @return availableTermId Term in which the deactivated amount will be available

    */

    function getDeactivationRequest(address _juror) external view returns (uint256 amount, uint64 availableTermId) {

        DeactivationRequest storage request = jurorsByAddress[_juror].deactivationRequest;

        return (request.amount, request.availableTermId);

    }



    /**

    * @dev Tell the withdrawals lock term ID for a juror

    * @param _juror Address of the juror whose info is requested

    * @return Term ID until which the juror's withdrawals will be locked

    */

    function getWithdrawalsLockTermId(address _juror) external view returns (uint64) {

        return jurorsByAddress[_juror].withdrawalsLockTermId;

    }



    /**

    * @dev Tell the identification number associated to a juror address

    * @param _juror Address of the juror querying the identification number of

    * @return Identification number associated to a juror address, zero in case it wasn't registered yet

    */

    function getJurorId(address _juror) external view returns (uint256) {

        return jurorsByAddress[_juror].id;

    }



    /**

    * @dev Tell the maximum amount of total active balance that can be held in the registry

    * @return Maximum amount of total active balance that can be held in the registry

    */

    function totalJurorsActiveBalanceLimit() external view returns (uint256) {

        return totalActiveBalanceLimit;

    }



    /**

    * @dev ERC900 - Tell if the current registry supports historic information or not

    * @return Always false

    */

    function supportsHistory() external pure returns (bool) {

        return false;

    }



    /**

    * @dev Internal function to activate a given amount of tokens for a juror.

    *      This function assumes that the given term is the current term and has already been ensured.

    * @param _juror Address of the juror to activate tokens

    * @param _amount Amount of juror tokens to be activated

    * @param _sender Address of the account requesting the activation

    */

    function _activateTokens(address _juror, uint256 _amount, address _sender) internal {

        uint64 termId = _ensureCurrentTerm();



        // Try to clean a previous deactivation request if any

        _processDeactivationRequest(_juror, termId);



        uint256 availableBalance = jurorsByAddress[_juror].availableBalance;

        uint256 amountToActivate = _amount == 0 ? availableBalance : _amount;

        require(amountToActivate > 0, ERROR_INVALID_ZERO_AMOUNT);

        require(amountToActivate <= availableBalance, ERROR_INVALID_ACTIVATION_AMOUNT);



        uint64 nextTermId = termId + 1;

        _checkTotalActiveBalance(nextTermId, amountToActivate);

        Juror storage juror = jurorsByAddress[_juror];

        uint256 minActiveBalance = _getMinActiveBalance(nextTermId);



        if (_existsJuror(juror)) {

            // Even though we are adding amounts, let's check the new active balance is greater than or equal to the

            // minimum active amount. Note that the juror might have been slashed.

            uint256 activeBalance = tree.getItem(juror.id);

            require(activeBalance.add(amountToActivate) >= minActiveBalance, ERROR_ACTIVE_BALANCE_BELOW_MIN);

            tree.update(juror.id, nextTermId, amountToActivate, true);

        } else {

            require(amountToActivate >= minActiveBalance, ERROR_ACTIVE_BALANCE_BELOW_MIN);

            juror.id = tree.insert(nextTermId, amountToActivate);

            jurorsAddressById[juror.id] = _juror;

        }



        _updateAvailableBalanceOf(_juror, amountToActivate, false);

        emit JurorActivated(_juror, nextTermId, amountToActivate, _sender);

    }



    /**

    * @dev Internal function to create a token deactivation request for a juror. Jurors will be allowed

    *      to process a deactivation request from the next term.

    * @param _juror Address of the juror to create a token deactivation request for

    * @param _amount Amount of juror tokens requested for deactivation

    */

    function _createDeactivationRequest(address _juror, uint256 _amount) internal {

        uint64 termId = _ensureCurrentTerm();



        // Try to clean a previous deactivation request if possible

        _processDeactivationRequest(_juror, termId);



        uint64 nextTermId = termId + 1;

        Juror storage juror = jurorsByAddress[_juror];

        DeactivationRequest storage request = juror.deactivationRequest;

        request.amount = request.amount.add(_amount);

        request.availableTermId = nextTermId;

        tree.update(juror.id, nextTermId, _amount, false);



        emit JurorDeactivationRequested(_juror, nextTermId, _amount);

    }



    /**

    * @dev Internal function to process a token deactivation requested by a juror. It will move the requested amount

    *      to the available balance of the juror if the term when the deactivation was requested has already finished.

    * @param _juror Address of the juror to process the deactivation request of

    * @param _termId Current term id

    */

    function _processDeactivationRequest(address _juror, uint64 _termId) internal {

        Juror storage juror = jurorsByAddress[_juror];

        DeactivationRequest storage request = juror.deactivationRequest;

        uint64 deactivationAvailableTermId = request.availableTermId;



        // If there is a deactivation request, ensure that the deactivation term has been reached

        if (deactivationAvailableTermId == uint64(0) || _termId < deactivationAvailableTermId) {

            return;

        }



        uint256 deactivationAmount = request.amount;

        // Note that we can use a zeroed term ID to denote void here since we are storing

        // the minimum allowed term to deactivate tokens which will always be at least 1.

        request.availableTermId = uint64(0);

        request.amount = 0;

        _updateAvailableBalanceOf(_juror, deactivationAmount, true);



        emit JurorDeactivationProcessed(_juror, deactivationAvailableTermId, deactivationAmount, _termId);

    }



    /**

    * @dev Internal function to reduce a token deactivation requested by a juror. It assumes the deactivation request

    *      cannot be processed for the given term yet.

    * @param _juror Address of the juror to reduce the deactivation request of

    * @param _amount Amount to be reduced from the current deactivation request

    * @param _termId Term ID in which the deactivation request is being reduced

    */

    function _reduceDeactivationRequest(address _juror, uint256 _amount, uint64 _termId) internal {

        Juror storage juror = jurorsByAddress[_juror];

        DeactivationRequest storage request = juror.deactivationRequest;

        uint256 currentRequestAmount = request.amount;

        require(currentRequestAmount >= _amount, ERROR_CANNOT_REDUCE_DEACTIVATION_REQUEST);



        // No need for SafeMath: we already checked values above

        uint256 newRequestAmount = currentRequestAmount - _amount;

        request.amount = newRequestAmount;



        // Move amount back to the tree

        tree.update(juror.id, _termId + 1, _amount, true);



        emit JurorDeactivationUpdated(_juror, request.availableTermId, newRequestAmount, _termId);

    }



    /**

    * @dev Internal function to stake an amount of tokens for a juror

    * @param _from Address sending the amount of tokens to be deposited

    * @param _juror Address of the juror to deposit the tokens to

    * @param _amount Amount of tokens to be deposited

    * @param _data Optional data that can be used to request the activation of the deposited tokens

    */

    function _stake(address _from, address _juror, uint256 _amount, bytes memory _data) internal {

        require(_amount > 0, ERROR_INVALID_ZERO_AMOUNT);

        _updateAvailableBalanceOf(_juror, _amount, true);



        // Activate tokens if it was requested by the sender. Note that there's no need to check

        // the activation amount since we have just added it to the available balance of the juror.

        if (_data.toBytes4() == JurorsRegistry(this).activate.selector) {

            _activateTokens(_juror, _amount, _from);

        }



        emit Staked(_juror, _amount, _totalStakedFor(_juror), _data);

        require(jurorsToken.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);

    }



    /**

    * @dev Internal function to unstake an amount of tokens of a juror

    * @param _juror Address of the juror to to unstake the tokens of

    * @param _amount Amount of tokens to be unstaked

    * @param _data Optional data is never used by this function, only logged

    */

    function _unstake(address _juror, uint256 _amount, bytes memory _data) internal {

        require(_amount > 0, ERROR_INVALID_ZERO_AMOUNT);



        // Try to process a deactivation request for the current term if there is one. Note that we don't need to ensure

        // the current term this time since deactivation requests always work with future terms, which means that if

        // the current term is outdated, it will never match the deactivation term id. We avoid ensuring the term here

        // to avoid forcing jurors to do that in order to withdraw their available balance. Same applies to final round locks.

        uint64 lastEnsuredTermId = _getLastEnsuredTermId();



        // Check that juror's withdrawals are not locked

        uint64 withdrawalsLockTermId = jurorsByAddress[_juror].withdrawalsLockTermId;

        require(withdrawalsLockTermId == 0 || withdrawalsLockTermId < lastEnsuredTermId, ERROR_WITHDRAWALS_LOCK);



        _processDeactivationRequest(_juror, lastEnsuredTermId);



        _updateAvailableBalanceOf(_juror, _amount, false);

        emit Unstaked(_juror, _amount, _totalStakedFor(_juror), _data);

        require(jurorsToken.safeTransfer(_juror, _amount), ERROR_TOKEN_TRANSFER_FAILED);

    }



    /**

    * @dev Internal function to update the available balance of a juror

    * @param _juror Juror to update the available balance of

    * @param _amount Amount of tokens to be added to or removed from the available balance of a juror

    * @param _positive True if the given amount should be added, or false to remove it from the available balance

    */

    function _updateAvailableBalanceOf(address _juror, uint256 _amount, bool _positive) internal {

        // We are not using a require here to avoid reverting in case any of the treasury maths reaches this point

        // with a zeroed amount value. Instead, we are doing this validation in the external entry points such as

        // stake, unstake, activate, deactivate, among others.

        if (_amount == 0) {

            return;

        }



        Juror storage juror = jurorsByAddress[_juror];

        if (_positive) {

            juror.availableBalance = juror.availableBalance.add(_amount);

        } else {

            require(_amount <= juror.availableBalance, ERROR_NOT_ENOUGH_AVAILABLE_BALANCE);

            // No need for SafeMath: we already checked values right above

            juror.availableBalance -= _amount;

        }

    }



    /**

    * @dev Internal function to set new limit of total active balance of juror tokens

    * @param _totalActiveBalanceLimit New limit of total active balance of juror tokens

    */

    function _setTotalActiveBalanceLimit(uint256 _totalActiveBalanceLimit) internal {

        require(_totalActiveBalanceLimit > 0, ERROR_BAD_TOTAL_ACTIVE_BALANCE_LIMIT);

        emit TotalActiveBalanceLimitChanged(totalActiveBalanceLimit, _totalActiveBalanceLimit);

        totalActiveBalanceLimit = _totalActiveBalanceLimit;

    }



    /**

    * @dev Internal function to tell the total amount of tokens of juror

    * @param _juror Address of the juror querying the total amount of tokens staked of

    * @return Total amount of tokens of a juror

    */

    function _totalStakedFor(address _juror) internal view returns (uint256) {

        (uint256 active, uint256 available, , uint256 pendingDeactivation) = _balanceOf(_juror);

        return available.add(active).add(pendingDeactivation);

    }



    /**

    * @dev Internal function to tell the balance information of a juror

    * @param _juror Address of the juror querying the balance information of

    * @return active Amount of active tokens of a juror

    * @return available Amount of available tokens of a juror

    * @return locked Amount of active tokens that are locked due to ongoing disputes

    * @return pendingDeactivation Amount of active tokens that were requested for deactivation

    */

    function _balanceOf(address _juror) internal view returns (uint256 active, uint256 available, uint256 locked, uint256 pendingDeactivation) {

        Juror storage juror = jurorsByAddress[_juror];



        active = _existsJuror(juror) ? tree.getItem(juror.id) : 0;

        (available, locked, pendingDeactivation) = _getBalances(juror);

    }



    /**

    * @dev Tell the active balance of a juror for a given term id

    * @param _juror Address of the juror querying the active balance of

    * @param _termId Term ID querying the active balance for

    * @return Amount of active tokens for juror in the requested past term id

    */

    function _activeBalanceOfAt(address _juror, uint64 _termId) internal view returns (uint256) {

        Juror storage juror = jurorsByAddress[_juror];

        return _existsJuror(juror) ? tree.getItemAt(juror.id, _termId) : 0;

    }



    /**

    * @dev Internal function to get the amount of active tokens of a juror that are not locked due to ongoing disputes

    *      It will use the last value, that might be in a future term

    * @param _juror Juror querying the unlocked active balance of

    * @return Amount of active tokens of a juror that are not locked due to ongoing disputes

    */

    function _lastUnlockedActiveBalanceOf(Juror storage _juror) internal view returns (uint256) {

        return _existsJuror(_juror) ? tree.getItem(_juror.id).sub(_juror.lockedBalance) : 0;

    }



    /**

    * @dev Internal function to get the amount of active tokens at the last ensured term of a juror that are not locked due to ongoing disputes

    * @param _juror Juror querying the unlocked active balance of

    * @return Amount of active tokens of a juror that are not locked due to ongoing disputes

    */

    function _currentUnlockedActiveBalanceOf(Juror storage _juror) internal view returns (uint256) {

        uint64 lastEnsuredTermId = _getLastEnsuredTermId();

        return _existsJuror(_juror) ? tree.getItemAt(_juror.id, lastEnsuredTermId).sub(_juror.lockedBalance) : 0;

    }



    /**

    * @dev Internal function to check if a juror was already registered

    * @param _juror Juror to be checked

    * @return True if the given juror was already registered, false otherwise

    */

    function _existsJuror(Juror storage _juror) internal view returns (bool) {

        return _juror.id != 0;

    }



    /**

    * @dev Internal function to get the amount of a deactivation request for a given term id

    * @param _juror Juror to query the deactivation request amount of

    * @param _termId Term ID of the deactivation request to be queried

    * @return Amount of the deactivation request for the given term, 0 otherwise

    */

    function _deactivationRequestedAmountForTerm(Juror storage _juror, uint64 _termId) internal view returns (uint256) {

        DeactivationRequest storage request = _juror.deactivationRequest;

        return request.availableTermId == _termId ? request.amount : 0;

    }



    /**

    * @dev Internal function to tell the total amount of active juror tokens at the given term id

    * @param _termId Term ID querying the total active balance for

    * @return Total amount of active juror tokens at the given term id

    */

    function _totalActiveBalanceAt(uint64 _termId) internal view returns (uint256) {

        // This function will return always the same values, the only difference remains on gas costs. In case we look for a

        // recent term, in this case current or future ones, we perform a backwards linear search from the last checkpoint.

        // Otherwise, a binary search is computed.

        bool recent = _termId >= _getLastEnsuredTermId();

        return recent ? tree.getRecentTotalAt(_termId) : tree.getTotalAt(_termId);

    }



    /**

    * @dev Internal function to check if its possible to add a given new amount to the registry or not

    * @param _termId Term ID when the new amount will be added

    * @param _amount Amount of tokens willing to be added to the registry

    */

    function _checkTotalActiveBalance(uint64 _termId, uint256 _amount) internal view {

        uint256 currentTotalActiveBalance = _totalActiveBalanceAt(_termId);

        uint256 newTotalActiveBalance = currentTotalActiveBalance.add(_amount);

        require(newTotalActiveBalance <= totalActiveBalanceLimit, ERROR_TOTAL_ACTIVE_BALANCE_EXCEEDED);

    }



    /**

    * @dev Tell the local balance information of a juror (that is not on the tree)

    * @param _juror Address of the juror querying the balance information of

    * @return available Amount of available tokens of a juror

    * @return locked Amount of active tokens that are locked due to ongoing disputes

    * @return pendingDeactivation Amount of active tokens that were requested for deactivation

    */

    function _getBalances(Juror storage _juror) internal view returns (uint256 available, uint256 locked, uint256 pendingDeactivation) {

        available = _juror.availableBalance;

        locked = _juror.lockedBalance;

        pendingDeactivation = _juror.deactivationRequest.amount;

    }



    /**

    * @dev Internal function to search jurors in the tree based on certain search restrictions

    * @param _params Draft params to be used for the jurors search

    * @return ids List of juror ids obtained based on the requested search

    * @return activeBalances List of active balances for each juror obtained based on the requested search

    */

    function _treeSearch(DraftParams memory _params) internal view returns (uint256[] memory ids, uint256[] memory activeBalances) {

        (ids, activeBalances) = tree.batchedRandomSearch(

            _params.termRandomness,

            _params.disputeId,

            _params.termId,

            _params.selectedJurors,

            _params.batchRequestedJurors,

            _params.roundRequestedJurors,

            _params.iteration

        );

    }



    /**

    * @dev Private function to parse a certain set given of draft params

    * @param _params Array containing draft requirements:

    *        0. bytes32 Term randomness

    *        1. uint256 Dispute id

    *        2. uint64  Current term id

    *        3. uint256 Number of seats already filled

    *        4. uint256 Number of seats left to be filled

    *        5. uint64  Number of jurors required for the draft

    *        6. uint16  Permyriad of the minimum active balance to be locked for the draft

    *

    * @return Draft params object parsed

    */

    function _buildDraftParams(uint256[7] memory _params) private view returns (DraftParams memory) {

        uint64 termId = uint64(_params[2]);

        uint256 minActiveBalance = _getMinActiveBalance(termId);



        return DraftParams({

            termRandomness: bytes32(_params[0]),

            disputeId: _params[1],

            termId: termId,

            selectedJurors: _params[3],

            batchRequestedJurors: _params[4],

            roundRequestedJurors: _params[5],

            draftLockAmount: minActiveBalance.pct(uint16(_params[6])),

            iteration: 0

        });

    }

}



// File: contracts/JurorsRegistryMigrator.sol



pragma solidity ^0.5.8;













contract JurorsRegistryMigrator is IDisputeManager {

    string constant internal ERROR_TOKEN_DOES_NOT_MATCH = "JRM_TOKEN_DOES_NOT_MATCH";

    string constant internal ERROR_CONTROLLER_DOES_NOT_MATCH = "JRM_CONTROLLER_DOES_NOT_MATCH";

    string constant internal ERROR_BALANCE_TO_MIGRATE_ZERO = "JRM_BALANCE_TO_MIGRATE_ZERO";

    string constant internal ERROR_ANJ_APPROVAL_FAILED = "JRM_ANJ_APPROVAL_FAILED";

    string constant internal ERROR_MIGRATION_IN_PROGRESS = "JRM_MIGRATION_IN_PROGRESS";

    string constant internal ERROR_CLOSE_TRANSFER_FAILED = "JRM_CLOSE_TRANSFER_FAILED";

    string constant internal ERROR_COURT_TERM_HAS_PASSED = "JRM_COURT_TERM_HAS_PASSED";

    string constant internal ERROR_SENDER_NOT_FUNDS_GOVERNOR = "JRM_SENDER_NOT_FUNDS_GOVERNOR";



    ERC20 public token;

    uint64 public termId;

    Controller public controller;

    JurorsRegistry public oldRegistry;

    JurorsRegistry public newRegistry;



    event TokensMigrated(address indexed juror, uint256 amount);

    event MigrationClosed(uint256 amount);



    modifier onlyFundsGovernor() {

        address fundsGovernor = controller.getFundsGovernor();

        require(fundsGovernor == msg.sender, ERROR_SENDER_NOT_FUNDS_GOVERNOR);

        _;

    }



    constructor (JurorsRegistry _oldRegistry, JurorsRegistry _newRegistry) public {

        address oldRegistryToken = _oldRegistry.token();

        address newRegistryToken = _newRegistry.token();

        require(oldRegistryToken == newRegistryToken, ERROR_TOKEN_DOES_NOT_MATCH);



        Controller oldRegistryController = _oldRegistry.getController();

        Controller newRegistryController = _newRegistry.getController();

        require(oldRegistryController == newRegistryController, ERROR_CONTROLLER_DOES_NOT_MATCH);



        token = ERC20(oldRegistryToken);

        oldRegistry = _oldRegistry;

        newRegistry = _newRegistry;

        controller = oldRegistryController;

        termId = oldRegistryController.getCurrentTermId();

    }



    function migrate(address[] calldata _jurors) external {

        uint64 currentTermId = _ensureMigrationTerm();



        for (uint256 i = 0; i < _jurors.length; i++) {

            _migrate(_jurors[i], currentTermId);

        }

    }



    function migrate(address _juror) external {

        uint64 currentTermId = _ensureMigrationTerm();

        _migrate(_juror, currentTermId);

    }



    function close() external onlyFundsGovernor {

        uint256 balance = token.balanceOf(address(this));

        emit MigrationClosed(balance);



        if (balance > 0) {

            require(token.transfer(address(oldRegistry), balance), ERROR_CLOSE_TRANSFER_FAILED);

        }

    }



    function _migrate(address _juror, uint64 _currentTermId) internal {

        uint256 balanceToBeMigrated = oldRegistry.activeBalanceOfAt(_juror, _currentTermId + 1);

        require(balanceToBeMigrated > 0, ERROR_BALANCE_TO_MIGRATE_ZERO);



        oldRegistry.collectTokens(_juror, balanceToBeMigrated, _currentTermId);

        require(token.approve(address(newRegistry), balanceToBeMigrated), ERROR_ANJ_APPROVAL_FAILED);

        newRegistry.stakeFor(_juror, balanceToBeMigrated, abi.encodePacked(keccak256("activate(uint256)")));



        emit TokensMigrated(_juror, balanceToBeMigrated);

    }



    function _ensureMigrationTerm() internal view returns (uint64) {

        uint64 currentTerm = controller.getCurrentTermId();

        require(termId == currentTerm, ERROR_COURT_TERM_HAS_PASSED);

        return currentTerm;

    }



    /** DISPUTE MANAGER METHODS **/

    // solium-disable function-order



    function createDispute(IArbitrable /* _subject */, uint8 /* _possibleRulings */, bytes calldata /* _metadata */) external returns (uint256) {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function closeEvidencePeriod(IArbitrable /* _subject */, uint256 /* _disputeId */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function draft(uint256 /* _disputeId */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function createAppeal(uint256 /* _disputeId */, uint256 /* _roundId */, uint8 /* _ruling */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function confirmAppeal(uint256 /* _disputeId */, uint256 /* _roundId */, uint8 /* _ruling */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function computeRuling(uint256 /* _disputeId */) external returns (IArbitrable /* subject */, uint8 /* finalRuling */) {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function settlePenalties(uint256 /* _disputeId */, uint256 /* _roundId */, uint256 /* _jurorsToSettle */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function settleReward(uint256 /* _disputeId */, uint256 /* _roundId */, address /* _juror */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function settleAppealDeposit(uint256 /* _disputeId */, uint256 /* _roundId */) external {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function getDisputeFees() external view returns (ERC20 /* feeToken */, uint256 /* feeAmount */) {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function getDispute(uint256 /* _disputeId */) external view

        returns (

            IArbitrable /* subject */,

            uint8 /* possibleRulings */,

            DisputeState /* state */,

            uint8 /* finalRuling */,

            uint256 /* lastRoundId */,

            uint64 /* createTermId */

        )

    {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function getRound(uint256 /* _disputeId */, uint256 /* _roundId */) external view

        returns (

            uint64 /* draftTerm */,

            uint64 /* delayedTerms */,

            uint64 /* jurorsNumber */,

            uint64 /* selectedJurors */,

            uint256 /* jurorFees */,

            bool /* settledPenalties */,

            uint256 /* collectedTokens */,

            uint64 /* coherentJurors */,

            AdjudicationState /* state */

        )

    {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function getAppeal(uint256 /* _disputeId */, uint256 /* _roundId */) external view

        returns (address /* maker */, uint64 /* appealedRuling */, address /* taker */, uint64 /* opposedRuling */)

    {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function getNextRoundDetails(uint256 /* _disputeId */, uint256 /* _roundId */) external view

        returns (

            uint64 /* nextRoundStartTerm */,

            uint64 /* nextRoundJurorsNumber */,

            DisputeState /* newDisputeState */,

            ERC20 /* feeToken */,

            uint256 /* totalFees */,

            uint256 /* jurorFees */,

            uint256 /* appealDeposit */,

            uint256 /* confirmAppealDeposit */

        )

    {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }



    function getJuror(uint256 /* _disputeId */, uint256 /* _roundId */, address /* _juror */) external view

        returns (uint64 /* weight */, bool /* rewarded */)

    {

        revert(ERROR_MIGRATION_IN_PROGRESS);

    }

}