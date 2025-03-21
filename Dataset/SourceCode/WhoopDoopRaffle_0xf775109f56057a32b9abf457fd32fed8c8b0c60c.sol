// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)



pragma solidity ^0.8.1;



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



// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol





// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)



pragma solidity ^0.8.2;





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



// File: @openzeppelin/contracts/utils/Counters.sol





// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)



pragma solidity ^0.8.0;



/**

 * @title Counters

 * @author Matt Condon (@shrugs)

 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number

 * of elements in a mapping, issuing ERC721 ids, or counting request ids.

 *

 * Include with `using Counters for Counters.Counter;`

 */

library Counters {

    struct Counter {

        // This variable should never be directly accessed by users of the library: interactions must be restricted to

        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add

        // this feature: see https://github.com/ethereum/solidity/issues/4637

        uint256 _value; // default: 0

    }



    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;

    }



    function increment(Counter storage counter) internal {

        unchecked {

            counter._value += 1;

        }

    }



    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;

        require(value > 0, "Counter: decrement overflow");

        unchecked {

            counter._value = value - 1;

        }

    }



    function reset(Counter storage counter) internal {

        counter._value = 0;

    }

}



// File: @openzeppelin/contracts/utils/Context.sol





// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



pragma solidity ^0.8.0;



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



// File: @openzeppelin/contracts/access/Ownable.sol





// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



pragma solidity ^0.8.0;





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



// File: contracts/ver.sol





/**

* @title whoopdoopRaffle

* @author Captain Unknown

*/

pragma solidity ^0.8.19.0;









interface IERC20{

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

}



interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);



    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function balanceOf(address owner) external view returns (uint256 balance);

    function transferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



