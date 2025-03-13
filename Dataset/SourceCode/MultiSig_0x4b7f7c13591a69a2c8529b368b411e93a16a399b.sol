{{

  "language": "Solidity",

  "settings": {

    "evmVersion": "paris",

    "libraries": {},

    "metadata": {

      "bytecodeHash": "ipfs",

      "useLiteralContent": true

    },

    "optimizer": {

      "enabled": true,

      "runs": 1000

    },

    "remappings": [],

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

  },

  "sources": {

    "contracts/lib/utils/Multisig.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\n// https://github.com/paxosglobal/simple-multisig\n\npragma solidity 0.8.18;\n\ncontract MultiSig {\n\n  // EIP712 Precomputed hashes:\n  // keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\")\n  bytes32 private constant EIP712DOMAINTYPE_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;\n\n  // keccak256(\"MultiSig\")\n  bytes32 private constant NAME_HASH = 0xd90d81238fec68b58412fea0ed72a6621ecd31c74022809053834bb75fa1820f;\n\n  // keccak256(\"1\")\n  bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;\n\n  // keccak256(\"MultiSigTransaction(address destination,uint256 value,bytes data,uint256 nonce,address executor,uint256 gasLimit)\")\n  bytes32 private constant TXTYPE_HASH = 0x3ee892349ae4bbe61dce18f95115b5dc02daf49204cc602458cd4c1f540d56d7;\n\n  uint public nonce;                 // mutable state\n  uint public threshold;             // mutable state\n  mapping (address => bool) private isOwner; // mutable state\n  address[] public ownersArr;        // mutable state\n\n  // solhint-disable-next-line var-name-mixedcase\n  bytes32 private immutable DOMAIN_SEPARATOR;          // hash for EIP712, computed from contract address\n\n  function owners() external view returns (address[] memory) {\n    return ownersArr;\n  }\n\n  // Note that owners_ must be strictly increasing, in order to prevent duplicates\n  function setOwners_(uint threshold_, address[] memory owners_) private {\n    require(owners_.length <= 20 && threshold_ <= owners_.length && threshold_ > 0, \"Invalid threshold\");\n\n    // remove old owners from map\n    for (uint i = 0; i < ownersArr.length; i++) {\n      isOwner[ownersArr[i]] = false;\n    }\n\n    // add new owners to map\n    address lastAdd = address(0);\n    for (uint i = 0; i < owners_.length; i++) {\n      require(owners_[i] > lastAdd, \"Addresses added must be sequential\");\n      isOwner[owners_[i]] = true;\n      lastAdd = owners_[i];\n    }\n\n    // set owners array and threshold\n    ownersArr = owners_;\n    threshold = threshold_;\n  }\n\n  constructor(uint threshold_, address[] memory owners_) {\n    setOwners_(threshold_, owners_);\n\n    DOMAIN_SEPARATOR = keccak256(abi.encode(EIP712DOMAINTYPE_HASH,\n                                            NAME_HASH,\n                                            VERSION_HASH,\n                                            block.chainid,\n                                            this));\n  }\n\n  // Requires a quorum of owners to call from this contract using execute\n  function setOwners(uint threshold_, address[] memory owners_) external {\n    require(msg.sender == address(this), \"Can only be called by multisig\");\n    setOwners_(threshold_, owners_);\n  }\n\n  // Note that address recovered from signatures must be strictly increasing, in order to prevent duplicates\n  function execute(\n      uint8[] memory sigV,\n      bytes32[] memory sigR,\n      bytes32[] memory sigS,\n      address destination,\n      uint256 value,\n      bytes memory data,\n      address executor,\n      uint256 gasLimit\n  ) external {\n    require(sigR.length == threshold, \"Threshold requirement not met\");\n    require(sigR.length == sigS.length && sigR.length == sigV.length, \"Sig length mismatch\");\n    require(executor == msg.sender || executor == address(0), \"Invalid executor address\");\n\n    // EIP712 scheme: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md\n    bytes32 txInputHash = keccak256(abi.encode(TXTYPE_HASH, destination, value, keccak256(data), nonce, executor, gasLimit));\n    bytes32 totalHash = keccak256(abi.encodePacked(\"\\x19\\x01\", DOMAIN_SEPARATOR, txInputHash));\n\n    address lastAdd = address(0); // cannot have address(0) as an owner\n    for (uint i = 0; i < threshold; i++) {\n      address recovered = ecrecover(totalHash, sigV[i], sigR[i], sigS[i]);\n      require(recovered > lastAdd && isOwner[recovered], \"Invalid recovered address\");\n      lastAdd = recovered;\n    }\n\n    // If we make it here all signatures are accounted for.\n    nonce = nonce + 1;\n    bool success = false;\n    // solhint-disable-next-line avoid-low-level-calls\n    (success,) = destination.call{value: value, gas: gasLimit}(data);\n    // https://ethereum.stackexchange.com/a/86983/75264\n    // https://ethereum.stackexchange.com/a/111143/75264\n    if (success == false) {\n      // solhint-disable-next-line no-inline-assembly\n      assembly {\n        let ptr := mload(0x40)\n        let size := returndatasize()\n        returndatacopy(ptr, 0, size)\n        revert(ptr, size)\n      }\n    }\n  }\n\n  receive() external payable {}\n}"

    }

  }

}}