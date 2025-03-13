/**

 *Submitted for verification at Etherscan.io on 2023-04-14

*/



// SPDX-License-Identifier: MIT

// File: contract/operator-filterer/lib/Constants.sol





pragma solidity ^0.8.13;



address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;

address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;

// File: contract/operator-filterer/IOperatorFilterRegistry.sol





pragma solidity ^0.8.13;



interface IOperatorFilterRegistry {

    /**

     * @notice Returns true if operator is not filtered for a given token, either by address or codeHash. Also returns

     *         true if supplied registrant address is not registered.

     */

    function isOperatorAllowed(address registrant, address operator) external view returns (bool);



    /**

     * @notice Registers an address with the registry. May be called by address itself or by EIP-173 owner.

     */

    function register(address registrant) external;



    /**

     * @notice Registers an address with the registry and "subscribes" to another address's filtered operators and codeHashes.

     */

    function registerAndSubscribe(address registrant, address subscription) external;



    /**

     * @notice Registers an address with the registry and copies the filtered operators and codeHashes from another

     *         address without subscribing.

     */

    function registerAndCopyEntries(address registrant, address registrantToCopy) external;



    /**

     * @notice Unregisters an address with the registry and removes its subscription. May be called by address itself or by EIP-173 owner.

     *         Note that this does not remove any filtered addresses or codeHashes.

     *         Also note that any subscriptions to this registrant will still be active and follow the existing filtered addresses and codehashes.

     */

    function unregister(address addr) external;



    /**

     * @notice Update an operator address for a registered address - when filtered is true, the operator is filtered.

     */

    function updateOperator(address registrant, address operator, bool filtered) external;



    /**

     * @notice Update multiple operators for a registered address - when filtered is true, the operators will be filtered. Reverts on duplicates.

     */

    function updateOperators(address registrant, address[] calldata operators, bool filtered) external;



    /**

     * @notice Update a codeHash for a registered address - when filtered is true, the codeHash is filtered.

     */

    function updateCodeHash(address registrant, bytes32 codehash, bool filtered) external;



    /**

     * @notice Update multiple codeHashes for a registered address - when filtered is true, the codeHashes will be filtered. Reverts on duplicates.

     */

    function updateCodeHashes(address registrant, bytes32[] calldata codeHashes, bool filtered) external;



    /**

     * @notice Subscribe an address to another registrant's filtered operators and codeHashes. Will remove previous

     *         subscription if present.

     *         Note that accounts with subscriptions may go on to subscribe to other accounts - in this case,

     *         subscriptions will not be forwarded. Instead the former subscription's existing entries will still be

     *         used.

     */

    function subscribe(address registrant, address registrantToSubscribe) external;



    /**

     * @notice Unsubscribe an address from its current subscribed registrant, and optionally copy its filtered operators and codeHashes.

     */

    function unsubscribe(address registrant, bool copyExistingEntries) external;



    /**

     * @notice Get the subscription address of a given registrant, if any.

     */

    function subscriptionOf(address addr) external returns (address registrant);



    /**

     * @notice Get the set of addresses subscribed to a given registrant.

     *         Note that order is not guaranteed as updates are made.

     */

    function subscribers(address registrant) external returns (address[] memory);



    /**

     * @notice Get the subscriber at a given index in the set of addresses subscribed to a given registrant.

     *         Note that order is not guaranteed as updates are made.

     */

    function subscriberAt(address registrant, uint256 index) external returns (address);



    /**

     * @notice Copy filtered operators and codeHashes from a different registrantToCopy to addr.

     */

    function copyEntriesOf(address registrant, address registrantToCopy) external;



    /**

     * @notice Returns true if operator is filtered by a given address or its subscription.

     */

    function isOperatorFiltered(address registrant, address operator) external returns (bool);



    /**

     * @notice Returns true if the hash of an address's code is filtered by a given address or its subscription.

     */

    function isCodeHashOfFiltered(address registrant, address operatorWithCode) external returns (bool);



    /**

     * @notice Returns true if a codeHash is filtered by a given address or its subscription.

     */

    function isCodeHashFiltered(address registrant, bytes32 codeHash) external returns (bool);



    /**

     * @notice Returns a list of filtered operators for a given address or its subscription.

     */

    function filteredOperators(address addr) external returns (address[] memory);



    /**

     * @notice Returns the set of filtered codeHashes for a given address or its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashes(address addr) external returns (bytes32[] memory);



    /**

     * @notice Returns the filtered operator at the given index of the set of filtered operators for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredOperatorAt(address registrant, uint256 index) external returns (address);



    /**

     * @notice Returns the filtered codeHash at the given index of the list of filtered codeHashes for a given address or

     *         its subscription.

     *         Note that order is not guaranteed as updates are made.

     */

    function filteredCodeHashAt(address registrant, uint256 index) external returns (bytes32);



    /**

     * @notice Returns true if an address has registered

     */

    function isRegistered(address addr) external returns (bool);



    /**

     * @dev Convenience method to compute the code hash of an arbitrary contract

     */

    function codeHashOf(address addr) external returns (bytes32);

}

// File: contract/operator-filterer/OperatorFilterer.sol





pragma solidity ^0.8.13;





/**

 * @title  OperatorFilterer

 * @notice Abstract contract whose constructor automatically registers and optionally subscribes to or copies another

 *         registrant's entries in the OperatorFilterRegistry.

 * @dev    This smart contract is meant to be inherited by token contracts so they can use the following:

 *         - `onlyAllowedOperator` modifier for `transferFrom` and `safeTransferFrom` methods.

 *         - `onlyAllowedOperatorApproval` modifier for `approve` and `setApprovalForAll` methods.

 *         Please note that if your token contract does not provide an owner with EIP-173, it must provide

 *         administration methods on the contract itself to interact with the registry otherwise the subscription

 *         will be locked to the options set during construction.

 */



abstract contract OperatorFilterer {

    /// @dev Emitted when an operator is not allowed.

    error OperatorNotAllowed(address operator);



    IOperatorFilterRegistry public constant OPERATOR_FILTER_REGISTRY =

        IOperatorFilterRegistry(CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS);



    /// @dev The constructor that is called when the contract is being deployed.

    constructor(address subscriptionOrRegistrantToCopy, bool subscribe) {

        // If an inheriting token contract is deployed to a network without the registry deployed, the modifier

        // will not revert, but the contract will need to be registered with the registry once it is deployed in

        // order for the modifier to filter addresses.

        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {

            if (subscribe) {

                OPERATOR_FILTER_REGISTRY.registerAndSubscribe(address(this), subscriptionOrRegistrantToCopy);

            } else {

                if (subscriptionOrRegistrantToCopy != address(0)) {

                    OPERATOR_FILTER_REGISTRY.registerAndCopyEntries(address(this), subscriptionOrRegistrantToCopy);

                } else {

                    OPERATOR_FILTER_REGISTRY.register(address(this));

                }

            }

        }

    }



    /**

     * @dev A helper function to check if an operator is allowed.

     */

    modifier onlyAllowedOperator(address from) virtual {

        // Allow spending tokens from addresses with balance

        // Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred

        // from an EOA.

        if (from != msg.sender) {

            _checkFilterOperator(msg.sender);

        }

        _;

    }



    /**

     * @dev A helper function to check if an operator approval is allowed.

     */

    modifier onlyAllowedOperatorApproval(address operator) virtual {

        _checkFilterOperator(operator);

        _;

    }



    /**

     * @dev A helper function to check if an operator is allowed.

     */

    function _checkFilterOperator(address operator) internal view virtual {

        // Check registry code length to facilitate testing in environments without a deployed registry.

        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {

            // under normal circumstances, this function will revert rather than return false, but inheriting contracts

            // may specify their own OperatorFilterRegistry implementations, which may behave differently

            if (!OPERATOR_FILTER_REGISTRY.isOperatorAllowed(address(this), operator)) {

                revert OperatorNotAllowed(operator);

            }

        }

    }

}

// File: contract/operator-filterer/DefaultOperatorFilterer.sol





