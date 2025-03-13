{{

  "language": "Solidity",

  "sources": {

    "contracts/MutariuumGiveaways.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\nimport \"../interfaces/IERC721.sol\";\nimport \"../libraries/ECDSA.sol\";\nimport \"./Roles.sol\";\n\ncontract MutariuumGiveaways is Roles {\n    error ClaimTimeout();\n\n    constructor() {\n        _setRole(msg.sender, 0, true);\n    }\n\n    function claim(\n        address nft,\n        address sender,\n        uint256[] calldata tokenIds,\n        uint256 blockNumber,\n        bytes calldata signature\n    ) external {\n        _verifySignature(nft, sender, tokenIds, blockNumber, signature);\n        IERC721 collection = IERC721(nft);\n        uint256 tokensLength = tokenIds.length;\n        for (uint256 i = 0; i < tokensLength;) {\n            collection.safeTransferFrom(sender, msg.sender, tokenIds[i]);\n            unchecked { ++i; }\n        }\n    }\n\n    function _verifySignature(\n        address nft,\n        address sender,\n        uint256[] calldata tokenIds,\n        uint256 blockNumber,\n        bytes calldata signature\n    ) internal view {\n        unchecked {\n            if (block.number > blockNumber + 10) {\n                revert ClaimTimeout();\n            }\n        }\n        address signer = _getSigner(\n            keccak256(\n                abi.encode(\n                    msg.sender, nft, sender, tokenIds, blockNumber\n                )\n            ), signature\n        );\n        if (!_hasRole(signer, 1)) {\n            revert ECDSA.InvalidSignature();\n        }\n    }\n\n    function _getSigner(bytes32 message, bytes calldata signature) internal pure returns(address) {\n        bytes32 hash = keccak256(\n            abi.encodePacked(\n                \"\\x19Ethereum Signed Message:\\n32\",\n                message\n            )\n        );\n        return ECDSA.recover(hash, signature);\n    }\n}\n"

    },

    "contracts/Roles.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.19;\n\nimport \"../libraries/Bits.sol\";\n\ncontract Roles {\n    using Bits for bytes32;\n\n    error MissingRole(address user, uint256 role);\n\n    event RoleUpdated(address indexed user, uint256 indexed role, bool indexed status);\n\n    /**\n     * @dev There is a maximum of 256 roles: each bit says if the role is on or off\n     */\n    mapping(address => bytes32) private _addressRoles;\n\n    function _hasRole(address user, uint8 role) internal view returns(bool) {\n        bytes32 roles = _addressRoles[user];\n        return roles.getBool(role);\n    }\n\n    function _checkRole(address user, uint8 role) internal virtual view {\n        if (user == address(this)) return;\n        bytes32 roles = _addressRoles[user];\n        bool allowed = roles.getBool(role);\n        if (!allowed) {\n            revert MissingRole(user, role);\n        }\n    }\n\n    function _setRole(address user, uint8 role, bool status) internal virtual {\n        _addressRoles[user] = _addressRoles[user].setBit(role, status);\n        emit RoleUpdated(user, role, status);\n    }\n\n    function setRole(address user, uint8 role, bool status) external virtual {\n        _checkRole(msg.sender, 0);\n        _setRole(user, role, status);\n    }\n\n    function getRoles(address user) external view returns(bytes32) {\n        return _addressRoles[user];\n    }\n}\n"

    },

    "interfaces/IERC721.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\ninterface IERC721 {\n  function safeTransferFrom(address from, address to, uint256 tokenId) external;\n}\n"

    },

    "libraries/Bits.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\nlibrary Bits {\n    /**\n     * @dev unpack bit [offset] (bool)\n     */\n    function getBool(bytes32 p, uint8 offset) internal pure returns (bool r) {\n        assembly {\n            r := and(shr(offset, p), 1)\n        }\n    }\n\n    /**\n     * @dev set bit [{offset}] to {value}\n     */\n    function setBit(\n        bytes32 p,\n        uint8 offset,\n        bool value\n    ) internal pure returns (bytes32 np) {\n        assembly {\n            np := or(\n                and(\n                    p,\n                    xor(\n                        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,\n                        shl(offset, 1)\n                    )\n                ),\n                shl(offset, value)\n            )\n        }\n    }\n}\n"

    },

    "libraries/ECDSA.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.19;\n\nlibrary ECDSA {\n  error InvalidSignature();\n\n  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\n    if (signature.length != 65) {\n      revert InvalidSignature();\n    }\n    bytes32 r;\n    bytes32 s;\n    uint8 v;\n    assembly {\n      r := mload(add(signature, 0x20))\n      s := mload(add(signature, 0x40))\n      v := byte(0, mload(add(signature, 0x60)))\n    }\n    return tryRecover(hash, v, r, s);\n  }\n\n  function tryRecover(\n    bytes32 hash,\n    uint8 v,\n    bytes32 r,\n    bytes32 s\n  ) internal pure returns (address) {\n    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\n      revert InvalidSignature();\n    }\n    return ecrecover(hash, v, r, s);\n  }\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 1

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