contract WhoopDoopRaffle is Ownable, Initializable {

    using Counters for Counters.Counter;

    Counters.Counter public currentRaffleId;



    struct Prize {

        address NFTContract;

        uint256 NFTTokenId;

    }



    struct Raffle {

        uint256 raffleId;

        uint256 ethPrice;

        uint256 doopPrice;

        bool payableWithDoop;

        bool hasEnded;

        uint256 endTime;

        address[] participants;

        address winner;

        Prize rafflePrize;

    }



    // Context

    address public EAPass;

    address public WDCollection;

    address public doopToken;

    uint256 public maxTicketCount;



    mapping (address => bool) private admin;

    mapping (uint256 => Raffle) public OnGoingRaffles;



    event RaffleStarted(uint256 indexed raffleId, uint256 price, uint256 endTime, Prize rafflePrize);

    event Winner(uint256 indexed raffleId, address winner);



    constructor(address _EAPass, address _WDCollection, address _doopToken, uint256 _maxTicketCount) {

        EAPass = _EAPass;

        WDCollection = _WDCollection;

        doopToken = _doopToken; 

        maxTicketCount = _maxTicketCount;

        _disableInitializers();

    }



    function startRaffle(uint256 _priceInEth, uint256 _doopPrice, bool _payableWithDoop, uint256 _duration, address _prizeNFTContract, uint256 _prizeNFTTokenId) public {

        require(admin[msg.sender], "Only admins can invoke this function.");

        uint256 _endTime = block.timestamp + _duration;



        Raffle memory newRaffle = Raffle(currentRaffleId.current(), _priceInEth, _doopPrice, _payableWithDoop, false, _endTime,

            new address[](0), address(0), Prize(_prizeNFTContract, _prizeNFTTokenId));

        OnGoingRaffles[currentRaffleId.current()] = newRaffle;



        currentRaffleId.increment();

        IERC721(_prizeNFTContract).transferFrom(msg.sender, address(this), _prizeNFTTokenId);

        emit RaffleStarted(newRaffle.raffleId, newRaffle.ethPrice, newRaffle.endTime, newRaffle.rafflePrize);

    }



    function buyTicket(uint256 _RaffleId, uint256 ticketCount) public payable {

        require(raffleExists(_RaffleId), "Invalid Raffle Id.");

        require(block.timestamp < OnGoingRaffles[_RaffleId].endTime, "Raffle entry time is over.");

        require(!(OnGoingRaffles[_RaffleId].hasEnded), "Raffle has already ended.");

        require(ticketCount > 0, "Requested number of tickets should be greater than 0.");

        require(!admin[msg.sender], "Admins can't participate in the raffle.");

        require(msg.sender != owner(), "Owner can't participate in the raffle.");

        require(ticketCount <= maxTicketCount, "Cant buy this much tickets in one go.");



        if (OnGoingRaffles[_RaffleId].payableWithDoop) {

            require(IERC20(doopToken).balanceOf(msg.sender) >= OnGoingRaffles[_RaffleId].doopPrice * ticketCount, "Not enough DOOP balance.");

            require(IERC20(doopToken).transferFrom(msg.sender, address(this), OnGoingRaffles[_RaffleId].doopPrice * ticketCount), "Doop Transfer Failed.");

        } else {

            require(OnGoingRaffles[_RaffleId].ethPrice * ticketCount == msg.value, "Invalid value sent.");

        }



        registerPurchase(_RaffleId, ticketCount);

    }



    function registerPurchase(uint256 _RaffleId, uint256 ticketCount) private {

        if (isHolderOf(msg.sender, EAPass)) {

            ticketCount *= 5;

        } else if (isHolderOf(msg.sender, WDCollection)) {

            ticketCount *= 3;

        } else {

            ticketCount *= 1;

        }



        for (uint256 i = 0; i < ticketCount; i++) {

            OnGoingRaffles[_RaffleId].participants.push(msg.sender);

        }

    }



    function pickWinner(uint256 _RaffleId, string memory seed) private {

        uint256 randomIndex = uint256(keccak256(abi.encodePacked(

                block.timestamp,

                seed,

                blockhash(block.number - 1)

            ))) % OnGoingRaffles[_RaffleId].participants.length;

        address winner = OnGoingRaffles[_RaffleId].participants[randomIndex];

        OnGoingRaffles[_RaffleId].winner = winner;



        IERC721(OnGoingRaffles[_RaffleId].rafflePrize.NFTContract).safeTransferFrom(address(this), winner, OnGoingRaffles[_RaffleId].rafflePrize.NFTTokenId);

        emit Winner(_RaffleId, winner);

    }



    function endRaffle(uint256 _RaffleId, string memory seed) public {

        require(msg.sender == owner() || admin[msg.sender], "Either the owner or an admin can end the raffle.");

        require(raffleExists(_RaffleId), "Invalid Raffle Id.");

        require(block.timestamp >= OnGoingRaffles[_RaffleId].endTime, "Raffle has not ended yet.");

        require(!(OnGoingRaffles[_RaffleId].hasEnded), "Raffle has already ended.");



        OnGoingRaffles[_RaffleId].hasEnded = true;



        if (OnGoingRaffles[_RaffleId].participants.length == 0) {

            IERC721(OnGoingRaffles[_RaffleId].rafflePrize.NFTContract).safeTransferFrom(address(this), owner(), OnGoingRaffles[_RaffleId].rafflePrize.NFTTokenId);

        } else {

            pickWinner(_RaffleId, seed);

        }

    }

    

    function cancelRaffle(uint256 _RaffleId) public {

        require(raffleExists(_RaffleId), "Invalid Raffle Id.");

        require(msg.sender == owner() || admin[msg.sender], "Either the owner or an admin can cancel the raffle.");

        OnGoingRaffles[_RaffleId].hasEnded = true;

        IERC721(OnGoingRaffles[_RaffleId].rafflePrize.NFTContract).safeTransferFrom(address(this), owner(), OnGoingRaffles[_RaffleId].rafflePrize.NFTTokenId);

    }



    // Utilities

    function raffleExists(uint256 _RaffleId) public view returns (bool) {

        return _RaffleId < currentRaffleId.current();

    }



    function getTotalParticipants(uint256 _RaffleId) public view returns (uint256) {

        require(raffleExists(_RaffleId), "Invalid Raffle Id.");

        return OnGoingRaffles[_RaffleId].participants.length;

    }



    function getOngoingRaffles() public view returns (uint256[] memory) {

        uint256[] memory raffleIds = new uint256[](currentRaffleId.current());

        uint256 count = 0;

        for (uint256 i = 0; i < currentRaffleId.current(); i++) {

            if (!OnGoingRaffles[i].hasEnded) {

                raffleIds[count] = i;

                count++;

            }

        }

        uint256[] memory result = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {

            result[i] = raffleIds[i];

        }

        return result;

    }



    function getEndedRaffles() public view returns (uint256[] memory) {

        uint256[] memory raffleIds = new uint256[](currentRaffleId.current());

        uint256 count = 0;

        for (uint256 i = 0; i < currentRaffleId.current(); i++) {

            if (OnGoingRaffles[i].hasEnded) {

                raffleIds[count] = i;

                count++;

            }

        }

        uint256[] memory result = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {

            result[i] = raffleIds[i];

        }

        return result;

    }



    function isHolderOf(address user, address NFT) private view returns(bool) {

        return IERC721(NFT).balanceOf(user) > 0;

    }



    function withdrawAll() public payable onlyOwner {

        require(address(this).balance > 0 || IERC20(doopToken).balanceOf(address(this)) > 0, "Balance is 0.");

        IERC20(doopToken).transfer(msg.sender, IERC20(doopToken).balanceOf(address(this)));

        payable(msg.sender).transfer(address(this).balance);

    }



    function withdrawEth(uint256 amount) public payable onlyOwner {

        require(address(this).balance >= amount, "Insufficient balance in the contract.");

        payable(msg.sender).transfer(amount);

    }



    function withdrawDoop(uint256 amount) public payable onlyOwner {

        require(IERC20(doopToken).balanceOf(address(this)) >= amount, "Insufficient balance in the contract.");

        IERC20(doopToken).transfer(msg.sender, amount);

    }



    function addAdmin(address _admin) public onlyOwner {

        admin[_admin] = true;

    }



    function removeAdmin(address _admin) public onlyOwner {

        admin[_admin] = false;

    }

}