pragma solidity ^0.8.13;





/**

 * @title  DefaultOperatorFilterer

 * @notice Inherits from OperatorFilterer and automatically subscribes to the default OpenSea subscription.

 * @dev    Please note that if your token contract does not provide an owner with EIP-173, it must provide

 *         administration methods on the contract itself to interact with the registry otherwise the subscription

 *         will be locked to the options set during construction.

 */



abstract contract DefaultOperatorFilterer is OperatorFilterer {

    /// @dev The constructor that is called when the contract is being deployed.

    constructor() OperatorFilterer(CANONICAL_CORI_SUBSCRIPTION, true) {}

}

// File: @chainlink/contracts/src/v0.8/interfaces/OwnableInterface.sol





pragma solidity ^0.8.0;



interface OwnableInterface {

  function owner() external returns (address);



  function transferOwnership(address recipient) external;



  function acceptOwnership() external;

}



// File: @chainlink/contracts/src/v0.8/ConfirmedOwnerWithProposal.sol





pragma solidity ^0.8.0;





/**

 * @title The ConfirmedOwner contract

 * @notice A contract with helpers for basic contract ownership.

 */

contract ConfirmedOwnerWithProposal is OwnableInterface {

  address private s_owner;

  address private s_pendingOwner;



  event OwnershipTransferRequested(address indexed from, address indexed to);

  event OwnershipTransferred(address indexed from, address indexed to);



  constructor(address newOwner, address pendingOwner) {

    require(newOwner != address(0), "Cannot set owner to zero");



    s_owner = newOwner;

    if (pendingOwner != address(0)) {

      _transferOwnership(pendingOwner);

    }

  }



  /**

   * @notice Allows an owner to begin transferring ownership to a new address,

   * pending.

   */

  function transferOwnership(address to) public override onlyOwner {

    _transferOwnership(to);

  }



  /**

   * @notice Allows an ownership transfer to be completed by the recipient.

   */

  function acceptOwnership() external override {

    require(msg.sender == s_pendingOwner, "Must be proposed owner");



    address oldOwner = s_owner;

    s_owner = msg.sender;

    s_pendingOwner = address(0);



    emit OwnershipTransferred(oldOwner, msg.sender);

  }



  /**

   * @notice Get the current owner

   */

  function owner() public view override returns (address) {

    return s_owner;

  }



  /**

   * @notice validate, transfer ownership, and emit relevant events

   */

  function _transferOwnership(address to) private {

    require(to != msg.sender, "Cannot transfer to self");



    s_pendingOwner = to;



    emit OwnershipTransferRequested(s_owner, to);

  }



  /**

   * @notice validate access

   */

  function _validateOwnership() internal view {

    require(msg.sender == s_owner, "Only callable by owner");

  }



  /**

   * @notice Reverts if called by anyone other than the contract owner.

   */

  modifier onlyOwner() {

    _validateOwnership();

    _;

  }

}



// File: @chainlink/contracts/src/v0.8/ConfirmedOwner.sol





pragma solidity ^0.8.0;





/**

 * @title The ConfirmedOwner contract

 * @notice A contract with helpers for basic contract ownership.

 */

contract ConfirmedOwner is ConfirmedOwnerWithProposal {

  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}

}



// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol





pragma solidity ^0.8.4;



/** ****************************************************************************

 * @notice Interface for contracts using VRF randomness

 * *****************************************************************************

 * @dev PURPOSE

 *

 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness

 * @dev to Vera the verifier in such a way that Vera can be sure he's not

 * @dev making his output up to suit himself. Reggie provides Vera a public key

 * @dev to which he knows the secret key. Each time Vera provides a seed to

 * @dev Reggie, he gives back a value which is computed completely

 * @dev deterministically from the seed and the secret key.

 *

 * @dev Reggie provides a proof by which Vera can verify that the output was

 * @dev correctly computed once Reggie tells it to her, but without that proof,

 * @dev the output is indistinguishable to her from a uniform random sample

 * @dev from the output space.

 *

 * @dev The purpose of this contract is to make it easy for unrelated contracts

 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide

 * @dev simple access to a verifiable source of randomness. It ensures 2 things:

 * @dev 1. The fulfillment came from the VRFCoordinator

 * @dev 2. The consumer contract implements fulfillRandomWords.

 * *****************************************************************************

 * @dev USAGE

 *

 * @dev Calling contracts must inherit from VRFConsumerBase, and can

 * @dev initialize VRFConsumerBase's attributes in their constructor as

 * @dev shown:

 *

 * @dev   contract VRFConsumer {

 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)

 * @dev       VRFConsumerBase(_vrfCoordinator) public {

 * @dev         <initialization with other arguments goes here>

 * @dev       }

 * @dev   }

 *

 * @dev The oracle will have given you an ID for the VRF keypair they have

 * @dev committed to (let's call it keyHash). Create subscription, fund it

 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface

 * @dev subscription management functions).

 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,

 * @dev callbackGasLimit, numWords),

 * @dev see (VRFCoordinatorInterface for a description of the arguments).

 *

 * @dev Once the VRFCoordinator has received and validated the oracle's response

 * @dev to your request, it will call your contract's fulfillRandomWords method.

 *

 * @dev The randomness argument to fulfillRandomWords is a set of random words

 * @dev generated from your requestId and the blockHash of the request.

 *

 * @dev If your contract could have concurrent requests open, you can use the

 * @dev requestId returned from requestRandomWords to track which response is associated

 * @dev with which randomness request.

 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,

 * @dev if your contract could have multiple requests in flight simultaneously.

 *

 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds

 * @dev differ.

 *

 * *****************************************************************************

 * @dev SECURITY CONSIDERATIONS

 *

 * @dev A method with the ability to call your fulfillRandomness method directly

 * @dev could spoof a VRF response with any random value, so it's critical that

 * @dev it cannot be directly called by anything other than this base contract

 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).

 *

 * @dev For your users to trust that your contract's random behavior is free

 * @dev from malicious interference, it's best if you can write it so that all

 * @dev behaviors implied by a VRF response are executed *during* your

 * @dev fulfillRandomness method. If your contract must store the response (or

 * @dev anything derived from it) and use it later, you must ensure that any

 * @dev user-significant behavior which depends on that stored value cannot be

 * @dev manipulated by a subsequent VRF request.

 *

 * @dev Similarly, both miners and the VRF oracle itself have some influence

 * @dev over the order in which VRF responses appear on the blockchain, so if

 * @dev your contract could have multiple VRF requests in flight simultaneously,

 * @dev you must ensure that the order in which the VRF responses arrive cannot

 * @dev be used to manipulate your contract's user-significant behavior.

 *

 * @dev Since the block hash of the block which contains the requestRandomness

 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful

 * @dev miner could, in principle, fork the blockchain to evict the block

 * @dev containing the request, forcing the request to be included in a

 * @dev different block with a different hash, and therefore a different input

 * @dev to the VRF. However, such an attack would incur a substantial economic

 * @dev cost. This cost scales with the number of blocks the VRF oracle waits

 * @dev until it calls responds to a request. It is for this reason that

 * @dev that you can signal to an oracle you'd like them to wait longer before

 * @dev responding to the request (however this is not enforced in the contract

 * @dev and so remains effective only in the case of unmodified oracle software).

 */

abstract contract VRFConsumerBaseV2 {

  error OnlyCoordinatorCanFulfill(address have, address want);

  address private immutable vrfCoordinator;



  /**

   * @param _vrfCoordinator address of VRFCoordinator contract

   */

  constructor(address _vrfCoordinator) {

    vrfCoordinator = _vrfCoordinator;

  }



  /**

   * @notice fulfillRandomness handles the VRF response. Your contract must

   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important

   * @notice principles to keep in mind when implementing your fulfillRandomness

   * @notice method.

   *

   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this

   * @dev signature, and will call it once it has verified the proof

   * @dev associated with the randomness. (It is triggered via a call to

   * @dev rawFulfillRandomness, below.)

   *

   * @param requestId The Id initially returned by requestRandomness

   * @param randomWords the VRF output expanded to the requested number of words

   */

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;



  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF

  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating

  // the origin of the call

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {

    if (msg.sender != vrfCoordinator) {

      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);

    }

    fulfillRandomWords(requestId, randomWords);

  }

}



// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol





pragma solidity ^0.8.0;



interface VRFCoordinatorV2Interface {

  /**

   * @notice Get configuration relevant for making requests

   * @return minimumRequestConfirmations global min for request confirmations

   * @return maxGasLimit global max for request gas limit

   * @return s_provingKeyHashes list of registered key hashes

   */

  function getRequestConfig()

    external

    view

    returns (

      uint16,

      uint32,

      bytes32[] memory

    );



  /**

   * @notice Request a set of random words.

   * @param keyHash - Corresponds to a particular oracle job which uses

   * that key for generating the VRF proof. Different keyHash's have different gas price

   * ceilings, so you can select a specific one to bound your maximum per request cost.

   * @param subId  - The ID of the VRF subscription. Must be funded

   * with the minimum subscription balance required for the selected keyHash.

   * @param minimumRequestConfirmations - How many blocks you'd like the

   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS

   * for why you may want to request more. The acceptable range is

   * [minimumRequestBlockConfirmations, 200].

   * @param callbackGasLimit - How much gas you'd like to receive in your

   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords

   * may be slightly less than this amount because of gas used calling the function

   * (argument decoding etc.), so you may need to request slightly more than you expect

   * to have inside fulfillRandomWords. The acceptable range is

   * [0, maxGasLimit]

   * @param numWords - The number of uint256 random values you'd like to receive

   * in your fulfillRandomWords callback. Note these numbers are expanded in a

   * secure way by the VRFCoordinator from a single random value supplied by the oracle.

   * @return requestId - A unique identifier of the request. Can be used to match

   * a request to a response in fulfillRandomWords.

   */

  function requestRandomWords(

    bytes32 keyHash,

    uint64 subId,

    uint16 minimumRequestConfirmations,

    uint32 callbackGasLimit,

    uint32 numWords

  ) external returns (uint256 requestId);



  /**

   * @notice Create a VRF subscription.

   * @return subId - A unique subscription id.

   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.

   * @dev Note to fund the subscription, use transferAndCall. For example

   * @dev  LINKTOKEN.transferAndCall(

   * @dev    address(COORDINATOR),

   * @dev    amount,

   * @dev    abi.encode(subId));

   */

  function createSubscription() external returns (uint64 subId);



  /**

   * @notice Get a VRF subscription.

   * @param subId - ID of the subscription

   * @return balance - LINK balance of the subscription in juels.

   * @return reqCount - number of requests for this subscription, determines fee tier.

   * @return owner - owner of the subscription.

   * @return consumers - list of consumer address which are able to use this subscription.

   */

  function getSubscription(uint64 subId)

    external

    view

    returns (

      uint96 balance,

      uint64 reqCount,

      address owner,

      address[] memory consumers

    );



  /**

   * @notice Request subscription owner transfer.

   * @param subId - ID of the subscription

   * @param newOwner - proposed new owner of the subscription

   */

  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;



  /**

   * @notice Request subscription owner transfer.

   * @param subId - ID of the subscription

   * @dev will revert if original owner of subId has

   * not requested that msg.sender become the new owner.

   */

  function acceptSubscriptionOwnerTransfer(uint64 subId) external;



  /**

   * @notice Add a consumer to a VRF subscription.

   * @param subId - ID of the subscription

   * @param consumer - New consumer which can use the subscription

   */

  function addConsumer(uint64 subId, address consumer) external;



  /**

   * @notice Remove a consumer from a VRF subscription.

   * @param subId - ID of the subscription

   * @param consumer - Consumer to remove from the subscription

   */

  function removeConsumer(uint64 subId, address consumer) external;



  /**

   * @notice Cancel a subscription

   * @param subId - ID of the subscription

   * @param to - Where to send the remaining LINK to

   */

  function cancelSubscription(uint64 subId, address to) external;



  /*

   * @notice Check to see if there exists a request commitment consumers

   * for all consumers and keyhashes for a given sub.

   * @param subId - ID of the subscription

   * @return true if there exists at least one unfulfilled request for the subscription, false

   * otherwise.

   */

