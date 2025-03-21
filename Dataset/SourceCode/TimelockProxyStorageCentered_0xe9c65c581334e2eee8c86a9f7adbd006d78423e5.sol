{{

  "language": "Solidity",

  "sources": {

    "contracts/TimelockProxyStorageCentered.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.7.6;\nimport \"@openzeppelin/contracts/proxy/Proxy.sol\";\nimport \"./utilities/UnstructuredStorageWithTimelock.sol\";\nimport \"./interface/IStorageV1.sol\";\n\n/**\n    TimelockProxyStorageCentered is a proxy implementation that timelocks the implementation switch.\n    The owner is stored in the system storage (StorageV1Upgradeable) and not in the contract storage\n    of the proxy.\n*/\ncontract TimelockProxyStorageCentered is Proxy {\n    using UnstructuredStorageWithTimelock for bytes32;\n\n    // bytes32(uint256(keccak256(\"eip1967.proxy.systemStorage\")) - 1\n    bytes32 private constant _SYSTEM_STORAGE_SLOT =\n        0xf7ce9e33978bd6e766998cbee51134930bc6e39dc5dcd8f992c5b743b1c6d698;\n\n    // bytes32(uint256(keccak256(\"eip1967.proxy.timelock\")) - 1\n    bytes32 private constant _TIMELOCK_SLOT =\n        0xc6fb23975d74c7743b6d6d0c1ad9dc3911bc8a4a970ec5723a30579b45472009;\n\n    // _IMPLEMENTATION_SLOT, value cloned from UpgradeableProxy\n    bytes32 private constant _IMPLEMENTATION_SLOT =\n        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    event UpgradeScheduled(address indexed implementation, uint256 activeTime);\n    event Upgraded(address indexed implementation);\n\n    event TimelockUpdateScheduled(uint256 newTimelock, uint256 activeTime);\n    event TimelockUpdated(uint256 newTimelock);\n\n    constructor(\n        address _logic,\n        address _storage,\n        uint256 _timelock,\n        bytes memory _data\n    ) {\n        assert(\n            _SYSTEM_STORAGE_SLOT ==\n                bytes32(uint256(keccak256(\"eip1967.proxy.systemStorage\")) - 1)\n        );\n        assert(\n            _TIMELOCK_SLOT ==\n                bytes32(uint256(keccak256(\"eip1967.proxy.timelock\")) - 1)\n        );\n        assert(\n            _IMPLEMENTATION_SLOT ==\n                bytes32(uint256(keccak256(\"eip1967.proxy.implementation\")) - 1)\n        );\n        _SYSTEM_STORAGE_SLOT.setAddress(_storage);\n        _TIMELOCK_SLOT.setUint256(_timelock);\n        _IMPLEMENTATION_SLOT.setAddress(_logic);\n        if (_data.length > 0) {\n            // solhint-disable-next-line avoid-low-level-calls\n            (bool success, ) = _logic.delegatecall(_data);\n            require(success);\n        }\n    }\n\n    // Using Transparent proxy pattern to avoid collision attacks\n    // see OpenZeppelin's `TransparentUpgradeableProxy`\n    modifier adminPriviledged() {\n        require(\n            msg.sender == IStorageV1(_systemStorage()).governance() ||\n            IStorageV1(_systemStorage()).isAdmin(msg.sender), \n            \"msg.sender is not adminPriviledged\"\n        );\n        _;\n    }\n\n    modifier requireTimelockPassed(bytes32 _slot) {\n        require(\n            block.timestamp >= _slot.scheduledTime(),\n            \"Timelock has not passed yet\"\n        );\n        _;\n    }\n\n    function proxyScheduleImplementationUpdate(address targetAddress)\n        public\n        adminPriviledged\n    {\n        bytes32 _slot = _IMPLEMENTATION_SLOT;\n        uint256 activeTime = block.timestamp + _TIMELOCK_SLOT.fetchUint256();\n        (_slot.scheduledContentSlot()).setAddress(targetAddress);\n        (_slot.scheduledTimeSlot()).setUint256(activeTime);\n\n        emit UpgradeScheduled(targetAddress, activeTime);\n    }\n\n    function proxyScheduleTimelockUpdate(uint256 newTimelock) public adminPriviledged {\n        uint256 activeTime = block.timestamp + _TIMELOCK_SLOT.fetchUint256();\n        (_TIMELOCK_SLOT.scheduledContentSlot()).setUint256(newTimelock);\n        (_TIMELOCK_SLOT.scheduledTimeSlot()).setUint256(activeTime);\n\n        emit TimelockUpdateScheduled(newTimelock, activeTime);\n    }\n\n    function proxyUpgradeTimelock()\n        public\n        adminPriviledged\n        requireTimelockPassed(_TIMELOCK_SLOT)\n    {\n        uint256 newTimelock =\n            (_TIMELOCK_SLOT.scheduledContentSlot()).fetchUint256();\n        _TIMELOCK_SLOT.setUint256(newTimelock);\n        emit TimelockUpdated(newTimelock);\n    }\n\n    function proxyUpgradeImplementation()\n        public\n        adminPriviledged\n        requireTimelockPassed(_IMPLEMENTATION_SLOT)\n    {\n        address newImplementation =\n            (_IMPLEMENTATION_SLOT.scheduledContentSlot()).fetchAddress();\n        _IMPLEMENTATION_SLOT.setAddress(newImplementation);\n        emit Upgraded(newImplementation);\n    }\n\n    function _implementation() internal view override returns (address impl) {\n        bytes32 slot = _IMPLEMENTATION_SLOT;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            impl := sload(slot)\n        }\n    }\n\n    function _systemStorage() internal view returns (address systemStorage) {\n        bytes32 slot = _SYSTEM_STORAGE_SLOT;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            systemStorage := sload(slot)\n        }\n    }\n}\n"

    },

    "@openzeppelin/contracts/proxy/Proxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM\n * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to\n * be specified by overriding the virtual {_implementation} function.\n * \n * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a\n * different contract through the {_delegate} function.\n * \n * The success and return data of the delegated call will be returned back to the caller of the proxy.\n */\nabstract contract Proxy {\n    /**\n     * @dev Delegates the current call to `implementation`.\n     * \n     * This function does not return to its internall call site, it will return directly to the external caller.\n     */\n    function _delegate(address implementation) internal {\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 because we don't know the size yet.\n            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 { revert(0, returndatasize()) }\n            default { return(0, returndatasize()) }\n        }\n    }\n\n    /**\n     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function\n     * and {_fallback} should delegate.\n     */\n    function _implementation() internal virtual view returns (address);\n\n    /**\n     * @dev Delegates the current call to the address returned by `_implementation()`.\n     * \n     * This function does not return to its internall call site, it will return directly to the external caller.\n     */\n    function _fallback() internal {\n        _beforeFallback();\n        _delegate(_implementation());\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other\n     * function in the contract matches the call data.\n     */\n    fallback () external payable {\n        _fallback();\n    }\n\n    /**\n     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data\n     * is empty.\n     */\n    receive () external payable {\n        _fallback();\n    }\n\n    /**\n     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`\n     * call, or as part of the Solidity `fallback` or `receive` functions.\n     * \n     * If overriden should call `super._beforeFallback()`.\n     */\n    function _beforeFallback() internal virtual {\n    }\n}\n"

    },

    "contracts/utilities/UnstructuredStorageWithTimelock.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.7.6;\n\n/**\n    UnstructuredStorageWithTimelock is a set of functions that facilitates setting/fetching unstructured storage \n    along with information of future updates and its timelock information.\n\n    For every content storage, there are two other slots that could be calculated automatically:\n        * Slot (The current value)\n        * Scheduled Slot (The future value)\n        * Scheduled Time (The future time)\n\n    Note that the library does NOT enforce timelock and does NOT store the timelock information.\n*/\nlibrary UnstructuredStorageWithTimelock {\n    // This is used to calculate the time slot and scheduled content for different variables\n    uint256 private constant SCHEDULED_SIGNATURE = 0x111;\n    uint256 private constant TIMESLOT_SIGNATURE = 0xAAA;\n\n    function updateAddressWithTimelock(bytes32 _slot) internal {\n        require(\n            scheduledTime(_slot) > block.timestamp,\n            \"Timelock has not passed\"\n        );\n        setAddress(_slot, scheduledAddress(_slot));\n    }\n\n    function updateUint256WithTimelock(bytes32 _slot) internal {\n        require(\n            scheduledTime(_slot) > block.timestamp,\n            \"Timelock has not passed\"\n        );\n        setUint256(_slot, scheduledUint256(_slot));\n    }\n\n    function setAddress(bytes32 _slot, address _target) internal {\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            sstore(_slot, _target)\n        }\n    }\n\n    function fetchAddress(bytes32 _slot)\n        internal\n        view\n        returns (address result)\n    {\n        assembly {\n            result := sload(_slot)\n        }\n    }\n\n    function scheduledAddress(bytes32 _slot)\n        internal\n        view\n        returns (address result)\n    {\n        result = fetchAddress(scheduledContentSlot(_slot));\n    }\n\n    function scheduledUint256(bytes32 _slot)\n        internal\n        view\n        returns (uint256 result)\n    {\n        result = fetchUint256(scheduledContentSlot(_slot));\n    }\n\n    function setUint256(bytes32 _slot, uint256 _target) internal {\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            sstore(_slot, _target)\n        }\n    }\n\n    function fetchUint256(bytes32 _slot)\n        internal\n        view\n        returns (uint256 result)\n    {\n        assembly {\n            result := sload(_slot)\n        }\n    }\n\n    function scheduledContentSlot(bytes32 _slot)\n        internal\n        pure\n        returns (bytes32)\n    {\n        return\n            bytes32(\n                uint256(keccak256(abi.encodePacked(_slot, SCHEDULED_SIGNATURE)))\n            );\n    }\n\n    function scheduledTime(bytes32 _slot) internal view returns (uint256) {\n        return fetchUint256(scheduledTimeSlot(_slot));\n    }\n\n    function scheduledTimeSlot(bytes32 _slot) internal pure returns (bytes32) {\n        return\n            bytes32(\n                uint256(keccak256(abi.encodePacked(_slot, TIMESLOT_SIGNATURE)))\n            );\n    }\n}\n"

    },

    "contracts/interface/IStorageV1.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.7.6;\n\ninterface IStorageV1 {\n    function governance() external view returns(address);\n    function treasury() external view returns(address);\n    function isAdmin(address _target) external view returns(bool);\n    function isOperator(address _target) external view returns(bool);\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "abi"

        ]

      }

    },

    "metadata": {

      "useLiteralContent": true

    },

    "libraries": {}

  }

}}