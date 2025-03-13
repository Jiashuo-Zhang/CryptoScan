{{

  "language": "Solidity",

  "sources": {

    "contracts/migrate/ProxyPausable.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.7.6;\n\nimport \"./Proxy.sol\";\n\ncontract ProxyPausable is Proxy {\n\n    bytes32 constant PAUSED_SLOT = keccak256(abi.encodePacked(\"PAUSED_SLOT\"));\n    bytes32 constant PAUZER_SLOT = keccak256(abi.encodePacked(\"PAUZER_SLOT\"));\n\n\n    constructor() Proxy() {\n        setAddress(PAUZER_SLOT, msg.sender);\n    }\n\n\n    modifier onlyPauzer() {\n        require(msg.sender == readAddress(PAUZER_SLOT), \"ProxyPausable.onlyPauzer: msg sender not pauzer\");\n        _;\n    }\n\n    modifier notPaused() {\n        require(!readBool(PAUSED_SLOT), \"ProxyPausable.notPaused: contract is paused\");\n        _;\n    }\n\n    function getPauzer() public view returns (address) {\n        return readAddress(PAUZER_SLOT);\n    }\n\n    function setPauzer(address _newPauzer) public onlyProxyOwner{\n        setAddress(PAUZER_SLOT, _newPauzer);\n    }\n\n    function renouncePauzer() public onlyPauzer {\n        setAddress(PAUZER_SLOT, address(0));\n    }\n\n    function getPaused() public view returns (bool) {\n        return readBool(PAUSED_SLOT);\n    }\n\n    function setPaused(bool _value) public onlyPauzer {\n        setBool(PAUSED_SLOT, _value);\n    }\n\n    function internalFallback() internal virtual override notPaused {\n        super.internalFallback();\n    }\n\n}"

    },

    "contracts/migrate/Proxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.7.6;\n\nimport \"./ProxyStorage.sol\";\n\ncontract Proxy is ProxyStorage {\n\n    bytes32 constant IMPLEMENTATION_SLOT = keccak256(abi.encodePacked(\"IMPLEMENTATION_SLOT\"));\n    bytes32 constant OWNER_SLOT = keccak256(abi.encodePacked(\"OWNER_SLOT\"));\n\n    modifier onlyProxyOwner() {\n        require(msg.sender == readAddress(OWNER_SLOT), \"Proxy.onlyProxyOwner: msg sender not owner\");\n        _;\n    }\n\n    constructor () {\n        setAddress(OWNER_SLOT, msg.sender);\n    }\n\n    function getProxyOwner() public view returns (address) {\n       return readAddress(OWNER_SLOT);\n    }\n\n    function setProxyOwner(address _newOwner) onlyProxyOwner public {\n        setAddress(OWNER_SLOT, _newOwner);\n    }\n\n    function getImplementation() public view returns (address) {\n        return readAddress(IMPLEMENTATION_SLOT);\n    }\n\n    function setImplementation(address _newImplementation) onlyProxyOwner public {\n        setAddress(IMPLEMENTATION_SLOT, _newImplementation);\n    }\n\n\n    fallback () external payable {\n       return internalFallback();\n    }\n\n    receive () payable external {\n        return internalFallback();\n    }\n    function internalFallback() internal virtual {\n        address contractAddr = readAddress(IMPLEMENTATION_SLOT);\n        assembly {\n            let ptr := mload(0x40)\n            calldatacopy(ptr, 0, calldatasize())\n            let result := delegatecall(gas(), contractAddr, ptr, calldatasize(), 0, 0)\n            let size := returndatasize()\n            returndatacopy(ptr, 0, size)\n\n            switch result\n            case 0 { revert(ptr, size) }\n            default { return(ptr, size) }\n        }\n    }\n\n}"

    },

    "contracts/migrate/ProxyStorage.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.7.6;\ncontract ProxyStorage {\n\n    function readBool(bytes32 _key) public view returns(bool) {\n        return storageRead(_key) == bytes32(uint256(1));\n    }\n\n    function setBool(bytes32 _key, bool _value) internal {\n        if(_value) {\n            storageSet(_key, bytes32(uint256(1)));\n        } else {\n            storageSet(_key, bytes32(uint256(0)));\n        }\n    }\n\n    function readAddress(bytes32 _key) public view returns(address) {\n        return bytes32ToAddress(storageRead(_key));\n    }\n\n    function setAddress(bytes32 _key, address _value) internal {\n        storageSet(_key, addressToBytes32(_value));\n    }\n\n    function storageRead(bytes32 _key) public view returns(bytes32) {\n        bytes32 value;\n        //solium-disable-next-line security/no-inline-assembly\n        assembly {\n            value := sload(_key)\n        }\n        return value;\n    }\n\n    function storageSet(bytes32 _key, bytes32 _value) internal {\n        // targetAddress = _address;  // No!\n        bytes32 implAddressStorageKey = _key;\n        //solium-disable-next-line security/no-inline-assembly\n        assembly {\n            sstore(implAddressStorageKey, _value)\n        }\n    }\n\n    function bytes32ToAddress(bytes32 _value) public pure returns(address) {\n        return address(uint160(uint256(_value)));\n    }\n\n    function addressToBytes32(address _value) public pure returns(bytes32) {\n        return bytes32(uint256(uint160(_value)));\n    }\n\n}"

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

    }

  }

}}