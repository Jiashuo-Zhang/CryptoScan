/**

 *Submitted for verification at Etherscan.io on 2020-03-31

*/



/*

⚠⚠⚠ WARNING WARNING WARNING ⚠⚠⚠

This is a TARGET contract - DO NOT CONNECT TO IT DIRECTLY IN YOUR CONTRACTS or DAPPS!

This contract has an associated PROXY that MUST be used for all integrations - this TARGET will be REPLACED in an upcoming Synthetix release!
The proxy for this contract can be found here:

https://contracts.synthetix.io/ProxyFeePool

*//*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: FeePool.sol
*
* Latest source (may be newer): https://github.com/Synthetixio/synthetix/blob/master/contracts/FeePool.sol
* Docs: https://docs.synthetix.io/contracts/FeePool
*
* Contract Dependencies: 
*	- EternalStorage
*	- ExternStateToken
*	- LimitedSetup
*	- MixinResolver
*	- Owned
*	- Proxyable
*	- SelfDestructible
*	- State
* Libraries: 
*	- Math
*	- SafeDecimalMath
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity 0.4.25;


// https://docs.synthetix.io/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    /**
     * @dev Owned Constructor
     */
    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    /**
     * @notice Nominate a new owner of this contract.
     * @dev Only the current owner may nominate a new owner.
     */
    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    /**
     * @notice Accept the nomination to be owner.
     */
    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


// https://docs.synthetix.io/contracts/Proxy
contract Proxy is Owned {
    Proxyable public target;
    bool public useDELEGATECALL;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(Proxyable _target) external onlyOwner {
        target = _target;
        emit TargetUpdated(_target);
    }

    function setUseDELEGATECALL(bool value) external onlyOwner {
        useDELEGATECALL = value;
    }

    function _emit(bytes callData, uint numTopics, bytes32 topic1, bytes32 topic2, bytes32 topic3, bytes32 topic4)
        external
        onlyTarget
    {
        uint size = callData.length;
        bytes memory _callData = callData;

        assembly {
            /* The first 32 bytes of callData contain its length (as specified by the abi).
             * Length is assumed to be a uint256 and therefore maximum of 32 bytes
             * in length. It is also leftpadded to be a multiple of 32 bytes.
             * This means moving call_data across 32 bytes guarantees we correctly access
             * the data itself. */
            switch numTopics
                case 0 {
                    log0(add(_callData, 32), size)
                }
                case 1 {
                    log1(add(_callData, 32), size, topic1)
                }
                case 2 {
                    log2(add(_callData, 32), size, topic1, topic2)
                }
                case 3 {
                    log3(add(_callData, 32), size, topic1, topic2, topic3)
                }
                case 4 {
                    log4(add(_callData, 32), size, topic1, topic2, topic3, topic4)
                }
        }
    }

    function() external payable {
        if (useDELEGATECALL) {
            assembly {
                /* Copy call data into free memory region. */
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                /* Forward all gas and call data to the target contract. */
                let result := delegatecall(gas, sload(target_slot), free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                /* Revert if the call failed, otherwise return the result. */
                if iszero(result) {
                    revert(free_ptr, returndatasize)
                }
                return(free_ptr, returndatasize)
            }
        } else {
            /* Here we are as above, but must send the messageSender explicitly
             * since we are using CALL rather than DELEGATECALL. */
            target.setMessageSender(msg.sender);
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                /* We must explicitly forward ether to the underlying contract as well. */
                let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
                returndatacopy(free_ptr, 0, returndatasize)

                if iszero(result) {
                    revert(free_ptr, returndatasize)
                }
                return(free_ptr, returndatasize)
            }
        }
    }

    modifier onlyTarget {
        require(Proxyable(msg.sender) == target, "Must be proxy target");
        _;
    }

    event TargetUpdated(Proxyable newTarget);
}


// https://docs.synthetix.io/contracts/Proxyable
contract Proxyable is Owned {
    // This contract should be treated like an abstract contract

    /* The proxy this contract exists behind. */
    Proxy public proxy;
    Proxy public integrationProxy;

    /* The caller of the proxy, passed through to this contract.
     * Note that every function using this member must apply the onlyProxy or
     * optionalProxy modifiers, otherwise their invocations can use stale values. */
    address public messageSender;

    constructor(address _proxy, address _owner) public Owned(_owner) {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address _proxy) external onlyOwner {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setIntegrationProxy(address _integrationProxy) external onlyOwner {
        integrationProxy = Proxy(_integrationProxy);
    }

    function setMessageSender(address sender) external onlyProxy {
        messageSender = sender;
    }

    modifier onlyProxy {
        require(Proxy(msg.sender) == proxy || Proxy(msg.sender) == integrationProxy, "Only the proxy can call");
        _;
    }

    modifier optionalProxy {
        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        _;
    }

    modifier optionalProxy_onlyOwner {
        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == owner, "Owner only function");
        _;
    }

    event ProxyUpdated(address proxyAddress);
}


