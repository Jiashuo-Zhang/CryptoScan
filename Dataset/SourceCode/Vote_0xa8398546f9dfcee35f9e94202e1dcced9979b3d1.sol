{{

  "language": "Solidity",

  "sources": {

    "contracts/tokenomics/Vote.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.8.20;\n\nimport \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\nimport \"../../interfaces/tokenomics/ITORUSLockerV2.sol\";\n\ncontract Vote is Ownable, ReentrancyGuard {\n    address public voteLocker;\n\n    uint256 internal constant DURATION = 7 days;\n    uint256 public constant MAX_VOTE_DELAY = 7 days;\n    uint256 internal constant WEEK = 86400 * 7; // allows minting once per week (reset every Thursday 00:00 UTC)\n    uint256 public active_period;\n    uint256 public VOTE_DELAY; // delay between votes in seconds\n\n    mapping(address => mapping(address => uint256)) public votes; // user => pool => votes\n    mapping(address => address[]) public poolVote; // user => pool\n    mapping(uint256 => mapping(address => uint256)) internal weightsPerEpoch; // timestamp => pool => weights\n    mapping(uint256 => uint256) internal totalWeightsPerEpoch; // timestamp => total weights\n    mapping(address => uint256) public lastVoted; // user => timestamp of last vote\n    mapping(address => bool) public isAlive; // crv pool => boolean [is pool alive for vote?]\n    mapping(address => bool) public poolAdded; // crv pool => existance\n    address[] internal pools;\n\n    event Voted(address indexed voter, uint256 weight);\n\n    constructor(address _voteLocker) public {\n        voteLocker = _voteLocker;\n    }\n\n    // @notice Vote for pools\n    // @param _poolVote array of LP addresses to vote\n    // @param _weights  array of weights for each LPs\n    function vote(address[] calldata _poolVote, uint256[] calldata _weights) external nonReentrant {\n        _voteDelay(msg.sender);\n        _vote(msg.sender, _poolVote, _weights);\n        lastVoted[msg.sender] = _epochTimestamp() + 1;\n    }\n\n    function _vote(address _user, address[] memory _poolVote, uint256[] memory _weights) internal {\n        _reset(_user);\n        uint256 _poolCnt = _poolVote.length;\n        uint256 _weight = ITORUSLockerV2(voteLocker).balanceOf(_user);\n        uint256 _totalVoteWeight = 0;\n        uint256 _totalWeight = 0;\n        uint256 _usedWeight = 0;\n        uint256 _time = _epochTimestamp();\n        active_period = _time;\n        \n        for (uint256 i = 0; i < _poolCnt; i++) {\n            if (isAlive[_poolVote[i]]) _totalVoteWeight += _weights[i];\n        }\n\n        for (uint256 i = 0; i < _poolCnt; i++) {\n            address _pool = _poolVote[i];\n\n            if (isAlive[_pool]) {\n                uint256 _poolWeight = _weights[i] * _weight / _totalVoteWeight;\n\n                require(votes[_user][_pool] == 0);\n                require(_poolWeight != 0);\n\n                poolVote[_user].push(_pool);\n                weightsPerEpoch[_time][_pool] += _poolWeight;\n\n                votes[_user][_pool] += _poolWeight;\n\n                _usedWeight += _poolWeight;\n                _totalWeight += _poolWeight;\n                emit Voted(msg.sender, _poolWeight);\n            }\n        }\n        totalWeightsPerEpoch[_time] += _totalWeight;\n    }\n\n    function _reset(address _user) internal {\n        address[] storage _poolVote = poolVote[_user];\n        uint256 _poolVoteCnt = _poolVote.length;\n        uint256 _totalWeight = 0;\n        uint256 _time = _epochTimestamp();\n\n        for (uint256 i; i < _poolVoteCnt; i++) {\n            address _pool = _poolVote[i];\n            uint256 _votes = votes[_user][_pool];\n\n            if (_votes != 0) {\n                if (lastVoted[_user] > _time) {\n                    weightsPerEpoch[_time][_pool] -= _votes;\n                }\n                votes[_user][_pool] = 0;\n\n                if (isAlive[_pool]) {\n                    _totalWeight += _votes;\n                }\n            }\n        }\n\n        if (lastVoted[_user] < _time) {\n            _totalWeight = 0;\n        }\n        totalWeightsPerEpoch[_time] -= _totalWeight;\n    }\n\n    /// @notice check if user can vote\n    function _voteDelay(address _user) internal view {\n        require(block.timestamp > lastVoted[_user] + VOTE_DELAY, \"ERR: VOTE_DELAY\");\n    }\n\n    function addPool(address _pool) external onlyOwner {\n        require(!poolAdded[_pool], \"Already added\");\n        pools.push(_pool);\n        poolAdded[_pool] = true;\n    }\n\n    function _epochTimestamp() internal view returns (uint256) {\n        return block.timestamp / 1 weeks * 1 weeks;\n    }\n\n    function setPoolState(address _pool, bool _state) external onlyOwner {\n        if (poolAdded[_pool]) {\n            isAlive[_pool] = _state;\n        }\n    }\n\n    function getPoolVote(address _user) external view returns (address[] memory) {\n        return poolVote[_user];\n    }\n\n    function getPools() external view returns (address[] memory) {\n        return pools;\n    }\n\n    function getPoolWeightPerEpoch(uint256 _timestamp, address _pool) external view returns (uint256) {\n        return weightsPerEpoch[_timestamp][_pool];\n    }\n}\n"

    },

    "node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be _NOT_ENTERED\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == _ENTERED;\n    }\n}\n"

    },

    "node_modules/@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "interfaces/tokenomics/ITORUSLockerV2.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.8.20;\n\nimport \"../../libraries/MerkleProof.sol\";\n\ninterface ITORUSLockerV2 {\n    event Locked(address indexed account, uint256 amount, uint256 unlockTime, bool relocked);\n    event UnlockExecuted(address indexed account, uint256 amount);\n    event Relocked(address indexed account, uint256 amount);\n    event KickExecuted(address indexed account, address indexed kicker, uint256 amount);\n    event FeesReceived(address indexed sender, uint256 crvAmount, uint256 cvxAmount);\n    event FeesClaimed(address indexed claimer, uint256 crvAmount, uint256 cvxAmount);\n    event AirdropBoostClaimed(address indexed claimer, uint256 amount);\n    event Shutdown();\n    event TokenRecovered(address indexed token);\n\n    struct VoteLock {\n        uint256 amount;\n        uint64 unlockTime;\n        uint128 boost;\n        uint64 id;\n    }\n\n    function lock(uint256 amount, uint64 lockTime) external;\n\n    function lock(\n        uint256 amount,\n        uint64 lockTime,\n        bool relock\n    ) external;\n\n    function lockFor(\n        uint256 amount,\n        uint64 lockTime,\n        bool relock,\n        address account\n    ) external;\n\n    function relock(uint64 lockId, uint64 lockTime) external;\n\n    function relock(uint64 lockTime) external;\n\n    function relockMultiple(uint64[] calldata lockIds, uint64 lockTime) external;\n\n    function totalBoosted() external view returns (uint256);\n\n    function shutDown() external;\n\n    function recoverToken(address token) external;\n\n    function executeAvailableUnlocks() external returns (uint256);\n\n    function executeAvailableUnlocksFor(address dst) external returns (uint256);\n\n    function executeUnlocks(address dst, uint64[] calldata lockIds) external returns (uint256);\n\n    // This will need to include the boosts etc.\n    function balanceOf(address user) external view returns (uint256);\n\n    function unlockableBalance(address user) external view returns (uint256);\n\n    function unlockableBalanceBoosted(address user) external view returns (uint256);\n\n    function kick(address user, uint64 lockId) external;\n\n    function receiveFees(uint256 amountCrv, uint256 amountCvx) external;\n\n    function claimableFees(address account)\n        external\n        view\n        returns (uint256 claimableCrv, uint256 claimableCvx);\n\n    function claimFees() external returns (uint256 crvAmount, uint256 cvxAmount);\n\n    function computeBoost(uint128 lockTime) external view returns (uint128);\n\n    function claimedAirdrop(address account) external view returns (bool);\n\n    function totalVoteBoost(address account) external view returns (uint256);\n\n    function totalRewardsBoost(address account) external view returns (uint256);\n\n    function userLocks(address account) external view returns (VoteLock[] memory);\n}\n"

    },

    "node_modules/@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "libraries/MerkleProof.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.8.20;\n\nlibrary MerkleProof {\n    struct Proof {\n        uint16 nodeIndex;\n        bytes32[] hashes;\n    }\n\n    function isValid(\n        Proof memory proof,\n        bytes32 node,\n        bytes32 merkleTorus\n    ) internal pure returns (bool) {\n        uint256 length = proof.hashes.length;\n        uint16 nodeIndex = proof.nodeIndex;\n        for (uint256 i = 0; i < length; i++) {\n            if (nodeIndex % 2 == 0) {\n                node = keccak256(abi.encodePacked(node, proof.hashes[i]));\n            } else {\n                node = keccak256(abi.encodePacked(proof.hashes[i], node));\n            }\n            nodeIndex /= 2;\n        }\n\n        return node == merkleTorus;\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "@chainlink/contracts/=node_modules/@chainlink/contracts/src/v0.8/",

      "@openzeppelin/=node_modules/@openzeppelin/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "forge-std/=lib/forge-std/src/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "bytecodeHash": "ipfs",

      "appendCBOR": true

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

    "evmVersion": "shanghai",

    "libraries": {}

  }

}}