{{

  "language": "Solidity",

  "sources": {

    "contracts/EthClaim.sol": {

      "content": "//SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./libraries/MerkleProof.sol\";\nimport \"./libraries/Math.sol\";\n\ncontract EthClaim {\n    using Math for uint256;\n    using MerkleProof for bytes32;\n\n    address public owner;\n    bytes32 public merkleRoot;\n    uint256 public claimEnds;\n    bool public isActive;\n\n    uint256 private _totalBalance;\n    uint256 private _totalAmount;\n    \n    mapping(address => bool) private _claims;\n\n    constructor(bytes32 _merkleRoot, uint256 totalAmount) payable {\n        merkleRoot = _merkleRoot;\n        owner = msg.sender;\n        claimEnds = block.timestamp + (365 * 86400);\n        _totalAmount = totalAmount;\n    }\n\n    receive() external payable {}\n    fallback() external payable {}\n\n    function setActive() public {\n        require(msg.sender == owner, \"Not owner\");\n        require(!isActive, \"Contract already active\");\n\n        _totalBalance = address(this).balance;\n    }\n\n    function checkAmount(uint256 amount) public view returns (uint256) {\n        uint256 percentOfTotal = amount.mulDivDown(1e18, _totalAmount);\n        uint256 amountToSend = _totalBalance.mulDivDown(percentOfTotal, 1e18);\n\n        return amountToSend;\n    }\n\n    function claim(bytes32[] calldata proof, uint256 amount) external returns (uint256)\n    {\n        require(checkProof(msg.sender, proof, amount));\n        require(block.timestamp < claimEnds, \"Claiming is over\");\n\n        uint256 amountToSend = checkAmount(amount);\n\n        require(amountToSend < address(this).balance, \"Amount exceeds contract balance\");\n        require(amountToSend > 0, \"Amount cannot be 0\");\n\n        (bool sent, ) = payable(msg.sender).call{value: amountToSend}(\"\");\n\n        require(sent, \"Failed to send ETH\");\n\n        _claims[msg.sender] = true;\n\n        return amountToSend;\n    }\n\n    function checkProof(address account, bytes32[] calldata proof, uint256 amount) public view returns (bool) {\n        require(!checkClaimed(account), \"Already claimed\");\n\n        bytes32 leaf = keccak256(abi.encode(account, amount));\n\n        require(MerkleProof.verify(proof, merkleRoot, leaf), \"Proof failed\");\n\n        return true;\n    }\n\n    function checkClaimed(address account) public view returns (bool)\n    {\n        return _claims[account];\n    }\n\n    function withdrawLeftover() public\n    {\n        require(msg.sender == owner, \"Not owner\");\n        require(block.timestamp > claimEnds, \"Claiming not done yet\");\n\n        isActive = false;\n\n        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(\"\");\n        \n        require(sent, \"Failed to send ETH\");\n    }\n}\n"

    },

    "contracts/libraries/Math.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\n\npragma solidity >=0.8.0;\n\nlibrary Math {\n    /*//////////////////////////////////////////////////////////////\n                    SIMPLIFIED FIXED POINT OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.\n\n    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {\n        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.\n    }\n\n    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {\n        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.\n    }\n\n    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {\n        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.\n    }\n\n    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {\n        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                    LOW LEVEL FIXED POINT OPERATIONS\n    //////////////////////////////////////////////////////////////*/\n\n    function mulDivDown(\n        uint256 x,\n        uint256 y,\n        uint256 denominator\n    ) internal pure returns (uint256 z) {\n        assembly {\n            // Store x * y in z for now.\n            z := mul(x, y)\n\n            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))\n            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {\n                revert(0, 0)\n            }\n\n            // Divide z by the denominator.\n            z := div(z, denominator)\n        }\n    }\n\n    function mulDivUp(\n        uint256 x,\n        uint256 y,\n        uint256 denominator\n    ) internal pure returns (uint256 z) {\n        assembly {\n            // Store x * y in z for now.\n            z := mul(x, y)\n\n            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))\n            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {\n                revert(0, 0)\n            }\n\n            // First, divide z - 1 by the denominator and add 1.\n            // We allow z - 1 to underflow if z is 0, because we multiply the\n            // end result by 0 if z is zero, ensuring we return 0 if z is zero.\n            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))\n        }\n    }\n}"

    },

    "contracts/libraries/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle Trees proofs.\n *\n * The proofs can be generated using the JavaScript library\n * https://github.com/miguelmota/merkletreejs[merkletreejs].\n * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.\n *\n * See `test/utils/cryptography/MerkleProof.test.js` for some examples.\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(\n        bytes32[] memory proof,\n        bytes32 root,\n        bytes32 leaf\n    ) internal pure returns (bool) {\n        return processProof(proof, leaf) == root;\n    }\n\n    /**\n     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up\n     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt\n     * hash matches the root of the tree. When processing the proof, the pairs\n     * of leafs & pre-images are assumed to be sorted.\n     *\n     * _Available since v4.4._\n     */\n    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {\n        bytes32 computedHash = leaf;\n        for (uint256 i = 0; i < proof.length; i++) {\n            bytes32 proofElement = proof[i];\n            if (computedHash <= proofElement) {\n                // Hash(current computed hash + current element of the proof)\n                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\n            } else {\n                // Hash(current element of the proof + current computed hash)\n                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\n            }\n        }\n        return computedHash;\n    }\n}"

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

    },

    "libraries": {}

  }

}}