/**

 *Submitted for verification at Etherscan.io on 2023-07-15

*/



// File: ShuffleSale/ShuffleSale/Shuffler.sol





// Copyright (c) 2023 Fellowship



pragma solidity ^0.8.20;



/// @notice A contract that draws (without replacement) pseudorandom shuffled values

/// @dev Uses prevrandao and Fisher-Yates shuffle to return values one at a time

contract Shuffler {

    uint256 internal remainingValueCount;

    uint16[] private shuffleValues;



    function _setUp(uint16[] calldata remainingValues) internal {

        shuffleValues = remainingValues;

        remainingValueCount = remainingValues.length;

    }



    function drawNext() internal returns (uint256) {

        require(remainingValueCount > 0, "Shuffled values have been exhausted");



        uint16 swapValue;

        swapValue = shuffleValues[remainingValueCount - 1];



        if (remainingValueCount == 1) {

            remainingValueCount = 0;

            return swapValue;

        }



        uint256 randomIndex = uint256(keccak256(abi.encodePacked(remainingValueCount, block.prevrandao))) %

            remainingValueCount;

        remainingValueCount--;



        uint256 drawnValue = shuffleValues[randomIndex];

        shuffleValues[randomIndex] = swapValue;



        return drawnValue;

    }

}

// File: ShuffleSale/ShuffleSale/interfaces/IShuffleSale.sol





pragma solidity ^0.8.17;



interface IShuffleSale {

    event Purchase(address indexed purchaser, address tokenContract, uint256 tokenId, uint256 price);

    error SoldOut();

    struct Collection {

        address tokenAddress;

        uint96 offset;

    }



    function mint() external payable;

    function mintMultipleFromPasses(uint256 quantity, uint256[] calldata passIds) external payable;

    

    function COLLECTIONS(uint256 index) external view returns (Collection memory);

    function publicMints(address minter) external view returns (uint256);

}

// File: ShuffleSale/ShuffleSale/interfaces/IDelegationRegistry.sol





pragma solidity ^0.8.17;



/**

 * @title An immutable registry contract to be deployed as a standalone primitive

 * @dev See EIP-5639, new project launches can read previous cold wallet -> hot wallet delegations

 * from here and integrate those permissions into their flow

 */

interface IDelegationRegistry {

    /// @notice Delegation type

    enum DelegationType {

        NONE,

        ALL,

        CONTRACT,

        TOKEN

    }



    /// @notice Info about a single delegation, used for onchain enumeration

    struct DelegationInfo {

        DelegationType type_;

        address vault;

        address delegate;

        address contract_;

        uint256 tokenId;

    }



    /// @notice Info about a single contract-level delegation

    struct ContractDelegation {

        address contract_;

        address delegate;

    }



    /// @notice Info about a single token-level delegation

    struct TokenDelegation {

        address contract_;

        uint256 tokenId;

        address delegate;

    }



    /// @notice Emitted when a user delegates their entire wallet

    event DelegateForAll(address vault, address delegate, bool value);



    /// @notice Emitted when a user delegates a specific contract

    event DelegateForContract(address vault, address delegate, address contract_, bool value);



    /// @notice Emitted when a user delegates a specific token

    event DelegateForToken(address vault, address delegate, address contract_, uint256 tokenId, bool value);



    /// @notice Emitted when a user revokes all delegations

    event RevokeAllDelegates(address vault);



    /// @notice Emitted when a user revoes all delegations for a given delegate

    event RevokeDelegate(address vault, address delegate);



    /**

     * -----------  WRITE -----------

     */



    /**

     * @notice Allow the delegate to act on your behalf for all contracts

     * @param delegate The hotwallet to act on your behalf

     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking

     */

    function delegateForAll(address delegate, bool value) external;



    /**

     * @notice Allow the delegate to act on your behalf for a specific contract

     * @param delegate The hotwallet to act on your behalf

     * @param contract_ The address for the contract you're delegating

     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking

     */

    function delegateForContract(address delegate, address contract_, bool value) external;



    /**

     * @notice Allow the delegate to act on your behalf for a specific token

     * @param delegate The hotwallet to act on your behalf

     * @param contract_ The address for the contract you're delegating

     * @param tokenId The token id for the token you're delegating

     * @param value Whether to enable or disable delegation for this address, true for setting and false for revoking

     */

    function delegateForToken(address delegate, address contract_, uint256 tokenId, bool value) external;



    /**

     * @notice Revoke all delegates

     */

    function revokeAllDelegates() external;



    /**

     * @notice Revoke a specific delegate for all their permissions

     * @param delegate The hotwallet to revoke

     */

    function revokeDelegate(address delegate) external;



    /**

     * @notice Remove yourself as a delegate for a specific vault

     * @param vault The vault which delegated to the msg.sender, and should be removed

     */

    function revokeSelf(address vault) external;



    /**

     * -----------  READ -----------

     */



    /**

     * @notice Returns all active delegations a given delegate is able to claim on behalf of

     * @param delegate The delegate that you would like to retrieve delegations for

     * @return info Array of DelegationInfo structs

     */

    function getDelegationsByDelegate(address delegate) external view returns (DelegationInfo[] memory);



