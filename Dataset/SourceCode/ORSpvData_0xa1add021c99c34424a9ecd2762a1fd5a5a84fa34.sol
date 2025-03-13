{{

  "language": "Solidity",

  "sources": {

    "contracts/interface/IORSpvData.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.17;\n\ninterface IORSpvData {\n    struct InjectionBlocksRoot {\n        uint256 startBlockNumber;\n        bytes32 blocksRoot;\n    }\n\n    event BlockIntervalUpdated(uint64 blockInterval);\n    event InjectOwnerUpdated(address injectOwner);\n    event HistoryBlocksRootSaved(uint256 indexed startBlockNumber, bytes32 blocksRoot, uint256 blockInterval);\n\n    function blockInterval() external view returns (uint64);\n\n    function updateBlockInterval(uint64 blockInterval_) external;\n\n    function saveHistoryBlocksRoots() external;\n\n    function getStartBlockNumber(bytes32 blocksRoot) external view returns (uint);\n\n    function injectOwner() external view returns (address);\n\n    function updateInjectOwner(address injectOwner_) external;\n\n    function injectBlocksRoots(\n        bytes32 blocksRoot0,\n        bytes32 blocksRoot1,\n        InjectionBlocksRoot[] calldata injectionBlocksRoots\n    ) external;\n}\n"

    },

    "contracts/library/HelperLib.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.17;\n\nlibrary HelperLib {\n    function hash(bytes memory data) internal pure returns (bytes32) {\n        return keccak256(data);\n    }\n\n    function includes(uint256[] memory arr, uint256 element) internal pure returns (bool) {\n        for (uint256 i = 0; i < arr.length; ) {\n            if (element == arr[i]) {\n                return true;\n            }\n            unchecked {\n                i++;\n            }\n        }\n        return false;\n    }\n\n    function arrayIncludes(uint256[] memory arr, uint256[] memory elements) internal pure returns (bool) {\n        for (uint256 i = 0; i < elements.length; i++) {\n            bool ic = false;\n            for (uint256 j = 0; j < arr.length; ) {\n                if (elements[i] == arr[j]) {\n                    ic = true;\n                    break;\n                }\n                unchecked {\n                    j++;\n                }\n            }\n\n            if (!ic) return false;\n\n            unchecked {\n                i++;\n            }\n        }\n        return true;\n    }\n\n    function includes(address[] memory arr, address element) internal pure returns (bool) {\n        for (uint256 i = 0; i < arr.length; ) {\n            if (element == arr[i]) {\n                return true;\n            }\n            unchecked {\n                i++;\n            }\n        }\n        return false;\n    }\n\n    function arrayIncludes(address[] memory arr, address[] memory elements) internal pure returns (bool) {\n        for (uint256 i = 0; i < elements.length; i++) {\n            bool ic = false;\n            for (uint256 j = 0; j < arr.length; ) {\n                if (elements[i] == arr[j]) {\n                    ic = true;\n                    break;\n                }\n                unchecked {\n                    j++;\n                }\n            }\n\n            if (!ic) return false;\n\n            unchecked {\n                i++;\n            }\n        }\n        return true;\n    }\n\n    function calculateChallengeIdentNum(\n        uint64 sourceTxTime,\n        uint64 sourceChainId,\n        uint64 sourceTxBlockNum,\n        uint64 sourceTxIndex\n    ) internal pure returns (uint256) {\n        uint256 challengeIdentNum;\n\n        assembly {\n            challengeIdentNum := add(\n                shl(192, sourceTxTime),\n                add(shl(128, sourceChainId), add(shl(64, sourceTxBlockNum), sourceTxIndex))\n            )\n        }\n        return challengeIdentNum;\n    }\n}\n"

    },

    "contracts/ORSpvData.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.17;\n\nimport {HelperLib} from \"./library/HelperLib.sol\";\nimport {IORSpvData} from \"./interface/IORSpvData.sol\";\n\ncontract ORSpvData is IORSpvData {\n    using HelperLib for bytes;\n\n    address public manager;\n\n    uint64 private _blockInterval = 192;\n    address private _injectOwner;\n    mapping(bytes32 => uint) private _blocksRoots; // [start ..._blockInterval... end]'s blocks root => startBlockNumber\n\n    constructor(address manager_, address injectOwner_) {\n        require(manager_ != address(0), \"MZ\");\n        manager = manager_;\n\n        if (injectOwner_ != address(0)) {\n            _injectOwner = injectOwner_;\n            emit InjectOwnerUpdated(injectOwner_);\n        }\n    }\n\n    modifier onlyManager() {\n        require(msg.sender == manager, \"Forbidden: caller is not the manager\");\n        _;\n    }\n\n    function blockInterval() external view returns (uint64) {\n        return _blockInterval;\n    }\n\n    function updateBlockInterval(uint64 blockInterval_) external onlyManager {\n        require(blockInterval_ >= 2 && blockInterval_ <= 256, \"IOF\");\n        require(blockInterval_ % 2 == 0, \"IV\");\n\n        _blockInterval = blockInterval_;\n\n        emit BlockIntervalUpdated(blockInterval_);\n    }\n\n    function _calculateRoot(uint startBlockNumber) internal view returns (bytes32) {\n        uint len = _blockInterval / 2;\n        bytes32 root;\n        assembly {\n            let leaves := mload(0x40)\n            mstore(0x40, add(leaves, mul(len, 0x20)))\n\n            // The lowest layer is calculated separately from other layers to save gas\n            for {\n                let i := 0\n                let leavesPtr := leaves\n            } lt(i, len) {\n                i := add(i, 1)\n            } {\n                let ix2 := mul(i, 2)\n                let data := mload(0x40)\n                mstore(data, blockhash(add(startBlockNumber, ix2)))\n                mstore(add(data, 0x20), blockhash(add(startBlockNumber, add(ix2, 1))))\n\n                mstore(leavesPtr, keccak256(data, 0x40))\n\n                // Release memory\n                data := mload(0x40)\n\n                leavesPtr := add(leavesPtr, 0x20)\n            }\n\n            for {\n\n            } gt(len, 1) {\n                len := add(div(len, 2), mod(len, 2))\n            } {\n                for {\n                    let i := 0\n                    let leavesPtr := leaves\n                } lt(i, len) {\n                    i := add(i, 2)\n                } {\n                    // Default\n                    let ptrL := add(leaves, mul(i, 0x20))\n                    mstore(leavesPtr, mload(ptrL))\n\n                    // When i+1 < len, hash(ptrL connect ptrR)\n                    if lt(add(i, 1), len) {\n                        let ptrR := add(ptrL, 0x20)\n\n                        let data := mload(0x40)\n                        mstore(data, mload(ptrL))\n                        mstore(add(data, 0x20), mload(ptrR))\n\n                        mstore(leavesPtr, keccak256(data, 0x40))\n\n                        // Release memory\n                        data := mload(0x40)\n                    }\n\n                    leavesPtr := add(leavesPtr, 0x20)\n                }\n            }\n\n            root := mload(leaves)\n        }\n\n        return root;\n    }\n\n    function saveHistoryBlocksRoots() external {\n        uint256 currentBlockNumber = block.number;\n        uint256 bi = _blockInterval;\n        uint256 startBlockNumber = currentBlockNumber - 256;\n        uint256 batchLen;\n        unchecked {\n            uint256 m = startBlockNumber % bi;\n            if (m > 0) {\n                startBlockNumber += bi - m;\n            }\n\n            batchLen = (currentBlockNumber - 1 - startBlockNumber) / bi;\n        }\n\n        // Reject when batchLen == 0, save gas\n        require(batchLen > 0, \"IBL\");\n\n        for (uint256 i = 0; i < batchLen; ) {\n            bytes32 root = _calculateRoot(startBlockNumber);\n\n            if (_blocksRoots[root] == 0 && root != bytes32(0)) {\n                _blocksRoots[root] = startBlockNumber;\n                emit HistoryBlocksRootSaved(startBlockNumber, root, bi);\n            }\n\n            unchecked {\n                startBlockNumber += bi;\n                i++;\n            }\n        }\n    }\n\n    function getStartBlockNumber(bytes32 blocksRoot) external view returns (uint) {\n        return _blocksRoots[blocksRoot];\n    }\n\n    function injectOwner() external view returns (address) {\n        return _injectOwner;\n    }\n\n    function updateInjectOwner(address injectOwner_) external onlyManager {\n        _injectOwner = injectOwner_;\n        emit InjectOwnerUpdated(injectOwner_);\n    }\n\n    function injectBlocksRoots(\n        bytes32 blocksRoot0,\n        bytes32 blocksRoot1,\n        InjectionBlocksRoot[] calldata injectionBlocksRoots\n    ) external {\n        require(msg.sender == _injectOwner, \"Forbidden: caller is not the inject owner\");\n\n        uint blockNumber0 = _blocksRoots[blocksRoot0];\n        uint blockNumber1 = _blocksRoots[blocksRoot1];\n\n        require(blockNumber0 < blockNumber1, \"SNLE\");\n\n        // Make sure the blockNumber0 and blockNumber1 at storage\n        require(blockNumber0 != 0, \"SZ\");\n        require(blockNumber1 != 0, \"EZ\"); // This logic may never be false\n\n        uint256 i = 0;\n        uint256 ni = 0;\n        for (; i < injectionBlocksRoots.length; ) {\n            unchecked {\n                ni = i + 1;\n            }\n\n            InjectionBlocksRoot memory ibsr = injectionBlocksRoots[i];\n\n            require(blockNumber0 < ibsr.startBlockNumber, \"IBLE0\");\n            require(blockNumber1 > ibsr.startBlockNumber, \"IBGE1\");\n            require(ibsr.startBlockNumber % _blockInterval == 0, \"IIB\");\n            require(_blocksRoots[ibsr.blocksRoot] == 0, \"BE\");\n\n            _blocksRoots[ibsr.blocksRoot] = ibsr.startBlockNumber;\n            emit HistoryBlocksRootSaved(ibsr.startBlockNumber, ibsr.blocksRoot, _blockInterval);\n\n            i = ni;\n        }\n    }\n}\n"

    }

  },

  "settings": {

    "metadata": {

      "bytecodeHash": "none"

    },

    "optimizer": {

      "enabled": true,

      "runs": 10

    },

    "viaIR": true,

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