// https://docs.synthetix.io/contracts/SelfDestructible
contract SelfDestructible is Owned {
    uint public initiationTime;
    bool public selfDestructInitiated;
    address public selfDestructBeneficiary;
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    /**
     * @dev Constructor
     * @param _owner The account which controls this contract.
     */
    constructor(address _owner) public Owned(_owner) {
        require(_owner != address(0), "Owner must not be zero");
        selfDestructBeneficiary = _owner;
        emit SelfDestructBeneficiaryUpdated(_owner);
    }

    /**
     * @notice Set the beneficiary address of this contract.
     * @dev Only the contract owner may call this. The provided beneficiary must be non-null.
     * @param _beneficiary The address to pay any eth contained in this contract to upon self-destruction.
     */
    function setSelfDestructBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    /**
     * @notice Begin the self-destruction counter of this contract.
     * Once the delay has elapsed, the contract may be self-destructed.
     * @dev Only the contract owner may call this.
     */
    function initiateSelfDestruct() external onlyOwner {
        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    /**
     * @notice Terminate and reset the self-destruction timer.
     * @dev Only the contract owner may call this.
     */
    function terminateSelfDestruct() external onlyOwner {
        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    /**
     * @notice If the self-destruction delay has elapsed, destroy this contract and
     * remit any ether it owns to the beneficiary address.
     * @dev Only the contract owner may call this.
     */
    function selfDestruct() external onlyOwner {
        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        address beneficiary = selfDestructBeneficiary;
        emit SelfDestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
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
}


// https://docs.synthetix.io/contracts/SafeDecimalMath
library SafeDecimalMath {
    using SafeMath for uint;

    /* Number of decimal places in the representations. */
    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    /* The number representing 1.0. */
    uint public constant UNIT = 10**uint(decimals);

    /* The number representing 1.0 for higher fidelity numbers. */
    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    /**
     * @return Provides an interface to UNIT.
     */
    function unit() external pure returns (uint) {
        return UNIT;
    }

    /**
     * @return Provides an interface to PRECISE_UNIT.
     */
    function preciseUnit() external pure returns (uint) {
        return PRECISE_UNIT;
    }

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y) / UNIT;
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of the specified precision unit.
     *
     * @dev The operands should be in the form of a the specified unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function _multiplyDecimalRound(uint x, uint y, uint precisionUnit) private pure returns (uint) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a precise unit.
     *
     * @dev The operands should be in the precise unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    /**
     * @return The result of safely multiplying x and y, interpreting the operands
     * as fixed-point decimals of a standard unit.
     *
     * @dev The operands should be in the standard unit factor which will be
     * divided out after the product of x and y is evaluated, so that product must be
     * less than 2**256.
     *
     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.
     * Rounding is useful when you need to retain fidelity for small decimal numbers
     * (eg. small fractions or percentages).
     */
    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function divideDecimal(uint x, uint y) internal pure returns (uint) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(UNIT).div(y);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * decimal in the precision unit specified in the parameter.
     *
     * @dev y is divided after the product of x and the specified precision unit
     * is evaluated, so the product of x and the specified precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function _divideDecimalRound(uint x, uint y, uint precisionUnit) private pure returns (uint) {
        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * standard precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and the standard precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is as a rounded
     * high precision decimal.
     *
     * @dev y is divided after the product of x and the high precision unit
     * is evaluated, so the product of x and the high precision unit must
     * be less than 2**256. The result is rounded to the nearest increment.
     */
    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {
        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {
        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}


// https://docs.synthetix.io/contracts/AddressResolver
contract AddressResolver is Owned {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== MUTATIVE FUNCTIONS ========== */

    function importAddresses(bytes32[] names, address[] destinations) public onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    /* ========== VIEWS ========== */

    function getAddress(bytes32 name) public view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string reason) public view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }
}


// https://docs.synthetix.io/contracts/MixinResolver
contract MixinResolver is Owned {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    bytes32[] public resolverAddressesRequired;

    uint public constant MAX_ADDRESSES_FROM_RESOLVER = 24;

    constructor(address _owner, address _resolver, bytes32[MAX_ADDRESSES_FROM_RESOLVER] _addressesToCache)
        public
        Owned(_owner)
    {
        for (uint i = 0; i < _addressesToCache.length; i++) {
            if (_addressesToCache[i] != bytes32(0)) {
                resolverAddressesRequired.push(_addressesToCache[i]);
            } else {
                // End early once an empty item is found - assumes there are no empty slots in
                // _addressesToCache
                break;
            }
        }
        resolver = AddressResolver(_resolver);
        // Do not sync the cache as addresses may not be in the resolver yet
    }

    /* ========== SETTERS ========== */
    function setResolverAndSyncCache(AddressResolver _resolver) external onlyOwner {
        resolver = _resolver;

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            addressCache[name] = resolver.requireAndGetAddress(name, "Resolver missing target");
        }
    }

    /* ========== VIEWS ========== */

    function requireAndGetAddress(bytes32 name, string reason) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    // Note: this could be made external in a utility contract if addressCache was made public
    // (used for deployment)
    function isResolverCached(AddressResolver _resolver) external view returns (bool) {
        if (resolver != _resolver) {
            return false;
        }

        // otherwise, check everything
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    // Note: can be made external into a utility contract (used for deployment)
    function getResolverAddressesRequired() external view returns (bytes32[MAX_ADDRESSES_FROM_RESOLVER] addressesRequired) {
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            addressesRequired[i] = resolverAddressesRequired[i];
        }
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    function appendToAddressCache(bytes32 name) internal {
        resolverAddressesRequired.push(name);
        require(resolverAddressesRequired.length < MAX_ADDRESSES_FROM_RESOLVER, "Max resolver cache size met");
        // Because this is designed to be called internally in constructors, we don't
        // check the address exists already in the resolver
        addressCache[name] = resolver.getAddress(name);
    }
}


// https://docs.synthetix.io/contracts/State
contract State is Owned {
    // the address of the contract that can modify variables
    // this can only be changed by the owner of this contract
    address public associatedContract;

    constructor(address _owner, address _associatedContract) public Owned(_owner) {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== SETTERS ========== */

    // Change the associated contract to a new address
    function setAssociatedContract(address _associatedContract) external onlyOwner {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyAssociatedContract {
        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }

    /* ========== EVENTS ========== */

    event AssociatedContractUpdated(address associatedContract);
}


// https://docs.synthetix.io/contracts/TokenState
contract TokenState is State {
    /* ERC20 fields. */
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    /**
     * @dev Constructor
     * @param _owner The address which controls this contract.
     * @param _associatedContract The ERC20 contract whose state this composes.
     */
    constructor(address _owner, address _associatedContract) public State(_owner, _associatedContract) {}

    /* ========== SETTERS ========== */

    /**
     * @notice Set ERC20 allowance.
     * @dev Only the associated contract may call this.
     * @param tokenOwner The authorising party.
     * @param spender The authorised party.
     * @param value The total value the authorised party may spend on the
     * authorising party's behalf.
     */
    function setAllowance(address tokenOwner, address spender, uint value) external onlyAssociatedContract {
        allowance[tokenOwner][spender] = value;
    }

    /**
     * @notice Set the balance in a given account
     * @dev Only the associated contract may call this.
     * @param account The account whose value to set.
     * @param value The new balance of the given account.
     */
    function setBalanceOf(address account, uint value) external onlyAssociatedContract {
        balanceOf[account] = value;
    }
}


// https://docs.synthetix.io/contracts/ExternStateToken
contract ExternStateToken is SelfDestructible, Proxyable {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    /* ========== STATE VARIABLES ========== */

    /* Stores balances and allowances. */
    TokenState public tokenState;

    /* Other ERC20 fields. */
    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals;

    /**
     * @dev Constructor.
     * @param _proxy The proxy associated with this contract.
     * @param _name Token's ERC20 name.
     * @param _symbol Token's ERC20 symbol.
     * @param _totalSupply The total supply of the token.
     * @param _tokenState The TokenState contract address.
     * @param _owner The owner of this contract.
     */
    constructor(
        address _proxy,
        TokenState _tokenState,
        string _name,
        string _symbol,
        uint _totalSupply,
        uint8 _decimals,
        address _owner
    ) public SelfDestructible(_owner) Proxyable(_proxy, _owner) {
        tokenState = _tokenState;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }

    /* ========== VIEWS ========== */

    /**
     * @notice Returns the ERC20 allowance of one party to spend on behalf of another.
     * @param owner The party authorising spending of their funds.
     * @param spender The party spending tokenOwner's funds.
     */
    function allowance(address owner, address spender) public view returns (uint) {
        return tokenState.allowance(owner, spender);
    }

    /**
     * @notice Returns the ERC20 token balance of a given account.
     */
    function balanceOf(address account) public view returns (uint) {
        return tokenState.balanceOf(account);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice Set the address of the TokenState contract.
     * @dev This can be used to "pause" transfer functionality, by pointing the tokenState at 0x000..
     * as balances would be unreachable.
     */
    function setTokenState(TokenState _tokenState) external optionalProxy_onlyOwner {
        tokenState = _tokenState;
        emitTokenStateUpdated(_tokenState);
    }

    function _internalTransfer(address from, address to, uint value) internal returns (bool) {
        /* Disallow transfers to irretrievable-addresses. */
        require(to != address(0) && to != address(this) && to != address(proxy), "Cannot transfer to this address");

        // Insufficient balance will be handled by the safe subtraction.
        tokenState.setBalanceOf(from, tokenState.balanceOf(from).sub(value));
        tokenState.setBalanceOf(to, tokenState.balanceOf(to).add(value));

        // Emit a standard ERC20 transfer event
        emitTransfer(from, to, value);

        return true;
    }

    /**
     * @dev Perform an ERC20 token transfer. Designed to be called by transfer functions possessing
     * the onlyProxy or optionalProxy modifiers.
     */
    function _transfer_byProxy(address from, address to, uint value) internal returns (bool) {
        return _internalTransfer(from, to, value);
    }

    /**
     * @dev Perform an ERC20 token transferFrom. Designed to be called by transferFrom functions
     * possessing the optionalProxy or optionalProxy modifiers.
     */
    function _transferFrom_byProxy(address sender, address from, address to, uint value) internal returns (bool) {
        /* Insufficient allowance will be handled by the safe subtraction. */
        tokenState.setAllowance(from, sender, tokenState.allowance(from, sender).sub(value));
        return _internalTransfer(from, to, value);
    }

    /**
     * @notice Approves spender to transfer on the message sender's behalf.
     */
    function approve(address spender, uint value) public optionalProxy returns (bool) {
        address sender = messageSender;

        tokenState.setAllowance(sender, spender, value);
        emitApproval(sender, spender, value);
        return true;
    }

    /* ========== EVENTS ========== */

    event Transfer(address indexed from, address indexed to, uint value);
    bytes32 constant TRANSFER_SIG = keccak256("Transfer(address,address,uint256)");

    function emitTransfer(address from, address to, uint value) internal {
        proxy._emit(abi.encode(value), 3, TRANSFER_SIG, bytes32(from), bytes32(to), 0);
    }

    event Approval(address indexed owner, address indexed spender, uint value);
    bytes32 constant APPROVAL_SIG = keccak256("Approval(address,address,uint256)");

    function emitApproval(address owner, address spender, uint value) internal {
        proxy._emit(abi.encode(value), 3, APPROVAL_SIG, bytes32(owner), bytes32(spender), 0);
    }

    event TokenStateUpdated(address newTokenState);
    bytes32 constant TOKENSTATEUPDATED_SIG = keccak256("TokenStateUpdated(address)");

    function emitTokenStateUpdated(address newTokenState) internal {
        proxy._emit(abi.encode(newTokenState), 1, TOKENSTATEUPDATED_SIG, 0, 0, 0);
    }
}


// https://docs.synthetix.io/contracts/Math
library Math {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    /**
     * @dev Uses "exponentiation by squaring" algorithm where cost is 0(logN)
     * vs 0(N) for naive repeated multiplication.
     * Calculates x^n with x as fixed-point and n as regular unsigned int.
     * Calculates to 18 digits of precision with SafeDecimalMath.unit()
     */
    function powDecimal(uint x, uint n) internal pure returns (uint) {
        // https://mpark.github.io/programming/2014/08/18/exponentiation-by-squaring/

        uint result = SafeDecimalMath.unit();
        while (n > 0) {
            if (n % 2 != 0) {
                result = result.multiplyDecimal(x);
            }
            x = x.multiplyDecimal(x);
            n /= 2;
        }
        return result;
    }
}


/**
 * @title SynthetixState interface contract
 * @notice Abstract contract to hold public getters
 */
contract ISynthetixState {
    // A struct for handing values associated with an individual user's debt position
    struct IssuanceData {
        // Percentage of the total debt owned at the time
        // of issuance. This number is modified by the global debt
        // delta array. You can figure out a user's exit price and
        // collateralisation ratio using a combination of their initial
        // debt and the slice of global debt delta which applies to them.
        uint initialDebtOwnership;
        // This lets us know when (in relative terms) the user entered
        // the debt pool so we can calculate their exit price and
        // collateralistion ratio
        uint debtEntryIndex;
    }

    uint[] public debtLedger;
    uint public issuanceRatio;
    mapping(address => IssuanceData) public issuanceData;

    function debtLedgerLength() external view returns (uint);

    function hasIssued(address account) external view returns (bool);

    function incrementTotalIssuerCount() external;

    function decrementTotalIssuerCount() external;

    function setCurrentIssuanceData(address account, uint initialDebtOwnership) external;

    function lastDebtLedgerEntry() external view returns (uint);

    function appendDebtLedgerValue(uint value) external;

    function clearIssuanceData(address account) external;
}


interface ISynth {
    function burn(address account, uint amount) external;

    function issue(address account, uint amount) external;

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function transferFromAndSettle(address from, address to, uint value) external returns (bool);

    function balanceOf(address owner) external view returns (uint);
}


/**
 * @title SynthetixEscrow interface
 */
interface ISynthetixEscrow {
    function balanceOf(address account) public view returns (uint);

    function appendVestingEntry(address account, uint quantity) public;
}


/**
 * @title FeePool Interface
 * @notice Abstract contract to hold public getters
 */
contract IFeePool {
    address public FEE_ADDRESS;
    uint public exchangeFeeRate;

    function amountReceivedFromExchange(uint value) external view returns (uint);

    function amountReceivedFromTransfer(uint value) external view returns (uint);

    function recordFeePaid(uint sUSDAmount) external;

    function appendAccountIssuanceRecord(address account, uint lockedAmount, uint debtEntryIndex) external;

    function setRewardsToDistribute(uint amount) external;
}


/**
 * @title ExchangeRates interface
 */
interface IExchangeRates {
    function effectiveValue(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint);

    function rateForCurrency(bytes32 currencyKey) external view returns (uint);

    function ratesForCurrencies(bytes32[] currencyKeys) external view returns (uint[] memory);

    function rateIsStale(bytes32 currencyKey) external view returns (bool);

    function rateIsFrozen(bytes32 currencyKey) external view returns (bool);

    function anyRateIsStale(bytes32[] currencyKeys) external view returns (bool);

    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint);

    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view returns (uint);

    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint);

    function ratesAndStaleForCurrencies(bytes32[] currencyKeys) external view returns (uint[], bool);

    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);
}


interface ISystemStatus {
    function requireSystemActive() external view;

    function requireIssuanceActive() external view;

    function requireExchangeActive() external view;

    function requireSynthActive(bytes32 currencyKey) external view;

    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;
}


interface IExchanger {
    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);

    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view returns (uint);

    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (uint reclaimAmount, uint rebateAmount, uint numEntries);

    function settle(address from, bytes32 currencyKey) external returns (uint reclaimed, uint refunded, uint numEntries);

    function exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external returns (uint amountReceived);

    function exchangeOnBehalf(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);

    function calculateAmountAfterSettlement(address from, bytes32 currencyKey, uint amount, uint refunded)
        external
        view
        returns (uint amountAfterSettlement);
}


interface IIssuer {
    function issueSynths(address from, uint amount) external;

    function issueSynthsOnBehalf(address issueFor, address from, uint amount) external;

    function issueMaxSynths(address from) external;

    function issueMaxSynthsOnBehalf(address issueFor, address from) external;

    function burnSynths(address from, uint amount) external;

    function burnSynthsOnBehalf(address burnForAddress, address from, uint amount) external;

    function burnSynthsToTarget(address from) external;

    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;

    function canBurnSynths(address account) external view returns (bool);

    function lastIssueEvent(address account) external view returns (uint);
}


// https://docs.synthetix.io/contracts/Synth
contract Synth is ExternStateToken, MixinResolver {
    /* ========== STATE VARIABLES ========== */

    // Currency key which identifies this Synth to the Synthetix system
    bytes32 public currencyKey;

    uint8 public constant DECIMALS = 18;

    // Where fees are pooled in sUSD
    address public constant FEE_ADDRESS = 0xfeEFEEfeefEeFeefEEFEEfEeFeefEEFeeFEEFEeF;

    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */

    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_SYNTHETIX = "Synthetix";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";

    bytes32[24] internal addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_SYNTHETIX,
        CONTRACT_EXCHANGER,
        CONTRACT_ISSUER,
        CONTRACT_FEEPOOL
    ];

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _proxy,
        TokenState _tokenState,
        string _tokenName,
        string _tokenSymbol,
        address _owner,
        bytes32 _currencyKey,
        uint _totalSupply,
        address _resolver
    )
        public
        ExternStateToken(_proxy, _tokenState, _tokenName, _tokenSymbol, _totalSupply, DECIMALS, _owner)
        MixinResolver(_owner, _resolver, addressesToCache)
    {
        require(_proxy != address(0), "_proxy cannot be 0");
        require(_owner != 0, "_owner cannot be 0");

        currencyKey = _currencyKey;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function transfer(address to, uint value) public optionalProxy returns (bool) {
        _ensureCanTransfer(messageSender, value);

        // transfers to FEE_ADDRESS will be exchanged into sUSD and recorded as fee
        if (to == FEE_ADDRESS) {
            return _transferToFeeAddress(to, value);
        }

        // transfers to 0x address will be burned
        if (to == address(0)) {
            return _internalBurn(messageSender, value);
        }

        return super._internalTransfer(messageSender, to, value);
    }

    function transferAndSettle(address to, uint value) public optionalProxy returns (bool) {
        systemStatus().requireSynthActive(currencyKey);

        (, , uint numEntriesSettled) = exchanger().settle(messageSender, currencyKey);

        // Save gas instead of calling transferableSynths
        uint balanceAfter = value;

        if (numEntriesSettled > 0) {
            balanceAfter = tokenState.balanceOf(messageSender);
        }

        // Reduce the value to transfer if balance is insufficient after reclaimed
        value = value > balanceAfter ? balanceAfter : value;

        return super._internalTransfer(messageSender, to, value);
    }

    function transferFrom(address from, address to, uint value) public optionalProxy returns (bool) {
        _ensureCanTransfer(from, value);

        return _internalTransferFrom(from, to, value);
    }

    function transferFromAndSettle(address from, address to, uint value) public optionalProxy returns (bool) {
        systemStatus().requireSynthActive(currencyKey);

        (, , uint numEntriesSettled) = exchanger().settle(from, currencyKey);

        // Save gas instead of calling transferableSynths
        uint balanceAfter = value;

        if (numEntriesSettled > 0) {
            balanceAfter = tokenState.balanceOf(from);
        }

        // Reduce the value to transfer if balance is insufficient after reclaimed
        value = value >= balanceAfter ? balanceAfter : value;

        return _internalTransferFrom(from, to, value);
    }

    /**
     * @notice _transferToFeeAddress function
     * non-sUSD synths are exchanged into sUSD via synthInitiatedExchange
     * notify feePool to record amount as fee paid to feePool */
    function _transferToFeeAddress(address to, uint value) internal returns (bool) {
        uint amountInUSD;

        // sUSD can be transferred to FEE_ADDRESS directly
        if (currencyKey == "sUSD") {
            amountInUSD = value;
            super._internalTransfer(messageSender, to, value);
        } else {
            // else exchange synth into sUSD and send to FEE_ADDRESS
            amountInUSD = exchanger().exchange(messageSender, currencyKey, value, "sUSD", FEE_ADDRESS);
        }

        // Notify feePool to record sUSD to distribute as fees
        feePool().recordFeePaid(amountInUSD);

        return true;
    }

    // Allow synthetix to issue a certain number of synths from an account.
    // forward call to _internalIssue
    function issue(address account, uint amount) external onlyInternalContracts {
        _internalIssue(account, amount);
    }

    // Allow synthetix or another synth contract to burn a certain number of synths from an account.
    // forward call to _internalBurn
    function burn(address account, uint amount) external onlyInternalContracts {
        _internalBurn(account, amount);
    }

    function _internalIssue(address account, uint amount) internal {
        tokenState.setBalanceOf(account, tokenState.balanceOf(account).add(amount));
        totalSupply = totalSupply.add(amount);
        emitTransfer(address(0), account, amount);
        emitIssued(account, amount);
    }

    function _internalBurn(address account, uint amount) internal returns (bool) {
        tokenState.setBalanceOf(account, tokenState.balanceOf(account).sub(amount));
        totalSupply = totalSupply.sub(amount);
        emitTransfer(account, address(0), amount);
        emitBurned(account, amount);

        return true;
    }

    // Allow owner to set the total supply on import.
    function setTotalSupply(uint amount) external optionalProxy_onlyOwner {
        totalSupply = amount;
    }

    /* ========== VIEWS ========== */
    function systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function synthetix() internal view returns (ISynthetix) {
        return ISynthetix(requireAndGetAddress(CONTRACT_SYNTHETIX, "Missing Synthetix address"));
    }

    function feePool() internal view returns (IFeePool) {
        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool address"));
    }

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER, "Missing Issuer address"));
    }

    function _ensureCanTransfer(address from, uint value) internal view {
        require(exchanger().maxSecsLeftInWaitingPeriod(from, currencyKey) == 0, "Cannot transfer during waiting period");
        require(transferableSynths(from) >= value, "Insufficient balance after any settlement owing");
        systemStatus().requireSynthActive(currencyKey);
    }

    function transferableSynths(address account) public view returns (uint) {
        (uint reclaimAmount, , ) = exchanger().settlementOwing(account, currencyKey);

        // Note: ignoring rebate amount here because a settle() is required in order to
        // allow the transfer to actually work

        uint balance = tokenState.balanceOf(account);

        if (reclaimAmount > balance) {
            return 0;
        } else {
            return balance.sub(reclaimAmount);
        }
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _internalTransferFrom(address from, address to, uint value) internal returns (bool) {
        // Skip allowance update in case of infinite allowance
        if (tokenState.allowance(from, messageSender) != uint(-1)) {
            // Reduce the allowance by the amount we're transferring.
            // The safeSub call will handle an insufficient allowance.
            tokenState.setAllowance(from, messageSender, tokenState.allowance(from, messageSender).sub(value));
        }

        return super._internalTransfer(from, to, value);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyInternalContracts() {
        bool isSynthetix = msg.sender == address(synthetix());
        bool isFeePool = msg.sender == address(feePool());
        bool isExchanger = msg.sender == address(exchanger());
        bool isIssuer = msg.sender == address(issuer());

        require(
            isSynthetix || isFeePool || isExchanger || isIssuer,
            "Only Synthetix, FeePool, Exchanger or Issuer contracts allowed"
        );
        _;
    }

    /* ========== EVENTS ========== */
    event Issued(address indexed account, uint value);
    bytes32 private constant ISSUED_SIG = keccak256("Issued(address,uint256)");

    function emitIssued(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, ISSUED_SIG, bytes32(account), 0, 0);
    }

    event Burned(address indexed account, uint value);
    bytes32 private constant BURNED_SIG = keccak256("Burned(address,uint256)");

    function emitBurned(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, BURNED_SIG, bytes32(account), 0, 0);
    }
}


