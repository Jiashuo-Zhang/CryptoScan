{{

  "language": "Solidity",

  "sources": {

    "contracts/core/constants/Common.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity ^0.8.15;\n\nstring constant OPERATION_STORAGE = \"OperationStorage_2\";\nstring constant OPERATION_EXECUTOR = \"OperationExecutor_2\";\nstring constant OPERATIONS_REGISTRY = \"OperationsRegistry_2\";\nstring constant CHAINLOG_VIEWER = \"ChainLogView\";\nstring constant ONE_INCH_AGGREGATOR = \"OneInchAggregator\";\nstring constant DS_GUARD_FACTORY = \"DSGuardFactory\";\nstring constant WETH = \"WETH\";\nstring constant DAI = \"DAI\";\nuint256 constant RAY = 10 ** 27;\nbytes32 constant NULL = \"\";\n\n/**\n * @dev We do not include patch versions in contract names to allow\n * for hotfixes of Action dma-contracts\n * and to limit updates to TheGraph\n * if the types encoded in emitted events change then use a minor version and\n * update the ServiceRegistry with a new entry\n * and update TheGraph decoding accordingly\n */\nstring constant POSITION_CREATED_ACTION = \"PositionCreated\";\n\nstring constant UNISWAP_ROUTER = \"UniswapRouter\";\nstring constant SWAP = \"Swap\";\n\naddress constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n"

    },

    "contracts/core/OperationsRegistry.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity ^0.8.15;\n\nimport { Operation } from \"./types/Common.sol\";\nimport { OPERATIONS_REGISTRY } from \"./constants/Common.sol\";\n\nstruct StoredOperation {\n  bytes32[] actions;\n  bool[] optional;\n  string name;\n}\n\n/**\n * @title Operation Registry\n * @notice Stores the Actions that constitute a given Operation and information if an Action can be skipped\n\n */\ncontract OperationsRegistry {\n  mapping(string => StoredOperation) private operations;\n  address public owner;\n\n  modifier onlyOwner() {\n    require(msg.sender == owner, \"only-owner\");\n    _;\n  }\n\n  constructor() {\n    owner = msg.sender;\n  }\n\n  /**\n   * @notice Stores the Actions that constitute a given Operation\n   * @param newOwner The address of the new owner of the Operations Registry\n   */\n  function transferOwnership(address newOwner) public onlyOwner {\n    owner = newOwner;\n  }\n\n  /**\n   * @dev Emitted when a new operation is added or an existing operation is updated\n   * @param name The Operation name\n   **/\n  event OperationAdded(bytes32 indexed name);\n\n  /**\n   * @notice Adds an Operation's Actions keyed to a an operation name\n   * @param operation Struct with Operation name, actions and their optionality\n   */\n  function addOperation(StoredOperation calldata operation) external onlyOwner {\n    operations[operation.name] = operation;\n    // By packing the string into bytes32 which means the max char length is capped at 64\n    emit OperationAdded(bytes32(abi.encodePacked(operation.name)));\n  }\n\n  /**\n   * @notice Gets an Operation from the Registry\n   * @param name The name of the Operation\n   * @return actions Returns an array of Actions and array for optionality of coresponding Actions\n   */\n  function getOperation(\n    string memory name\n  ) external view returns (bytes32[] memory actions, bool[] memory optional) {\n    if (keccak256(bytes(operations[name].name)) == keccak256(bytes(\"\"))) {\n      revert(\"Operation doesn't exist\");\n    }\n    actions = operations[name].actions;\n    optional = operations[name].optional;\n  }\n}\n"

    },

    "contracts/core/types/Common.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-or-later\npragma solidity ^0.8.15;\n\nenum FlashloanProvider {\n  DssFlash,\n  Balancer\n}\n\nstruct FlashloanData {\n  uint256 amount;\n  address asset;\n  bool isProxyFlashloan;\n  bool isDPMProxy;\n  FlashloanProvider provider;\n  Call[] calls;\n}\n\nstruct PullTokenData {\n  address asset;\n  address from;\n  uint256 amount;\n}\n\nstruct SendTokenData {\n  address asset;\n  address to;\n  uint256 amount;\n}\n\nstruct SetApprovalData {\n  address asset;\n  address delegate;\n  uint256 amount;\n  bool sumAmounts;\n}\n\nstruct SwapData {\n  address fromAsset;\n  address toAsset;\n  uint256 amount;\n  uint256 receiveAtLeast;\n  uint256 fee;\n  bytes withData;\n  bool collectFeeInFromToken;\n}\n\nstruct Call {\n  bytes32 targetHash;\n  bytes callData;\n  bool skipped;\n}\n\nstruct Operation {\n  uint8 currentAction;\n  bytes32[] actions;\n}\n\nstruct WrapEthData {\n  uint256 amount;\n}\n\nstruct UnwrapEthData {\n  uint256 amount;\n}\n\nstruct ReturnFundsData {\n  address asset;\n}\n\nstruct PositionCreatedData {\n  string protocol;\n  string positionType;\n  address collateralToken;\n  address debtToken;\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 1000

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