    /**

     * @notice Returns an array of wallet-level delegates for a given vault

     * @param vault The cold wallet who issued the delegation

     * @return addresses Array of wallet-level delegates for a given vault

     */

    function getDelegatesForAll(address vault) external view returns (address[] memory);



    /**

     * @notice Returns an array of contract-level delegates for a given vault and contract

     * @param vault The cold wallet who issued the delegation

     * @param contract_ The address for the contract you're delegating

     * @return addresses Array of contract-level delegates for a given vault and contract

     */

    function getDelegatesForContract(address vault, address contract_) external view returns (address[] memory);



    /**

     * @notice Returns an array of contract-level delegates for a given vault's token

     * @param vault The cold wallet who issued the delegation

     * @param contract_ The address for the contract holding the token

     * @param tokenId The token id for the token you're delegating

     * @return addresses Array of contract-level delegates for a given vault's token

     */

    function getDelegatesForToken(address vault, address contract_, uint256 tokenId)

        external

        view

        returns (address[] memory);



    /**

     * @notice Returns all contract-level delegations for a given vault

     * @param vault The cold wallet who issued the delegations

     * @return delegations Array of ContractDelegation structs

     */

    function getContractLevelDelegations(address vault)

        external

        view

        returns (ContractDelegation[] memory delegations);



    /**

     * @notice Returns all token-level delegations for a given vault

     * @param vault The cold wallet who issued the delegations

     * @return delegations Array of TokenDelegation structs

     */

    function getTokenLevelDelegations(address vault) external view returns (TokenDelegation[] memory delegations);



    /**

     * @notice Returns true if the address is delegated to act on the entire vault

     * @param delegate The hotwallet to act on your behalf

     * @param vault The cold wallet who issued the delegation

     */

    function checkDelegateForAll(address delegate, address vault) external view returns (bool);



    /**

     * @notice Returns true if the address is delegated to act on your behalf for a token contract or an entire vault

     * @param delegate The hotwallet to act on your behalf

     * @param contract_ The address for the contract you're delegating

     * @param vault The cold wallet who issued the delegation

     */

    function checkDelegateForContract(address delegate, address vault, address contract_)

        external

        view

        returns (bool);



    /**

     * @notice Returns true if the address is delegated to act on your behalf for a specific token, the token's contract or an entire vault

     * @param delegate The hotwallet to act on your behalf

     * @param contract_ The address for the contract you're delegating

     * @param tokenId The token id for the token you're delegating

     * @param vault The cold wallet who issued the delegation

     */

    function checkDelegateForToken(address delegate, address vault, address contract_, uint256 tokenId)

        external

        view