/**
 * @title Synthetix interface contract
 * @notice Abstract contract to hold public getters
 * @dev pseudo interface, actually declared as contract to hold the public getters
 */


contract ISynthetix {
    // ========== PUBLIC STATE VARIABLES ==========

    uint public totalSupply;

    mapping(bytes32 => Synth) public synths;

    mapping(address => bytes32) public synthsByAddress;

    // ========== PUBLIC FUNCTIONS ==========

    function balanceOf(address account) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function exchange(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external
        returns (uint amountReceived);

    function issueSynths(uint amount) external;

    function issueMaxSynths() external;

    function burnSynths(uint amount) external;

    function burnSynthsToTarget() external;

    function settle(bytes32 currencyKey) external returns (uint reclaimed, uint refunded, uint numEntries);

    function collateralisationRatio(address issuer) public view returns (uint);

    function totalIssuedSynths(bytes32 currencyKey) public view returns (uint);

    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) public view returns (uint);

    function debtBalanceOf(address issuer, bytes32 currencyKey) public view returns (uint);

    function debtBalanceOfAndTotalDebt(address issuer, bytes32 currencyKey)
        public
        view
        returns (uint debtBalance, uint totalSystemValue);

    function remainingIssuableSynths(address issuer)
        public
        view
        returns (uint maxIssuable, uint alreadyIssued, uint totalSystemDebt);

    function maxIssuableSynths(address issuer) public view returns (uint maxIssuable);

    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);

    function emitSynthExchange(
        address account,
        bytes32 fromCurrencyKey,
        uint fromAmount,
        bytes32 toCurrencyKey,
        uint toAmount,
        address toAddress
    ) external;

    function emitExchangeReclaim(address account, bytes32 currencyKey, uint amount) external;

    function emitExchangeRebate(address account, bytes32 currencyKey, uint amount) external;
}


