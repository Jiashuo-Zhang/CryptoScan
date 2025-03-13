{{

  "language": "Solidity",

  "sources": {

    "src/contracts/CollectionFactory.sol": {

      "content": "// SPDX-License-Identifier: BUSL-1.1\n// omnisea-contracts v0.1\n\npragma solidity ^0.8.7;\n\nimport \"../interfaces/ICollectionsRepository.sol\";\nimport \"../interfaces/IOmniApp.sol\";\nimport \"../interfaces/IOmnichainRouter.sol\";\nimport { CreateParams } from \"../structs/erc721/ERC721Structs.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\n/**\n * @title CollectionFactory\n * @author Omnisea\n * @custom:version 1.0\n * @notice CollectionFactory is ERC721 collection creation service.\n *         Contract is responsible for validating and executing the function that creates ERC721 collection.\n *         Enables delegation of cross-chain collection creation via Omnichain Router which abstracts underlying cross-chain messaging.\n *         messaging protocols such as LayerZero and Axelar Network.\n *         With the TokenFactory contract, it is designed to avoid burn & mint mechanism to keep NFT's non-fungibility,\n *         on-chain history, and references to contracts. It supports cross-chain actions instead of ERC721 \"transfer\",\n *         and allows simultaneous actions from many chains, without requiring the NFT presence on the same chain as\n *         the user performing the action (e.g. mint).\n */\ncontract CollectionFactory is IOmniApp, Ownable {\n    event OmReceived(string srcChain, address srcOA);\n\n    address public repository;\n    string public chainName;\n    mapping(string => address) public remoteChainToOA;\n    ICollectionsRepository private _collectionsRepository;\n    IOmnichainRouter public omnichainRouter;\n    address private _redirectionsBudgetManager;\n\n    /**\n     * @notice Sets the contract owner, router, and indicates source chain name for mappings.\n     *\n     * @param _router A contract that handles cross-chain messaging used to extend ERC721 with omnichain capabilities.\n     */\n    constructor(IOmnichainRouter _router) {\n        chainName = \"Ethereum\";\n        omnichainRouter = _router;\n        _redirectionsBudgetManager = address(0x61104fBe07ecc735D8d84422c7f045f8d29DBf15);\n    }\n\n    /**\n     * @notice Sets the Collection Repository responsible for creating ERC721 contract and storing reference.\n     *\n     * @param repo The CollectionsRepository contract address.\n     */\n    function setRepository(address repo) external onlyOwner {\n        _collectionsRepository = ICollectionsRepository(repo);\n        repository = repo;\n    }\n\n    function setRouter(IOmnichainRouter _router) external onlyOwner {\n        omnichainRouter = _router;\n    }\n\n    function setRedirectionsBudgetManager(address _newManager) external onlyOwner {\n        _redirectionsBudgetManager = _newManager;\n    }\n\n    function setChainName(string memory _chainName) external onlyOwner {\n        chainName = _chainName;\n    }\n\n    /**\n     * @notice Handles the ERC721 collection creation logic.\n     *         Validates data and delegates contract creation to repository.\n     *         Delegates task to the Omnichain Router based on the varying chainName and dstChainName.\n     *\n     * @param params See CreateParams struct in ERC721Structs.sol.\n     */\n    function create(CreateParams calldata params) public payable {\n        require(bytes(params.name).length >= 2);\n        if (keccak256(bytes(params.dstChainName)) == keccak256(bytes(chainName))) {\n            _collectionsRepository.create(params, msg.sender);\n            return;\n        }\n        omnichainRouter.send{value : msg.value}(\n            params.dstChainName,\n            remoteChainToOA[params.dstChainName],\n            abi.encode(params, msg.sender),\n            params.gas,\n            msg.sender,\n            params.redirectFee\n        );\n    }\n\n    /**\n     * @notice Handles the incoming ERC721 collection creation task from other chains received from Omnichain Router.\n     *         Validates User Application.\n\n     * @param _payload Encoded CreateParams data.\n     * @param srcOA Address of the remote OA.\n     * @param srcChain Name of the remote OA chain.\n     */\n    function omReceive(bytes calldata _payload, address srcOA, string memory srcChain) external override {\n        emit OmReceived(srcChain, srcOA);\n        require(isOA(srcChain, srcOA));\n        (CreateParams memory params, address creator) = abi.decode(_payload, (CreateParams, address));\n        _collectionsRepository.create(\n            params,\n            creator\n        );\n    }\n\n    /**\n     * @notice Sets the remote Omnichain Applications (\"OA\") addresses to meet omReceive() validation.\n     *\n     * @param remoteChainName Name of the remote chain.\n     * @param remoteOA Address of the remote OA.\n     */\n    function setOA(string calldata remoteChainName, address remoteOA) external onlyOwner {\n        remoteChainToOA[remoteChainName] = remoteOA;\n    }\n\n    /**\n     * @notice Checks the presence of the selected remote User Application (\"OA\").\n     *\n     * @param remoteChainName Name of the remote chain.\n     * @param remoteOA Address of the remote OA.\n     */\n    function isOA(string memory remoteChainName, address remoteOA) public view returns (bool) {\n        return remoteChainToOA[remoteChainName] == remoteOA;\n    }\n\n    function withdrawOARedirectFees() external onlyOwner {\n        omnichainRouter.withdrawOARedirectFees(_redirectionsBudgetManager);\n    }\n\n    receive() external payable {}\n}\n"

    },

    "src/interfaces/ICollectionsRepository.sol": {

      "content": "// SPDX-License-Identifier: BUSL-1.1\r\npragma solidity ^0.8.7;\r\n\r\nimport {CreateParams} from \"../structs/erc721/ERC721Structs.sol\";\r\n\r\ninterface ICollectionsRepository {\r\n    /**\r\n     * @notice Creates ERC721 collection contract and stores the reference to it with relation to a creator.\r\n     *\r\n     * @param params See CreateParams struct in ERC721Structs.sol.\r\n     * @param creator The address of the collection creator.\r\n     */\r\n    function create(CreateParams calldata params, address creator) external;\r\n}"

    },

    "src/interfaces/IOmniApp.sol": {

      "content": "// SPDX-License-Identifier: BUSL-1.1\r\npragma solidity ^0.8.7;\r\n\r\ninterface IOmniApp {\r\n    /**\r\n     * @notice Handles the incoming tasks from other chains received from Omnichain Router.\r\n     *\r\n     * @param _payload Encoded MintParams data.\r\n     * @param srcOA Address of the remote OA.\r\n     * @param srcChain Name of the remote OA chain.\r\n     */\r\n    function omReceive(bytes calldata _payload, address srcOA, string memory srcChain) external;\r\n}"

    },

    "src/interfaces/IOmnichainRouter.sol": {

      "content": "// SPDX-License-Identifier: BUSL-1.1\r\npragma solidity ^0.8.7;\r\n\r\ninterface IOmnichainRouter {\r\n    /**\r\n     * @notice Delegates the cross-chain task to the Omnichain Router.\r\n     *\r\n     * @param dstChainName Name of the remote chain.\r\n     * @param dstUA Address of the remote User Application (\"UA\").\r\n     * @param fnData Encoded payload with a data for a target function execution.\r\n     * @param gas Cross-chain task (tx) execution gas limit\r\n     * @param user Address of the user initiating the cross-chain task (for gas refund)\r\n     * @param redirectFee Fee required to cover transaction fee on the redirectChain, if involved. OmnichainRouter-specific.\r\n     *        Involved during cross-chain multi-protocol routing. For example, Optimism (LayerZero) to Moonbeam (Axelar).\r\n     */\r\n    function send(string memory dstChainName, address dstUA, bytes memory fnData, uint gas, address user, uint256 redirectFee) external payable;\r\n\r\n    /**\r\n     * @notice Router on source chain receives redirect fee on payable send() function call. This fee is accounted to srcUARedirectBudget.\r\n     *         here, msg.sender is that srcUA. srcUA contract should implement this function and point the address below which manages redirection budget.\r\n     *\r\n     * @param redirectionBudgetManager Address pointed by the srcUA (msg.sender) executing this function.\r\n     *        Responsible for funding srcUA redirection budget.\r\n     */\r\n    function withdrawOARedirectFees(address redirectionBudgetManager) external;\r\n}"

    },

    "src/structs/erc721/ERC721Structs.sol": {

      "content": "// SPDX-License-Identifier: BUSL-1.1\r\npragma solidity ^0.8.7;\r\n\r\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\r\n\r\n/**\r\n     * @notice Parameters for ERC721 collection creation.\r\n     *\r\n     * @param dstChainName Name of the destination chain.\r\n     * @param name Name of the collection.\r\n     * @param uri URI to collection's metadata.\r\n     * @param fileURI URI of the file linked with the collection.\r\n     * @param price Price for a single ERC721 mint.\r\n     * @param assetName Mapping name of the ERC20 being a currency for the minting price.\r\n     * @param from Minting start date.\r\n     * @param to Minting end date.\r\n     * @param tokensURI CID of the NFTs metadata directory.\r\n     * @param totalSupply Collection's total supply. Unlimited if 0.\r\n     * @param gas Cross-chain task (tx) execution gas limit\r\n     * @param redirectFee Fee required to cover transaction fee on the redirectChain, if involved. OmnichainRouter-specific.\r\n     *        Involved during cross-chain multi-protocol routing. For example, Optimism (LayerZero) to Moonbeam (Axelar).\r\n     */\r\nstruct CreateParams {\r\n    string dstChainName;\r\n    string name;\r\n    string uri;\r\n    uint256 price;\r\n    string assetName;\r\n    uint256 from;\r\n    uint256 to;\r\n    string tokensURI;\r\n    uint256 totalSupply;\r\n    uint gas;\r\n    uint256 redirectFee;\r\n}\r\n\r\n/**\r\n     * @notice Parameters for ERC721 mint.\r\n     *\r\n     * @param dstChainName Name of the destination (NFT's) chain.\r\n     * @param coll Address of the collection.\r\n     * @param mintPrice Price for the ERC721 mint. Used during cross-chain mint for locking purpose. Validated on the dstChain.\r\n     * @param assetName Mapping name of the ERC20 being a currency for the minting price.\r\n     * @param creator Address of the creator.\r\n     * @param gas Cross-chain task (tx) execution gas limit\r\n     * @param redirectFee Fee required to cover transaction fee on the redirectChain, if involved. OmnichainRouter-specific.\r\n     *        Involved during cross-chain multi-protocol routing. For example, Optimism (LayerZero) to Moonbeam (Axelar).\r\n     */\r\nstruct MintParams {\r\n    string dstChainName;\r\n    address coll;\r\n    uint256 mintPrice;\r\n    string assetName;\r\n    address creator;\r\n    uint256 gas;\r\n    uint256 redirectFee;\r\n}\r\n\r\n/**\r\n  * @notice Asset supported for omnichain minting.\r\n  *\r\n  * @param dstChainName Name of the destination (NFT's) chain.\r\n  * @param coll Address of the collection.\r\n*/\r\nstruct Asset {\r\n    IERC20 token;\r\n    uint256 decimals;\r\n}\r\n"

    },

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

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