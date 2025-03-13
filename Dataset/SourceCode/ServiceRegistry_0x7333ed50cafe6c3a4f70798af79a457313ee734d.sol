{{

  "language": "Solidity",

  "sources": {

    "contracts/core/ServiceRegistry.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\n\n/// ServiceRegistry.sol\n\n// Copyright (C) 2021-2021 Oazo Apps Limited\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see <https://www.gnu.org/licenses/>.\npragma solidity ^0.8.0;\n\ncontract ServiceRegistry {\n  uint256 public constant MAX_DELAY = 30 days;\n\n  mapping(bytes32 => uint256) public lastExecuted;\n  mapping(bytes32 => address) private namedService;\n  mapping(bytes32 => bool) private invalidHashes;\n  address public owner;\n  uint256 public requiredDelay;\n\n  modifier validateInput(uint256 len) {\n    require(msg.data.length == len, \"registry/illegal-padding\");\n    _;\n  }\n\n  modifier delayedExecution() {\n    bytes32 operationHash = keccak256(msg.data);\n    uint256 reqDelay = requiredDelay;\n\n    /* solhint-disable not-rely-on-time */\n    if (lastExecuted[operationHash] == 0 && reqDelay > 0) {\n      // not called before, scheduled for execution\n      lastExecuted[operationHash] = block.timestamp;\n      emit ChangeScheduled(operationHash, block.timestamp + reqDelay, msg.data);\n    } else {\n      require(block.timestamp - reqDelay > lastExecuted[operationHash], \"registry/delay-too-small\");\n      emit ChangeApplied(operationHash, block.timestamp, msg.data);\n      _;\n      lastExecuted[operationHash] = 0;\n    }\n    /* solhint-enable not-rely-on-time */\n  }\n\n  modifier onlyOwner() {\n    require(msg.sender == owner, \"registry/only-owner\");\n    _;\n  }\n\n  constructor(uint256 initialDelay) {\n    require(initialDelay <= MAX_DELAY, \"registry/invalid-delay\");\n    requiredDelay = initialDelay;\n    owner = msg.sender;\n  }\n\n  function transferOwnership(\n    address newOwner\n  ) external onlyOwner validateInput(36) delayedExecution {\n    owner = newOwner;\n  }\n\n  function changeRequiredDelay(\n    uint256 newDelay\n  ) external onlyOwner validateInput(36) delayedExecution {\n    require(newDelay <= MAX_DELAY, \"registry/invalid-delay\");\n    requiredDelay = newDelay;\n  }\n\n  function getServiceNameHash(string memory name) external pure returns (bytes32) {\n    return keccak256(abi.encodePacked(name));\n  }\n\n  function addNamedService(\n    bytes32 serviceNameHash,\n    address serviceAddress\n  ) external onlyOwner validateInput(68) delayedExecution {\n    require(invalidHashes[serviceNameHash] == false, \"registry/service-name-used-before\");\n    require(namedService[serviceNameHash] == address(0), \"registry/service-override\");\n    namedService[serviceNameHash] = serviceAddress;\n    emit NamedServiceAdded(serviceNameHash, serviceAddress);\n  }\n\n  function removeNamedService(bytes32 serviceNameHash) external onlyOwner validateInput(36) {\n    require(namedService[serviceNameHash] != address(0), \"registry/service-does-not-exist\");\n    namedService[serviceNameHash] = address(0);\n    invalidHashes[serviceNameHash] = true;\n    emit NamedServiceRemoved(serviceNameHash);\n  }\n\n  function getRegisteredService(string memory serviceName) external view returns (address) {\n    return namedService[keccak256(abi.encodePacked(serviceName))];\n  }\n\n  function getServiceAddress(bytes32 serviceNameHash) external view returns (address) {\n    return namedService[serviceNameHash];\n  }\n\n  function clearScheduledExecution(\n    bytes32 scheduledExecution\n  ) external onlyOwner validateInput(36) {\n    require(lastExecuted[scheduledExecution] > 0, \"registry/execution-not-scheduled\");\n    lastExecuted[scheduledExecution] = 0;\n    emit ChangeCancelled(scheduledExecution);\n  }\n\n  event ChangeScheduled(bytes32 dataHash, uint256 scheduledFor, bytes data);\n  event ChangeApplied(bytes32 dataHash, uint256 appliedAt, bytes data);\n  event ChangeCancelled(bytes32 dataHash);\n  event NamedServiceRemoved(bytes32 nameHash);\n  event NamedServiceAdded(bytes32 nameHash, address service);\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 0

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "libraries": {}

  }

}}