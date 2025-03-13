{{

  "language": "Solidity",

  "sources": {

    "Contribution.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.8.0;\n\ncontract Contribution {\n\n    // roles\n    address public immutable owner;\n    address payable public immutable beneficiary;\n\n    // countdown and threshold\n    bool public materialReleaseConditionMet = false;\n    uint256 public deadline;\n    uint256 public countdownPeriod;\n    uint256 public threshold;\n    uint256 public minContribution;\n    uint256 public initialWindow;  // TODO: Constant?\n\n    // commit and reveal\n    bool public isKeySet = false;\n    bytes32 public keyPlaintextHash;\n    bytes public keyCiphertext;\n    bytes public keyPlaintext;\n\n    // testnet mode\n    bool public testnet;\n\n    // contributions storage\n    bool[] public contributionIsCombined;\n    uint256[] public contributionAmounts;\n    uint256[] public contributionDatetimes;\n    address[] public contributorsForEachContribution;\n\n    address public artifactContract;\n\n    //events\n    event Contribute(address indexed contributor, uint256 amount);\n    event Decryptable(address indexed lastContributor);\n    event Withdraw(address indexed beneficiary, uint256 amount);\n    event ClockReset(uint256 deadline);\n\n    constructor(\n        uint256 _countdownPeriod,\n        uint256 _threshold,\n        uint256 _minContribution,\n        uint256 _initialWindow,\n        address payable _beneficiary,\n        bool _testnet\n    ) {\n        countdownPeriod = _countdownPeriod;\n        deadline = 0;\n        owner = msg.sender;\n        beneficiary = payable(_beneficiary);\n        threshold = _threshold;\n        minContribution = _minContribution;\n        testnet = _testnet;\n        initialWindow = _initialWindow;  // 2 weeks\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner,\n            \"Only the contract owner can call this function.\");\n        _;\n    }\n\n    modifier onlyBeneficiary() {\n        require(\n            msg.sender == beneficiary,\n            \"Only the beneficiary can call this function.\"\n        );\n        _;\n    }\n\n    //\n    // Testnet functions\n    //\n\n    function resetClock() external onlyOwner {\n        require(testnet, \"This function is only available on testnet.\");\n        deadline = block.timestamp + countdownPeriod;\n    }\n\n    function setMaterialReleaseConditionMet(bool status) external onlyOwner {\n        require(testnet, \"This function is only available on testnet.\");\n        materialReleaseConditionMet = status;\n    }\n\n    function setThreshold(uint256 _threshold) external onlyOwner {\n        require(testnet, \"This function is only available on testnet.\");\n        threshold = _threshold;\n    }\n\n    //\n    // Production functions\n    //\n\n    function setArtifactContract(address _artifactContract) public onlyOwner {\n        artifactContract = _artifactContract;\n    }\n\n    function commitSecret(bytes32 _hash, bytes memory _ciphertext) external onlyOwner {\n        if (!testnet) {\n            require(!isKeySet, \"Key already set.\");\n        }\n        keyPlaintextHash = _hash;\n        keyCiphertext = _ciphertext;\n        isKeySet = true;\n        deadline = block.timestamp + initialWindow; // The initial window begins now and lasts initialWindow seconds.\n    }\n\n    function revealSecret(bytes memory secret) external {\n        require(materialReleaseConditionMet, \"Material has not been set for a release.\");\n        require(keccak256(secret) == keyPlaintextHash, \"Invalid secret provided, hash does not match.\");\n        keyPlaintext = secret;\n    }\n\n    function _contribute(bool combine) internal {\n        require(isKeySet, \"Material is not ready for contributions yet.\");\n        require(!materialReleaseConditionMet || block.timestamp < deadline,\n            \"Cannot contribute after the deadline\");\n        require(msg.value >= minContribution,\n            \"Contribution must be equal to or greater than the minimum.\");\n\n        contributionAmounts.push(msg.value);\n        contributorsForEachContribution.push(msg.sender);\n        contributionIsCombined.push(combine);\n        contributionDatetimes.push(block.timestamp);\n\n        if (address(this).balance >= threshold && !materialReleaseConditionMet) {\n            materialReleaseConditionMet = true;  // BOOM! Release the material!\n            emit Decryptable(msg.sender);\n        }\n\n        if (materialReleaseConditionMet) {\n\n            // If the deadline is within the countdownPeriod, extend it by countdownPeriod.\n            if (deadline - block.timestamp < countdownPeriod) {\n                deadline = block.timestamp + countdownPeriod;\n                emit ClockReset(deadline);\n            }\n\n        }\n        emit Contribute(msg.sender, msg.value);\n    }\n\n    function contribute() external payable {\n        _contribute(false);\n    }\n\n    function contributeAndCombine() external payable {\n        _contribute(true);\n    }\n\n    function totalContributedByAddress(address contributor) external view returns (uint256) {\n        uint256 total = 0;\n        for (uint256 i = 0; i < contributorsForEachContribution.length; i++) {\n            if (contributorsForEachContribution[i] == contributor) {\n                total += contributionAmounts[i];\n            }\n        }\n        return total;\n    }\n\n    receive() external payable {\n        emit Contribute(msg.sender, msg.value);\n    }\n\n    function getAllContributions() external view returns (address[] memory, uint256[] memory, bool[] memory, uint256[] memory) {\n\n        return (contributorsForEachContribution, contributionAmounts, contributionIsCombined, contributionDatetimes);\n    }\n\n    function withdraw() external onlyBeneficiary {\n        require(materialReleaseConditionMet, \"Material has not been set for a release.\");\n        uint256 balance = address(this).balance;\n        beneficiary.transfer(balance);\n        emit Withdraw(beneficiary, balance);\n    }\n\n}\n"

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

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "evmVersion": "paris"

  }

}}