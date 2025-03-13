{{

  "language": "Solidity",

  "sources": {

    "contracts/timelock.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.17;\n\ncontract TimeLock {\n    error NotOwnerError();\n    error AlreadyQueuedError(bytes32 txId);\n    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);\n    error NotQueuedError(bytes32 txId);\n    error TimestampNotPassedError(uint blockTimestmap, uint timestamp);\n    error TimestampExpiredError(uint blockTimestamp, uint expiresAt);\n    error TxFailedError();\n\n    event Queue(\n        bytes32 indexed txId,\n        address indexed target,\n        uint value,\n        string func,\n        bytes data,\n        uint timestamp\n    );\n    event Execute(\n        bytes32 indexed txId,\n        address indexed target,\n        uint value,\n        string func,\n        bytes data,\n        uint timestamp\n    );\n    event Cancel(bytes32 indexed txId);\n\n    uint public constant MIN_DELAY = 21600; // 6 hr in seconds\n    uint public constant MAX_DELAY = 43200; // 12 hr seconds\n    uint public constant GRACE_PERIOD = 43200; // 12 hr seconds\n\n    address public owner;\n    // tx id => queued\n    mapping(bytes32 => bool) public queued;\n\n    constructor() {\n        owner = msg.sender;\n    }\n\n    modifier onlyOwner() {\n        if (msg.sender != owner) {\n            revert NotOwnerError();\n        }\n        _;\n    }\n\n    receive() external payable {}\n\n    function getTxId(\n        address _target,\n        uint _value,\n        string calldata _func,\n        bytes calldata _data,\n        uint _timestamp\n    ) public pure returns (bytes32) {\n        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));\n    }\n\n    /**\n     * @param _target Address of contract or account to call\n     * @param _value Amount of ETH to send\n     * @param _func Function signature, for example \"foo(address,uint256)\"\n     * @param _data ABI encoded data send.\n     * @param _timestamp Timestamp after which the transaction can be executed.\n     */\n    function queue(\n        address _target,\n        uint _value,\n        string calldata _func,\n        bytes calldata _data,\n        uint _timestamp\n    ) external onlyOwner returns (bytes32 txId) {\n        txId = getTxId(_target, _value, _func, _data, _timestamp);\n        if (queued[txId]) {\n            revert AlreadyQueuedError(txId);\n        }\n        // ---|------------|---------------|-------\n        //  block    block + min     block + max\n        if (\n            _timestamp < block.timestamp + MIN_DELAY ||\n            _timestamp > block.timestamp + MAX_DELAY\n        ) {\n            revert TimestampNotInRangeError(block.timestamp, _timestamp);\n        }\n\n        queued[txId] = true;\n\n        emit Queue(txId, _target, _value, _func, _data, _timestamp);\n    }\n\n    function execute(\n        address _target,\n        uint _value,\n        string calldata _func,\n        bytes calldata _data,\n        uint _timestamp\n    ) external payable onlyOwner returns (bytes memory) {\n        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);\n        if (!queued[txId]) {\n            revert NotQueuedError(txId);\n        }\n        // ----|-------------------|-------\n        //  timestamp    timestamp + grace period\n        if (block.timestamp < _timestamp) {\n            revert TimestampNotPassedError(block.timestamp, _timestamp);\n        }\n        if (block.timestamp > _timestamp + GRACE_PERIOD) {\n            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);\n        }\n\n        queued[txId] = false;\n\n        // prepare data\n        bytes memory data;\n        if (bytes(_func).length > 0) {\n            // data = func selector + _data\n            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);\n        } else {\n            // call fallback with data\n            data = _data;\n        }\n\n        // call target\n        (bool ok, bytes memory res) = _target.call{value: _value}(data);\n        if (!ok) {\n            revert TxFailedError();\n        }\n\n        emit Execute(txId, _target, _value, _func, _data, _timestamp);\n\n        return res;\n    }\n    \n    function transferOwnership(address newAddress) public onlyOwner {\n        require(newAddress != address(0),\"Invalid Address\");\n        owner = newAddress;\n    }\n\n\n    function cancel(bytes32 _txId) external onlyOwner {\n        if (!queued[_txId]) {\n            revert NotQueuedError(_txId);\n        }\n\n        queued[_txId] = false;\n\n        emit Cancel(_txId);\n    }\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": false,

      "runs": 200

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

    }

  }

}}