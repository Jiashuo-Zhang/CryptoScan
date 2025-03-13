{{

  "language": "Solidity",

  "sources": {

    "lib/ds-pause/src/pause.sol": {

      "content": "// Copyright (C) 2019 David Terry <me@xwvvvvwx.com>\n//\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n// You should have received a copy of the GNU Affero General Public License\n// along with this program.  If not, see <https://www.gnu.org/licenses/>.\n\npragma solidity 0.6.7;\n\nimport {DSAuth, DSAuthority} from \"ds-auth/auth.sol\";\n\ncontract DSPause is DSAuth {\n    // --- Admin ---\n    modifier isDelayed { require(msg.sender == address(proxy), \"ds-pause-undelayed-call\"); _; }\n\n    function setOwner(address owner_) override public isDelayed {\n        owner = owner_;\n        emit LogSetOwner(owner);\n    }\n    function setAuthority(DSAuthority authority_) override public isDelayed {\n        authority = authority_;\n        emit LogSetAuthority(address(authority));\n    }\n    function setDelay(uint delay_) public isDelayed {\n        require(delay_ <= MAX_DELAY, \"ds-pause-delay-not-within-bounds\");\n        delay = delay_;\n        emit SetDelay(delay_);\n    }\n\n    // --- Math ---\n    function addition(uint x, uint y) internal pure returns (uint z) {\n        z = x + y;\n        require(z >= x, \"ds-pause-add-overflow\");\n    }\n    function subtract(uint x, uint y) internal pure returns (uint z) {\n        require((z = x - y) <= x, \"ds-pause-sub-underflow\");\n    }\n\n    // --- Data ---\n    mapping (bytes32 => bool)  public scheduledTransactions;\n    mapping (bytes32 => bool)  public scheduledTransactionsDataHashes;\n    DSPauseProxy               public proxy;\n    uint                       public delay;\n    uint                       public currentlyScheduledTransactions;\n\n    uint256                    public constant EXEC_TIME                = 3 days;\n    uint256                    public constant maxScheduledTransactions = 10;\n    uint256                    public constant MAX_DELAY                = 28 days;\n    bytes32                    public constant DS_PAUSE_TYPE            = bytes32(\"BASIC\");\n\n    // --- Events ---\n    event SetDelay(uint256 delay);\n    event ScheduleTransaction(address sender, address usr, bytes32 codeHash, bytes parameters, uint earliestExecutionTime);\n    event AbandonTransaction(address sender, address usr, bytes32 codeHash, bytes parameters, uint earliestExecutionTime);\n    event ExecuteTransaction(address sender, address usr, bytes32 codeHash, bytes parameters, uint earliestExecutionTime);\n    event AttachTransactionDescription(address sender, address usr, bytes32 codeHash, bytes parameters, uint earliestExecutionTime, string description);\n\n    // --- Init ---\n    constructor(uint delay_, address owner_, DSAuthority authority_) public {\n        require(delay_ <= MAX_DELAY, \"ds-pause-delay-not-within-bounds\");\n        delay = delay_;\n        owner = owner_;\n        authority = authority_;\n        proxy = new DSPauseProxy();\n    }\n\n    // --- Util ---\n    function getTransactionDataHash(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime)\n        public pure\n        returns (bytes32)\n    {\n        return keccak256(abi.encode(usr, codeHash, parameters, earliestExecutionTime));\n    }\n    function getTransactionDataHash(address usr, bytes32 codeHash, bytes memory parameters)\n        public pure\n        returns (bytes32)\n    {\n        return keccak256(abi.encode(usr, codeHash, parameters));\n    }\n\n    function getExtCodeHash(address usr)\n        internal view\n        returns (bytes32 codeHash)\n    {\n        assembly { codeHash := extcodehash(usr) }\n    }\n\n    // --- Operations ---\n    function scheduleTransaction(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime)\n        public auth\n    {\n        schedule(usr, codeHash, parameters, earliestExecutionTime);\n    }\n    function scheduleTransaction(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime, string memory description)\n        public auth\n    {\n        schedule(usr, codeHash, parameters, earliestExecutionTime);\n        emit AttachTransactionDescription(msg.sender, usr, codeHash, parameters, earliestExecutionTime, description);\n    }\n    function schedule(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime) internal {\n        require(!scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)], \"ds-pause-already-scheduled\");\n        require(subtract(earliestExecutionTime, now) <= MAX_DELAY, \"ds-pause-delay-not-within-bounds\");\n        require(earliestExecutionTime >= addition(now, delay), \"ds-pause-delay-not-respected\");\n        require(currentlyScheduledTransactions < maxScheduledTransactions, \"ds-pause-too-many-scheduled\");\n        bytes32 dataHash = getTransactionDataHash(usr, codeHash, parameters);\n        require(!scheduledTransactionsDataHashes[dataHash], \"ds-pause-cannot-schedule-same-tx-twice\");\n        currentlyScheduledTransactions = addition(currentlyScheduledTransactions, 1);\n        scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)] = true;\n        scheduledTransactionsDataHashes[dataHash] = true;\n        emit ScheduleTransaction(msg.sender, usr, codeHash, parameters, earliestExecutionTime);\n    }\n    function attachTransactionDescription(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime, string memory description)\n        public auth\n    {\n        require(scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)], \"ds-pause-unplotted-plan\");\n        emit AttachTransactionDescription(msg.sender, usr, codeHash, parameters, earliestExecutionTime, description);\n    }\n    function abandonTransaction(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime)\n        public auth\n    {\n        require(scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)], \"ds-pause-unplotted-plan\");\n        scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)] = false;\n        scheduledTransactionsDataHashes[getTransactionDataHash(usr, codeHash, parameters)] = false;\n        currentlyScheduledTransactions = subtract(currentlyScheduledTransactions, 1);\n        emit AbandonTransaction(msg.sender, usr, codeHash, parameters, earliestExecutionTime);\n    }\n    function executeTransaction(address usr, bytes32 codeHash, bytes memory parameters, uint earliestExecutionTime)\n        public\n        returns (bytes memory out)\n    {\n        require(scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)], \"ds-pause-unplotted-plan\");\n        require(getExtCodeHash(usr) == codeHash, \"ds-pause-wrong-codehash\");\n        require(now >= earliestExecutionTime, \"ds-pause-premature-exec\");\n        require(now < addition(earliestExecutionTime, EXEC_TIME), \"ds-pause-expired-tx\");\n\n        scheduledTransactions[getTransactionDataHash(usr, codeHash, parameters, earliestExecutionTime)] = false;\n        scheduledTransactionsDataHashes[getTransactionDataHash(usr, codeHash, parameters)] = false;\n        currentlyScheduledTransactions = subtract(currentlyScheduledTransactions, 1);\n\n        emit ExecuteTransaction(msg.sender, usr, codeHash, parameters, earliestExecutionTime);\n\n        out = proxy.executeTransaction(usr, parameters);\n        require(proxy.owner() == address(this), \"ds-pause-illegal-storage-change\");\n    }\n}\n\n// scheduled txs are executed in an isolated storage context to protect the pause from\n// malicious storage modification during plan execution\ncontract DSPauseProxy {\n    address public owner;\n    modifier isAuthorized { require(msg.sender == owner, \"ds-pause-proxy-unauthorized\"); _; }\n    constructor() public { owner = msg.sender; }\n\n    function executeTransaction(address usr, bytes memory parameters)\n        public isAuthorized\n        returns (bytes memory out)\n    {\n        bool ok;\n        (ok, out) = usr.delegatecall(parameters);\n        require(ok, \"ds-pause-delegatecall-error\");\n    }\n}\n"

    },

    "lib/ds-proxy/lib/ds-auth/src/auth.sol": {

      "content": "// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see <http://www.gnu.org/licenses/>.\n\npragma solidity >=0.6.7;\n\ninterface DSAuthority {\n    function canCall(\n        address src, address dst, bytes4 sig\n    ) external view returns (bool);\n}\n\nabstract contract DSAuthEvents {\n    event LogSetAuthority (address indexed authority);\n    event LogSetOwner     (address indexed owner);\n}\n\ncontract DSAuth is DSAuthEvents {\n    DSAuthority  public  authority;\n    address      public  owner;\n\n    constructor() public {\n        owner = msg.sender;\n        emit LogSetOwner(msg.sender);\n    }\n\n    function setOwner(address owner_)\n        virtual\n        public\n        auth\n    {\n        owner = owner_;\n        emit LogSetOwner(owner);\n    }\n\n    function setAuthority(DSAuthority authority_)\n        virtual\n        public\n        auth\n    {\n        authority = authority_;\n        emit LogSetAuthority(address(authority));\n    }\n\n    modifier auth {\n        require(isAuthorized(msg.sender, msg.sig), \"ds-auth-unauthorized\");\n        _;\n    }\n\n    function isAuthorized(address src, bytes4 sig) virtual internal view returns (bool) {\n        if (src == address(this)) {\n            return true;\n        } else if (src == owner) {\n            return true;\n        } else if (authority == DSAuthority(0)) {\n            return false;\n        } else {\n            return authority.canCall(src, address(this), sig);\n        }\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "ds-auth/=lib/ds-proxy/lib/ds-auth/src/",

      "ds-exec/=lib/ds-pause/lib/ds-spell/lib/ds-exec/src/",

      "ds-guard/=lib/geb-deploy/lib/ds-guard/src/",

      "ds-math/=lib/esm/lib/ds-token/lib/ds-math/src/",

      "ds-note/=lib/ds-proxy/lib/ds-note/src/",

      "ds-pause/=lib/ds-pause/src/",

      "ds-proxy/=lib/ds-proxy/src/",

      "ds-roles/=lib/ds-pause/lib/ds-vote-quorum/lib/ds-roles/src/",

      "ds-spell/=lib/ds-pause/lib/ds-spell/src/",

      "ds-stop/=lib/geb-fsm/lib/ds-stop/src/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "ds-thing/=lib/ds-value/lib/ds-thing/src/",

      "ds-token/=lib/esm/lib/ds-token/src/",

      "ds-value/=lib/ds-value/src/",

      "ds-vote-quorum/=lib/ds-pause/lib/ds-vote-quorum/src/",

      "ds-weth/=lib/ds-weth/",

      "erc20/=lib/ds-weth/lib/erc20/src/",

      "esm/=lib/esm/src/",

      "forge-std/=lib/forge-std/src/",

      "geb-basic-multisig/=lib/ds-pause/lib/geb-basic-multisig/src/",

      "geb-chainlink-median/=lib/geb-chainlink-median/src/",

      "geb-debt-popper-rewards/=lib/geb-debt-popper-rewards/src/",

      "geb-deploy/=lib/geb-deploy/src/",

      "geb-esm-threshold-setter/=lib/geb-esm-threshold-setter/src/",

      "geb-fsm/=lib/geb-fsm/src/",

      "geb-incentives/=lib/geb-proxy-actions/lib/geb-incentives/src/",

      "geb-lender-first-resort/=lib/geb-lender-first-resort/src/",

      "geb-pit/=lib/geb-pit/src/",

      "geb-protocol-token-authority/=lib/geb-protocol-token-authority/src/",

      "geb-proxy-actions/=lib/geb-proxy-actions/src/",

      "geb-proxy-registry/=lib/geb-proxy-registry/src/",

      "geb-rrfm-calculators/=lib/geb-rrfm-calculators/src/",

      "geb-rrfm-rate-setter/=lib/geb-rrfm-rate-setter/src/",

      "geb-safe-manager/=lib/geb-safe-manager/src/",

      "geb-safe-saviours/=lib/geb-proxy-actions/lib/geb-safe-saviours/src/",

      "geb-treasury-reimbursement/=lib/geb-debt-popper-rewards/lib/geb-treasury-reimbursement/src/",

      "geb-uniswap-median/=lib/geb-uniswap-median/src/",

      "geb/=lib/geb/src/",

      "mgl-debt-minter-rewards/=lib/mgl-debt-minter-rewards/",

      "mgl-emitter/=lib/mgl-emitter/src/",

      "multicall/=lib/multicall/src/"

    ],

    "optimizer": {

      "enabled": false,

      "runs": 200

    },

    "metadata": {

      "bytecodeHash": "ipfs"

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

    "evmVersion": "istanbul",

    "libraries": {}

  }

}}