// https://docs.synthetix.io/contracts/SupplySchedule
contract SupplySchedule is Owned {
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Math for uint;

    // Time of the last inflation supply mint event
    uint public lastMintEvent;

    // Counter for number of weeks since the start of supply inflation
    uint public weekCounter;

    // The number of SNX rewarded to the caller of Synthetix.mint()
    uint public minterReward = 200 * SafeDecimalMath.unit();

    // The initial weekly inflationary supply is 75m / 52 until the start of the decay rate.
    // 75e6 * SafeDecimalMath.unit() / 52
    uint public constant INITIAL_WEEKLY_SUPPLY = 1442307692307692307692307;

    // Address of the SynthetixProxy for the onlySynthetix modifier
    address public synthetixProxy;

    // Max SNX rewards for minter
    uint public constant MAX_MINTER_REWARD = 200 * SafeDecimalMath.unit();

    // How long each inflation period is before mint can be called
    uint public constant MINT_PERIOD_DURATION = 1 weeks;

    uint public constant INFLATION_START_DATE = 1551830400; // 2019-03-06T00:00:00+00:00
    uint public constant MINT_BUFFER = 1 days;
    uint8 public constant SUPPLY_DECAY_START = 40; // Week 40
    uint8 public constant SUPPLY_DECAY_END = 234; //  Supply Decay ends on Week 234 (inclusive of Week 234 for a total of 195 weeks of inflation decay)

    // Weekly percentage decay of inflationary supply from the first 40 weeks of the 75% inflation rate
    uint public constant DECAY_RATE = 12500000000000000; // 1.25% weekly

    // Percentage growth of terminal supply per annum
    uint public constant TERMINAL_SUPPLY_RATE_ANNUAL = 25000000000000000; // 2.5% pa

    constructor(address _owner, uint _lastMintEvent, uint _currentWeek) public Owned(_owner) {
        lastMintEvent = _lastMintEvent;
        weekCounter = _currentWeek;
    }

    // ========== VIEWS ==========

    /**
     * @return The amount of SNX mintable for the inflationary supply
     */
    function mintableSupply() external view returns (uint) {
        uint totalAmount;

        if (!isMintable()) {
            return totalAmount;
        }

        uint remainingWeeksToMint = weeksSinceLastIssuance();

        uint currentWeek = weekCounter;

        // Calculate total mintable supply from exponential decay function
        // The decay function stops after week 234
        while (remainingWeeksToMint > 0) {
            currentWeek++;

            if (currentWeek < SUPPLY_DECAY_START) {
                // If current week is before supply decay we add initial supply to mintableSupply
                totalAmount = totalAmount.add(INITIAL_WEEKLY_SUPPLY);
                remainingWeeksToMint--;
            } else if (currentWeek <= SUPPLY_DECAY_END) {
                // if current week before supply decay ends we add the new supply for the week
                // diff between current week and (supply decay start week - 1)
                uint decayCount = currentWeek.sub(SUPPLY_DECAY_START - 1);

                totalAmount = totalAmount.add(tokenDecaySupplyForWeek(decayCount));
                remainingWeeksToMint--;
            } else {
                // Terminal supply is calculated on the total supply of Synthetix including any new supply
                // We can compound the remaining week's supply at the fixed terminal rate
                uint totalSupply = ISynthetix(synthetixProxy).totalSupply();
                uint currentTotalSupply = totalSupply.add(totalAmount);

                totalAmount = totalAmount.add(terminalInflationSupply(currentTotalSupply, remainingWeeksToMint));
                remainingWeeksToMint = 0;
            }
        }

        return totalAmount;
    }

    /**
     * @return A unit amount of decaying inflationary supply from the INITIAL_WEEKLY_SUPPLY
     * @dev New token supply reduces by the decay rate each week calculated as supply = INITIAL_WEEKLY_SUPPLY * ()
     */
    function tokenDecaySupplyForWeek(uint counter) public pure returns (uint) {
        // Apply exponential decay function to number of weeks since
        // start of inflation smoothing to calculate diminishing supply for the week.
        uint effectiveDecay = (SafeDecimalMath.unit().sub(DECAY_RATE)).powDecimal(counter);
        uint supplyForWeek = INITIAL_WEEKLY_SUPPLY.multiplyDecimal(effectiveDecay);

        return supplyForWeek;
    }

    /**
     * @return A unit amount of terminal inflation supply
     * @dev Weekly compound rate based on number of weeks
     */
    function terminalInflationSupply(uint totalSupply, uint numOfWeeks) public pure returns (uint) {
        // rate = (1 + weekly rate) ^ num of weeks
        uint effectiveCompoundRate = SafeDecimalMath.unit().add(TERMINAL_SUPPLY_RATE_ANNUAL.div(52)).powDecimal(numOfWeeks);

        // return Supply * (effectiveRate - 1) for extra supply to issue based on number of weeks
        return totalSupply.multiplyDecimal(effectiveCompoundRate.sub(SafeDecimalMath.unit()));
    }

    /**
     * @dev Take timeDiff in seconds (Dividend) and MINT_PERIOD_DURATION as (Divisor)
     * @return Calculate the numberOfWeeks since last mint rounded down to 1 week
     */
    function weeksSinceLastIssuance() public view returns (uint) {
        // Get weeks since lastMintEvent
        // If lastMintEvent not set or 0, then start from inflation start date.
        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(INFLATION_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    /**
     * @return boolean whether the MINT_PERIOD_DURATION (7 days)
     * has passed since the lastMintEvent.
     * */
    function isMintable() public view returns (bool) {
        if (now - lastMintEvent > MINT_PERIOD_DURATION) {
            return true;
        }
        return false;
    }

    // ========== MUTATIVE FUNCTIONS ==========

    /**
     * @notice Record the mint event from Synthetix by incrementing the inflation
     * week counter for the number of weeks minted (probabaly always 1)
     * and store the time of the event.
     * @param supplyMinted the amount of SNX the total supply was inflated by.
     * */
    function recordMintEvent(uint supplyMinted) external onlySynthetix returns (bool) {
        uint numberOfWeeksIssued = weeksSinceLastIssuance();

        // add number of weeks minted to weekCounter
        weekCounter = weekCounter.add(numberOfWeeksIssued);

        // Update mint event to latest week issued (start date + number of weeks issued * seconds in week)
        // 1 day time buffer is added so inflation is minted after feePeriod closes
        lastMintEvent = INFLATION_START_DATE.add(weekCounter.mul(MINT_PERIOD_DURATION)).add(MINT_BUFFER);

        emit SupplyMinted(supplyMinted, numberOfWeeksIssued, lastMintEvent, now);
        return true;
    }

    /**
     * @notice Sets the reward amount of SNX for the caller of the public
     * function Synthetix.mint().
     * This incentivises anyone to mint the inflationary supply and the mintr
     * Reward will be deducted from the inflationary supply and sent to the caller.
     * @param amount the amount of SNX to reward the minter.
     * */
    function setMinterReward(uint amount) external onlyOwner {
        require(amount <= MAX_MINTER_REWARD, "Reward cannot exceed max minter reward");
        minterReward = amount;
        emit MinterRewardUpdated(minterReward);
    }

    // ========== SETTERS ========== */

    /**
     * @notice Set the SynthetixProxy should it ever change.
     * SupplySchedule requires Synthetix address as it has the authority
     * to record mint event.
     * */
    function setSynthetixProxy(ISynthetix _synthetixProxy) external onlyOwner {
        require(_synthetixProxy != address(0), "Address cannot be 0");
        synthetixProxy = _synthetixProxy;
        emit SynthetixProxyUpdated(synthetixProxy);
    }

    // ========== MODIFIERS ==========

    /**
     * @notice Only the Synthetix contract is authorised to call this function
     * */
    modifier onlySynthetix() {
        require(
            msg.sender == address(Proxy(synthetixProxy).target()),
            "Only the synthetix contract can perform this action"
        );
        _;
    }

    /* ========== EVENTS ========== */
    /**
     * @notice Emitted when the inflationary supply is minted
     * */
    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    /**
     * @notice Emitted when the SNX minter reward amount is updated
     * */
    event MinterRewardUpdated(uint newRewardAmount);

    /**
     * @notice Emitted when setSynthetixProxy is called changing the Synthetix Proxy address
     * */
    event SynthetixProxyUpdated(address newAddress);
}


/**
 * @title RewardsDistribution interface
 */
interface IRewardsDistribution {
    function distributeRewards(uint amount) external;
}


contract IEtherCollateral {
    uint256 public totalIssuedSynths;
}


// https://docs.synthetix.io/contracts/Synthetix
contract Synthetix is ExternStateToken, MixinResolver {
    // ========== STATE VARIABLES ==========

    // Available Synths which can be used with the system
    Synth[] public availableSynths;
    mapping(bytes32 => Synth) public synths;
    mapping(address => bytes32) public synthsByAddress;

    string constant TOKEN_NAME = "Synthetix Network Token";
    string constant TOKEN_SYMBOL = "SNX";
    uint8 constant DECIMALS = 18;
    bytes32 constant sUSD = "sUSD";

    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */

    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ETHERCOLLATERAL = "EtherCollateral";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHETIXSTATE = "SynthetixState";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";
    bytes32 private constant CONTRACT_SUPPLYSCHEDULE = "SupplySchedule";
    bytes32 private constant CONTRACT_REWARDESCROW = "RewardEscrow";
    bytes32 private constant CONTRACT_SYNTHETIXESCROW = "SynthetixEscrow";
    bytes32 private constant CONTRACT_REWARDSDISTRIBUTION = "RewardsDistribution";

    bytes32[24] private addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_EXCHANGER,
        CONTRACT_ETHERCOLLATERAL,
        CONTRACT_ISSUER,
        CONTRACT_SYNTHETIXSTATE,
        CONTRACT_EXRATES,
        CONTRACT_FEEPOOL,
        CONTRACT_SUPPLYSCHEDULE,
        CONTRACT_REWARDESCROW,
        CONTRACT_SYNTHETIXESCROW,
        CONTRACT_REWARDSDISTRIBUTION
    ];

    // ========== CONSTRUCTOR ==========

    /**
     * @dev Constructor
     * @param _proxy The main token address of the Proxy contract. This will be ProxyERC20.sol
     * @param _tokenState Address of the external immutable contract containing token balances.
     * @param _owner The owner of this contract.
     * @param _totalSupply On upgrading set to reestablish the current total supply (This should be in SynthetixState if ever updated)
     * @param _resolver The address of the Synthetix Address Resolver
     */
    constructor(address _proxy, TokenState _tokenState, address _owner, uint _totalSupply, address _resolver)
        public
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, _totalSupply, DECIMALS, _owner)
        MixinResolver(_owner, _resolver, addressesToCache)
    {}

    /* ========== VIEWS ========== */

    function systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function etherCollateral() internal view returns (IEtherCollateral) {
        return IEtherCollateral(requireAndGetAddress(CONTRACT_ETHERCOLLATERAL, "Missing EtherCollateral address"));
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER, "Missing Issuer address"));
    }

    function synthetixState() internal view returns (ISynthetixState) {
        return ISynthetixState(requireAndGetAddress(CONTRACT_SYNTHETIXSTATE, "Missing SynthetixState address"));
    }

    function exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates address"));
    }

    function feePool() internal view returns (IFeePool) {
        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool address"));
    }

    function supplySchedule() internal view returns (SupplySchedule) {
        return SupplySchedule(requireAndGetAddress(CONTRACT_SUPPLYSCHEDULE, "Missing SupplySchedule address"));
    }

    function rewardEscrow() internal view returns (ISynthetixEscrow) {
        return ISynthetixEscrow(requireAndGetAddress(CONTRACT_REWARDESCROW, "Missing RewardEscrow address"));
    }

    function synthetixEscrow() internal view returns (ISynthetixEscrow) {
        return ISynthetixEscrow(requireAndGetAddress(CONTRACT_SYNTHETIXESCROW, "Missing SynthetixEscrow address"));
    }

    function rewardsDistribution() internal view returns (IRewardsDistribution) {
        return
            IRewardsDistribution(requireAndGetAddress(CONTRACT_REWARDSDISTRIBUTION, "Missing RewardsDistribution address"));
    }

    /**
     * @notice Total amount of synths issued by the system, priced in currencyKey
     * @param currencyKey The currency to value the synths in
     */
    function _totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) internal view returns (uint) {
        IExchangeRates exRates = exchangeRates();
        uint total = 0;
        uint currencyRate = exRates.rateForCurrency(currencyKey);

        (uint[] memory rates, bool anyRateStale) = exRates.ratesAndStaleForCurrencies(availableCurrencyKeys());
        require(!anyRateStale, "Rates are stale");

        for (uint i = 0; i < availableSynths.length; i++) {
            // What's the total issued value of that synth in the destination currency?
            // Note: We're not using exchangeRates().effectiveValue() because we don't want to go get the
            //       rate for the destination currency and check if it's stale repeatedly on every
            //       iteration of the loop
            uint totalSynths = availableSynths[i].totalSupply();

            // minus total issued synths from Ether Collateral from sETH.totalSupply()
            if (excludeEtherCollateral && availableSynths[i] == synths["sETH"]) {
                totalSynths = totalSynths.sub(etherCollateral().totalIssuedSynths());
            }

            uint synthValue = totalSynths.multiplyDecimalRound(rates[i]);
            total = total.add(synthValue);
        }

        return total.divideDecimalRound(currencyRate);
    }

    /**
     * @notice Total amount of synths issued by the system priced in currencyKey
     * @param currencyKey The currency to value the synths in
     */
    function totalIssuedSynths(bytes32 currencyKey) public view returns (uint) {
        return _totalIssuedSynths(currencyKey, false);
    }

    /**
     * @notice Total amount of synths issued by the system priced in currencyKey, excluding ether collateral
     * @param currencyKey The currency to value the synths in
     */
    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) public view returns (uint) {
        return _totalIssuedSynths(currencyKey, true);
    }

    /**
     * @notice Returns the currencyKeys of availableSynths for rate checking
     */
    function availableCurrencyKeys() public view returns (bytes32[]) {
        bytes32[] memory currencyKeys = new bytes32[](availableSynths.length);

        for (uint i = 0; i < availableSynths.length; i++) {
            currencyKeys[i] = synthsByAddress[availableSynths[i]];
        }

        return currencyKeys;
    }

    /**
     * @notice Returns the count of available synths in the system, which you can use to iterate availableSynths
     */
    function availableSynthCount() public view returns (uint) {
        return availableSynths.length;
    }

    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool) {
        return exchanger().maxSecsLeftInWaitingPeriod(messageSender, currencyKey) > 0;
    }

    // ========== MUTATIVE FUNCTIONS ==========

    /**
     * @notice Add an associated Synth contract to the Synthetix system
     * @dev Only the contract owner may call this.
     */
    function addSynth(Synth synth) external optionalProxy_onlyOwner {
        bytes32 currencyKey = synth.currencyKey();

        require(synths[currencyKey] == Synth(0), "Synth already exists");
        require(synthsByAddress[synth] == bytes32(0), "Synth address already exists");

        availableSynths.push(synth);
        synths[currencyKey] = synth;
        synthsByAddress[synth] = currencyKey;
    }

    /**
     * @notice Remove an associated Synth contract from the Synthetix system
     * @dev Only the contract owner may call this.
     */
    function removeSynth(bytes32 currencyKey) external optionalProxy_onlyOwner {
        require(synths[currencyKey] != address(0), "Synth does not exist");
        require(synths[currencyKey].totalSupply() == 0, "Synth supply exists");
        require(currencyKey != sUSD, "Cannot remove synth");

        // Save the address we're removing for emitting the event at the end.
        address synthToRemove = synths[currencyKey];

        // Remove the synth from the availableSynths array.
        for (uint i = 0; i < availableSynths.length; i++) {
            if (availableSynths[i] == synthToRemove) {
                delete availableSynths[i];

                // Copy the last synth into the place of the one we just deleted
                // If there's only one synth, this is synths[0] = synths[0].
                // If we're deleting the last one, it's also a NOOP in the same way.
                availableSynths[i] = availableSynths[availableSynths.length - 1];

                // Decrease the size of the array by one.
                availableSynths.length--;

                break;
            }
        }

        // And remove it from the synths mapping
        delete synthsByAddress[synths[currencyKey]];
        delete synths[currencyKey];

        // Note: No event here as Synthetix contract exceeds max contract size
        // with these events, and it's unlikely people will need to
        // track these events specifically.

    }

    /**
     * @notice ERC20 transfer function.
     */
    function transfer(address to, uint value) public optionalProxy returns (bool) {
        systemStatus().requireSystemActive();

        // Ensure they're not trying to exceed their staked SNX amount
        require(value <= transferableSynthetix(messageSender), "Cannot transfer staked or escrowed SNX");

        // Perform the transfer: if there is a problem an exception will be thrown in this call.
        _transfer_byProxy(messageSender, to, value);

        return true;
    }

    /**
     * @notice ERC20 transferFrom function.
     */
    function transferFrom(address from, address to, uint value) public optionalProxy returns (bool) {
        systemStatus().requireSystemActive();

        // Ensure they're not trying to exceed their locked amount
        require(value <= transferableSynthetix(from), "Cannot transfer staked or escrowed SNX");

        // Perform the transfer: if there is a problem,
        // an exception will be thrown in this call.
        return _transferFrom_byProxy(messageSender, from, to, value);
    }

    function issueSynths(uint amount) external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().issueSynths(messageSender, amount);
    }

    function issueSynthsOnBehalf(address issueForAddress, uint amount) external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().issueSynthsOnBehalf(issueForAddress, messageSender, amount);
    }

    function issueMaxSynths() external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().issueMaxSynths(messageSender);
    }

    function issueMaxSynthsOnBehalf(address issueForAddress) external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().issueMaxSynthsOnBehalf(issueForAddress, messageSender);
    }

    function burnSynths(uint amount) external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().burnSynths(messageSender, amount);
    }

    function burnSynthsOnBehalf(address burnForAddress, uint amount) external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().burnSynthsOnBehalf(burnForAddress, messageSender, amount);
    }

    function burnSynthsToTarget() external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().burnSynthsToTarget(messageSender);
    }

    function burnSynthsToTargetOnBehalf(address burnForAddress) external optionalProxy {
        systemStatus().requireIssuanceActive();

        return issuer().burnSynthsToTargetOnBehalf(burnForAddress, messageSender);
    }

    function exchange(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        external
        optionalProxy
        returns (uint amountReceived)
    {
        systemStatus().requireExchangeActive();

        systemStatus().requireSynthsActive(sourceCurrencyKey, destinationCurrencyKey);

        return exchanger().exchange(messageSender, sourceCurrencyKey, sourceAmount, destinationCurrencyKey, messageSender);
    }

    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external optionalProxy returns (uint amountReceived) {
        systemStatus().requireExchangeActive();

        systemStatus().requireSynthsActive(sourceCurrencyKey, destinationCurrencyKey);

        return
            exchanger().exchangeOnBehalf(
                exchangeForAddress,
                messageSender,
                sourceCurrencyKey,
                sourceAmount,
                destinationCurrencyKey
            );
    }

    function settle(bytes32 currencyKey)
        external
        optionalProxy
        returns (uint reclaimed, uint refunded, uint numEntriesSettled)
    {
        return exchanger().settle(messageSender, currencyKey);
    }

    // ========== Issuance/Burning ==========

    /**
     * @notice The maximum synths an issuer can issue against their total synthetix quantity.
     * This ignores any already issued synths, and is purely giving you the maximimum amount the user can issue.
     */
    function maxIssuableSynths(address _issuer)
        public
        view
        returns (
            // We don't need to check stale rates here as effectiveValue will do it for us.
            uint
        )
    {
        // What is the value of their SNX balance in the destination currency?
        uint destinationValue = exchangeRates().effectiveValue("SNX", collateral(_issuer), sUSD);

        // They're allowed to issue up to issuanceRatio of that value
        return destinationValue.multiplyDecimal(synthetixState().issuanceRatio());
    }

    /**
     * @notice The current collateralisation ratio for a user. Collateralisation ratio varies over time
     * as the value of the underlying Synthetix asset changes,
     * e.g. based on an issuance ratio of 20%. if a user issues their maximum available
     * synths when they hold $10 worth of Synthetix, they will have issued $2 worth of synths. If the value
     * of Synthetix changes, the ratio returned by this function will adjust accordingly. Users are
     * incentivised to maintain a collateralisation ratio as close to the issuance ratio as possible by
     * altering the amount of fees they're able to claim from the system.
     */
    function collateralisationRatio(address _issuer) public view returns (uint) {
        uint totalOwnedSynthetix = collateral(_issuer);
        if (totalOwnedSynthetix == 0) return 0;

        uint debtBalance = debtBalanceOf(_issuer, "SNX");
        return debtBalance.divideDecimalRound(totalOwnedSynthetix);
    }

    /**
     * @notice If a user issues synths backed by SNX in their wallet, the SNX become locked. This function
     * will tell you how many synths a user has to give back to the system in order to unlock their original
     * debt position. This is priced in whichever synth is passed in as a currency key, e.g. you can price
     * the debt in sUSD, or any other synth you wish.
     */
    function debtBalanceOf(address _issuer, bytes32 currencyKey)
        public
        view
        returns (
            // Don't need to check for stale rates here because totalIssuedSynths will do it for us
            uint
        )
    {
        ISynthetixState state = synthetixState();

        // What was their initial debt ownership?
        (uint initialDebtOwnership, ) = state.issuanceData(_issuer);

        // If it's zero, they haven't issued, and they have no debt.
        if (initialDebtOwnership == 0) return 0;

        (uint debtBalance, ) = debtBalanceOfAndTotalDebt(_issuer, currencyKey);
        return debtBalance;
    }

    function debtBalanceOfAndTotalDebt(address _issuer, bytes32 currencyKey)
        public
        view
        returns (uint debtBalance, uint totalSystemValue)
    {
        ISynthetixState state = synthetixState();

        // What was their initial debt ownership?
        uint initialDebtOwnership;
        uint debtEntryIndex;
        (initialDebtOwnership, debtEntryIndex) = state.issuanceData(_issuer);

        // What's the total value of the system excluding ETH backed synths in their requested currency?
        totalSystemValue = totalIssuedSynthsExcludeEtherCollateral(currencyKey);

        // If it's zero, they haven't issued, and they have no debt.
        if (initialDebtOwnership == 0) return (0, totalSystemValue);

        // Figure out the global debt percentage delta from when they entered the system.
        // This is a high precision integer of 27 (1e27) decimals.
        uint currentDebtOwnership = state
            .lastDebtLedgerEntry()
            .divideDecimalRoundPrecise(state.debtLedger(debtEntryIndex))
            .multiplyDecimalRoundPrecise(initialDebtOwnership);

        // Their debt balance is their portion of the total system value.
        uint highPrecisionBalance = totalSystemValue.decimalToPreciseDecimal().multiplyDecimalRoundPrecise(
            currentDebtOwnership
        );

        // Convert back into 18 decimals (1e18)
        debtBalance = highPrecisionBalance.preciseDecimalToDecimal();
    }

    /**
     * @notice The remaining synths an issuer can issue against their total synthetix balance.
     * @param _issuer The account that intends to issue
     */
    function remainingIssuableSynths(address _issuer)
        public
        view
        returns (
            // Don't need to check for synth existing or stale rates because maxIssuableSynths will do it for us.
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        )
    {
        (alreadyIssued, totalSystemDebt) = debtBalanceOfAndTotalDebt(_issuer, sUSD);
        maxIssuable = maxIssuableSynths(_issuer);

        if (alreadyIssued >= maxIssuable) {
            maxIssuable = 0;
        } else {
            maxIssuable = maxIssuable.sub(alreadyIssued);
        }
    }

    /**
     * @notice The total SNX owned by this account, both escrowed and unescrowed,
     * against which synths can be issued.
     * This includes those already being used as collateral (locked), and those
     * available for further issuance (unlocked).
     */
    function collateral(address account) public view returns (uint) {
        uint balance = tokenState.balanceOf(account);

        if (synthetixEscrow() != address(0)) {
            balance = balance.add(synthetixEscrow().balanceOf(account));
        }

        if (rewardEscrow() != address(0)) {
            balance = balance.add(rewardEscrow().balanceOf(account));
        }

        return balance;
    }

    /**
     * @notice The number of SNX that are free to be transferred for an account.
     * @dev Escrowed SNX are not transferable, so they are not included
     * in this calculation.
     * @notice SNX rate not stale is checked within debtBalanceOf
     */
    function transferableSynthetix(address account)
        public
        view
        rateNotStale("SNX") // SNX is not a synth so is not checked in totalIssuedSynths
        returns (uint)
    {
        // How many SNX do they have, excluding escrow?
        // Note: We're excluding escrow here because we're interested in their transferable amount
        // and escrowed SNX are not transferable.
        uint balance = tokenState.balanceOf(account);

        // How many of those will be locked by the amount they've issued?
        // Assuming issuance ratio is 20%, then issuing 20 SNX of value would require
        // 100 SNX to be locked in their wallet to maintain their collateralisation ratio
        // The locked synthetix value can exceed their balance.
        uint lockedSynthetixValue = debtBalanceOf(account, "SNX").divideDecimalRound(synthetixState().issuanceRatio());

        // If we exceed the balance, no SNX are transferable, otherwise the difference is.
        if (lockedSynthetixValue >= balance) {
            return 0;
        } else {
            return balance.sub(lockedSynthetixValue);
        }
    }

    /**
     * @notice Mints the inflationary SNX supply. The inflation shedule is
     * defined in the SupplySchedule contract.
     * The mint() function is publicly callable by anyone. The caller will
     receive a minter reward as specified in supplySchedule.minterReward().
     */
    function mint() external returns (bool) {
        require(rewardsDistribution() != address(0), "RewardsDistribution not set");

        systemStatus().requireIssuanceActive();

        SupplySchedule _supplySchedule = supplySchedule();
        IRewardsDistribution _rewardsDistribution = rewardsDistribution();

        uint supplyToMint = _supplySchedule.mintableSupply();
        require(supplyToMint > 0, "No supply is mintable");

        // record minting event before mutation to token supply
        _supplySchedule.recordMintEvent(supplyToMint);

        // Set minted SNX balance to RewardEscrow's balance
        // Minus the minterReward and set balance of minter to add reward
        uint minterReward = _supplySchedule.minterReward();
        // Get the remainder
        uint amountToDistribute = supplyToMint.sub(minterReward);

        // Set the token balance to the RewardsDistribution contract
        tokenState.setBalanceOf(_rewardsDistribution, tokenState.balanceOf(_rewardsDistribution).add(amountToDistribute));
        emitTransfer(this, _rewardsDistribution, amountToDistribute);

        // Kick off the distribution of rewards
        _rewardsDistribution.distributeRewards(amountToDistribute);

        // Assign the minters reward.
        tokenState.setBalanceOf(msg.sender, tokenState.balanceOf(msg.sender).add(minterReward));
        emitTransfer(this, msg.sender, minterReward);

        totalSupply = totalSupply.add(supplyToMint);

        return true;
    }

    // ========== MODIFIERS ==========

    modifier rateNotStale(bytes32 currencyKey) {
        require(!exchangeRates().rateIsStale(currencyKey), "Rate stale or not a synth");
        _;
    }

    modifier onlyExchanger() {
        require(msg.sender == address(exchanger()), "Only the exchanger contract can invoke this function");
        _;
    }

    // ========== EVENTS ==========
    /* solium-disable */
    event SynthExchange(
        address indexed account,
        bytes32 fromCurrencyKey,
        uint256 fromAmount,
        bytes32 toCurrencyKey,
        uint256 toAmount,
        address toAddress
    );
    bytes32 constant SYNTHEXCHANGE_SIG = keccak256("SynthExchange(address,bytes32,uint256,bytes32,uint256,address)");

    function emitSynthExchange(
        address account,
        bytes32 fromCurrencyKey,
        uint256 fromAmount,
        bytes32 toCurrencyKey,
        uint256 toAmount,
        address toAddress
    ) external onlyExchanger {
        proxy._emit(
            abi.encode(fromCurrencyKey, fromAmount, toCurrencyKey, toAmount, toAddress),
            2,
            SYNTHEXCHANGE_SIG,
            bytes32(account),
            0,
            0
        );
    }

    event ExchangeReclaim(address indexed account, bytes32 currencyKey, uint amount);
    bytes32 constant EXCHANGERECLAIM_SIG = keccak256("ExchangeReclaim(address,bytes32,uint256)");

    function emitExchangeReclaim(address account, bytes32 currencyKey, uint256 amount) external onlyExchanger {
        proxy._emit(abi.encode(currencyKey, amount), 2, EXCHANGERECLAIM_SIG, bytes32(account), 0, 0);
    }

    event ExchangeRebate(address indexed account, bytes32 currencyKey, uint amount);
    bytes32 constant EXCHANGEREBATE_SIG = keccak256("ExchangeRebate(address,bytes32,uint256)");

    function emitExchangeRebate(address account, bytes32 currencyKey, uint256 amount) external onlyExchanger {
        proxy._emit(abi.encode(currencyKey, amount), 2, EXCHANGEREBATE_SIG, bytes32(account), 0, 0);
    }
    /* solium-enable */
}


