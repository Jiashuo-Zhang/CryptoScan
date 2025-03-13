{{

  "language": "Solidity",

  "sources": {

    "Multisig.sol": {

      "content": "pragma solidity ^0.4.23;\n\nimport \"Multiownable.sol\";\nimport \"IProposal.sol\";\n\ncontract Multisig is Multiownable\n{\n\tuint256 public timeout;\n\n\tmapping (bytes32 => uint256) public initiationTimeByOperation;\n\n\tevent TimeoutExpired(bytes32 operation);\n\n\tevent OperationCreatedWithParams(bytes32 indexed operation, address contractAddress, bytes data);\n\n\tmodifier onlyNotExpired(address contractAddress, bytes data)\n\t{\n\t\tbytes32 operation = keccak256(msg.data, ownersGeneration);\n\t\tif (initiationTimeByOperation[operation] == 0)\n\t\t{\n\t\t\tinitiationTimeByOperation[operation] = block.timestamp;\n\t\t\temit OperationCreatedWithParams(operation, contractAddress, data);\n\t\t}\n\n\t\tif (block.timestamp - initiationTimeByOperation[operation] > timeout)\n\t\t{\n\t\t\tinitiationTimeByOperation[operation] = 0;\n\t\t\tdeleteOperation(operation);\n\n\t\t\temit TimeoutExpired(operation);\n\t\t}\n\t\telse\n\t\t{\n\t\t\t_;\n\t\t}\n\t}\n\n\tconstructor(uint256 _timeout) Multiownable() public\n\t{\n\t\ttimeout = _timeout;\n\t}\n\n\tfunction voteForCall(address to, bytes data) external onlyNotExpired(to, data) onlyManyOwners()\n\t{\n\t\tbool success = to.call(data);\n\t\trequire(success, \"call failed\");\n\t}\n\n\tfunction getOwners() external view returns (address[])\n\t{\n\t\treturn owners;\n\t}\n\n\tfunction voteForDelegatecall(address proposal) external onlyNotExpired(proposal, \"\") onlyManyOwners()\n\t{\n\t\tproposal.delegatecall(abi.encodeWithSignature(\"execute()\"));\n\t}\n}"

    },

    "Multiownable.sol": {

      "content": "pragma solidity ^0.4.23;\n\n\ncontract Multiownable {\n\n    // VARIABLES\n\n    uint256 public ownersGeneration;\n    uint256 public howManyOwnersDecide;\n    address[] public owners;\n    bytes32[] public allOperations;\n    address internal insideCallSender;\n    uint256 internal insideCallCount;\n\n    // Reverse lookup tables for owners and allOperations\n    mapping(address => uint) public ownersIndices; // Starts from 1\n    mapping(bytes32 => uint) public allOperationsIndicies;\n\n    // Owners voting mask per operations\n    mapping(bytes32 => uint256) public votesMaskByOperation;\n    mapping(bytes32 => uint256) public votesCountByOperation;\n\n    // EVENTS\n\n    event OwnershipTransferred(address[] previousOwners, uint howManyOwnersDecide, address[] newOwners, uint newHowManyOwnersDecide);\n    event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);\n    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);\n    event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);\n    event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount,  address downvoter);\n    event OperationCancelled(bytes32 operation, address lastCanceller);\n    \n    // ACCESSORS\n\n    function isOwner(address wallet) public constant returns(bool) {\n        return ownersIndices[wallet] > 0;\n    }\n\n    function ownersCount() public constant returns(uint) {\n        return owners.length;\n    }\n\n    function allOperationsCount() public constant returns(uint) {\n        return allOperations.length;\n    }\n\n    // MODIFIERS\n\n    /**\n    * @dev Allows to perform method by any of the owners\n    */\n    modifier onlyAnyOwner {\n        if (checkHowManyOwners(1)) {\n            bool update = (insideCallSender == address(0));\n            if (update) {\n                insideCallSender = msg.sender;\n                insideCallCount = 1;\n            }\n            _;\n            if (update) {\n                insideCallSender = address(0);\n                insideCallCount = 0;\n            }\n        }\n    }\n\n    /**\n    * @dev Allows to perform method only after many owners call it with the same arguments\n    */\n    modifier onlyManyOwners {\n        if (checkHowManyOwners(howManyOwnersDecide)) {\n            bool update = (insideCallSender == address(0));\n            if (update) {\n                insideCallSender = msg.sender;\n                insideCallCount = howManyOwnersDecide;\n            }\n            _;\n            if (update) {\n                insideCallSender = address(0);\n                insideCallCount = 0;\n            }\n        }\n    }\n\n    /**\n    * @dev Allows to perform method only after all owners call it with the same arguments\n    */\n    modifier onlyAllOwners {\n        if (checkHowManyOwners(owners.length)) {\n            bool update = (insideCallSender == address(0));\n            if (update) {\n                insideCallSender = msg.sender;\n                insideCallCount = owners.length;\n            }\n            _;\n            if (update) {\n                insideCallSender = address(0);\n                insideCallCount = 0;\n            }\n        }\n    }\n\n    /**\n    * @dev Allows to perform method only after some owners call it with the same arguments\n    */\n    modifier onlySomeOwners(uint howMany) {\n        require(howMany > 0, \"onlySomeOwners: howMany argument is zero\");\n        require(howMany <= owners.length, \"onlySomeOwners: howMany argument exceeds the number of owners\");\n        \n        if (checkHowManyOwners(howMany)) {\n            bool update = (insideCallSender == address(0));\n            if (update) {\n                insideCallSender = msg.sender;\n                insideCallCount = howMany;\n            }\n            _;\n            if (update) {\n                insideCallSender = address(0);\n                insideCallCount = 0;\n            }\n        }\n    }\n\n    // CONSTRUCTOR\n\n    constructor() public {\n        owners.push(msg.sender);\n        ownersIndices[msg.sender] = 1;\n        howManyOwnersDecide = 1;\n    }\n\n    // INTERNAL METHODS\n\n    /**\n     * @dev onlyManyOwners modifier helper\n     */\n    function checkHowManyOwners(uint howMany) internal returns(bool) {\n        if (insideCallSender == msg.sender) {\n            require(howMany <= insideCallCount, \"checkHowManyOwners: nested owners modifier check require more owners\");\n            return true;\n        }\n\n        uint ownerIndex = ownersIndices[msg.sender] - 1;\n        require(ownerIndex < owners.length, \"checkHowManyOwners: msg.sender is not an owner\");\n        bytes32 operation = keccak256(msg.data, ownersGeneration);\n\n        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0, \"checkHowManyOwners: owner already voted for the operation\");\n        votesMaskByOperation[operation] |= (2 ** ownerIndex);\n        uint operationVotesCount = votesCountByOperation[operation] + 1;\n        votesCountByOperation[operation] = operationVotesCount;\n        if (operationVotesCount == 1) {\n            allOperationsIndicies[operation] = allOperations.length;\n            allOperations.push(operation);\n            emit OperationCreated(operation, howMany, owners.length, msg.sender);\n        }\n        emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);\n\n        // If enough owners confirmed the same operation\n        if (votesCountByOperation[operation] == howMany) {\n            deleteOperation(operation);\n            emit OperationPerformed(operation, howMany, owners.length, msg.sender);\n            return true;\n        }\n\n        return false;\n    }\n\n    /**\n    * @dev Used to delete cancelled or performed operation\n    * @param operation defines which operation to delete\n    */\n    function deleteOperation(bytes32 operation) internal {\n        uint index = allOperationsIndicies[operation];\n        if (index < allOperations.length - 1) { // Not last\n            allOperations[index] = allOperations[allOperations.length - 1];\n            allOperationsIndicies[allOperations[index]] = index;\n        }\n        allOperations.length--;\n\n        delete votesMaskByOperation[operation];\n        delete votesCountByOperation[operation];\n        delete allOperationsIndicies[operation];\n    }\n\n    // PUBLIC METHODS\n\n    /**\n    * @dev Allows owners to change their mind by cacnelling votesMaskByOperation operations\n    * @param operation defines which operation to delete\n    */\n    function cancelPending(bytes32 operation) public onlyAnyOwner {\n        uint ownerIndex = ownersIndices[msg.sender] - 1;\n        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0, \"cancelPending: operation not found for this user\");\n        votesMaskByOperation[operation] &= ~(2 ** ownerIndex);\n        uint operationVotesCount = votesCountByOperation[operation] - 1;\n        votesCountByOperation[operation] = operationVotesCount;\n        emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);\n        if (operationVotesCount == 0) {\n            deleteOperation(operation);\n            emit OperationCancelled(operation, msg.sender);\n        }\n    }\n\n    /**\n    * @dev Allows owners to change ownership\n    * @param newOwners defines array of addresses of new owners\n    */\n    function transferOwnership(address[] newOwners) public {\n        transferOwnershipWithHowMany(newOwners, newOwners.length);\n    }\n\n    /**\n    * @dev Allows owners to change ownership\n    * @param newOwners defines array of addresses of new owners\n    * @param newHowManyOwnersDecide defines how many owners can decide\n    */\n    function transferOwnershipWithHowMany(address[] newOwners, uint256 newHowManyOwnersDecide) public onlyManyOwners {\n        require(newOwners.length > 0, \"transferOwnershipWithHowMany: owners array is empty\");\n        require(newOwners.length <= 256, \"transferOwnershipWithHowMany: owners count is greater then 256\");\n        require(newHowManyOwnersDecide > 0, \"transferOwnershipWithHowMany: newHowManyOwnersDecide equal to 0\");\n        require(newHowManyOwnersDecide <= newOwners.length, \"transferOwnershipWithHowMany: newHowManyOwnersDecide exceeds the number of owners\");\n\n        // Reset owners reverse lookup table\n        for (uint j = 0; j < owners.length; j++) {\n            delete ownersIndices[owners[j]];\n        }\n        for (uint i = 0; i < newOwners.length; i++) {\n            require(newOwners[i] != address(0), \"transferOwnershipWithHowMany: owners array contains zero\");\n            require(ownersIndices[newOwners[i]] == 0, \"transferOwnershipWithHowMany: owners array contains duplicates\");\n            ownersIndices[newOwners[i]] = i + 1;\n        }\n        \n        emit OwnershipTransferred(owners, howManyOwnersDecide, newOwners, newHowManyOwnersDecide);\n        owners = newOwners;\n        howManyOwnersDecide = newHowManyOwnersDecide;\n        allOperations.length = 0;\n        ownersGeneration++;\n    }\n\n}\n"

    },

    "IProposal.sol": {

      "content": "pragma solidity ^0.4.23;\n\ninterface IProposal\n{\n\tfunction execute() external;\n}"

    }

  },

  "settings": {

    "evmVersion": "byzantium",

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "libraries": {

      "Multisig.sol": {}

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