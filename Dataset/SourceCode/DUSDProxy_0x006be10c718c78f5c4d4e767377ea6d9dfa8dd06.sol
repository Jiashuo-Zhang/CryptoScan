pragma solidity 0.5.8;





/**

 * @title Proxy

 * @dev This is the proxy contract for the DUSDToken Registry

 */

contract Proxy {

    

    /**

    * @dev Tell the address of the implementation where every call will be delegated.

    * @return address of the implementation to which it will be delegated

    */

    function implementation() public view returns (address);



    /**

    * @dev Fallback function allowing to perform a delegatecall to the given implementation.

    * This function will return whatever the implementation call returns.

    */

    function() external payable {

        address _impl = implementation();

        require(_impl != address(0), "implementation contract not set");

        

        assembly {

            let ptr := mload(0x40)

            calldatacopy(ptr, 0, calldatasize)

            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)

            let size := returndatasize

            returndatacopy(ptr, 0, size)



            switch result

            case 0 { revert(ptr, size) }

            default { return(ptr, size) }

        }

    }

}





/**

 * @title UpgradeabilityProxy

 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded.

 */

contract UpgradeabilityProxy is Proxy {



    // Event, it will be emitted every time the implementation gets upgraded.

    event Upgraded(address indexed currentImplementation, address indexed newImplementation);



    // Storage position of the address of the current implementation

    bytes32 private constant implementationPosition = keccak256("DUSD.proxy.implementation");



    /**

    * @dev Return to the current implementation.

    */

    function implementation() public view returns (address impl) {

        bytes32 position = implementationPosition;

        assembly {

          impl := sload(position)

        }

    }



    /**

    * @dev Set the address of the current implementation.

    * @param newImplementation address representing the new implementation to be set.

    */

    function _setImplementation(address newImplementation) internal {

        bytes32 position = implementationPosition;

        assembly {

          sstore(position, newImplementation)

        }

    }



    /**

    * @dev Upgrade the implementation address.

    * @param newImplementation representing the address of the new implementation to be set.

    */

    function _upgradeTo(address newImplementation) internal {

        address currentImplementation = implementation();

        require(currentImplementation != newImplementation);

        emit Upgraded(currentImplementation, newImplementation);

        _setImplementation(newImplementation);

    }

}





/**

 * @title DUSDProxy

 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities

 */

contract DUSDProxy is UpgradeabilityProxy {



    // Event to show ownership has been transferred.

    event ProxyOwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    // Event to show ownership transfer is pending.

    event NewPendingOwner(address currentOwner, address pendingOwner);

    

    // Storage position of the owner and pendingOwner of the contract.

    bytes32 private constant proxyOwnerPosition = keccak256("DUSD.proxy.owner");

    bytes32 private constant pendingProxyOwnerPosition = keccak256("DUSD.pending.proxy.owner");



    /**

    * @dev The constructor sets the original owner of the contract to the sender account.

    */

    constructor() public {

        _setUpgradeabilityOwner(0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1);

    }



    /**

    * @dev Throw if called by any account other than the proxy owner.

    */

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner(), "only Proxy Owner");

        _;

    }



    /**

    * @dev Throw if called by any account other than the pending owner.

    */

    modifier onlyPendingProxyOwner() {

        require(msg.sender == pendingProxyOwner(), "only pending Proxy Owner");

        _;

    }



    /**

    * @dev Return the address of the proxy owner.

    * @return The address of the proxy owner.

    */

    function proxyOwner() public view returns (address owner) {

        bytes32 position = proxyOwnerPosition;

        assembly {

            owner := sload(position)

        }

    }



    /**

    * @dev Return the address of the pending proxy owner.

    * @return The address of the pending proxy owner.

    */

    function pendingProxyOwner() public view returns (address pendingOwner) {

        bytes32 position = pendingProxyOwnerPosition;

        assembly {

            pendingOwner := sload(position)

        }

    }



    /**

    * @dev Set the address of the proxy owner.

    */

    function _setUpgradeabilityOwner(address newProxyOwner) internal {

        bytes32 position = proxyOwnerPosition;

        assembly {

            sstore(position, newProxyOwner)

        }

    }



    /**

    * @dev Set the address of the pending proxy owner.

    */

    function _setPendingUpgradeabilityOwner(address newPendingProxyOwner) internal {

        bytes32 position = pendingProxyOwnerPosition;

        assembly {

            sstore(position, newPendingProxyOwner)

        }

    }



    /**

    * @dev Change the owner of the proxy.

    * @param newOwner The address to transfer ownership to.

    */

    function transferProxyOwnership(address newOwner) external onlyProxyOwner {

        require(newOwner != address(0));

        _setPendingUpgradeabilityOwner(newOwner);

        emit NewPendingOwner(proxyOwner(), newOwner);

    }



    /**

    * @dev Allow the pendingOwner to claim ownership of the proxy.

    */

    function claimProxyOwnership() external onlyPendingProxyOwner {

        emit ProxyOwnershipTransferred(proxyOwner(), pendingProxyOwner());

        _setUpgradeabilityOwner(pendingProxyOwner());

        _setPendingUpgradeabilityOwner(address(0));

    }



    /**

    * @dev Allow the proxy owner to upgrade the current version of the proxy.

    * @param implementation representing the address of the new implementation to be set.

    */

    function upgradeTo(address implementation) external onlyProxyOwner {

        _upgradeTo(implementation);

    }

}