        returns (bool);

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



// File: @openzeppelin/contracts/security/Pausable.sol





// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)



pragma solidity ^0.8.0;





/**

 * @dev Contract module which allows children to implement an emergency stop

 * mechanism that can be triggered by an authorized account.

 *

 * This module is used through inheritance. It will make available the

 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to

 * the functions of your contract. Note that they will not be pausable by

 * simply including this module, only once the modifiers are put in place.

 */

abstract contract Pausable is Context {

    /**

     * @dev Emitted when the pause is triggered by `account`.

     */

    event Paused(address account);



    /**

     * @dev Emitted when the pause is lifted by `account`.

     */

    event Unpaused(address account);



    bool private _paused;



    /**

     * @dev Initializes the contract in unpaused state.

     */

    constructor() {

        _paused = false;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     *

     * Requirements:

     *

     * - The contract must not be paused.

     */

    modifier whenNotPaused() {

        _requireNotPaused();

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     *

     * Requirements:

     *

     * - The contract must be paused.

     */

    modifier whenPaused() {

        _requirePaused();

        _;

    }



    /**

     * @dev Returns true if the contract is paused, and false otherwise.

     */

    function paused() public view virtual returns (bool) {

        return _paused;

    }



    /**

     * @dev Throws if the contract is paused.

     */

    function _requireNotPaused() internal view virtual {

        require(!paused(), "Pausable: paused");

    }



    /**

     * @dev Throws if the contract is not paused.

     */

    function _requirePaused() internal view virtual {

        require(paused(), "Pausable: not paused");

    }



    /**

     * @dev Triggers stopped state.

     *

     * Requirements:

     *

     * - The contract must not be paused.

     */

    function _pause() internal virtual whenNotPaused {

        _paused = true;

        emit Paused(_msgSender());

    }



    /**

     * @dev Returns to normal state.

     *

     * Requirements:

     *

     * - The contract must be paused.

     */

    function _unpause() internal virtual whenPaused {

        _paused = false;

        emit Unpaused(_msgSender());

    }

}



// File: @openzeppelin/contracts/access/Ownable.sol





// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)



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

     * `onlyOwner` functions. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby disabling any functionality that is only available to the owner.

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



// File: ShuffleSale/ShuffleSale/ShuffleSaleContinued.sol







pragma solidity ^0.8.20;













contract ShuffleSaleContinued is IShuffleSale, Shuffler, Ownable, Pausable {

    address private constant DELEGATION_REGISTRY = 0x00000000000076A84feF008CDAbe6409d2FE638B;

    address private constant FPP = 0xA8A425864dB32fCBB459Bf527BdBb8128e6abF21;

    uint256 private constant FPP_PROJECT_ID = 4;

    address private constant ORIGINAL_SALE = 0xB9a0A4D74291307f004fCD8909Fa39Bfc91deA1b;

    uint256 public immutable START_TIME;



    uint256 public passLimit = 5;

    uint256 public publicLimit = 4;

    uint256 public priceForFPPHolder = 0.1 ether;

    uint256 public priceForPublic = 0.2 ether;



    mapping(address => uint256) private _publicMints;



    constructor(

        uint256 startTime

    ) {

        START_TIME = startTime;

    }



    // PUBLIC FUNCTIONS



    function mint() external override payable whenNotPaused {

        if (remainingValueCount == 0) revert SoldOut();

        uint256 price = priceForPublic;

        require(msg.value == price, "Insufficient payment");

        require(isStarted(), "Not started");

        require(publicMints(msg.sender) < publicLimit);

        _publicMints[msg.sender]++;

        _mint(price);

    }



    function mintMultipleFromPasses(

        uint256 quantity,

        uint256[] calldata passIds

    ) external override payable whenNotPaused {

        uint256 remaining = remainingValueCount;

        if (remaining == 0) revert SoldOut();

        require(isStarted(), "Not started");

        uint256 price = priceForFPPHolder;



        if (quantity > remaining) {

            quantity = remaining;

        }



        uint256 passUses;

        for (uint256 i; i < passIds.length; ++i) {

            uint256 passId = passIds[i];



            uint256 allowance = passAllowance(passId);



            for (uint256 j; j < allowance && passUses < quantity; ++j) {

                IFPP(FPP).logPassUse(passId, FPP_PROJECT_ID);

                passUses++;

                _mint(price);

            }



            if (passUses == quantity) break;

        }



        uint256 totalCost = price * passUses;

        require(

            msg.value >= totalCost,

            "Insufficient payment"

        );



        uint256 refund = msg.value - totalCost;

        if (refund > 0) {

            (bool refunded, ) = msg.sender.call{value: refund}("");

            require(refunded, "Refund failed");

        }

    }



    // OWNER ONLY FUNCTIONS



    function emergencyPause() external onlyOwner {

        _pause();

    }



    function setUp(

        uint16[] calldata remainingValues

    ) external onlyOwner {

        _setUp(remainingValues);

    }



    function updatePassLimit(

        uint256 newLimit

    ) external onlyOwner {

        passLimit = newLimit;

    }



    function updatePublicLimit(

        uint256 newLimit

    ) external onlyOwner {

        publicLimit = newLimit;

    }



    function updatePrices(

        uint256 fppPrice,

        uint256 pubPrice

    ) external onlyOwner {

        priceForFPPHolder = fppPrice;

        priceForPublic = pubPrice;

    }



    function withdraw(

        address recipient

    ) external onlyOwner {

        (bool success,) = recipient.call{value: address(this).balance}("");

        require(success, "Withdraw failed");

    }



    // INTERNAL FUNCTIONS



    function _mint(uint256 price) internal {

        uint256 metaId = drawNext();

        (address tokenContract, uint256 tokenId) = getTokenFromMetaId(metaId);

        emit Purchase(msg.sender, tokenContract, tokenId, price);

        IMint(tokenContract).mint(msg.sender, tokenId);

    }



    function getTokenFromMetaId(

        uint256 metaId

    ) internal view returns (address, uint256) {

        Collection memory collection = IShuffleSale(ORIGINAL_SALE).COLLECTIONS(metaId / 100);

        // + 1 on tokenId to account for 1-indexing

        return (

            collection.tokenAddress,

            metaId % 100 + collection.offset + 1

        );

    }



    function isStarted() internal view returns (bool) {

        return block.timestamp >= START_TIME;

    }



    function passAllowance(

        uint256 passId

    ) internal view returns (uint256) {

        address passOwner = IFPP(FPP).ownerOf(passId);

        require(

            passOwner == msg.sender ||

            IDelegationRegistry(DELEGATION_REGISTRY).checkDelegateForToken(

                msg.sender,

                passOwner,

                FPP,

                passId

            ),

            "Pass not owned or delegated"

        );

        uint256 uses = IFPP(FPP).passUses(passId, FPP_PROJECT_ID);

        return uses >= passLimit ? 0 : passLimit - uses;

    }



    function COLLECTIONS(uint256 index) external override view returns (Collection memory) {

        return IShuffleSale(ORIGINAL_SALE).COLLECTIONS(index);

    }



    function publicMints(address minter) public override view returns (uint256) {

        return _publicMints[minter] + IShuffleSale(ORIGINAL_SALE).publicMints(minter);

    }

}



interface IFPP {

  function logPassUse(uint256 tokenId, uint256 projectId) external;

  function ownerOf(uint256 tokenId) external view returns (address);

  function passUses(uint256 tokenId, uint256 projectId) external view returns (uint256);

}



interface IMint {

    function mint(address to, uint256 tokenId) external;

}