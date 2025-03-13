// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;



import "@openzeppelin/contracts/proxy/Proxy.sol";

import "./interface/IERC897Proxy.sol";



contract HSKProxy is Proxy, IERC897Proxy {

    bytes32 internal constant IMPLEMENTATION_SLOT = keccak256("hsk.proxy.implementation");



    bytes32 internal constant STATUS_SLOT = keccak256("hsk.proxy.status");



    bytes32 internal constant OWNER_SLOT = keccak256("hsk.proxy.owner");



    bytes32 internal constant UPGRADER_SLOT_TAG = keccak256("hsk.proxy.upgraderTag");



    bytes32 internal constant PAUSER_SLOT_TAG = keccak256("hsk.proxy.pauserTag");



    /// @dev Emitted when the administration has been transferred.

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);



    /// @dev Emitted when the upgrader is updated.

    event SetUpgrader(address indexed account, bool enable);



    /// @dev Emitted when the pauser is updated.

    event SetPauser(address indexed account, bool enable);



    /// @dev Emitted when the implementation is upgraded.

    event Upgraded(address indexed implementation);



    /// @dev Proxy status is updated.

    event StatusUpdated(bool status);



    modifier onlyOwner() {

        require(msg.sender == _owner(), "Proxy: is not owner");

        _;

    }



    modifier canUpgrade() {

        require(msg.sender == _owner() || _isUpgrader(msg.sender), "Proxy: is not owner or upgrader");

        _;

    }



    modifier canPause() {

        require(msg.sender == _owner() || _isPauser(msg.sender), "Proxy: is not owner or pauser");

        _;

    }



    constructor(address _impl, address _implOwner, address _proxyOwner) {

        _upgradeToAndCall(_impl, abi.encodeWithSelector(bytes4(keccak256("init(address)")), _implOwner));

        _setOwner(_proxyOwner);

        _setStatus(true);

    }



    function _implementation() internal view override returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            impl := sload(slot)

        }

    }



    function _beforeFallback() internal view override {

        require(_status(), "Proxy: proxy is not active");

    }



    /// @dev Sets the implementation address of the proxy.

    /// @param _impl Address of the new implementation.

    function _setImplementation(address _impl) internal {

        require(_impl.code.length > 0, "Proxy: not a contract address");



        bytes32 slot = IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            sstore(slot, _impl)

        }

    }



    /**

    * @dev Upgrades the proxy to a new implementation.

    * @param newImplementation Address of the new implementation.

    */

    function _upgradeTo(address newImplementation) internal {

        _setImplementation(newImplementation);

        emit Upgraded(newImplementation);

    }



    /// @dev Upgrade the implementation of the proxy and call a function on the new implementation.

    /// @param _impl Address of the new implementation.

    /// @param data Data to send as msg.data in the low level call.

    function _upgradeToAndCall(address _impl, bytes memory data) internal {

        _upgradeTo(_impl);

        if (data.length > 0) {

            // solhint-disable-next-line avoid-low-level-calls

            (bool ok, ) = _impl.delegatecall(data);

            require(ok, "Proxy: delegateCall failed");

        }

    }



    /// @dev Return proxy status

    function _status() internal view returns (bool active) {

        bytes32 slot = STATUS_SLOT;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            active := sload(slot)

        }

    }



    /// @dev Set proxy status

    function _setStatus(bool active) internal {

        bytes32 slot = STATUS_SLOT;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            sstore(slot, active)

        }

    }



    /// @dev Return the owner slot.

    function _owner() internal view returns (address account) {

        bytes32 slot = OWNER_SLOT;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            account := sload(slot)

        }

    }



    /// @dev Return the upgrader slot.

    function _isUpgrader(address account) internal view returns (bool enable) {

        bytes32 slot = keccak256(abi.encodePacked(UPGRADER_SLOT_TAG, account));

        // solhint-disable-next-line no-inline-assembly

        assembly {

            enable := sload(slot)

        }

    }



    /// @dev Return the pauser slot.

    function _isPauser(address account) internal view returns (bool enable) {

        bytes32 slot = keccak256(abi.encodePacked(PAUSER_SLOT_TAG, account));

        // solhint-disable-next-line no-inline-assembly

        assembly {

            enable := sload(slot)

        }

    }



    /// @dev Set new owner

    function _setOwner(address account) internal {

        require(account != address(0), "Proxy: account can not be zero");



        bytes32 slot = OWNER_SLOT;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            sstore(slot, account)

        }

    }



    function _setUpgrader(address account, bool enable) internal {

        require(account != address(0), "Proxy: account can not be zero");



        bytes32 slot = keccak256(abi.encodePacked(UPGRADER_SLOT_TAG, account));

        // solhint-disable-next-line no-inline-assembly

        assembly {

            sstore(slot, enable)

        }

    }



    function _setPauser(address account, bool enable) internal {

        require(account != address(0), "Proxy: account can not be zero");



        bytes32 slot = keccak256(abi.encodePacked(PAUSER_SLOT_TAG, account));

        // solhint-disable-next-line no-inline-assembly

        assembly {

            sstore(slot, enable)

        }

    }



    /// @dev Perform implementation upgrade

    function upgradeTo(address _impl) external canUpgrade {

        _upgradeTo(_impl);

    }



    /// @dev Perform implementation upgrade with additional setup call.

    function upgradeToAndCall(address _impl, bytes memory data) external payable canUpgrade {

        _upgradeToAndCall(_impl, data);

    }



    /// @dev Get proxy status.

    function status() external view returns (bool) {

        return _status();

    }



    /// @dev Pause or unpause proxy.

    function setStatus(bool active) external canPause {

        _setStatus(active);

        emit StatusUpdated(active);

    }



    /// @dev Returns the current owner.

    function proxyOwner() external view returns (address) {

        return _owner();

    }



    /// @dev eturns if the current account is upgrader.

    function isUpgrader(address account) external view returns (bool) {

        return _isUpgrader(account);

    }



    /// @dev Returns if the current account is pauser.

    function isPauser(address account) external view returns (bool) {

        return _isPauser(account);

    }



    /// @dev Changes the owner of the proxy.

    function changeOwner(address _newOwner) external onlyOwner {

        address _oldOwner = _owner();

        _setOwner(_newOwner);

        emit OwnerChanged(_oldOwner, _newOwner);

    }



    /// @dev Set upgrader.

    function setUpgrader(address account, bool enable) external onlyOwner {

        _setUpgrader(account, enable);

        emit SetUpgrader(account, enable);

    }



    /// @dev Set pauser.

    function setPauser(address account, bool enable) external onlyOwner {

        _setPauser(account, enable);

        emit SetPauser(account, enable);

    }



    ///////////////////////// ERC897Proxy methods ////////////////////////

    

    /// @dev See in IERC897Proxy.

    function implementation() external view override returns (address) {

        return _implementation();

    }



    /// @dev See in IERC897Proxy.

    function proxyType() external pure override returns (uint256) {

        // upgradable

        return 2;

    }

}