  function pendingRequestExists(uint64 subId) external view returns (bool);

}



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20 {

    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by

     * a call to {approve}. `value` is the new allowance.

     */

    event Approval(address indexed owner, address indexed spender, uint256 value);



    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `to`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address to, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * Emits an {Approval} event.

     */

    function approve(address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `from` to `to` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

}



// File: @openzeppelin/contracts/security/ReentrancyGuard.sol





// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)



pragma solidity ^0.8.0;



/**

 * @dev Contract module that helps prevent reentrant calls to a function.

 *

 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier

 * available, which can be applied to functions to make sure there are no nested

 * (reentrant) calls to them.

 *

 * Note that because there is a single `nonReentrant` guard, functions marked as

 * `nonReentrant` may not call one another. This can be worked around by making

 * those functions `private`, and then adding `external` `nonReentrant` entry

 * points to them.

 *

 * TIP: If you would like to learn more about reentrancy and alternative ways

 * to protect against it, check out our blog post

 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].

 */

abstract contract ReentrancyGuard {

    // Booleans are more expensive than uint256 or any type that takes up a full

    // word because each write operation emits an extra SLOAD to first read the

    // slot's contents, replace the bits taken up by the boolean, and then write

    // back. This is the compiler's defense against contract upgrades and

    // pointer aliasing, and it cannot be disabled.



    // The values being non-zero value makes deployment a bit more expensive,

    // but in exchange the refund on every call to nonReentrant will be lower in

    // amount. Since refunds are capped to a percentage of the total

    // transaction's gas, it is best to keep them low in cases like this one, to

    // increase the likelihood of the full refund coming into effect.

    uint256 private constant _NOT_ENTERED = 1;

    uint256 private constant _ENTERED = 2;



    uint256 private _status;



    constructor() {

        _status = _NOT_ENTERED;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and making it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _nonReentrantBefore();

        _;

        _nonReentrantAfter();

    }



    function _nonReentrantBefore() private {

        // On the first call to nonReentrant, _status will be _NOT_ENTERED

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _status = _ENTERED;

    }



    function _nonReentrantAfter() private {

        // By storing the original value once again, a refund is triggered (see

        // https://eips.ethereum.org/EIPS/eip-2200)

        _status = _NOT_ENTERED;

    }

}



// File: @openzeppelin/contracts/utils/math/Math.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)



pragma solidity ^0.8.0;



/**

 * @dev Standard math utilities missing in the Solidity language.

 */

library Math {

    enum Rounding {

        Down, // Toward negative infinity

        Up, // Toward infinity

        Zero // Toward zero

    }



    /**

     * @dev Returns the largest of two numbers.

     */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;

    }



    /**

     * @dev Returns the smallest of two numbers.

     */

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    /**

     * @dev Returns the average of two numbers. The result is rounded towards

     * zero.

     */

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b) / 2 can overflow.

        return (a & b) + (a ^ b) / 2;

    }



    /**

     * @dev Returns the ceiling of the division of two numbers.

     *

     * This differs from standard division with `/` in that it rounds up instead

     * of rounding down.

     */

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b - 1) / b can overflow on addition, so we distribute.

        return a == 0 ? 0 : (a - 1) / b + 1;

    }



    /**

     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0

     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)

     * with further edits by Uniswap Labs also under MIT license.

     */

    function mulDiv(

        uint256 x,

        uint256 y,

        uint256 denominator

    ) internal pure returns (uint256 result) {

        unchecked {

            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use

            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256

            // variables such that product = prod1 * 2^256 + prod0.

            uint256 prod0; // Least significant 256 bits of the product

            uint256 prod1; // Most significant 256 bits of the product

            assembly {

                let mm := mulmod(x, y, not(0))

                prod0 := mul(x, y)

                prod1 := sub(sub(mm, prod0), lt(mm, prod0))

            }



            // Handle non-overflow cases, 256 by 256 division.

            if (prod1 == 0) {

                return prod0 / denominator;

            }



            // Make sure the result is less than 2^256. Also prevents denominator == 0.

            require(denominator > prod1);



            ///////////////////////////////////////////////

            // 512 by 256 division.

            ///////////////////////////////////////////////



            // Make division exact by subtracting the remainder from [prod1 prod0].

            uint256 remainder;

            assembly {

                // Compute remainder using mulmod.

                remainder := mulmod(x, y, denominator)



                // Subtract 256 bit number from 512 bit number.

                prod1 := sub(prod1, gt(remainder, prod0))

                prod0 := sub(prod0, remainder)

            }



            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.

            // See https://cs.stackexchange.com/q/138556/92363.



            // Does not overflow because the denominator cannot be zero at this stage in the function.

            uint256 twos = denominator & (~denominator + 1);

            assembly {

                // Divide denominator by twos.

                denominator := div(denominator, twos)



                // Divide [prod1 prod0] by twos.

                prod0 := div(prod0, twos)



                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.

                twos := add(div(sub(0, twos), twos), 1)

            }



            // Shift in bits from prod1 into prod0.

            prod0 |= prod1 * twos;



            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such

            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for

            // four bits. That is, denominator * inv = 1 mod 2^4.

            uint256 inverse = (3 * denominator) ^ 2;



            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works

            // in modular arithmetic, doubling the correct bits in each step.

            inverse *= 2 - denominator * inverse; // inverse mod 2^8

            inverse *= 2 - denominator * inverse; // inverse mod 2^16

            inverse *= 2 - denominator * inverse; // inverse mod 2^32

            inverse *= 2 - denominator * inverse; // inverse mod 2^64

            inverse *= 2 - denominator * inverse; // inverse mod 2^128

            inverse *= 2 - denominator * inverse; // inverse mod 2^256



            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.

            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is

            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1

            // is no longer required.

            result = prod0 * inverse;

            return result;

        }

    }



    /**

     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.

     */

    function mulDiv(

        uint256 x,

        uint256 y,

        uint256 denominator,

        Rounding rounding

    ) internal pure returns (uint256) {

        uint256 result = mulDiv(x, y, denominator);

        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {

            result += 1;

        }

        return result;

    }



    /**

     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.

     *

     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).

     */

    function sqrt(uint256 a) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.

        //

        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have

        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.

        //

        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`

        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`

        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`

        //

        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.

        uint256 result = 1 << (log2(a) >> 1);



        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,

        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at

        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision

        // into the expected uint128 result.

        unchecked {

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            result = (result + a / result) >> 1;

            return min(result, a / result);

        }

    }



    /**

     * @notice Calculates sqrt(a), following the selected rounding direction.

     */

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = sqrt(a);

            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 2, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log2(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >> 128 > 0) {

                value >>= 128;

                result += 128;

            }

            if (value >> 64 > 0) {

                value >>= 64;

                result += 64;

            }

            if (value >> 32 > 0) {

                value >>= 32;

                result += 32;

            }

            if (value >> 16 > 0) {

                value >>= 16;

                result += 16;

            }

            if (value >> 8 > 0) {

                value >>= 8;

                result += 8;

            }

            if (value >> 4 > 0) {

                value >>= 4;

                result += 4;

            }

            if (value >> 2 > 0) {

                value >>= 2;

                result += 2;

            }

            if (value >> 1 > 0) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log2(value);

            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 10, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >= 10**64) {

                value /= 10**64;

                result += 64;

            }

            if (value >= 10**32) {

                value /= 10**32;

                result += 32;

            }

            if (value >= 10**16) {

                value /= 10**16;

                result += 16;

            }

            if (value >= 10**8) {

                value /= 10**8;

                result += 8;

            }

            if (value >= 10**4) {

                value /= 10**4;

                result += 4;

            }

            if (value >= 10**2) {

                value /= 10**2;

                result += 2;

            }

            if (value >= 10**1) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log10(value);

            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);

        }

    }



    /**

     * @dev Return the log in base 256, rounded down, of a positive value.

     * Returns 0 if given 0.

     *

     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.

     */

    function log256(uint256 value) internal pure returns (uint256) {

        uint256 result = 0;

        unchecked {

            if (value >> 128 > 0) {

                value >>= 128;

                result += 16;

            }

            if (value >> 64 > 0) {

                value >>= 64;

                result += 8;

            }

            if (value >> 32 > 0) {

                value >>= 32;

                result += 4;

            }

            if (value >> 16 > 0) {

                value >>= 16;

                result += 2;

            }

            if (value >> 8 > 0) {

                result += 1;

            }

        }

        return result;

    }



    /**

     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.

     * Returns 0 if given 0.

     */

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {

        unchecked {

            uint256 result = log256(value);

            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);

        }

    }

}



// File: @openzeppelin/contracts/utils/Strings.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)



pragma solidity ^0.8.0;





/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;



    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory) {

        unchecked {

            uint256 length = Math.log10(value) + 1;

            string memory buffer = new string(length);

            uint256 ptr;

            /// @solidity memory-safe-assembly

            assembly {

                ptr := add(buffer, add(32, length))

            }

            while (true) {

                ptr--;

                /// @solidity memory-safe-assembly

                assembly {

                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))

                }

                value /= 10;

                if (value == 0) break;

            }

            return buffer;

        }

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.

     */

    function toHexString(uint256 value) internal pure returns (string memory) {

        unchecked {

            return toHexString(value, Math.log256(value) + 1);

        }

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

     */

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);

        buffer[0] = "0";

        buffer[1] = "x";

        for (uint256 i = 2 * length + 1; i > 1; --i) {

            buffer[i] = _SYMBOLS[value & 0xf];

            value >>= 4;

        }

        require(value == 0, "Strings: hex length insufficient");

        return string(buffer);

    }



    /**

     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.

     */

    function toHexString(address addr) internal pure returns (string memory) {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);

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



// File: @openzeppelin/contracts/utils/Address.sol





// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)



pragma solidity ^0.8.1;



/**

 * @dev Collection of functions related to the address type

 */

library Address {

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

     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],

     * but performing a delegate call.

     *

     * _Available since v3.4._

     */

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");

    }



    /**

     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],

     * but performing a delegate call.

     *

     * _Available since v3.4._

     */

    function functionDelegateCall(

        address target,

        bytes memory data,

        string memory errorMessage

    ) internal returns (bytes memory) {

        (bool success, bytes memory returndata) = target.delegatecall(data);

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



// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol





// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)



pragma solidity ^0.8.0;



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

interface IERC721Receiver {

    /**

     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}

     * by `operator` from `from`, this function is called.

     *

     * It must return its Solidity selector to confirm the token transfer.

     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.

     *

     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.

     */

    function onERC721Received(

        address operator,

        address from,

        uint256 tokenId,

        bytes calldata data

    ) external returns (bytes4);

}



// File: @openzeppelin/contracts/utils/introspection/IERC165.sol





// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC165 standard, as defined in the

 * https://eips.ethereum.org/EIPS/eip-165[EIP].

 *

 * Implementers can declare support of contract interfaces, which can then be

 * queried by others ({ERC165Checker}).

 *

 * For an implementation, see {ERC165}.

 */

interface IERC165 {

    /**

     * @dev Returns true if this contract implements the interface defined by

     * `interfaceId`. See the corresponding

     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]

     * to learn more about how these ids are created.

     *

     * This function call must use less than 30 000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



// File: @openzeppelin/contracts/utils/introspection/ERC165.sol





// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)



pragma solidity ^0.8.0;





/**

 * @dev Implementation of the {IERC165} interface.

 *

 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check

 * for the additional interface id that will be supported. For example:

 *

 * ```solidity

 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);

 * }

 * ```

 *

 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.

 */

abstract contract ERC165 is IERC165 {

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}



// File: @openzeppelin/contracts/token/ERC721/IERC721.sol





// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)



pragma solidity ^0.8.0;





/**

 * @dev Required interface of an ERC721 compliant contract.

 */

interface IERC721 is IERC165 {

    /**

     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.

     */

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);



    /**

     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.

     */

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);



    /**

     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.

     */

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    /**

     * @dev Returns the number of tokens in ``owner``'s account.

     */

    function balanceOf(address owner) external view returns (uint256 balance);



    /**

     * @dev Returns the owner of the `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function ownerOf(uint256 tokenId) external view returns (address owner);



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes calldata data

    ) external;



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) external;



    /**

     * @dev Transfers `tokenId` token from `from` to `to`.

     *

     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721

     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must

     * understand this adds an external call which potentially creates a reentrancy vulnerability.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must be owned by `from`.

     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) external;



    /**

     * @dev Gives permission to `to` to transfer `tokenId` token to another account.

     * The approval is cleared when the token is transferred.

     *

     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.

     *

     * Requirements:

     *

     * - The caller must own the token or be an approved operator.

     * - `tokenId` must exist.

     *

     * Emits an {Approval} event.

     */

    function approve(address to, uint256 tokenId) external;



    /**

     * @dev Approve or remove `operator` as an operator for the caller.

     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.

     *

     * Requirements:

     *

     * - The `operator` cannot be the caller.

     *

     * Emits an {ApprovalForAll} event.

     */

    function setApprovalForAll(address operator, bool _approved) external;



    /**

     * @dev Returns the account approved for `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function getApproved(uint256 tokenId) external view returns (address operator);



    /**

     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

     *

     * See {setApprovalForAll}

     */

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}



// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol





// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)



pragma solidity ^0.8.0;





/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

interface IERC721Enumerable is IERC721 {

    /**

     * @dev Returns the total amount of tokens stored by the contract.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.

     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.

     */

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);



    /**

     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.

     * Use along with {totalSupply} to enumerate all tokens.

     */

    function tokenByIndex(uint256 index) external view returns (uint256);

}



// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol





// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)



pragma solidity ^0.8.0;





/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://eips.ethereum.org/EIPS/eip-721

 */

interface IERC721Metadata is IERC721 {

    /**

     * @dev Returns the token collection name.

     */

    function name() external view returns (string memory);



    /**

     * @dev Returns the token collection symbol.

     */

    function symbol() external view returns (string memory);



    /**

     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.

     */

    function tokenURI(uint256 tokenId) external view returns (string memory);

}



// File: @openzeppelin/contracts/token/ERC721/ERC721.sol





// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)



pragma solidity ^0.8.0;

















/**

 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including

 * the Metadata extension, but not including the Enumerable extension, which is available separately as

 * {ERC721Enumerable}.

 */

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;

    using Strings for uint256;



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Mapping from token ID to owner address

    mapping(uint256 => address) private _owners;



    // Mapping owner address to token count

    mapping(address => uint256) private _balances;



    // Mapping from token ID to approved address

    mapping(uint256 => address) private _tokenApprovals;



    // Mapping from owner to operator approvals

    mapping(address => mapping(address => bool)) private _operatorApprovals;



    /**

     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.

     */

    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721-balanceOf}.

     */

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: address zero is not a valid owner");

        return _balances[owner];

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _ownerOf(tokenId);

        require(owner != address(0), "ERC721: invalid token ID");

        return owner;

    }



    /**

     * @dev See {IERC721Metadata-name}.

     */

    function name() public view virtual override returns (string memory) {

        return _name;

    }



    /**

     * @dev See {IERC721Metadata-symbol}.

     */

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    /**

     * @dev See {IERC721Metadata-tokenURI}.

     */

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        _requireMinted(tokenId);



        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";

    }



    /**

     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each

     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty

     * by default, can be overridden in child contracts.

     */

    function _baseURI() internal view virtual returns (string memory) {

        return "";

    }



    /**

     * @dev See {IERC721-approve}.

     */

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);

        require(to != owner, "ERC721: approval to current owner");



        require(

            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),

            "ERC721: approve caller is not token owner or approved for all"

        );



        _approve(to, tokenId);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        _requireMinted(tokenId);



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC721-isApprovedForAll}.

     */

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev See {IERC721-transferFrom}.

     */

    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public virtual override {

        //solhint-disable-next-line max-line-length

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");



        _transfer(from, to, tokenId);

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _safeTransfer(from, to, tokenId, data);

    }



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * `data` is additional data, it has no specified format and it is sent in call to `to`.

     *

     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.

     * implement alternative mechanisms to perform token transfer, such as signature-based.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function _safeTransfer(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) internal virtual {

        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");

    }



    /**

     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist

     */

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {

        return _owners[tokenId];

    }



    /**

     * @dev Returns whether `tokenId` exists.

     *

     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

     *

     * Tokens start existing when they are minted (`_mint`),

     * and stop existing when they are burned (`_burn`).

     */

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _ownerOf(tokenId) != address(0);

    }



    /**

     * @dev Returns whether `spender` is allowed to manage `tokenId`.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        address owner = ERC721.ownerOf(tokenId);

        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);

    }



    /**

     * @dev Safely mints `tokenId` and transfers it to `to`.

     *

     * Requirements:

     *

     * - `tokenId` must not exist.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");

    }



    /**

     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is

     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.

     */

    function _safeMint(

        address to,

        uint256 tokenId,

        bytes memory data

    ) internal virtual {

        _mint(to, tokenId);

        require(

            _checkOnERC721Received(address(0), to, tokenId, data),

            "ERC721: transfer to non ERC721Receiver implementer"

        );

    }



    /**

     * @dev Mints `tokenId` and transfers it to `to`.

     *

     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible

     *

     * Requirements:

     *

     * - `tokenId` must not exist.

     * - `to` cannot be the zero address.

     *

     * Emits a {Transfer} event.

     */

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");

        require(!_exists(tokenId), "ERC721: token already minted");



        _beforeTokenTransfer(address(0), to, tokenId, 1);



        // Check that tokenId was not minted by `_beforeTokenTransfer` hook

        require(!_exists(tokenId), "ERC721: token already minted");



        unchecked {

            // Will not overflow unless all 2**256 token ids are minted to the same owner.

            // Given that tokens are minted one by one, it is impossible in practice that

            // this ever happens. Might change if we allow batch minting.

            // The ERC fails to describe this case.

            _balances[to] += 1;

        }



        _owners[tokenId] = to;



        emit Transfer(address(0), to, tokenId);



        _afterTokenTransfer(address(0), to, tokenId, 1);

    }



    /**

     * @dev Destroys `tokenId`.

     * The approval is cleared when the token is burned.

     * This is an internal function that does not check if the sender is authorized to operate on the token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     *

     * Emits a {Transfer} event.

     */

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);



        _beforeTokenTransfer(owner, address(0), tokenId, 1);



        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook

        owner = ERC721.ownerOf(tokenId);



        // Clear approvals

        delete _tokenApprovals[tokenId];



        unchecked {

            // Cannot overflow, as that would require more tokens to be burned/transferred

            // out than the owner initially received through minting and transferring in.

            _balances[owner] -= 1;

        }

        delete _owners[tokenId];



        emit Transfer(owner, address(0), tokenId);



        _afterTokenTransfer(owner, address(0), tokenId, 1);

    }



    /**

     * @dev Transfers `tokenId` from `from` to `to`.

     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `tokenId` token must be owned by `from`.

     *

     * Emits a {Transfer} event.

     */

    function _transfer(

        address from,

        address to,

        uint256 tokenId

    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        require(to != address(0), "ERC721: transfer to the zero address");



        _beforeTokenTransfer(from, to, tokenId, 1);



        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");



        // Clear approvals from the previous owner

        delete _tokenApprovals[tokenId];



        unchecked {

            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:

            // `from`'s balance is the number of token held, which is at least one before the current

            // transfer.

            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require

            // all 2**256 token ids to be minted, which in practice is impossible.

            _balances[from] -= 1;

            _balances[to] += 1;

        }

        _owners[tokenId] = to;



        emit Transfer(from, to, tokenId);



        _afterTokenTransfer(from, to, tokenId, 1);

    }



    /**

     * @dev Approve `to` to operate on `tokenId`

     *

     * Emits an {Approval} event.

     */

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;

        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);

    }



    /**

     * @dev Approve `operator` to operate on all of `owner` tokens

     *

     * Emits an {ApprovalForAll} event.

     */

    function _setApprovalForAll(

        address owner,

        address operator,

        bool approved

    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");

        _operatorApprovals[owner][operator] = approved;

        emit ApprovalForAll(owner, operator, approved);

    }



    /**

     * @dev Reverts if the `tokenId` has not been minted yet.

     */

    function _requireMinted(uint256 tokenId) internal view virtual {

        require(_exists(tokenId), "ERC721: invalid token ID");

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.

     * The call is not executed if the target address is not a contract.

     *

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) private returns (bool) {

        if (to.isContract()) {

            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {

                return retval == IERC721Receiver.onERC721Received.selector;

            } catch (bytes memory reason) {

                if (reason.length == 0) {

                    revert("ERC721: transfer to non ERC721Receiver implementer");

                } else {

                    /// @solidity memory-safe-assembly

                    assembly {

                        revert(add(32, reason), mload(reason))

                    }

                }

            }

        } else {

            return true;

        }

    }



    /**

     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is

     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.

     * - When `from` is zero, the tokens will be minted for `to`.

     * - When `to` is zero, ``from``'s tokens will be burned.

     * - `from` and `to` are never both zero.

     * - `batchSize` is non-zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 firstTokenId,

        uint256 batchSize

    ) internal virtual {}



    /**

     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is

     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.

     * - When `from` is zero, the tokens were minted for `to`.

     * - When `to` is zero, ``from``'s tokens were burned.

     * - `from` and `to` are never both zero.

     * - `batchSize` is non-zero.

     *

     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].

     */

    function _afterTokenTransfer(

        address from,

        address to,

        uint256 firstTokenId,

        uint256 batchSize

    ) internal virtual {}



    /**

     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.

     *

     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant

     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such

     * that `ownerOf(tokenId)` is `a`.

     */

    // solhint-disable-next-line func-name-mixedcase

    function __unsafe_increaseBalance(address account, uint256 amount) internal {

        _balances[account] += amount;

    }

}



// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol





// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)



pragma solidity ^0.8.0;





/**

 * @dev ERC721 token with storage based token URI management.

 */

abstract contract ERC721URIStorage is ERC721 {

    using Strings for uint256;



    // Optional mapping for token URIs

    mapping(uint256 => string) private _tokenURIs;



    /**

     * @dev See {IERC721Metadata-tokenURI}.

     */

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        _requireMinted(tokenId);



        string memory _tokenURI = _tokenURIs[tokenId];

        string memory base = _baseURI();



        // If there is no base URI, return the token URI.

        if (bytes(base).length == 0) {

            return _tokenURI;

        }

        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).

        if (bytes(_tokenURI).length > 0) {

            return string(abi.encodePacked(base, _tokenURI));

        }



        return super.tokenURI(tokenId);

    }



    /**

     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");

        _tokenURIs[tokenId] = _tokenURI;

    }



    /**

     * @dev See {ERC721-_burn}. This override additionally checks to see if a

     * token-specific URI was set for the token, and if so, it deletes the token URI from

     * the storage mapping.

     */

    function _burn(uint256 tokenId) internal virtual override {

        super._burn(tokenId);



        if (bytes(_tokenURIs[tokenId]).length != 0) {

            delete _tokenURIs[tokenId];

        }

    }

}



// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol





// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)



pragma solidity ^0.8.0;







/**

 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds

 * enumerability of all the token ids in the contract as well as all token ids owned by each

 * account.

 */

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {

    // Mapping from owner to list of owned token IDs

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;



    // Mapping from token ID to index of the owner tokens list

    mapping(uint256 => uint256) private _ownedTokensIndex;



    // Array with all token ids, used for enumeration

    uint256[] private _allTokens;



    // Mapping from token id to position in the allTokens array

    mapping(uint256 => uint256) private _allTokensIndex;



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {

        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.

     */

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");

        return _ownedTokens[owner][index];

    }



    /**

     * @dev See {IERC721Enumerable-totalSupply}.

     */

    function totalSupply() public view virtual override returns (uint256) {

        return _allTokens.length;

    }



    /**

     * @dev See {IERC721Enumerable-tokenByIndex}.

     */

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");

        return _allTokens[index];

    }



    /**

     * @dev See {ERC721-_beforeTokenTransfer}.

     */

    function _beforeTokenTransfer(

        address from,

        address to,

        uint256 firstTokenId,

        uint256 batchSize

    ) internal virtual override {

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);



        if (batchSize > 1) {

            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.

            revert("ERC721Enumerable: consecutive transfers not supported");

        }



        uint256 tokenId = firstTokenId;



        if (from == address(0)) {

            _addTokenToAllTokensEnumeration(tokenId);

        } else if (from != to) {

            _removeTokenFromOwnerEnumeration(from, tokenId);

        }

        if (to == address(0)) {

            _removeTokenFromAllTokensEnumeration(tokenId);

        } else if (to != from) {

            _addTokenToOwnerEnumeration(to, tokenId);

        }

    }



    /**

     * @dev Private function to add a token to this extension's ownership-tracking data structures.

     * @param to address representing the new owner of the given token ID

     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

     */

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        uint256 length = ERC721.balanceOf(to);

        _ownedTokens[to][length] = tokenId;

        _ownedTokensIndex[tokenId] = length;

    }



    /**

     * @dev Private function to add a token to this extension's token tracking data structures.

     * @param tokenId uint256 ID of the token to be added to the tokens list

     */

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;

        _allTokens.push(tokenId);

    }



    /**

     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that

     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for

     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).

     * This has O(1) time complexity, but alters the order of the _ownedTokens array.

     * @param from address representing the previous owner of the given token ID

     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address

     */

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and

        // then delete the last slot (swap and pop).



        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;

        uint256 tokenIndex = _ownedTokensIndex[tokenId];



        // When the token to delete is the last token, the swap operation is unnecessary

        if (tokenIndex != lastTokenIndex) {

            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];



            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        }



        // This also deletes the contents at the last position of the array

        delete _ownedTokensIndex[tokenId];

        delete _ownedTokens[from][lastTokenIndex];

    }



    /**

     * @dev Private function to remove a token from this extension's token tracking data structures.

     * This has O(1) time complexity, but alters the order of the _allTokens array.

     * @param tokenId uint256 ID of the token to be removed from the tokens list

     */

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and

        // then delete the last slot (swap and pop).



        uint256 lastTokenIndex = _allTokens.length - 1;

        uint256 tokenIndex = _allTokensIndex[tokenId];



        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so

        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding

        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)

        uint256 lastTokenId = _allTokens[lastTokenIndex];



        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token

        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index



        // This also deletes the contents at the last position of the array

        delete _allTokensIndex[tokenId];

        _allTokens.pop();

    }

}



// File: contract/BearFruitsCode.sol



pragma solidity ^0.8.13;



// let's flip some monkeys



contract BearFruits is 

    ERC721Enumerable, 

    DefaultOperatorFilterer, 

    ReentrancyGuard, 

    VRFConsumerBaseV2, 

    ConfirmedOwner