// https://docs.synthetix.io/contracts/LimitedSetup
contract LimitedSetup {
    uint setupExpiryTime;

    /**
     * @dev LimitedSetup Constructor.
     * @param setupDuration The time the setup period will last for.
     */
    constructor(uint setupDuration) public {
        setupExpiryTime = now + setupDuration;
    }

    modifier onlyDuringSetup {
        require(now < setupExpiryTime, "Can only perform this action during setup");
        _;
    }
}


// https://docs.synthetix.io/contracts/FeePoolState
contract FeePoolState is SelfDestructible, LimitedSetup {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    /* ========== STATE VARIABLES ========== */

    uint8 public constant FEE_PERIOD_LENGTH = 6;

    address public feePool;

    // The IssuanceData activity that's happened in a fee period.
    struct IssuanceData {
        uint debtPercentage;
        uint debtEntryIndex;
    }

    // The IssuanceData activity that's happened in a fee period.
    mapping(address => IssuanceData[FEE_PERIOD_LENGTH]) public accountIssuanceLedger;

    /**
     * @dev Constructor.
     * @param _owner The owner of this contract.
     */
    constructor(address _owner, IFeePool _feePool) public SelfDestructible(_owner) LimitedSetup(6 weeks) {
        feePool = _feePool;
    }

    /* ========== SETTERS ========== */

    /**
     * @notice set the FeePool contract as it is the only authority to be able to call
     * appendAccountIssuanceRecord with the onlyFeePool modifer
     * @dev Must be set by owner when FeePool logic is upgraded
     */
    function setFeePool(IFeePool _feePool) external onlyOwner {
        feePool = _feePool;
    }

    /* ========== VIEWS ========== */

    /**
     * @notice Get an accounts issuanceData for
     * @param account users account
     * @param index Index in the array to retrieve. Upto FEE_PERIOD_LENGTH
     */
    function getAccountsDebtEntry(address account, uint index)
        public
        view
        returns (uint debtPercentage, uint debtEntryIndex)
    {
        require(index < FEE_PERIOD_LENGTH, "index exceeds the FEE_PERIOD_LENGTH");

        debtPercentage = accountIssuanceLedger[account][index].debtPercentage;
        debtEntryIndex = accountIssuanceLedger[account][index].debtEntryIndex;
    }

    /**
     * @notice Find the oldest debtEntryIndex for the corresponding closingDebtIndex
     * @param account users account
     * @param closingDebtIndex the last periods debt index on close
     */
    function applicableIssuanceData(address account, uint closingDebtIndex) external view returns (uint, uint) {
        IssuanceData[FEE_PERIOD_LENGTH] memory issuanceData = accountIssuanceLedger[account];

        // We want to use the user's debtEntryIndex at when the period closed
        // Find the oldest debtEntryIndex for the corresponding closingDebtIndex
        for (uint i = 0; i < FEE_PERIOD_LENGTH; i++) {
            if (closingDebtIndex >= issuanceData[i].debtEntryIndex) {
                return (issuanceData[i].debtPercentage, issuanceData[i].debtEntryIndex);
            }
        }
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice Logs an accounts issuance data in the current fee period which is then stored historically
     * @param account Message.Senders account address
     * @param debtRatio Debt of this account as a percentage of the global debt.
     * @param debtEntryIndex The index in the global debt ledger. synthetix.synthetixState().issuanceData(account)
     * @param currentPeriodStartDebtIndex The startingDebtIndex of the current fee period
     * @dev onlyFeePool to call me on synthetix.issue() & synthetix.burn() calls to store the locked SNX
     * per fee period so we know to allocate the correct proportions of fees and rewards per period
      accountIssuanceLedger[account][0] has the latest locked amount for the current period. This can be update as many time
      accountIssuanceLedger[account][1-2] has the last locked amount for a previous period they minted or burned
     */
    function appendAccountIssuanceRecord(
        address account,
        uint debtRatio,
        uint debtEntryIndex,
        uint currentPeriodStartDebtIndex
    ) external onlyFeePool {
        // Is the current debtEntryIndex within this fee period
        if (accountIssuanceLedger[account][0].debtEntryIndex < currentPeriodStartDebtIndex) {
            // If its older then shift the previous IssuanceData entries periods down to make room for the new one.
            issuanceDataIndexOrder(account);
        }

        // Always store the latest IssuanceData entry at [0]
        accountIssuanceLedger[account][0].debtPercentage = debtRatio;
        accountIssuanceLedger[account][0].debtEntryIndex = debtEntryIndex;
    }

    /**
     * @notice Pushes down the entire array of debt ratios per fee period
     */
    function issuanceDataIndexOrder(address account) private {
        for (uint i = FEE_PERIOD_LENGTH - 2; i < FEE_PERIOD_LENGTH; i--) {
            uint next = i + 1;
            accountIssuanceLedger[account][next].debtPercentage = accountIssuanceLedger[account][i].debtPercentage;
            accountIssuanceLedger[account][next].debtEntryIndex = accountIssuanceLedger[account][i].debtEntryIndex;
        }
    }

    /**
     * @notice Import issuer data from synthetixState.issuerData on FeePeriodClose() block #
     * @dev Only callable by the contract owner, and only for 6 weeks after deployment.
     * @param accounts Array of issuing addresses
     * @param ratios Array of debt ratios
     * @param periodToInsert The Fee Period to insert the historical records into
     * @param feePeriodCloseIndex An accounts debtEntryIndex is valid when within the fee peroid,
     * since the input ratio will be an average of the pervious periods it just needs to be
     * > recentFeePeriods[periodToInsert].startingDebtIndex
     * < recentFeePeriods[periodToInsert - 1].startingDebtIndex
     */
    function importIssuerData(address[] accounts, uint[] ratios, uint periodToInsert, uint feePeriodCloseIndex)
        external
        onlyOwner
        onlyDuringSetup
    {
        require(accounts.length == ratios.length, "Length mismatch");

        for (uint i = 0; i < accounts.length; i++) {
            accountIssuanceLedger[accounts[i]][periodToInsert].debtPercentage = ratios[i];
            accountIssuanceLedger[accounts[i]][periodToInsert].debtEntryIndex = feePeriodCloseIndex;
            emit IssuanceDebtRatioEntry(accounts[i], ratios[i], feePeriodCloseIndex);
        }
    }

    /* ========== MODIFIERS ========== */

    modifier onlyFeePool {
        require(msg.sender == address(feePool), "Only the FeePool contract can perform this action");
        _;
    }

    /* ========== Events ========== */
    event IssuanceDebtRatioEntry(address indexed account, uint debtRatio, uint feePeriodCloseIndex);
}


/**
 * @notice  This contract is based on the code available from this blog
 * https://blog.colony.io/writing-upgradeable-contracts-in-solidity-6743f0eecc88/
 * Implements support for storing a keccak256 key and value pairs. It is the more flexible
 * and extensible option. This ensures data schema changes can be implemented without
 * requiring upgrades to the storage contract.
 */
// https://docs.synthetix.io/contracts/EternalStorage
contract EternalStorage is State {
    constructor(address _owner, address _associatedContract) public State(_owner, _associatedContract) {}

    /* ========== DATA TYPES ========== */
    mapping(bytes32 => uint) UIntStorage;
    mapping(bytes32 => string) StringStorage;
    mapping(bytes32 => address) AddressStorage;
    mapping(bytes32 => bytes) BytesStorage;
    mapping(bytes32 => bytes32) Bytes32Storage;
    mapping(bytes32 => bool) BooleanStorage;
    mapping(bytes32 => int) IntStorage;

    // UIntStorage;
    function getUIntValue(bytes32 record) external view returns (uint) {
        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) external onlyAssociatedContract {
        UIntStorage[record] = value;
    }

    function deleteUIntValue(bytes32 record) external onlyAssociatedContract {
        delete UIntStorage[record];
    }

    // StringStorage
    function getStringValue(bytes32 record) external view returns (string memory) {
        return StringStorage[record];
    }

    function setStringValue(bytes32 record, string value) external onlyAssociatedContract {
        StringStorage[record] = value;
    }

    function deleteStringValue(bytes32 record) external onlyAssociatedContract {
        delete StringStorage[record];
    }

    // AddressStorage
    function getAddressValue(bytes32 record) external view returns (address) {
        return AddressStorage[record];
    }

    function setAddressValue(bytes32 record, address value) external onlyAssociatedContract {
        AddressStorage[record] = value;
    }

    function deleteAddressValue(bytes32 record) external onlyAssociatedContract {
        delete AddressStorage[record];
    }

    // BytesStorage
    function getBytesValue(bytes32 record) external view returns (bytes memory) {
        return BytesStorage[record];
    }

    function setBytesValue(bytes32 record, bytes value) external onlyAssociatedContract {
        BytesStorage[record] = value;
    }

    function deleteBytesValue(bytes32 record) external onlyAssociatedContract {
        delete BytesStorage[record];
    }

    // Bytes32Storage
    function getBytes32Value(bytes32 record) external view returns (bytes32) {
        return Bytes32Storage[record];
    }

    function setBytes32Value(bytes32 record, bytes32 value) external onlyAssociatedContract {
        Bytes32Storage[record] = value;
    }

    function deleteBytes32Value(bytes32 record) external onlyAssociatedContract {
        delete Bytes32Storage[record];
    }

    // BooleanStorage
    function getBooleanValue(bytes32 record) external view returns (bool) {
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) external onlyAssociatedContract {
        BooleanStorage[record] = value;
    }

    function deleteBooleanValue(bytes32 record) external onlyAssociatedContract {
        delete BooleanStorage[record];
    }

    // IntStorage
    function getIntValue(bytes32 record) external view returns (int) {
        return IntStorage[record];
    }

    function setIntValue(bytes32 record, int value) external onlyAssociatedContract {
        IntStorage[record] = value;
    }

    function deleteIntValue(bytes32 record) external onlyAssociatedContract {
        delete IntStorage[record];
    }
}


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       FeePoolEternalStorage.sol
version:    1.0
author:     Clinton Ennis
            Jackson Chan
date:       2019-04-05

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

The FeePoolEternalStorage is for any state the FeePool contract
needs to persist between upgrades to the FeePool logic.

Please see EternalStorage.sol

-----------------------------------------------------------------
*/


// https://docs.synthetix.io/contracts/FeePoolEternalStorage
contract FeePoolEternalStorage is EternalStorage, LimitedSetup {
    bytes32 constant LAST_FEE_WITHDRAWAL = "last_fee_withdrawal";

    /**
     * @dev Constructor.
     * @param _owner The owner of this contract.
     */
    constructor(address _owner, address _feePool) public EternalStorage(_owner, _feePool) LimitedSetup(6 weeks) {}

    /**
     * @notice Import data from FeePool.lastFeeWithdrawal
     * @dev Only callable by the contract owner, and only for 6 weeks after deployment.
     * @param accounts Array of addresses that have claimed
     * @param feePeriodIDs Array feePeriodIDs with the accounts last claim
     */
    function importFeeWithdrawalData(address[] accounts, uint[] feePeriodIDs) external onlyOwner onlyDuringSetup {
        require(accounts.length == feePeriodIDs.length, "Length mismatch");

        for (uint8 i = 0; i < accounts.length; i++) {
            this.setUIntValue(keccak256(abi.encodePacked(LAST_FEE_WITHDRAWAL, accounts[i])), feePeriodIDs[i]);
        }
    }
}


// https://docs.synthetix.io/contracts/DelegateApprovals
contract DelegateApprovals is Owned {
    bytes32 public constant BURN_FOR_ADDRESS = "BurnForAddress";
    bytes32 public constant ISSUE_FOR_ADDRESS = "IssueForAddress";
    bytes32 public constant CLAIM_FOR_ADDRESS = "ClaimForAddress";
    bytes32 public constant EXCHANGE_FOR_ADDRESS = "ExchangeForAddress";
    bytes32 public constant APPROVE_ALL = "ApproveAll";

    bytes32[5] private _delegatableFunctions = [
        APPROVE_ALL,
        BURN_FOR_ADDRESS,
        ISSUE_FOR_ADDRESS,
        CLAIM_FOR_ADDRESS,
        EXCHANGE_FOR_ADDRESS
    ];

    /* ========== STATE VARIABLES ========== */
    EternalStorage public eternalStorage;

    /**
     * @dev Constructor
     * @param _owner The address which controls this contract.
     * @param _eternalStorage The eternalStorage address.
     */
    constructor(address _owner, EternalStorage _eternalStorage) public Owned(_owner) {
        eternalStorage = _eternalStorage;
    }

    /* ========== VIEWS ========== */

    // Move it to setter and associatedState

    // util to get key based on action name + address of authoriser + address for delegate
    function _getKey(bytes32 _action, address _authoriser, address _delegate) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_action, _authoriser, _delegate));
    }

    // hash of actionName + address of authoriser + address for the delegate
    function canBurnFor(address authoriser, address delegate) external view returns (bool) {
        return _checkApproval(BURN_FOR_ADDRESS, authoriser, delegate);
    }

    function canIssueFor(address authoriser, address delegate) external view returns (bool) {
        return _checkApproval(ISSUE_FOR_ADDRESS, authoriser, delegate);
    }

    function canClaimFor(address authoriser, address delegate) external view returns (bool) {
        return _checkApproval(CLAIM_FOR_ADDRESS, authoriser, delegate);
    }

    function canExchangeFor(address authoriser, address delegate) external view returns (bool) {
        return _checkApproval(EXCHANGE_FOR_ADDRESS, authoriser, delegate);
    }

    function approvedAll(address authoriser, address delegate) public view returns (bool) {
        return eternalStorage.getBooleanValue(_getKey(APPROVE_ALL, authoriser, delegate));
    }

    // internal function to check approval based on action
    // if approved for all actions then will return true
    // before checking specific approvals
    function _checkApproval(bytes32 action, address authoriser, address delegate) internal view returns (bool) {
        if (approvedAll(authoriser, delegate)) return true;

        return eternalStorage.getBooleanValue(_getKey(action, authoriser, delegate));
    }

    /* ========== SETTERS ========== */

    // Approve All
    function approveAllDelegatePowers(address delegate) external {
        _setApproval(APPROVE_ALL, msg.sender, delegate);
    }

    // Removes all delegate approvals
    function removeAllDelegatePowers(address delegate) external {
        for (uint i = 0; i < _delegatableFunctions.length; i++) {
            _withdrawApproval(_delegatableFunctions[i], msg.sender, delegate);
        }
    }

    // Burn on behalf
    function approveBurnOnBehalf(address delegate) external {
        _setApproval(BURN_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeBurnOnBehalf(address delegate) external {
        _withdrawApproval(BURN_FOR_ADDRESS, msg.sender, delegate);
    }

    // Issue on behalf
    function approveIssueOnBehalf(address delegate) external {
        _setApproval(ISSUE_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeIssueOnBehalf(address delegate) external {
        _withdrawApproval(ISSUE_FOR_ADDRESS, msg.sender, delegate);
    }

    // Claim on behalf
    function approveClaimOnBehalf(address delegate) external {
        _setApproval(CLAIM_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeClaimOnBehalf(address delegate) external {
        _withdrawApproval(CLAIM_FOR_ADDRESS, msg.sender, delegate);
    }

    // Exchange on behalf
    function approveExchangeOnBehalf(address delegate) external {
        _setApproval(EXCHANGE_FOR_ADDRESS, msg.sender, delegate);
    }

    function removeExchangeOnBehalf(address delegate) external {
        _withdrawApproval(EXCHANGE_FOR_ADDRESS, msg.sender, delegate);
    }

    function _setApproval(bytes32 action, address authoriser, address delegate) internal {
        require(delegate != address(0), "Can't delegate to address(0)");
        eternalStorage.setBooleanValue(_getKey(action, authoriser, delegate), true);
        emit Approval(authoriser, delegate, action);
    }

    function _withdrawApproval(bytes32 action, address authoriser, address delegate) internal {
        // Check approval is set otherwise skip deleting approval
        if (eternalStorage.getBooleanValue(_getKey(action, authoriser, delegate))) {
            eternalStorage.deleteBooleanValue(_getKey(action, authoriser, delegate));
            emit WithdrawApproval(authoriser, delegate, action);
        }
    }

    function setEternalStorage(EternalStorage _eternalStorage) external onlyOwner {
        require(_eternalStorage != address(0), "Can't set eternalStorage to address(0)");
        eternalStorage = _eternalStorage;
        emit EternalStorageUpdated(eternalStorage);
    }

    /* ========== EVENTS ========== */
    event Approval(address indexed authoriser, address delegate, bytes32 action);
    event WithdrawApproval(address indexed authoriser, address delegate, bytes32 action);
    event EternalStorageUpdated(address newEternalStorage);
}


// https://docs.synthetix.io/contracts/FeePool
contract FeePool is Proxyable, SelfDestructible, LimitedSetup, MixinResolver {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    // A percentage fee charged on each exchange between currencies.
    uint public exchangeFeeRate;

    // Exchange fee may not exceed 10%.
    uint public constant MAX_EXCHANGE_FEE_RATE = SafeDecimalMath.unit() / 10;

    // Where fees are pooled in sUSD.
    address public constant FEE_ADDRESS = 0xfeEFEEfeefEeFeefEEFEEfEeFeefEEFeeFEEFEeF;

    // sUSD currencyKey. Fees stored and paid in sUSD
    bytes32 private sUSD = "sUSD";

    // This struct represents the issuance activity that's happened in a fee period.
    struct FeePeriod {
        uint64 feePeriodId;
        uint64 startingDebtIndex;
        uint64 startTime;
        uint feesToDistribute;
        uint feesClaimed;
        uint rewardsToDistribute;
        uint rewardsClaimed;
    }

    // A staker(mintr) can claim from the previous fee period (7 days) only.
    // Fee Periods stored and managed from [0], such that [0] is always
    // the current active fee period which is not claimable until the
    // public function closeCurrentFeePeriod() is called closing the
    // current weeks collected fees. [1] is last weeks feeperiod
    uint8 public constant FEE_PERIOD_LENGTH = 2;

    FeePeriod[FEE_PERIOD_LENGTH] private _recentFeePeriods;
    uint256 private _currentFeePeriod;

    // How long a fee period lasts at a minimum. It is required for
    // anyone to roll over the periods, so they are not guaranteed
    // to roll over at exactly this duration, but the contract enforces
    // that they cannot roll over any quicker than this duration.
    uint public feePeriodDuration = 1 weeks;
    // The fee period must be between 1 day and 60 days.
    uint public constant MIN_FEE_PERIOD_DURATION = 1 days;
    uint public constant MAX_FEE_PERIOD_DURATION = 60 days;

    // Users are unable to claim fees if their collateralisation ratio drifts out of target treshold
    uint public targetThreshold = (1 * SafeDecimalMath.unit()) / 100;

    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */

    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_SYNTHETIX = "Synthetix";
    bytes32 private constant CONTRACT_FEEPOOLSTATE = "FeePoolState";
    bytes32 private constant CONTRACT_FEEPOOLETERNALSTORAGE = "FeePoolEternalStorage";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHETIXSTATE = "SynthetixState";
    bytes32 private constant CONTRACT_REWARDESCROW = "RewardEscrow";
    bytes32 private constant CONTRACT_DELEGATEAPPROVALS = "DelegateApprovals";
    bytes32 private constant CONTRACT_REWARDSDISTRIBUTION = "RewardsDistribution";

    bytes32[24] private addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_EXRATES,
        CONTRACT_SYNTHETIX,
        CONTRACT_FEEPOOLSTATE,
        CONTRACT_FEEPOOLETERNALSTORAGE,
        CONTRACT_EXCHANGER,
        CONTRACT_ISSUER,
        CONTRACT_SYNTHETIXSTATE,
        CONTRACT_REWARDESCROW,
        CONTRACT_DELEGATEAPPROVALS,
        CONTRACT_REWARDSDISTRIBUTION
    ];

    /* ========== ETERNAL STORAGE CONSTANTS ========== */

    bytes32 private constant LAST_FEE_WITHDRAWAL = "last_fee_withdrawal";

    constructor(address _proxy, address _owner, uint _exchangeFeeRate, address _resolver)
        public
        SelfDestructible(_owner)
        Proxyable(_proxy, _owner)
        LimitedSetup(3 weeks)
        MixinResolver(_owner, _resolver, addressesToCache)
    {
        // Constructed fee rates should respect the maximum fee rates.
        require(_exchangeFeeRate <= MAX_EXCHANGE_FEE_RATE, "Exchange fee rate max exceeded");

        exchangeFeeRate = _exchangeFeeRate;

        // Set our initial fee period
        _recentFeePeriodsStorage(0).feePeriodId = 1;
        _recentFeePeriodsStorage(0).startTime = uint64(now);
    }

    /* ========== VIEWS ========== */

    function systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function synthetix() internal view returns (ISynthetix) {
        return ISynthetix(requireAndGetAddress(CONTRACT_SYNTHETIX, "Missing Synthetix address"));
    }

    function feePoolState() internal view returns (FeePoolState) {
        return FeePoolState(requireAndGetAddress(CONTRACT_FEEPOOLSTATE, "Missing FeePoolState address"));
    }

    function feePoolEternalStorage() internal view returns (FeePoolEternalStorage) {
        return
            FeePoolEternalStorage(
                requireAndGetAddress(CONTRACT_FEEPOOLETERNALSTORAGE, "Missing FeePoolEternalStorage address")
            );
    }

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER, "Missing Exchanger address"));
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER, "Missing Issuer address"));
    }

    function synthetixState() internal view returns (ISynthetixState) {
        return ISynthetixState(requireAndGetAddress(CONTRACT_SYNTHETIXSTATE, "Missing SynthetixState address"));
    }

    function rewardEscrow() internal view returns (ISynthetixEscrow) {
        return ISynthetixEscrow(requireAndGetAddress(CONTRACT_REWARDESCROW, "Missing RewardEscrow address"));
    }

    function delegateApprovals() internal view returns (DelegateApprovals) {
        return DelegateApprovals(requireAndGetAddress(CONTRACT_DELEGATEAPPROVALS, "Missing DelegateApprovals address"));
    }

    function rewardsDistribution() internal view returns (IRewardsDistribution) {
        return
            IRewardsDistribution(requireAndGetAddress(CONTRACT_REWARDSDISTRIBUTION, "Missing RewardsDistribution address"));
    }

    function recentFeePeriods(uint index)
        external
        view
        returns (
            uint64 feePeriodId,
            uint64 startingDebtIndex,
            uint64 startTime,
            uint feesToDistribute,
            uint feesClaimed,
            uint rewardsToDistribute,
            uint rewardsClaimed
        )
    {
        FeePeriod memory feePeriod = _recentFeePeriodsStorage(index);
        return (
            feePeriod.feePeriodId,
            feePeriod.startingDebtIndex,
            feePeriod.startTime,
            feePeriod.feesToDistribute,
            feePeriod.feesClaimed,
            feePeriod.rewardsToDistribute,
            feePeriod.rewardsClaimed
        );
    }

    function _recentFeePeriodsStorage(uint index) internal view returns (FeePeriod storage) {
        return _recentFeePeriods[(_currentFeePeriod + index) % FEE_PERIOD_LENGTH];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice Logs an accounts issuance data per fee period
     * @param account Message.Senders account address
     * @param debtRatio Debt percentage this account has locked after minting or burning their synth
     * @param debtEntryIndex The index in the global debt ledger. synthetixState.issuanceData(account)
     * @dev onlyIssuer to call me on synthetix.issue() & synthetix.burn() calls to store the locked SNX
     * per fee period so we know to allocate the correct proportions of fees and rewards per period
     */
    function appendAccountIssuanceRecord(address account, uint debtRatio, uint debtEntryIndex) external onlyIssuer {
        feePoolState().appendAccountIssuanceRecord(
            account,
            debtRatio,
            debtEntryIndex,
            _recentFeePeriodsStorage(0).startingDebtIndex
        );

        emitIssuanceDebtRatioEntry(account, debtRatio, debtEntryIndex, _recentFeePeriodsStorage(0).startingDebtIndex);
    }

    /**
     * @notice Set the exchange fee, anywhere within the range 0-10%.
     * @dev The fee rate is in decimal format, with UNIT being the value of 100%.
     */
    function setExchangeFeeRate(uint _exchangeFeeRate) external optionalProxy_onlyOwner {
        require(_exchangeFeeRate < MAX_EXCHANGE_FEE_RATE, "rate < MAX_EXCHANGE_FEE_RATE");
        exchangeFeeRate = _exchangeFeeRate;
    }

    /**
     * @notice Set the fee period duration
     */
    function setFeePeriodDuration(uint _feePeriodDuration) external optionalProxy_onlyOwner {
        require(_feePeriodDuration >= MIN_FEE_PERIOD_DURATION, "value < MIN_FEE_PERIOD_DURATION");
        require(_feePeriodDuration <= MAX_FEE_PERIOD_DURATION, "value > MAX_FEE_PERIOD_DURATION");

        feePeriodDuration = _feePeriodDuration;

        emitFeePeriodDurationUpdated(_feePeriodDuration);
    }

    function setTargetThreshold(uint _percent) external optionalProxy_onlyOwner {
        require(_percent >= 0, "Threshold should be positive");
        require(_percent <= 50, "Threshold too high");
        targetThreshold = _percent.mul(SafeDecimalMath.unit()).div(100);
    }

    /**
     * @notice The Exchanger contract informs us when fees are paid.
     * @param amount susd amount in fees being paid.
     */
    function recordFeePaid(uint amount) external onlyExchangerOrSynth {
        // Keep track off fees in sUSD in the open fee pool period.
        _recentFeePeriodsStorage(0).feesToDistribute = _recentFeePeriodsStorage(0).feesToDistribute.add(amount);
    }

    /**
     * @notice The RewardsDistribution contract informs us how many SNX rewards are sent to RewardEscrow to be claimed.
     */
    function setRewardsToDistribute(uint amount) external {
        address rewardsAuthority = rewardsDistribution();
        require(messageSender == rewardsAuthority || msg.sender == rewardsAuthority, "Caller is not rewardsAuthority");
        // Add the amount of SNX rewards to distribute on top of any rolling unclaimed amount
        _recentFeePeriodsStorage(0).rewardsToDistribute = _recentFeePeriodsStorage(0).rewardsToDistribute.add(amount);
    }

    /**
     * @notice Close the current fee period and start a new one.
     */
    function closeCurrentFeePeriod() external {
        require(_recentFeePeriodsStorage(0).startTime <= (now - feePeriodDuration), "Too early to close fee period");

        systemStatus().requireIssuanceActive();

        // Note:  when FEE_PERIOD_LENGTH = 2, periodClosing is the current period & periodToRollover is the last open claimable period
        FeePeriod storage periodClosing = _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 2);
        FeePeriod storage periodToRollover = _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 1);

        // Any unclaimed fees from the last period in the array roll back one period.
        // Because of the subtraction here, they're effectively proportionally redistributed to those who
        // have already claimed from the old period, available in the new period.
        // The subtraction is important so we don't create a ticking time bomb of an ever growing
        // number of fees that can never decrease and will eventually overflow at the end of the fee pool.
        _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 2).feesToDistribute = periodToRollover
            .feesToDistribute
            .sub(periodToRollover.feesClaimed)
            .add(periodClosing.feesToDistribute);
        _recentFeePeriodsStorage(FEE_PERIOD_LENGTH - 2).rewardsToDistribute = periodToRollover
            .rewardsToDistribute
            .sub(periodToRollover.rewardsClaimed)
            .add(periodClosing.rewardsToDistribute);

        // Shift the previous fee periods across to make room for the new one.
        _currentFeePeriod = _currentFeePeriod.add(FEE_PERIOD_LENGTH).sub(1).mod(FEE_PERIOD_LENGTH);

        // Clear the first element of the array to make sure we don't have any stale values.
        delete _recentFeePeriods[_currentFeePeriod];

        // Open up the new fee period.
        // Increment periodId from the recent closed period feePeriodId
        _recentFeePeriodsStorage(0).feePeriodId = uint64(uint256(_recentFeePeriodsStorage(1).feePeriodId).add(1));
        _recentFeePeriodsStorage(0).startingDebtIndex = uint64(synthetixState().debtLedgerLength());
        _recentFeePeriodsStorage(0).startTime = uint64(now);

        emitFeePeriodClosed(_recentFeePeriodsStorage(1).feePeriodId);
    }

    /**
     * @notice Claim fees for last period when available or not already withdrawn.
     */
    function claimFees() external optionalProxy returns (bool) {
        return _claimFees(messageSender);
    }

    /**
     * @notice Delegated claimFees(). Call from the deletegated address
     * and the fees will be sent to the claimingForAddress.
     * approveClaimOnBehalf() must be called first to approve the deletage address
     * @param claimingForAddress The account you are claiming fees for
     */
    function claimOnBehalf(address claimingForAddress) external optionalProxy returns (bool) {
        require(delegateApprovals().canClaimFor(claimingForAddress, messageSender), "Not approved to claim on behalf");

        return _claimFees(claimingForAddress);
    }

    function _claimFees(address claimingAddress) internal returns (bool) {
        systemStatus().requireIssuanceActive();

        uint rewardsPaid = 0;
        uint feesPaid = 0;
        uint availableFees;
        uint availableRewards;

        // Address won't be able to claim fees if it is too far below the target c-ratio.
        // It will need to burn synths then try claiming again.
        require(isFeesClaimable(claimingAddress), "C-Ratio below penalty threshold");

        // Get the claimingAddress available fees and rewards
        (availableFees, availableRewards) = feesAvailable(claimingAddress);

        require(
            availableFees > 0 || availableRewards > 0,
            "No fees or rewards available for period, or fees already claimed"
        );

        // Record the address has claimed for this period
        _setLastFeeWithdrawal(claimingAddress, _recentFeePeriodsStorage(1).feePeriodId);

        if (availableFees > 0) {
            // Record the fee payment in our recentFeePeriods
            feesPaid = _recordFeePayment(availableFees);

            // Send them their fees
            _payFees(claimingAddress, feesPaid);
        }

        if (availableRewards > 0) {
            // Record the reward payment in our recentFeePeriods
            rewardsPaid = _recordRewardPayment(availableRewards);

            // Send them their rewards
            _payRewards(claimingAddress, rewardsPaid);
        }

        emitFeesClaimed(claimingAddress, feesPaid, rewardsPaid);

        return true;
    }

    /**
     * @notice Admin function to import the FeePeriod data from the previous contract
     */
    function importFeePeriod(
        uint feePeriodIndex,
        uint feePeriodId,
        uint startingDebtIndex,
        uint startTime,
        uint feesToDistribute,
        uint feesClaimed,
        uint rewardsToDistribute,
        uint rewardsClaimed
    ) public optionalProxy_onlyOwner onlyDuringSetup {
        require(startingDebtIndex <= synthetixState().debtLedgerLength(), "Cannot import bad data");

        _recentFeePeriods[_currentFeePeriod.add(feePeriodIndex).mod(FEE_PERIOD_LENGTH)] = FeePeriod({
            feePeriodId: uint64(feePeriodId),
            startingDebtIndex: uint64(startingDebtIndex),
            startTime: uint64(startTime),
            feesToDistribute: feesToDistribute,
            feesClaimed: feesClaimed,
            rewardsToDistribute: rewardsToDistribute,
            rewardsClaimed: rewardsClaimed
        });
    }

    /**
     * @notice Owner can escrow SNX. Owner to send the tokens to the RewardEscrow
     * @param account Address to escrow tokens for
     * @param quantity Amount of tokens to escrow
     */
    function appendVestingEntry(address account, uint quantity) public optionalProxy_onlyOwner {
        // Transfer SNX from messageSender to the Reward Escrow
        synthetix().transferFrom(messageSender, rewardEscrow(), quantity);

        // Create Vesting Entry
        rewardEscrow().appendVestingEntry(account, quantity);
    }

    /**
     * @notice Record the fee payment in our recentFeePeriods.
     * @param sUSDAmount The amount of fees priced in sUSD.
     */
    function _recordFeePayment(uint sUSDAmount) internal returns (uint) {
        // Don't assign to the parameter
        uint remainingToAllocate = sUSDAmount;

        uint feesPaid;
        // Start at the oldest period and record the amount, moving to newer periods
        // until we've exhausted the amount.
        // The condition checks for overflow because we're going to 0 with an unsigned int.
        for (uint i = FEE_PERIOD_LENGTH - 1; i < FEE_PERIOD_LENGTH; i--) {
            uint feesAlreadyClaimed = _recentFeePeriodsStorage(i).feesClaimed;
            uint delta = _recentFeePeriodsStorage(i).feesToDistribute.sub(feesAlreadyClaimed);

            if (delta > 0) {
                // Take the smaller of the amount left to claim in the period and the amount we need to allocate
                uint amountInPeriod = delta < remainingToAllocate ? delta : remainingToAllocate;

                _recentFeePeriodsStorage(i).feesClaimed = feesAlreadyClaimed.add(amountInPeriod);
                remainingToAllocate = remainingToAllocate.sub(amountInPeriod);
                feesPaid = feesPaid.add(amountInPeriod);

                // No need to continue iterating if we've recorded the whole amount;
                if (remainingToAllocate == 0) return feesPaid;

                // We've exhausted feePeriods to distribute and no fees remain in last period
                // User last to claim would in this scenario have their remainder slashed
                if (i == 0 && remainingToAllocate > 0) {
                    remainingToAllocate = 0;
                }
            }
        }

        return feesPaid;
    }

    /**
     * @notice Record the reward payment in our recentFeePeriods.
     * @param snxAmount The amount of SNX tokens.
     */
    function _recordRewardPayment(uint snxAmount) internal returns (uint) {
        // Don't assign to the parameter
        uint remainingToAllocate = snxAmount;

        uint rewardPaid;

        // Start at the oldest period and record the amount, moving to newer periods
        // until we've exhausted the amount.
        // The condition checks for overflow because we're going to 0 with an unsigned int.
        for (uint i = FEE_PERIOD_LENGTH - 1; i < FEE_PERIOD_LENGTH; i--) {
            uint toDistribute = _recentFeePeriodsStorage(i).rewardsToDistribute.sub(
                _recentFeePeriodsStorage(i).rewardsClaimed
            );

            if (toDistribute > 0) {
                // Take the smaller of the amount left to claim in the period and the amount we need to allocate
                uint amountInPeriod = toDistribute < remainingToAllocate ? toDistribute : remainingToAllocate;

                _recentFeePeriodsStorage(i).rewardsClaimed = _recentFeePeriodsStorage(i).rewardsClaimed.add(amountInPeriod);
                remainingToAllocate = remainingToAllocate.sub(amountInPeriod);
                rewardPaid = rewardPaid.add(amountInPeriod);

                // No need to continue iterating if we've recorded the whole amount;
                if (remainingToAllocate == 0) return rewardPaid;

                // We've exhausted feePeriods to distribute and no rewards remain in last period
                // User last to claim would in this scenario have their remainder slashed
                // due to rounding up of PreciseDecimal
                if (i == 0 && remainingToAllocate > 0) {
                    remainingToAllocate = 0;
                }
            }
        }
        return rewardPaid;
    }

    /**
     * @notice Send the fees to claiming address.
     * @param account The address to send the fees to.
     * @param sUSDAmount The amount of fees priced in sUSD.
     */
    function _payFees(address account, uint sUSDAmount) internal notFeeAddress(account) {
        // Checks not really possible but rather gaurds for the internal code.
        require(
            account != address(0) ||
                account != address(this) ||
                account != address(proxy) ||
                account != address(synthetix()),
            "Can't send fees to this address"
        );

        // Grab the sUSD Synth
        Synth sUSDSynth = synthetix().synths(sUSD);

        // NOTE: we do not control the FEE_ADDRESS so it is not possible to do an
        // ERC20.approve() transaction to allow this feePool to call ERC20.transferFrom
        // to the accounts address

        // Burn the source amount
        sUSDSynth.burn(FEE_ADDRESS, sUSDAmount);

        // Mint their new synths
        sUSDSynth.issue(account, sUSDAmount);
    }

    /**
     * @notice Send the rewards to claiming address - will be locked in rewardEscrow.
     * @param account The address to send the fees to.
     * @param snxAmount The amount of SNX.
     */
    function _payRewards(address account, uint snxAmount) internal notFeeAddress(account) {
        require(account != address(0), "Account can't be 0");
        require(account != address(this), "Can't send rewards to fee pool");
        require(account != address(proxy), "Can't send rewards to proxy");
        require(account != address(synthetix()), "Can't send rewards to synthetix");

        // Record vesting entry for claiming address and amount
        // SNX already minted to rewardEscrow balance
        rewardEscrow().appendVestingEntry(account, snxAmount);
    }

    /**
     * @notice The amount the recipient will receive if you send a certain number of tokens.
     * function used by Depot and stub will return value amount inputted.
     * @param value The amount of tokens you intend to send.
     */
    function amountReceivedFromTransfer(uint value) external pure returns (uint) {
        return value;
    }

    /**
     * @notice Calculate the fee charged on top of a value being sent via an exchange
     * @return Return the fee charged
     */
    function exchangeFeeIncurred(uint value) public view returns (uint) {
        return value.multiplyDecimal(exchangeFeeRate);

        // Exchanges less than the reciprocal of exchangeFeeRate should be completely eaten up by fees.
        // This is on the basis that exchanges less than this value will result in a nil fee.
        // Probably too insignificant to worry about, but the following code will achieve it.
        //      if (fee == 0 && exchangeFeeRate != 0) {
        //          return _value;
        //      }
        //      return fee;
    }

    /**
     * @notice The amount the recipient will receive if you are performing an exchange and the
     * destination currency will be worth a certain number of tokens.
     * @param value The amount of destination currency tokens they received after the exchange.
     */
    function amountReceivedFromExchange(uint value) external view returns (uint) {
        return value.multiplyDecimal(SafeDecimalMath.unit().sub(exchangeFeeRate));
    }

    /**
     * @notice The total fees available in the system to be withdrawnn in sUSD
     */
    function totalFeesAvailable() external view returns (uint) {
        uint totalFees = 0;

        // Fees in fee period [0] are not yet available for withdrawal
        for (uint i = 1; i < FEE_PERIOD_LENGTH; i++) {
            totalFees = totalFees.add(_recentFeePeriodsStorage(i).feesToDistribute);
            totalFees = totalFees.sub(_recentFeePeriodsStorage(i).feesClaimed);
        }

        return totalFees;
    }

    /**
     * @notice The total SNX rewards available in the system to be withdrawn
     */
    function totalRewardsAvailable() external view returns (uint) {
        uint totalRewards = 0;

        // Rewards in fee period [0] are not yet available for withdrawal
        for (uint i = 1; i < FEE_PERIOD_LENGTH; i++) {
            totalRewards = totalRewards.add(_recentFeePeriodsStorage(i).rewardsToDistribute);
            totalRewards = totalRewards.sub(_recentFeePeriodsStorage(i).rewardsClaimed);
        }

        return totalRewards;
    }

    /**
     * @notice The fees available to be withdrawn by a specific account, priced in sUSD
     * @dev Returns two amounts, one for fees and one for SNX rewards
     */
    function feesAvailable(address account) public view returns (uint, uint) {
        // Add up the fees
        uint[2][FEE_PERIOD_LENGTH] memory userFees = feesByPeriod(account);

        uint totalFees = 0;
        uint totalRewards = 0;

        // Fees & Rewards in fee period [0] are not yet available for withdrawal
        for (uint i = 1; i < FEE_PERIOD_LENGTH; i++) {
            totalFees = totalFees.add(userFees[i][0]);
            totalRewards = totalRewards.add(userFees[i][1]);
        }

        // And convert totalFees to sUSD
        // Return totalRewards as is in SNX amount
        return (totalFees, totalRewards);
    }

    /**
     * @notice Check if a particular address is able to claim fees right now
     * @param account The address you want to query for
     */
    function isFeesClaimable(address account) public view returns (bool) {
        // Threshold is calculated from ratio % above the target ratio (issuanceRatio).
        //  0  <  10%:   Claimable
        // 10% > above:  Unable to claim
        uint ratio = synthetix().collateralisationRatio(account);
        uint targetRatio = synthetixState().issuanceRatio();

        // Claimable if collateral ratio below target ratio
        if (ratio < targetRatio) {
            return true;
        }

        // Calculate the threshold for collateral ratio before fees can't be claimed.
        uint ratio_threshold = targetRatio.multiplyDecimal(SafeDecimalMath.unit().add(targetThreshold));

        // Not claimable if collateral ratio above threshold
        if (ratio > ratio_threshold) {
            return false;
        }

        return true;
    }

    /**
     * @notice Calculates fees by period for an account, priced in sUSD
     * @param account The address you want to query the fees for
     */
    function feesByPeriod(address account) public view returns (uint[2][FEE_PERIOD_LENGTH] memory results) {
        // What's the user's debt entry index and the debt they owe to the system at current feePeriod
        uint userOwnershipPercentage;
        uint debtEntryIndex;
        FeePoolState _feePoolState = feePoolState();

        (userOwnershipPercentage, debtEntryIndex) = _feePoolState.getAccountsDebtEntry(account, 0);

        // If they don't have any debt ownership and they never minted, they don't have any fees.
        // User ownership can reduce to 0 if user burns all synths,
        // however they could have fees applicable for periods they had minted in before so we check debtEntryIndex.
        if (debtEntryIndex == 0 && userOwnershipPercentage == 0) return;

        // The [0] fee period is not yet ready to claim, but it is a fee period that they can have
        // fees owing for, so we need to report on it anyway.
        uint feesFromPeriod;
        uint rewardsFromPeriod;
        (feesFromPeriod, rewardsFromPeriod) = _feesAndRewardsFromPeriod(0, userOwnershipPercentage, debtEntryIndex);

        results[0][0] = feesFromPeriod;
        results[0][1] = rewardsFromPeriod;

        // Retrieve user's last fee claim by periodId
        uint lastFeeWithdrawal = getLastFeeWithdrawal(account);

        // Go through our fee periods from the oldest feePeriod[FEE_PERIOD_LENGTH - 1] and figure out what we owe them.
        // Condition checks for periods > 0
        for (uint i = FEE_PERIOD_LENGTH - 1; i > 0; i--) {
            uint next = i - 1;
            uint nextPeriodStartingDebtIndex = _recentFeePeriodsStorage(next).startingDebtIndex;

            // We can skip the period, as no debt minted during period (next period's startingDebtIndex is still 0)
            if (nextPeriodStartingDebtIndex > 0 && lastFeeWithdrawal < _recentFeePeriodsStorage(i).feePeriodId) {
                // We calculate a feePeriod's closingDebtIndex by looking at the next feePeriod's startingDebtIndex
                // we can use the most recent issuanceData[0] for the current feePeriod
                // else find the applicableIssuanceData for the feePeriod based on the StartingDebtIndex of the period
                uint closingDebtIndex = uint256(nextPeriodStartingDebtIndex).sub(1);

                // Gas optimisation - to reuse debtEntryIndex if found new applicable one
                // if applicable is 0,0 (none found) we keep most recent one from issuanceData[0]
                // return if userOwnershipPercentage = 0)
                (userOwnershipPercentage, debtEntryIndex) = _feePoolState.applicableIssuanceData(account, closingDebtIndex);

                (feesFromPeriod, rewardsFromPeriod) = _feesAndRewardsFromPeriod(i, userOwnershipPercentage, debtEntryIndex);

                results[i][0] = feesFromPeriod;
                results[i][1] = rewardsFromPeriod;
            }
        }
    }

    /**
     * @notice ownershipPercentage is a high precision decimals uint based on
     * wallet's debtPercentage. Gives a precise amount of the feesToDistribute
     * for fees in the period. Precision factor is removed before results are
     * returned.
     * @dev The reported fees owing for the current period [0] are just a
     * running balance until the fee period closes
     */
    function _feesAndRewardsFromPeriod(uint period, uint ownershipPercentage, uint debtEntryIndex)
        internal
        view
        returns (uint, uint)
    {
        // If it's zero, they haven't issued, and they have no fees OR rewards.
        if (ownershipPercentage == 0) return (0, 0);

        uint debtOwnershipForPeriod = ownershipPercentage;

        // If period has closed we want to calculate debtPercentage for the period
        if (period > 0) {
            uint closingDebtIndex = uint256(_recentFeePeriodsStorage(period - 1).startingDebtIndex).sub(1);
            debtOwnershipForPeriod = _effectiveDebtRatioForPeriod(closingDebtIndex, ownershipPercentage, debtEntryIndex);
        }

        // Calculate their percentage of the fees / rewards in this period
        // This is a high precision integer.
        uint feesFromPeriod = _recentFeePeriodsStorage(period).feesToDistribute.multiplyDecimal(debtOwnershipForPeriod);

        uint rewardsFromPeriod = _recentFeePeriodsStorage(period).rewardsToDistribute.multiplyDecimal(
            debtOwnershipForPeriod
        );

        return (feesFromPeriod.preciseDecimalToDecimal(), rewardsFromPeriod.preciseDecimalToDecimal());
    }

    function _effectiveDebtRatioForPeriod(uint closingDebtIndex, uint ownershipPercentage, uint debtEntryIndex)
        internal
        view
        returns (uint)
    {
        // Figure out their global debt percentage delta at end of fee Period.
        // This is a high precision integer.
        ISynthetixState _synthetixState = synthetixState();
        uint feePeriodDebtOwnership = _synthetixState
            .debtLedger(closingDebtIndex)
            .divideDecimalRoundPrecise(_synthetixState.debtLedger(debtEntryIndex))
            .multiplyDecimalRoundPrecise(ownershipPercentage);

        return feePeriodDebtOwnership;
    }

    function effectiveDebtRatioForPeriod(address account, uint period) external view returns (uint) {
        require(period != 0, "Current period is not closed yet");
        require(period < FEE_PERIOD_LENGTH, "Exceeds the FEE_PERIOD_LENGTH");

        // If the period being checked is uninitialised then return 0. This is only at the start of the system.
        if (_recentFeePeriodsStorage(period - 1).startingDebtIndex == 0) return 0;

        uint closingDebtIndex = uint256(_recentFeePeriodsStorage(period - 1).startingDebtIndex).sub(1);

        uint ownershipPercentage;
        uint debtEntryIndex;
        (ownershipPercentage, debtEntryIndex) = feePoolState().applicableIssuanceData(account, closingDebtIndex);

        // internal function will check closingDebtIndex has corresponding debtLedger entry
        return _effectiveDebtRatioForPeriod(closingDebtIndex, ownershipPercentage, debtEntryIndex);
    }

    /**
     * @notice Get the feePeriodID of the last claim this account made
     * @param _claimingAddress account to check the last fee period ID claim for
     * @return uint of the feePeriodID this account last claimed
     */
    function getLastFeeWithdrawal(address _claimingAddress) public view returns (uint) {
        return feePoolEternalStorage().getUIntValue(keccak256(abi.encodePacked(LAST_FEE_WITHDRAWAL, _claimingAddress)));
    }

    /**
     * @notice Calculate the collateral ratio before user is blocked from claiming.
     */
    function getPenaltyThresholdRatio() public view returns (uint) {
        uint targetRatio = synthetixState().issuanceRatio();

        return targetRatio.multiplyDecimal(SafeDecimalMath.unit().add(targetThreshold));
    }

    /**
     * @notice Set the feePeriodID of the last claim this account made
     * @param _claimingAddress account to set the last feePeriodID claim for
     * @param _feePeriodID the feePeriodID this account claimed fees for
     */
    function _setLastFeeWithdrawal(address _claimingAddress, uint _feePeriodID) internal {
        feePoolEternalStorage().setUIntValue(
            keccak256(abi.encodePacked(LAST_FEE_WITHDRAWAL, _claimingAddress)),
            _feePeriodID
        );
    }

    /* ========== Modifiers ========== */
    modifier onlyExchangerOrSynth {
        bool isExchanger = msg.sender == address(exchanger());
        bool isSynth = synthetix().synthsByAddress(msg.sender) != bytes32(0);

        require(isExchanger || isSynth, "Only Exchanger, Synths Authorised");
        _;
    }

    modifier onlyIssuer {
        require(msg.sender == address(issuer()), "FeePool: Only Issuer Authorised");
        _;
    }

    modifier notFeeAddress(address account) {
        require(account != FEE_ADDRESS, "Fee address not allowed");
        _;
    }

    /* ========== Proxy Events ========== */

    event IssuanceDebtRatioEntry(
        address indexed account,
        uint debtRatio,
        uint debtEntryIndex,
        uint feePeriodStartingDebtIndex
    );
    bytes32 private constant ISSUANCEDEBTRATIOENTRY_SIG = keccak256(
        "IssuanceDebtRatioEntry(address,uint256,uint256,uint256)"
    );

    function emitIssuanceDebtRatioEntry(
        address account,
        uint debtRatio,
        uint debtEntryIndex,
        uint feePeriodStartingDebtIndex
    ) internal {
        proxy._emit(
            abi.encode(debtRatio, debtEntryIndex, feePeriodStartingDebtIndex),
            2,
            ISSUANCEDEBTRATIOENTRY_SIG,
            bytes32(account),
            0,
            0
        );
    }

    event ExchangeFeeUpdated(uint newFeeRate);
    bytes32 private constant EXCHANGEFEEUPDATED_SIG = keccak256("ExchangeFeeUpdated(uint256)");

    function emitExchangeFeeUpdated(uint newFeeRate) internal {
        proxy._emit(abi.encode(newFeeRate), 1, EXCHANGEFEEUPDATED_SIG, 0, 0, 0);
    }

    event FeePeriodDurationUpdated(uint newFeePeriodDuration);
    bytes32 private constant FEEPERIODDURATIONUPDATED_SIG = keccak256("FeePeriodDurationUpdated(uint256)");

    function emitFeePeriodDurationUpdated(uint newFeePeriodDuration) internal {
        proxy._emit(abi.encode(newFeePeriodDuration), 1, FEEPERIODDURATIONUPDATED_SIG, 0, 0, 0);
    }

    event FeePeriodClosed(uint feePeriodId);
    bytes32 private constant FEEPERIODCLOSED_SIG = keccak256("FeePeriodClosed(uint256)");

    function emitFeePeriodClosed(uint feePeriodId) internal {
        proxy._emit(abi.encode(feePeriodId), 1, FEEPERIODCLOSED_SIG, 0, 0, 0);
    }

    event FeesClaimed(address account, uint sUSDAmount, uint snxRewards);
    bytes32 private constant FEESCLAIMED_SIG = keccak256("FeesClaimed(address,uint256,uint256)");

    function emitFeesClaimed(address account, uint sUSDAmount, uint snxRewards) internal {
        proxy._emit(abi.encode(account, sUSDAmount, snxRewards), 1, FEESCLAIMED_SIG, 0, 0, 0);
    }
}