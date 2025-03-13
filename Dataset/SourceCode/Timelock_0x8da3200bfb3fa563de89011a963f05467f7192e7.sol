{{

  "language": "Solidity",

  "sources": {

    "contracts/timelock/Timelock.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\n\npragma solidity >=0.8.0 <0.9.0;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract Timelock is Ownable {\n    event NewAdmin(address indexed newAdmin);\n    event NewPendingAdmin(address indexed newPendingAdmin);\n    event NewDelay(uint256 indexed newDelay);\n    event CancelTransaction(\n        bytes32 indexed txHash,\n        address indexed target,\n        uint256 value,\n        string signature,\n        bytes data,\n        uint256 eta\n    );\n    event ExecuteTransaction(\n        bytes32 indexed txHash,\n        address indexed target,\n        uint256 value,\n        string signature,\n        bytes data,\n        uint256 eta\n    );\n    event QueueTransaction(\n        bytes32 indexed txHash,\n        address indexed target,\n        uint256 value,\n        string signature,\n        bytes data,\n        uint256 eta\n    );\n\n    uint256 public constant GRACE_PERIOD = 14 days;\n    uint256 public constant MINIMUM_DELAY = 12 hours;\n    uint256 public constant MAXIMUM_DELAY = 30 days;\n\n    address public admin;\n    address public pendingAdmin;\n    uint256 public delay;\n    bool public admin_initialized;\n\n    mapping(bytes32 => bool) public queuedTransactions;\n\n    modifier onlyAdmin() {\n        require(\n            admin == msg.sender,\n            \"Timelock::queueTransaction: Call must come from admin.\"\n        );\n        _;\n    }\n\n    constructor(address admin_, uint256 delay_) {\n        require(\n            delay_ >= MINIMUM_DELAY,\n            \"Timelock::constructor: Delay must exceed minimum delay.\"\n        );\n        require(\n            delay_ <= MAXIMUM_DELAY,\n            \"Timelock::constructor: Delay must not exceed maximum delay.\"\n        );\n\n        admin = admin_;\n        delay = delay_;\n        admin_initialized = false;\n    }\n\n    // XXX: function() external payable { }\n    receive() external payable {}\n\n    function setDelay(uint256 delay_) public {\n        require(\n            msg.sender == address(this),\n            \"Timelock::setDelay: Call must come from Timelock.\"\n        );\n        require(\n            delay_ >= MINIMUM_DELAY,\n            \"Timelock::setDelay: Delay must exceed minimum delay.\"\n        );\n        require(\n            delay_ <= MAXIMUM_DELAY,\n            \"Timelock::setDelay: Delay must not exceed maximum delay.\"\n        );\n        delay = delay_;\n\n        emit NewDelay(delay);\n    }\n\n    function acceptAdmin() public {\n        require(\n            msg.sender == pendingAdmin,\n            \"Timelock::acceptAdmin: Call must come from pendingAdmin.\"\n        );\n        admin = msg.sender;\n        pendingAdmin = address(0);\n\n        emit NewAdmin(admin);\n    }\n\n    function setPendingAdmin(address pendingAdmin_) public {\n        // allows one time setting of admin for deployment purposes\n        if (admin_initialized) {\n            require(\n                msg.sender == address(this),\n                \"Timelock::setPendingAdmin: Call must come from Timelock.\"\n            );\n        } else {\n            require(\n                msg.sender == admin,\n                \"Timelock::setPendingAdmin: First call must come from admin.\"\n            );\n            admin_initialized = true;\n        }\n        pendingAdmin = pendingAdmin_;\n\n        emit NewPendingAdmin(pendingAdmin);\n    }\n\n    function queueTransaction(\n        address target,\n        uint256 value,\n        string memory signature,\n        bytes memory data,\n        uint256 eta\n    ) public onlyAdmin returns (bytes32) {\n        require(\n            eta >= getBlockTimestamp() + delay,\n            \"Timelock::queueTransaction: Estimated execution block must satisfy delay.\"\n        );\n\n        bytes32 txHash = keccak256(\n            abi.encode(target, value, signature, data, eta)\n        );\n        queuedTransactions[txHash] = true;\n        emit QueueTransaction(txHash, target, value, signature, data, eta);\n        return txHash;\n    }\n\n    function cancelTransaction(\n        address target,\n        uint256 value,\n        string memory signature,\n        bytes memory data,\n        uint256 eta\n    ) public onlyAdmin {\n        bytes32 txHash = keccak256(\n            abi.encode(target, value, signature, data, eta)\n        );\n        queuedTransactions[txHash] = false;\n\n        emit CancelTransaction(txHash, target, value, signature, data, eta);\n    }\n\n    function executeTransaction(\n        address target,\n        uint256 value,\n        string memory signature,\n        bytes memory data,\n        uint256 eta\n    ) public payable onlyAdmin returns (bytes memory) {\n        bytes32 txHash = keccak256(\n            abi.encode(target, value, signature, data, eta)\n        );\n        require(\n            queuedTransactions[txHash],\n            \"Timelock::executeTransaction: Transaction hasn't been queued.\"\n        );\n        // require(\n        //     getBlockTimestamp() >= eta,\n        //     \"Timelock::executeTransaction: Transaction hasn't surpassed time lock.\"\n        // );\n        // require(\n        //     getBlockTimestamp() <= eta + GRACE_PERIOD,\n        //     \"Timelock::executeTransaction: Transaction is stale.\"\n        // );\n\n        queuedTransactions[txHash] = false;\n\n        bytes memory callData;\n\n        if (bytes(signature).length == 0) {\n            callData = data;\n        } else {\n            callData = abi.encodePacked(\n                bytes4(keccak256(bytes(signature))),\n                data\n            );\n        }\n\n        // solium-disable-next-line security/no-call-value\n        (bool success, bytes memory returnData) = target.call{value: value}(\n            callData\n        );\n        require(\n            success,\n            \"Timelock::executeTransaction: Transaction execution reverted.\"\n        );\n\n        emit ExecuteTransaction(txHash, target, value, signature, data, eta);\n\n        return returnData;\n    }\n\n    function getBlockTimestamp() internal view returns (uint256) {\n        // solium-disable-next-line security/no-block-members\n        return block.timestamp;\n    }\n}\n"

    },

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 10000

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