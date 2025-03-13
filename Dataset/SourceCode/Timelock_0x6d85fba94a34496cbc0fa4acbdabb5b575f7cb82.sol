{{

  "language": "Solidity",

  "sources": {

    "src/Timelock.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.13;\n\ncontract Timelock {\n  error NotOwnerError();\n  error AlreadyQueuedError(bytes32 txId);\n  error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);\n  error NotQueuedError(bytes32 txId);\n  error TimestampNotPassedError(uint blockTimestmap, uint timestamp);\n  error TimestampExpiredError(uint blockTimestamp, uint expiresAt);\n  error TxFailedError();\n\n  event Queue(bytes32 indexed txId, address indexed target, uint value, string func, bytes data, uint timestamp);\n  event Execute(bytes32 indexed txId, address indexed target, uint value, string func, bytes data, uint timestamp);\n  event Cancel(bytes32 indexed txId);\n\n  uint public constant MIN_DELAY = 172800; // seconds\n  uint public constant MAX_DELAY = 604800; // seconds\n  uint public constant GRACE_PERIOD = 1000; // seconds\n\n  address public owner;\n  // tx id => queued\n  mapping(bytes32 => bool) public queued;\n\n  constructor() {\n    owner = msg.sender;\n  }\n\n  modifier onlyOwner() {\n    if (msg.sender != owner) {\n      revert NotOwnerError();\n    }\n    _;\n  }\n\n  receive() external payable {}\n\n  function getTxId(\n    address _target,\n    uint _value,\n    string calldata _func,\n    bytes calldata _data,\n    uint _timestamp\n  ) public pure returns (bytes32) {\n    return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));\n  }\n\n  /**\n   * @param _target Address of contract or account to call\n   * @param _value Amount of ETH to send\n   * @param _func Function signature, for example \"foo(address,uint256)\"\n   * @param _data ABI encoded data send.\n   * @param _timestamp Timestamp after which the transaction can be executed.\n   */\n  function queue(\n    address _target,\n    uint _value,\n    string calldata _func,\n    bytes calldata _data,\n    uint _timestamp\n  ) external onlyOwner returns (bytes32 txId) {\n    txId = getTxId(_target, _value, _func, _data, _timestamp);\n    if (queued[txId]) {\n      revert AlreadyQueuedError(txId);\n    }\n    // ---|------------|---------------|-------\n    //  block    block + min     block + max\n    if (_timestamp < block.timestamp + MIN_DELAY || _timestamp > block.timestamp + MAX_DELAY) {\n      revert TimestampNotInRangeError(block.timestamp, _timestamp);\n    }\n\n    queued[txId] = true;\n\n    emit Queue(txId, _target, _value, _func, _data, _timestamp);\n  }\n\n  function execute(\n    address _target,\n    uint _value,\n    string calldata _func,\n    bytes calldata _data,\n    uint _timestamp\n  ) external payable onlyOwner returns (bytes memory) {\n    bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);\n    if (!queued[txId]) {\n      revert NotQueuedError(txId);\n    }\n    // ----|-------------------|-------\n    //  timestamp    timestamp + grace period\n    if (block.timestamp < _timestamp) {\n      revert TimestampNotPassedError(block.timestamp, _timestamp);\n    }\n    if (block.timestamp > _timestamp + GRACE_PERIOD) {\n      revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);\n    }\n\n    queued[txId] = false;\n\n    // prepare data\n    bytes memory data;\n    if (bytes(_func).length > 0) {\n      // data = func selector + _data\n      data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);\n    } else {\n      // call fallback with data\n      data = _data;\n    }\n\n    // call target\n    (bool ok, bytes memory res) = _target.call{value: _value}(data);\n    if (!ok) {\n      revert TxFailedError();\n    }\n\n    emit Execute(txId, _target, _value, _func, _data, _timestamp);\n\n    return res;\n  }\n\n  function cancel(bytes32 _txId) external onlyOwner {\n    if (!queued[_txId]) {\n      revert NotQueuedError(_txId);\n    }\n\n    queued[_txId] = false;\n\n    emit Cancel(_txId);\n  }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "forge-std/=lib/forge-std/src/",

      "solmate/=lib/solmate/src/",

      "@uniswap/v3-core/=lib/v3-core/",

      "@uniswap/v3-periphery/=lib/v3-periphery/contracts/",

      "v3-core/=lib/v3-core/",

      "v3-periphery/=lib/v3-periphery/contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "useLiteralContent": false,

      "bytecodeHash": "ipfs",

      "appendCBOR": true

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

    "evmVersion": "shanghai",

    "libraries": {}

  }

}}