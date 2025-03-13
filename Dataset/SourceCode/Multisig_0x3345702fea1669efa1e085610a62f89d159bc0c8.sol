{{

  "language": "Solidity",

  "sources": {

    "contracts/bridge/v2/libs/MemberSet.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\n// LightLink 2023\nlibrary MemberSet {\n  struct Record {\n    address[] values;\n    mapping(address => uint256) indexes; // value to index\n  }\n\n  function add(Record storage _record, address _value) internal {\n    if (contains(_record, _value)) return; // exist\n    _record.values.push(_value);\n    _record.indexes[_value] = _record.values.length;\n  }\n\n  function remove(Record storage _record, address _value) internal {\n    uint256 valueIndex = _record.indexes[_value];\n    if (valueIndex == 0) return; // removed non-exist value\n    uint256 toDeleteIndex = valueIndex - 1; // dealing with out of bounds\n    uint256 lastIndex = _record.values.length - 1;\n    if (lastIndex != toDeleteIndex) {\n      address lastvalue = _record.values[lastIndex];\n      _record.values[toDeleteIndex] = lastvalue;\n      _record.indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex\n    }\n    _record.values.pop();\n    _record.indexes[_value] = 0; // set to 0\n  }\n\n  function contains(Record storage _record, address _value) internal view returns (bool) {\n    return _record.indexes[_value] != 0;\n  }\n\n  function size(Record storage _record) internal view returns (uint256) {\n    return _record.values.length;\n  }\n\n  function at(Record storage _record, uint256 _index) internal view returns (address) {\n    return _record.values[_index];\n  }\n}"

    },

    "contracts/bridge/v2/prerequisite/Multisig.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\nimport \"../libs/MemberSet.sol\";\nimport \"./Multisigable.sol\";\n\n// LightLink 2023\ncontract Multisig is Multisigable {\n  using MemberSet for MemberSet.Record;\n\n  struct Transaction {\n    bool executed;\n    address target;\n    bytes data;\n    uint256 value;\n    uint256 numConfirmations;\n  }\n\n  // variables\n  MemberSet.Record internal members;\n  // mapping from tx index => owner => bool\n  mapping(uint256 => mapping(address => bool)) public isConfirmed;\n  Transaction[] public transactions;\n\n  event SubmitTransaction(uint256 indexed txIndex, address indexed account, uint256 value, bytes data);\n  event ConfirmTransaction(uint256 indexed txIndex, address indexed owner);\n  event RevokeConfirmation(uint256 indexed txIndex, address indexed owner);\n  event ExecuteTransaction(uint256 indexed txIndex, address indexed owner);\n\n  constructor() {\n    __Multisigable_init(address(this));\n    members.add(0xdE2552948aacb82dCa7a04AffbcB1B8e3C97D590);\n    members.add(0x26623571D709862776a0E061617634e6474393F2);\n  }\n\n  /** Modifier */\n  // verified\n  modifier requireOwner() {\n    require(members.contains(msg.sender), \"Owner required\");\n    _;\n  }\n\n  // verified\n  modifier requireTxExists(uint256 _txIndex) {\n    require(_txIndex < transactions.length, \"Nonexistent tx\");\n    _;\n  }\n\n  modifier requireTxNotExecuted(uint256 _txIndex) {\n    require(!transactions[_txIndex].executed, \"Tx already executed\");\n    _;\n  }\n\n  /* View */\n  // verified\n  function isOwner(address _account) public view returns (bool) {\n    return members.contains(_account);\n  }\n\n  // verified\n  function getMembers() public view returns (address[] memory) {\n    uint256 size = members.size();\n    address[] memory records = new address[](size);\n\n    for (uint256 i = 0; i < size; i++) {\n      records[i] = members.at(i);\n    }\n    return records;\n  }\n\n  // verified\n  function getMemberByIndex(uint256 _index) public view returns (address) {\n    return members.at(_index);\n  }\n\n  // verified\n  function getTransactionCount() public view returns (uint256) {\n    return transactions.length;\n  }\n\n  // verified\n  function getTransaction(uint256 _idx) public view returns (Transaction memory, bytes4 funcSelector) {\n    bytes memory data = transactions[_idx].data;\n    assembly {\n      funcSelector := mload(add(data, 32))\n    }\n    return (transactions[_idx], funcSelector);\n  }\n\n  // verified\n  function getSelector(string calldata _func) public pure returns (bytes4) {\n    return bytes4(keccak256(bytes(_func)));\n  }\n\n  /* Admins */\n  // verified\n  function addMember(address _account) public virtual requireMultisig {\n    members.add(_account);\n  }\n\n  // verified\n  function removeMember(address _account) public virtual requireMultisig {\n    require(members.size() > 1, \"Cannot remove last member\");\n    members.remove(_account);\n  }\n\n  // verified\n  function submitTransaction(address _target, uint256 _value, bytes calldata _data) public requireOwner {\n    _beforeAddTransaction(_data);\n\n    uint256 txIndex = transactions.length;\n\n    transactions.push(Transaction({ executed: false, target: _target, data: _data, value: _value, numConfirmations: 0 }));\n\n    confirmTransaction(txIndex);\n\n    emit SubmitTransaction(txIndex, msg.sender, _value, _data);\n  }\n\n  // verified\n  function confirmTransaction(uint256 _txIndex) public requireOwner requireTxExists(_txIndex) requireTxNotExecuted(_txIndex) {\n    Transaction storage transaction = transactions[_txIndex];\n\n    require(!isConfirmed[_txIndex][msg.sender], \"Already confirmed\");\n\n    transaction.numConfirmations += 1;\n    isConfirmed[_txIndex][msg.sender] = true;\n\n    emit ConfirmTransaction(_txIndex, msg.sender);\n  }\n\n  // verified\n  function executeTransaction(uint256 _txIndex) public requireOwner requireTxExists(_txIndex) requireTxNotExecuted(_txIndex) {\n    Transaction storage transaction = transactions[_txIndex];\n    uint256 numConfirmationsRequired = members.size() / 2 + 1;\n\n    require(transaction.numConfirmations >= numConfirmationsRequired, \"Confirmations required\");\n\n    transaction.executed = true;\n\n    (bool success, ) = transaction.target.call{ value: transaction.value }(transaction.data);\n    require(success, \"Tx failed\");\n\n    emit ExecuteTransaction(_txIndex, msg.sender);\n  }\n\n  // verified\n  function revokeConfirmation(uint256 _txIndex) public requireOwner requireTxExists(_txIndex) requireTxNotExecuted(_txIndex) {\n    Transaction storage transaction = transactions[_txIndex];\n\n    require(isConfirmed[_txIndex][msg.sender], \"Confirmation required\");\n\n    transaction.numConfirmations -= 1;\n    isConfirmed[_txIndex][msg.sender] = false;\n\n    emit RevokeConfirmation(_txIndex, msg.sender);\n  }\n\n  /* Internal */\n  // verified\n  function _beforeAddTransaction(bytes calldata _data) internal pure virtual {\n    // bytes4 funcSelector = bytes4(_data[:4]);\n  }\n}\n"

    },

    "contracts/bridge/v2/prerequisite/Multisigable.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\n// LightLink 2023\nabstract contract Multisigable {\n  address public multisig;\n\n  /** Modifier */\n  // verified\n  modifier requireMultisig() {\n    require(msg.sender == multisig, \"Multisig required\");\n    _;\n  }\n\n  function modifyMultisig(address _multisig) public requireMultisig {\n    require(_multisig != address(0), \"Multisig address cannot be zero\");\n    multisig = _multisig;\n  }\n\n  function __Multisigable_init(address _multisig) internal {\n    require(_multisig != address(0), \"Multisig address cannot be zero\");\n    multisig = _multisig;\n  }\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 9999

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