{

    constructor() 

        ERC721("Bear Fruits", "GRACE")

        VRFConsumerBaseV2(0x271682DEB8C4E0901D1a1550aD2e64D568E69909)

        ConfirmedOwner(msg.sender)

    {

        COORDINATOR = VRFCoordinatorV2Interface(0x271682DEB8C4E0901D1a1550aD2e64D568E69909);

        s_subscriptionId = 707;

        mintIsActive = false;

        allowlistMintActive = false;

        mintingForbiddenFruit = ForbiddenFruitType.Banana;

        mintingSeason = SeasonType.Spring;

        ranksForbidden = [0, 1, 2, 3, 4, 5, 6, 7];

        currentSeason = SeasonType.Spring;

        DDE = false;

        forbiddenFruitCounter = 1;

        goldenAppleCounter = 5601;

        reserveCounter = 6101;

        paidCounter = 0;

        callbackGasLimit = 300000;

        requestConfirmations = 3;

        numWords = 9;

        keyHash = 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef;

    }



    event PaidMint(address indexed to, uint256 indexed tokenId);



    uint256 private constant MAX_ITEMS = 6102;

    uint256 private constant MAX_FORBIDDEN_FRUITS_TOTAL = 5600;

    uint256 private constant MAX_FORBIDDEN_FRUIT_SEASON_TYPE = 175;

    uint256 private constant MAX_GOLDEN_APPLE = 6100;



    uint256 public forbiddenFruitCounter;

    uint256 public goldenAppleCounter;

    uint256 public paidCounter;

    uint256 private reserveCounter;

    uint256 private allowlistCode;



    bool public mintIsActive;

    bool public allowlistMintActive;



    string private URI;



    enum ForbiddenFruitType {

        Banana,

        Carob,

        Citron,

        Fig,

        Grape,

        Mushroom,

        Pomegranate,

        Quince

    }



    enum SeasonType {

        Spring,

        Summer,

        Fall,

        Winter

    }



    struct Fruit {

        bool isGoldenApple;

        bool isReserve;

        ForbiddenFruitType fruitType;

        SeasonType season;

    }



    mapping(uint256 => Fruit) public fruitInfo;



    ForbiddenFruitType public mintingForbiddenFruit;

    SeasonType public mintingSeason;



    mapping(ForbiddenFruitType => mapping(SeasonType => uint256)) public forbiddenFruitTypeMinted;

    mapping(address => bool) public hasMintedForFree;



    function setMint() external onlyOwner {

        mintIsActive = !mintIsActive;

    }



    function toggleAllowlistMintActive() external onlyOwner {

        allowlistMintActive = !allowlistMintActive;

    }



    function setAllowlistCode(uint256 newCode) external onlyOwner {

        allowlistCode = newCode;

    }



    function mintForbiddenFruit(uint256 code) external nonReentrant {

        require(mintIsActive, "Mint is not active");

        if (allowlistMintActive) {

            require(code == allowlistCode, "Incorrect, generating new code");

        }

        require(!hasMintedForFree[msg.sender], "You have already minted one for free");

        require(msg.sender == tx.origin, "Minter must not be a contract");

        require(forbiddenFruitCounter <= MAX_FORBIDDEN_FRUITS_TOTAL, "Insufficient Forbidden Fruit supply");

        

        if (forbiddenFruitTypeMinted[mintingForbiddenFruit][mintingSeason] >= MAX_FORBIDDEN_FRUIT_SEASON_TYPE) {

            updateForbiddenFruitType();

        }



        require(forbiddenFruitTypeMinted[mintingForbiddenFruit][mintingSeason] < MAX_FORBIDDEN_FRUIT_SEASON_TYPE, 

                "Too many of this type");



        _safeMint(msg.sender, forbiddenFruitCounter);

        hasMintedForFree[msg.sender] = true;



        fruitInfo[forbiddenFruitCounter] = Fruit(false, false, mintingForbiddenFruit, mintingSeason);



        forbiddenFruitTypeMinted[mintingForbiddenFruit][mintingSeason]++;

        forbiddenFruitCounter++;

    }



    function updateForbiddenFruitType() private {

        if (mintingSeason == SeasonType.Winter) {

            mintingForbiddenFruit = getNextFruit(mintingForbiddenFruit);

        }



        mintingSeason = getNextSeason(mintingSeason);

    }



    function getNextSeason(SeasonType currSeason) private pure returns (SeasonType) {

        return SeasonType((uint256(currSeason) + 1) % 4);

    }



    function getNextFruit(ForbiddenFruitType currForbiddenFruit) private pure returns (ForbiddenFruitType) {

        return ForbiddenFruitType((uint256(currForbiddenFruit) + 1) % 8);

    }



    function mintGoldenApple() external payable nonReentrant {

        require(mintIsActive, "Mint is not active");

        require(msg.sender == tx.origin, "EOAOnly");

        require(goldenAppleCounter <= MAX_GOLDEN_APPLE, "All Golden Apples have been minted");



        if (forbiddenFruitCounter <= MAX_FORBIDDEN_FRUITS_TOTAL) {

            require(msg.value == 0.2 ether, 

                    "You must pay 0.2 ETH to mint a Golden Apple before all Forbidden Fruits are minted");

        }

        else if (forbiddenFruitCounter > MAX_FORBIDDEN_FRUITS_TOTAL && hasMintedForFree[msg.sender]) {

            require(msg.value == 0.2 ether, "You must pay 0.2 ETH to mint an extra Golden Apple");

        }

        else {

            require(!hasMintedForFree[msg.sender], "You have already minted for free");

            hasMintedForFree[msg.sender] = true;

        }



        _safeMint(msg.sender, goldenAppleCounter);



        if (msg.value == 0.2 ether) {

            emit PaidMint(msg.sender, goldenAppleCounter);

            paidCounter++;

        }



        fruitInfo[goldenAppleCounter] = Fruit(true, false, mintingForbiddenFruit, mintingSeason);

        goldenAppleCounter++;

    }



    function reserveMint() external onlyOwner {

        require(reserveCounter < MAX_ITEMS, "CHE");



        for (uint256 i = 0; i < 2; i++) {

            _safeMint(owner(), reserveCounter);

            fruitInfo[reserveCounter] = Fruit(false, true, mintingForbiddenFruit, mintingSeason);

            reserveCounter++;

        }

    }



    function setBaseURI(string memory baseURI) external onlyOwner {

        URI = baseURI;

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return URI;

    }



    function withdrawPaidMint() external onlyOwner {

        uint256 amountInWei = paidCounter * 0.2 ether;

        require(address(this).balance >= amountInWei, "Insufficient balance");

        payable(owner()).transfer(amountInWei);

        paidCounter = 0;

    }



    function setApprovalForAll(address operator, bool approved) public override(ERC721, IERC721) 

    onlyAllowedOperatorApproval(operator) 

    {

        super.setApprovalForAll(operator, approved);

    }



    function approve(address operator, uint256 tokenId) public override(ERC721, IERC721) 

    onlyAllowedOperatorApproval(operator) 

    {

        super.approve(operator, tokenId);

    }



    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) 

    onlyAllowedOperator(from) 

    {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) 

    onlyAllowedOperator(from) 

    {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)

        public

        override(ERC721, IERC721)

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId, data);

    }



    event RequestSent(uint256 requestId, uint32 numWords);

    event RequestFulfilled(uint256 requestId, uint256[] randomWords);



    struct RequestStatus {

        bool fulfilled; 

        bool exists; 

        uint256[] randomWords;

    }



    mapping(uint256 => RequestStatus) public s_requests; 

    VRFCoordinatorV2Interface COORDINATOR;



    function changeCoordinator(address newCoordinator) external onlyOwner {

        COORDINATOR = VRFCoordinatorV2Interface(newCoordinator);

    }



    uint64 s_subscriptionId;



    function changeSubscriptionID(uint64 newID) external onlyOwner {

        s_subscriptionId = newID;

    }



    uint256[] private requestIds;

    uint256 private lastRequestId;



    function getRequestIds(uint256 index) external view onlyOwner returns (uint256) {

        return requestIds[index];

    }



    function getLastRequestId() external view onlyOwner returns (uint256) {

        return lastRequestId;

    }



    bytes32 keyHash;



    function changeKeyHash(bytes32 newKeyHash) external onlyOwner {

        keyHash = newKeyHash;

    }



    uint32 callbackGasLimit;



    function changeGasLimit(uint32 newLimit) external onlyOwner {

        callbackGasLimit = newLimit;

    }



    uint16 requestConfirmations;



    function changeRequestConfirmations(uint16 newLimit) external onlyOwner {

        requestConfirmations = newLimit;

    }



    uint32 numWords;



    function changeNumWords(uint32 newNum) external onlyOwner {

        numWords = newNum;

    }



    function requestRandomWords()

        external

        onlyOwner

        returns (uint256 requestId)

    {

        requestId = COORDINATOR.requestRandomWords(

            keyHash,

            s_subscriptionId,

            requestConfirmations,

            callbackGasLimit,

            numWords

        );

        s_requests[requestId] = RequestStatus({

            randomWords: new uint256[](0),

            exists: true,

            fulfilled: false

        });

        requestIds.push(requestId);

        lastRequestId = requestId;

        emit RequestSent(requestId, numWords);

        return requestId;

    }



    function fulfillRandomWords(

        uint256 _requestId,

        uint256[] memory _randomWords

    ) internal override {

        require(s_requests[_requestId].exists, "request not found");

        s_requests[_requestId].fulfilled = true;

        s_requests[_requestId].randomWords = _randomWords;

        emit RequestFulfilled(_requestId, _randomWords);

    }



    function getRequestStatus(

        uint256 _requestId

    ) external view onlyOwner returns (bool fulfilled, uint256[] memory randomWords) {

        require(s_requests[_requestId].exists, "request not found");

        RequestStatus memory request = s_requests[_requestId];

        return (request.fulfilled, request.randomWords);

    }



    event DividendClaimed(address indexed claimer, uint256 amount);



    uint256[] private percentageForbidden = [40357, 21428, 14285, 11071, 7142, 4285, 2857, 1429];

    uint256[] private ranksForbidden;



    uint256 private constant percentageSeason = 10000;

    uint256 private constant percentageGold  = 20000;

    uint256 private constant percentageReserve = 2000000;

    uint256 private constant div = 100000000;

    SeasonType private currentSeason;



    bool public DDE;

    uint256 public dividendAmount;



    mapping(uint256 => bool) private isBlacklisted;

    mapping(uint256 => bool) private dividendAlreadyClaimed;



    function startDDE() external onlyOwner {

        require(!DDE, "DDE is ongoing");

        DDE = true;

        dividendAmount = address(this).balance;

    }



    function finishDDE() external onlyOwner {

        require(DDE, "DDE already ended");

        DDE = false;



        for (uint256 i = 1; i <= MAX_ITEMS; i++) {

            dividendAlreadyClaimed[i] = false;

        }



        dividendAmount = 0;

    }



    function checkDividend() external view returns (uint256) {

        require(DDE, "Dividend not claimable at the moment");



        uint256[] memory tokenIds = checkNFTTokens(msg.sender);

        uint256 tokensOwned = tokenIds.length;



        uint256 amountToSend = 0;



        for (uint256 i = 0; i < tokensOwned; i++) {

            uint256 tokenId = tokenIds[i];



            if (!dividendAlreadyClaimed[tokenId] && !isBlacklisted[tokenId]) {

                amountToSend += calculateAmountToSend(tokenId);

            }

        }



        amountToSend = dividendAmount * amountToSend / div;



        return amountToSend;

    }



    function calculateAmountToSend(uint256 tokenId) private view returns (uint256) {

        Fruit memory fruit = fruitInfo[tokenId];

        uint256 amountToSend = 0;



        if (fruit.isGoldenApple && !fruit.isReserve) {

            amountToSend += percentageGold;

        } else if (!fruit.isGoldenApple && fruit.isReserve) {

            amountToSend += percentageReserve;

        } else if (!fruit.isGoldenApple && !fruit.isReserve) {

            uint256 fruitTypeIndex = uint256(fruit.fruitType);

            uint256 rankIndex = ranksForbidden[fruitTypeIndex];

            amountToSend += percentageForbidden[rankIndex];



            if (fruit.season == currentSeason) {

                amountToSend += percentageSeason;

            }

        }



        return amountToSend;

    }



    function claimDividend() external nonReentrant {

        require(DDE, "Dividend not claimable at the moment");



        uint256[] memory tokenIds = checkNFTTokens(msg.sender);

        uint256 tokensOwned = tokenIds.length;



        require(tokensOwned > 0, "You don't have any tokens from this contract in your wallet");



        uint256 amountToSend = 0;



        for (uint256 i = 0; i < tokensOwned; i++) {

            uint256 tokenId = tokenIds[i];



            if (!dividendAlreadyClaimed[tokenId] && !isBlacklisted[tokenId]) {

                amountToSend += calculateAmountToSend(tokenId);

                dividendAlreadyClaimed[tokenId] = true;

            }

        }



        amountToSend = dividendAmount * amountToSend / div;



        require(amountToSend > 0, "No dividend to claim");



        uint256 contractBalance = address(this).balance;

        require(contractBalance >= amountToSend, "Insufficient contract balance to pay the dividend");



        payable(msg.sender).transfer(amountToSend);

        emit DividendClaimed(msg.sender, amountToSend);

    }



    function hasTokenClaimedDividend(uint256 tokenId) external view returns (bool) {

        require(DDE, "Dividend not claimable at the moment");

        return dividendAlreadyClaimed[tokenId];

    }



    function blacklistTokens(uint256[] memory tokenIds) external onlyOwner {

        for (uint256 i = 0; i < tokenIds.length; i++) {

            isBlacklisted[tokenIds[i]] = true;

        }

    }



    function unblacklistTokens(uint256[] memory tokenIds) external onlyOwner {

        for (uint256 i = 0; i < tokenIds.length; i++) {

            isBlacklisted[tokenIds[i]] = false;

        }

    }



    function isTokenBlacklisted(uint256 tokenId) external view returns (bool) {

        return isBlacklisted[tokenId];

    }



    function shuffleRankings() external onlyOwner {

        require(s_requests[lastRequestId].exists, "Request not found");

        require(s_requests[lastRequestId].fulfilled, "Request not fulfilled");



        uint256[] memory ranNums = s_requests[lastRequestId].randomWords;



        uint256[] memory arr = ranksForbidden;



        for (uint256 i = 0; i < arr.length; i++) {

            uint256 j = i + (ranNums[i] % (arr.length - i));



            uint256 temp = arr[j];

            arr[j] = arr[i];

            arr[i] = temp;

        }



        ranksForbidden = arr;



        uint256 newSeasonIndex = ranNums[8] % 4;



        currentSeason = SeasonType(newSeasonIndex);

    }



    function shuffleRankingsManual() external onlyOwner {

        uint256[] memory arr = ranksForbidden;



        for (uint256 i = 0; i < arr.length; i++) {

            uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, 

                                                                      block.difficulty, 

                                                                      block.gaslimit, 

                                                                      i)));

            uint256 j = i + (randomNumber % (arr.length - i));



            uint256 temp = arr[j];

            arr[j] = arr[i];

            arr[i] = temp;

        }



        ranksForbidden = arr;



        uint256 randomNumber1 = uint256(keccak256(abi.encodePacked(block.timestamp, 

                                                                   block.difficulty, 

                                                                   block.gaslimit)));



        uint256 newSeasonIndex = randomNumber1 % 4;



        currentSeason = SeasonType(newSeasonIndex);

    }



    function getRankings() external view returns (uint256[] memory) {

        return ranksForbidden;

    }



    function getCurrentSeason() external view returns (SeasonType) {

        return currentSeason;

    }



    function checkNFTTokens(address user) public view returns (uint256[] memory) {

        uint256 balance = balanceOf(user);



        uint256[] memory tokenIds = new uint256[](balance);



        for (uint256 i = 0; i < balance; i++) {

            tokenIds[i] = tokenOfOwnerByIndex(user, i);

        }



        return tokenIds;

    }



    function withdrawERC20(

        IERC20 token,

        address to,

        uint256 amount

    ) external onlyOwner {

        require(to != address(0), "Invalid address");

        require(amount > 0, "Amount should be greater than 0");



        token.transfer(to, amount);

    }

    

    function deposit() public payable {}

    receive() external payable {}

    fallback() external payable {}

}